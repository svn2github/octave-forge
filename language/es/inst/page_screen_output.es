md5="90e4d9b25fa17569fb3993b9c1c9eac8";rev="6367";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} page_screen_output ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} page_screen_output (@var{new_val})
Consulta o establece el valor de la variable interna que controla si la 
salidas propuestas para la terminal, que son m@'as largas que una p@'agina, 
son enviadas al paginador. Esto permite mirar todo en un solo pantallazo a la 
vez. Algunos paginadores (tales como @code{less}---v@'ease @ref{Installation}) 
son capaces de moverse hacia atr@'as en la salida. 
@end deftypefn
