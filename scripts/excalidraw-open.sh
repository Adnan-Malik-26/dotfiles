#!/bin/bash
# open .excalidraw files in Chrome PWA
for f in "$@"; do
  /opt/google/chrome/google-chrome --profile-directory=Default --app-id=dnfpoenibinnbbckgbhendmlljoobcfg "file://$f"
done
