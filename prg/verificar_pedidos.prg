LOCAL lcLogFile, lcLog, lcDirData, lcRutaPedidos, lcRutaDetalles
lcLogFile = "X:\Galepso\Data\Emp6\diagnostico_pedidos.txt"
lcLog = "--- DIAGNOSTICO DE PEDIDOS ---" + CHR(13) + CHR(10)
lcLog = lcLog + "Fecha: " + TTOC(DATETIME()) + CHR(13) + CHR(10)

SET SAFETY OFF
SET EXCLUSIVE OFF
SET DELETED OFF
CLOSE DATABASES ALL

lcDirData = "X:\Galepso\Data\Emp6\"
lcRutaPedidos = lcDirData + "tpedidos.dbf"
lcRutaDetalles = lcDirData + "tdetalles_pedido.dbf"

* 1. Verificar ruta fisica y registros
IF FILE(lcRutaPedidos)
    USE (lcRutaPedidos) SHARED IN 0 ALIAS diag_pedidos
    SELECT diag_pedidos
    
    lcLog = lcLog + CHR(13) + CHR(10) + "TABLA: TPEDIDOS" + CHR(13) + CHR(10)
    lcLog = lcLog + "Ruta fisica: " + DBF("diag_pedidos") + CHR(13) + CHR(10)
    lcLog = lcLog + "Total Registros (Fisicos): " + TRANSFORM(RECCOUNT("diag_pedidos")) + CHR(13) + CHR(10)
    
    LOCAL lnBorrados
    lnBorrados = 0
    COUNT FOR DELETED() TO lnBorrados
    lcLog = lcLog + "Total Registros Borrados (DELETED): " + TRANSFORM(lnBorrados) + CHR(13) + CHR(10)
    
    lcLog = lcLog + "Ultimos 5 registros (orden de insercion):" + CHR(13) + CHR(10)
    GO BOTTOM
    LOCAL lnCount
    lnCount = 0
    DO WHILE !BOF() AND lnCount < 5
        lcLog = lcLog + "  Pedido: " + TRANSFORM(cid_pedido) + " | Fecha: " + TRANSFORM(dfecha) + " | Borrado: " + TRANSFORM(DELETED()) + CHR(13) + CHR(10)
        lnCount = lnCount + 1
        SKIP -1
    ENDDO
ELSE
    lcLog = lcLog + "No se encontro tpedidos.dbf en " + lcDirData + CHR(13) + CHR(10)
ENDIF

* Lo mismo para tdetalles_pedido
IF FILE(lcRutaDetalles)
    USE (lcRutaDetalles) SHARED IN 0 ALIAS diag_detalles
    SELECT diag_detalles
    
    lcLog = lcLog + CHR(13) + CHR(10) + "TABLA: TDETALLES_PEDIDO" + CHR(13) + CHR(10)
    lcLog = lcLog + "Ruta fisica: " + DBF("diag_detalles") + CHR(13) + CHR(10)
    lcLog = lcLog + "Total Registros (Fisicos): " + TRANSFORM(RECCOUNT("diag_detalles")) + CHR(13) + CHR(10)
    
    LOCAL lnBorradosDet
    lnBorradosDet = 0
    COUNT FOR DELETED() TO lnBorradosDet
    lcLog = lcLog + "Total Registros Borrados (DELETED): " + TRANSFORM(lnBorradosDet) + CHR(13) + CHR(10)
    
    lcLog = lcLog + "Ultimos 5 registros (orden de insercion):" + CHR(13) + CHR(10)
    GO BOTTOM
    lnCount = 0
    DO WHILE !BOF() AND lnCount < 5
        lcLog = lcLog + "  Pedido: " + TRANSFORM(cid_pedido) + " | Producto: " + TRANSFORM(cid_produc) + " | Borrado: " + TRANSFORM(DELETED()) + CHR(13) + CHR(10)
        lnCount = lnCount + 1
        SKIP -1
    ENDDO
ELSE
    lcLog = lcLog + "No se encontro tdetalles_pedido.dbf en " + lcDirData + CHR(13) + CHR(10)
ENDIF

STRTOFILE(lcLog, (lcLogFile))
MESSAGEBOX("Diagnostico generado en " + lcLogFile, 64, "Proceso Completado")
