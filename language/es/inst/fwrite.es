md5="d90b85cff986d46a4bba06df857112db";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{count} =} fwrite (@var{fid}, @var{data}, @var{precision}, @var{skip}, @var{arch})
Escribe los datos @var{data} en formato binario de tipo @var{precision} en el 
archivo especificado @var{fid}, retornando el n@'umero de valores escritos exitosamente
en el archivo.

El argumento @var{data} es una matriz de valores que ser@'an escritos en 
el archivo. Los valores se extraen en sentido de las columnas.

Los argumentos restantes @var{precision}, @var{skip} y @var{arch} son 
opcionales, y son implementados como se describe en @code{fread}.

El comportamiento de @code{fwrite} es indefinido si los valores en @var{data} 
son m@'as grandes que la precisi@'on especificada.
@seealso{fread, fopen, fclose}
@end deftypefn
