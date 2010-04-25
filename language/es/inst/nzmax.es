md5="446abb865fe5d87c68e595bf88d13724";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{scalar} =} nzmax (@var{SM})
Retorna la cantidad de memoria alojada para la matriz dispersa @var{SM}. 
Nótese que Octave tiende a recortar la memoria no utilizada a la primera 
oportunidad para objetos dispersos. Existen algunos objetos dispersos creados 
por el usuario en donde el valor retornado por @dfn{nzmaz} no es el mismo que 
el retornado por @dfn{nnz}, pero en general, las funciones retornan el mismo 
resultado.
@seealso{sparse, spalloc}
@end deftypefn
