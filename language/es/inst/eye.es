md5="0b47197f44d3439741e5f35a6f7cc87d";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} eye (@var{x})
@deftypefnx {Función incorporada} {} eye (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} eye (@dots{}, @var{class})
Retorna una matriz identidad. Si se invoca con un único arumento escalar, 
@code{eye} retorna una matriz cuadrada con la dimensión especificada. Si se 
suministran dos argumentos escalares, @code{eye} los toma como el número de 
filas y columnas respectivamente. Si se suministra un vector con dos elementos, @code{eye} use 
los valores de los elementos como el número de filas y columnas, respectivamente. 
Por ejemplo, 

@example
@group
eye (3)
     @result{}  
		 1  0  0
         0  1  0
         0  0  1
@end group
@end example

Todas las siguientes producen el mismo resultado: 

@example
@group
eye (2)
@equiv{}
eye (2, 2)
@equiv{}
eye (size ([1, 2; 3, 4])
@end group
@end example

El argumento opcional @var{class}, le permite a @code{eye} retornar un arreglo del 
tipo especificado, por ejemplo 

@example
val = zeros (n,m, "uint8")
@end example

Invocando @code{eye} sin argumentos es equivalente a llamarla con 1  
como argumento.  Esta definición es dada para ofrecer compatibilidad 
con @sc{Matlab}.
@end deftypefn
