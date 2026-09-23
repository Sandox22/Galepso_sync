---
name: galepso-cxc
description: >-
  Patrón de sincronización de Cuentas por Cobrar (CxC) con upsert manual de
  llave primaria compuesta. Usar cuando el usuario pida sincronizar CxC,
  documentos de cuentas por cobrar, facturas pendientes, saldos de clientes
  hacia conex_sincro_cxc, o cualquier tabla con PK compuesta de múltiples
  columnas que no pueda usar SyncUpsert.
---

# Patrón B: Upsert Manual con PK Compuesta (CxC)

## Descripción

Para tablas transaccionales con clave primaria compuesta de N columnas, el
motor genérico SyncUpsert **NO es compatible** (asume PK de columna única).
Se requiere un bloque transaccional explícito con verificación de existencia.

**Archivo de referencia:** `C:\liderplussync\prg\cxc_sincro_subida.prg`

## Tabla Destino: conex_sincro_cxc

| Propiedad | Valor |
|-----------|-------|
| Motor | MyISAM |
| Charset | utf8 |
| PK Compuesta | `(CODIGO, NUMERO, TIPO)` |

## Mapeo de Campos VFP → MariaDB

### Campos de PK (Llave Compuesta)

| Campo VFP (tdocumentos_cxc) | Campo MariaDB | Transformación |
|-----------------------------|---------------|----------------|
| `cid_clien` | `CODIGO` | `ALLTRIM()` |
| `cid_doccxc` | `NUMERO` | `ALLTRIM()` |
| `cid_tipo_d` | `TIPO` | Traducción via `TraducirTipoDoc()` |

### Campos de Datos

| Campo VFP | Campo MariaDB | Tipo | Transformación |
|-----------|---------------|------|----------------|
| `dfecha` | `FECHA` | DATE | `FechaISO()` → `'YYYY-MM-DD'` |
| `dfecha_ven` | `FECHAVEN` | DATE | `FechaISO()` → `'YYYY-MM-DD'` |
| `nsaldo` | `SALDO` | DECIMAL(20,2) | `STR(lnSaldo, 20, 2)` |
| `cid_vende` | `VEN_CODIGO` | VARCHAR(10) | `ALLTRIM()` |
| `nfactor` | `TASA` | DECIMAL(20,4) | `STR(lnTasa, 20, 4)` |
| `mobservaci` | `COMENTARIO` | VARCHAR(255) | **Sanitización obligatoria de Memo** |

### Constantes Fijas

| Campo MariaDB | Valor | Descripción |
|---------------|-------|-------------|
| `ID_ENTERPRISE` | `'3'` | Identificador asignado a KW |
| `TASACOP` | `0.00` | Sin tasa COP |

### Estructura Física Validada para INFOCXC

El campo `INFOCXC` en `conex_sincro_cxc` recibe un arreglo JSON construido a partir de:

- **Tabla Detalle:** `tdetalles_factura`
  - Enlace con CxC: `cid_factu` (con `tdocumentos_cxc.cid_doccxc`)
  - SKU / Producto: `cid_produc`
  - Cantidad: `ncantidad`
  - Precio: `nprecio`
  - Total línea: `nmonto` (NO existe `ntotal`)
- **Tabla Maestro:** `tproductos`
  - Código: `cid_produc`
  - Descripción / Nombre: `cdescripci`

## Filtro de Vendedores (Distribuidores)

El campo que identifica el tipo de vendedor en `tvendedores` es **`ctipo_v`**
(NO `cid_tipove`, que no existe).

```foxpro
* Verificar existencia del campo antes de usarlo
IF TYPE("tvendedores.ctipo_v") <> "U"
    * Filtro completo: solo vendedores tipo 2 (DISTRIBUIDORES)
    ... WHERE VAL(v.ctipo_v) = 2 AND v.lactivo = .T.
ELSE
    * Fallback: solo vendedores activos (sin filtro de tipo)
    ... WHERE v.lactivo = .T.
ENDIF
```

## Traducción de Tipos de Documento

La función `TraducirTipoDoc()` convierte el código numérico de Galepso al
código alfanumérico de la nube:

| cid_tipo_d (VFP) | TIPO (MariaDB) | Descripción |
|-------------------|----------------|-------------|
| `"1"` / `"01"` | `"FAV"` | Factura de Venta |
| `"2"` / `"02"` | `"NEN"` | Nota de Entrega |
| `"3"` / `"03"` | `"DEBV"` | Nota de Débito de Venta |
| `"4"` / `"04"` | `"CREV"` | Nota de Crédito de Venta |
| `"5"` / `"05"` | `"ANT"` | Anticipo |

