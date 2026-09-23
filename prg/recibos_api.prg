SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DATE TO british
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata, lcApiBase, lcResp, lnTotalReg
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
USE SHARED (dirdata + "trecibos_ingreso.dbf") IN 0
USE SHARED (dirdata + "tdetalles_recibo_ingreso.dbf") IN 0
USE SHARED (dirdata + "tclientes.dbf") IN 0

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"

* --- Descargar recibos ---
lcResp = ApiCall(lcApiBase + "/recibo-ingreso", "GET", "")
IF !ApiSuccess(lcResp)
    PCESTADOENVIA = "Error API recibos: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
    RETURN
ENDIF

lnReg = JsonArrayToCursor(lcResp, "ttrecibos")
IF lnReg = 0
    PCESTADOENVIA = "No hay recibos nuevos en el servidor " + TTOC(DATETIME())
    RETURN
ENDIF

* --- Descargar detalles ---
lcRespDet = ApiCall(lcApiBase + "/detalle-recibo-ingreso", "GET", "")
lnRegDet = JsonArrayToCursor(lcRespDet, "ttdetalles_recibo")

SELECT trecibos_ingreso
SET ORDER TO IX_RECIBO

SELECT ttrecibos
GO bottom
nTotalRegistros = RECNO()
GO top

DO WHILE !EOF()
    SELECT trecibos_ingreso
    SEEK(PADL(ALLTRIM(JsonStr(ttrecibos.cid_reci_i)),8))
    IF FOUND()
        SELECT ttrecibos
        SKIP
        LOOP
    ENDIF

    APPEND BLANK
    REPLACE cid_reci_i WITH PADL(ALLTRIM(JsonStr(ttrecibos.cid_reci_i)),8)
    REPLACE cid_clien WITH PADL(ALLTRIM(JsonStr(ttrecibos.cid_clien)),5)
    REPLACE dfecha WITH JsonDate(JsonStr(ttrecibos.dfecha))
    REPLACE cid_status WITH "  1"
    REPLACE nmonto WITH JsonVal(ttrecibos.nmonto)

    * Detalles del recibo
    IF lnRegDet > 0
        SELECT ttdetalles_recibo
        SET FILTER TO ALLTRIM(JsonStr(ttdetalles_recibo.creferenci)) == ALLTRIM(JsonStr(ttrecibos.cid_reci_i))
        GO TOP
        DO WHILE !EOF()
            SELECT tdetalles_recibo_ingreso
            APPEND BLANK
            REPLACE cid_docum WITH JsonStr(ttdetalles_recibo.cid_docum)
            REPLACE cid_tipo_d WITH JsonStr(ttdetalles_recibo.cid_tipo_d)
            REPLACE nmonto_d WITH JsonVal(ttdetalles_recibo.nmonto_d)
            REPLACE nmonto_h WITH JsonVal(ttdetalles_recibo.nmonto_h)
            REPLACE nsaldo WITH JsonVal(ttdetalles_recibo.nsaldo)
            REPLACE creferenci WITH JsonStr(ttdetalles_recibo.creferenci)
            SELECT ttdetalles_recibo
            SKIP
        ENDDO
    ENDIF

    SELECT ttrecibos
    SKIP
ENDDO

CLOSE DATABASES ALL
PCESTADOENVIA = "Recibos via API recibidos con exito " + TTOC(DATETIME())
