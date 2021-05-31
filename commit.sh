#!/usr/bin/env bash

set -e

git pull

echo -n "Formatting & Checking..."
find . -type f -name '*.nix' -exec nixfmt {} +
nix flake update
nix flake check --no-build
echo "Done."

echo -n "Adding to git..."
git add --all
echo "Done."

git status
read -n 1 -s -r -p "Press any key to continue"

echo "Commiting..."
echo "Enter commit message: "
read -r commitMessage
git commit -m "$commitMessage"
echo "Done."

echo -n "Pushing..."
git push
echo "Done."
