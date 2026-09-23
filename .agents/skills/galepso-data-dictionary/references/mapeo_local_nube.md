# Mapeos Validados: VFP Local → MariaDB Nube

Este documento detalla cada mapeo campo-a-campo entre las tablas locales de
Galepso (VFP/DBF) y las tablas remotas en MariaDB, organizados por módulo
de sincronización.

---

## 1. tclientes ↔ conex_clientes (Bidireccional)

**Módulo:** `clientes.prg`
**Dirección:** Bidireccional (Bajada + Subida)

### Subida (VFP → MariaDB) via SyncUpsert

| Campo VFP | Campo MariaDB | Tipo tcMap | Transformación |
|-----------|---------------|------------|----------------|
| `cid_clien` | `CNX_CLT_CODIGO` | C | PK, `ALLTRIM()` |
| `cnombre_cl` | `CNX_CLT_NOMBRE` | C | Escape `'` con `CHRTRAN` |
| `crif_cli` | `CNX_CLT_RIF` | C | `ALLTRIM()` |
| `cdir_cli1` | `CNX_CLT_DIRECCION1` | C | - |
| `ctele_cli` | `CNX_CLT_TELEFONO1` | C | - |
| `cid_vende` | `CNX_CLT_VEN_CODIGO` | C | - |
| `cid_estadc` | `CNX_CLT_EDO_CODIGO` | N | `VAL()` del código |
| `cid_ciudac` | `CNX_CLT_MPO_CODIGO` | N | `VAL()` del código |

### Bajada (MariaDB → VFP) via INSERT directo

| Campo MariaDB | Campo VFP | Transformación |
|---------------|-----------|----------------|
| `cnx_clt_codigo` | `cnit_cli` | Marca de origen nube |
| `cnx_clt_nombre` | `cnombre_cl` | Directo |
| `cnx_clt_rif` | `crif_cli` | Directo |
| `cnx_clt_edo_codigo` | `cid_estadc` | `STR(val, 2)` |
| `cnx_clt_mpo_codigo` | `cid_ciudac` | `STR(val, 2)` |
| `cnx_clt_direccion1` | `cdir_cli1` | Directo |
| `cnx_clt_telefono1` | `ctele_cli` | Directo |

**Filtro de bajada:** `cnx_clt_check = 0 AND (cnx_clt_galexo IS NULL OR TRIM(cnx_clt_galexo) = '')`

**Confirmación:** `UPDATE conex_clientes SET cnx_clt_galexo = ?lcNewCid, cnx_clt_check = 1 WHERE cnx_clt_codigo = ?...`

---

## 2. tproductos → conex_productos (Subida)

**Módulo:** `productos.prg`
**Dirección:** Solo subida
**Patrón:** SyncUpsert (Patrón A)

| Campo VFP / Cursor | Campo MariaDB | Tipo tcMap | Notas |
|---------------------|---------------|------------|-------|
| `cid_produc` | `CNX_PDT_CODIGO` | C | PK |
| `cdescripci` | `CNX_PDT_DESCRIPCION` | C | - |
| `cempaque` | `CNX_UND_ID` | C | Unidad de medida |
| `nprecio` (cursor) | `CNX_PDT_PRE_PRECIO` | N | MAX de tproductos_precio |
| `nexisten` (cursor) | `CNX_PDT_EXIS` | N | Calculado como 0.00 |
| `nfactor` (cursor) | `CNX_PDT_FACTOR` | N | Factor de empaque |

**Filtro:** `ALLTRIM(p.cclasi1) == '05'` (clasificación KW)

**Cursor intermedio:**
```sql
SELECT p.cid_produc, p.cdescripci, p.cempaque,
       NVL(pr.nprecio, 0.00) AS nprecio,
       NVL(pr.nfactor, 0.00) AS nfactor,
       NVL(a.nexisten, 0.00) AS nexisten
FROM tproductos p
LEFT JOIN cur_pre_temp pr ON p.cid_produc = pr.cid_produc
LEFT JOIN cur_alm_temp a ON p.cid_produc = a.cid_produc
WHERE ALLTRIM(p.cclasi1) == '05'
INTO CURSOR cur_productos READWRITE
```

---

## 3. tproductos_precio → conex_precios (Subida)

**Módulo:** `precios.prg`
**Dirección:** Solo subida
**Patrón:** SyncUpsert (Patrón A)

