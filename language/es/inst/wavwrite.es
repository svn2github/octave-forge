md5="61d3528132eaf33d5756fd3f1612400f";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} wavwrite (@var{y}, @var{filename})
@deftypefnx {Archivo de función} {} wavwrite (@var{y}, @var{fs}, @var{filename})
@deftypefnx {Archivo de función} {} wavwrite (@var{y}, @var{fs}, @var{bits}, @var{filename})
Escribe @var{y} al archivo de audio RIFF/WAVE @var{filename} con 
tasa de muestreo @var{fs} y bits por muestra @var{bits}. La tasa 
de muestreo predetermianda es 8000 Hz con 16 bits por muestra. Cada 
columna de los datos representa un canal separado.
@seealso{wavread}
@end deftypefn
