md5="caf06de3d9e4dda178fafb84bcf4f7b9";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci�n} {@var{parent} =} ancestor (@var{h}, @var{type})
@deftypefnx {Archivo de funci�n} {@var{parent} =} ancestor (@var{h}, @var{type}, 'toplevel')
Retorna el primer antepasado del apuntador de objetos @var{h} cuyo tipo corresponde 
con @var{type}, donde @var{type} es una cadena de catacteres. Si @var{type} es un
arreglo de c�lulas de cadenas, retorna el primer padre cuyo tipo coincide con 
cualquiera de los tipos de cadena dados.

Si el apuntador de objetos @var{h} es de tipo @var{type}, returna @var{h}.

Si @code{"toplevel"} es dado como un tercer argumento, returna el m�s alto
padre en la jerarqu�a de objetos que coincide con la condici�n, en lugar
del primero (el m�s cercano).
@seealso{get, set}
@end deftypefn
