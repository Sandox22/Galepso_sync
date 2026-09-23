*** 
*** ReFox MMII (Win) #UK813760  OSCAR VALENTE  LINCKER S.R.L. [VFP60]
***
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
LOCAL dirdata
dirdata = "z:\confia\data\emp1\"
USE SHARED (dirdata +  ;
    "tclientes.dbf") IN 0
USE SHARED (dirdata + "tproductos.dbf") IN 0
USE SHARED (dirdata +  ;
    "tproductos_precio.dbf") IN  ;
    0
USE SHARED (dirdata +  ;
    "tdocumentos_cxc.dbf") IN 0
USE SHARED (dirdata +  ;
    "ttipos_documentocxc.dbf") IN  ;
    0
USE SHARED (dirdata + "tlineas.dbf") IN 0
USE SHARED (dirdata + "tsublineas.dbf") IN 0
USE SHARED (dirdata + "tproductos_almacen.dbf") IN 0
USE SHARED (dirdata + "ttallas.dbf") IN 0
USE SHARED (dirdata + "tcolores.dbf") IN 0
USE SHARED (dirdata + "tcontroles.dbf") IN 0

SELECT tproductos_precio
SET ORDER TO ix_pro_pre


*****************************
SET DATABASE TO z:\confia\data\emp1\bdemp.dbc


	LOCAL lcSQLcommand,lcSQLcommand2
	lcSQLcommand=""
	lcSQLcommand2=""
	
	LOCAL lBandera AS Boolean
	lBandera=.f.
	
	LOCAL lBandera2 AS Boolean
	lBandera2=.f.
	
	LOCAL nTotalRegistros
	nTotalRegistros=0
	LOCAL nTotalRegistros2
	nTotalRegistros2=0


LOCAL lcProducto,lcDescrip
lcProducto=""
lcDescrip=""

LOCAL lnNroRegistro
lnNroRegistro=0


SELECT TOP 100 SUM(ncantidad) as Monto, tproductos.cid_produc,cdescripci;
   FROM tproductos INNER JOIN tdetalles_factura;
   ON tproductos.cid_produc=tdetalles_factura.cid_produc;
   GROUP BY  tproductos.cid_produc,cdescripci;
   HAVING SUM(ncantidad)>=146;
   WHERE lactivo = .T. AND nexisten>0;
   ORDER BY monto DESC;
   INTO CURSOR ttproductos
   

SELECT cclasi1,cclasi2,cclasi3,cclasi4,tlineas.cdescripci, tsublineas.cdescripci, ttallas.cdescripci,tcolores.cdescripci;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
where cid_produc in (SELECT cid_produc FROM ttproductos);
into CURSOR clasificaciones

SELECT clasificaciones
GO top



SELECT INT(VAL(cclasi1))+5000 as term_taxonomy_id,INT(VAL(cclasi1))+5000 as term_id,'product_cat' as taxonomy, 0 as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR term_taxonomy1

SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_id,'product_cat' as taxonomy, INT(VAL(cclasi1))+5000 as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR term_taxonomy2


SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR term_taxonomy3


SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR term_taxonomy4


SELECT term_taxonomy_id,term_id,taxonomy, parent FROM term_taxonomy1;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy, parent FROM term_taxonomy2;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy, parent FROM term_taxonomy3;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy, parent FROM term_taxonomy4;
into CURSOR  term_taxonomy




***TABLA TERMS****
*aqui se almacenan las categorias
*!*	term_id= codigo de linea
*!*	name= descripcion de categoria
*!*	slug= es la url
*!*	term_group

SELECT INT(VAL(cclasi1))+5000 as term_taxonomy_id,INT(VAL(cclasi1))+5000 as term_id,'product_cat' as taxonomy, 0 as parent,tlineas.cdescripci as name, tlineas.cdescripci as slug;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent,name,slug;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR terms1

SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_id,'product_cat' as taxonomy, INT(VAL(cclasi1))+5000 as parent,tsublineas.cdescripci as name, tsublineas.cdescripci as slug;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent,name,slug;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR terms2


SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))))  as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as parent ,ttallas.cdescripci as name, ttallas.cdescripci as slug;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent,name,slug;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR terms3


