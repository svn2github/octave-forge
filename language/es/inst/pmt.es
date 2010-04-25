md5="d225bb0025cf741a38889e2f077d3787";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} pmt (@var{r}, @var{n}, @var{a}, @var{l}, @var{method})
Retorna la cantidad de pagos periódicos necesarios para amortizar 
el préstamo de una cantidad con tasa de interés @var{r} en @var{n} periodos.

El argumento opcional @var{l} puede ser usado para especificar la suma 
total.

El argumento opcional @var{method} puede ser usado para especificar si 
los pagos son realizados al final (@var{"e"}, predetermiando) o al inicio 
(@var{"b"}) de cada periodo.
@seealso{pv, nper, rate}
@end deftypefn
