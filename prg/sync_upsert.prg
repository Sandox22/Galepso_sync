* =============================================================
* sync_upsert.prg
* Motor dinámico de sincronización incremental (Upsert)
* Genera y ejecuta INSERT ... ON DUPLICATE KEY UPDATE
* para cualquier tabla del sistema Galepso.
*
* FIRMA:
*   SyncUpsert(tnHandle, tcLocalAlias, tcRemoteTable, tcFieldMap)
*
* PARÁMETROS:
*   tnHandle      N  Handle ODBC activo (de SQLSTRINGCONNECT)
*   tcLocalAlias  C  Alias local del cursor/DBF a leer (ej. "tclientes")
*   tcRemoteTable C  Tabla destino en MariaDB (ej. "conex_clientes")
*   tcFieldMap    C  Mapa delimitado por comas con formato:
*                    "campo_local|CAMPO_REMOTO|Tipo"
*                    Tipos soportados: C (String), N (Numérico/INT)
*
* RETORNO:
*   N  > 0  : Número de registros sincronizados exitosamente
*   N  = 0  : Sin registros activos o error de parámetros
*   N  < 0  : Código de error ODBC del último fallo
*
* EJEMPLO DE USO:
*   tcMap = "cid_clien|CNX_CLT_CODIGO|C, cnombre_cl|CNX_CLT_NOMBRE|C, " + ;
*           "crif_cli|CNX_CLT_RIF|C, cid_estadc|CNX_CLT_EDO_CODIGO|N"
*   lnSincronizados = SyncUpsert(lnHandle, "tclientes", "conex_clientes", tcMap)
* =============================================================

