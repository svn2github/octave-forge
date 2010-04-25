md5="5e4979a846ab6a0031ca61567df84a39";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} spchol2inv (@var{u})
Invierte una matriz cuadrada dispersa simétrica, positiva definida a 
partir de su factorización de Cholesky, @var{u}. Nótese que @var{u} 
deberia ser una matriz triangular superior con elementos positivos en la 
diagonal. 

@code{chol2inv (@var{u})} provee @code{inv (@var{u}'*@var{u})} pero 
es más rápido usando @code{inv}.
@seealso{spchol, spcholinv}
@end deftypefn
