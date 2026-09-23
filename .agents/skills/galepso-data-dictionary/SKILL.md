---
name: galepso-data-dictionary
description: >-
  Diccionario de datos maestro del proyecto Galepso: mapeos validados entre
  campos locales de VFP (DBF) y campos remotos de MariaDB, esquemas de tablas
  nube, y strings tcMap probados. Usar cuando el usuario pregunte por nombres
  de campos, estructuras de tablas, mapeos, o necesite construir un tcMap para
  SyncUpsert o un bloque de SQL para insert/update manual.
---

# Diccionario de Datos Galepso

## Descripción

Este skill contiene el diccionario de datos validado del proyecto: los nombres
exactos de campos en VFP y MariaDB, los mapeos entre ellos, y los strings
`tcMap` ya probados en producción.

**REGLA CARDINAL:** NUNCA inventes nombres de campos. Si necesitas un campo que
no aparece aquí, solicita al usuario que valide la estructura del DBF con
`LIST STRUCTURE` o consulte el esquema de MariaDB.

## Mapeos Validados por Módulo

Consulta los archivos de referencia para detalles completos:
- [Mapeos VFP → MariaDB](./references/mapeo_local_nube.md)
- [Esquemas MariaDB](./references/esquema_mariadb.md)

## Resumen de tcMap Probados en Producción

### Clientes (cxc.prg → conex_clientes)
```
cid_clien|CNX_CLT_CODIGO|C,
cnombre_cl|CNX_CLT_NOMBRE|C,
crif_cli|CNX_CLT_RIF|C,
cdir_cli1|CNX_CLT_DIRECCION1|C,
ctele_cli|CNX_CLT_TELEFONO1|C,
cid_vende|CNX_CLT_VEN_CODIGO|C,
cid_estadc|CNX_CLT_EDO_CODIGO|N,
cid_ciudac|CNX_CLT_MPO_CODIGO|N
```

### Productos (productos.prg → conex_productos)
```
cid_produc|CNX_PDT_CODIGO|C,
cdescripci|CNX_PDT_DESCRIPCION|C,
cempaque|CNX_UND_ID|C,
nprecio|CNX_PDT_PRE_PRECIO|N,
nexisten|CNX_PDT_EXIS|N,
nfactor|CNX_PDT_FACTOR|N
```
**Nota:** `productos.prg` filtra `ALLTRIM(p.cclasi1) == '05'` para KW.

### Precios (precios.prg → conex_precios)
```
cid_produc|CNX_PRE_PDT_CODIGO|C,
ctipo_pre|CNX_PRE_PLT_LISTA|C,
nprecio|CNX_PRE_PRECIO|N,
cemp_sync|CNX_PRE_UGR_UND_ID|C
```
**Nota:** `ctipo_pre` se traduce: `"1"→"A"`, `"2"→"B"`, `"3"→"C"`, `"4"→"D"` via `ICASE`.

### Estados (estados.prg → conex_estados)
```
edo_codigo|CNX_EDOCODIGO|N,
edo_descri|CNX_EDODESCRI|C,
edo_activo|CNX_EDOACTIVO|N
```
**Nota:** `edo_codigo` y `edo_descri` son aliases de cursor, no campos nativos del DBF.

### Municipios (municipios.prg → conex_municipios)
```
mpo_codigo|CNX_MPO_CODIGO|N,
mpo_descri|CNX_MPO_DESCRI|C,
mpo_edo_codigo|CNX_MPO_EDO_CODIGO|N
```
**Nota:** `mpo_codigo = VAL(cid_estado) * 100 + VAL(cid_ciudad)` (código compuesto).

### CxC (cxc_sincro_subida.prg → conex_sincro_cxc)
**No usa tcMap.** Mapeo manual (ver skill `galepso-cxc`):
```
cid_clien    → CODIGO
cid_doccxc   → NUMERO
cid_tipo_d   → TIPO (traducción dinámica)
dfecha       → FECHA (FechaISO)
dfecha_ven   → FECHAVEN (FechaISO)
nsaldo       → SALDO
cid_vende    → VEN_CODIGO
nfactor      → TASA
Constante    → TASACOP = 0.00
mobservaci   → COMENTARIO (sanitizado)
Constante    → ID_ENTERPRISE = '3'
INFOCXC      → JSON (tdetalles_factura + tproductos)
```

