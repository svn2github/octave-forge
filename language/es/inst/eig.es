md5="83e1ee77b0d12c618f0a78dc57045757";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{lambda} =} eig (@var{a})
@deftypefnx {Función cargable} {[@var{v}, @var{lambda}] =} eig (@var{a})
Calcula las valores propios (y vectores propios) de una matriz mediante un 
proceso de múltiples pasos los cuales inician con la factorización de Hessenberg, 
seguido por la factorización de Schur, en este punto los valores propios son aparentes. 
Los valores propios, cuando se necesitan, se calculan mediante manipulaciones posteriores 
de la factorización de Schur.

Los valores propios retornados por by @code{eig} no están ordenados.
@end deftypefn
