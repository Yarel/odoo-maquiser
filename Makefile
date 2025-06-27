# Makefile para gestión de proyecto Odoo

.PHONY: all init up down restart check validate install reinstall reset clean logs shell-odoo shell-db test backup restore help

# Variables configurables
DB_NAME ?= odoo
MODULE_NAME ?= maquiser_base
ODOO_IMAGE ?= odoo:16
POSTGRES_IMAGE ?= postgres:13
PGPASSWORD ?= odoo

all: init check

## Inicialización
init: validate
	@echo "Iniciando contenedores..."
	@docker-compose up -d db
	@echo "Esperando inicialización de PostgreSQL..."
	@docker-compose exec db bash -c "\
		until pg_isready -U odoo; do sleep 2; done; \
		if ! psql -U odoo -lqt | cut -d \| -f 1 | grep -qw $(DB_NAME); then \
			echo 'Creando base de datos $(DB_NAME)...'; \
			psql -U odoo -c \"CREATE DATABASE $(DB_NAME) WITH TEMPLATE template0 ENCODING 'unicode';\"; \
		else \
			echo 'La base de datos $(DB_NAME) ya existe.'; \
		fi"
	@docker-compose up -d
	@sleep 8  # Aumentado el tiempo de espera
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
	@echo "\n=== Verificación Base de Datos ==="
	@docker-compose exec db bash -c "\
		if psql -U odoo -lqt | grep -qw $(DB_NAME); then \
			echo 'Base de datos $(DB_NAME) existe.'; \
			echo '\n=== Módulos Odoo ==='; \
			PGPASSWORD=$(PGPASSWORD) psql -h db -U odoo -d $(DB_NAME) -c \
			\"SELECT name, state FROM ir_module_module WHERE name IN ('web', 'base', 'mail', '$(MODULE_NAME)')\"; \
		else \
			echo 'ERROR: Base de datos $(DB_NAME) no existe.'; \
			exit 1; \
		fi"

validate:
	@echo "Validando estructura del proyecto..."
	@test -d addons || (echo "ERROR: Falta directorio 'addons'" && exit 1)
	@test -d addons/$(MODULE_NAME) || (echo "ERROR: Falta directorio del módulo" && exit 1)
	@test -f addons/$(MODULE_NAME)/__manifest__.py || (echo "ERROR: Falta __manifest__.py" && exit 1)
	@test -f addons/$(MODULE_NAME)/__init__.py || (echo "ERROR: Falta __init__.py" && exit 1)
	@test -f docker-compose.yaml || (echo "ERROR: Falta docker-compose.yaml" && exit 1)
	@echo "Estructura del proyecto OK"

## Gestión de módulos (SECCIÓN CRÍTICA MODIFICADA)
install:
	@echo "Instalando módulos esenciales..."
	@docker-compose exec odoo bash -c "\
		echo 'Paso 1/4: Instalando módulo web (crítico)...'; \
		odoo -d $(DB_NAME) -i web --stop-after-init; \
		echo 'Paso 2/4: Instalando módulo base...'; \
		odoo -d $(DB_NAME) -i base --stop-after-init; \
		echo 'Paso 3/4: Instalando módulo mail...'; \
		odoo -d $(DB_NAME) -i mail --stop-after-init; \
		echo 'Paso 4/4: Instalando módulo $(MODULE_NAME)...'; \
		odoo -d $(DB_NAME) -i $(MODULE_NAME) --stop-after-init; \
		echo 'Actualización final de todos los módulos...'; \
		odoo -d $(DB_NAME) -u all --stop-after-init"

reinstall: reset install

## Gestión de base de datos
reset:
	@echo "Reiniciando completamente el entorno..."
	@docker-compose down -v
	@mkdir -p data/db
	@sudo chmod -R 777 data/db
	@docker-compose up -d db
	@sleep 12  # Tiempo aumentado para PostgreSQL
	@echo "Creando base de datos $(DB_NAME) con configuración óptima..."
	@docker-compose exec db psql -U odoo -c \
		"CREATE DATABASE $(DB_NAME) WITH TEMPLATE template0 ENCODING 'unicode' LC_COLLATE 'C' LC_CTYPE 'C';"
	@docker-compose up -d
	@sleep 8
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
	@echo "  init        - Inicia el entorno por primera vez (crea DB si no existe)"
	@echo "  up          - Levanta los contenedores"
	@echo "  down        - Detiene los contenedores"
	@echo "  restart     - Reinicia los contenedores"
	@echo "  check       - Verifica el estado del sistema (con chequeo de DB)"
	@echo "  validate    - Valida la estructura del proyecto"
	@echo "  install     - Instala los módulos (web, base, mail y tu módulo)"
	@echo "  reinstall   - Reinicia e instala los módulos"
	@echo "  reset       - Reinicia completamente el entorno (elimina y recrea DB)"
	@echo "  clean       - Limpia completamente el entorno (elimina todo)"
	@echo "  logs        - Muestra los logs de Odoo"
	@echo "  shell-odoo  - Accede a la shell del contenedor Odoo"
	@echo "  shell-db    - Accede a la shell del contenedor DB"
	@echo "  test        - Ejecuta pruebas"
	@echo "  backup      - Crea un backup de la base de datos"
	@echo "  restore     - Restaura un backup (BACKUP_FILE=path opcional)"
	@echo "  help        - Muestra esta ayuda"