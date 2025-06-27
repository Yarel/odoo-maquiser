# Makefile para gestión de proyecto Odoo - Versión Mejorada

.PHONY: all init up down restart check validate install-module install-all reinstall reset clean logs shell-odoo shell-db test backup restore help

# Variables configurables
DB_NAME ?= odoo
MODULES ?= maquiser_core,maquiser_security,maquiser_hr,maquiser_inventory,maquiser_manufacturing,maquiser_sales
ODOO_IMAGE ?= odoo:16
POSTGRES_IMAGE ?= postgres:13
PGPASSWORD ?= odoo

all: init install-all

## Inicialización
init: validate
	@echo "Iniciando contenedores..."
	@docker-compose up -d db
	@echo "Esperando inicialización de PostgreSQL (20 segundos)..."
	@sleep 20
	@docker-compose exec db bash -c "\
		if ! psql -U odoo -lqt | cut -d \| -f 1 | grep -qw $(DB_NAME); then \
			echo 'Creando base de datos $(DB_NAME)...'; \
			psql -U odoo -c \"CREATE DATABASE $(DB_NAME) WITH TEMPLATE template0 ENCODING 'unicode' LC_COLLATE 'C' LC_CTYPE 'C'\"; \
		else \
			echo 'La base de datos $(DB_NAME) ya existe.'; \
		fi"
	@docker-compose up -d
	@sleep 10
	@echo "\nContenedores iniciados. Verifique con 'make check'"

up:
	@docker-compose up -d

down:
	@docker-compose down

restart: down up

## Verificación
check:
	@echo "Verificando estado del sistema..."
	@echo "\n=== Contenedores ==="
	@docker-compose ps
	@echo "\n=== Conexión DB ==="
	@docker-compose exec db pg_isready -U odoo -d $(DB_NAME)
	@echo "\n=== Módulos Instalados ==="
	@docker-compose exec db psql -U odoo -d $(DB_NAME) -c \
		"SELECT name, state FROM ir_module_module WHERE name LIKE 'maquiser_%' OR name IN ('web', 'base', 'mail') ORDER BY name;"

validate:
	@echo "Validando estructura del proyecto..."
	@test -d addons || (echo "ERROR: Falta directorio 'addons'" && exit 1)
	@for module in $(shell echo $(MODULES) | tr ',' ' '); do \
		test -d addons/$$module || (echo "ERROR: Falta directorio del módulo $$module" && exit 1); \
		test -f addons/$$module/__manifest__.py || (echo "ERROR: Falta __manifest__.py en $$module" && exit 1); \
		test -f addons/$$module/__init__.py || (echo "ERROR: Falta __init__.py en $$module" && exit 1); \
	done
	@test -f docker-compose.yaml || (echo "ERROR: Falta docker-compose.yaml" && exit 1)
	@echo "Estructura del proyecto OK"

## Instalación de módulos
install-module:
	@test -n "$(MODULE)" || { echo "ERROR: Debes especificar un módulo con MODULE=nombre_modulo"; exit 1; }
	@echo "Instalando módulo $(MODULE)..."
	@docker-compose exec odoo odoo -d $(DB_NAME) -i $(MODULE) --stop-after-init
	@echo "Módulo $(MODULE) instalado"

install-all:
	@echo "Instalando todos los módulos Maquiser..."
	@docker-compose exec odoo bash -c "\
		echo 'Instalando módulos base...'; \
		odoo -d $(DB_NAME) -i web,base,mail --stop-after-init; \
		echo 'Instalando módulos Maquiser...'; \
		odoo -d $(DB_NAME) -i $(MODULES) --stop-after-init; \
		echo 'Actualizando todos los módulos...'; \
		odoo -d $(DB_NAME) -u all --stop-after-init"
	@echo "Todos los módulos instalados"

reinstall: reset install-all

