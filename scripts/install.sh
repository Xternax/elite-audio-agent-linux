#!/bin/bash
# Elite Audio Agent - Instalación Automatizada
set -e
echo "🎵 Instalando Elite Audio Agent Linux..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm ardour lmms mixxx jack2 pipewire wine
echo "✅ Instalación completada. Ver docs/USER_GUIDE.md para más info."
