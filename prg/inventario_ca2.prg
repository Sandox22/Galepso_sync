***
*** ReFox MMII (Win) #UK813760  OSCAR VALENTE  LINCKER S.R.L. [VFP60]
***

**On Error Do errhand WITH Sys(0), Error(), Message(), Message(1), ;
	PROGRAM(), Lineno(1), Dbf(), Date(), Time()
* End of error trap setup.

	Set Safety Off
	Set Exclusive Off
	Set Exact On
	Clear
	Set Exclusive Off
	Set Deleted On
	Set Debugout To c:\resultado.txt
	Set Date To Japan
	Close Databases All
	Local dirdata
	dirdata = "C:\galepso\data\emp2\"
	Use Shared (dirdata +  ;
		"tclientes.dbf") In 0
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
	Use Shared (dirdata + "tlineas.dbf") In 0
	Use Shared (dirdata + "tsublineas.dbf") In 0
	Use Shared (dirdata + "tproductos_almacen.dbf") In 0
	Use Shared (dirdata + "tcolores.dbf") In 0
	Use Shared (dirdata + "tcontroles.dbf") In 0
	Use Shared (dirdata + "ttipos_precio.dbf") In 0

PCESTADOENVIA = "Transferencia en proceso" + TTOC(DATETIME())
	*****************************
	Set Database To C:\galepso\Data\emp2\bdemp.Dbc
	
	LOCAL lcSQLcommand
	lcSQLcommand=""
	
	LOCAL lBandera AS Boolean
	lBanderas=.f.
	
	LOCAL nTotalRegistros
	nTotalRegistros=0

	Local lcstringcnxlocal As String
	**lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdfelcas;User=felcas; Password=felc@s123;Option=3"
	lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdferreperiquitos;User=ferreperiquitos; Password=101084pedro;Option=3"
	SQLSetprop(0, "DispLogin", 3)
	lnhandle = Sqlstringconnect(lcstringcnxlocal)
	If lnhandle > 0
		
		Select tproductos
		Set Filter To lactivo = .T. .And.  .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
		IF !lBandera
		 lcSQLcommand="INSERT INTO tproductos(cid_produc,cdescripci,cdescrialt,cempaque,creferenci,cclasi1,cclasi2,cclasi3,cclasi4,ngarantia,gfoto,cid_alter,nexisten,lactivo) VALUES"
		 lBandera=.t.
		endif
		
		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<ALLTRIM(tproductos.cid_produc)>>','<<ALLTRIM(CHRTRAN(tproductos.cdescripci,"'",""))>>','<<ALLTRIM(CHRTRAN(tproductos.cdescrialt,"'",""))>>','<<ALLTRIM(tproductos.cempaque)>>','<<ALLTRIM(tproductos.creferenci)>>','<<ALLTRIM(tproductos.cclasi1)>>','<<ALLTRIM(tproductos.cclasi2)>>','<<ALLTRIM(tproductos.cclasi3)>>','<<ALLTRIM(tproductos.cclasi4)>>','<<STR(tproductos.ngarantia,3,0)>>','<<ALLTRIM(tproductos.gfoto)>>','<<ALLTRIM(tproductos.cid_alter)>>','<<STR(tproductos.nexisten,8, 2)>>','<<IIF(tproductos.lactivo,'V', 'F')>>')
		ENDTEXT
		
		
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSQLcommand=lcSQLcommand+","
		ENDIF	
			
			Select tproductos
			Skip
		ENDDO
		
		**===============TRANSFIRIENDO PRODUCTOS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		nTotalRegistros=0
		
		
		SQLEXEC(lnhandle,"DELETE FROM tproductos")	
		SQLEXEC(lnhandle,lcSQLcommand)
		CREATE CURSOR Temporal(cadena M)
		SELECT Temporal
		APPEND BLANK
		replace cadena WITH lcSQLcommand
		
		
		
		lcSQLcommand=""
		**===============TRANSFIRIENDO PRODUCTOS==================
		

		Set Database To C:\galepso\Data\emp2\bdemp.Dbc


		Select tproductos_precio
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
		IF !lBandera
		 lcSQLcommand="INSERT INTO tproductos_precio(cid_produc,ctipo_pre,nprecio,ctipo_ref,nfactor) VALUES"
		 lBandera=.t.
		ENDIF
		
		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    ('<<ALLTRIM(tproductos_precio.cid_produc)>>','<<tproductos_precio.ctipo_pre>>','<<STR(tproductos_precio.nprecio,8, 2)>>','<<tproductos_precio.ctipo_ref>>','<<STR(tproductos_precio.nfactor,8, 2)>>')
		ENDTEXT
		
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSQLcommand=lcSQLcommand+","
		ENDIF
			
			Select tproductos_precio
			Skip
		ENDDO
		
		**===============TRANSFIRIENDO PRECIOS DE PRODUCTOS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"DELETE FROM tproductos_precio")		
		SQLEXEC(lnhandle,lcSQLcommand)
		lcSQLcommand=""
		nTotalRegistros=0
		**===============TRANSFIRIENDO PRECIOS DE PRODUCTOS==================


		**********************************************
		Set Database To C:\galepso\Data\emp2\bdemp.Dbc
		*SET DEFAULT TO z:\confia\data\emp1\

		
		Select tproductos_almacen
		Set Filter To .Not. Deleted() And Alltrim(cid_almace)="02"
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			
			IF !lBandera
				lcSQLcommand="INSERT INTO tproductos_almacen(CID_PRODUC,CID_ALMACE,NEXISTEN,ncosto_inv,ncosto_ulc) VALUES"
				lBandera=.t.
			ENDIF
		
				
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<ALLTRIM(tproductos_almacen.cid_produc)>>','<<'1'>>','<<Str(tproductos_almacen.nexisten,5,2)>>','<<Str(tproductos_almacen.ncosto_inv,5,2)>>','<<Str(tproductos_almacen.ncosto_ulc,5,2)>>')
			ENDTEXT	
					
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF
			
			Select tproductos_almacen
			Skip
		ENDDO
		
			
		**===============TRANSFIRIENDO EXISTENCIAS POR ALMACEN==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.
		SQLEXEC(lnhandle,"Delete from tproductos_almacen where TRIM(tproductos_almacen.cid_almace)='1'")			
		SQLEXEC(lnhandle,lcSQLcommand)
		lcSQLcommand=""
		nTotalRegistros=0
		**===============TRANSFIRIENDO EXISTENCIAS POR ALMACEN==================


		*!*	     **************************************
		Set Database To C:\galepso\Data\emp2\bdemp.Dbc

		
		Select tlineas
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			IF !lBandera
				lcSQLcommand="INSERT INTO tlineas(CID_linea,cdescripci) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<ALLTRIM(tlineas.cid_linea)>>','<<tlineas.cdescripci>>')
			ENDTEXT	
			
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF		
		
			Select tlineas
			Skip
		ENDDO
		
		
				
		**===============TRANSFIRIENDO LAS LINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from tlineas")	
		SQLEXEC(lnhandle,lcSQLcommand)
		nTotalRegistros=0
		
		
		*CREATE CURSOR Temporal(cadena M)
		**SELECT Temporal
		**APPEND BLANK
		**replace cadena WITH lcSQLcommand
		
		lcSQLcommand=""
		**===============TRANSFIRIENDO LAS LINEAS==================


		*!*	    *================================
		
		Select tcolores
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
			IF !lBandera
				lcSQLcommand="INSERT INTO tcolores(CID_color,cdescripci) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<ALLTRIM(tcolores.cid_color)>>','<<tcolores.cdescripci>>')
			ENDTEXT	
		
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF	
			
			Select tcolores
			Skip
		ENDDO
		
		**===============TRANSFIRIENDO LAS SUBLINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from tcolores")		
		SQLEXEC(lnhandle,lcSQLcommand)
		lcSQLcommand=""
		nTotalRegistros=0
		**===============TRANSFIRIENDO LAS SUBLINEAS==================

		*!*
		*!*		 *================================
		
		Select tcontroles
		Set Filter To .Not. Deleted()		
		Goto Top
		Do While  .Not. Eof()
			IF !lBandera
				lcSQLcommand="INSERT INTO tcontroles(niva) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<STR(tcontroles.niva,2,2) >>')
			ENDTEXT	
		
			
			Select tcontroles
			Skip
		ENDDO
		
		**===============TRANSFIRIENDO LOS CONTROLES==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from tcontroles")		
		SQLEXEC(lnhandle,lcSQLcommand)
		lcSQLcommand=""
		**===============TRANSFIRIENDO LOS CONTROLES==================

		
		
		************************
		*** TIPOS DE PRECIOS*****
		***********************
		*!*		 *================================
		
		
		Select ttipos_precio
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
			IF !lBandera
				lcSQLcommand="INSERT INTO ttipos_precio(cid_tipo_p,cdescripci,nfactor,ctipo_ref,linclu_iva,ndecimal,lmuestra,ldecena,lcentena,lunida_mil) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    ('<<Alltrim(ttipos_precio.cid_tipo_p)>>','<<Alltrim(ttipos_precio.cdescripci)>>','<<Str(ttipos_precio.nfactor,4,4)>>','<<ttipos_precio.ctipo_ref>>','<<Iif(ttipos_precio.linclu_iva=.T.,"1","0")>>','<<Str(ttipos_precio.ndecimal)>>','<<Iif(ttipos_precio.lmuestra=.T.,"1","0")>>','<<Iif(ttipos_precio.ldecena=.T.,"1","0")>>','<<Iif(ttipos_precio.lcentena=.T.,"1","0")>>','<<Iif(ttipos_precio.lunida_mil=.T.,"1","0")>>')
			ENDTEXT	
		
		
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF	
			
			Select ttipos_precio
			Skip
		ENDDO
		
		
		
		**===============TRANSFIRIENDO LOS CONTROLES==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from ttipos_precio")		
		SQLEXEC(lnhandle,lcSQLcommand)
		SQLEXEC(lnhandle, "UPDATE tsincronizacion set dact_existen=CONVERT_TZ(NOW(),'-4:30','-8:00') where cid_empre='1'")

		lcSQLcommand=""
		nTotalRegistros=0
		**===============TRANSFIRIENDO LOS CONTROLES==================

		CLOSE DATABASES all

		SQLDisconnect(lnhandle)
		PCESTADOENVIA = "Transferencia de Inventarios realizada en forma Exitosa " + TTOC(DATETIME())
	Else
		PCESTADOENVIA = "No se encontro conexion a internet " + TTOC(DATETIME())		
	ENDIF

	
	CLOSE DATABASES ALL
Endproc
*
Function FECHAGUION
	Lparameters fecha
	Local valor
	valor = Alltrim(Str(Year(fecha))) +  ;
		"-" +  ;
		ALLTRIM(Str(Month(fecha))) +  ;
		"-" +  ;
		ALLTRIM(Str(Day(fecha)))
	Return valor
Endfunc

