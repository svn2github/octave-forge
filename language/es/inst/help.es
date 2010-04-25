md5="bd1e2d35d7ba5baa3bd4e18789b4ae26";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Comando} help
El comando @code{help} de Octave se puede utilizar para imprimir el uso
de breves mensajes de estilo, o para mostrar la información directamente
de una versión en línea del manual impreso, utilizando la Información
del navegador GNU. Si se invoca sin argumentos, @code{help} imprime una
lista de todos los operadores y funciones disponibles. Si el primer
argumento es @code{-i}, el comando @code{help} busca en el índice de la
versión en línea de este manual para los temas dados.

Por ejemplo, el comando @kbd{help help} imprime un mensaje breve que describe
comando @code{help}, y @kbd{help -i help} inicia en el navegador la 
información GNU en este nodo de la versión en línea del manual .

Una vez la Información GNU es ejecuta en navegador, la ayuda para el uso 
que está disponible utilizando el comando @kbd{C-h}.
@seealso{doc, which, lookfor}
@end deftypefn