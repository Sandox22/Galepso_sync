* pedidos.prg
* Módulo de bajada transaccional para pedidos desde MariaDB a VFP
* Patrón C: Bajada Transaccional ACID

LPARAMETERS tnH

IF TYPE("tnH") <> "N" OR tnH <= 0
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: Handle ODBC invalido." + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

LOCAL lcDirData, lnRet, lcSQL, laErr[1], lnCount
lnCount = 0

* Resolucion de ruta de datos
IF TYPE("dirdata") = "C" AND !EMPTY(dirdata)
    lcDirData = dirdata
ELSE
    IF TYPE("PCUNIDAD") = "C" AND TYPE("pcSistema") = "C" AND TYPE("pcEmpresa") = "C"
        lcDirData = ALLTRIM(PCUNIDAD) + "\" + pcSistema + "\data\" + pcEmpresa + "\"
    ELSE
        lcDirData = "X:\Galepso\Data\Emp6\"   && Fallback hardcoded
    ENDIF
ENDIF

* Saneamiento preventivo de transacciones huerfanas
DO WHILE TXNLEVEL() > 0
    ROLLBACK
ENDDO

SET MULTILOCKS ON

* Apertura defensiva de tcontroles
IF !USED("tcontroles")
    IF FILE(lcDirData + "tcontroles.dbf")
        USE (lcDirData + "tcontroles.dbf") SHARED IN 0 ALIAS tcontroles
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tcontroles.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tpedidos
IF !USED("tpedidos")
    IF FILE(lcDirData + "tpedidos.dbf")
        USE (lcDirData + "tpedidos.dbf") SHARED IN 0 ALIAS tpedidos
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tpedidos.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tdetalles_pedido
IF !USED("tdetalles_pedido")
    IF FILE(lcDirData + "tdetalles_pedido.dbf")
        USE (lcDirData + "tdetalles_pedido.dbf") SHARED IN 0 ALIAS tdetalles_pedido
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tdetalles_pedido.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tclientes
IF !USED("tclientes")
    IF FILE(lcDirData + "tclientes.dbf")
        USE (lcDirData + "tclientes.dbf") SHARED IN 0 ALIAS tclientes
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tclientes.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

* Apertura defensiva de tvendedores
IF !USED("tvendedores")
    IF FILE(lcDirData + "tvendedores.dbf")
        USE (lcDirData + "tvendedores.dbf") SHARED IN 0 ALIAS tvendedores
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se encontro tvendedores.dbf" + CHR(13)
        ENDIF
        RETURN .F.
    ENDIF
ENDIF

CURSORSETPROP("Buffering", 5, "tpedidos")
CURSORSETPROP("Buffering", 5, "tdetalles_pedido")

* 1. Extraccion desde la Nube (MariaDB) - Cabeceras
LOCAL lcLogMsg
lcLogMsg = DTOC(DATE()) + " " + TIME() + " - [Radar] Buscando pedidos pendientes..." + CHR(13) + CHR(10)
STRTOFILE(lcLogMsg, lcDirData + "sync_log.txt", 1)

lcSQL = "SELECT * FROM conex_documentos WHERE CNX_CHECK = 0 AND CNX_DCL_TDT_CODIGO = 'PED'"
lnRet = SQLEXEC(tnH, lcSQL, "cur_conex_doc")
IF lnRet < 0
    LOCAL ARRAY laErr[1]
    AERROR(laErr)
    LOCAL lcErrSql
    lcErrSql = DTOC(DATE()) + " " + TIME() + " - [Radar] ERROR SQL leyendo pedidos: " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13) + CHR(10)
    STRTOFILE(lcErrSql, lcDirData + "error_sync.txt", 1)
    
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR MariaDB (Cabeceras): " + ALLTRIM(TRANSFORM(laErr[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
    RETURN .F.
ENDIF

lcLogMsg = DTOC(DATE()) + " " + TIME() + " - [Radar] Pedidos pendientes detectados: " + TRANSFORM(RECCOUNT("cur_conex_doc")) + CHR(13) + CHR(10)
STRTOFILE(lcLogMsg, lcDirData + "sync_log.txt", 1)

SELECT cur_conex_doc
IF RECCOUNT() = 0
    USE IN cur_conex_doc
    RETURN 0
ENDIF

* Extraccion de detalles de la nube
lcSQL = "SELECT d.* FROM conex_movimientos d INNER JOIN conex_documentos c ON d.CNX_MCL_DCL_NUMERO = c.CNX_DCL_NUMERO WHERE c.CNX_CHECK = 0 AND c.CNX_DCL_TDT_CODIGO = 'PED'"
lnRet = SQLEXEC(tnH, lcSQL, "cur_conex_mov")
IF lnRet < 0
    AERROR(laErr)
    IF TYPE("PCESTADORECIBE") = "C"
        PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR MariaDB (Detalles): " + ALLTRIM(TRANSFORM(laErr[2])) + " " + TTOC(DATETIME()) + CHR(13)
    ENDIF
    USE IN cur_conex_doc
    RETURN .F.
