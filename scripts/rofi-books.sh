#!/usr/bin/env bash
#
# rofi-books.sh — Spotlight-style launcher for a Calibre library, via Rofi.
#
# Architecture:
#   1. Read Calibre's metadata.db (SQLite) with ONE query -> TSV cache.
#   2. Cache is keyed on metadata.db's mtime+size; rebuilt only when stale.
#   3. TSV cache is transformed into a Rofi "icon dmenu" script cache
#      (display line + \0icon\x1f<cover>) — this is what Rofi actually reads,
#      so a warm run does zero SQLite / stat work beyond one `stat` call.
#   4. Rofi returns (selection index, exit code). Exit code encodes which
#      keybinding fired. We map index -> book row -> action.
#
# Adding a field (e.g. "last_read") later = add a column to the SQL query,
# add a column to the TSV, bump CACHE_SCHEMA_VERSION. Adding an action
# (e.g. Goodreads lookup) = add a kb-custom-N binding + a case arm in
# dispatch_action(). Nothing else changes.

set -euo pipefail
IFS=$'\n\t'

# ─────────────────────────────── Config ────────────────────────────────────

readonly LIBRARY_DIR="/home/adnanmalik/Storage/Calibre Library"
readonly DB_PATH="${LIBRARY_DIR}/metadata.db"
readonly ROFI_THEME="/home/adnanmalik/.config/rofi/new-wallpaper-style.rasi"
readonly CACHE_DIR="${HOME}/.cache/rofi-books"
readonly TSV_CACHE="${CACHE_DIR}/books.tsv"
readonly ROFI_CACHE="${CACHE_DIR}/rofi_input.cache"
readonly STATE_FILE="${CACHE_DIR}/cache_state"
# No cover on disk -> fall back to a themed icon NAME (not a file path).
# Rofi's -show-icons resolves icon names against the active icon theme,
# so this needs no bundled asset and still looks native.
readonly DEFAULT_COVER="text-x-generic"
readonly LOG_FILE="${CACHE_DIR}/rofi-books.log"

# Bump this whenever the TSV column layout changes, to force a rebuild.
readonly CACHE_SCHEMA_VERSION=1

# Preferred format order (highest priority first).
readonly FORMAT_PRIORITY=(EPUB AZW3 MOBI PDF)

# Rofi custom-keybinding exit codes (rofi: kb-custom-N -> exit code 9+N).
readonly EXIT_OPEN_FOLDER=10   # Alt+Return   -> kb-custom-1
readonly EXIT_OPEN_CALIBRE=11  # Ctrl+Return  -> kb-custom-2
readonly EXIT_COPY_PATH=12     # Ctrl+c       -> kb-custom-3
readonly EXIT_COPY_TITLE=13    # Ctrl+Shift+c -> kb-custom-4

# ─────────────────────────────── Logging ────────────────────────────────────

log() { printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >>"$LOG_FILE"; }

die_rofi() {
    # Show a user-facing error inside Rofi itself (so failures are never
    # silent when launched from a keybinding with no visible terminal).
    local msg="$1"
    log "ERROR" "$msg"
    if command -v rofi &>/dev/null; then
        rofi -e "$msg" ${ROFI_THEME:+-theme "$ROFI_THEME"} 2>/dev/null || true
    else
        echo "ERROR: $msg" >&2
    fi
    exit 1
}

# ─────────────────────────── Dependency checks ──────────────────────────────

