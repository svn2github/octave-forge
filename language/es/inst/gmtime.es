md5="ca741c581da89d432815103c2449df56";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} gmtime (@var{t})
Dado el valor retornado por @code{time} (o cualquier entero no negativo), 
retorna una estructura de tiempo correspondiente a CUT. Por ejemplo, 

@example
@group
gmtime (time ())
     @result{} @{
           usec = 0
           year = 97
           mon = 1
           mday = 17
           sec = 6
           zone = CST
           min = 15
           wday = 1
           hour = 7
           isdst = 0
           yday = 47
         @}
@end group
@end example
@seealso{strftime, strptime, localtime, mktime, time, now, date, clock, datenum, datestr, datevec, calendar, weekday}
@end deftypefn
