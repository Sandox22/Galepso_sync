SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DATE TO british
CLOSE DATABASES ALL
_CALCVALUE=6023

LOCAL dirdata, lcApiBase, lcResp, lnTotalReg, lcPedidos, lcSqlUpdate
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"

USE SHARED (dirdata + "tpedidos.dbf") IN 0
USE SHARED (dirdata + "tdetalles_pedido.dbf") IN 0

SELECT tpedidos
SET ORDER TO ix_pedido

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"
lcResp = ApiCall(lcApiBase + "/pedido", "GET", "")

IF !ApiSuccess(lcResp)
    PCESTADOENVIA = "Error API pedidos: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
    RETURN
ENDIF

lnRegistros = JsonArrayToCursor(lcResp, "ttpedidos")
IF lnRegistros = 0
    PCESTADOENVIA = "No hay pedidos nuevos en el servidor " + TTOC(DATETIME())
    RETURN
ENDIF

lcRespDet = ApiCall(lcApiBase + "/detalle-pedido", "GET", "")
lnRegDet = JsonArrayToCursor(lcRespDet, "ttdetalles_pedido")

SELECT ttpedidos
GO bottom
nTotalRegistros = RECNO()
GO top

lcPedidos = ""

DO WHILE !EOF()
    SELECT tpedidos
    SEEK(PADL(ALLTRIM(JsonStr(ttpedidos.cid_pedido)),8))
    IF FOUND()
        SELECT ttpedidos
        SKIP
        LOOP
    ENDIF

    lcPedidos = lcPedidos + ALLTRIM(JsonStr(ttpedidos.cid_pedido)) + ","
    APPEND BLANK
    REPLACE cid_pedido WITH PADL(ALLTRIM(JsonStr(ttpedidos.cid_pedido)),8)
    REPLACE cid_clien WITH PADL(ALLTRIM(JsonStr(ttpedidos.cid_clien)),5)
    REPLACE dfecha WITH JsonDate(JsonStr(ttpedidos.dfecha))
    REPLACE cid_status WITH "  1"
    REPLACE ctipo_pre WITH " 1"
    REPLACE cid_vende WITH PADL(ALLTRIM(JsonStr(ttpedidos.cid_vende)),5)
    REPLACE cnombre_cl WITH JsonStr(ttpedidos.cnombre_cl)
    REPLACE crif_cli WITH JsonStr(ttpedidos.crif_cli)
    REPLACE nmonto_t WITH JsonVal(ttpedidos.nmonto_t) + JsonVal(ttpedidos.nmontoiva)

    * Detalles del pedido
    IF lnRegDet > 0
        SELECT ttdetalles_pedido
        SET FILTER TO ALLTRIM(JsonStr(ttdetalles_pedido.cid_pedido)) == ALLTRIM(JsonStr(ttpedidos.cid_pedido))
        GO TOP
        DO WHILE !EOF()
            SELECT tdetalles_pedido
            APPEND BLANK
            REPLACE cid_pedido WITH PADL(ALLTRIM(JsonStr(ttdetalles_pedido.cid_pedido)),8)
            REPLACE cid_produc WITH JsonStr(ttdetalles_pedido.cid_produc)
            REPLACE ncantidad WITH JsonVal(ttdetalles_pedido.ncantidad)
            REPLACE nprecio WITH JsonVal(ttdetalles_pedido.nprecio)
            REPLACE nmonto WITH JsonVal(ttdetalles_pedido.nmonto)
            SELECT ttdetalles_pedido
            SKIP
        ENDDO
    ENDIF

    SELECT ttpedidos
    SKIP
ENDDO

CLOSE DATABASES ALL
PCESTADOENVIA = "Pedidos via API recibidos con exito " + TTOC(DATETIME())
