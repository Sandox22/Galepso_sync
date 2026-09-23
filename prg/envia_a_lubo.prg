PARAMETERS lcrutaenvio,lcempresa

*ON ERROR do errores
LOCAL lnrecno
lnrecno=0

Set Exclu Off
Set Dele On
Set Talk Off
Set Safety Off
Set Date british
Select a
pnnivel_recursividad = 0
Use c:\confia\adsndd
discox=Alltrim(rx)+"\confia\data\emp"
**interfacex="c:\lubosales\envia\"
interfacex=ALLTRIM(lcrutaenvio)
**interfacex="c:\liderplussync\prueba\"
empresax=VAL(lcempresa)
rutax=discox+Alltrim(Str(empresax))+"\"

SELECT empresas
lnrecno=RECNO()


* CREAR TABLA DE CLIENTES
Select a
Use (rutax+"tclientes")
Select b
Use (rutax+"tdetalles_datos_envio")
Set Order To ix_clien
Select d
Use (rutax+"testados")
Set Order To ix_estado
Select c
Use (rutax+"tciudades")
Set Order To ix_ciudad
Create Cursor tblclie (;
codclie		c(12),;		&&Codigo
nomclie		c(50),;		&&Nombre
razclie		c(50),;		&&Razon Social
rifclie		c(15),;		&&Cedula o Rif
dirclie		c(120),;	&&Direccion
dirdesp		c(120),;		&&Despacho
telclie		c(30),;		&&Telefono
faxclie		c(30),;		&&Fax
visitado	c(1),;		&&Indica si fue visitado o no
limcred		N(16,2),;	&&Limite de Credito
diascred	c(4),;		&&Dias Credito
codvend		c(10),;		&&Codigo del Vendedor
fecnac		c(10),;		&&Fecha de Nacimiento del Propietario o Persona Contacto
obsclie		c(250),;	&&Observaciones acerca del cliente
tipoimp		c(1),;		&&Tipo de Impuesto
contacto	c(40),;		&&Persona Contacto
contacel	c(30),;		&&Celular Persona Contacto
mailclie	c(60),;		&&Lista de Precio
codzona		c(10),;		&&Zona
codmzona	c(10),;		&&Mini Zona (Este campo no lo tengo en el sistema)
pordesc		N(5,2),;	&&Porcentaje de descuento de precio lista
pordesc1	N(5,2),;	&&Porcentaje de descuento de familia 1
pordesc2	N(5,2),;	&&Porcentaje de descuento de familia 2
pordesc3	N(5,2),;	&&Porcentaje de descuento de familia 3
contesp		c(1),;		&&El cliente Es contribuyente especial?
estclie		c(1),;		&&Cliente 0=Inactivo, 1=Activo
tippre		c(1),;		&&Tipo de Precio
descppag    N(5,2),;	&&Porcentaje de descuento Pronto Pago
codalt		c(40) )		&&Codigo Alterno del Cliente

Create Cursor tbldiral (;
coddir		c(10),;		&&Codigo Direccion Alterna
codclie		c(12),;		&&Codigo
diralt		c(120) )	&&Direccion Alterna del Cliente

