md5="80fd5034e7f9358cdfb50b4951653053";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{v} =} datevec (@var{date})
@deftypefnx {Archivo de función} {@var{v} =} datevec (@var{date}, @var{f})
@deftypefnx {Archivo de función} {@var{v} =} datevec (@var{date}, @var{p})
@deftypefnx {Archivo de función} {@var{v} =} datevec (@var{date}, @var{f}, @var{p})
@deftypefnx {Archivo de función} {[@var{y}, @var{m}, @var{d}, @var{h}, @var{mi}, @var{s}] =} datevec (@dots{})
Convierte un número de fecha serial (véase @code{datenum}) o cadena de fecha (véase 
@code{datestr}) en un vector fecha.

Un vector fecha es un vector con seis elementos, representando el a@~{n}o,
mes, día, hora, minutos, y segundos respectivamente.

El parámetro @var{f} es la cadena de formato usada para interpretar las cadenas de fechas 
(véase @code{datestr}).

El parámetro @var{p} es el a@~{n}o al inicio del siglo en el cual el a@~{n}o de dos dígitos 
sera interpretado. Si no se especifica, se inicializa con el a@~{n}o actual menos 50.
@seealso{datenum, datestr, date, clock, now}
@end deftypefn
