#!/usr/bin/env bash
# Commit-gated restart with automatic rollback.
#   scripts/deploy.sh
# 1. refuses to run with uncommitted changes (so a rollback target always exists)
# 2. restarts quickshell.service
# 3. healthy after a few seconds -> tags this commit `last-good`
#    failed                       -> checks out `last-good` (detached, non-destructive:
#                                    your branch is untouched) and restarts again
# Catches STARTUP failures (bad import, syntax error). Runtime QML errors don't
# kill the process, so watch `journalctl --user -u quickshell -f` for those.
set -u
cd "$(dirname "$0")/.." || exit 1

if ! git symbolic-ref -q HEAD >/dev/null; then
    echo "detached HEAD (a previous rollback?). Run: git switch main   — then fix and commit."
    exit 1
fi
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "uncommitted changes — commit first so there is something to roll back to."
    exit 1
fi

systemctl --user restart quickshell.service
sleep "${DEPLOY_WAIT:-5}"

if systemctl --user is-active --quiet quickshell.service; then
    git tag -f last-good >/dev/null
    echo "ok: $(git rev-parse --short HEAD) is now last-good"
    exit 0
fi

echo "FAILED to start — rolling back."
journalctl --user -u quickshell.service -n 15 --no-pager 2>/dev/null
if git rev-parse -q --verify refs/tags/last-good >/dev/null; then
    git checkout -q last-good
    systemctl --user restart quickshell.service
    echo "now running last-good ($(git rev-parse --short HEAD)), detached."
    echo "your commit is still on the branch: git switch main, fix it, commit, deploy again."
else
    echo "no last-good tag yet (first deploy) — nothing to roll back to."
fi
exit 1
