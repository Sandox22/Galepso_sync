---
name: galepso-sync-upsert
description: >-
  Motor centralizado de sincronización incremental SyncUpsert para tablas
  maestras/catálogos con clave primaria simple. Usar cuando el usuario pida
  sincronizar productos, precios, estados, municipios, clientes (subida),
  o cualquier tabla con PK de columna única hacia MariaDB.
---

# Patrón A: Motor SyncUpsert

## Descripción

El motor `sync_upsert.prg` es la pieza central para sincronización de tablas
con clave primaria de columna única. Genera y ejecuta `INSERT ... ON DUPLICATE
KEY UPDATE` dinámicamente para cualquier tabla del sistema.

**Archivo fuente:** `C:\liderplussync\prg\sync_upsert.prg`

## Firma

```foxpro
FUNCTION SyncUpsert(tnHandle, tcLocalAlias, tcRemoteTable, tcFieldMap)
```

### Parámetros

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `tnHandle` | N | Handle ODBC activo (de `SQLSTRINGCONNECT`) |
| `tcLocalAlias` | C | Alias del cursor/DBF local a leer (ej. `"tclientes"`) |
| `tcRemoteTable` | C | Tabla destino en MariaDB (ej. `"conex_clientes"`) |
| `tcFieldMap` | C | Mapa de campos delimitado por comas |

### Retorno

| Valor | Significado |
|-------|-------------|
| `> 0` | Número de registros sincronizados exitosamente |
| `= 0` | Sin registros activos o error de parámetros |
| `< 0` | Negativo del conteo de fallos |

## Inyección Obligatoria del Helper

Todo módulo que use SyncUpsert DEBE incluir este bloque **antes** de la llamada:

```foxpro
*-- Sincronización incremental via Helper Dinámico --*
IF FILE("C:\liderplussync\prg\sync_upsert.prg")
    SET PROCEDURE TO C:\liderplussync\prg\sync_upsert.prg ADDITIVE
ELSE
    SET PROCEDURE TO (ADDBS(JUSTPATH(SYS(16))) + "sync_upsert.prg") ADDITIVE
ENDIF
```

**Excepción:** Si el orquestador (`sincronizar_todo.prg`) ya cargó el helper
en scope, los módulos hijos llamados con `DO modulo.prg WITH lnhandle` no
necesitan recargarlo.

## Formato del tcMap

Cadena delimitada por comas. Cada elemento tiene el formato:
```
campo_local|CAMPO_REMOTO|Tipo
```

### Tipos Permitidos

| Tipo | Descripción | Comportamiento en sync_upsert.prg |
|------|-------------|-----------------------------------|
| `C` | Cadena/Texto | `ALLTRIM()` + escape de `'` → envuelto en comillas simples |
| `N` | Numérico | `STR()` + sanitización de exponentes → sin comillas |
| `B` | Booleano | VFP Logical `.T.`/`.F.` → MariaDB `1`/`0` sin comillas |

**IMPORTANTE:** El motor NO soporta tipo `D` (Date) ni `T` (DateTime).
Para campos de fecha, deben convertirse a cadena ISO `'YYYY-MM-DD'` en un
cursor intermedio y mapearse como tipo `C`.

### Regla de PK

La **primera columna** del tcMap se asume como la clave primaria. Esta columna:
- SÍ se incluye en el `INSERT INTO (...)`
- NO se incluye en el `ON DUPLICATE KEY UPDATE ...`

## Patrón Post-SyncUpsert

Después de cada invocación, seguir este patrón estándar de reporte:

```foxpro
lnResult = SyncUpsert(tnH, "cur_datos", "conex_tabla", tcMap)

IF USED("cur_datos")
    USE IN cur_datos
ENDIF

IF TYPE("PCESTADOENVIA") = "C"
    IF lnResult > 0
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + lnResult
        ENDIF
        PCESTADOENVIA = PCESTADOENVIA + "Tabla sincronizada OK " + TTOC(DATETIME()) + CHR(13)
    ELSE
        IF lnResult < 0
            PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR en Tabla " + TTOC(DATETIME())
        ELSE
            PCESTADOENVIA = PCESTADOENVIA + "Sin registros para Tabla " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ENDIF
ENDIF
```

