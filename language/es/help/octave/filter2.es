md5="e30bb92dcb24448903d385d65cce8caa";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{y} =} filter2 (@var{b}, @var{x})
@deftypefnx {Archivo de funci@'on} {@var{y} =} filter2 (@var{b}, @var{x}, @var{shape})
Aplica el filtro FIR de dos dimensiones @var{b} sobre @var{x}. Si se 
especifica el argumento @var{shape}, retorna un arreglo de la forma deseada. 
Los posibles valores son: 

@table @asis
@item 'full'
completa @var{x} con ceros en todos los lados antes de aplicar el filtro.
@item 'same'
unpadded @var{x} (predetermiando)
@item 'valid'
recorta @var{x} despu@'es de filtrar de tal forma que los efectos de 
los bordes no son incluidos.
@end table

N@'otese que esta es una variaci@'on de la convoluci@'on, con los par@'ametros 
invertidos y @var{b} rotado 180 grados. 
@seealso{conv2}
@end deftypefn
