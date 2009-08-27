md5="8670a40a558773a9c9cf18583731e80c";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z}, @var{lvl})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z}, @var{n})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{z}, @var{n})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{z}, @var{lvl})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{z})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@var{ax}, @dots{})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contourf (@dots{}, @var{"property"}, @var{val})
Calcula y grafica contornos s@'olidos de la matriz @var{z}.
Los par@'ametros @var{x}, @var{y} y @var{n} o @var{lvl} son opcionales.

El valor retornado @var{c} es una matrix 2 por @var{n} que contiene las l@'ineas 
de contorno en el siguiente formato:

@example
@var{c} = [lev1, x1, x2, ..., levn, x1, x2, ... 
     len1, y1, y2, ..., lenn, y1, y2, ...]
@end example

@noindent
en donde la l@'inea de contorno @var{n} tiene un nivel (altura) @var{levn} y
longitud @var{lenn}.

El valor retornado @var{h} es una manejador de vector al objecto creando el
contorno s@'olido.

Si @var{x} y @var{y} se omiten, son tomados como @'indices fila/columna
de @var{z}. @var{n} es un escalar que denota el n@'umero de l@'ineas
a calcular. Alternativamente @var{lvl} es un vector que contiene los niveles 
de contorno. Si solo se necesita un valor (e.g. lvl0), establezca
@var{lvl} a [lvl0, lvl0].  Si se omite @var{n} o @var{lvl}, se asume 10 
como valor predeterminado de niveles de contorno.

Si se especifica, los contornos s@'olidos se agragan al objeto ejes
@var{ax} en lugar del eje actual.

El siuiente ejemplo graf@'ica contornos s@'olidos de la funci@'on @code{peaks}.
@example
[x, y, z] = peaks (50);
contourf (x, y, z, -7:9)
@end example
@seealso{contour, contourc, patch}
@end deftypefn