Select a
Goto Top
Do While !Eof()
	Select c
	Seek a.cid_estadc+a.cid_ciudac
	Select d
	Seek a.cid_estadc
	ciudaenv = c.cdescripci
	estadenv = d.cdescripci
	Select c
	Seek a.cid_estadc+a.cid_ciudac
	Select d
	Seek a.cid_estadc
	If Val(a.cid_tpr_cr)>9
		tipx=1
	Else
		tipx=Val(a.cid_tpr_cr)
	Endif
	Select b
	Seek a.cid_clien
	Do While !Eof() And cid_clien=a.cid_clien
		If Substr(cnombreenv,1,10)="PRINCIPAL "
			Skip
			Loop
		Endif
		Select c
		Seek b.cid_estade+b.cid_ciudae
		Select d
		Seek b.cid_estade
		ciudaalt = c.cdescripci
		estadalt = d.cdescripci
		Select tbldiral
		Append Blank
		Replace coddir With b.cnombreenv,;
		codclie With Str(Val(a.cid_clien)),;
		diralt With Alltrim(b.cdir_env1)+" "+Alltrim(b.cdir_env2)+" "+Alltrim(ciudaalt)+" "+Alltrim(estadalt)
		Select b
		Skip
	Enddo
	Select tblclie
	Append Blank
	Replace codclie With Alltrim(a.cid_clien),;
	nomclie With a.cnombre_cl,;
	razclie With a.cnombre_cl,;
	rifclie With a.crif_cli,;
	dirclie With Alltrim(a.cdir_cli1)+" "+Alltrim(a.cdir_cli2)+" "+Alltrim(c.cdescripci)+" "+Alltrim(d.cdescripci),;
	dirdesp With Alltrim(b.cdir_env1)+" "+Alltrim(b.cdir_env2)+" "+Alltrim(ciudaenv)+" "+Alltrim(estadenv),;
	telclie With a.ctele_cli,;
	faxclie With a.cfax_cli,;
	limcred With a.nlimite_c,;
	diascred With Alltrim(Str(a.nvencimien)),;
	codvend With Alltrim(Str(Val(a.cid_vende),10)),;
	fecnac With Dtoc(a.dfecha_nac),;
	obsclie With a.mobservaci,;
	tipoimp With "1",;
	contacto With a.mcontactos,;
	contacel With a.ccelu_cli,;
	mailclie With a.ce_mail,;
	codzona With Str(Val(a.cid_zona),10),;
	pordesc With a.nmaximo_d,;
	contesp With Substr(a.ccategoria,1,1),;
	estclie With Iif(a.lactivo,"1","0"),;
	tippre With Str(tipx,1)
	Select a
	Skip
Enddo
Select tblclie
Goto Top
Copy To (interfacex+"tblclie.dbf") Type Fox2x
Select tbldiral
Goto Top
Copy To (interfacex+"tbldiral.dbf") Type Fox2x
Close All



* CREAR TABLA DE PRODUCTOS
Select a
Use (rutax+"tproductos")
Select b
Use (rutax+"tproductos_precio")
Select c
Use (rutax+"ttipos_precio")
Set Order To ix_tip_pre
Goto Top
Dimension tipos_precios(6)
tipos_precios="  "
i=1
Do While !Eof() And i<7
	tipos_precios(i)=cid_tipo_p
	Skip
	i=i+1
Enddo
Select d
Use (rutax+"tcontroles")
Select e
Use (rutax+"tproductos_almacen")
Select F
Use (rutax+"talmacenes")
*!*	Select g
*!*	Use (rutax+"tinventarios")
*!*	Select h
*!*	Use (rutax+"tdetalles_inventario")
Select g
Use (rutax+"tdetalles_descuento_linea")

Create Cursor descpro (;
codclie		c(12),;		&&codigo del cliente
codprod		c(20),;		&&codigo del producto
rango0		N(5),;
rango1		N(5),;
pordesc1	N(5,2),;
rango2		N(5),;
pordesc2	N(5,2),;
rango3		N(5),;
pordesc3	N(5,2),;
rango4		N(5),;
pordesc4	N(5,2),;
rango5		N(5),;
pordesc5	N(5,2),;
rango6		N(5),;
pordesc6	N(5,2),;
rango7		N(5),;
pordesc7	N(5,2),;
rango8		N(5),;
pordesc8	N(5,2),;
rango9		N(5),;
pordesc9	N(5,2),;
rango10		N(5),;
pordesc10	N(5,2),;
negociar	c(1) )

