<?php
	$fichero = "escribir";
	$filas = file($fichero);
	if(count($filas))
	{
		$fin = $filas[count($filas)-1];
		echo $fin;
		if( $fin == 'o' || $fin == 'x' || $fin == 'g' || $fin == 'e' || $fin == 'p')
		{
			$fp = fopen($fichero, "w+");
			fclose($fp);
		}
	}
	else
		echo 'false';
?>