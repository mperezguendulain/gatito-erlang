% Autores:
% 	-Martín Alejandro Pérez Guendulain
%		-mixtecalex@gmail.com
%	-Ángel Ortiz Olivera
%		-zero_qosmio@hotmail.com


-module (gatito).
-export ([start_servidor/0, serv/1, start_gato/0, cliente/4, dibuja_gato/1, getElemOfListByIndex/2, putValueInListByIndex/3, buscaGanador/2]).

% ----------------------------------------
start_servidor() ->
	register(servidor, spawn(gatito, serv, [[]])).

serv(Ls) ->
	receive
		{ eliminarJugadores } ->
			serv([]);
		{enviarTiro, NumCelda, NumJugador} ->
			[Jugador1|Cuerpo] = Ls,
			[Jugador2 | _] = Cuerpo,
			PidJug1 = element(2, Jugador1),
			PidJug2 = element(2, Jugador2),
			if
				NumJugador == 1 ->
					PidJug2 ! {actualizarMtz, NumCelda};
				NumJugador == 2 ->
					PidJug1 ! {actualizarMtz, NumCelda}
			end,
			serv(Ls);
		{agregar, Cliente_PID} ->
			LongList = length(Ls),
			if
				LongList == 0 ->
					ListUsuarios = Ls++[{x,Cliente_PID}],
					Cliente_PID ! {registroExitoso, {"Esperando al jugador 2, tu simbolo es: x ...~n", 1, x}};
				LongList == 1 ->
					ListUsuarios = Ls++[{o,Cliente_PID}],
					[Jugador1 | _Jugador2] = ListUsuarios,
					Cliente_PID ! {registroExitoso, {"Eres el jugador 2, el juego inicia con el jugador 1, tu simbolo es: o.~n", 2, o}},
					element(2, Jugador1) ! {tirar}
			end,
			io:format("Lista actual: ~p  ~n", [ListUsuarios]),
			serv(ListUsuarios)
	end.

cliente(Servidor_Node, Personaje, MtzGato, NumJugador) ->
	receive
		{agregar} ->
			{servidor, Servidor_Node} ! {agregar, self()},
			cliente(Servidor_Node, Personaje, MtzGato, NumJugador);
		{registroExitoso, {Mensaje, NumJug, Alias}} ->
			if
				Alias == o ->
					escribeDatosEnArchivo("escribir", Alias);
				true ->
					ok
			end,
			clear(),
			print_titulo(),
			io:format(Mensaje),
			cliente(Servidor_Node, Alias, MtzGato, NumJug);
		{tirar} ->
			escribeDatosEnArchivo("escribir", Personaje),
			NumCelda = getNumCelda(MtzGato),
			%dibuja_gato(MtzGato),
			% NumCelda = leeNumCelda(MtzGato),			
			MtzGatoTemp = putValueInListByIndex(MtzGato, NumCelda, Personaje),
			dibuja_gato(MtzGatoTemp),
			io:format("Esperando a que el otro jugador tire...~n~n"),
			{servidor, Servidor_Node} ! {enviarTiro, NumCelda, NumJugador},
			cliente(Servidor_Node, Personaje, MtzGatoTemp, NumJugador);
		{actualizarMtz, NumCelda} ->
			PersonajeTemp = getPersonajeOtro(Personaje),
			escribeDatosEnArchivo("escribir", NumCelda),
			MtzGatoTemp = putValueInListByIndex(MtzGato, NumCelda, PersonajeTemp),
			Gano = buscaGanador(MtzGatoTemp, PersonajeTemp),
			Empato = empate(MtzGatoTemp),
			dibuja_gato(MtzGatoTemp),
			if
				Gano == true ->
					escribeDatosEnArchivo("escribir", p),
					print_perdiste(),
					reiniciarOTerminar(Servidor_Node, self());
				Empato == true ->
					escribeDatosEnArchivo("escribir", e),
					print_empate(),
					reiniciarOTerminar(Servidor_Node, self());
				true ->
					NumCeldaActual = getNumCelda(MtzGatoTemp),
					% NumCeldaActual = leeNumCelda(MtzGatoTemp),
					MtzGatoTemp2 = putValueInListByIndex(MtzGatoTemp, NumCeldaActual, Personaje),
					dibuja_gato(MtzGatoTemp2),
					GanoActual = buscaGanador(MtzGatoTemp2, Personaje),
					EmpatoActual = empate(MtzGatoTemp2),
					{servidor, Servidor_Node} ! {enviarTiro, NumCeldaActual, NumJugador},
					if
						GanoActual == true ->
							escribeDatosEnArchivo("escribir", g),
							print_ganaste(),
							reiniciarOTerminar(Servidor_Node, self());
						EmpatoActual == true ->
							escribeDatosEnArchivo("escribir", e),
							print_empate(),
							reiniciarOTerminar(Servidor_Node, self());
						true ->
							io:format("Esperando a que el otro jugador tire...~n~n"),
							cliente(Servidor_Node, Personaje, MtzGatoTemp2, NumJugador)
					end
			end
	end.