Create Cursor tblprod (;
codfam		c(15),;		&&Familia de Productos
codprod		c(20),;		&&codigo de producto
codsfam		c(15),;		&&Subfamilia de Productos
desprod		c(40),;		&&Descripcion del Producto
descalt		c(50),;		&&Descripcion Alterna
unimed		c(3),;		&&Unidad de medida
convprod	c(8),;		&&Conversion de producto
precio		N(16,2),;	&&Precio 1 del Producto
precio2		N(16,2),;	&&Precio 2 del Producto
precio3		N(16,2),;	&&Precio 3 del Producto
precio4		N(16,2),;	&&Precio 4 del Producto
precio5		N(16,2),;	&&Precio 5 del Producto
precio6		N(16,2),;	&&Precio 6 del Producto
alicuota	N(16,2),;	&&Alicuota de Impuesto
imp1		N(16,2),;	&&Impuesto 1
imp2		N(16,2),;	&&Impuesto 2
imp3		N(16,2),;	&&Impuesto 3
imp4		N(16,2),;	&&Impuesto 4
secpro		N(5,2),;
seleped		c(1),;
codalt		c(5),;
codgrp3		c(3),;
invprod		N(5,0),;
selepro		c(1) )

Dimension precios(6)
precios=0.00
Select a
Do While !Eof()
	If lapli_iva
		If nporc_iva=0
			impuesto=tcontroles.niva
		Else
			impuesto=nporc_iva
		Endif
	Else
		impuesto=0
	Endif
	For i=1 To 6
		If tipos_precios(i)<>"  "
			precios(i)=devuelve_precio(a.cid_produc,tipos_precios(i))
		Endif
	Next
	Select tblprod
	Append Blank
	Replace codfam With "0",;
	codsfam With Alltrim(a.cclasi1),;
	codprod With a.cid_produc,;
	desprod With a.cdescripci,;
	descalt With a.cdescrialt,;
	unimed With a.cunidad_m,;
	convprod With "1",;
	precio  With precios(1),;
	precio2 With precios(2),;
	precio3 With precios(3),;
	precio4 With precios(4),;
	precio5 With precios(5),;
	precio6 With precios(6),;
	imp1 With impuesto,;
	invprod With a.nexisten
	precios=0
	If a.ndescmax<>0
		Select descpro
		Append Blank
		Replace codprod With a.cid_produc,;
		rango0 With 1,;
		rango1 With 99999,;
		pordesc1 With a.ndescmax,;
		negociar With "1"
	Endif
	Select a
	Skip
Enddo
Select g
Goto Top
Do While !Eof()
	Select a
	Set Filter To cclasi1=g.cid_linea
	Goto Top
	Do While !Eof()
		Select descpro
		Append Blank
		Replace codclie With Alltrim(g.cid_clien),;
		codprod With a.cid_produc,;
		rango0 With 1,;
		rango1 With 99999,;
		pordesc1 With g.ndescuenma,;
		negociar With Iif(g.ndescuen=g.ndescuenma,"0","1")
		Select a
		Skip
	Enddo
	Select g
	Skip
Enddo

Select tblprod
Copy To (interfacex+"tblprod.dbf")Type Fox2x
Select descpro
Copy To (interfacex+"descpro.dbf")Type Fox2x
Close All


* CREAR TABLA DE FAMILIAS
Select a
Use (rutax+"tlineas")
Set Order To ix_linea
Goto Top
Create Cursor tblfam (;
codfam		c(15),;		&&Familia de Productos
desfam		c(40),;		&&Descripcion de Familia de Productos
porcum		N(5,2),;	&&Porcentaje de cumplimiento
codalt		c(3) )
Select tblfam
Append Blank
Replace codfam With "0",;
desfam With "FAMILIA UNICA"
Select tblfam
Copy To (interfacex+"tblfam.dbf")Type Fox2x
Close All


* CREAR TABLA DE SUB-FAMILIAS
Select a
Use (rutax+"tlineas")
Set Order To ix_linea
Goto Top
Create Cursor tblsfam (;
codfam		c(15),;	&&Codigo Familia de Productos
codsfam		c(15),;	&&Codigo Sub-Familia de Productos
desfam		c(40),;	&&Descripcion de la Sub Familia de Productos
secsfam		N(10,2),;
codalt		c(3) )
Select a
Do While !Eof()
	Select tblsfam
	Append Blank
	Replace codsfam With a.cid_linea,;
	desfam With a.cdescripci,;
	codfam With "0"
	Select a
	Skip
Enddo
Select tblsfam
Copy To (interfacex+"tblsfam.dbf")Type Fox2x
Close All

