* cxc_sincro_subida.prg
* Sincronizacion de Cuentas por Cobrar (CxC) con Detalles JSON hacia conex_sincro_cxc
* Patrón B: Upsert Manual con PK Compuesta

LPARAMETERS tnH

IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[cxc_sincro_subida] ERROR: Handle ODBC inválido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL lcDirData
IF TYPE("dirdata") = "C" AND !EMPTY(dirdata)
    lcDirData = dirdata
ELSE
    IF TYPE("PCUNIDAD") = "C" AND TYPE("pcSistema") = "C" AND TYPE("pcEmpresa") = "C"
        lcDirData = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
    ELSE
        lcDirData = "X:\Galepso\Data\Emp6\"
    ENDIF
ENDIF

* 1. Apertura defensiva de tablas
LOCAL ARRAY laTablas[4]
laTablas[1] = "tdocumentos_cxc"
laTablas[2] = "tvendedores"
laTablas[3] = "tdetalles_factura"
laTablas[4] = "tproductos"

LOCAL lnI, lcTabla
FOR lnI = 1 TO ALEN(laTablas)
    lcTabla = laTablas[lnI]
    IF !USED(lcTabla)
        IF FILE(lcDirData + lcTabla + ".dbf")
            USE (lcDirData + lcTabla + ".dbf") SHARED IN 0 ALIAS (lcTabla)
        ELSE
            IF TYPE("PCESTADOENVIA") = "C"
                PCESTADOENVIA = PCESTADOENVIA + "[cxc_sincro_subida] No se encontro " + lcTabla + ".dbf en " + lcDirData + CHR(13)
            ENDIF
            RETURN .F.
        ENDIF
    ENDIF
ENDFOR

* 2. Extracción y Filtros: Documentos con saldo > 0 y vendedor distribuidor
SELECT d.cid_clien, ;
       d.cid_doccxc, ;
       d.cid_tipo_d, ;
       d.dfecha, ;
       d.dfecha_ven, ;
       d.nsaldo, ;
       d.cid_vende, ;
       d.nfactor, ;
       d.mobservaci ;
FROM tdocumentos_cxc d ;
INNER JOIN tvendedores v ON ALLTRIM(d.cid_vende) == ALLTRIM(v.cid_vende) ;
WHERE d.nsaldo > 0 ;
  AND !DELETED("tdocumentos_cxc") ;
  AND VAL(v.ctipo_v) = 2 ;
INTO CURSOR curCxC_Subida READWRITE

IF TYPE("PCESTADOENVIA") = "C"
    PCESTADOENVIA = PCESTADOENVIA + " / CxC a subir: " + TRANSFORM(RECCOUNT("curCxC_Subida")) + CHR(13)
ENDIF

IF RECCOUNT("curCxC_Subida") = 0
    IF USED("curCxC_Subida")
        USE IN curCxC_Subida
    ENDIF
    RETURN .T.
ENDIF

