md5="26decc9125aa3048921937e83f9b71d9";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} nper (@var{r}, @var{p}, @var{a}, @var{l}, @var{method})

Retorna el n@'umero de pagos regulares de @var{p} necesarios para 
amortizar un pr@'estamo de valor @var{a} e inter@'es @var{r}.

El argumento opcional @var{l} puede ser unsado para especificar un pago 
adicional de @var{l} realizado al final del periodo de amortizaci@'on.

El argumento opcional @var{method} puede ser usado para especificar si 
los pagos son realizados al final (@var{"e"}, predeterminado) o al inicio 
(@var{"b"}) de cada periodo.

N@'otese que la tasa @var{r} se especifica como una fracci@'on (p.e., 0.05,
no 5 por ciento).

@seealso{pv, pmt, rate, npv}
@end deftypefn
