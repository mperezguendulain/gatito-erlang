<?php
	$fp = fopen("leer", "a+");
	fputs($fp, "\n".$_POST['col']);
	fclose($fp);	
?>