#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="/var/www/html"

echo "[1/4] Install/start Apache (apache2 - Ubuntu)"
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y apache2
else
  echo "This script expects Ubuntu/Debian (apt-get not found)." >&2
  exit 1
fi

sudo systemctl enable apache2 >/dev/null 2>&1 || true
sudo systemctl start apache2

echo "[2/4] Clear Apache web root"
sudo rm -rf "${TARGET_DIR:?}/"* "${TARGET_DIR:?}/".[^.]* "${TARGET_DIR:?}/"..?* 2>/dev/null || true

echo "[3/4] Copy repo web files to ${TARGET_DIR}"
# Copy all files in repo root except docs + this script itself.
# Expectation: students will clone this repo and run this script from the repo root.
for f in * .*; do
  # skip '.' and '..'
  if [[ "$f" == "." || "$f" == ".." ]]; then
    continue
  fi
  # skip hidden files/folders besides the web assets (we keep this simple)
  if [[ "$f" == .git* || "$f" == .github* ]]; then
    continue
  fi
  if [[ "$f" == "README.md" || "$f" == "deploy-ec2-apache.sh" ]]; then
    continue
  fi
  # Only copy regular files and directories (static site content).
  if [[ -e "$f" ]]; then
    sudo cp -r "$f" "${TARGET_DIR}/"
  fi
done

echo "[4/4] Restart Apache"
sudo systemctl restart apache2

echo "Deployment complete."
echo "Test from EC2:"
echo "  curl -I http://localhost"
echo "Open from your laptop:"
echo "  http://<PUBLIC-IP>"