FUNCTION SyncUpsert
    LPARAMETERS tnHandle, tcLocalAlias, tcRemoteTable, tcFieldMap

    * ----------------------------------------------------------
    * 0. Validación de parámetros de entrada
    * ----------------------------------------------------------
    IF tnHandle <= 0 OR EMPTY(tcLocalAlias) OR EMPTY(tcRemoteTable) OR EMPTY(tcFieldMap)
        RETURN 0
    ENDIF

    IF !USED(tcLocalAlias)
        RETURN 0
    ENDIF

    * ----------------------------------------------------------
    * 1. Parsear tcFieldMap en un array de mapeos
    *    Cada elemento: "campo_local|CAMPO_REMOTO|Tipo"
    * ----------------------------------------------------------
    LOCAL laMap(1), lnMapCount
    lnMapCount = ALINES(laMap, tcFieldMap, 1 + 4, ",")  && Trim automático de cada elemento

    IF lnMapCount = 0
        RETURN 0
    ENDIF

    * ----------------------------------------------------------
    * 2. Construir las 3 cláusulas SQL una sola vez (estructura fija)
    *    lcCols: columnas del INSERT INTO (...)
    *    lcUpd:  columnas del ON DUPLICATE KEY UPDATE ...
    *    Solo lcVals varía por registro → se reconstruye en el SCAN
    * ----------------------------------------------------------
    LOCAL lcCols, lcUpd, lcPK
    LOCAL laFields(lnMapCount, 3)  && [i,1]=campo_local [i,2]=CAMPO_REMOTO [i,3]=Tipo
    lcCols = ""
    lcUpd  = ""
    lcPK   = ""  && Primera columna = PK (no entra en UPDATE)

    LOCAL lnI, lcParts(1)
    FOR lnI = 1 TO lnMapCount
        * Separar cada elemento por "|"
        LOCAL lnParts
        lnParts = ALINES(lcParts, laMap(lnI), 1 + 4, "|")
        IF lnParts < 3
            LOOP  && Elemento malformado, ignorar
        ENDIF

        laFields(lnI, 1) = ALLTRIM(lcParts(1))  && campo_local
        laFields(lnI, 2) = ALLTRIM(lcParts(2))  && CAMPO_REMOTO
        laFields(lnI, 3) = UPPER(ALLTRIM(lcParts(3)))  && Tipo: C o N

        * Acumular columnas INSERT
        lcCols = lcCols + IIF(EMPTY(lcCols), "", ", ") + laFields(lnI, 2)

        * Primera columna = PK → no entra en ON DUPLICATE KEY UPDATE
        IF lnI > 1
            lcUpd = lcUpd + IIF(EMPTY(lcUpd), "", ", ") + ;
                    laFields(lnI, 2) + " = VALUES(" + laFields(lnI, 2) + ")"
        ELSE
            lcPK = laFields(lnI, 2)
        ENDIF
    ENDFOR

    * ----------------------------------------------------------
    * 3. Recorrer el alias local y ejecutar upsert por registro
    * ----------------------------------------------------------
    LOCAL lnOK, lnFail, lcSQL, lcVals, lcRawVal, lcSafeVal
    LOCAL laErr(1), lnRet
    lnOK   = 0
    lnFail = 0
    lcSQL  = ""

    SELECT (tcLocalAlias)
    SET FILTER TO .NOT. DELETED()
    GO TOP

    * --- INYECCIÓN DE TELEMETRÍA: RADAR INTERNO DEL MOTOR ---
    LOCAL lnFilteredCount
    COUNT TO lnFilteredCount
    GO TOP
    IF TYPE("PCESTADOENVIA") = "C"
        PCESTADOENVIA = PCESTADOENVIA + "[SyncUpsert] RADAR MOTOR: " + TRANSFORM(lnFilteredCount) + " registros activos (no eliminados) en " + tcLocalAlias + " para " + tcRemoteTable + CHR(13)
    ENDIF
    LOCAL lcEngineRadarMsg
    lcEngineRadarMsg = TTOC(DATETIME()) + " [SyncUpsert] RADAR MOTOR (" + tcRemoteTable + "): " + TRANSFORM(lnFilteredCount) + " registros listos para procesar." + CHR(13) + CHR(10)
    STRTOFILE(lcEngineRadarMsg, "C:\GalepsoSync\telemetria_syncupsert.log", 1)
    * --------------------------------------------------------

    SCAN
        lcVals = ""

        * --- 3a. Construir lcVals para el registro actual ---
        FOR lnI = 1 TO lnMapCount
            IF EMPTY(laFields(lnI, 1))
                LOOP
            ENDIF

            * Leer valor del campo dinámicamente
            lcRawVal = EVALUATE(tcLocalAlias + "." + laFields(lnI, 1))

            DO CASE
                CASE laFields(lnI, 3) = "C"
                    * String: ALLTRIM + escape de comillas simples + envolver en ''
                    lcSafeVal = "'" + STRTRAN(ALLTRIM(lcRawVal), "'", "''") + "'"

                CASE laFields(lnI, 3) = "N"
                    * Numérico: si el campo origen es C, aplicar VAL(); si es N, directo
                    IF VARTYPE(lcRawVal) = "C"
                        lcSafeVal = ALLTRIM(STR(VAL(lcRawVal)))
                    ELSE
                        lcSafeVal = ALLTRIM(STR(lcRawVal))
                    ENDIF
                    * Sanitizar exponente o formato no deseado de STR()
                    IF "E" $ lcSafeVal OR "." $ lcSafeVal
                        lcSafeVal = ALLTRIM(STR(INT(VAL(lcSafeVal))))
                    ENDIF

                CASE laFields(lnI, 3) = "B"
                    * Booleano VFP (L) → entero MySQL 0/1, sin comillas
                    LOCAL luValor
                    luValor = lcRawVal
                    lcSafeVal = IIF(luValor, "1", "0")

                OTHERWISE
                    lcSafeVal = "''"  && Tipo desconocido → string vacío seguro
            ENDCASE

            lcVals = lcVals + IIF(EMPTY(lcVals), "", ", ") + lcSafeVal
        ENDFOR

        * --- 3b. Ensamblar SQL completo ---
        lcSQL = "INSERT INTO " + tcRemoteTable + " (" + lcCols + ")" + ;
                " VALUES (" + lcVals + ")" + ;
                " ON DUPLICATE KEY UPDATE " + lcUpd + ";"

        * --- 3c. Ejecutar y contabilizar ---
        lnRet = SQLEXEC(tnHandle, lcSQL)
        IF lnRet < 0
            =AERROR(laErr)
            lnFail = lnFail + 1
            
            * --- INYECCIÓN DE TELEMETRÍA: RECHAZO MARIADB AGRESIVO ---
            LOCAL lcErrorLogMsg
            lcErrorLogMsg = TTOC(DATETIME()) + " [SyncUpsert] RECHAZO MARIADB en " + tcRemoteTable + CHR(13) + CHR(10) + ;
                            "  - SQL: " + lcSQL + CHR(13) + CHR(10) + ;
                            "  - ERROR NATIVO: " + ALLTRIM(TRANSFORM(laErr(1))) + " | " + ALLTRIM(TRANSFORM(laErr(2))) + CHR(13) + CHR(10) + ;
                            "--------------------------------------------------" + CHR(13) + CHR(10)
            STRTOFILE(lcErrorLogMsg, "C:\GalepsoSync\telemetria_syncupsert.log", 1)
            * ---------------------------------------------------------

            * Registrar en PCESTADOENVIA si está disponible en scope
            IF TYPE("PCESTADOENVIA") = "C"
                PCESTADOENVIA = PCESTADOENVIA + CHR(13) + ;
                    "[SyncUpsert] ERROR en " + tcRemoteTable + ;
                    " | Registro: " + lcVals + CHR(13) + ;
                    ALLTRIM(TRANSFORM(laErr(2))) + " " + TTOC(DATETIME())
            ENDIF
        ELSE
            lnOK = lnOK + 1
            IF TYPE("contaenviar") = "N"
                contaenviar = contaenviar + 1
            ENDIF
        ENDIF
    ENDSCAN

    SET FILTER TO  && Limpiar filtro del alias

    * ----------------------------------------------------------
    * 4. Retornar resultado
    *    > 0 : registros OK
    *    < 0 : negativo de fallos si hubo errores (sin OK)
    * ----------------------------------------------------------
    IF lnOK > 0
        RETURN lnOK
    ELSE
        RETURN -lnFail
    ENDIF

ENDFUNC
