SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET DATE TO british
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata, lcApiBase, lcResp, lnTotalReg
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
USE SHARED (dirdata + "tdevoluciones_venta.dbf") IN 0
USE SHARED (dirdata + "tdetalles_devolucion_venta.dbf") IN 0
USE SHARED (dirdata + "tclientes.dbf") IN 0

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"

* --- Descargar devoluciones ---
lcResp = ApiCall(lcApiBase + "/devolucion-venta", "GET", "")
IF !ApiSuccess(lcResp)
    PCESTADOENVIA = "Error API devoluciones: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
    RETURN
ENDIF

lnReg = JsonArrayToCursor(lcResp, "ttdevoluciones")
IF lnReg = 0
    PCESTADOENVIA = "No hay devoluciones nuevas en el servidor " + TTOC(DATETIME())
    RETURN
ENDIF

* --- Descargar detalles ---
lcRespDet = ApiCall(lcApiBase + "/detalle-devolucion-venta", "GET", "")
lnRegDet = JsonArrayToCursor(lcRespDet, "ttdetalles_devolucion")

SELECT tdevoluciones_venta
SET ORDER TO IX_DEV_VEN

SELECT ttdevoluciones
GO bottom
nTotalRegistros = RECNO()
GO top

DO WHILE !EOF()
    SELECT tdevoluciones_venta
    SEEK(PADL(ALLTRIM(JsonStr(ttdevoluciones.cid_dev_v)),8))
    IF FOUND()
        SELECT ttdevoluciones
        SKIP
        LOOP
    ENDIF

    APPEND BLANK
    REPLACE cid_dev_v WITH PADL(ALLTRIM(JsonStr(ttdevoluciones.cid_dev_v)),8)
    REPLACE cid_clien WITH PADL(ALLTRIM(JsonStr(ttdevoluciones.cid_clien)),5)
    REPLACE dfecha WITH JsonDate(JsonStr(ttdevoluciones.dfecha))
    REPLACE cid_status WITH "  1"
    REPLACE cid_vende WITH PADL(ALLTRIM(JsonStr(ttdevoluciones.cid_vende)),5)

    * Detalles de la devolucion
    IF lnRegDet > 0
        SELECT ttdetalles_devolucion
        SET FILTER TO ALLTRIM(JsonStr(ttdetalles_devolucion.cid_dev_v)) == ALLTRIM(JsonStr(ttdevoluciones.cid_dev_v))
        GO TOP
        DO WHILE !EOF()
            SELECT tdetalles_devolucion_venta
            APPEND BLANK
            REPLACE cid_dev_v WITH PADL(ALLTRIM(JsonStr(ttdetalles_devolucion.cid_dev_v)),8)
            REPLACE cid_produc WITH JsonStr(ttdetalles_devolucion.cid_produc)
            REPLACE ncantidad WITH JsonVal(ttdetalles_devolucion.ncantidad)
            REPLACE nprecio WITH JsonVal(ttdetalles_devolucion.nprecio)
            REPLACE nmonto WITH JsonVal(ttdetalles_devolucion.nmonto)
            SELECT ttdetalles_devolucion
            SKIP
        ENDDO
    ENDIF

    SELECT ttdevoluciones
    SKIP
ENDDO

CLOSE DATABASES ALL
PCESTADOENVIA = "Devoluciones via API recibidas con exito " + TTOC(DATETIME())
