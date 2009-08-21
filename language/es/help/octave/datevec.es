md5="80fd5034e7f9358cdfb50b4951653053";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{v} =} datevec (@var{date})
@deftypefnx {Archivo de funci@'on} {@var{v} =} datevec (@var{date}, @var{f})
@deftypefnx {Archivo de funci@'on} {@var{v} =} datevec (@var{date}, @var{p})
@deftypefnx {Archivo de funci@'on} {@var{v} =} datevec (@var{date}, @var{f}, @var{p})
@deftypefnx {Archivo de funci@'on} {[@var{y}, @var{m}, @var{d}, @var{h}, @var{mi}, @var{s}] =} datevec (@dots{})
Convierte un n@'umero de fecha serial (v@'ease @code{datenum}) o cadena de fecha (v@'ease 
@code{datestr}) en un vector fecha.

Un vector fecha es un vector con seis elementos, representando el a@~{n}o,
mes, d@'ia, hora, minutos, y segundos respectivamente.

El par@'ametro @var{f} es la cadena de formato usada para interpretar las cadenas de fechas 
(v@'ease @code{datestr}).

El par@'ametro @var{p} es el a@~{n}o al inicio del siglo en el cual el a@~{n}o de dos d@'igitos 
sera interpretado. Si no se especifica, se inicializa con el a@~{n}o actual menos 50.
@seealso{datenum, datestr, date, clock, now}
@end deftypefn