* CREAR TABLA DE VENDEDORES
Select a
Use (rutax+"tvendedores")
Set Order To ix_vendedo
Goto Top
Create Cursor tblvend (;
codvend		c(10),;	&&Codigo del Vendedor
nomvend		c(40),;	&&Nombre del Vendedor
clavend		c(5),;	&&Clave del Vendedor
clamast		c(5),;	&&Clave Maestra
descalic	c(7),;	&&Descripcion del Impuesto a las Ventas
simdec		c(1),;	&&Simbolo decimal
ultmod		c(1),;
codfam		c(3),;
coment		c(250),;
comentp		c(250),;
porret1		N(8,2),;
porret2		N(8,2) )
Select a
Do While !Eof()
	Select tblvend
	Append Blank
	Replace codvend With Alltrim(Str(Val(a.cid_vende),10)),;
	clavend With Alltrim(Substr(a.mobservaci,1,10)),;
	clamast With Alltrim(Str(Val(a.cid_vende),10)),;
	nomvend With a.cnombrev,;
	descalic With "IVA"
	Select a
	Skip
Enddo
Select tblvend
Copy To (interfacex+"tblvend.dbf")Type Fox2x


Close All

PCESTADOENVIA = "Transferencia realizada en forma Exitosa " + TTOC(DATETIME())

USE (ADDBS(JUSTPATH(JUSTPATH(SYS(16))))+"data\respaldos") IN 0 SHARED
USE (ADDBS(JUSTPATH(JUSTPATH(SYS(16))))+"data\empresas") IN 0 SHARED
USE (PCRUTABDSISTEMA+"tempresas") IN 0 shared

SELECT empresas
GO lnrecno

Return

*** ESTA FUNCION PERMITE ESTABLECER CUALES SON LOS TIPOS DE PRECIOS
** QUE TIENE EL PRODUCTO SELECCIONADO TOAMDO EN CUENTA LAS REFERENCIAS QUE TINEN CADA TIPO DE
** PRECIO Y SE SE MUESTRA EL TIPO DE PRECIO
** LOS DIFERENTES TIPOS DE PRECIOS SON GUARDADOS EN UN CURSOR TEMPORAL CREADO AL MOMENTO DE
** CARGAR EL FORMULARIO DE PRODUCTOS
&&   OJO  ESTA FUNCION SOLO PUEDE SER UTILIZADA POR EL FOMULARIO DE PRODUCTOS Y DE
&&   CONSULTA DE PRODUCTOS


* ESTA FUNCION DEVUELVE EL PRECIO DE UN PRODUCTO DEPENDIENDO DE SUS PARAMETROS.
Function devuelve_precio(tcproducto,tcprecio,tcoferta,tcfecha)
pnnivel_recursividad = pnnivel_recursividad + 1
If pnnivel_recursividad > 5
	Messagebox("Existe un lazo infinito en los precios")
	pnnivel_recursividad = pnnivel_recursividad - 1
	Return 0
Endif
If Pcount()=3
	If !Empty(tcoferta)
		If devuelve_precio(tcproducto,tcoferta)<> 0
			pnnivel_recursividad = pnnivel_recursividad - 1
			Return devuelve_precio(tcproducto,tcoferta)
		Endif
	Endif
Endif

Local ldfecha_pre,lnprecio_pre
*-* Verifica si  esta la tabla tControles esta activa para pregusntar por el campo
llfechpre = .F.
lndias_pre = 0

Select tproductos_almacen
Set Order To ix_prodalm
Select tproductos_precio
Set Order To ix_pro_pre
Local lnprecios,lncantidad,lntotal,lnfecha,lnunidad
Store 0.00 To lnprecios,lncantidad,lntotal
lnfecha =Ctod("01/01/1900")

Select ttipos_precio
Seek tcprecio
*** verificando la unidad en caso de tenerla
Do Case
Case !Empty(ttipos_precio.ctipo_ref) And ttipos_precio.ldecena
	lnunidad = 1
