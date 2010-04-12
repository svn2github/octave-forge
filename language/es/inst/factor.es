md5="412b2d942ae9a3eb076867c03606db8c";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{p} =} factor (@var{q})
@deftypefnx {Archivo de funci@'on} {[@var{p}, @var{n}] =} factor (@var{q})

Retorna las factores primos de @var{q}. Esto es @code{prod (@var{p})
== @var{q}}. Si @code{@var{q} == 1}, retorna 1. 

Con dos argumentos de salida, retorna los primos @'unicos @var{p} y 
sus m@'ultiplos. Esto es @code{prod (@var{p} .^ @var{n}) ==
@var{q}}.

@end deftypefn