## Ejemplos Reales del Proyecto

### Productos (productos.prg)
```foxpro
tcMap = "cid_produc|CNX_PDT_CODIGO|C," + ;
        "cdescripci|CNX_PDT_DESCRIPCION|C," + ;
        "cempaque|CNX_UND_ID|C," + ;
        "nprecio|CNX_PDT_PRE_PRECIO|N," + ;
        "nexisten|CNX_PDT_EXIS|N," + ;
        "nfactor|CNX_PDT_FACTOR|N"

lnResult = SyncUpsert(tnH, "cur_productos", "conex_productos", tcMap)
```

### Precios (precios.prg)
```foxpro
tcMapPre = "cid_produc|CNX_PRE_PDT_CODIGO|C," + ;
           "ctipo_pre|CNX_PRE_PLT_LISTA|C," + ;
           "nprecio|CNX_PRE_PRECIO|N," + ;
           "cemp_sync|CNX_PRE_UGR_UND_ID|C"

lnResPre = SyncUpsert(tnH, "cur_precios_sync", "conex_precios", tcMapPre)
```

### Estados (estados.prg)
```foxpro
tcMapEdo = "edo_codigo|CNX_EDOCODIGO|N," + ;
           "edo_descri|CNX_EDODESCRI|C," + ;
           "edo_activo|CNX_EDOACTIVO|N"

lnResEdo = SyncUpsert(tnH, "cur_estados_sync", "conex_estados", tcMapEdo)
```

### Municipios (municipios.prg)
```foxpro
* CNX_MPO_CODIGO = VAL(cid_estado) * 100 + VAL(cid_ciudad)
tcMapMpo = "mpo_codigo|CNX_MPO_CODIGO|N," + ;
           "mpo_descri|CNX_MPO_DESCRI|C," + ;
           "mpo_edo_codigo|CNX_MPO_EDO_CODIGO|N"

lnResMpo = SyncUpsert(tnH, "cur_municipios_sync", "conex_municipios", tcMapMpo)
```

### Clientes - Subida (cxc.prg L66-75)
```foxpro
tcMap = "cid_clien|CNX_CLT_CODIGO|C," + ;
        "cnombre_cl|CNX_CLT_NOMBRE|C," + ;
        "crif_cli|CNX_CLT_RIF|C," + ;
        "cdir_cli1|CNX_CLT_DIRECCION1|C," + ;
        "ctele_cli|CNX_CLT_TELEFONO1|C," + ;
        "cid_vende|CNX_CLT_VEN_CODIGO|C," + ;
        "cid_estadc|CNX_CLT_EDO_CODIGO|N," + ;
        "cid_ciudac|CNX_CLT_MPO_CODIGO|N"

lnResult = SyncUpsert(lnhandle, "tclientes", "conex_clientes", tcMap)
```

## Preparación de Cursores Intermedios

Cuando la tabla local no tiene exactamente los campos que necesitas, crea un
cursor intermedio con `SELECT ... INTO CURSOR ... READWRITE`:

```foxpro
* Ejemplo: municipios necesita un código compuesto
SELECT VAL(CID_ESTADO) * 100 + VAL(CID_CIUDAD) AS mpo_codigo, ;
       ALLTRIM(CDESCRIPCI) AS mpo_descri, ;
       VAL(CID_ESTADO) AS mpo_edo_codigo ;
FROM tciudades ;
WHERE !EMPTY(ALLTRIM(CID_ESTADO)) AND !EMPTY(ALLTRIM(CDESCRIPCI)) ;
INTO CURSOR cur_municipios_sync READWRITE
```

**IMPORTANTE:** Siempre cerrar los cursores temporales después del SyncUpsert.
