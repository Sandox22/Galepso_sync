***
*** ReFox MMII (Win) #UK813760  OSCAR VALENTE  LINCKER S.R.L. [VFP60]
***
Set Safety Off
Set Exclusive Off
Set Exact On
Clear
Set Exclusive Off
Set Deleted On
Set Debugout To c:\resultado.txt
Set Date To Japan
Close Databases All
_Calcvalue=6023
Local dirdata
dirdata = ALLTRIM("X:") + "\" + pcSistema + "\data\" + pcEmpresa + "\"
Use Shared (dirdata +  ;
	"tclientes.dbf") In 0
Use Shared (dirdata +  ;
	"tfacturas.dbf") In 0
	
Use Shared (dirdata +  ;
	"tdetalles_factura.dbf") In 0	
Use Shared (dirdata +  ;
	"tdevoluciones_venta.dbf") In 0	
Use Shared (dirdata +  ;
	"tdetalles_devolucion_venta.dbf") In 0	
Use Shared (dirdata +  ;
	"tproductos.dbf") In 0
Use Shared (dirdata +  ;
	"tproductos_precio.dbf") In  ;
	0
Use Shared (dirdata +  ;
	"tdocumentos_cxc.dbf") In 0
Use Shared (dirdata +  ;
	"ttipos_documentocxc.dbf") In  ;
	0
Use Shared (dirdata +  ;
	"tvendedores.dbf") In  ;
	0
*!*	USE SHARED (dirdata +  ;
*!*	    "tfinanciamientos.dbf") IN  ;
*!*	    0
*!*	USE SHARED (dirdata +  ;
*!*	    "tdetalles_finca.dbf") IN  ;
*!*	    0

Local lBandera As Boolean
lBanderas=.F.

**PUBLIC lcStringConexion
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=148.66.136.54;Database=liderplus_elite;User=liderplus; Password=*netwire-0207;Option=3"


