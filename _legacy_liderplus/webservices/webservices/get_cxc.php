<?php
include("../Librerias/misclases.php");
$listado= new cxc();
$cuentas=$listado->cxc_webservices($_POST['id']);
//echo json_encode($clientes);
//$lista_clientes= new clientes();
?>