start_gato() ->
	io:format("Bienvenido.~n"),

	{ok, Servidor_Node} = io:fread("Servidor: ","~s"),
	NodoServidor = list_to_atom(lists:flatten(Servidor_Node)),
	register(interface,spawn(gatito, cliente, [NodoServidor, w, [0, 1, 2, 3, 4, 5, 6, 7, 8], 0])),
	interface ! { agregar}.

reiniciarOTerminar(Servidor_Node, PidJugador) ->
	{servidor, Servidor_Node} ! { eliminarJugadores },
	JugarOtraVes = jugarDeNuevo(),
	if
		JugarOtraVes == true ->
			reiniciarJuego(Servidor_Node, PidJugador);
		true ->
			ok
	end.

reiniciarJuego(Servidor_Node, PidJugador) ->
	{servidor, Servidor_Node} ! {agregar, PidJugador},
	cliente(Servidor_Node, w, [0, 1, 2, 3, 4, 5, 6, 7, 8], 0).


jugarDeNuevo() ->
	JugarOtraVes = getJugarOtraVes(),
	if
		JugarOtraVes == s ->
			true;
		JugarOtraVes == n ->
			false;
		true ->
			jugarDeNuevo()
	end.

print_titulo() ->
	io:format("              ________        __  .__  __                      
  /\\|\\/\\     /  _____/_____ _/  |_|__|/  |_  ____     /\\|\\/\\   
 _)    (__  /   \\  ___\\__  \\\\   __\\  \\   __\\/  _ \\   _)    (__ 
 \\_     _/  \\    \\_\\  \\/ __ \\|  | |  ||  | (  <_> )  \\_     _/ 
   )    \\    \\______  (____  /__| |__||__|  \\____/     )    \\  
   \\/\\|\\/           \\/     \\/                          \\/\\|\\/  ~n~n").


print_ganaste() ->
	io:format("               ________________
              |                |_____    __
              |  Has Ganado!   |     |__|  |_________
              |________________|     |::|  |        /
 /\\**/\\       |                \\.____|::|__|      <
( o_o  )_     |                      \\::/  \\._______\\
 (u--u   \\_)  |
  (||___   )==\\
,dP\"/b/=( /P\"/b\\
|8 || 8\\=== || 8
`b,  ,P  `b,  ,P
  \"\"\"`     \"\"\"`~n~n").

