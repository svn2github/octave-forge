-*- texinfo -*-
@deftypefn {Archivo de funci@'on}  @var{string} = regexprep(@var{string}, @var{pat}, @var{repstr}, @var{options})
Remplace los encuentros de @var{pat} en @var{string} con @var{repstr}.

El reemplazo puede contener @code{$i}, que sustituye para el 
i-�simo grupo de par�ntesis en la cadena de b�squeda. Por ejemplo,

@example

   regexprep("Bill Dunn",'(\w+) (\w+)','$2, $1')

@end example
retorna "Dunn, Bill"

@var{options} puede ser cero o m�s de
@table @samp

@item once
Remplace s�lo la primera aparici�n de @var{pat} en el resultado.

@item warnings
Esta opci�n est� presente por compatibilidad, pero se ignora

@item ignorecase or matchcase
Ignorar may�sculas y min�sculas para la comparaci�n de patrones 
(ver @code{regexpi}).
Como alternativa, use (?i) o (?-i) en el patr�n.

@item lineanchors and stringanchors
Si los caracteres ^ y $ coinciden con el comienzo y el final de las 
l�neas.
Como alternativa, el uso (?m) o (?-m) en el patr�n.

@item dotexceptnewline and dotall
Si. coincide con saltos de l�nea en la cadena.
Como alternativa, el uso (? S) o (?-S) del patr�n.

@item freespacing or literalspacing
Si los espacios en blanco y los comentarios # puede ser usado para hacer
la expresi�n regular m�s legible.
Como alternativa, el uso (? X) o (?-X) en el patr�n.

@end table
@seealso{regexp,regexpi}
@end deftypefn
