md5="9de6b49442dc6041b454ef9a6671f464";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} mktime (@var{tm_struct})
Convierte una estructura de tiempo correspondiente al tiempo local 
al número de segundos desde la época. Por ejemplo, 

@example
@group
mktime (localtime (time ())
     @result{} 856163706
@end group
@end example
@seealso{strftime, strptime, localtime, gmtime, time, now, date, clock, datenum, datestr, datevec, calendar, weekday}
@end deftypefn
