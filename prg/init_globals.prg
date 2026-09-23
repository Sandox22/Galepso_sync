* =============================================================
* init_globals.prg
* Inicializa variables PUBLIC del sincronizador SIN abrir
* el formulario ni ejecutar CLEAR ALL.
* =============================================================
* Derivar raíz del proyecto dinámicamente
LOCAL lcAppRoot
lcAppRoot = ADDBS(JUSTPATH(JUSTPATH(SYS(16))))

CLOSE DATABASES ALL

SET PATH TO (lcAppRoot+"DATA"), (lcAppRoot+"Formularios"), ;
            (lcAppRoot+"libreria"), (lcAppRoot+"iconos"),   ;
            (lcAppRoot+"prg")
SET PROCEDURE TO (lcAppRoot+"prg\funciones.prg"), ;
                 (lcAppRoot+"prg\correo.prg"),     ;
                 (lcAppRoot+"prg\api_helper.prg")  ;
                 ADDITIVE
SET EXCLUSIVE OFF
SET DELETED ON
SET SAFETY OFF
SET DATE BRITISH
SET MULTILOCKS ON

PUBLIC PCRESPUESTA, PCEMPRESA, PCRUTABDSISTEMA, PCUNIDAD
PUBLIC PCRUTABDEMPRESA, PCRUTAEMPRESACORTA
PUBLIC contaenviar, contarecibe, PCESTADOENVIA, PCESTADORECIBE
PUBLIC lcStringConexion, llApiRest, pcSistema, pcEmpresa

pcSistema    = "galepso"
pcEmpresa    = "emp1"
llApiRest    = .F.
contaenviar  = 0
contarecibe  = 0
PCESTADOENVIA  = ""
PCESTADORECIBE = ""

PCUNIDAD = "C:"

PCRUTABDEMPRESA    = ALLTRIM(PCUNIDAD) + "\galepso\data\Emp"
PCRUTABDSISTEMA    = ALLTRIM(PCUNIDAD) + "\galepso\data\sistema\"
PCRUTAEMPRESACORTA = ALLTRIM(PCUNIDAD) + "\galepso\data\"

lcStringConexion = "Driver={MySQL ODBC 3.51 Driver};" + ;
                   "Server=159.195.66.171;Port=3459;"  + ;
                   "Database=bdsistemas2;User=galexo_kw;" + ;
                   "Password=PGXz&161WW0d;Option=3"

MESSAGEBOX( ;
    "Globals inicializados OK:" + CHR(13) + ;
    "  PCUNIDAD    = " + PCUNIDAD + CHR(13) + ;
    "  pcSistema   = " + pcSistema + CHR(13) + ;
    "  pcEmpresa   = " + pcEmpresa, ;
    64, "init_globals.prg")

