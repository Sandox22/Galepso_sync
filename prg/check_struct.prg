SET SAFETY OFF
LOCAL dirdata, lcAppRoot
lcAppRoot = ADDBS(JUSTPATH(JUSTPATH(SYS(16))))
dirdata = 'X:\Galepso\Data\Emp6\'
IF FILE(dirdata + 'tproductos.dbf')
    USE (dirdata + 'tproductos.dbf') IN 0
    LIST STRUCTURE TO (lcAppRoot + "prg\struct.txt")
ENDIF
