md5="57258f1a459cbdecb934f07f577a1ccc";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} quad_options (@var{opt}, @var{val})
Cuando se llama con dos argumentos, permite establecer las opciones 
de los parámetros de la función @code{quad}.

Dado un argumento, @code{quad_options} retorna el valor de la opción
correspondiente. Si no se suministran argumentos, se muestran los nombres 
de todas las opciones disponibles y sus valores actuales.

Las opciones incluyen

@table @code
@item "absolute tolerance"
Tolerancia absoluta; puede ser cero para pruebas de error relativo puro.
@item "relative tolerance"
Tolerancia relativa no negativa. Si la tolerancia absoluta es cero,
la tolerancia relativa debe ser mayor o igual que @code{max (50*eps, 0.5e-28)}.
@end table
@end deftypefn