md5="13bcf388e1187c59ba34ca1520017448";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} fflush (@var{fid})
Limpia la salida de @var{fid}. Esta funci@'on es @'util para asegurar que todas 
las salidas pendientes muestran su resultado en la pantalla antes de que ocurran 
otros eventos. Por ejemplo, siempre es buena idea limpiar la salida est@'andar 
antes de llamar @code{input}.

La funci@'on @code{fflush} retorna 0 si la ejecuci@'on es exitosa y valor de error
dependiente del sistema (@minus{}1 en unix) en caso de error.
@seealso{fopen, fclose}
@end deftypefn
