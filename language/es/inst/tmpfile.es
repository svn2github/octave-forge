md5="73f44ff761756c43e28d95c415fcf76f";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{fid}, @var{msg}] =} tmpfile ()
Retorna el identificador del archivo correspondiente al archivo temporal 
nuevo con un nombre @'unico. El archivo se abre en modo binario de lectura 
y escritura (@code{"w+b"}). El archivo ser@'a borrado autom@'aticamente 
cuando se cierra o cuando de sale de Octave.

Si la ejecunci@'on es exitosa, la variable @var{fid} es un identiicador 
v@'alido de archivo y @var{msg} es una cadena vacia. En otro caso, @var{fid} 
es -1 y @var{msg} contiene un mensaje de error dependiente del sistema. 
@seealso{tmpnam, mkstemp, P_tmpdir}
@end deftypefn
