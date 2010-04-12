md5="91c19f5519e9b4f45476a3054a6eca08";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{systype}, @var{nout}, @var{nin}, @var{ncstates}, @var{ndstates}] =} minfo (@var{inmat})
Determina el tipo de matriz del sistema. La variable @var{inmat} puede 
ser una variable, un sistema, una constante o una matriz vacia. 

@strong{Salidas}
@table @var
@item systype 
Puede ser: variable, sistema, constante, o vacio.
@item nout 
El n@'umero de salidas del sistema.
@item nin
El n@'umero de entradas del sistema.
@item ncstates
El n@'umero de estados continuos del sistema.
@item ndstates 
El n@'umero de discretos continuos del sistema.
@end table
@end deftypefn