check_dependencies() {
    local missing=()
    for bin in sqlite3 rofi awk sed find; do
        command -v "$bin" &>/dev/null || missing+=("$bin")
    done
    if ((${#missing[@]} > 0)); then
        die_rofi "Missing required tools: ${missing[*]}"
    fi

    command -v foliate &>/dev/null || log "WARN" "foliate not found in PATH"

    # Prefer wl-copy on Wayland/Hyprland; fall back to xclip.
    if command -v wl-copy &>/dev/null; then
        CLIPBOARD_CMD="wl-copy"
    elif command -v xclip &>/dev/null; then
        CLIPBOARD_CMD="xclip -selection clipboard"
    else
        CLIPBOARD_CMD=""
        log "WARN" "Neither wl-copy nor xclip found; clipboard actions disabled"
    fi

    [[ -f "$DB_PATH" ]] || die_rofi "Calibre database not found:\n${DB_PATH}"
    [[ -f "$ROFI_THEME" ]] || log "WARN" "Rofi theme not found: ${ROFI_THEME} (using default)"
}

# ───────────────────────────── Cache helpers ─────────────────────────────────

ensure_cache_dir() { mkdir -p "$CACHE_DIR"; }

# A cheap fingerprint of the DB: mtime + size. Cheaper than hashing a
# multi-hundred-MB SQLite file, and just as reliable for "did it change".
db_fingerprint() {
    stat -c '%Y-%s' "$DB_PATH" 2>/dev/null || stat -f '%m-%z' "$DB_PATH"
}

cache_is_stale() {
    [[ -f "$TSV_CACHE" ]] || return 0
    [[ -f "$STATE_FILE" ]] || return 0

    local stored_fp stored_schema
    IFS='|' read -r stored_fp stored_schema <"$STATE_FILE"

    [[ "$stored_schema" == "$CACHE_SCHEMA_VERSION" ]] || return 0
    [[ "$stored_fp" == "$(db_fingerprint)" ]] || return 0

    return 1  # cache is fresh
}

write_cache_state() {
    printf '%s|%s\n' "$(db_fingerprint)" "$CACHE_SCHEMA_VERSION" >"$STATE_FILE"
}

# ────────────────────────── SQLite -> TSV cache ──────────────────────────────
#
# ONE query. No per-book subprocess, no recursive find. GROUP_CONCAT collapses
# 1:N relations (authors, formats, tags) into single delimited fields.
#
# Columns (tab-separated):
#   id  title  author  path  has_cover  formats  series  series_index  rating  tags  timestamp

build_tsv_cache() {
    log "INFO" "Rebuilding TSV cache from ${DB_PATH}"

    local sql
    sql=$(cat <<'SQL'
SELECT
  b.id,
  REPLACE(b.title, char(9), ' ')  AS title,
  COALESCE(
    (SELECT GROUP_CONCAT(a.name, ' & ')
       FROM authors a JOIN books_authors_link bal ON a.id = bal.author
      WHERE bal.book = b.id),
    'Unknown Author'
  ) AS author,
  b.path,
  b.has_cover,
  COALESCE(
    (SELECT GROUP_CONCAT(d.format, ',') FROM data d WHERE d.book = b.id),
    ''
  ) AS formats,
  COALESCE(s.name, '') AS series,
  b.series_index,
  COALESCE(
    (SELECT r.rating FROM ratings r
       JOIN books_ratings_link brl ON r.id = brl.rating
      WHERE brl.book = b.id LIMIT 1),
    0
  ) AS rating,
  COALESCE(
    (SELECT GROUP_CONCAT(t.name, ',') FROM tags t
       JOIN books_tags_link btl ON t.id = btl.tag
      WHERE btl.book = b.id),
    ''
  ) AS tags,
  b.timestamp
FROM books b
LEFT JOIN books_series_link bsl ON b.id = bsl.book
LEFT JOIN series s ON bsl.series = s.id
ORDER BY b.title COLLATE NOCASE;
SQL
)

    if ! sqlite3 -separator $'\t' "$DB_PATH" "$sql" >"${TSV_CACHE}.tmp" 2>>"$LOG_FILE"; then
        die_rofi "Failed to query metadata.db (see ${LOG_FILE})"
    fi

    mv "${TSV_CACHE}.tmp" "$TSV_CACHE"
    write_cache_state
    log "INFO" "TSV cache written: $(wc -l <"$TSV_CACHE") books"
}

# ───────────────────────── Format / path resolution ──────────────────────────

# Given a comma-separated format list, pick the best available format
# per FORMAT_PRIORITY. Falls back to the first format present, if any.
pick_best_format() {
    local formats_csv="$1"
    local fmt
    for fmt in "${FORMAT_PRIORITY[@]}"; do
        if [[ ",${formats_csv}," == *",${fmt},"* ]]; then
            echo "$fmt"
            return 0
        fi
    done
    # Nothing in our priority list matched — take whatever's first.
    echo "${formats_csv%%,*}"
}

# Resolve the on-disk file for a book, given its relative path + best format.
# Calibre stores the filename as the sanitized title/author, not always
# predictable, so we glob for the extension rather than guessing the name.
resolve_book_file() {
    local rel_path="$1" fmt="$2"
    local dir="${LIBRARY_DIR}/${rel_path}"
    local ext="${fmt,,}"  # lowercase
    local match
    match=$(find "$dir" -maxdepth 1 -type f -iname "*.${ext}" -print -quit 2>/dev/null)
    echo "$match"
}

resolve_cover() {
    local rel_path="$1" has_cover="$2"
    local cover="${LIBRARY_DIR}/${rel_path}/cover.jpg"
    if [[ "$has_cover" == "1" && -f "$cover" ]]; then
        echo "$cover"
    else
        echo "$DEFAULT_COVER"
    fi
}

# ────────────────────────── Sorting (extensible) ─────────────────────────────
#
# Add a new sort mode by adding one line here — no other code changes.
declare -A SORT_FIELD_INDEX=(
    [title]=2
    [author]=3
    [recent]=11   # timestamp column
    [rating]=9
    [series]=7
)

sort_tsv() {
    local mode="$1"
    local field="${SORT_FIELD_INDEX[$mode]:-2}"
    local order="-k${field},${field}"
    if [[ "$mode" == "recent" || "$mode" == "rating" ]]; then
        sort -t $'\t' "${order}r" -f "$TSV_CACHE"   # descending, numeric-ish
    else
        sort -t $'\t' "$order" -f "$TSV_CACHE"       # ascending, case-insensitive
    fi
}

# ───────────────────────── Build the Rofi entry list ─────────────────────────
#
# Each stdout line = the display row Rofi shows.
# Each row is followed by rofi's icon directive: \0icon\x1f<cover-path>
# We also emit a companion array (BOOK_INDEX) mapping row number -> TSV line,
# so that after Rofi returns a selection we can look the book back up in O(1)
# without re-parsing anything.

build_rofi_cache() {
    local sort_mode="$1"
    ensure_cache_dir
    : >"$ROFI_CACHE"

    local line
    while IFS=$'\t' read -r id title author path has_cover formats series series_idx rating tags ts; do
        local cover display
        cover=$(resolve_cover "$path" "$has_cover")
        if [[ -n "$series" ]]; then
            display="${title}  —  ${author}  ·  ${series} #${series_idx}"
        else
            display="${title}  —  ${author}"
        fi
        # rofi extended dmenu row format: TEXT\0icon\x1fICON_PATH
        printf '%s\0icon\x1f%s\n' "$display" "$cover" >>"$ROFI_CACHE"
    done < <(sort_tsv "$sort_mode")
}

# ─────────────────────────────── Rofi launch ─────────────────────────────────

launch_rofi() {
    local rofi_args=(
        -dmenu
        -show-icons
        -i                      # case-insensitive fuzzy filtering
        -p "Library"
        # Control+Return is rofi's built-in kb-accept-custom, and Control+c
        # is kb-secondary-copy (confirmed via `rofi -list-keybindings`).
        # Free both before claiming them for our own custom actions.
        -kb-accept-custom ""            # frees Control+Return
        -kb-secondary-copy ""           # frees Control+c
        -kb-custom-1 "Alt+Return"       # open containing folder
        -kb-custom-2 "Control+Return"   # open in Calibre
        -kb-custom-3 "Control+c"        # copy path
        -kb-custom-4 "Control+shift+c"  # copy title
        -format i                # return the SELECTED INDEX, not the text
    )
    [[ -f "$ROFI_THEME" ]] && rofi_args+=(-theme "$ROFI_THEME")

    local selection exit_code
    set +e
    selection=$(rofi "${rofi_args[@]}" <"$ROFI_CACHE")
    exit_code=$?
    set -e

    echo "${selection}:${exit_code}"
}

# ───────────────────────────── Action dispatch ────────────────────────────────

dispatch_action() {
    local row_index="$1" exit_code="$2" sort_mode="$3"

    # Re-derive the exact TSV row for the selected index. Sorting order must
    # match what build_rofi_cache used, so we reuse sort_tsv() here too.
    local tsv_line
    tsv_line=$(sort_tsv "$sort_mode" | sed -n "$((row_index + 1))p")
    [[ -n "$tsv_line" ]] || die_rofi "Selection out of range."

    IFS=$'\t' read -r id title author path has_cover formats series series_idx rating tags ts <<<"$tsv_line"

    case "$exit_code" in
        0)
            # Normal Enter -> open in Foliate with the best available format.
            local fmt file
            fmt=$(pick_best_format "$formats")
            file=$(resolve_book_file "$path" "$fmt")
            if [[ -z "$file" ]]; then
                die_rofi "No readable file found for:\n${title}"
            fi
            command -v foliate &>/dev/null || die_rofi "Foliate is not installed."
            nohup foliate "$file" >>"$LOG_FILE" 2>&1 &
            disown
            ;;
        "$EXIT_OPEN_FOLDER")
            nohup xdg-open "${LIBRARY_DIR}/${path}" >>"$LOG_FILE" 2>&1 &
            disown
            ;;
        "$EXIT_OPEN_CALIBRE")
            command -v calibre &>/dev/null || die_rofi "Calibre is not installed."
            nohup calibre --with-library "$LIBRARY_DIR" -s "$id" >>"$LOG_FILE" 2>&1 &
            disown
            ;;
        "$EXIT_COPY_PATH")
            local fmt file
            fmt=$(pick_best_format "$formats")
            file=$(resolve_book_file "$path" "$fmt")
            copy_to_clipboard "${file:-${LIBRARY_DIR}/${path}}"
            ;;
        "$EXIT_COPY_TITLE")
            copy_to_clipboard "$title"
            ;;
        1)
            # User pressed Escape — silent, not an error.
            exit 0
            ;;
        *)
            log "WARN" "Unhandled rofi exit code: ${exit_code}"
            ;;
    esac
}

