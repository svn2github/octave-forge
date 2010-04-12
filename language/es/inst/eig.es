md5="83e1ee77b0d12c618f0a78dc57045757";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{lambda} =} eig (@var{a})
@deftypefnx {Funci@'on cargable} {[@var{v}, @var{lambda}] =} eig (@var{a})
Calcula las valores propios (y vectores propios) de una matriz mediante un 
proceso de m@'ultiples pasos los cuales inician con la factorizaci@'on de Hessenberg, 
seguido por la factorizaci@'on de Schur, en este punto los valores propios son aparentes. 
Los valores propios, cuando se necesitan, se calculan mediante manipulaciones posteriores 
de la factorizaci@'on de Schur.

Los valores propios retornados por by @code{eig} no est@'an ordenados.
@end deftypefn
