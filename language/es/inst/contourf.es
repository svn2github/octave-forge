md5="8670a40a558773a9c9cf18583731e80c";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z}, @var{lvl})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z}, @var{n})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{z}, @var{n})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{z}, @var{lvl})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{z})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@var{ax}, @dots{})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contourf (@dots{}, @var{"property"}, @var{val})
Calcula y grafica contornos sólidos de la matriz @var{z}.
Los parámetros @var{x}, @var{y} y @var{n} o @var{lvl} son opcionales.

El valor retornado @var{c} es una matrix 2 por @var{n} que contiene las líneas 
de contorno en el siguiente formato:

@example
@var{c} = [lev1, x1, x2, ..., levn, x1, x2, ... 
     len1, y1, y2, ..., lenn, y1, y2, ...]
@end example

@noindent
en donde la línea de contorno @var{n} tiene un nivel (altura) @var{levn} y
longitud @var{lenn}.

El valor retornado @var{h} es una apuntador de vector al objecto creando el
contorno sólido.

Si @var{x} y @var{y} se omiten, son tomados como índices fila/columna
de @var{z}. @var{n} es un escalar que denota el número de líneas
a calcular. Alternativamente @var{lvl} es un vector que contiene los niveles 
de contorno. Si solo se necesita un valor (e.g. lvl0), establezca
@var{lvl} a [lvl0, lvl0].  Si se omite @var{n} o @var{lvl}, se asume 10 
como valor predeterminado de niveles de contorno.

Si se especifica, los contornos sólidos se agragan al objeto ejes
@var{ax} en lugar del eje actual.

El siuiente ejemplo grafíca contornos sólidos de la función @code{peaks}.
@example
[x, y, z] = peaks (50);
contourf (x, y, z, -7:9)
@end example
@seealso{contour, contourc, patch}
@end deftypefn
