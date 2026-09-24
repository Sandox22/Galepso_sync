* precios.prg
* Módulo independiente para sincronización de precios a conex_precios
* Arquitectura Modular - Fase 1

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[Precios] ERROR: Handle ODBC invalido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL tcMapPre, lnResPre, lcDirData

* Obtener directorio de data
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura defensiva de las tablas
IF !USED("tproductos")
    IF FILE(lcDirData + "tproductos.dbf")
        USE (lcDirData + "tproductos.dbf") SHARED IN 0 ALIAS tproductos
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tproductos.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

IF !USED("tproductos_precio")
    IF FILE(lcDirData + "tproductos_precio.dbf")
        USE (lcDirData + "tproductos_precio.dbf") SHARED IN 0 ALIAS tproductos_precio
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tproductos_precio.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Preparación de cursores
SELECT pr.cid_produc, ;
       ICASE(ALLTRIM(pr.ctipo_pre) == "1", "A", ;
             ALLTRIM(pr.ctipo_pre) == "2", "B", ;
             ALLTRIM(pr.ctipo_pre) == "3", "C", ;
             ALLTRIM(pr.ctipo_pre) == "4", "D", "X") AS ctipo_pre, ;
       pr.nprecio, ;
       PADR(IIF(EMPTY(p.cempaque) OR ISNULL(p.cempaque), "UND", ALLTRIM(p.cempaque)), 15) AS cemp_sync ;
FROM tproductos_precio pr ;
LEFT JOIN tproductos p ON ALLTRIM(pr.cid_produc) = ALLTRIM(p.cid_produc) ;
WHERE INLIST(ALLTRIM(pr.ctipo_pre), "1", "2", "3", "4") ;
  AND ALLTRIM(p.cclasi1) == '05' ;
INTO CURSOR cur_precios_sync READWRITE

tcMapPre = "cid_produc|CNX_PRE_PDT_CODIGO|C,ctipo_pre|CNX_PRE_PLT_LISTA|C,nprecio|CNX_PRE_PRECIO|N,cemp_sync|CNX_PRE_UGR_UND_ID|C"

lnResPre = SyncUpsert(tnH, "cur_precios_sync", "conex_precios", tcMapPre)

* Cierre de cursores temporales
IF USED("cur_precios_sync")
    USE IN cur_precios_sync
ENDIF

* Control de errores y reporte global
IF TYPE("PCESTADOENVIA") = "C"
    IF lnResPre > 0
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + lnResPre
        ENDIF
        PCESTADOENVIA = PCESTADOENVIA + "Productos Precios Insertados con exito " + TTOC(DATETIME()) + CHR(13)
    ELSE
        IF lnResPre < 0
            LOCAL ARRAY laErr[1]
            AERROR(laErr)
            LOCAL lcErrMsg
            lcErrMsg = IIF(TYPE("laErr[2]") = "C", laErr[2], "Error SQL Desconocido o código: " + TRANSFORM(lnResPre))
            PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR PRECIOS: " + lcErrMsg + CHR(13)
        ELSE
            PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Precios " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ENDIF
ENDIF

RETURN lnResPre