## Tablas Locales VFP (DBFs)

### tclientes
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_clien` | C | 5 | PK: Código cliente |
| `cnombre_cl` | C | 100 | Nombre/razón social |
| `crif_cli` | C | 12 | RIF |
| `cdir_cli1` | C | 60 | Dirección principal |
| `ctele_cli` | C | 25 | Teléfono |
| `cid_vende` | C | 5 | FK: Código vendedor |
| `cid_estadc` | C | 2 | FK: Código estado |
| `cid_ciudac` | C | 2 | FK: Código ciudad |
| `cnit_cli` | C | 12 | Marca de sincronización (subida) |
| `lactivo` | L | 1 | Estado activo |
| `mobservaci` | M | - | Observaciones (Memo) |

### tdocumentos_cxc
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_clien` | C | 5 | FK: Código cliente → CODIGO |
| `cid_doccxc` | C | 10 | PK: Número documento → NUMERO |
| `cid_tipo_d` | C | 2 | Tipo documento → TIPO (traducir) |
| `dfecha` | D | 8 | Fecha emisión → FECHA |
| `dfecha_ven` | D | 8 | Fecha vencimiento → FECHAVEN |
| `nsaldo` | N | 17,2 | Saldo pendiente → SALDO |
| `cid_vende` | C | 5 | Código vendedor → VEN_CODIGO |
| `nfactor` | N | 12,6 | Tasa de cambio → TASA |
| `mobservaci` | M | - | Observaciones (Memo) → COMENTARIO |

### tdetalles_factura
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_factu` | C | 10 | FK: Enlace con CxC (`tdocumentos_cxc.cid_doccxc`) |
| `cid_produc` | C | 10 | FK: SKU / Producto |
| `ncantidad` | N/Y | 14,2 | Cantidad |
| `nprecio` | N/Y | 14,2 | Precio unitario |
| `nmonto` | N/Y | 14,2 | Total línea (NO `ntotal`) |

### tvendedores
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_vende` | C | 5 | PK: Código vendedor |
| `cnombrev` | C | 40 | Nombre vendedor |
| `ctipo_v` | C | 2 | Tipo vendedor (`'2'` = DISTRIBUIDOR) |
| `lactivo` | L | 1 | Estado activo |

### tproductos
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_produc` | C | 10 | PK: Código producto |
| `cdescripci` | C | 60 | Descripción |
| `cempaque` | C | 15 | Unidad de medida |
| `cclasi1` | C | 3 | Clasificación (filtro: `'05'` para KW) |

### tproductos_precio
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_produc` | C | 10 | FK: Código producto |
| `ctipo_pre` | C | 2 | Tipo lista precio (`'1'`→A, `'2'`→B, etc.) |
| `nprecio` | N | 14,2 | Precio |
| `nfactor` | N | 12,2 | Factor de empaque |

### tpedidos
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_pedido` | C | 8 | PK: Número pedido |
| `cid_clien` | C | 5 | FK: Código cliente |
| `dfecha` | D | 8 | Fecha |
| `cid_status` | C | 3 | Estado (`"  1"` = pendiente) |
| `ctipo_pre` | C | 2 | Tipo precio |
| `cid_vende` | C | 5 | FK: Código vendedor |
| `cnombre_cl` | C | 100 | Nombre cliente |
| `crif_cli` | C | 12 | RIF |
| `nmonto_t` | N/Y | 17,2 | Monto total |

### tdetalles_pedido
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_pedido` | C | 8 | FK: Número pedido |
| `cid_produc` | C | 10 | FK: Código producto |
| `ncantidad` | N/Y | 12,2 | Cantidad |
| `nprecio` | N/Y | 14,2 | Precio unitario |
| `nmonto` | N/Y | 14,2 | Monto (cantidad × precio) |

### testados
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_estado` | C | 2 | PK: Código estado |
| `cdescripci` | C | 20 | Descripción |

### tciudades
| Campo | Tipo | Longitud | Uso |
|-------|------|----------|-----|
| `cid_estado` | C | 2 | FK: Código estado |
| `cid_ciudad` | C | 2 | Código ciudad (PK parcial) |
| `cdescripci` | C | 20 | Descripción municipio |
