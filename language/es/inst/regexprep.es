-*- texinfo -*-
@deftypefn {Archivo de funci@'on}  @var{string} = regexprep(@var{string}, @var{pat}, @var{repstr}, @var{options})
Remplace los encuentros de @var{pat} en @var{string} con @var{repstr}.

El reemplazo puede contener @code{$i}, que sustituye para el 
i-ésimo grupo de paréntesis en la cadena de búsqueda. Por ejemplo,

@example

   regexprep("Bill Dunn",'(\w+) (\w+)','$2, $1')

@end example
retorna "Dunn, Bill"

@var{options} puede ser cero o más de
@table @samp

@item once
Remplace sólo la primera aparición de @var{pat} en el resultado.

@item warnings
Esta opción está presente por compatibilidad, pero se ignora

@item ignorecase or matchcase
Ignorar mayúsculas y minúsculas para la comparación de patrones 
(ver @code{regexpi}).
Como alternativa, use (?i) o (?-i) en el patrón.

@item lineanchors and stringanchors
Si los caracteres ^ y $ coinciden con el comienzo y el final de las 
líneas.
Como alternativa, el uso (?m) o (?-m) en el patrón.

@item dotexceptnewline and dotall
Si. coincide con saltos de línea en la cadena.
Como alternativa, el uso (? S) o (?-S) del patrón.

@item freespacing or literalspacing
Si los espacios en blanco y los comentarios # puede ser usado para hacer
la expresión regular más legible.
Como alternativa, el uso (? X) o (?-X) en el patrón.

@end table
@seealso{regexp,regexpi}
@end deftypefn
