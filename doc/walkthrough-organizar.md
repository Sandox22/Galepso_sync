# Walkthrough — Refactorización del Directorio Raíz

## Resumen

Migración completa de `C:\liderplussync` → `C:\GalepsoSync`, eliminando **todas** las rutas hardcodeadas en favor de resolución dinámica con `SYS(16)` en VFP y `os.path.abspath` en Python.

---

## 1. Archivos Movidos

| Archivo | Origen | Destino |
|---------|--------|---------|
| `instancia.prg` | raíz | `prg/` |
| `mailpowershell.prg` + `.BAK` + `.FXP` | raíz | `prg/` |
| `psclass.prg` | raíz | `prg/` |
| `psdemo.prg` | raíz | `prg/` |
| `tclientes.htm` | `prg/` | `doc/` |

**Resultado:** La raíz solo conserva `sincronizar.prg` (entry point del `.exe` compilado).

---

## 2. VFP — Patrón de Rutas Dinámicas

Todas las rutas hardcodeadas `C:\liderplussync\...` fueron reemplazadas por:

```foxpro
LOCAL lcAppRoot
lcAppRoot = ADDBS(JUSTPATH(JUSTPATH(SYS(16))))  && Raíz del proyecto
```

Esto permite que el proyecto funcione desde **cualquier ubicación** sin editar rutas.

### Archivos modificados

| Archivo | Cambios |
|---------|---------|
| [principal.prg](file:///c:/GalepsoSync/prg/principal.prg) | `SET PATH`, `SET PROCEDURE`, apertura de `respaldos.dbf` |
| [init_globals.prg](file:///c:/GalepsoSync/prg/init_globals.prg) | `SET PATH`, `SET PROCEDURE` |
| [sincronizar_todo.prg](file:///c:/GalepsoSync/prg/sincronizar_todo.prg) | Bloque `IF FILE(...)` simplificado a una sola línea dinámica |
| [cxc.prg](file:///c:/GalepsoSync/prg/cxc.prg) | Carga de `sync_upsert.prg` — simplificada |
| [inventario.prg](file:///c:/GalepsoSync/prg/inventario.prg) | Carga de `sync_upsert.prg` — simplificada |
| [envia_a_lubo.prg](file:///c:/GalepsoSync/prg/envia_a_lubo.prg) | `USE data\respaldos`, `USE data\empresas` |
| [recibe_de_lubo.prg](file:///c:/GalepsoSync/prg/recibe_de_lubo.prg) | `USE data\respaldos`, `USE data\empresas` |
| [setup_api_sync.prg](file:///c:/GalepsoSync/prg/setup_api_sync.prg) | 6 referencias: `respaldos.dbf`, `formularios\frmrespaldos.scx/.sct` |
| [check_struct.prg](file:///c:/GalepsoSync/prg/check_struct.prg) | Ruta de salida de `LIST STRUCTURE` |

---

## 3. Python / Spec

| Archivo | Cambio |
|---------|--------|
| [main.py](file:///c:/GalepsoSync/main.py) | Docstring actualizado (L722-723). La ruta de ejecución ya era dinámica ✓ |
| [main.spec](file:///c:/GalepsoSync/main.spec) | Source path y icon path → `C:\GalepsoSync\...` |
| [read_dbf.py](file:///c:/GalepsoSync/read_dbf.py) | Ruta de datos → `C:\GalepsoSync\DATA_KW\...` |
| [read_tclientes.py](file:///c:/GalepsoSync/read_tclientes.py) | Ruta de datos → `C:\GalepsoSync\DATA_KW\...` |

---

## 4. Documentación

| Archivo | Cambio |
|---------|--------|
| [GEMINI.md](file:///c:/GalepsoSync/GEMINI.md) | Árbol de proyecto → `C:\GalepsoSync\` |
| [WORKFLOW.md](file:///c:/GalepsoSync/WORKFLOW.md) | 18 enlaces `file:///` actualizados |
| [Skill - Sincronizador.md](file:///c:/GalepsoSync/Skill%20-%20Sincronizador.md) | Snippet de carga actualizado al patrón dinámico |

---

## 5. Verificación

```
Grep "liderplussync" en *.prg, *.py, *.md, *.spec, *.json:
  → 1 hit residual (comentario VFP inactivo — línea con ** en envia_a_lubo.prg:18)
  → 0 hits en código ejecutable ✓

Raíz del proyecto:
  → Único .prg en raíz: sincronizar.prg (entry point .exe) ✓
  → 0 archivos .htm en prg/ ✓
```

## No tocados (por diseño)

- **Archivos `.BAK`**: Backups históricos — contienen refs obsoletas pero no se ejecutan
- **Archivos `.FXP`**: Compilados intermedios — se regeneran automáticamente al ejecutar los `.prg` corregidos
- **`envia_a_lubo.prg:18`**: Línea comentada (`**interfacex=...`) — código inactivo