SELECT INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as parent,tcolores.cdescripci as name, tcolores.cdescripci as slug;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY term_taxonomy_id,term_id,taxonomy, parent,name,slug;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR terms4


SELECT term_taxonomy_id,term_id,taxonomy,parent,name,slug FROM terms1;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy,parent,name,slug FROM terms2;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy,parent,name,slug FROM terms3;
UNION;
SELECT term_taxonomy_id,term_id,taxonomy,parent,name,slug FROM terms4;
into CURSOR  terms



*****************************
*****TERMS RELATIONSHIP******
*****************************
SELECT cid_produc,INT(VAL(cclasi1))+5000 as term_taxonomy_id,INT(VAL(cclasi1))+5000 as term_id,'product_cat' as taxonomy, 0 as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY cid_produc,term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR relation1

SELECT cid_produc,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as term_id,'product_cat' as taxonomy, INT(VAL(cclasi1))+5000 as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY cid_produc,term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR relation2


SELECT cid_produc,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000)))) as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY cid_produc,term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR relation3


SELECT cid_produc,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_taxonomy_id,INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000))+ALLTRIM(str(INT(VAL(cclasi4))+8000)))) as term_id,'product_cat' as taxonomy, INT(VAL(ALLTRIM(str(INT(VAL(cclasi1))+5000))+ALLTRIM(str(INT(VAL(cclasi2))+6000))+ALLTRIM(str(INT(VAL(cclasi3))+7000)))) as parent;
FROM tproductos INNER JOIN tlineas;
on tproductos.cclasi1=tlineas.cid_linea;
INNER JOIN tsublineas ON tproductos.cclasi2=tsublineas.cid_sublin;
INNER JOIN ttallas ON tproductos.cclasi3=ttallas.cid_talla;
INNER JOIN tcolores ON tproductos.cclasi4=tcolores.cid_color;
GROUP BY cid_produc,term_taxonomy_id,term_id,taxonomy, parent;
where cid_produc in (SELECT cid_produc FROM ttproductos);
INTO CURSOR relation4


SELECT cid_produc,term_taxonomy_id FROM relation1;
UNION;
SELECT cid_produc,term_taxonomy_id FROM relation2;
UNION;
SELECT cid_produc,term_taxonomy_id FROM relation3;
UNION;
SELECT cid_produc,term_taxonomy_id FROM relation4;
into CURSOR  relationship



**BROWSE
**return




