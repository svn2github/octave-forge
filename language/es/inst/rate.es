md5="fa535e5da107161ad06404ac29ab5707";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} rate (@var{n}, @var{p}, @var{v}, @var{l}, @var{method})
Retorna la tasa de retorno para una inversión de valor presente @var{v}, 
la cual paga @var{p} en @var{n} periodos consecutivos.

El argumento opcional @var{l} se puede usar para especificar el pago total 
realizado al final de @var{n} periodos.

El argumento opcional de tipo cadena @var{method} puede ser usado para 
especificar si los pagos son realizados al final (@code{"e"}, predetermiando) 
o al inicio (@code{"b"}) de cada periodo.
@seealso{pv, pmt, nper, npv}
@end deftypefn
