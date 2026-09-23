SET SAFETY OFF
SET EXCLUSIVE OFF
SET EXACT ON
CLEAR
SET EXCLUSIVE OFF
SET DELETED ON
SET DEBUGOUT TO c:\resultado.txt
SET DATE TO JAPAN
CLOSE DATABASES ALL
_CALCVALUE=6023
LOCAL dirdata, lcApiBase, lcBody, lcResp, lcJson, lnCount
dirdata = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
USE SHARED (dirdata + "tclientes.dbf") IN 0
USE SHARED (dirdata + "tfacturas.dbf") IN 0
USE SHARED (dirdata + "tdetalles_factura.dbf") IN 0
USE SHARED (dirdata + "tdevoluciones_venta.dbf") IN 0
USE SHARED (dirdata + "tdetalles_devolucion_venta.dbf") IN 0
USE SHARED (dirdata + "tproductos.dbf") IN 0
USE SHARED (dirdata + "tproductos_precio.dbf") IN 0
USE SHARED (dirdata + "tdocumentos_cxc.dbf") IN 0
USE SHARED (dirdata + "ttipos_documentocxc.dbf") IN 0
USE SHARED (dirdata + "tvendedores.dbf") IN 0

lcApiBase = "https://chocolatesridetti.com/liderplusapirest"

lcJson = '{"tclientes":['

*=== 1. tclientes ===
SELECT tclientes
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_clien":"' + JS_ESCAPE(tclientes.cid_clien) + '","cnombre_cl":"' + JS_ESCAPE(tclientes.cnombre_cl) + '","cdir_cli1":"' + JS_ESCAPE(tclientes.cdir_cli1) + '","cdir_cli2":"' + JS_ESCAPE(tclientes.cdir_cli2) + '","cid_ciudac":"' + JS_ESCAPE(tclientes.cid_ciudac) + '","cid_estadc":"' + JS_ESCAPE(tclientes.cid_estadc) + '","ctele_cli":"' + JS_ESCAPE(tclientes.ctele_cli) + '","ccelu_cli":"' + JS_ESCAPE(tclientes.ccelu_cli) + '","crif_cli":"' + JS_ESCAPE(tclientes.crif_cli) + '","ce_mail":"' + JS_ESCAPE(tclientes.ce_mail) + '","cid_vende":"' + JS_ESCAPE(tclientes.cid_vende) + '","nlimite_c":' + STR(tclientes.nlimite_c,8,2) + ',"nsaldo_a":' + STR(tclientes.nsaldo_a,8,2) + ',"cid_tipo_p":"' + JS_ESCAPE(ALLTRIM(tclientes.cid_tipo_p)) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*=== 2. tdocumentos_cxc ===
lcJson = lcJson + '"tdocumentos_cxc":['
SELECT tdocumentos_cxc
SET FILTER TO nsaldo <> 0 .AND. .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_doccxc":"' + JS_ESCAPE(tdocumentos_cxc.cid_doccxc) + '","cid_tipo_d":"' + JS_ESCAPE(tdocumentos_cxc.cid_tipo_d) + '","cid_clien":"' + JS_ESCAPE(tdocumentos_cxc.cid_clien) + '","dfecha":"' + FECHAGUION(tdocumentos_cxc.dfecha) + '","dfecha_ven":"' + FECHAGUION(tdocumentos_cxc.dfecha_ven) + '","nsaldo":' + STR(tdocumentos_cxc.nsaldo,12,2) + ',"cid_vende":"' + JS_ESCAPE(tdocumentos_cxc.cid_vende) + '","nimpuesto":' + STR(tdocumentos_cxc.nimpuesto,10,2) + ',"nbase":' + STR(tdocumentos_cxc.nbase,10,2) + ',"ntasa_iva":' + STR(tdocumentos_cxc.ntasa_iva,10,2) + ',"cnrofiscal":"' + JS_ESCAPE(tdocumentos_cxc.cnrofiscal) + '","cserie":"' + JS_ESCAPE(tdocumentos_cxc.cserie) + '","ccomprob_f":"' + JS_ESCAPE(tdocumentos_cxc.ccomprob_f) + '","nmonto_d":' + STR(tdocumentos_cxc.nmonto_d,12,2) + ',"nmonto_h":' + STR(tdocumentos_cxc.nmonto_h,12,2) + ',"nfactor":' + STR(tdocumentos_cxc.nfactor,12,6) + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*=== 3. ttipos_documentocxc ===
lcJson = lcJson + '"ttipos_documentocxc":['
SELECT ttipos_documentocxc
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_tipod":"' + JS_ESCAPE(ttipos_documentocxc.cid_tipod) + '","cdescripci":"' + JS_ESCAPE(ttipos_documentocxc.cdescripci) + '","cabreviado":"' + JS_ESCAPE(ttipos_documentocxc.cabreviado) + '","lsuma":' + IIF(ttipos_documentocxc.lsuma,'1','0') + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*=== 4. tvendedores ===
lcJson = lcJson + '"tvendedores":['
SELECT tvendedores
SET FILTER TO .NOT. DELETED() AND lactivo=.T.
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_vende":"' + JS_ESCAPE(tvendedores.cid_vende) + '","cnombrev":"' + JS_ESCAPE(tvendedores.cnombrev) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*=== 5. tfacturas (ultimos 90 dias) ===
lcJson = lcJson + '"tfacturas":['
SELECT tfacturas
SET FILTER TO .NOT. DELETED() AND dfecha >= (DATE()-90) AND (cid_status='999' OR cid_status='  6')
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_factu":"' + JS_ESCAPE(tfacturas.cid_factu) + '","ctipo_fac":"' + JS_ESCAPE(tfacturas.ctipo_fac) + '","cid_clien":"' + JS_ESCAPE(tfacturas.cid_clien) + '","cnombre_cl":"' + JS_ESCAPE(tfacturas.cnombre_cl) + '","crif_cli":"' + JS_ESCAPE(tfacturas.crif_cli) + '","cid_vende":"' + JS_ESCAPE(tfacturas.cid_vende) + '","dfecha":"' + FECHAGUION(tfacturas.dfecha) + '","cid_caja":"' + JS_ESCAPE(tfacturas.cid_caja) + '","dfecha_ven":"' + FECHAGUION(tfacturas.dfecha_ven) + '","cid_pedido":"' + JS_ESCAPE(tfacturas.cid_pedido) + '","cid_tipo_p":"' + JS_ESCAPE(tfacturas.cid_tipo_p) + '","mobservaci":"' + JS_ESCAPE(tfacturas.mobservaci) + '","cid_status":"' + JS_ESCAPE(tfacturas.cid_status) + '","ntasa_iva":' + STR(tfacturas.ntasa_iva,5,2) + ',"nmontoti":' + STR(tfacturas.nmontoti,18,2) + ',"nbase_iva":' + STR(tfacturas.nbase_iva,18,2) + ',"nmontotal":' + STR(tfacturas.nmontotal,18,2) + ',"nmontoiva":' + STR(tfacturas.nmontoiva,18,2) + '}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + '],'

