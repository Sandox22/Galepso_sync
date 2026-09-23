PARAMETERS lcrutarecibe,lcempresa
*ON ERROR do errores
LOCAL lnrecno
lnrecno=0

&& direccion c:\lubosync\envia\
Set exclu off
Set dele on
SET TALK off
Set safety off
Set date british
Select a
Use c:\confia\adsndd
discox=alltrim(rx)+"\confia\data\emp"
**interfacex="c:\lubosales\recibe\"
interfacex=ALLTRIM(lcrutarecibe)
Clear
empresax=val(lcempresa)
rutax=discox+alltrim(str(empresax))+"\"
pedidos=0

SELECT empresas
lnrecno=RECNO()

* LLENAR PEDIDOS
Select a
Use (rutax+"tpedidos")
set order to ix_pedido
select b
use (rutax+"tdetalles_pedido")
Select c
use (interfacex+"encaped")
select d
use (interfacex+"detaped")
select e
Use (rutax+"tclientes")
set order to ix_cliente
Select c
Goto top
Do while !eof()
    if syncok="1"
      skip
      loop
    endif
    pedidos=pedidos+1
    select e
    seek str(val(c.codclie),5)
    select a
    seek str(val(c.numped),8)
    if found()
      select c
      skip
      loop
    endif
    largox=len(alltrim(c.numped))
    vendedorx=substr(c.numped,1,largox-5)
    pedidox=substr(c.numped,largox-5+1,5)
    append blank
    replace cid_pedido with str(val(c.numped),8),;
            cid_clien with str(val(c.codclie),5),;
 			crif_cli with e.crif_cli,;
            dfecha with ctod(c.fecped),;
            dfecha_e with ctod(c.fecped),;
            cid_status with "  1",;
            ctipo_pre WITH STR(VAL(c.tippre),2),;
            ctipo_pre with " 1",;
            cid_vende with str(val(vendedorx),5),;
            mobservaci with c.obsped,;
            cnombre_cl with c.nomclie,;
            nmonto_t with c.subped-c.descped,;
            corden_com with c.ordcomp
    select d
    set filter to c.numped = numped
    goto top
    do while !eof()
      select b
      append blank
      replace cid_pedido with str(val(c.numped),8),;
      		  cid_produc with d.codprod,;
      		  ncantidad with val(d.canprod),;
      		  nprecio with d.precio,;
      		  nmonto with d.subtotal-d.descuento,;
      		  ndescuento with d.pordesc
      select d
      skip
    enddo
    select c
    replace syncok with "1"
    skip
enddo                
close all
*WAIT "Transferidos en forma exitosa: "+ALLTRIM(STR(pedidos))+" pedidos" TIMEOUT 2
**MESSAGEBOX("Transferidos en forma exitosa: "+ALLTRIM(STR(pedidos))+" pedidos")
PCESTADORECIBE= "Transferidos en forma exitosa: "+ALLTRIM(STR(pedidos))+" pedidos " + TTOC(DATETIME())
USE (ADDBS(JUSTPATH(JUSTPATH(SYS(16))))+"data\respaldos") IN 0 SHARED
USE (ADDBS(JUSTPATH(JUSTPATH(SYS(16))))+"data\empresas") IN 0 SHARED
USE (PCRUTABDSISTEMA+"tempresas") IN 0 shared

SELECT empresas
GO lnrecno
ON ERROR 