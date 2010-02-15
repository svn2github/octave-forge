md5="b410a0be83112b74841cb4a9370e8ef2";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{count}, @var{mean}, @var{var}] =} spstats (@var{s})
@deftypefnx {Archivo de funci@'on} {[@var{count}, @var{mean}, @var{var}] =} spstats (@var{s}, @var{j})
Regresa las estad@'isticas para los elementos distintos de cero de la
matrix dispersa @var{s}. @var{count} es el n@'umero de no-ceros en cada
columna. @var{mean} es el promedio de los no-ceros en cada columna, y
@var{var} es la varianza de los no-ceros en cada columna.

Al invocar la fuci@'on con dos argumentos de entrada, si @var{s} son los
datos y @var{j} es el n@'umero de ubicaci@'on de los datos, calcula las
estad@'isticas para cada ubicaci@'on. En este caso, la ubicaciones pueden
contener valores de datos de cero, mientras que @code{spstats (@var{s})}
los ceros pueden desaparecer.
@end deftypefn