ENDIF

SELECT cur_conex_doc
GO TOP

DO WHILE !EOF()
    LOCAL llError, lcNumeroNube, lcNewPedidoID, lnNextPedido, lcCidCliente, lcCidVende, lnMontoT
    llError = .F.
    
    lcNumeroNube = ALLTRIM(TRANSFORM(NVL(cur_conex_doc.CNX_DCL_NUMERO, "")))
    
    * Verificacion preventiva de duplicados (ya procesado pero fallo el acuse en MariaDB)
    SELECT tpedidos
    LOCATE FOR ALLTRIM(creferenci) == lcNumeroNube
    IF FOUND()
        * Existe, hacer el UPDATE en MariaDB para sacarlo de la cola y continuar
        LOCAL lcSqlUpdateDupe, lnRetDupe
        lcNewPedidoID = tpedidos.cid_pedido
        lcSqlUpdateDupe = "UPDATE conex_documentos SET CNX_CHECK = 1, CNX_PED_GALEXO = ?lcNewPedidoID WHERE CNX_DCL_NUMERO = ?lcNumeroNube"
        lnRetDupe = SQLEXEC(tnH, lcSqlUpdateDupe)
        IF lnRetDupe < 0
            AERROR(laErr)
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR Update MariaDB (Duplicado) " + lcNumeroNube + ": " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13)
            ENDIF
        ENDIF
        SELECT cur_conex_doc
        SKIP
        LOOP
    ENDIF
    
    * Variables de la cabecera
    LOCAL lcCloudCli, lcCloudVen
    lcCloudCli = ALLTRIM(TRANSFORM(NVL(cur_conex_doc.cnx_dcl_clt_codigo, "")))
    lcCloudVen = ALLTRIM(TRANSFORM(NVL(cur_conex_doc.cnx_dcl_ven_codigo, "")))
    
    * Por defecto, el ID del cliente y vendedor asumen ser el de la nube
    lcCidCliente = lcCloudCli
    lcCidVende   = lcCloudVen
    lnMontoT     = NVL(cur_conex_doc.CNX_DCL_NETO, 0)
    
    * Validacion de Cliente Local
    SELECT tclientes
    * Buscamos por la clave primaria directa o por la marca de sincronizacion cruzada
    LOCATE FOR ALLTRIM(cid_clien) == ALLTRIM(lcCloudCli) OR ALLTRIM(cnit_cli) == ALLTRIM(lcCloudCli)
    IF FOUND()
        * Si existe, tomamos su ID local real para armar el pedido
        lcCidCliente = tclientes.cid_clien
    ELSE
        LOCAL lcErrCli
        lcErrCli = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] Omitido: El cliente nube " + lcCloudCli + " no existe localmente." + CHR(13) + CHR(10)
        STRTOFILE(lcErrCli, lcDirData + "error_sync.txt", 1)
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + lcErrCli
        ENDIF
        SELECT cur_conex_doc
        SKIP
        LOOP
    ENDIF
    
    * Validacion de Vendedor Local
    IF llError
        SKIP
        LOOP
    ENDIF

    SELECT tvendedores
    LOCATE FOR ALLTRIM(cid_vende) == ALLTRIM(lcCloudVen)
    IF FOUND()
        lcCidVende = tvendedores.cid_vende
    ELSE
        LOCAL lcErrVen
        lcErrVen = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] Omitido: El vendedor nube " + lcCloudVen + " no existe localmente." + CHR(13) + CHR(10)
        STRTOFILE(lcErrVen, lcDirData + "error_sync.txt", 1)
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + lcErrVen
        ENDIF
        SELECT cur_conex_doc
        SKIP
        LOOP
    ENDIF
    
    IF llError
        SKIP
        LOOP
    ENDIF
    
    * 2. Generacion del Correlativo Local (tcontroles.dbf)
    SELECT tcontroles
    IF RLOCK()
        lnNextPedido  = tcontroles.npedidos_c
        lcNewPedidoID = STR(lnNextPedido, 8)
    ELSE
        IF TYPE("PCESTADORECIBE") = "C"
            PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR: No se pudo bloquear tcontroles.dbf" + CHR(13)
        ENDIF
        llError = .T.
    ENDIF
    
    IF !llError
        BEGIN TRANSACTION
        
        TRY
            * 3. Mapeo Estricto de Cabecera (tpedidos)
            INSERT INTO tpedidos ;
                (cid_pedido, creferenci, cid_clien, cid_vende, nmonto_t, cid_status, cid_usuari, ctipo_pre) ;
                VALUES ;
                (lcNewPedidoID, lcNumeroNube, lcCidCliente, lcCidVende, lnMontoT, "  1", "SYNC", " 1")
            
            * 4. Mapeo Estricto de Renglones (tdetalles_pedido)
            SELECT cur_conex_mov
            SET FILTER TO ALLTRIM(TRANSFORM(CNX_MCL_DCL_NUMERO)) == lcNumeroNube
            GO TOP
            
            DO WHILE !EOF()
                LOCAL lcProducto, lnCantidad, lnPrecio, lnMonto
                lcProducto = ALLTRIM(TRANSFORM(NVL(cur_conex_mov.CNX_MCL_UPP_PDT_CODIGO, "")))
                lnCantidad = NVL(cur_conex_mov.CNX_MCL_CANTIDAD, 0)
                lnPrecio   = NVL(cur_conex_mov.CNX_MCL_BASE, 0)
                lnMonto    = lnCantidad * lnPrecio
                
                INSERT INTO tdetalles_pedido ;
                    (cid_pedido, cid_produc, ncantidad, nprecio, nmonto, nentregado) ;
                    VALUES ;
                    (lcNewPedidoID, lcProducto, lnCantidad, lnPrecio, lnMonto, 0)
                
                SELECT cur_conex_mov
                SKIP
            ENDDO
            SET FILTER TO
            
            * Escritura en disco (Flush)
            IF !TABLEUPDATE(1, .T., "tpedidos") OR !TABLEUPDATE(1, .T., "tdetalles_pedido")
                llError = .T.
                LOCAL ARRAY laErrTable[1]
                AERROR(laErrTable)
                LOCAL lcErrTbl
                lcErrTbl = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] ERROR TABLEUPDATE nativo: " + ALLTRIM(TRANSFORM(laErrTable[2])) + CHR(13) + CHR(10)
                STRTOFILE(lcErrTbl, lcDirData + "error_sync.txt", 1)
                
                IF TYPE("PCESTADORECIBE") = "C"
                    PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR TABLEUPDATE: " + ALLTRIM(TRANSFORM(laErrTable[2])) + CHR(13)
                ENDIF
            ENDIF
            
        CATCH TO oErr
            llError = .T.
            LOCAL lcErrCatch
            lcErrCatch = DTOC(DATE()) + " " + TIME() + " - [Pedido " + lcNumeroNube + "] CATCH ERROR transaccion: " + oErr.Message + " (Lin: " + TRANSFORM(oErr.LineNo) + ")" + CHR(13) + CHR(10)
            STRTOFILE(lcErrCatch, lcDirData + "error_sync.txt", 1)
            
            IF TYPE("PCESTADORECIBE") = "C"
                PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] CATCH ERROR: " + oErr.Message + CHR(13)
            ENDIF
        ENDTRY
        
        IF llError
            ROLLBACK
            SELECT tcontroles
            UNLOCK
            
            * Limpieza mandatoria de buffers sucios para evitar bloqueos iterativos
            IF USED("tpedidos")
                TABLEREVERT(.T., "tpedidos")
            ENDIF
            IF USED("tdetalles_pedido")
                TABLEREVERT(.T., "tdetalles_pedido")
            ENDIF
        ELSE
            END TRANSACTION
            FLUSH FORCE
            
            * 5. Acuse de Recibo y Concurrencia (Nube y Local)
            LOCAL lcSqlUpdate, lnRetUpdate
            lcSqlUpdate = "UPDATE conex_documentos SET CNX_CHECK = 1, CNX_PED_GALEXO = ?lcNewPedidoID WHERE CNX_DCL_NUMERO = ?lcNumeroNube"
            lnRetUpdate = SQLEXEC(tnH, lcSqlUpdate)
            
            IF lnRetUpdate < 0
                AERROR(laErr)
                IF TYPE("PCESTADORECIBE") = "C"
                    PCESTADORECIBE = PCESTADORECIBE + "[Pedidos] ERROR Update MariaDB " + lcNumeroNube + ": " + ALLTRIM(TRANSFORM(laErr[2])) + CHR(13)
                ENDIF
            ENDIF
            
            * Consolidar incremento en tcontroles y liberar
            SELECT tcontroles
            REPLACE npedidos_c WITH (lnNextPedido + 1)
            UNLOCK
            
            * Estadisticas globales
            lnCount = lnCount + 1
            IF TYPE("contarecibe") = "N"
                contarecibe = contarecibe + 1
            ENDIF
        ENDIF
    ENDIF
    
    SELECT cur_conex_doc
    SKIP
ENDDO

* Limpieza de cursores temporales
IF USED("cur_conex_doc")
    USE IN cur_conex_doc
ENDIF
IF USED("cur_conex_mov")
    USE IN cur_conex_mov
ENDIF

RETURN lnCount