print_perdiste() ->
	io:format("__________                 .___.__          __                       
\\______   \\ ___________  __| _/|__| _______/  |_  ____               
 |     ___// __ \\_  __ \\/ __ | |  |/  ___/\\   __\\/ __ \\              
 |    |   \\  ___/|  | \\/ /_/ | |  |\\___ \\  |  | \\  ___/              
 |____|    \\___  >__|  \\____ | |__/____  > |__|  \\___  >  /\\  /\\  /\\ 
               \\/           \\/         \\/            \\/   \\/  \\/  \\/ ~n~n").

print_empate() ->
	io:format("___________                     __                       
\\_   _____/ _____ ___________ _/  |_  ____               
 |    __)_ /     \\\\____ \\__  \\\\   __\\/ __ \\              
 |        \\  Y Y  \\  |_> > __ \\|  | \\  ___/              
/_______  /__|_|  /   __(____  /__|  \\___  >  /\\  /\\  /\\ 
        \\/      \\/|__|       \\/          \\/   \\/  \\/  \\/ ~n~n").

getPersonajeOtro(Personaje) ->
	if
		Personaje == x ->
			o;
		Personaje == o ->
			x;
		true ->
			io:format("Error: ~p", [Personaje])
	end.
% ----------------------------
clear() ->
	io:format(os:cmd("clear")).

dibuja_gato(List) ->
	clear(),
	print_titulo(),
	print_gato(List, 0).

print_gato([], _) -> ok;
print_gato([Cabeza|Cuerpo], Index) ->
	if
		(Index == 0) or (Index == 1) or (Index == 3) or (Index == 4) or (Index == 6) or (Index == 7) ->
			io:format(" ~p |", [Cabeza]);
		(Index == 2) or (Index == 5) ->
			io:format(" ~p~n", [Cabeza]),
			io:format("___ ___ ___~n");
		(Index == 8) ->
			io:format(" ~p~n~n", [Cabeza])
	end,
	print_gato(Cuerpo, Index + 1).


empate([]) ->
	true;
empate([Cabeza|Cuerpo]) ->
	if
		Cabeza == x ->
			empate(Cuerpo);
		Cabeza == o ->
			empate(Cuerpo);
		true ->
			false
	end.
	



getElemOfListByIndex(List, Index) ->
	getElemOfListByIndexAux(List, Index, 0).

getElemOfListByIndexAux([Cabeza|_Cuerpo], Index, IndexActual) when Index == IndexActual ->
	Cabeza;
getElemOfListByIndexAux([_Cabeza|Cuerpo], Index, IndexActual) ->
	getElemOfListByIndexAux(Cuerpo, Index, IndexActual + 1).




putValueInListByIndex(List, Index, Value) ->
	lists:sublist(List, Index) ++ [Value] ++ lists:nthtail(Index + 1, List).

leeNumCelda(Ls) ->
	{ok, [NumCelda]} = io:fread("Numero de celda: ","~d"),
	Validado = validaNumCel(Ls,NumCelda),
	if
		Validado == true ->
			NumCelda;
		true ->
			leeNumCelda(Ls)
	end.


validaNumCel(Ls,Pos)->
	if
		Pos < 0 ->
			false;
		Pos > 8 ->
			false;
		true ->
			Elemento = getElemOfListByIndex(Ls,Pos),
			if
				Elemento == Pos ->
					true;
				true ->
					false
			end
	end.

buscaGanador(List, Personaje) ->
	Pos0 = getElemOfListByIndex(List, 0),
	Pos1 = getElemOfListByIndex(List, 1),
	Pos2 = getElemOfListByIndex(List, 2),
	Pos3 = getElemOfListByIndex(List, 3),
	Pos4 = getElemOfListByIndex(List, 4),
	Pos5 = getElemOfListByIndex(List, 5),
	Pos6 = getElemOfListByIndex(List, 6),
	Pos7 = getElemOfListByIndex(List, 7),
	Pos8 = getElemOfListByIndex(List, 8),

	if
		% Buscando en Horizontal
		(Pos0 == Personaje) and (Pos1 == Personaje) and (Pos2 == Personaje) ->
			true;
		(Pos3 == Personaje) and (Pos4 == Personaje) and (Pos5 == Personaje) ->
			true;
		(Pos6 == Personaje) and (Pos7 == Personaje) and (Pos8 == Personaje) ->
			true;
		% Buscando en Vertial
		(Pos0 == Personaje) and (Pos3 == Personaje) and (Pos6 == Personaje) ->
			true;
		(Pos1 == Personaje) and (Pos4 == Personaje) and (Pos7 == Personaje) ->
			true;
		(Pos2 == Personaje) and (Pos5 == Personaje) and (Pos8 == Personaje) ->
			true;
		% Buscando en Diagonal
		(Pos0 == Personaje) and (Pos4 == Personaje) and (Pos8 == Personaje) ->
			true;
		(Pos6 == Personaje) and (Pos4 == Personaje) and (Pos2 == Personaje) ->
			true;
		% Sino encuentra ganador entonces retorna false
		true ->
			false
	end.

getJugarOtraVes() ->
	StrJugarOtraVes = getUltimaLinea("leer"),
	JugarOtraVes = list_to_atom(lists:flatten(StrJugarOtraVes)),
	if
		(JugarOtraVes == s) or (JugarOtraVes == n) ->
			JugarOtraVes;
		true ->
			getJugarOtraVes()
	end.


getNumCelda(MtzGato) ->
	StrNumCelda = getUltimaLinea("leer"),
	NumCelda = element(1, string:to_integer(StrNumCelda)),
	io:format("~p", [NumCelda]),
	Validado = validaNumCel(MtzGato,NumCelda),
	if
		Validado == true ->
			NumCelda;
		true ->
			getNumCelda(MtzGato)
	end.

escribeDatosEnArchivo(File, StrDatos) ->
	case file:open(File, [append]) of
		{ok, Fd} ->
			io:format(Fd, "~n~p", [StrDatos]),
			file:close(Fd),
			{ok};
		{error, Motivo} ->
			{error, Motivo}
	end.

getUltimaLinea(File) ->
	leerArchivoLineaALinea(File).


leerArchivoLineaALinea(File) ->
	case file:open(File, read) of
		{ok, Fd} ->
			Linea = leer_texto_linea_a_linea(Fd, ""),
			file:close(Fd),
			Linea;
		{error, Motivo} ->
			{error, Motivo}
	end.

leer_texto_linea_a_linea(Fd, Linea) ->
	case io:get_line(Fd, '') of
		eof -> 
			if
				Linea == "" ->
					timer:sleep(150),
					leer_texto_linea_a_linea(Fd, Linea);
				true ->
					Linea
			end;
		{error, Motivo} -> 
			{error,Motivo};
		Texto ->
			leer_texto_linea_a_linea(Fd, Texto)
	end.