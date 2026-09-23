<?php

header('Content-Type: application/json');
include(dirname(__FILE__)."/../Librerias/misclases.php");
$listado= new articulo();

$productos=$listado->productos_webservicesopencart();
/*echo "1";
$productos=$listado->productos_webservicesopencart(1501,3000,2);
echo "2";
$productos=$listado->productos_webservicesopencart(3001,4500,3);
echo "3";
$productos=$listado->productos_webservicesopencart(4501,6000,4);
echo "4";*/
?>