LOCAL lcstringcnxlocal AS STRING
lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=204.12.208.38;Database=autorepu_wordpress_6;User=autor_f1; Password=auto@123;Option=3"
**lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=200.74.207.9;Database=bdf1;User=autorepuestosf1; Password=auto123;Option=3"
*lcstringcnxlocal = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=bdfelcas;User=root; Password=;Option=3"
SQLSETPROP(0, "DispLogin", 3)
lnhandle = SQLSTRINGCONNECT(lcstringcnxlocal)
IF lnhandle > 0
   Select tproductos
   
   
   SELECT ttproductos
   
   
   
   SELECT tproductos
  
		**Set Filter To lactivo = .T. .And.  .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		SELECT ttproductos
		GO bottom
		nTotalRegistros2=RECCOUNT()
		Goto Top
		Do While  .Not. Eof()
		
		lnNroRegistro=RECNO()
		
		lcProducto=LOWER(ALLTRIM(ttproductos.cdescripci))
		lcDescrip=ALLTRIM(ttproductos.cdescripci)
		lcDescrip=CHRTRAN(lcDescrip,"'","")
		
		lcProducto=CHRTRAN(lcProducto,"'","")
		lcProducto=CHRTRAN(lcProducto,"/"," ")
		lcProducto=CHRTRAN(lcProducto,"("," ")
		lcProducto=CHRTRAN(lcProducto,")"," ")
		lcProducto=CHRTRAN(lcProducto,".","")
		lcProducto=CHRTRAN(lcProducto,"-"," ")
		lcProducto=strTRAN(lcProducto,"  "," ")
		
		
		IF !lBandera
		 lcSQLcommand="INSERT INTO 36Bbmi3M4O_posts(ID,post_author,post_date, post_date_gmt,post_content,post_title ,post_excerpt, post_name,guid,post_type) VALUES"
		 lBandera=.t.
		endif
		
		TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
	    (<<lnNroRegistro+2000>>,<<2>>,'<<>>','<<>>','<<utf8encode(lcProducto)>>','<<utf8encode(lcDescrip)>>','<<utf8encode(lcProducto)>>','<<CHRTRAN(utf8encode(lcProducto)," ","-")>>','http://autorepuestosf1.com/?post_type=product&#038;p=<<ALLTRIM(STR(RECNO()+2000))>>','product')
		ENDTEXT
		
		
		IF !lBandera2
		
		 lcSQLcommand2="INSERT INTO 36Bbmi3M4O_postmeta(meta_id,post_id,meta_key,meta_value) VALUES"
		 lBandera2=.t.
		endif
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"1"))>>,<<lnNroRegistro+2000>>,'_vc_post_settings','a:1:{s:10:"vc_grid_id";a:0:{}}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"2"))>>,<<lnNroRegistro+2000>>,'_edit_lock','1480294476:2')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"3"))>>,<<lnNroRegistro+2000>>,'_edit_last','2')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"4"))>>,<<lnNroRegistro+2000>>,'_visibility','visible')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"5"))>>,<<lnNroRegistro+2000>>,'_stock_status','instock')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		
		
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"++"6"))>>,<<lnNroRegistro+2000>>,'_downloadable','yes')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"7"))>>,<<lnNroRegistro+2000>>,'_virtual','no')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"8"))>>,<<lnNroRegistro+2000>>,'_tax_status','taxable')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"9"))>>,<<lnNroRegistro+2000>>,'_featured','no')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"10"))>>,<<lnNroRegistro+2000>>,'_product_attributes','a:0:{}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"11"))>>,<<lnNroRegistro+2000>>,'_regular_price','<<Precio(ttproductos.cid_produc)>>')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"12"))>>,<<lnNroRegistro+2000>>,'_sale_price','<<Precio(ttproductos.cid_produc)>>')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"13"))>>,<<lnNroRegistro+2000>>,'_price','<<Precio(ttproductos.cid_produc)>>')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"14"))>>,<<lnNroRegistro+2000>>,'_manage_stock','no')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"15"))>>,<<lnNroRegistro+2000>>,'_backorders','no')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"16"))>>,<<lnNroRegistro+2000>>,'_upsell_ids','a:0:{}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"17"))>>,<<lnNroRegistro+2000>>,'_crosssell_ids','a:0:{}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"18"))>>,<<lnNroRegistro+2000>>,'_downloadable_files','a:0:{}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"19"))>>,<<lnNroRegistro+2000>>,'slide_template','default')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"20"))>>,<<lnNroRegistro+2000>>,'_wc_rating_count','a:0:{}')
		ENDTEXT
		lcSQLcommand2=lcSQLcommand2+","
		
		TEXT TO lcSQLcommand2 NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		(<<INT(VAL(ALLTRIM(STR(lnNroRegistro))+"0000"+"21"))>>,<<lnNroRegistro+2000>>,'_wc_average_rating','0')
		ENDTEXT	
			
		
		
		IF RECNO()=nTotalRegistros then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		
		
		ENDIF	
		
		SELECT ttproductos
		
		IF RECNO()=nTotalRegistros2 then
		 **lcSQLcommand=lcSQLcommand+""
		ELSE
		 lcSQLcommand2=lcSQLcommand2+","
		 lcSQLcommand=lcSQLcommand+","
		ENDIF			
		
			
			Select ttproductos
			Skip
		ENDDO
		
		CREATE CURSOR Temporal(cadena M)
		SELECT Temporal
		APPEND BLANK
		replace cadena WITH lcSQLcommand2
		
		**===============TRANSFIRIENDO PRODUCTOS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		nTotalRegistros=0	
		
		lcSQLcommand2=lcSQLcommand2+";"		
		lBandera2=.f.			
		
		
		
		
		SQLEXEC(lnhandle,"DELETE FROM 36Bbmi3M4O_posts where post_type='product'")	
		SQLEXEC(lnhandle,"DELETE FROM 36Bbmi3M4O_postmeta where meta_id>100000 and post_id<=2100")	
		RETORNO2=SQLEXEC(lnhandle,lcSQLcommand)
		RETORNO=SQLEXEC(lnhandle,lcSQLcommand2)
		IF RETORNO>0 AND RETORNO2>0 &&La consulta se ejecutó sin problemas
    		PCESTADOENVIA = PCESTADOENVIA+"Productos I Insertados con exito"+TTOC(DATETIME())+CHR(13)
		ELSE
		   =AERROR(NOMBREARREGLO)
		   PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO PRODUCTOS I"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
		   MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		ENDIF
		
		
     
     SET DATABASE TO 
     **************************************
 
     **************************************
     SET DATABASE TO z:\confia\data\emp1\bdemp.dbc
     
    	
		Select terms
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			IF !lBandera
				lcSQLcommand="INSERT INTO 36Bbmi3M4O_terms(term_id,name,slug) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<terms.term_id>>,'<<PROPER(LOWER(terms.name))>>','<<ALLTRIM(STR(terms.term_id,20,0))+CHRTRAN(CHRTRAN(ALLTRIM(LOWER(terms.slug))," ","-"),",","-")>>')
			ENDTEXT	
			
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF		
		
			Select terms
			Skip
		ENDDO
		
		
		
		
	

		
		**===============TRANSFIRIENDO LAS LINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from 36Bbmi3M4O_terms where term_id>5000")	
		RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
		
		IF RETORNO>0 &&La consulta se ejecutó sin problemas
    		PCESTADOENVIA = PCESTADOENVIA+"Lineas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
		ELSE
		    =AERROR(NOMBREARREGLO)
		    PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO LINEAS"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
		   **MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		ENDIF
		nTotalRegistros=0
		
		***************************
		******TERMS META***********
		***************************
		
		Select terms
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			IF !lBandera
				lcSQLcommand="INSERT INTO 36Bbmi3M4O_termmeta(meta_id,term_id,meta_key,meta_value) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<INT(VAL("1"+ALLTRIM(STR(RECNO()+5000))))>>,<<terms.term_id>>,'order',<<0>>)
			ENDTEXT	
			lcSQLcommand=lcSQLcommand+","
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<INT(VAL("2"+ALLTRIM(STR(RECNO()+5000))))>>,<<terms.term_id>>,'static_block_id',<<0>>)
			ENDTEXT	
			lcSQLcommand=lcSQLcommand+","
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<INT(VAL("3"+ALLTRIM(STR(RECNO()+5000))))>>,<<terms.term_id>>,'display_type',<<0>>)
			ENDTEXT	
			lcSQLcommand=lcSQLcommand+","
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<INT(VAL("4"+ALLTRIM(STR(RECNO()+5000))))>>,<<terms.term_id>>,'thumbnail_id',<<0>>)
			ENDTEXT	
			
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF		
		
			Select terms
			Skip
		ENDDO
		
		
		
	

		
		**===============TRANSFIRIENDO LAS LINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from 36Bbmi3M4O_termmeta where meta_id>15000")	
		RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
		
		IF RETORNO>0 &&La consulta se ejecutó sin problemas
    		PCESTADOENVIA = PCESTADOENVIA+"Lineas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
		ELSE
		    =AERROR(NOMBREARREGLO)
		    PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO LINEAS"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
		   **MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		ENDIF
		nTotalRegistros=0
		
		
		
	
		
		*CREATE CURSOR Temporal(cadena M)
		**SELECT Temporal
		**APPEND BLANK
		**replace cadena WITH lcSQLcommand
		
		lcSQLcommand=""
		
			
		Select term_taxonomy
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			IF !lBandera
				lcSQLcommand="INSERT INTO 36Bbmi3M4O_term_taxonomy(term_taxonomy_id,term_id,taxonomy, parent) VALUES"
				lBandera=.t.
			ENDIF
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<term_taxonomy.term_taxonomy_id>>,<<term_taxonomy.term_id>>,'<<term_taxonomy.taxonomy>>',<<term_taxonomy.parent>>)
			ENDTEXT	
			
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF		
		
			Select term_taxonomy
			Skip
		ENDDO
		
		
		
		
			
	

		
		**===============TRANSFIRIENDO LAS LINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from 36Bbmi3M4O_term_taxonomy where term_taxonomy_id>5000")	
		RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
		
		IF RETORNO>0 &&La consulta se ejecutó sin problemas
    		PCESTADOENVIA = PCESTADOENVIA+"Lineas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
		ELSE
		    =AERROR(NOMBREARREGLO)
		    PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO LINEAS"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
		   **MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		ENDIF
		nTotalRegistros=0
		
		
		SELECT ttproductos
		INDEX on cid_produc TAG ix_prod
		SET ORDER TO ix_prod
		GO top
		
		LOCAL lnPosicion
		lnPosicion=0
			
		Select relationship
		Set Filter To .Not. Deleted()
		GO bottom
		nTotalRegistros=RECNO()
		Goto Top
		Do While  .Not. Eof()
		
			IF !lBandera
				lcSQLcommand="INSERT INTO 36Bbmi3M4O_term_relationships(object_id,term_taxonomy_id,term_order) VALUES"
				lBandera=.t.
			ENDIF
			
			lnPosicion=0
			
			SELECT ttproductos
			SEEK(relationship.cid_produc)
			IF FOUND()
			lnPosicion=RECNO()+2000
			ENDIF
			Select relationship
			
			TEXT TO lcSQLcommand NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
		    (<<lnPosicion>>,<<relationship.term_taxonomy_id>>,<<0>>)
			ENDTEXT	
			
			IF RECNO()=nTotalRegistros then
			 **lcSQLcommand=lcSQLcommand+""
			ELSE
			 lcSQLcommand=lcSQLcommand+","
			ENDIF		
		
			Select relationship
			Skip
		ENDDO
		
		
		
	
		
		
		
			
	

		
		**===============TRANSFIRIENDO LAS LINEAS==================
		lcSQLcommand=lcSQLcommand+";"		
		lBandera=.f.	
		SQLEXEC(lnhandle,"Delete from 36Bbmi3M4O_term_relationships where term_taxonomy_id>5000")	
		RETORNO=SQLEXEC(lnhandle,lcSQLcommand)
		
		IF RETORNO>0 &&La consulta se ejecutó sin problemas
    		PCESTADOENVIA = PCESTADOENVIA+"Lineas Insertadas con exito"+ TTOC(DATETIME())+CHR(13)
		ELSE
		    =AERROR(NOMBREARREGLO)
		    PCESTADOENVIA = PCESTADOENVIA+ CHR(13)+ "ERROR INSERTANDO LINEAS"+CHR(13)+NOMBREARREGLO(2)+ TTOC(DATETIME())
		   **MESSAGEB("ERROR EN LA CONSULTA"+CHR(13)+NOMBREARREGLO(2))
		ENDIF
		nTotalRegistros=0
		
		
		
		
		

		**===============TRANSFIRIENDO LOS CONTROLES==================
    
