md5="54db6077201efd3328bec3728ca3cb95";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} fsolve_options (@var{opt}, @var{val})
Cuando se llama con dos argumentos, esta fución permite establecer los 
parámetros opcionales de la función @code{fsolve}. Dado un argumento, 
@code{fsolve_options} retorna los valores de la opción correspondiente. 
Si no se suministran argumentos, se muestran los nombres de todas las opciones 
disponibles y sus valores actuales.

Las opciones incluyen

@table @code
@item "tolerance"
Tolerancia relativa no negativa.
@end table
@end deftypefn