SELECT curCxC_Subida
SCAN
    LOCAL lcCodigo, lcNumero, lcTipo, lcFecha, lcFechaVen, lnSaldo, lcVenCodigo, lnTasa, lcComentario, lcFactAfect, lcInfoCxc
    
    * Sanitización e Identificadores (Llave compuesta)
    lcCodigo = ALLTRIM(curCxC_Subida.cid_clien)
    lcNumero = ALLTRIM(curCxC_Subida.cid_doccxc)
    lcTipo   = TraducirTipoDoc(curCxC_Subida.cid_tipo_d)
    
    lcFecha    = FechaISO(curCxC_Subida.dfecha)
    lcFechaVen = FechaISO(curCxC_Subida.dfecha_ven)
    lnSaldo    = curCxC_Subida.nsaldo
    lcVenCodigo = ALLTRIM(curCxC_Subida.cid_vende)
    lnTasa     = curCxC_Subida.nfactor
    
    * Documento afectado (e.g. FACT_AFECT)
    lcFactAfect = .NULL.
    IF TYPE("tdocumentos_cxc.cdoc_afec") = "C"
        lcFactAfect = ALLTRIM(EVALUATE("tdocumentos_cxc.cdoc_afec"))
    ELSE
        IF TYPE("tdocumentos_cxc.cfact_afec") = "C"
            lcFactAfect = ALLTRIM(EVALUATE("tdocumentos_cxc.cfact_afec"))
        ENDIF
    ENDIF

    * Sanitización del Memo
    IF TYPE("curCxC_Subida.mobservaci") $ "CM"
        lcComentario = NVL(curCxC_Subida.mobservaci, "")
        lcComentario = ALLTRIM(lcComentario)
        lcComentario = LEFT(lcComentario, 255)
        lcComentario = STRTRAN(lcComentario, "'", "''")
        lcComentario = STRTRAN(lcComentario, CHR(13), " ")
        lcComentario = STRTRAN(lcComentario, CHR(10), " ")
    ELSE
        lcComentario = ""
    ENDIF

    * Serialización de Detalles en JSON (INFOCXC)
    LOCAL lcJsonDetalles
    lcJsonDetalles = "["
    LOCAL llFirstDetalle
    llFirstDetalle = .T.
    
    LOCAL lcDocId
    lcDocId = ALLTRIM(curCxC_Subida.cid_doccxc)
    
    SELECT df.cid_produc, df.ncantidad, df.nprecio, df.nmonto, p.cdescripci ;
    FROM tdetalles_factura df ;
    LEFT JOIN tproductos p ON ALLTRIM(df.cid_produc) == ALLTRIM(p.cid_produc) ;
    WHERE ALLTRIM(df.cid_factu) == lcDocId ;
    INTO CURSOR curDetallesCxC
    
    SELECT curDetallesCxC
    SCAN
        IF !llFirstDetalle
            lcJsonDetalles = lcJsonDetalles + ","
        ENDIF
        LOCAL lcSku, lcDesc, lnCant, lnPrec, lnTot
        lcSku  = STRTRAN(ALLTRIM(curDetallesCxC.cid_produc), '"', '\"')
        lcDesc = STRTRAN(ALLTRIM(NVL(curDetallesCxC.cdescripci, "")), '"', '\"')
        lnCant = curDetallesCxC.ncantidad
        lnPrec = curDetallesCxC.nprecio
        lnTot  = curDetallesCxC.nmonto
        
        lcJsonDetalles = lcJsonDetalles + ;
            '{"sku":"' + lcSku + '",' + ;
            '"descripcion":"' + lcDesc + '",' + ;
            '"cantidad":' + TRANSFORM(lnCant) + ',' + ;
            '"precio":' + TRANSFORM(lnPrec) + ',' + ;
            '"total":' + TRANSFORM(lnTot) + '}'
        
        llFirstDetalle = .F.
    ENDSCAN
    lcJsonDetalles = lcJsonDetalles + "]"
    
    IF USED("curDetallesCxC")
        USE IN curDetallesCxC
    ENDIF

    lcInfoCxc = lcJsonDetalles
    
    SELECT curCxC_Subida

    * Validación Upsert
    LOCAL lcSqlCheck, lnRetCheck
    lcSqlCheck = "SELECT CODIGO FROM conex_sincro_cxc " + ;
                 "WHERE CODIGO = ?lcCodigo " + ;
                 "AND NUMERO = ?lcNumero " + ;
                 "AND TIPO = ?lcTipo LIMIT 1"
    
    lnRetCheck = SQLEXEC(tnH, lcSqlCheck, "curCheckExiste")
    
    IF lnRetCheck < 0
        LOCAL ARRAY laErrCheck[1]
        AERROR(laErrCheck)
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + " | ERROR CHECK CxC: " + TRANSFORM(laErrCheck[2]) + CHR(13)
        ENDIF
        LOOP
    ENDIF

    LOCAL lcSqlExecute, lnResExecute
    
    IF RECCOUNT("curCheckExiste") = 0
        * INSERT
        lcSqlExecute = "INSERT INTO conex_sincro_cxc (" + ;
                       "CODIGO, NUMERO, TIPO, FECHA, FECHAVEN, SALDO, " + ;
                       "VEN_CODIGO, TASA, TASACOP, COMENTARIO, ID_ENTERPRISE, INFOCXC, FACT_AFECT) " + ;
                       "VALUES (" + ;
                       "?lcCodigo, ?lcNumero, ?lcTipo, ?lcFecha, ?lcFechaVen, ?lnSaldo, " + ;
                       "?lcVenCodigo, ?lnTasa, 0.00, ?lcComentario, '3', ?lcInfoCxc, ?lcFactAfect)"
    ELSE
        * UPDATE quirúrgico (saldo, infocxc, fact_afect, fechas y tasa)
        lcSqlExecute = "UPDATE conex_sincro_cxc SET " + ;
                       "SALDO = ?lnSaldo, " + ;
                       "INFOCXC = ?lcInfoCxc, " + ;
                       "FECHA = ?lcFecha, " + ;
                       "FECHAVEN = ?lcFechaVen, " + ;
                       "TASA = ?lnTasa, " + ;
                       "FACT_AFECT = ?lcFactAfect " + ;
                       "WHERE CODIGO = ?lcCodigo AND NUMERO = ?lcNumero AND TIPO = ?lcTipo"
    ENDIF
    
    lnResExecute = SQLEXEC(tnH, lcSqlExecute)
    
    IF lnResExecute < 0
        LOCAL ARRAY laError[1]
        AERROR(laError)
        IF TYPE("PCESTADOENVIA") = "C"
            PCESTADOENVIA = PCESTADOENVIA + " | ERROR SQL NUBE (CxC): " + TRANSFORM(laError[2]) + CHR(13)
        ENDIF
    ELSE
        * Auditoria local
        IF TYPE("contaenviar") = "N"
            contaenviar = contaenviar + 1
        ENDIF
    ENDIF
    
    IF USED("curCheckExiste")
        USE IN curCheckExiste
    ENDIF
    
ENDSCAN

IF USED("curCxC_Subida")
    USE IN curCxC_Subida
ENDIF

RETURN .T.

* ---------------------------------------------------------
FUNCTION TraducirTipoDoc(tcTipoLocal)
    LOCAL lcTipo
    lcTipo = ALLTRIM(tcTipoLocal)
    IF lcTipo == "1" OR lcTipo == "01"
        RETURN "FAC"
    ENDIF
    
    DO CASE
        CASE lcTipo == "2" OR lcTipo == "02"
            RETURN "NEN"
        CASE lcTipo == "3" OR lcTipo == "03"
            RETURN "DEBV"
        CASE lcTipo == "4" OR lcTipo == "04"
            RETURN "CREV"
        CASE lcTipo == "5" OR lcTipo == "05"
            RETURN "ANT"
        OTHERWISE
            RETURN lcTipo
    ENDCASE
ENDFUNC

* ---------------------------------------------------------
FUNCTION FechaISO(tdFecha)
    IF EMPTY(tdFecha) OR ISNULL(tdFecha)
        RETURN .NULL.
    ENDIF
    LOCAL lcAnio, lcMes, lcDia
    lcAnio = ALLTRIM(STR(YEAR(tdFecha), 4))
    lcMes  = PADL(ALLTRIM(STR(MONTH(tdFecha))), 2, "0")
    lcDia  = PADL(ALLTRIM(STR(DAY(tdFecha))), 2, "0")
    RETURN lcAnio + "-" + lcMes + "-" + lcDia
ENDFUNC
