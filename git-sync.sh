#!/bin/bash

# Git Commit & Sync Script - /git-sync.sh
# Syncs local repository with remote and optionally triggers Cloud CI/CD

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Trackify git sync...${NC}"

# Stage all changes
echo -e "${BLUE}Staging changes...${NC}"
git add .

# Commit changes
echo -e "${BLUE}Committing changes...${NC}"
read -p "Enter commit message: " commit_message
git commit -m "$commit_message" || echo "No changes to commit"

# Fetch latest changes from remote
echo -e "${BLUE}Fetching from remote...${NC}"
git fetch origin

# Pull latest changes to current branch
echo -e "${BLUE}Pulling changes...${NC}"
git pull origin "$(git rev-parse --abbrev-ref HEAD)"

# Push local commits to remote
echo -e "${BLUE}Pushing changes...${NC}"
git push origin "$(git rev-parse --abbrev-ref HEAD)"

echo -e "${GREEN}Git sync completed successfully!${NC}"
echo ""

# ==========================================
# 🚀 CLOUD PIPELINE TRIGGER
# ==========================================
echo -e "${YELLOW}--- Release Manager ---${NC}"
read -p "Do you want to trigger a Cloud Release for these changes? (y/n): " trigger_release

if [[ "$trigger_release" == "y" || "$trigger_release" == "Y" ]]; then
    read -p "Enter version tag (e.g., v1.0.2): " version_tag
    
    echo -e "${BLUE}Tagging release $version_tag...${NC}"
    git tag "$version_tag"
    git push origin "$version_tag"
    
    echo -e "${GREEN}Boom! Release tag pushed.${NC}"
    echo -e "${GREEN}The GitHub Cloud Servers are now compiling your apps!${NC}"
else
    echo -e "${BLUE}Skipping release. Have a great day!${NC}"
fi