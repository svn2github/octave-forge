md5="9ba7364850ba63d8c8f171d3eacb9086";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{val}, @var{count}] =} fscanf (@var{fid}, @var{template}, @var{size})
@deftypefnx {Función incorporada} {[@var{v1}, @var{v2}, @dots{}, @var{count}] = } fscanf (@var{fid}, @var{template}, "C")
En la primera forma, lee desde el archivo @var{fid} acorde con la plantilla @var{template},
retornado el resultado en la matriz @var{val}.

El argumento opcional @var{size} especifica la cantidad de datos a leer 
y puede ser una de las siguientes opciones:

@table @code
@item Inf
Lee tanto como es posible, retornando un vector columna.

@item @var{nr}
Lee hasta @var{nr} elementos, retornando un vector columna.

@item [@var{nr}, Inf]
Lee tanto como es posible, retornando una matriz de @var{nr} filas. Si el 
número de elementos leidos no es múltiplo exacto de @var{nr}, se completa 
la última columna con ceros.

@item [@var{nr}, @var{nc}]
Lee hasta @code{@var{nr} * @var{nc}} elementos, retornando una matriz de 
@var{nr} filas.  Si el número de elementos leidos no es múltiplo exacto 
de @var{nr}, se completa la última columna con ceros.
@end table

@noindent
Si se omite @var{size}, se asume el valor @code{Inf}.

Si @var{template} especifica solo conversiones de caracteres, retorna una 
cadena.

El número de elementos leidos exitosamente se retorna en @var{count}.

En la segunda forma, lee desde el archivo @var{fid} acorde con la plantilla @var{template},
aplicando la conversión especificada en @var{template} correspondiente a un 
valor escalar retornado. Esta forma es mas parecida a `C', y también 
compatible con versiones previas de Octave. El número de conversiones exitosas 
se retorna en @var{count}.
@ifclear OCTAVE_MANUAL

Véase la sección Formatted Input del manual de Octave para una 
descripción completa de la sintaxis de la cadena plantilla.
@end ifclear
@seealso{scanf, sscanf, fread, fprintf}
@end deftypefn
