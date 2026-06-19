#!/usr/bin/env bash

# =============================================================
# Auto Add, Commit, and Push a directory to GitHub every 6 hours
# =============================================================

# Exit immediately if any command fails
set -e

# Colors
GRN='\033[1;32m'
RED='\033[1;31m'
YEL='\033[1;33m'
RST='\033[0m'

# Check for directory argument
if [ -z "$1" ]; then
  echo -e "${RED}Usage:${RST} $0 <directory>"
  exit 1
fi

DIR="$1"
TIMESTAMP=$(date '+%d-%m-%y %H:%M:%S')
COMMIT_MSG="$TIMESTAMP"

# Go to directory
if [ ! -d "$DIR" ]; then
  echo -e "${RED}Error:${RST} Directory '$DIR' not found!"
  exit 1
fi

cd "$DIR"

# Check if it's a git repository
if [ ! -d ".git" ]; then
  echo -e "${YEL}Not a git repository. Initializing...${RST}"
  git init
  echo -e "${YEL}Enter remote URL (e.g., git@github.com:user/repo.git):${RST}"
  read -r REMOTE_URL
  git remote add origin "$REMOTE_URL"
fi

# Detect branch automatically
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

# Add, commit, push
echo -e "${YEL}Adding changes...${RST}"
git add .

echo -e "${YEL}Committing with message:${RST} '$COMMIT_MSG'"
git commit -m "$COMMIT_MSG" || echo -e "${YEL}Nothing new to commit.${RST}"

echo -e "${YEL}Pushing to branch '${BRANCH}'...${RST}"
git push origin "$BRANCH" 2>/dev/null || {
  echo -e "${RED}Push failed.${RST} Ensure the branch exists and remote is correct."
  exit 1
}

echo -e "${GRN}✅ Successfully pushed '${DIR}' to GitHub at ${TIMESTAMP}!${RST}"
