<?php
include("../Librerias/misclases.php");
$listado= new clientes();
$clientes=$listado->clientes_webservices($_POST['id']);
//echo json_encode($clientes);
//$lista_clientes= new clientes();
?>