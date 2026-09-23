---
name: galepso-pedidos
description: >-
  Patrón de bajada transaccional desde MariaDB hacia VFP local con integridad
  ACID. Usar cuando el usuario pida sincronizar pedidos, devoluciones, recibos,
  visitas, o cualquier descarga de documentos desde la nube hacia tablas locales
  de VFP con cabecera+detalle y confirmación bulk.
---

# Patrón C: Bajada Transaccional (Nube → VFP Local)

## Descripción

Para descargar documentos desde MariaDB hacia tablas locales de VFP con
integridad transaccional ACID. Incluye manejo de cabecera+detalle, casteo
dinámico de tipos, y confirmación bulk en la nube.

**Archivo de referencia:** `C:\liderplussync\prg\pedidos.prg`

## Módulos que Usan Este Patrón

| Módulo | Tablas Nube | Tablas Locales | Estado |
|--------|-------------|----------------|--------|
| `pedidos.prg` | `conex_documentos` + `conex_movimientos` | `tpedidos` + `tdetalles_pedido` | ✅ Refactorizado |
| `devoluciones.prg` | Consulta SQL directa | `tdevoluciones_venta` + `tdetalles_devolucion_venta` | ⚠️ Legacy |
| `recibos.prg` | Consulta SQL directa | `trecibos_ingreso` + `tdetalles_recibo_ingreso` | ⚠️ Legacy |
| `visitas.prg` | Consulta SQL directa | `tvisitas_empresa` + `tdetalles_finca` | ⚠️ Legacy |

## Algoritmo Transaccional

### Paso 1: Extracción desde la Nube
```foxpro
* Cabeceras: solo documentos no descargados (CNX_CHECK = 0)
lcSqlDoc = "SELECT * FROM conex_documentos " + ;
           "WHERE CNX_CHECK = 0 AND CNX_DCL_TDT_CODIGO = 'PED'"
cmdPedidos = SQLEXEC(lnHandle, lcSqlDoc, "ttconex_doc")

* Detalles: solo los asociados a cabeceras pendientes
lcSqlMov = "SELECT d.* FROM conex_movimientos d " + ;
           "INNER JOIN conex_documentos c " + ;
           "ON d.CNX_MCL_DCL_NUMERO = c.CNX_DCL_NUMERO " + ;
           "WHERE c.CNX_CHECK = 0 AND c.CNX_DCL_TDT_CODIGO = 'PED'"
cmdDetalles = SQLEXEC(lnHandle, lcSqlMov, "ttconex_mov")
```

### Paso 2: Casteo Dinámico de Tipos

Los campos de MariaDB pueden llegar como tipos diferentes a los de VFP.
**Siempre** usar `TYPE()` para detectar y convertir dinámicamente:

```foxpro
* cid_pedido: puede ser C o N en VFP
IF TYPE("tpedidos.cid_pedido") = "C"
    lvPedidoID = ALLTRIM(TRANSFORM(ttconex_doc.CNX_DCL_NUMERO))
ELSE
    lvPedidoID = VAL(TRANSFORM(ttconex_doc.CNX_DCL_NUMERO))
ENDIF

* Fechas: MariaDB puede devolver DateTime(T) o String(C)
DO CASE
    CASE TYPE("tpedidos.dfecha") = "D" AND TYPE("ttconex_doc.CNX_DCL_FECHA") = "T"
        lvFecha = TTOD(ttconex_doc.CNX_DCL_FECHA)
    CASE TYPE("tpedidos.dfecha") = "D" AND TYPE("ttconex_doc.CNX_DCL_FECHA") = "C"
        lvFecha = CTOD(ttconex_doc.CNX_DCL_FECHA)
    OTHERWISE
        lvFecha = ttconex_doc.CNX_DCL_FECHA
ENDCASE

* Montos: Si VFP espera Currency (Y), hacer CAST
IF TYPE("tpedidos.nmonto_t") = "Y"
    lvMontoT = CAST(lvMontoT AS Y)
ENDIF
```

### Paso 3: Verificación de Duplicados
```foxpro
SELECT tpedidos
LOCATE FOR cid_pedido = lvPedidoID
IF FOUND()
    * Ya existe en local → saltar
    SELECT ttconex_doc
    SKIP
    LOOP
ENDIF
```

