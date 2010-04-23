md5="13ed14d3b08b3a576c3bbb72ec68d1ab";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} keyboard (@var{prompt})
Esta función se usa para depuración sencilla.  Cuando se 
ejecuta la función @code{keyboard}, Octave imprime un prompt y espera 
por la respuesta del usuario. Entonces, las cadenas de entrada se evaluan y se 
imprimen los resultados. Estoa hace posible examinar los valores de las variables 
dentro de la función, y asignar nuevos valores a las variables. La función @code{keyboard} 
no retorna ning'un valor, y continua su ejecución hasta que el usario 
digita @samp{quit} o @samp{exit}.

Si se invoca @code{keyboard} sin argumentos, se usa el prompt 
predetermiandos @samp{debug> }.
@end deftypefn
