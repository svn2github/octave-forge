md5="ead87a8b0f681f291724127d8badaace";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn  {Comando} pkg @var{command} @var{pkg_name}
@deftypefnx {Comando} pkg @var{command} @var{option} @var{pkg_name}
Este comando interactua con el administrador de paquetes. Dependiendo 
del valor de @var{command} se realizan diferentes acciones.

@table @samp
@item install
Instala un paquete. Por ejemplo, 
@example
pkg install image-1.0.0.tar.gz
@end example
@noindent
instala el paquete que se encuentra en el archivo @code{image-1.0.0.tar.gz}.

La variable @var{option} puede contener opciones que afectan la forma en 
la cual las paquetes son instalados. Estas opciones pueden ser una o m@'as 
de

@table @code
@item -nodeps
El administrador de paquetes desactiva la verificaci@'on de dependencias. 
De esta forma es posible instalar un paquete incluso si depende de otro 
paquete que no est@'a instalado en el sistema. @strong{Utilize esta opci@'on 
con precauci@'on}.

@item -noauto
El administrador de paquetes no cargar@'a autom@'aticamente el paquete 
instalado cuando inicia Octave, incluso si el paquete mismo solicita que 
sea cargado.

@item -auto
El administrador de paquetes cargar@'a autom@'aticamente el paquete 
instalado cuando inicia Octave, incluso si el paquete mismo solicita que 
no sea cargado.

@item -local
Se realiza un instalaci@'on local, incluso si el usuario tiene privilegios 
de administrador del sistema.

@item -global
Se realiza una instalaci@'on global, incluso si el usuario no tiene 
normalmente privilegios de administrador del sistema.

@item -verbose
El administrador de paquetes imprimir@'a la salida de los comandos que se 
est@'an ejecutando.
@end table

@item uninstall
Desinstala un paquete. Por ejemplo, 
@example
pkg uninstall image
@end example
@noindent
remueve el paquete @code{image} del sistema. Si otro paquete instalado 
depende del paquete @code{image}, se muestra un error. El paquete se 
puede desinstalar de todas formas usando la opci@'on @code{-nodeps}.

@item load
Agrega el paquete a la ruta. Despu@'es de cargar un paquete, es posible 
usar las funciones suministradas por el mismo. Por ejemplo, 
@example
pkg load image
@end example
@noindent
agrega el paquete @code{image} a la ruta. Es posible cargar todos los 
paquetes instalados mediante un solo comando
@example
pkg load all
@end example

@item unload
Remueve los paquetes de la ruta. Despu@'es de remover un paquete, no es 
posible usar las funciones suministradas por el mismo. Esta comando se 
comporta en forma similar que el comando @code{load}.

@item list
Muestra una lista de los paquetes instalados actualmente. Solicitando uno 
o dos argumentos de salida, es posible obtener una lista de los paquetes 
instalados actualmente. Por ejemplo, 
@example
installed_packages = pkg list;
@end example
@noindent
retorna un arreglo celda con una estructura para cada paquete instalado. 
El comando 
@example
[@var{user_packages}, @var{system_packages}] = pkg list
@end example
@noindent
divide la lista de paquetes instalados en paquetes instalados por el 
usuario actual o por el administrador de sistema.

@item prefix
Establece el prefijo del direcorio de instalci@'on. Por ejemplo, 
@example
pkg prefix ~/my_octave_packages
@end example
@noindent
establece el prefijo de instalaci@'on en @code{~/my_octave_packages}. 
Los paquetes ser@'a instalados en este directorio. 

Es posible obtener el prefijo de instalaci@'on actual agregando un 
de salida. Por ejemplo,
@example
p = pkg prefix
@end example

La ubicaci@'on en la cual se instalan los archivos dependientes de la 
arquitectura puede ser especificada independientemente agregando un 
argumentos adicional. Por ejemplo 

@example
pkg prefix ~/my_octave_packages ~/my_octave_packages_for_my_pc
@end example

@item local_list
Establece el archivo en el cual se va a buscar la informaci@'on acerca 
de los paquetes instalados localmente. Los paquetes instalados localmente
son aquellos que est@'an disponible @'unicamente para el usuario actual. 
Por ejemplo 
@example
pkg local_list ~/.octave_packages
@end example
Es posible obtener el valor actual de @code{local_list} mediante 
@example
pkg local_list
@end example

@item global_list
Establece el archivo en el cual se va a buscar la informaci@'on acerca 
de los paquetes instalados globalmente. Los paquetes instalados globalmente 
son aquellos que est@'an disponible para todos los usuarios. Por ejemplo 
@example
pkg global_list /usr/share/octave/octave_packages
@end example
Es posible obtener el valor de @code{global_list} mediante 
@example
pkg global_list
@end example

@item rebuild
Reconstruye la base de datos de paquetes a partir de los directorios 
instalados. Esta opci@'on puede ser usada en casos donde por alguna raz@'n 
la base de datos de paquetes est@'a corrupta. Tambi@'en puede tomar las 
opciones @code{-auto} y @code{-noauto} para permitir el estado de autocarga 
de un paquete que va a ser modificado. Por ejemplo 

@example
pkg rebuild -noauto image
@end example

remueve el estado de autocarga del paquete @code{image}.

@item build
Contruye la forma binaria de un paquete o paquetes. El archivo binario 
producido es por si mimo un paquete de Octave que puede ser instalado 
normalmente con @code{pkg}. La forma del comando para construir un paquete
binario es 

@example
pkg build builddir image-1.0.0.tar.gz @dots{}
@end example

@noindent
donde @code{buiddir} es el nombre de un directorio en donde se produce 
la instalaci@'on temporal y se encuentran los paquetes binarios. Las 
opciones @code{-verbose} y @code{-nodeps} se respetan, mientras que las 
otras opciones se ignoran.
@end table
@end deftypefn