*=== 6. tdetalles_factura ===
lcJson = lcJson + '"tdetalles_factura":['
SELECT tdetalles_factura
SET FILTER TO .NOT. DELETED()
GO TOP
lnCount = 0
SCAN
    IF lnCount > 0
        lcJson = lcJson + ','
    ENDIF
    lcJson = lcJson + '{"cid_factu":"' + JS_ESCAPE(tdetalles_factura.cid_factu) + '","cid_produc":"' + JS_ESCAPE(tdetalles_factura.cid_produc) + '","ncantidad":' + STR(tdetalles_factura.ncantidad,10,2) + ',"nprecio":' + STR(tdetalles_factura.nprecio,10,2) + ',"nmonto":' + STR(tdetalles_factura.nmonto,10,2) + ',"ndescuento":' + STR(tdetalles_factura.ndescuento,10,2) + ',"cid_docum":"' + JS_ESCAPE(tdetalles_factura.cid_docum) + '","mobservaci":"' + JS_ESCAPE(tdetalles_factura.mobservaci) + '","cid_almace":"' + JS_ESCAPE(tdetalles_factura.cid_almace) + '"}'
    lnCount = lnCount + 1
ENDSCAN
lcJson = lcJson + ']}'

*--- Enviar todo en un solo POST ---
lcResp = ApiCall(lcApiBase + "/sync/cxc", "POST", lcJson)
IF ApiSuccess(lcResp)
    PCESTADOENVIA = PCESTADOENVIA + "CXC sincronizado con exito " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = PCESTADOENVIA + "Error sync CXC: " + ApiErrorMsg(lcResp) + " " + TTOC(DATETIME())
ENDIF

CLOSE DATABASES ALL

FUNCTION FECHAGUION
    LPARAMETERS fecha
    RETURN ALLTRIM(STR(YEAR(fecha))) + "-" + ALLTRIM(STR(MONTH(fecha))) + "-" + ALLTRIM(STR(DAY(fecha)))
ENDFUNC

FUNCTION JS_ESCAPE
    LPARAMETERS lcStr
    lcStr = STRTRAN(lcStr, '\', '\\')
    lcStr = STRTRAN(lcStr, '"', '\"')
    lcStr = STRTRAN(lcStr, CHR(13), '\n')
    lcStr = STRTRAN(lcStr, CHR(10), '\n')
    RETURN lcStr
ENDFUNC