SQLSetprop(0, "DispLogin", 3)
lnhandle = Sqlstringconnect(lcStringConexion)
If lnhandle > 0
	**-- Sincronizacion incremental via Helper Dinámico --**
	* Carga sync_upsert.prg (ruta dinámica vía SYS(16))
	SET PROCEDURE TO (ADDBS(JUSTPATH(SYS(16))) + "sync_upsert.prg") ADDITIVE

	LOCAL tcMap, lnResult
	tcMap = "cid_clien|CNX_CLT_CODIGO|C, "      + ;
	        "cnombre_cl|CNX_CLT_NOMBRE|C, "      + ;
	        "crif_cli|CNX_CLT_RIF|C, "           + ;
	        "cdir_cli1|CNX_CLT_DIRECCION1|C, "   + ;
	        "ctele_cli|CNX_CLT_TELEFONO1|C, "    + ;
	        "cid_vende|CNX_CLT_VEN_CODIGO|C, "   + ;
	        "cid_estadc|CNX_CLT_EDO_CODIGO|N, "  + ;
	        "cid_ciudac|CNX_CLT_MPO_CODIGO|N"

	lnResult = SyncUpsert(lnhandle, "tclientes", "conex_clientes", tcMap)

	IF lnResult > 0
	    contaenviar = contaenviar + lnResult
	ELSE
	    IF lnResult < 0
	        PCESTADOENVIA = PCESTADOENVIA + Chr(13) + "Error SyncUpsert Cliente " + Ttoc(Datetime())
	    ENDIF
	ENDIF

	RETURN

	Select tdocumentos_cxc
	SQLExec(lnhandle,  ;
		"delete from tdocumentos_cxc",  ;
		"ttdocumentos_cxc")
	SQLExec(lnhandle,  ;
		"select * from tdocumentos_cxc",  ;
		"ttdocumentos_cxc")
	CursorSetProp("Buffering", 5,  ;
		"ttdocumentos_cxc")
	CursorSetProp("Tables",  ;
		"bdfelcas.dbo.tdocumentos_cxc",  ;
		"ttdocumentos_cxc")
	CursorSetProp("KeyFieldList",  ;
		"cid_doccxc")
	CursorSetProp("UpdateNameList",  ;
		"cid_doccxc liderplus.dbo.tdocumentos_cxc.cid_doccxc" ;
		)
	CursorSetProp("UpdatableFieldList",  ;
		"cid_doccxc")
	CursorSetProp("SendUpdates",  ;
		.T.)
	Select tdocumentos_cxc
	Set Filter To nsaldo <> 0 .And.  .Not. Deleted()
	Goto Top
	Do While  .Not. Eof()
		strsql = "INSERT INTO tdocumentos_cxc(CID_DOCCXC,CID_TIPO_D,CID_CLIEN,DFECHA,DFECHA_VEN,NSALDO,CID_VENDE,NIMPUESTO,NBASE,NTASA_IVA,CNROFISCAL,CSERIE,CCOMPROB_F,nmonto_D,nmonto_h,nfactor) "
		strsql = strsql + " values('" + cid_doccxc + "','" +cid_tipo_d + "','" + cid_clien + "','" + fechaguion(dfecha) + "','" + fechaguion(dfecha_ven) +  ;
			"'," + Iif(nfactor<>0,Str(nsaldo/nfactor, 12,2),Str(nsaldo, 12,2)) + ",'" + cid_vende + "'," +  Str(nimpuesto, 10, 2) + "," + Str(nbase, 10,2) + "," + Str(ntasa_iva,10, 2) + ",'" +  ;
			cnrofiscal + "','" + cserie +"','" + ccomprob_f + "'," + Str(nmonto_d,12,2) +"," + Str(nmonto_h,12,2) +","+Str(nfactor,12,6)+")"
		Select tdocumentos_cxc

		RETORNO= SQLExec(lnhandle,strsql,"ttdocumentos_cxc")
		If RETORNO>0 &&La consulta se ejecut� sin problemas
			**PCESTADOENVIA = PCESTADOENVIA+"Documentos Insertados con exito"+TTOC(DATETIME())+CHR(13)
		Else
			=Aerror(NOMBREARREGLO)
			PCESTADOENVIA = PCESTADOENVIA+ Chr(13)+ "ERROR INSERTANDO Documentos "+Chr(13)+NOMBREARREGLO(2)+ Ttoc(Datetime())
			**MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		Endif
		Select tdocumentos_cxc
		Skip
	Enddo
	SQLExec(lnhandle,  ;
		"delete from ttipos_documentocxc",  ;
		"tttipos_documentocxc")
	SQLExec(lnhandle,  ;
		"select * from ttipos_documentocxc",  ;
		"tttipos_documentocxc")
	CursorSetProp("Buffering", 5,  ;
		"tttipos_documentocxc")
	CursorSetProp("Tables",  ;
		"liderplus.dbo.ttipos_documentocxc",  ;
		"tttipos_documentocxc")
	CursorSetProp("KeyFieldList",  ;
		"CID_TIPOD")
	CursorSetProp("UpdateNameList",  ;
		"CID_TIPOD liderplus.dbo.ttipos_documentocxc.CID_TIPOD" ;
		)
	CursorSetProp("UpdatableFieldList",  ;
		"CID_TIPOD")
	CursorSetProp("SendUpdates",  ;
		.T.)
	Select ttipos_documentocxc
	Set Filter To  .Not. Deleted()
	Goto Top
	Do While  .Not. Eof()
		strsql = "INSERT INTO ttipos_documentocxc(CID_TIPOD,CDESCRIPCI,LSUMA,CABREVIADO)"
		strsql = strsql +  ;
			" values('" +  ;
			ttipos_documentocxc.cid_tipod +  ;
			"','" +  ;
			ttipos_documentocxc.cdescripci +  ;
			"'," +  ;
			IIF(ttipos_documentocxc.lsuma,  ;
			'1', '0') +  ;
			",'" +  ;
			ttipos_documentocxc.cabreviado +  ;
			"')"

		RETORNO= SQLExec(lnhandle, strsql,"ttipos_documentocxc")
		If RETORNO>0 &&La consulta se ejecut� sin problemas
			***PCESTADOENVIA = PCESTADOENVIA+"Tipos de Doc Insertados con exito"+TTOC(DATETIME())+CHR(13)
		Else
			=Aerror(NOMBREARREGLO)
			PCESTADOENVIA = PCESTADOENVIA+ Chr(13)+ "ERROR INSERTANDO Tipos de Documento "+Chr(13)+NOMBREARREGLO(2)+ Ttoc(Datetime())
			**MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		Endif


		Select ttipos_documentocxc
		Skip
	Enddo


	**====================================
	SQLExec(lnhandle,  ;
		"delete from tvendedores",  ;
		"ttvendedores")
	SQLExec(lnhandle,  ;
		"select * from tvendedores",  ;
		"ttvendedores")
	CursorSetProp("Buffering", 5,  ;
		"ttvendedores")
	CursorSetProp("Tables",  ;
		"liderplus.dbo.tvendedores",  ;
		"ttvendedores")
	CursorSetProp("KeyFieldList",  ;
		"cid_vende")
	CursorSetProp("UpdateNameList",  ;
		"cid_vende liderplus.dbo.tvendedores.cid_vende" ;
		)
	CursorSetProp("UpdatableFieldList",  ;
		"cid_vende")
	CursorSetProp("SendUpdates",  ;
		.T.)

	Select tvendedores
	Set Filter To  .Not. Deleted() And lactivo=.T.
	Goto Top
	Do While  .Not. Eof()
		strsql = "INSERT INTO tvendedores(cid_vende,cnombrev)"
		strsql = strsql +  ;
			" values('" + Alltrim(tvendedores.cid_vende) + "','" + tvendedores.cnombrev + "')"

		RETORNO= SQLExec(lnhandle, strsql,"ttvendedores")
		If RETORNO>0 &&La consulta se ejecut� sin problemas
			**PCESTADOENVIA = PCESTADOENVIA+"Vendedores Insertados con exito"+TTOC(DATETIME())+CHR(13)
		Else
			=Aerror(NOMBREARREGLO)
			PCESTADOENVIA = PCESTADOENVIA+ Chr(13)+ "ERROR INSERTANDO Vendedores "+Chr(13)+NOMBREARREGLO(2)+ Ttoc(Datetime())
			**MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		Endif
		Select tvendedores
		Skip
	Enddo




		LOCAL lcSQLcommand
		lcSQLcommand=""
	
		LOCAL lBandera AS Boolean
		lBanderas=.f.
	
		LOCAL nTotalRegistros
		nTotalRegistros=0
		
		Select tfacturas
		Set Filter To .Not. Deleted() AND dfecha>=(DATE()-90) AND (cid_status='999' OR cid_status='  6')
		GO bottom
		nTotalRegistros=RECNO()		
		Goto Top
		Do While  .Not. Eof()
			IF !lBandera
				lcSQLcommand="INSERT INTO tfacturas (CID_FACTU, CTIPO_FAC, CID_CLIEN, CNOMBRE_CL, CRIF_CLI, CID_VENDE, DFECHA, CID_CAJA, DFECHA_VEN, CID_PEDIDO, CID_TIPO_P, MOBSERVACI, CID_STATUS,  NTASA_IVA, NMONTOTI, NBASE_IVA,  NMONTOTAL, NMONTOIVA) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<Alltrim(tfacturas.CID_FACTU)>>','<<Alltrim(tfacturas.CTIPO_FAC)>>','<<Alltrim(tfacturas.cid_clien)>>','<<Chrtran(Chrtran(Chrtran(Chrtran(Chrtran(Chrtran(tfacturas.cnombre_cl, "'", "''"),"(",""),")",""),",",""),".",""),"'","")>>','<<Alltrim(tfacturas.crif_cli)>>','<<Alltrim(tfacturas.cid_vende)>>','<<Dtoc(tfacturas.dfecha)>>','<<Alltrim(tfacturas.CID_CAJA)>>','<<Dtoc(tfacturas.dfecha_ven)>>','<<Alltrim(tfacturas.CID_PEDIDO)>>','<<Alltrim(tfacturas.cid_tipo_p)>>','<<Chrtran(tfacturas.MOBSERVACI, "'","''")>>','<<Alltrim(tfacturas.CID_STATUS)>>',<<Str(tfacturas.ntasa_iva, 5, 2)>>,<<Str(tfacturas.NMONTOTI, 18, 2)>>,<<Str(tfacturas.NBASE_IVA, 18, 2)>>,<<Str(tfacturas.NMONTOTAL, 18, 2)>>,<<Str(tfacturas.NMONTOIVA, 18, 2)>>)
			ENDTEXT	
		
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF
			
			Select tfacturas
			Skip
		ENDDO
