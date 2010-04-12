md5="f2bb2403d8de959b56f1780b0167c43e";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cplxpair (@var{z}, @var{tol}, @var{dim})
Ordena las n@'umeros @var{z} en parejas de complejos conjugados ordenados por
la parte real en forma ascendente. Con partes reales id@'enticas, ordena por magnitud 
imaginaria ascendente. Ubica el n@'umero complejo imaginario negativo
primero dentro de cada pareja. Ubica todos los n@'umeros reales despu@'es de todas las
parejas complejas (aquellas con @code{abs (imag (@var{z}) / @var{z}) < 
@var{tol})}, donde el vaor predeterminado de @var{tol} is @code{100 * 
@var{eps}}.

En forma predeterminada, las parejas complejas se ordenan a lo largo de la primer 
dimensi@'on no unitaria @var{z}. Si se especifica @var{dim}, las parejas complejas
se orderan a lo largo de esta dimensi@'on.

Produce un error si algunos n@'umeros complejos no pudieran ser emparejados. Requiere
que todos los  n@'umeros complejos sean conjugado exactos dentro de @var{tol}, o produce 
un error. N@'otese que no hay garant@'ia en el orden de las parejas retornadas 
con partes reales id@'enticas y partes imaginarias diferentes.

@c Usando 'smallexample' para hacer que el texto se ajuste dentro de la p@'agina 
cuando se usa 'smallbook'
@smallexample
cplxpair (exp(2i*pi*[0:4]'/5)) == exp(2i*pi*[3; 2; 4; 1; 0]/5)
@end smallexample
@end deftypefn
