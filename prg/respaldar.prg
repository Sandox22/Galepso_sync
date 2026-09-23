PARAMETERS lcdestino1,lntipo&& lntipo indica si es diario cuando es 1 o 2 cuando es mensual

LOCAL contaempresas
contaempresas=0
IF DIRECTORY(ALLTRIM(lcdestino1)) THEN
	**	USE (PCRUTABDSISTEMA+"tempresas") IN 0 SHARED
	SELECT tempresas
	SELECT * FROM tempresas WHERE cid_empre IN(SELECT cid_empre FROM empresas)INTO CURSOR empresas2

	SELECT empresas2
	GO TOP
	DO WHILE !EOF()
		contaempresas=contaempresas+1
		SKIP
	ENDDO

	IF contaempresas=0 THEN
		SELECT empresas2
		USE
		SELECT * FROM tempresas INTO CURSOR empresas2
	ELSE
	ENDIF

	SELECT empresas2
	GO TOP

	PUBLIC pcSubcarpeta
	pcSubcarpeta=""
	IF lntipo=1 THEN
		DO CASE
			CASE DOW(DATE())=2
				pcSubcarpeta="LUNES"
			CASE DOW(DATE())=3
				pcSubcarpeta="MARTES"
			CASE DOW(DATE())=4
				pcSubcarpeta="MIERCOLES"
			CASE DOW(DATE())=5
				pcSubcarpeta="JUEVES"
			CASE DOW(DATE())=6
				pcSubcarpeta="VIERNES"
			CASE DOW(DATE())=7
				pcSubcarpeta="SABADO"
			CASE DOW(DATE())=1
				pcSubcarpeta="DOMINGO"
		ENDCASE
	ELSE
		pcSubcarpeta="MENSUAL"
	ENDIF

	SET EXCLUSIVE OFF
	SET DELETED ON
	SET EXACT ON

	LOCAL lcOrigen,Cadena,lnContador
	lnContador=0
	Cadena=""
	lcOrigen=""


	**fs.CopyFile(c:\autoexec.bat,a:\autoexec.bat,.T.)  && The last parameter is for overwriting.
	SELECT empresas2
	GO TOP


	DO WHILE !EOF()
		lnContador=lnContador+1

		lcOrigen=PCRUTAEMPRESACORTA+ALLTRIM(empresas2.crutabd)
		lcdestino=ALLTRIM(lcdestino1)+pcSubcarpeta+"\"+ALLTRIM(empresas2.crutabd)
		CHDIR ALLTRIM(lcdestino1)
		IF DIRECTORY(ALLTRIM(lcdestino))<>.T.
			MD ALLTRIM(lcdestino)
		ENDIF
		**lcdestino=lcdestino+" /Y"
		fs = CREATEOBJECT("Scripting.FileSystemObject")
		WAIT WINDOW "RESPALDANDO EMPRESA   ("+ALLTRIM(empresas2.cnombre)+")  PROGRESO "+STR(lnContador)+" DE "+ STR(contaempresas) +" POR FAVOR ESPERE..." TIMEOUT 1
		fs.CopyFile(lcOrigen+"\*.*",lcdestino+"\",.T.)&&copiando tablas



		**!xcopy "&lcOrigen" &lcdestino

		RELEASE fs

		SELECT empresas2
		SKIP
	ENDDO



	IF lntipo=1 THEN
		SELECT respaldos
		REPLACE dfech_ul WITH DATE()
	ELSE
		SELECT respaldos
		REPLACE dult_mes WITH DATE()
	ENDIF

	SELECT empresas2
	USE

ELSE
	MESSAGEBOX("El directorio seleccionado como ruta de respaldo es invalido o no existe")
ENDIF
MESSAGEBOX("Proceso culminado sus datos han sido respaldados con exito",64)


SET DEFAULT TO ("c:\respaldosautomaticos\iconos")






