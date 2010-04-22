md5="0b4d23875ba51c52049ae31c588056ce";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} compare_versions (@var{v1}, @var{v2}, @var{operator})
Compara las versiones de dos cadenas usando un operador dado @var{operator}.

Esta función asume que las versiones @var{v1} y @var{v2} son 
cadenas arbitrariamente largas conformadas pro caracteres 
numéricos y puntos posiblemente seguidas por una cadena arbitraria 
(e.g. "1.2.3", "0.3", "0.1.2+", or "1.2.3.4-test1").

La versión es la primer división en la parte numérica y de 
caracteres, luego las partes son emparejadas para tener las misma 
longitud (p.e. "1.1" seria emparejada como "1.1.0" para ser 
comparada con "1.1.1", y separadamente, las partes de caracteres son emparejadas con nulos).

El operador puede ser cualquier operador lógico del conjunto

@itemize @bullet
@item
"=="
igual
@item
"<"
menor que
@item
"<="
menor o igual que
@item
">"
mayor que
@item
">="
mayor o igual que
@item
"!="
distinto
@item
"~="
no igual
@end itemize

Nótese que versión "1.1-test2" comparar'ia como mayor que
"1.1-test10". También, puesto que la parte numérica se compara 
primero, "a" compara menor que "1a" porque la segunda cadena 
comienza con una parte numérica, incluso double("a") es mayor que 
double("1").
@end deftypefn
