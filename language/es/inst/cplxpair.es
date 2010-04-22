md5="f2bb2403d8de959b56f1780b0167c43e";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cplxpair (@var{z}, @var{tol}, @var{dim})
Ordena las números @var{z} en parejas de complejos conjugados ordenados por
la parte real en forma ascendente. Con partes reales idénticas, ordena por magnitud 
imaginaria ascendente. Ubica el número complejo imaginario negativo
primero dentro de cada pareja. Ubica todos los números reales después de todas las
parejas complejas (aquellas con @code{abs (imag (@var{z}) / @var{z}) < 
@var{tol})}, donde el vaor predeterminado de @var{tol} is @code{100 * 
@var{eps}}.

En forma predeterminada, las parejas complejas se ordenan a lo largo de la primer 
dimensión no unitaria @var{z}. Si se especifica @var{dim}, las parejas complejas
se orderan a lo largo de esta dimensión.

Produce un error si algunos números complejos no pudieran ser emparejados. Requiere
que todos los  números complejos sean conjugado exactos dentro de @var{tol}, o produce 
un error. Nótese que no hay garantía en el orden de las parejas retornadas 
con partes reales idénticas y partes imaginarias diferentes.

@c Usando 'smallexample' para hacer que el texto se ajuste dentro de la página 
cuando se usa 'smallbook'
@smallexample
cplxpair (exp(2i*pi*[0:4]'/5)) == exp(2i*pi*[3; 2; 4; 1; 0]/5)
@end smallexample
@end deftypefn
