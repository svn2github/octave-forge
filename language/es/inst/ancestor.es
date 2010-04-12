md5="caf06de3d9e4dda178fafb84bcf4f7b9";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{parent} =} ancestor (@var{h}, @var{type})
@deftypefnx {Archivo de funci@'on} {@var{parent} =} ancestor (@var{h}, @var{type}, 'toplevel')
Retorna el primer antepasado del manejador de objetos @var{h} cuyo tipo corresponde 
con @var{type}, donde @var{type} es una cadena de catacteres. Si @var{type} es un
arreglo de c@'elulas de cadenas, retorna el primer padre cuyo tipo coincide con 
cualquiera de los tipos de cadena dados.

Si el manejador de objetos @var{h} es de tipo @var{type}, returna @var{h}.

Si @code{"toplevel"} es dado como un tercer argumento, returna el m@'as alto
padre en la jerarqu@'ia de objetos que coincide con la condici@'on, en lugar
del primero (el m@'as cercano).
@seealso{get, set}
@end deftypefn
