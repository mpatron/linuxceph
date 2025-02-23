#!/bin/bash
echo "=== Maj OS ==="
sudo apt autoclean -yqq && sudo apt update -yqq && sudo apt upgrade -yqq && sudo apt autoremove --purge -yqq

echo "=== Inventory Ansible ==="
grep -v '^\s*$\|^\s*\#' /etc/ansible/hosts

echo "=== Rust update ==="
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
[[ -f $(which rustup) ]] && rustup upgrade || echo "Rust non installé"

echo "=== Maj Pip3 ==="
if [ -f $(which python3) ]; then
  FILE=~/venv/bin/activate
  sudo apt install -yqq python3-pip python3-venv jq && [[ ! -f "$FILE" ]] && python3 -m venv ~/venv  
  if [ -f "$FILE" ]; then
    echo "Activate VenV"
    source ~/venv/bin/activate
    pip install --upgrade ansible ansible-lint molecule molecule-plugins ansible-dev-tools
    pip list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip install --upgrade
  else 
    # pip list --user --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip install --user --upgrade
    echo "Interdiction de faire une mise à jour pip pour l'OS."
  fi
else
  echo "Python3 non installé"
fi

echo "=== SNAP ==="
[[ -f $(which snap) ]] && sudo snap refresh || echo "SNAP non installé"

echo "=== Clean ==="
[[ -d ~/.cache/thumbnails ]] && find ~/.cache/thumbnails -name '*.png' -delete

echo "=== OS need to restart ? ==="
if [ -f /var/run/reboot-required ]; then
  echo 'reboot required'
else
  echo 'no reboot need'
fi
