md5="a7f80e64d8dc6172a9b02e8570c2031d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{idx} =} dsearchn (@var{x}, @var{tri}, @var{xi})
@deftypefnx {Archivo de función} {@var{idx} =} dsearchn (@var{x}, @var{tri}, @var{xi}, @var{outval})
@deftypefnx {Archivo de función} {@var{idx} =} dsearchn (@var{x}, @var{xi})
@deftypefnx {Archivo de función} {[@var{idx}, @var{d}] =} dsearchn (@dots{})
Retorna el índice @var{idx} o el punto más cercano en @var{x} a los 
elementos @var{xi}. Si se suministra @var{outval}, los valores de 
@var{xi} que no están contenidos dentro de una de las simplicidades 
@var{tri} son igualados a @var{outval}. Generalmente, se retorna @var{tri} 
es desde  @code{delaunayn(@var{x})}.
@seealso{dsearch, tsearch}
@end deftypefn
