var alias,turno=0,ansBef;
var interval = setInterval(leer,500);

function leer()
{
	$.ajax({
		data: null,
		method: 'post',
		url: 'php/Pleer.php',
		success: function( response )
		{
			//alert(response);
			if (response != 'false')
				if( response == 'g' || response == 'p' || response == 'e'  )
				{
					clearInterval(interval);
					alert(fin(response));
					$('#reset').html("<label>Desea jugar de nuevo: </label><button type = 'button' onClick = 'resetgame(\"s\")'>SI</button> <button type = 'button' onClick = 'resetgame(\"n\")'>NO</button>");
				}
				else
					if(response == 'o' || response == 'x')
					{
						$('#turno').html('');
						alias=response;
						if(alias == 'x')
						{
							turno = 1;
							$('#turno').html('<label class = "tira">Tu turno<label>');
						}
						else
							$('#turno').html('<label class = "espera">Turno del oponente<label>');
					}
					else
						if( ansBef!=response && turno == 0)
						{
							ansBef = response;
							pinta(oponente(alias),response);
							$('#turno').html('<label class = "tira">Tu turno<label>');
							turno=1;	
						}
		}
	});
}

function resetgame(ans)
{
	$('#reset').html("");
	var data = { 
			col : ans
		};
		$.ajax({
			data: data,
			method: 'post',
			url: 'php/Pescribir.php',
		});
	if(ans == 's')
		javascript:location.reload();
}

function fin(l)
{
	if( l == 'g' )
		return 'Felicidades has ganado';
	if( l == 'e' )
		return 'Empataste';
	return 'Perdiste';
}

function oponente(sim)
{
	if(sim == 'x')
		return 'o';
	return 'x';
}

function pinta(alias,col)
{
	$('#c'+col).html(alias);
}

function clic(elemento)
{
	//alert(turno);
	if(turno == 1)
	{
		turno=0;
		pinta(alias,elemento)
		$('#turno').html('<label class = "espera">Turno del oponente<label>');
		var data = { 
			'col' : elemento
		};
		$.ajax({
			data: data,
			method: 'post',
			url: 'php/Pescribir.php',
		});
	}
}