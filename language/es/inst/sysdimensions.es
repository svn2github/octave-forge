md5="00b76c3b80cc9603bdad20b05fa9b9a5";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{n}, @var{nz}, @var{m}, @var{p}, @var{yd}] =} sysdimensions (@var{sys}, @var{opt})
Regresa el número de estados, entradas, y/o salidas en el sistema
@var{sys}.

@strong{Entradas}
@table @var
@item sys
estructura de datos del sistema

@item opt
Cadena que indica cuáles son las dimensiones deseadas. Valores:

@table @code
@item "all"
(por defecto) regresa todos los parámetros que se especifican en las
salidas a continuación.

@item "cst"
regresa @var{n}= número de estados continuos

@item "dst"
regresa @var{n}= número de estados discretos

@item "in"
regresa @var{n}= número de entradas

@item "out"
regresa @var{n}= número de salidas
@end table
@end table

@strong{Salidas}
@table @var
@item  n
 número de estados continuos (o dimensión individual solicitada según lo 
especificado por @var{opt}).
@item  nz
 número de estados discretos
@item  m
 número de entradas del sistema
@item  p
 número de salidas del sistema
@item  yd
 Vector binario; @var{yd}(@var{ii}) es no cero si la salida @var{ii} es
 discreta.
@math{yd(ii) = 0} si la salida @var{ii} es continua
@end table
@seealso{sysgetsignals, sysgettsam}
@end deftypefn