| Campo VFP / Cursor | Campo MariaDB | Tipo tcMap | Notas |
|---------------------|---------------|------------|-------|
| `cid_produc` | `CNX_PRE_PDT_CODIGO` | C | PK parcial |
| `ctipo_pre` (traducido) | `CNX_PRE_PLT_LISTA` | C | PK parcial |
| `nprecio` | `CNX_PRE_PRECIO` | N | - |
| `cemp_sync` (cursor) | `CNX_PRE_UGR_UND_ID` | C | PK parcial |

**Traducción de listas de precio:**
| ctipo_pre (VFP) | CNX_PRE_PLT_LISTA (MariaDB) |
|------------------|-----------------------------|
| `"1"` | `"A"` |
| `"2"` | `"B"` |
| `"3"` | `"C"` |
| `"4"` | `"D"` |

**cemp_sync:** `PADR(IIF(EMPTY(p.cempaque) OR ISNULL(p.cempaque), "UND", ALLTRIM(p.cempaque)), 15)`

---

## 4. testados → conex_estados (Subida)

**Módulo:** `estados.prg`
**Dirección:** Solo subida
**Patrón:** SyncUpsert (Patrón A)

| Campo VFP / Cursor | Campo MariaDB | Tipo tcMap | Notas |
|---------------------|---------------|------------|-------|
| `CID_ESTADO` → `edo_codigo` | `CNX_EDOCODIGO` | N | PK |
| `CDESCRIPCI` → `edo_descri` | `CNX_EDODESCRI` | C | `ALLTRIM()` |
| Constante `1` → `edo_activo` | `CNX_EDOACTIVO` | N | Siempre activo |

---

## 5. tciudades → conex_municipios (Subida)

**Módulo:** `municipios.prg`
**Dirección:** Solo subida
**Patrón:** SyncUpsert (Patrón A)

| Campo VFP / Cursor | Campo MariaDB | Tipo tcMap | Notas |
|---------------------|---------------|------------|-------|
| Compuesto → `mpo_codigo` | `CNX_MPO_CODIGO` | N | PK: `VAL(cid_estado)*100 + VAL(cid_ciudad)` |
| `CDESCRIPCI` → `mpo_descri` | `CNX_MPO_DESCRI` | C | `ALLTRIM()` |
| `CID_ESTADO` → `mpo_edo_codigo` | `CNX_MPO_EDO_CODIGO` | N | FK a conex_estados |

---

## 6. tdocumentos_cxc → conex_sincro_cxc (Subida)

**Módulo:** `cxc_sincro_subida.prg`
**Dirección:** Solo subida
**Patrón:** Upsert PK Compuesta (Patrón B)

Ver skill `galepso-cxc` para mapeo detallado.

---

## 7. conex_documentos → tpedidos (Bajada)

**Módulo:** `pedidos.prg`
**Dirección:** Solo bajada
**Patrón:** Bajada Transaccional (Patrón C)

### Cabecera

| Campo MariaDB | Campo VFP | Transformación |
|---------------|-----------|----------------|
| `CNX_DCL_NUMERO` | `cid_pedido` | Casteo dinámico C/N |
| `CNX_DCL_CLT_CODIGO` | `cid_clien` | `STR(VAL(...), 5)` |
| `CNX_DCL_VEN_CODIGO` | `cid_vende` | `STR(VAL(...), 5)` |
| `CNX_DCL_FECHA` | `dfecha` | Casteo T→D o C→D |
| `CNX_DCL_NETO` | `nmonto_t` | Casteo a Currency si aplica |
| Constante `"  1"` | `cid_status` | Status pendiente |
| Constante `" 1"` | `ctipo_pre` | Tipo precio default |

### Detalle (conex_movimientos → tdetalles_pedido)

| Campo MariaDB | Campo VFP | Transformación |
|---------------|-----------|----------------|
| `CNX_MCL_DCL_NUMERO` | `cid_pedido` | Casteo dinámico C/N |
| `CNX_MCL_UPP_PDT_CODIGO` | `cid_produc` | Casteo dinámico C/N |
| `CNX_MCL_CANTIDAD` | `ncantidad` | Casteo a Currency si aplica |
| `CNX_MCL_BASE` | `nprecio` | Casteo a Currency si aplica |
| Calculado | `nmonto` | `ncantidad * nprecio` |

**Filtro de descarga:** `CNX_CHECK = 0 AND CNX_DCL_TDT_CODIGO = 'PED'`

**Confirmación:** `UPDATE conex_documentos SET CNX_CHECK = 1 WHERE CNX_DCL_NUMERO IN (...) AND CNX_DCL_TDT_CODIGO = 'PED'`
