md5="179003f179ef1cf48e01eb29ce8e8323";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{tsq}] =} hotelling_test_2 (@var{x}, @var{y})
For two samples @var{x} from multivariate normal distributions with
the same number of variables (columns), unknown means and unknown
equal covariance matrices, test the null hypothesis @code{mean
(@var{x}) == mean (@var{y})}.

Hotelling's two-sample @math{T^2} is returned in @var{tsq}.  Under the null,

@iftex
@tex
$$
{n_x+n_y-p-1) T^2 \over p(n_x+n_y-2)}
$$
@end tex
@end iftex
@ifnottex
@example
(n_x+n_y-p-1) T^2 / (p(n_x+n_y-2))
@end example
@end ifnottex

@noindent
has an F distribution with @math{p} and @math{n_x+n_y-p-1} degrees of
freedom, where @math{n_x} and @math{n_y} are the sample sizes and
@math{p} is the number of variables.

The p-value of the test is returned in @var{pval}.

If no output argument is given, the p-value of the test is displayed.
@end deftypefn
