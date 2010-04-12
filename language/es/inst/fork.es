md5="037c9d48975523c0365a6ec623439d2d";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{pid}, @var{msg}] =} fork ()
Crea una copia del proceso actual. 

La funci@'on @code{fork} puede retornar uno de los siguientes valores: 

@table @asis
@item > 0
Proceso padre. El valor retornado por @code{fork} es el identificador 
de proceso del proceso hijo. Deber@'ia esperar por cualquier proceso 
hijo para salir.

@item 0
Proceso hijo. Se puede llamar @code{exec} para ejecutar otro 
proceso. Si falla, probablemente se deber@'ia llamar @code{exit}.

@item < 0
El llamado de @code{fork} falla por alguna raz@'on. Se debe tomar una 
acci@'on evasiva. Un mensaje de error dependiente del sistema estar@'a 
esperado en @var{msg}.
@end table
@end deftypefn
