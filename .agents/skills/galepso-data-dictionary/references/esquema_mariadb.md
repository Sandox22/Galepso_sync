# Esquemas de Tablas MariaDB (Nube)

Esquemas validados de las tablas destino en MariaDB (base de datos `bdsistemas2`).
Motor: MyISAM, Charset: utf8.

---

## conex_clientes

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_CLT_CODIGO` | VARCHAR(10) | NO | - | **PK** |
| `CNX_CLT_NOMBRE` | VARCHAR(160) | SI | NULL | Nombre/razón social |
| `CNX_CLT_RIF` | VARCHAR(15) | SI | NULL | RIF |
| `CNX_CLT_TELEFONO1` | VARCHAR(20) | SI | NULL | Teléfono |
| `CNX_CLT_DIRECCION1` | VARCHAR(250) | SI | NULL | Dirección |
| `CNX_CLT_PLT_LISTA` | VARCHAR(5) | NO | 'A' | Lista de precios |
| `CNX_CLT_EDO_CODIGO` | INT | NO | 1 | FK: Estado |
| `CNX_CLT_MPO_CODIGO` | INT | NO | 1 | FK: Municipio |
| `CNX_CLT_VEN_CODIGO` | VARCHAR(3) | SI | NULL | FK: Vendedor ADN |
| `CNX_CLT_CHECK` | INT(1) | NO | 0 | Flag sincronización |
| `CNX_CLT_DIASCRE` | INT | NO | 0 | Días de crédito |
| `CNX_CLT_DIAVISITA` | VARCHAR(20) | NO | 'LUNES' | Día visita |
| `CNX_CLT_GALEXO` | VARCHAR(10) | SI | NULL | Código Galepso asignado |

---

## conex_estados

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_EDOCODIGO` | INT | NO | - | **PK** |
| `CNX_EDODESCRI` | VARCHAR(300) | SI | NULL | Descripción |
| `CNX_EDOACTIVO` | TINYINT(1) | NO | 1 | Activo (1/0) |

---

## conex_municipios

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_MPO_CODIGO` | INT | NO | - | **PK** |
| `CNX_MPO_DESCRI` | VARCHAR(300) | SI | NULL | Descripción |
| `CNX_MPO_EDO_CODIGO` | INT | NO | - | FK: conex_estados |

---

## conex_productos

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_PDT_CODIGO` | VARCHAR(50) | NO | - | **PK** |
| `CNX_PDT_DESCRIPCION` | VARCHAR(200) | SI | NULL | Descripción |
| `CNX_PDT_TIV_CODIGO` | VARCHAR(10) | SI | NULL | Tipo IVA (EX/GN/RD) |
| `CNX_PDT_PRE_PRECIO` | DECIMAL(14,2) | SI | NULL | Precio (referencia) |
| `CNX_PDT_EXIS` | DECIMAL(14,2) | SI | NULL | Existencia (referencia) |
| `CNX_PDT_CANTXUND` | DECIMAL(14,3) | SI | NULL | Cantidad por unidad |
| `CNX_UND_ID` | VARCHAR(10) | SI | NULL | Unidad de medida |
| `CNX_PDT_FACTOR` | DECIMAL(14,2) | SI | NULL | Factor de empaque |
| `CNX_PDT_CHECK` | INT(1) | NO | 0 | Flag sincronización |

---

## conex_precios

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_PRE_PDT_CODIGO` | VARCHAR(50) | NO | - | **PK parcial** |
| `CNX_PRE_UGR_UND_ID` | VARCHAR(10) | NO | - | **PK parcial** |
| `CNX_PRE_PLT_LISTA` | VARCHAR(5) | NO | - | **PK parcial** |
| `CNX_PRE_PRECIO` | DECIMAL(14,2) | NO | 0.00 | Precio |
| `CNX_PRE_PORUTIL` | DECIMAL(14,7) | SI | NULL | % Utilidad |

---

## conex_documentos

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_DCL_NUMERO` | VARCHAR(20) | NO | - | **PK parcial** |
| `CNX_DCL_TDT_CODIGO` | VARCHAR(5) | NO | - | **PK parcial** |
| `CNX_DCL_SCS_CODIGO` | VARCHAR(6) | NO | '000001' | **PK parcial** |
| `CNX_DCL_REC_NUMERO` | VARCHAR(20) | NO | - | **PK parcial** |
| `CNX_DCL_VEN_CODIGO` | VARCHAR(10) | NO | '001' | FK: Vendedor |
| `CNX_DCL_CLT_CODIGO` | VARCHAR(10) | NO | - | **PK parcial**: Cliente |
| `CNX_DCL_FECHA` | DATE | SI | NULL | Fecha emisión |
| `CNX_DCL_NETO` | DECIMAL(14,3) | SI | NULL | Monto neto |
| `CNX_DCL_BASEG` | DECIMAL(14,3) | SI | NULL | Base imponible general |
| `CNX_DCL_EXENTO` | DECIMAL(14,3) | SI | NULL | Monto exento |
| `CNX_DCL_TIPTRA` | CHAR(1) | SI | NULL | Tipo transacción (D/P) |
| `CNX_DCL_CXC` | VARCHAR(2) | SI | NULL | Indicador CxC (0/1/-1) |
| `CNX_DCL_ACTIVO` | TINYINT(1) | NO | 1 | **PK parcial**: Activo |
| `CNX_DCL_STD_ESTADO` | VARCHAR(5) | SI | NULL | Estado (PEN/PAG) |
| `CNX_DCL_FECHAHORA` | DATETIME | SI | NULL | Fecha+hora registro |
| `CNX_DCL_CONDICION` | VARCHAR(10) | SI | NULL | Condición (CREDITO/CONTADO) |
| `CNX_DCL_VALORCAM` | DECIMAL(14,8) | SI | NULL | Tasa BCV |
| `CNX_DCL_FECHAVEN` | DATE | SI | NULL | Fecha vencimiento |
| `CNX_CHECK` | INT | NO | 0 | Flag sincronización |
| `CNX_PED_GALEXO` | VARCHAR(100) | SI | NULL | ID Galepso |