**Estrategia dual:**
1. Primero busca en `ttipos_documentocxc.cabreviado` (catálogo dinámico)
2. Si no encuentra, aplica tabla estática con `DO CASE`

## Sanitización de Campo Memo (mobservaci)

El campo `mobservaci` es un Memo nativo de VFP. **Siempre** aplicar esta
sanitización antes de insertar en MariaDB:

```foxpro
IF TYPE("curCxC_Subida.mobservaci") $ "CM"
    lcComentario = NVL(curCxC_Subida.mobservaci, "")
    lcComentario = ALLTRIM(lcComentario)
    lcComentario = LEFT(lcComentario, 255)           && Truncar a VARCHAR(255)
    lcComentario = STRTRAN(lcComentario, "'", "''")   && Escape comillas
    lcComentario = STRTRAN(lcComentario, CHR(13), " ") && Purgar CR
    lcComentario = STRTRAN(lcComentario, CHR(10), " ") && Purgar LF
ELSE
    lcComentario = ""
ENDIF
```

## Algoritmo Transaccional

### Paso 1: Extracción Local
```foxpro
SELECT d.cid_clien, d.cid_doccxc, d.cid_tipo_d, d.dfecha, ;
       d.dfecha_ven, d.nsaldo, d.cid_vende, d.nfactor, d.mobservaci ;
FROM tdocumentos_cxc d ;
INNER JOIN tvendedores v ON ALLTRIM(d.cid_vende) == ALLTRIM(v.cid_vende) ;
WHERE d.nsaldo > 0 ;
  AND !DELETED("tdocumentos_cxc") ;
  AND VAL(v.ctipo_v) = 2 ;
  AND v.lactivo = .T. ;
INTO CURSOR curCxC_Subida READWRITE
```

### Paso 2: Verificación de Existencia (por cada registro)
```foxpro
lcSqlCheck = "SELECT CODIGO FROM conex_sincro_cxc " + ;
             "WHERE CODIGO = '" + lcCodigo + "' " + ;
             "AND NUMERO = '" + lcNumero + "' " + ;
             "AND TIPO = '" + lcTipo + "' LIMIT 1"

lnRetCheck = SQLEXEC(tnH, lcSqlCheck, "curCheckExiste")
```

### Paso 3: Decisión INSERT o UPDATE
```foxpro
IF RECCOUNT("curCheckExiste") = 0
    * INSERTAR (Carga inicial): Inserta cabecera completa + arreglo JSON en INFOCXC
    * (CODIGO, NUMERO, TIPO, FECHA, FECHAVEN, SALDO, VEN_CODIGO, TASA, ID_ENTERPRISE='3', INFOCXC)
    lcSql = "INSERT INTO conex_sincro_cxc (CODIGO, NUMERO, TIPO, ...) VALUES (...)"
ELSE
    * ACTUALIZAR (Sincronizaciones subsecuentes): Exclusivamente quirúrgico sobre SALDO
    lcSql = "UPDATE conex_sincro_cxc SET SALDO = ?nSaldo WHERE CODIGO = ?lcCodigo AND NUMERO = ?lcNumero AND TIPO = ?lcTipo"
ENDIF
```

### Paso 4: Limpieza
```foxpro
IF USED("curCheckExiste")
    USE IN curCheckExiste
ENDIF
```

## Función Auxiliar: FechaISO()

Convierte fecha VFP a formato ISO `'YYYY-MM-DD'`:

```foxpro
FUNCTION FechaISO(tdFecha)
    LOCAL lcAnio, lcMes, lcDia
    lcAnio = ALLTRIM(STR(YEAR(tdFecha), 4))
    lcMes  = PADL(ALLTRIM(STR(MONTH(tdFecha))), 2, "0")
    lcDia  = PADL(ALLTRIM(STR(DAY(tdFecha))), 2, "0")
    RETURN lcAnio + "-" + lcMes + "-" + lcDia
ENDFUNC
```

## Cuándo Usar Este Patrón

- La tabla destino tiene PK compuesta de 2+ columnas
- Se necesita control granular INSERT vs UPDATE
- Se requiere auditoría por registro individual (no en bloque)
- El motor SyncUpsert no aplica (primera columna del map ≠ PK completa)
