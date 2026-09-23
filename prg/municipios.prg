* municipios.prg
* Módulo independiente para sincronización de la tabla tciudades a conex_municipios
* Arquitectura Modular - Fase 1
*
* Mapeo Local -> Nube:
*   tciudades.cid_estado + tciudades.cid_ciudad  ->  CNX_MPO_CODIGO  (PK numérica compuesta)
*   tciudades.cdescripci                          ->  CNX_MPO_DESCRI  (Texto)
*   tciudades.cid_estado                          ->  CNX_MPO_EDO_CODIGO (FK numérica)
*
* Nota: CNX_MPO_CODIGO se genera como código compuesto: VAL(cid_estado) * 100 + VAL(cid_ciudad)
*       Ej: estado "01", ciudad "03" => CNX_MPO_CODIGO = 103

LPARAMETERS tnH
IF TYPE("tnH") <> "N" OR tnH <= 0
    MESSAGEBOX("Se requiere un handle de conexión ODBC válido para sincronizar municipios.", 16, "Error")
    RETURN .F.
ENDIF

LOCAL tcMapMpo, lnResMpo, lcDirData

* Obtener directorio de data
IF TYPE("dirdata") = "U"
    lcDirData = "X:\Galepso\Data\Emp6\"
ELSE
    lcDirData = dirdata
ENDIF

* Apertura defensiva de la tabla
IF !USED("tciudades")
    IF FILE(lcDirData + "tciudades.dbf")
        USE (lcDirData + "tciudades.dbf") SHARED IN 0 ALIAS tciudades
    ELSE
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + "No se encontro tciudades.dbf en " + lcDirData + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Construcción del cursor temporal con el código compuesto
* CNX_MPO_CODIGO = VAL(cid_estado) * 100 + VAL(cid_ciudad)
* Esto genera un código numérico único por municipio.
SELECT VAL(CID_ESTADO) * 100 + VAL(CID_CIUDAD) AS mpo_codigo, ;
       ALLTRIM(CDESCRIPCI) AS mpo_descri, ;
       VAL(CID_ESTADO) AS mpo_edo_codigo ;
FROM tciudades ;
WHERE !EMPTY(ALLTRIM(CID_ESTADO)) AND !EMPTY(ALLTRIM(CDESCRIPCI)) ;
INTO CURSOR cur_municipios_sync READWRITE

* Mapa de campos: campo_local|CAMPO_REMOTO|Tipo
* Primera columna = PK (mpo_codigo -> CNX_MPO_CODIGO)
tcMapMpo = "mpo_codigo|CNX_MPO_CODIGO|N,mpo_descri|CNX_MPO_DESCRI|C,mpo_edo_codigo|CNX_MPO_EDO_CODIGO|N"

lnResMpo = SyncUpsert(tnH, "cur_municipios_sync", "conex_municipios", tcMapMpo)

* Cierre exclusivo del cursor temporal
IF USED("cur_municipios_sync")
    USE IN cur_municipios_sync
ENDIF

* Control de errores y reporte global
IF TYPE("PCESTADOENVIA") = "C"
    IF lnResMpo > 0
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + lnResMpo
        ENDIF
        PCESTADOENVIA = PCESTADOENVIA + "Municipios Insertados con exito " + TTOC(DATETIME()) + CHR(13)
    ELSE
        IF lnResMpo < 0
            LOCAL ARRAY laErrMpo[1]
            AERROR(laErrMpo)
            LOCAL lcErrMsgMpo
            lcErrMsgMpo = IIF(TYPE("laErrMpo[2]") = "C", laErrMpo[2], "Error SQL Desconocido o código: " + TRANSFORM(lnResMpo))
            PCESTADOENVIA = PCESTADOENVIA + CHR(13) + "ERROR MUNICIPIOS: " + lcErrMsgMpo + CHR(13)
        ELSE
            PCESTADOENVIA = PCESTADOENVIA + "No se encontraron registros para Municipios " + TTOC(DATETIME()) + CHR(13)
        ENDIF
    ENDIF
ENDIF

RETURN lnResMpo