---

## conex_movimientos

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CNX_MCL_DCL_NUMERO` | VARCHAR(20) | NO | - | **PK parcial**: Nro doc |
| `CNX_MCL_DCL_TDT_CODIGO` | VARCHAR(5) | NO | - | **PK parcial**: Tipo doc |
| `CNX_MCL_AMC_CODIGO` | VARCHAR(10) | NO | '001' | **PK parcial**: Almacén |
| `CNX_MCL_UPP_PDT_CODIGO` | VARCHAR(20) | NO | - | **PK parcial**: Producto |
| `CNX_MCL_UPP_UND_ID` | VARCHAR(10) | NO | - | **PK parcial**: Unidad |
| `CNX_MCL_CTR_CODIGO` | VARCHAR(10) | NO | '' | **PK parcial**: Centro costo |
| `CNX_MCL_CANTIDAD` | DECIMAL(14,3) | SI | NULL | Cantidad |
| `CNX_MCL_ACTIVO` | TINYINT(1) | NO | 0 | Activo |
| `CNX_MCL_BASE` | DECIMAL(14,4) | SI | NULL | Precio base unitario |
| `CNX_MCL_DCL_TIPTRA` | CHAR(1) | NO | - | **PK parcial**: Tipo transacción |
| `CNX_MCL_PLT_LISTA` | VARCHAR(5) | SI | NULL | Lista precios |
| `CNX_MCL_CANTXUND` | DECIMAL(14,3) | SI | NULL | Cantidad por unidad |
| `CNX_MCL_PORIVA` | DECIMAL(14,2) | SI | NULL | % IVA |
| `CNX_MCL_VEN_CODIGO` | VARCHAR(10) | SI | NULL | FK: Vendedor |
| `CNX_MCL_DESCRI` | VARCHAR(80) | SI | NULL | Descripción producto |

---

## conex_sincro_cxc

| Campo | Tipo | Nullable | Default | Rol |
|-------|------|----------|---------|-----|
| `CODIGO` | VARCHAR(20) | NO | '' | **PK (1/3)**: Código cliente |
| `NUMERO` | VARCHAR(20) | NO | '' | **PK (2/3)**: Número documento |
| `TIPO` | VARCHAR(10) | NO | '' | **PK (3/3)**: Tipo documento |
| `FECHA` | DATE | SI | NULL | Fecha emisión |
| `FECHAVEN` | DATE | SI | NULL | Fecha vencimiento |
| `SALDO` | DECIMAL(20,2) | NO | 0.00 | Saldo pendiente |
| `VEN_CODIGO` | VARCHAR(10) | NO | - | Código vendedor |
| `UPD` | TIMESTAMP | NO | CURRENT_TIMESTAMP | Última actualización (auto) |
| `TASA` | DECIMAL(20,4) | NO | 0.0000 | Tasa de cambio |
| `TASACOP` | DECIMAL(20,4) | NO | 0.0000 | Tasa COP |
| `COMENTARIO` | VARCHAR(255) | SI | NULL | Observaciones |
| `INFOCXC` | TEXT | NO | - | Info extendida CxC |
| `FACT_AFECT` | VARCHAR(255) | SI | NULL | Facturas afectadas |
| `ID_ORIGEN` | VARCHAR(100) | SI | '' | ID sistema origen |
| `ID_ENTERPRISE` | VARCHAR(50) | SI | '3' | ID empresa (KW = '3') |
