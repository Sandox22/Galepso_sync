<?php
include("../Librerias/misclases.php");
$listado= new articulo();
$productos=$listado->almacenes_webservices($_POST['id']);
?>