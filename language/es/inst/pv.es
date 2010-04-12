md5="c17855fc4a5f2946409806c0e4c612b2";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} pv (@var{r}, @var{n}, @var{p}, @var{l}, @var{method})

Retorna el valor presente de una inversi@'on que realizar@'a @var{p} pagos 
durante @var{n} periodos consecutivos, asumiendo una tasa de inter@'es @var{r}.

El argumento opcional @var{l} puede ser usado para especificar el un pago 
adicional realizado al final de los @var{n} periodos.

El argumento opcional @var{method} puede ser usado para especificar si 
los pagos se realiazan al final (@code{"e"}, predeterminado) o al inicio 
(@code{"b"}) de cada periodo. 

N@'otese que la tasa @var{r} se especifica como una fracci@'on (p.e., 0.05,
no 5 por ciento).

@seealso{pmt, nper, rate, npv}
@end deftypefn
