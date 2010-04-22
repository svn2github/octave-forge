md5="963de43c4fc949250e772a0cdd2c8650";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} chol2inv (@var{u})
Invierte una matrix simétrica positiva definida a partir de su 
factorización de Cholesky, @var{u}. Nótese que @var{u} debería ser 
una matriz triangular superior con elementos positivos en la diagonal.  
@code{chol2inv (@var{u})} suministra @code{inv (@var{u}'*@var{u})} pero es mas rápido que @code{inv}.
@seealso{chol, cholinv}
@end deftypefn