Case !Empty(ttipos_precio.ctipo_ref) And ttipos_precio.lcentena
	lnunidad = 10
Case !Empty(ttipos_precio.ctipo_ref) And  ttipos_precio.lunida_mil
	lnunidad = 100
Endcase

Select tproductos_precio
Seek tcproducto+tcprecio
If Found()

	Do Case
	Case tproductos_precio.ctipo_ref = "00" && Precio de Referencia es Costo Promedio
		Select tproductos_almacen
		Seek tcproducto
		Do While !Eof() And tproductos_almacen.cid_produc = tcproducto
			Select talmacenes
			Set Order To ix_almacen
			Seek(tproductos_almacen.cid_almace)
			Select tproductos_almacen
			If talmacenes.lmovimi
				lntotal    = lntotal +  tproductos_almacen.ncosto_inv
				lncantidad = lncantidad + tproductos_almacen.nexisten
			Endif
			Skip
		Enddo
		If lncantidad != 0
			lnprecios = Round((lntotal / lncantidad) * tproductos_precio.nfactor , ttipos_precio.ndecimal)
		Endif
		pnnivel_recursividad = pnnivel_recursividad - 1
		lnprecios = precioproximo(lnprecios,lnunidad)
		Return lnprecios

	Case tproductos_precio.ctipo_ref = "99" && Precio de Referencia es Ultimo Costo
		Select talmacenes
		Set Order To ix_almacen
		Select tproductos_almacen
		Seek tcproducto
		Do While !Eof() And tproductos_almacen.cid_produc = tcproducto
			Select talmacenes
			Seek(tproductos_almacen.cid_almace)
			If talmacenes.lmovimi
				Select tproductos_almacen
				If lnfecha < tproductos_almacen.dfecha_ulc
					lnfecha = tproductos_almacen.dfecha_ulc
					lnprecios = Round(tproductos_almacen.ncosto_ulc * tproductos_precio.nfactor, ttipos_precio.ndecimal)
				Endif
			Endif
			Select tproductos_almacen
			Skip
		Enddo
		pnnivel_recursividad = pnnivel_recursividad - 1
		lnprecios = precioproximo(lnprecios,lnunidad)
		Return lnprecios

	Case tproductos_precio.ctipo_ref = "98"  && Precio de Referencia es Costo Historico

		Select tdetalles_inventario
		Set Order To ix_prodalm
		Select tinventarios
		Set Order To ix_inventa
		If Pcount()  = 4 And !Empty(tcfecha)
			Select tproductos_almacen
			Seek tcproducto
			Do While !Eof() And tproductos_almacen.cid_produc = tcproducto
				Select talmacenes
				Set Order To ix_almacen
				Seek(tproductos_almacen.cid_almace)
				If talmacenes.lmovimi
					lncantidad = lncantidad + tproductos_almacen.ninv_ini
					lntotal = lntotal + tproductos_almacen.ncosto_ini
					Select tdetalles_inventario
					Seek (tcproducto + tproductos_almacen.cid_almace)
					Do While !Eof() And (tproductos_almacen.cid_produc = tcproducto) And (tproductos_almacen.cid_almace = cid_almace)
						Select tinventarios
						Seek tdetalles_inventario.cid_tipomo + tdetalles_inventario.cid_movimi
						If dfecha <= tcfecha
							lncantidad = lncantidad + tdetalles_inventario.ncantidad
							lntotal = lntotal + tdetalles_inventario.nmonto
						Endif
						Select tdetalles_inventario
						Skip
					Enddo
				Endif
				Select tproductos_almacen
				Skip
			Enddo
			If lncantidad > 0
				lnprecios = Round((lntotal / lncantidad) * tproductos_precio.nfactor , ttipos_precio.ndecimal)
			Endif
		Endif
		pnnivel_recursividad = pnnivel_recursividad - 1
		lnprecios = precioproximo(lnprecios,lnunidad)
		Return lnprecios

	Case tproductos_precio.ctipo_ref = "  "

		lnprecios = Round(nprecio, ttipos_precio.ndecimal)
		pnnivel_recursividad = pnnivel_recursividad - 1
		lnprecios = precioproximo(lnprecios,lnunidad)
		Return lnprecios

	Otherwise

		If llfechpre  .And. tproductos_precio.ctipo_ref != "  "&& Verificando si existe caducidad en los precios
			If tproductos_precio.ctipo_ref != "  "
				Select tproductos_precio
				Seek(tproductos_precio.cid_produc + tproductos_precio.ctipo_ref)
				ldfecha_pre   = tproductos_precio.dfecha_act
				lnprecio_pre  = tproductos_precio.nprecio

				Select tproductos_precio
				Seek tcproducto+tcprecio

			Else
				ldfecha_pre   = tproductos_precio.dfecha_act
				lnprecio_pre  = tproductos_precio.nprecio
			Endif

			If (pdfechaoper - Ttod(ldfecha_pre)) > lndias_pre And  !Empty(lnprecio_pre)
				If pnnivel_recursividad = 1 Or Type("plMostrar") = "U"
					*Messagebox("El Precio : " + Alltrim(ttipos_precio.cdescripci)+ " para: '" + Alltrim(tproductos_precio.cid_produc) + "' esta vencido",16,"Advertencia")
					PCESTADOENVIO = PCESTADOENVIO + "El Precio : " + Alltrim(ttipos_precio.cdescripci)+ " para: '" + Alltrim(tproductos_precio.cid_produc) + "' esta vencido"
				Endif
				If Type("plMostrar") = "U" && Verifica si se devuelve el el precio vencido
					lnprecios = -1
					pnnivel_recursividad = pnnivel_recursividad - 1
					lnprecios = precioproximo(lnprecios,lnunidad)
					Return lnprecios
				Endif
			Endif

		Endif

		Do Case
		Case Pcount()=2
			lnprecios = Round(nfactor * devuelve_precio(tcproducto,tproductos_precio.ctipo_ref),ttipos_precio.ndecimal)
		Case Pcount()=3
			lnprecios = Round(nfactor * devuelve_precio(tcproducto,tproductos_precio.ctipo_ref,tcoferta),ttipos_precio.ndecimal)
		Case Pcount()=4
			lnprecios = Round(nfactor * devuelve_precio(tcproducto,tproductos_precio.ctipo_ref,tcoferta,tcfecha),ttipos_precio.ndecimal)
		Endcase
		pnnivel_recursividad = pnnivel_recursividad - 1
		lnprecios = precioproximo(lnprecios,lnunidad)
		Return lnprecios
	Endcase

