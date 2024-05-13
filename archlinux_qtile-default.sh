#!/bin/bash

# Script de instalación de Arch Linux

# Actualizar el reloj del sistema
timedatectl set-ntp true

# Seleccionar partición de destino (reemplaza /dev/sdX con la partición deseada)
DISK="/dev/sda"

# Borrar la tabla de particiones existente
sgdisk --zap-all "$DISK"

# Crear la nueva tabla de particiones
sgdisk --clear \
       --new=1::+512M --typecode=1:ef00 --change-name=1:"EFI System" \
       --new=2::+2G --typecode=2:8200 --change-name=2:"Linux Swap" \
       --new=3 --typecode=3:8300 --change-name=3:"Linux Filesystem" \
       "$DISK"

# Formatear las particiones
mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"

# Montar la partición raíz
mount "${DISK}3" /mnt

# Crear y activar la partición de swap
swapon "${DISK}2"

# Crear y montar la partición EFI
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi

# Instalar el sistema base
pacstrap /mnt base linux linux-firmware

# Generar archivo fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Cambiar al entorno chroot
arch-chroot /mnt /bin/bash <<EOF

# Zona horaria
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# Idioma y localización
echo "es_ES.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf

# Configuración del teclado
echo "KEYMAP=es" > /etc/vconsole.conf

# Nombre de la máquina
echo "NombreDeEquipo" > /etc/hostname

# Configuración de hosts
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    NombreDeEquipo.localdomain NombreDeEquipo" >> /etc/hosts

# Configuración de la contraseña de root
echo "ContraseñaDeRoot" | passwd --stdin root

# Instalación de GRUB como gestor de arranque
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Crear un usuario y establecer contraseña
useradd -m -G wheel usuario
echo "ContraseñaDeUsuario" | passwd --stdin usuario

# Permitir que el usuario use sudo
sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

# Habilitar servicios necesarios
systemctl enable NetworkManager

EOF

# Finalizar instalación
echo "La instalación ha finalizado. Reinicia el sistema."
