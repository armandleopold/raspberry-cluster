#!/bin/bash

declare -A pis=(
  [pi1]=2239
  [pi2]=2240
  [pi3]=2241
  [pi4]=2242
)

dirs=(
  "/var/lib/rancher"
  "/mnt/sdcard"
  "/var/openebs/local"
)

backup_root=/mnt/g/raspi_backups

for pi in "${!pis[@]}"; do
  port=${pis[$pi]}
  echo "🟢 Synchronisation de $pi via port $port..."

  for dir in "${dirs[@]}"; do
    dirname=$(basename "$dir")
    dest="$backup_root/$pi/$dirname"

    mkdir -p "$dest"

    echo "   📁 $dir → $dest"

    if [[ "$dir" == "/var/lib/rancher" ]]; then
      # Exclure containerd pour /var/lib/rancher uniquement
      rsync -avz -e "ssh -p $port" \
        --rsync-path="sudo rsync" \
        --exclude="k3s/agent/containerd/" \
        pi@localhost:"$dir/" "$dest/"
    else
      rsync -avz -e "ssh -p $port" \
        --rsync-path="sudo rsync" \
        pi@localhost:"$dir/" "$dest/"
    fi
  done
done

echo "✅ Synchronisation avec sudo terminée."
