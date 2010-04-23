md5="a1a48f0ed2f8cea102d91e1bab1e6008";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} datenum (@var{year}, @var{month}, @var{day})
@deftypefnx {Archivo de función} {} datenum (@var{year}, @var{month}, @var{day}, @var{hour})
@deftypefnx {Archivo de función} {} datenum (@var{year}, @var{month}, @var{day}, @var{hour}, @var{minute})
@deftypefnx {Archivo de función} {} datenum (@var{year}, @var{month}, @var{day}, @var{hour}, @var{minute}, @var{second})
@deftypefnx {Archivo de función} {} datenum (@code{"date"})
@deftypefnx {Archivo de función} {} datenum (@code{"date"}, @var{p})
Retorna la fecha especificada como el número del dia, en donde Ene 1, 0000
es el dia 1. De esta forma, Ene 1, 1970 es número de dia 719529.  
La porción fracionaria, @var{p}, corresponde a la porción del 
dia especificado.

Notas:

@itemize
@item
Los a@~{n}os pueden ser negativos y/o fracciones.
@item
Los meses inferiores a 1 son considerados como Enero.
@item
Los dias del mes comienzan en 1.
@item
Los dias posteriores al fin de mes se consideran en el mes subsecuente.
@item
Los dias antes del inicio del mes se consideran en el mes previo.
@item
Los dias pueden ser fracciones.
@end itemize

@strong{Advertencia:} esta función no intenta maniular calendarios 
Julianos ya que fechas previas al 15 de Octubre de 1582 están 
corridas por 11 dias. También debe ser conciente que los paises 
Católicos Romanos adoptaron el calendario en 1582. Fue hasta 1924 
que se adoptó en todo el mundo. Véase el Calendario Gregoriano 
en Wikipedia para mas detalles.

@strong{Advertencia:} los saltos de seungos son ignorados. Una tabla de saltos de segundos 
está disponible en Saltos de segundos en Wikipedia.
@seealso{date, clock, now, datestr, datevec, calendar, weekday}
@end deftypefn
