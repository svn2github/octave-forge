md5="5dbe55d92552aff939a0bf90fee2e54a";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{p} =} etree (@var{s})
@deftypefnx {Funci@'on cargable} {@var{p} =} etree (@var{s}, @var{typ})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{q}] =} etree (@var{s}, @var{typ})
Retorna el @'arbol de elimiinaci@'on de la matriz @var{s}. En forma predeterminada, 
se asume que @var{s} es sim@'etrica y se retorna el @'arbol de eliminaci@'on 
sim@'etrico. El argumento @var{typ} controla si se retorna un @'arbol de eliminaci@'on 
s@'imetrico o por columnas. Los valores que puede tomar @var{typ} son 'sym' o 'col', 
para sim@'etrico o por columnas respectivamante.

Cuando de llama con el seguendo argumento, @dfn{etree} retorna tambi@'en el recorrido 
posorden del @'arbol.
@end deftypefn
