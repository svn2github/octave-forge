md5="5dbe55d92552aff939a0bf90fee2e54a";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{p} =} etree (@var{s})
@deftypefnx {Función cargable} {@var{p} =} etree (@var{s}, @var{typ})
@deftypefnx {Función cargable} {[@var{p}, @var{q}] =} etree (@var{s}, @var{typ})
Retorna el árbol de elimiinación de la matriz @var{s}. En forma predeterminada, 
se asume que @var{s} es simétrica y se retorna el árbol de eliminación 
simétrico. El argumento @var{typ} controla si se retorna un árbol de eliminación 
símetrico o por columnas. Los valores que puede tomar @var{typ} son 'sym' o 'col', 
para simétrico o por columnas respectivamante.

Cuando de llama con el seguendo argumento, @dfn{etree} retorna también el recorrido 
posorden del árbol.
@end deftypefn
