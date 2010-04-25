md5="90e4d9b25fa17569fb3993b9c1c9eac8";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} page_screen_output ()
@deftypefnx {Función incorporada} {@var{old_val} =} page_screen_output (@var{new_val})
Consulta o establece el valor de la variable interna que controla si la 
salidas propuestas para la terminal, que son más largas que una página, 
son enviadas al paginador. Esto permite mirar todo en un solo pantallazo a la 
vez. Algunos paginadores (tales como @code{less}---véase @ref{Installation}) 
son capaces de moverse hacia atrás en la salida. 
@end deftypefn