### Paso 4: Transacción Local ACID
```foxpro
BEGIN TRANSACTION

TRY
    * Insertar cabecera
    INSERT INTO tpedidos (cid_pedido, cid_clien, dfecha, ...) ;
        VALUES (lvPedidoID, lvClienteID, lvFecha, ...)

    * Insertar detalles (ciclo)
    SELECT ttconex_mov
    SET FILTER TO ALLTRIM(CNX_MCL_DCL_NUMERO) == ALLTRIM(ttconex_doc.CNX_DCL_NUMERO)
    GO TOP
    DO WHILE !EOF()
        INSERT INTO tdetalles_pedido (...) VALUES (...)
        SELECT ttconex_mov
        SKIP
    ENDDO
    SET FILTER TO

    * Forzar escritura a disco
    IF !TABLEUPDATE(1, .T., "tpedidos") OR !TABLEUPDATE(1, .T., "tdetalles_pedido")
        llErrorPedido = .T.
    ENDIF
CATCH
    LOCAL ARRAY laError[1]
    AERROR(laError)
    llErrorPedido = .T.
ENDTRY

IF llErrorPedido
    ROLLBACK
ELSE
    END TRANSACTION
    FLUSH FORCE
    * Acumular para Bulk Update
    lcPedidosSuccess = lcPedidosSuccess + "'" + ALLTRIM(ttconex_doc.CNX_DCL_NUMERO) + "',"
ENDIF
```

### Paso 5: Confirmación Bulk en la Nube
```foxpro
IF LEN(lcPedidosSuccess) > 0
    lcPedidosSuccess = SUBSTR(lcPedidosSuccess, 1, LEN(lcPedidosSuccess) - 1)

    * Marcar como descargados (CNX_CHECK = 1)
    lcSqlUpdate = "UPDATE conex_documentos SET CNX_CHECK = 1 " + ;
                  "WHERE CNX_DCL_NUMERO IN (" + lcPedidosSuccess + ") " + ;
                  "AND CNX_DCL_TDT_CODIGO = 'PED'"
    SQLEXEC(lnHandle, lcSqlUpdate)

    * Notificación por correo (opcional)
    correo(lcPedidosSuccess)
ENDIF
```

## Prerequisitos del Patrón

Antes de usar BEGIN TRANSACTION, asegurar:

```foxpro
* Saneamiento preventivo de transacciones huérfanas
DO WHILE TXNLEVEL() > 0
    ROLLBACK
ENDDO

* Habilitar multilocks para Table Buffering
SET MULTILOCKS ON

* Habilitar Buffering Optimista de Tabla (nivel 5)
CURSORSETPROP("Buffering", 5, "tpedidos")
CURSORSETPROP("Buffering", 5, "tdetalles_pedido")
```

## Notificación por Correo (CDO)

Los módulos de bajada pueden incluir notificación via CDO (gmail SMTP):

```foxpro
loCfg = CREATEOBJECT("CDO.Configuration")
WITH loCfg.Fields
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465
    .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = .T.
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
    .Update
ENDWITH

loMsg = CREATEOBJECT("CDO.Message")
WITH loMsg
    .Configuration = loCfg
    .From = "ventasypedidoselite@gmail.com"
    .Subject = "Notificación de documentos recibidos"
    .HTMLBody = strHTML
    .Send()
ENDWITH
```

## Diferencias entre Módulos Legacy y Refactorizados

| Aspecto | pedidos.prg (Refactorizado) | devoluciones/recibos/visitas (Legacy) |
|---------|----------------------------|---------------------------------------|
| Parámetros | `LPARAMETERS tnH` | Sin parámetros, conexión propia |
| Transacciones | `BEGIN TRANSACTION` / `END TRANSACTION` | Sin transacciones ACID |
| Casteo de tipos | Dinámico con `TYPE()` | Hardcoded |
| Duplicados | `LOCATE FOR` antes de insertar | `SEEK` con índice |
| Confirmación | Bulk `UPDATE ... IN (...)` | `UPDATE ... CASE WHEN` |
| Error handling | `TRY/CATCH` + `AERROR` | Sin manejo estructurado |

Los módulos legacy están **pendientes de refactorización** al estándar de `pedidos.prg`.
