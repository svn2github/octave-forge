md5="8c82cc510fff5118469183db122c95a4";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} arma_rnd (@var{a}, @var{b}, @var{v}, @var{t}, @var{n})
Retorna una simulación del modelo ARMA

@example
x(n) = a(1) * x(n-1) + ... + a(k) * x(n-k)
     + e(n) + b(1) * e(n-1) + ... + b(l) * e(n-l)
@end example

@noindent
donde @var{k} es la longitud del vector @var{a}, @var{l} es la
longitud del vector @var{b} y @var{e} es ruido blanco gaussiano con
varianza @var{v}. La función retorna un vector de longitud @var{t}.

El parámetro opcional @var{n} proporciona el número de muestras
@var{x}(@var{i}) usado para la inicialización, p.e., una secuencia de longitud
@var{t}+@var{n} es generada y @var{x}(@var{n}+1:@var{t}+@var{n})
es retornada. Si @var{n} es omitido, @var{n} = 100 es usado. 
@end deftypefn
