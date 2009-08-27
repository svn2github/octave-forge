md5="0b4d23875ba51c52049ae31c588056ce";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} compare_versions (@var{v1}, @var{v2}, @var{operator})
Compara las versiones de dos cadenas usando un operador dado @var{operator}.

Esta funci@'on asume que las versiones @var{v1} y @var{v2} son 
cadenas arbitrariamente largas conformadas pro caracteres 
num@'ericos y puntos posiblemente seguidas por una cadena arbitraria 
(e.g. "1.2.3", "0.3", "0.1.2+", or "1.2.3.4-test1").

La versi@'on es la primer divisi@'on en la parte num@'erica y de 
caracteres, luego las partes son emparejadas para tener las misma 
longitud (p.e. "1.1" seria emparejada como "1.1.0" para ser 
comparada con "1.1.1", y separadamente, las partes de caracteres son emparejadas con nulos).

El operador puede ser cualquier operador l@'ogico del conjunto

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

N@'otese que versi@'on "1.1-test2" comparar'ia como mayor que
"1.1-test10". Tambi@'en, puesto que la parte num@'erica se compara 
primero, "a" compara menor que "1a" porque la segunda cadena 
comienza con una parte num@'erica, incluso double("a") es mayor que 
double("1").
@end deftypefn
