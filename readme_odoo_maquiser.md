# ERP Textil Maquiser - Odoo 16

Este proyecto implementa un sistema ERP completo para la empresa **Maquiser S.R.L**, especializada en la fabricación de uniformes textiles. El sistema está construido sobre **Odoo 16** y desplegado mediante Docker, con automatización completa gracias a un `Makefile` robusto.

---

## 🚀 Características principales

- Gestión de contactos (clientes, proveedores, empleados)
- Modelado de productos textiles (uniformes, materiales, insumos)
- Control de inventario y manufactura (MTO/MTS)
- Compras, ventas y reportes
- Seguridad por grupos de usuarios (ventas, inventario, etc.)
- Menús personalizados con marca Maquiser

---

## 📁 Estructura del Proyecto

```
~/odoo
├── addons/
│   ├── maquiser_core/
│   ├── maquiser_security/
│   └── ...
├── data/
│   └── db/          # Volumen de base de datos
├── docker-compose.yaml
├── Makefile         # Comandos automatizados
└── README.md
```

---

## 🧰 Requisitos

- Docker & Docker Compose
- GNU Make
- Puerto `8069` libre

---

## 🟢 Instalación rápida (desde cero)

```bash
make all
```

Esto realiza:

- Validación del entorno (`validate`)
- Inicialización de contenedores (`init`)
- Instalación de todos los módulos Maquiser (`install-all`)

Accede al sistema vía navegador:

```
http://localhost:8069
```

---

## 🛠️ Ciclo típico de desarrollo

### Subir un módulo nuevo o modificado:

```bash
make install-module MODULE=maquiser_core
```

### Verificar que todo está bien:

```bash
make check
```

---

## 🧹 ¿Se rompió todo? ¿Error 500?

### Solución básica (limpia DB y reinicia):

```bash
make clean
make reset
make install-module MODULE=maquiser_core
```

### Solución total (limpia todo y reinstala todo):

```bash
make full-rebuild
```

Este comando:

1. Elimina todos los contenedores y volúmenes
2. Reinicia base de datos limpia
3. Instala todos los módulos

---

## 📦 Comandos disponibles

| Comando               | Descripción                                  |
| --------------------- | -------------------------------------------- |
| `make all`            | Valida, inicia y despliega todo desde cero   |
| `make init`           | Inicia DB, espera y lanza Odoo               |
| `make up`             | Levanta contenedores                         |
| `make down`           | Detiene contenedores                         |
| `make restart`        | Reinicia entorno                             |
| `make check`          | Verifica contenedores, DB y módulos          |
| `make validate`       | Comprueba estructura del proyecto            |
| `make install-module` | Instala módulo específico (`MODULE=...`)     |
| `make install-all`    | Instala todos los módulos definidos          |
| `make reinstall`      | Resetea entorno e instala todos los módulos  |
| `make reset`          | Borra y recrea DB desde cero                 |
| `make clean`          | Elimina volúmenes y DB                       |
| `make full-rebuild`   | Limpieza total + instalación completa ⚠️     |
| `make logs`           | Muestra logs en tiempo real                  |
| `make shell-odoo`     | Shell al contenedor Odoo                     |
| `make shell-db`       | Shell al contenedor PostgreSQL               |
| `make test`           | Corre pruebas unitarias                      |
| `make backup`         | Crea backup en `backups/`                    |
| `make restore`        | Restaura backup (último o `BACKUP_FILE=...`) |
| `make help`           | Muestra ayuda completa                       |

---

## 👨‍💻 Consejos de desarrollo

- Usa `make check` luego de cada instalación
- Si hay cambios en `.py`, `.xml`, `__manifest__` usa `make install-module`
- Si da error 500: `make clean && make reset && make install-module ...`
- Usa `make logs` para ver errores o fallos en Odoo

---

## 🔄 Mejoras futuras

- Integrar pruebas automáticas de validación
- Automatizar demo con datos de ejemplo pre-cargados
- Preparar despliegue en producción vía Nginx y dominio

---

## 🔐 Acceso por defecto (modo dev)

- Usuario: `admin`
- Contraseña: definida al instalar vía interfaz (o configurada manualmente)

---

## 📞 Soporte

Este ERP ha sido desarrollado y mantenido por el equipo técnico para el caso de estudio de **Maquiser S.R.L**.

¿Dudas o errores? Revisa los logs:

```bash
make logs
```

O ejecuta una shell directamente:

```bash
make shell-odoo
```

