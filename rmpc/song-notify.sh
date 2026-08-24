#!/usr/bin/env bash

LAST_SONG=""

while true; do
    # Wait for any player event
    mpc idle player > /dev/null

    # Get current song identifier (file path works well)
    CURRENT_SONG=$(mpc current -f "%file%")

    # Only notify if the song changed
    if [[ "$CURRENT_SONG" != "$LAST_SONG" ]]; then
        LAST_SONG="$CURRENT_SONG"

        TITLE=$(mpc current -f "%title%")
        ARTIST=$(mpc current -f "%artist%")
        ALBUM=$(mpc current -f "%album%")

        # Try MPRIS album art
        ART_URL=$(playerctl -p mpd metadata mpris:artUrl 2>/dev/null)
        if [[ "$ART_URL" == file://* ]]; then
            ART_PATH="${ART_URL#file://}"
        else
            ART_PATH=""
        fi

        # Fallback → search for cover in music folder
        if [[ ! -f "$ART_PATH" ]]; then
            FILE=$(mpc current -f "%file%")
            MUSIC_DIR="$HOME/Music"
            DIR=$(dirname "$MUSIC_DIR/$FILE")

            for name in cover.jpg cover.png folder.jpg folder.png; do
                if [[ -f "$DIR/$name" ]]; then
                    ART_PATH="$DIR/$name"
                    break
                fi
            done
        fi

        # Send notification
        notify-send \
            "🎵 $TITLE" \
            "$ARTIST — $ALBUM" \
            -i "$ART_PATH"
    fi
done
