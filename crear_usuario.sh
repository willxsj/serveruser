#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor ejecuta este script con sudo."
    exit 1
fi

# Instalar Apache2 y vsftpd
echo "Instalando Apache2 y vsftpd..."
apt update
apt install -y apache2 vsftpd

# Verificar si el archivo usuarios.csv existe
if [ ! -f usuarios.csv ]; then
    echo "ERROR: No se encuentra el archivo usuarios.csv"
    exit 1
fi

# Leer archivo CSV (saltar la primera línea)
tail -n +2 usuarios.csv | while IFS=',' read -r nombre usuario; do
    echo "Procesando usuario: $usuario ($nombre)"

    # Crear carpetas
    mkdir -p "/var/www/html/$usuario/web"

    # Crear usuario si no existe
    if id "$usuario" &>/dev/null; then
        echo "El usuario $usuario ya existe, omitiendo creación."
    else
        useradd -d "/var/www/html/$usuario" -s /bin/bash "$usuario"
        echo "$usuario:1234" | chpasswd
        echo "Usuario $usuario creado con contraseña '1234'"
    fi

    # Asignar permisos
    chown -R "$usuario:$usuario" "/var/www/html/$usuario"
    chmod -R 755 "/var/www/html/$usuario"
    echo "Permisos aplicados correctamente."
    echo "-----------------------------------------"
done

echo "¡Script terminado correctamente!"
