#!/bin/bash

# Script de instalación básica de Arch Linux

# Configuración de la zona horaria
ln -sf /usr/share/zoneinfo/Region/Americas /etc/localtime
hwclock --systohc

# Configuración del idioma y la localización
sed -i 's/#es_PE.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_PE.UTF-8" > /etc/locale.conf

# Configuración del teclado
echo "KEYMAP=es" > /etc/vconsole.conf

# Configuración del nombre del equipo
echo "name" > /etc/hostname

# Configuración de hosts
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    name.localdomain name" >> /etc/hosts

# Configuración de la contraseña de root
echo "1234" | passwd --stdin root

# Instalación de GRUB como gestor de arranque
pacman -S --noconfirm grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Instalación de paquetes adicionales
pacman -S --noconfirm networkmanager sudo

# Habilitar servicios necesarios
systemctl enable NetworkManager

# Configuración de usuario
useradd -m -G wheel usuario
echo "1234" | passwd --stdin usuario

# Configuración de sudo para el usuario
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers

# Fin de la instalación
echo "La instalación ha finalizado. Reinicia el sistema."

