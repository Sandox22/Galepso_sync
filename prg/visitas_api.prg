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

USE SHARED (dirdata + "tvisitas.dbf") IN 0
USE SHARED (dirdata + "tclientes.dbf") IN 0

SELECT tvisitas
SET ORDER TO ix_visita

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"
lcResp = ApiCall(lcApiBase + "/visita", "GET", "")

IF !ApiSuccess(lcResp)
    PCESTADOENVIA = "Error API visitas: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
    RETURN
ENDIF

lnRegistros = JsonArrayToCursor(lcResp, "ttvisitas")
IF lnRegistros = 0
    PCESTADOENVIA = "No hay visitas nuevas en el servidor " + TTOC(DATETIME())
    RETURN
ENDIF

SELECT ttvisitas
GO bottom
nTotalRegistros = RECNO()
GO top

DO WHILE !EOF()
    SELECT tvisitas
    SEEK(PADL(ALLTRIM(JsonStr(ttvisitas.cid_visita)),8))
    IF FOUND()
        SELECT ttvisitas
        SKIP
        LOOP
    ENDIF

    APPEND BLANK
    REPLACE cid_visita WITH PADL(ALLTRIM(JsonStr(ttvisitas.cid_visita)),8)
    REPLACE cid_clien WITH PADL(ALLTRIM(JsonStr(ttvisitas.cid_clien)),5)
    REPLACE cid_vende WITH PADL(ALLTRIM(JsonStr(ttvisitas.cid_vende)),5)
    REPLACE dfecha WITH JsonDate(JsonStr(ttvisitas.dfecha))
    REPLACE cobservac WITH JsonStr(ttvisitas.cobservacion)

    SELECT ttvisitas
    SKIP
ENDDO

CLOSE DATABASES ALL
PCESTADOENVIA = "Visitas via API recibidas con exito " + TTOC(DATETIME())