*!*			CREATE CURSOR Temporal(cadena M)
*!*			SELECT Temporal
*!*			APPEND BLANK
*!*			replace cadena WITH lcSQLcommand
		**===============TRANSFIRIENDO LOS CONTROLES==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from tfacturas")		
		IF lcSQLcommand != ";"
			RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
			IF RETORNO>0
				PCESTADOENVIA = PCESTADOENVIA+"Facturas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
			ELSE
				=AERROR(NOMBREARREGLO)
				PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO Facturas"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
			ENDIF
		ELSE
			PCESTADOENVIA = PCESTADOENVIA+ "No se encontraron registros para Facturas "+TTOC(DATETIME())+CHR(13)
		ENDIF
		lcSQLcommand=""
		
		
		
		************************************************
		
		
		
		
		**===============TRANSFIRIENDO DETALLES DE FACTURAS==================
		
		SELECT tdetalles_factura.cid_factu,cid_produc,ncantidad,nprecio,nmonto,ndescuento,cid_docum,tdetalles_factura.mobservaci,cid_almace FROM tdetalles_factura INNER JOIN tfacturas ON tdetalles_factura.cid_factu=tfacturas.cid_factu WHERE tfacturas.dfecha>=(DATE()-90) AND ncantidad>0 and (cid_status='999' OR cid_status='  6') INTO CURSOR tttdetalles_factura readwrite
		
		
		
		**RUTINA PARA RESTAR DEVOLUCIONES A LAS FACTURAS
		SELECT tdevoluciones_venta
		SET ORDER TO ix_factura
		
		SELECT tdetalles_devolucion_venta
		SET ORDER TO IX_DETDEVV &&cid_dev_v+cid_produc 
		
		SELECT tttdetalles_factura
		GO top
		DO WHILE !EOF()
		
				SELECT tdevoluciones_venta
				GO top
				SEEK(tttdetalles_factura.cid_factu)
				IF FOUND()
					**?"encontrada"
					SELECT tdetalles_devolucion_venta
					GO top
					SEEK(tdevoluciones_venta.cid_dev_v+tttdetalles_factura.cid_produc)
					IF FOUND()
					**?"Restando "+STR(ncantidad)+" del producto "+cid_produc
						replace ncantidad WITH ncantidad-tdetalles_devolucion_venta.ncantidad IN tttdetalles_factura
					endif
				endif	
				
		SELECT tttdetalles_factura
		SKIP
		enddo
		**++++++++++++++++++++++++++++++++++++++++++++
		
		SELECT tttdetalles_factura
		GO top
		
		LOCAL lcSQLcommand
		lcSQLcommand=""
	
		LOCAL lBandera AS Boolean
		lBanderas=.f.
	
		LOCAL nTotalRegistros
		nTotalRegistros=0
		
		Select tttdetalles_factura
		Set Filter To .Not. Deleted() 
		GO bottom
		nTotalRegistros=RECNO()		
		Goto Top
		Do While  .Not. Eof()
			IF !lBandera
				lcSQLcommand="INSERT INTO tdetalles_factura (CID_FACTU, cid_produc,ncantidad,nprecio,nmonto,ndescuento,cid_docum,mobservaci,cid_almace) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<Alltrim(tttdetalles_factura.CID_FACTU)>>','<<Alltrim(tttdetalles_factura.cid_produc)>>',<<tttdetalles_factura.ncantidad>>,<<tttdetalles_factura.nprecio>>,<<tttdetalles_factura.nmonto>>,<<tttdetalles_factura.ndescuento>>,'<<tttdetalles_factura.cid_docum>>','<<Alltrim(tttdetalles_factura.mobservaci)>>','<<tttdetalles_factura.cid_almace>>')
			ENDTEXT	
		
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF
			
			Select tttdetalles_factura
			Skip
		ENDDO
