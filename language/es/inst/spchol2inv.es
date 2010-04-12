md5="5e4979a846ab6a0031ca61567df84a39";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} spchol2inv (@var{u})
Invierte una matriz cuadrada dispersa sim@'etrica, positiva definida a 
partir de su factorizaci@'on de Cholesky, @var{u}. N@'otese que @var{u} 
deberia ser una matriz triangular superior con elementos positivos en la 
diagonal. 

@code{chol2inv (@var{u})} provee @code{inv (@var{u}'*@var{u})} pero 
es m@'as r@'apido usando @code{inv}.
@seealso{spchol, spcholinv}
@end deftypefn
