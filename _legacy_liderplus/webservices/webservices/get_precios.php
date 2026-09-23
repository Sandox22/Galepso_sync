<?php
include("../Librerias/misclases.php");
$listado= new articulo();
$productos=$listado->precios_webservices($_POST['id']);
?>