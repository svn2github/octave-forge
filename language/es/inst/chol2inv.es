md5="963de43c4fc949250e772a0cdd2c8650";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} chol2inv (@var{u})
Invierte una matrix sim@'etrica positiva definida a partir de su 
factorizaci@'on de Cholesky, @var{u}. N@'otese que @var{u} deber@'ia ser 
una matriz triangular superior con elementos positivos en la diagonal.  
@code{chol2inv (@var{u})} suministra @code{inv (@var{u}'*@var{u})} pero es mas r@'apido que @code{inv}.
@seealso{chol, cholinv}
@end deftypefn
