**SET DEFAULT TO C:\UTILITARIO

* Derivar raíz del proyecto dinámicamente
LOCAL lcAppRoot
lcAppRoot = ADDBS(JUSTPATH(JUSTPATH(SYS(16))))

CLOSE DATABASES ALL
SET PATH TO (lcAppRoot+"DATA"), (lcAppRoot+"Formularios"), (lcAppRoot+"libreria"), (lcAppRoot+"iconos"), (lcAppRoot+"prg")
SET RESOURCE OFF 
SET PROCEDURE TO (lcAppRoot+"prg\funciones.prg"), (lcAppRoot+"prg\correo.prg"), (lcAppRoot+"prg\api_helper.prg")
SET EXCLUSIVE OFF
SET DELETED ON
SET SAFETY OFF
SET SYSMENU TO
SET DATE BRITISH
SET MULTILOCKS ON
SET LIBRARY TO bbsystray.fll
SET FDOW TO 1
ON ERROR

_SCREEN.CAPTION="Utilitario: Pedro Lopez 0412 5234229"
_SCREEN.WINDOWSTATE=2
_SCREEN.VISIBLE=.F.

**On Error Do errhand WITH Sys(0), Error(), Message(), Message(1), ;
	PROGRAM(), Lineno(1), Dbf(), Date(), Time()
***** BUSCANDO UNIDAD DE DATOS
USE C:\galepso\ADSNDD.DBF ALIAS UNIDAD IN 0 SHARED

SELECT UNIDAD
GO TOP

PUBLIC PCRESPUESTA,PCEMPRESA,PCRUTABDSISTEMA,PCUNIDAD,PCRUTABDEMPRESA,PCRUTAEMPRESACORTA,contaenviar,contarecibe,PCESTADOENVIA,PCESTADORECIBE
PUBLIC lcStringConexion,llApiRest,pcSistema,pcEmpresa
pcSistema = "galepso"
pcEmpresa = "emp1"
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=40.160.61.158;Database=chocola2_liderplus;User=chocola2_liderplus; Password=Liderplus2026*;Option=3"
**lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=liderplus_sandbox;User=root; Password=;Option=3"
lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};Server=159.195.66.171;Port=3459;Database=bdsistemas2;User=galexo_kw; Password=PGXz&161WW0d;Option=3"
llApiRest = .F.

* Abrir respaldos.dbf para leer/configurar modo sync
IF FILE(lcAppRoot+"data\respaldos.dbf")
    USE (lcAppRoot+"data\respaldos.dbf") IN 0 SHARED ALIAS respaldos
    SELECT respaldos
    GO TOP
    llApiRest = IIF(respaldos.lapi_rest=1,.f.,.t.)
ENDIF

PCRUTAEMPRESACORTA=""
PCRUTABDEMPRESA=""

PCUNIDAD=""
PCRUTABDSISTEMA=""
contaenviar=0
contarecibe=0
PCESTADOENVIA=""
PCESTADORECIBE=""
PCUNIDAD=UNIDAD.RX
* Override de unidad: datos migrados de X: a C: (2026-09-04)
* Comentar esta linea cuando ADSNDD.DBF sea actualizado con el valor correcto.
PCUNIDAD = "C:"

PCRUTABDEMPRESA=ALLTRIM(PCUNIDAD)+"\galepso\data\Emp"
PCRUTABDSISTEMA=ALLTRIM(PCUNIDAD)+"\galepso\data\sistema\"
PCRUTAEMPRESACORTA=ALLTRIM(PCUNIDAD)+"\galepso\data\"
SELECT UNIDAD
USE

DO FORM frmrespaldos
READ EVENTS

IF USED("respaldos")
    SELECT respaldos
    USE
ENDIF

CLEAR ALL
CLOSE ALL
SET SYSMENU TO DEFAULT