*!*	     CLOSE DATABASES all
     SQLDISCONNECT(lnhandle)
     **PCESTADOENVIA = "Transferencia de Inventarios realizada en forma Exitosa " + TTOC(DATETIME())
ELSE
    PCESTADOENVIA = "No se encontro conexion a internet " + TTOC(DATETIME())		
ENDIF
*CLOSE DATABASES ALL
ENDPROC
*
FUNCTION FECHAGUION
LPARAMETERS fecha
LOCAL valor
valor = ALLTRIM(STR(YEAR(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(MONTH(fecha))) +  ;
        "-" +  ;
        ALLTRIM(STR(DAY(fecha)))
RETURN valor
ENDFUNC


function utf8encode( lcString )
local lcUtf, i

    lcUtf = ""
    for i = 1 to len(lcString) 
        c = asc(substr(lcString,i,1))
        if  c < 128
            lcUtf = lcUtf+chr(c)
        else
            lcUtf = lcUtf+chr(bitor(192,bitrshift(c,6)))+chr(bitor(128,bitand(c,63)))
        endif
    next

return lcUtf
ENDFUNC


function Precio(lcProducto)
LOCAL lnPrecio
lnPrecio=0
	SELECT tproductos_precio
	SEEK(lcProducto+" 9")
	IF FOUND()
		lnPrecio=tproductos_precio.nprecio
	ENDIF
	
RETURN lnPrecio	
endfunc