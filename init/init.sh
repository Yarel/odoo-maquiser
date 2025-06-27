#!/bin/bash
set -e

export PGPASSWORD=odoo

echo "Esperando que la base de datos esté lista..."
until pg_isready -h db -U odoo; do
  sleep 2
done
echo "Base de datos lista."

echo "Eliminando base 'odoo' si existe..."
dropdb -h db -U odoo --if-exists odoo

echo "Creando base de datos 'odoo'..."
createdb -h db -U odoo odoo

echo "Instalando módulos base y maquiser_base..."
exec /entrypoint.sh odoo -d odoo -i base,maquiser_base --without-demo=all --stop-after-init

