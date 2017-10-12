# Tres en Linea (Gatito)

Juego de tres en linea desarrollado en erlang para la materia de sistemas distribuidos y paralelos.
Se tienen que copiar las carpetas gatito1 y gatito2 dentro de la carpeta htdocs y el servidor apache debde de estar levantado. También es necesario levantar el servidor y los clientes del lado de Erlang, esto se explica en la parte de Lanzar Aplicación.

![Juego](/juego.png)

![Juego Ganado](/juego-ganado.png)

## Lanzar Aplicación
----------
Lanzar el servidor:
Es necesario situarse dentro de la gatito1 o gatito2 ya que los dos contienen el código para levantar el servidor.

    erl -sname servidor
    c(gatito).
    gatito:star



Ejecutar Jugador 1:
Es necesario situarse dentro de la gatito1 para levantar el cliente 1.

    erl -sname jugador1
    c(gatito).
    gatito:start_gato().
    servidor@host_name

Ejecutar Jugador 2:
Es necesario situarse dentro de la gatito2 para levantar el cliente 2.

    erl -sname jugador2
    c(gatito).
    gatito:start_gato().
    servidor@host_name

![Servidor y clientes](/server-erlang.png)