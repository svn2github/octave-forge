md5="13ed14d3b08b3a576c3bbb72ec68d1ab";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} keyboard (@var{prompt})
Esta funci@'on se usa para depuraci@'on sencilla.  Cuando se 
ejecuta la funci@'on @code{keyboard}, Octave imprime un prompt y espera 
por la respuesta del usuario. Entonces, las cadenas de entrada se evaluan y se 
imprimen los resultados. Estoa hace posible examinar los valores de las variables 
dentro de la funci@'on, y asignar nuevos valores a las variables. La funci@'on @code{keyboard} 
no retorna ning'un valor, y continua su ejecuci@'on hasta que el usario 
digita @samp{quit} o @samp{exit}.

Si se invoca @code{keyboard} sin argumentos, se usa el prompt 
predetermiandos @samp{debug> }.
@end deftypefn