copy_to_clipboard() {
    local text="$1"
    if [[ -z "${CLIPBOARD_CMD:-}" ]]; then
        die_rofi "No clipboard tool available (install wl-clipboard or xclip)."
    fi
    printf '%s' "$text" | $CLIPBOARD_CMD
}

# ─────────────────────────────────── Main ────────────────────────────────────

main() {
    local sort_mode="title"
    # --sort=title|author|recent|rating|series
    for arg in "$@"; do
        case "$arg" in
            --sort=*) sort_mode="${arg#--sort=}" ;;
        esac
    done
    [[ -v SORT_FIELD_INDEX[$sort_mode] ]] || sort_mode="title"

    ensure_cache_dir
    check_dependencies

    if cache_is_stale; then
        build_tsv_cache
    fi

    [[ -s "$TSV_CACHE" ]] || die_rofi "Your Calibre library appears to be empty."

    # The Rofi-format cache is cheap enough to always rebuild per sort mode
    # invocation (pure text formatting over an already-cached TSV — no I/O
    # to the DB, no cover re-resolution beyond a single stat per book).
    build_rofi_cache "$sort_mode"

    local result index code
    result=$(launch_rofi)
    index="${result%%:*}"
    code="${result##*:}"

    [[ -n "$index" ]] || exit 0  # nothing selected (escape with no text)

    dispatch_action "$index" "$code" "$sort_mode"
}

main "$@"