## Gestión de base de datos
# reset:
# 	@echo "Reiniciando completamente el entorno..."
# 	@docker-compose down -v
# 	@mkdir -p data/db
# 	@sudo chmod -R 777 data/db
# 	@docker-compose up -d db
# 	@sleep 20
# 	@echo "Forzando recreación de la base de datos..."
# 	@docker-compose exec db bash -c "\
# 		psql -U odoo -c \"SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$(DB_NAME)' AND pid <> pg_backend_pid()\"; \
# 		psql -U odoo -c 'DROP DATABASE IF EXISTS $(DB_NAME)'; \
# 		psql -U odoo -c 'CREATE DATABASE $(DB_NAME) WITH TEMPLATE template0 ENCODING \"unicode\" LC_COLLATE \"C\" LC_CTYPE \"C\"';"
# 	@docker-compose up -d
# 	@sleep 10
# 	@echo "Entorno reiniciado completamente"
DB_NAME=odoo

reset:
	@echo "Reiniciando completamente el entorno..."
	@docker-compose down -v
	@mkdir -p data/db
	@sudo chmod -R 777 data/db
	@docker-compose up -d db
	@sleep 20
	@echo "Forzando recreación de la base de datos..."
	@docker-compose exec db bash -c 'psql -U odoo -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = '\''$(DB_NAME)'\'' AND pid <> pg_backend_pid();"'
	@docker-compose exec db bash -c 'psql -U odoo -d postgres -c "DROP DATABASE IF EXISTS $(DB_NAME);"'
	@docker-compose exec db bash -c 'psql -U odoo -d postgres -c "CREATE DATABASE $(DB_NAME) WITH OWNER = odoo TEMPLATE = template0 ENCODING = '\''unicode'\'' LC_COLLATE = '\''C'\'' LC_CTYPE = '\''C'\'';"'
	@docker-compose up -d
	@sleep 10
	@echo "Entorno reiniciado completamente"

clean:
	@echo "Limpiando entorno..."
	@docker-compose down -v
	@sudo rm -rf data/db/*

## Desarrollo
logs:
	@docker-compose logs -f odoo

shell-odoo:
	@docker-compose exec odoo bash

shell-db:
	@docker-compose exec db bash

test:
	@echo "Ejecutando pruebas..."
	@docker-compose exec odoo odoo -d $(DB_NAME) --test-enable --stop-after-init

## Backup/Restore
backup:
	@echo "Creando backup de la base de datos..."
	@mkdir -p backups
	@docker-compose exec db pg_dump -U odoo -F c $(DB_NAME) > backups/$(DB_NAME)_$(shell date +%Y%m%d_%H%M%S).dump
	@echo "Backup creado en backups/"

restore:
	@echo "Restaurando backup más reciente..."
	@test -n "$(BACKUP_FILE)" || { \
		BACKUP_FILE=$$(ls -t backups/*.dump | head -1); \
		echo "Usando backup más reciente: $$BACKUP_FILE"; \
	}
	@docker-compose exec -T db pg_restore -U odoo -C -d postgres < $$BACKUP_FILE
	@echo "Backup restaurado"

## Ayuda
help:
	@echo "Opciones disponibles:"
	@echo "  all             - Inicia e instala todo (init + install-all)"
	@echo "  init            - Inicia el entorno por primera vez"
	@echo "  up              - Levanta los contenedores"
	@echo "  down            - Detiene los contenedores"
	@echo "  restart         - Reinicia los contenedores"
	@echo "  check           - Verifica el estado del sistema"
	@echo "  validate        - Valida la estructura del proyecto"
	@echo "  install-module  - Instala un módulo específico (MODULE=nombre)"
	@echo "  install-all     - Instala todos los módulos Maquiser"
	@echo "  reinstall       - Reinicia e instala los módulos"
	@echo "  reset           - Reinicia completamente el entorno"
	@echo "  clean           - Limpia completamente el entorno"
	@echo "  logs            - Muestra los logs de Odoo"
	@echo "  shell-odoo      - Accede a la shell del contenedor Odoo"
	@echo "  shell-db        - Accede a la shell del contenedor DB"
	@echo "  test            - Ejecuta pruebas"
	@echo "  backup          - Crea un backup de la base de datos"
	@echo "  restore         - Restaura un backup (BACKUP_FILE=path opcional)"
	@echo "  help            - Muestra esta ayuda"