Else

	Select ttipos_precio
	Seek tcprecio
	If Found()
		Store 0.00 To lnprecios,lncantidad,lntotal
		Select tproductos_precio
		Do Case

		Case ttipos_precio.ctipo_ref = "00" && Precio de Referencia es Costo Promedio
			Select tproductos_almacen
			Seek tcproducto

			Do While !Eof() And tproductos_almacen.cid_produc = tcproducto

				Select talmacenes
				Set Order To ix_almacen
				Seek(tproductos_almacen.cid_almace)
				Select tproductos_almacen
				If talmacenes.lmovimi
					lntotal    = lntotal +  tproductos_almacen.ncosto_inv
					lncantidad = lncantidad + tproductos_almacen.nexisten
				Endif
				Skip

			Enddo
			If lncantidad != 0
				lnprecios = Round((lntotal / lncantidad) * ttipos_precio.nfactor , ttipos_precio.ndecimal)
			Endif
			pnnivel_recursividad = pnnivel_recursividad - 1
			lnprecios = precioproximo(lnprecios,lnunidad)
			Return  lnprecios

		Case ttipos_precio.ctipo_ref = "99" && Precio de Referencia es Ultimo Costo

			Select talmacenes
			Set Order To ix_almacen

			Select tproductos_almacen
			Seek tcproducto
			Do While !Eof() And tproductos_almacen.cid_produc = tcproducto
				Select talmacenes
				Seek(tproductos_almacen.cid_almace)
				If talmacenes.lmovimi
					Select tproductos_almacen
					If lnfecha < tproductos_almacen.dfecha_ulc
						lnfecha = tproductos_almacen.dfecha_ulc
						lnprecios = Round(tproductos_almacen.ncosto_ulc * ttipos_precio.nfactor, ttipos_precio.ndecimal)
					Endif
				Endif
				Select tproductos_almacen
				Skip
			Enddo
			pnnivel_recursividad = pnnivel_recursividad - 1
			lnprecios = precioproximo(lnprecios,lnunidad)
			Return lnprecios

		Case ttipos_precio.ctipo_ref = "98"&& Precio de Referencia es Costo Historico


			Select tdetalles_inventario
			Set Order To ix_prodalm
			Select tinventarios
			Set Order To ix_inventa
			If Pcount() = 4 And !Empty(tcfecha)
				Select tproductos_almacen
				Seek tcproducto
				Do While !Eof() And tproductos_almacen.cid_produc = tcproducto
					Select talmacenes
					Set Order To ix_almacen
					Seek(tproductos_almacen.cid_almace)
					If talmacenes.lmovimi
						lncantidad = lncantidad + tproductos_almacen.ninv_ini
						lntotal = lntotal + tproductos_almacen.ncosto_ini
						Select tdetalles_inventario
						Seek (tcproducto + tproductos_almacen.cid_almace)
						Do While !Eof() And (tdetalles_inventario.cid_produc = tcproducto) And (tdetalles_inventario.cid_almace = tproductos_almacen.cid_almace)
							Select tinventarios
							Seek tdetalles_inventario.cid_tipomo + tdetalles_inventario.cid_movimi
							If dfecha <= tcfecha
								lncantidad = lncantidad + tdetalles_inventario.ncantidad
								lntotal = lntotal + tdetalles_inventario.nmonto
							Endif
							Select tdetalles_inventario
							Skip
						Enddo
					Endif
					Select tproductos_almacen
					Skip
				Enddo
				If lncantidad > 0
					lnprecios = Round((lntotal / lncantidad) * ttipos_precio.nfactor , ttipos_precio.ndecimal)
				Endif
			Endif
			pnnivel_recursividad = pnnivel_recursividad - 1
			lnprecios = precioproximo(lnprecios,lnunidad)
			Return lnprecios

		Case ttipos_precio.ctipo_ref = "  "

			lnprecios = 0
			pnnivel_recursividad = pnnivel_recursividad - 1
			lnprecios = precioproximo(lnprecios,lnunidad)
			Return lnprecios
		Otherwise

			Do Case
			Case Pcount()=2
				lnprecios = Round(ttipos_precio.nfactor * devuelve_precio(tcproducto,ttipos_precio.ctipo_ref),ttipos_precio.ndecimal)
			Case Pcount()=3
				lnprecios = Round(ttipos_precio.nfactor * devuelve_precio(tcproducto,ttipos_precio.ctipo_ref,tcoferta),ttipos_precio.ndecimal)
			Case Pcount()=4
				lnprecios = Round(ttipos_precio.nfactor * devuelve_precio(tcproducto,ttipos_precio.ctipo_ref,tcoferta,tcfecha),ttipos_precio.ndecimal)
			Endcase
			pnnivel_recursividad = pnnivel_recursividad - 1
			lnprecios = precioproximo(lnprecios,lnunidad)
			Return lnprecios

		Endcase
	Endif
Endif
Endfunc



** tnPrecio: el precio al que se desea llevar a su unidad mas proxima 10,100 o 1000
** tnUnidad: la unidad a la que se quiere llevar e precio enviuado 10 ,100 0 1000
Function precioproximo(tnprecio,tnunidad)
Local lnprecioant,lndifprecio
lnprecioant = tnprecio

If !Empty(tnunidad) And !Empty(tnprecio)
	tnprecio = tnprecio/tnunidad
	tnprecio = Int(tnprecio) + 1
	tnprecio = tnprecio * tnunidad
	lndifprecio = tnprecio - lnprecioant

	If Inlist(lndifprecio,1,10,100)
		tnprecio = lnprecioant
	Endif

Endif

Return tnprecio
Endfunc
ON ERROR