*!*			CREATE CURSOR Temporal(cadena M)
*!*			SELECT Temporal
*!*			APPEND BLANK
*!*			replace cadena WITH lcSQLcommand
		**===============TRANSFIRIENDO LOS CONTROLES==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from tdetalles_factura")		
		IF lcSQLcommand != ";"
			RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
			IF RETORNO>0
				PCESTADOENVIA = PCESTADOENVIA+"Detalles Facturas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
			ELSE
				=AERROR(NOMBREARREGLO)
				PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO Detalles Facturas"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
			ENDIF
		ELSE
			PCESTADOENVIA = PCESTADOENVIA+ "No se encontraron registros para Detalles Facturas "+TTOC(DATETIME())+CHR(13)
		ENDIF
		lcSQLcommand=""
		**===============TRANSFIRIENDO LOS CONTROLES==================
		
		
		
		
		




	SQLDisconnect(lnhandle)
ELSE
Aerror(laerr)
 PCESTADOENVIA = "No se encontro conexion a internet enviando cxc " + TTOC(DATETIME()+ laerr(2))
	
Endif
Close Databases All
Endproc
*
Function fechaguion
	Lparameters fecha
	Local valor
	valor = Alltrim(Str(Year(fecha))) +  ;
		"-" +  ;
		ALLTRIM(Str(Month(fecha))) +  ;
		"-" +  ;
		ALLTRIM(Str(Day(fecha)))
	Return valor
Endfunc
*
***
*** ReFox - retrace your steps ...
***
