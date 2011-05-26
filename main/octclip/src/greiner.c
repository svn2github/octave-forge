/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file greiner.c
\brief Definición de funciones para el recorte de polígonos mediante el
       algoritmo de Greiner-Hormann
       (http://davis.wpi.edu/~matt/courses/clipping/).
\author José Luis García Pallero, jgpallero@gmail.com
\date 14 de mayo de 2011
\section Licencia Licencia
Copyright (c) 2011, José Luis García Pallero. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.
- Neither the name of the copyright holders nor the names of its contributors
  may be used to endorse or promote products derived from this software without
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/******************************************************************************/
/******************************************************************************/
#include"libgeoc/greiner.h"
/******************************************************************************/
/******************************************************************************/
vertPoliClip* CreaVertPoliClip(const double x,
                               const double y,
                               vertPoliClip* anterior,
                               vertPoliClip* siguiente,
                               vertPoliClip* vecino,
                               const char ini,
                               const char interseccion,
                               const char entrada,
                               const char visitado,
                               const double alfa)
{
    //variable de salida (nuevo vértice)
    vertPoliClip* nuevoVert=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el nuevo vértice
    nuevoVert = (vertPoliClip*)malloc(sizeof(vertPoliClip));
    //comprobamos los posibles errores
    if(nuevoVert==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos los vértices anterior y posterior
    nuevoVert->anterior = anterior;
    nuevoVert->siguiente = siguiente;
    //si anterior es un vértice bueno
    if(anterior!=NULL)
    {
        //lo apuntamos al vértice creado
        nuevoVert->anterior->siguiente = nuevoVert;
    }
    //si siguiente es un vértice bueno
    if(siguiente!=NULL)
    {
        //indicamos que el vértice creado es el anterior
        nuevoVert->siguiente->anterior = nuevoVert;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el resto de campos
    nuevoVert->x = x;
    nuevoVert->y = y;
    nuevoVert->xP = x;
    nuevoVert->yP = y;
    nuevoVert->vecino = vecino;
    nuevoVert->ini = ini;
    nuevoVert->interseccion = interseccion;
    nuevoVert->entrada = entrada;
    nuevoVert->visitado = visitado;
    nuevoVert->alfa = alfa;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return nuevoVert;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* CreaPoliClip(const double* x,
                           const double* y,
                           const size_t nCoor,
                           const size_t incX,
                           const size_t incY)
{
    //índice para recorrer bucles
    size_t i=0;
    //variables auxiliares de posición
    size_t posIni=0,posFin=0;
    //otra variable auxiliar
    int hayVert=0;
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //variable de salida
    vertPoliClip* poli=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //buscamos el primer punto que sea distinto de NaN
    for(i=0;i<nCoor;i++)
    {
        //comprobamos si el elemento es distinto de NaN
        if((!EsGeocNan(x[i*incX]))&&(!EsGeocNan(y[i*incY])))
        {
            //indicamos que sí hay vértices de trabajo
            hayVert = 1;
            //guardamos la posición de este elemento
            posIni = i;
            //salimos del bucle
            break;
        }
    }
    //si no hay ningún vértice distinto de NaN
    if(!hayVert)
    {
        //salimos de la función
        return poli;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el primer elemento
    poli = CreaVertPoliClip(x[posIni*incX],y[posIni*incY],NULL,NULL,NULL,1,0,0,
                            0,0.0);
    //comprobamos los posibles errores
    if(poli==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //asignamos el elemento creado a la variable auxiliar
    aux = poli;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable posFin
    posFin = posIni;
    //recorremos los puntos de trabajo
    for(i=(posIni+1);i<nCoor;i++)
    {
        //comprobamos si el elemento es distinto de NaN
        if((!EsGeocNan(x[i*incX]))&&(!EsGeocNan(y[i*incY])))
        {
            //actualizamos la variable que almacena la posición del último
            //vértice válido
            posFin = i;
            //vamos añadiendo vértices al final
            aux = CreaVertPoliClip(x[i*incX],y[i*incY],aux,NULL,NULL,0,0,0,0,
                                   0.0);
            //comprobamos los posibles errores
            if(aux==NULL)
            {
                //liberamos la memoria asignada hasta ahora
                LibMemPoliClip(poli);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el último vértice no está repetido
    if((x[posIni*incX]!=x[posFin*incX])||(y[posIni*incY]!=y[posFin*incY]))
    {
        //repetimos el primer vértice al final
        aux = CreaVertPoliClip(x[posIni*incX],y[posIni*incY],aux,NULL,NULL,0,0,
                               0,0,0.0);
        //comprobamos los posibles errores
        if(aux==NULL)
        {
            //liberamos la memoria asignada hasta ahora
            LibMemPoliClip(poli);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return poli;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPoliClip(vertPoliClip* poli)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //trabajamos mientras quede memoria
    while(poli!=NULL)
    {
        //apuntamos con la estructura auxiliar hacia la memoria a liberar
        aux = poli;
        //apuntamos con la estructura principal al siguiente vértice
        poli = poli->siguiente;
        //liberamos la memoria
        free(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* ReiniciaPoliClip(vertPoliClip* poli)
{
    //estructura que apunta al espacio en memoria a liberar
    vertPoliClip* borra=NULL;
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //estructura de salida
    vertPoliClip* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar
    aux = poli;
    //comprobamos una posible salida rápida
    if(aux==NULL)
    {
        //salimos de la función
        return NULL;
    }
    //buscamos para la estructura de salida el primer vértice que no sea una
    //intersección
    while(aux!=NULL)
    {
        //comprobamos si estamos ante un vértice bueno
        if(aux->interseccion==0)
        {
            //asignamos la variable de salida
            sal = aux;
            //salimos del bucle
            break;
        }
        //siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //volvemos a inicializar la variable auxiliar
    aux = poli;
    //mientras la variable de trabajo no apunte a NULL
    while(aux!=NULL)
    {
        //comprobamos si estamos ante un vértice a borrar
        if(aux->interseccion)
        {
            //lo almacenamos en la estructura de borrado
            borra = aux;
            //actualizamos el puntero de vértice siguiente
            if(aux->anterior!=NULL)
            {
                //cuando el vértice a borrar no es el primero de la lista
                aux->anterior->siguiente = aux->siguiente;
            }
            else if(aux->siguiente!=NULL)
            {
                //cuando el vértice a borrar es el primero de la lista
                aux->siguiente->anterior = NULL;
            }
            //actualizamos el puntero de vértice anterior
            if(aux->siguiente!=NULL)
            {
                //cuando el vértice a borrar no es el último de la lista
                aux->siguiente->anterior = aux->anterior;
            }
            else if(aux->anterior!=NULL)
            {
                //cuando el vértice a borrar es el último de la lista
                aux->anterior->siguiente = NULL;
            }
            //apuntamos al siguiente elemento
            aux = aux->siguiente;
            //liberamos la memoria
            free(borra);
        }
        else
        {
            //reinicializamos el resto de miembros, menos las coordenadas
            //originales y el identificador de primer elemento
            aux->xP = aux->x;
            aux->yP = aux->y;
            aux->vecino = NULL;
            aux->interseccion = 0;
            aux->entrada = 0;
            aux->visitado = 0;
            aux->alfa = 0.0;
            //siguiente elemento
            aux = aux->siguiente;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* SiguienteVertOrigPoliClip(vertPoliClip* vert)
{
    //variable de salida, que inicializamos con la dirección de entrada
    vertPoliClip* sal=vert;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si estamos ante un vértice original, pasamos al siguiente
    if((sal!=NULL)&&(sal->interseccion==0))
    {
        //apuntamos al siguiente vértice
        sal = sal->siguiente;
    }
    //vamos rechazando intersecciones (el bucle se para cuando llegamos al final
    //o a un vértice que no es intersección)
    while((sal!=NULL)&&(sal->interseccion!=0))
    {
        //pasamos al siguiente vértice
        sal = sal->siguiente;
    }
    //si hemos llegado a un vértice que no es original, apuntamos a NULL
    if((sal!=NULL)&&(sal->interseccion!=0))
    {
        //asignamos NULL
        sal = NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* SiguienteIntersecNoVisitadaPoliClip(vertPoliClip* vert)
{
    //variable de salida, que inicializamos con la dirección de entrada
    vertPoliClip* sal=vert;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si estamos ante una intersección no visitada o ante el vértice original
    //del polígono, pasamos al siguiente vértice
    if((sal!=NULL)&&
       (((sal->interseccion!=0)&&(sal->visitado==0))||(sal->ini!=0)))
    {
        //apuntamos al siguiente vértice
        sal = sal->siguiente;
    }
    //vamos rechazando vértices originales e intersecciones visitadas: el bucle
    //se para cuando llegamos al final (si la lista no es circular), cuando
    //volvamos al principio (si la lista es circular) o cuando lleguemos a una
    //intersección no visitada
    while(((sal!=NULL)&&(sal->ini==0))&&
          ((sal->interseccion==0)||
           ((sal->interseccion!=0)&&(sal->visitado!=0))))
    {
        //pasamos al siguiente vértice
        sal = sal->siguiente;
    }
    //si hemos llegado a un vértice que no es una intersección no visitada o es
    //de nuevo el punto inicial (lista circular), apuntamos a NULL
    if((sal!=NULL)&&
       (((sal->interseccion!=0)&&(sal->visitado!=0))||(sal->ini!=0)))
    {
        //asignamos NULL
        sal = NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* UltimoVertPoliClip(vertPoliClip* poli)
{
    //variable de salida, que inicializamos con la dirección de entrada
    vertPoliClip* sal=poli;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //sólo trabajamos si la entrada es distinta de NULL
    if(sal!=NULL)
    {
        //mientras el siguiente vértice sea distinto de NULL
        while(sal->siguiente!=NULL)
        {
            //avanzamos un vértice
            sal = sal->siguiente;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
void InsertaVertPoliClip(vertPoliClip* ins,
                         vertPoliClip* extremoIni,
                         vertPoliClip* extremoFin)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el vértice auxiliar como el extremo inicial pasado
    aux = extremoIni;
    //mientras no lleguemos al extremo final y el punto a insertar esté más
    //lejos del origen que el punto de trabajo
    while((aux!=extremoFin)&&((aux->alfa)<=(ins->alfa)))
    {
        //avanzamos al siguiente vértice
        aux = aux->siguiente;
    }
    //insertamos el punto y ordenamos los punteros de vértices anterior y
    //posterior
    ins->siguiente = aux;
    ins->anterior = aux->anterior;
    ins->anterior->siguiente = ins;
    ins->siguiente->anterior = ins;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
vertPoliClip* CierraPoliClip(vertPoliClip* poli)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //variable de salida: último vértice de la lista original
    vertPoliClip* ultimo=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si se ha pasado NULL
    if(poli==NULL)
    {
        //salimos de la función
        return NULL;
    }
    //buscamos el último vértice de la lista original
    ultimo = UltimoVertPoliClip(poli);
    //almacenamos el penúltimo vértice en la estructura auxiliar
    aux = ultimo->anterior;
    //apuntamos el penúltimo vértice al primero
    aux->siguiente = poli;
    //le decimos al primer vértice cuál es el anterior
    aux->siguiente->anterior = aux;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return ultimo;
}
/******************************************************************************/
/******************************************************************************/
void AbrePoliClip(vertPoliClip* poli,
                  vertPoliClip* ultimo)
{
    //estructuras auxiliares
    vertPoliClip* aux=poli;
    vertPoliClip* ult=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //buscamos el vértice inicial
    while((aux!=NULL)&&(aux->ini==0))
    {
        //pasamos al siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //último vértice
    ult = aux->anterior;
    //le decimos al falso último vértice cuál es el último verdadero
    ult->siguiente = ultimo;
    //ajustamos los parámetros del nuevo último vértice
    ultimo->anterior = ult;
    ultimo->siguiente = NULL;
    //le decimos al primer vértice que el anterior es NULL
    aux->anterior = NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoliClip(const double x,
                  const double y,
                  vertPoliClip* poli)
{
    //estructuras auxiliares
    vertPoliClip* aux=NULL;
    vertPoliClip* aux1=NULL;
    //coordenadas auxiliares
    double x1=0.0,y1=0.0,x2=0.0,y2=0.0;
    //variable de salida
    int c=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //comprobamos si no es un vértice original
    if(aux->interseccion!=0)
    {
        //nos posicionamos en el siguiente vértice original
        aux = SiguienteVertOrigPoliClip(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //entramos en un bucle infinito
    while(1)
    {
        //nos posicionamos en el siguiente vértice original
        aux1 = SiguienteVertOrigPoliClip(aux);
        //sólo continuamos si el siguiente vértice no es NULL
        if(aux1!=NULL)
        {
            //extraemos las coordenadas de trabajo
            x1 = aux->xP;
            y1 = aux->yP;
            x2 = aux1->xP;
            y2 = aux1->yP;
            //actalizamos el vértice inicial de trabajo para la siguiente vuelta
            aux = aux1;
            //calculamos
            if(((y1>y)!=(y2>y))&&(x<(x2-x1)*(y-y1)/(y2-y1)+x1))
            {
                c = !c;
            }
        }
        else
        {
            //salimos del bucle
            break;
        }
    }
    //asignamos el elemento de salida
    if(c)
    {
        //el punto está dentro del polígono
        c = GEOC_PTO_DENTRO_POLIG;
    }
    else
    {
        //el punto está fuera del polígono
        c = GEOC_PTO_FUERA_POLIG;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return c;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoliClipVertice(const double x,
                         const double y,
                         vertPoliClip* poli)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //variable de salida, que inicializamos fuera del polígono
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //comprobamos si no es un vértice original
    if(aux->interseccion!=0)
    {
        //nos posicionamos en el siguiente vértice original
        aux = SiguienteVertOrigPoliClip(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el punto es un vértice
    while(aux!=NULL)
    {
        //comprobamos si las coordenadas coinciden
        if((aux->xP==x)&&(aux->yP==y))
        {
            //indicamos que el punto es un vértice
            pos = GEOC_PTO_VERTICE_POLIG;
            //salimos del bucle
            break;
        }
        //nos posicionamos en el siguiente vértice original
        aux = SiguienteVertOrigPoliClip(aux);
    }
    //sólo continuamos si el punto no es un vértice
    if(pos!=GEOC_PTO_VERTICE_POLIG)
    {
        //calculamos la posición sin tener en cuenta el borde
        pos = PtoEnPoliClip(x,y,poli);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
size_t NumeroVertOrigPoliClip(vertPoliClip* poli)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //variable de salida
    size_t num=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //comprobamos si estamos ante un vértice original
    if(aux->interseccion!=0)
    {
        //si no es un vértice original, nos posicionamos en el siguiente que sí
        //lo sea
        aux = SiguienteVertOrigPoliClip(aux);
    }
    //mientras no lleguemos al final
    while(aux!=NULL)
    {
        //aumentamos el contador de vértices originales
        num++;
        //nos posicionamos en el siguiente vértice original
        aux = SiguienteVertOrigPoliClip(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return num;
}
/******************************************************************************/
/******************************************************************************/
size_t NumeroVertPoliClip(vertPoliClip* poli)
{
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //variable de salida
    size_t num=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //mientras no lleguemos al final
    while(aux!=NULL)
    {
        //aumentamos el contador de vértices
        num++;
        //nos posicionamos en el siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return num;
}
/******************************************************************************/
/******************************************************************************/
double CantPerturbMin(const double x,
                      const double factor)
{
    //valor absoluto del argumento de entrada
    double xAbs=fabs(x);
    //variable auxiliar
    double aux=0.0;
    //variable de salida, que inicializamos como el épsilon para el tipo de dato
    double sal=fabs(DBL_EPSILON);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //mientras la variable auxiliar sea igual a la de antrada (la primera vuelta
    //del bucle se ejecuta siempre)
    do
    {
        //escalamos la variable de salida
        sal *= factor;
        //sumamos el nuevo valor a la coordenada de entrada
        //esta suma es necesario realizarla aquí, en lugar de en la propia
        //comparación del while, para obligar al resultado a almacenarse en una
        //variable y evitar errores porque las variables intermedias de la
        //comparación puede que se almacenen en registros de más precisión que
        //el tipo de dato
        aux = xAbs+sal;
    }while(aux==xAbs);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
double PerturbaPuntoMin(const double x,
                        const double factor)
{
    //variable para almacenar un número seudoaleatorio
    int aleat=0;
    //cantidad perturbadora
    double perturb=0.0;
    //signo para multiplicar por la cantidad perturbadora
    double signo=0.0;
    //variable de salida
    double sal=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //plantamos la semilla para la función rand()
    srand((unsigned int)time(NULL));
    //generamos el número seudoaleatorio
    aleat = rand();
    //calculamos el signo para la multiplicación, basándonos en la paridad del
    //número seudoaleatorio generado: si es par vale 1 y si es impar -1
    signo = (aleat%2) ? -1.0 : 1.0;
    //calculamos la cantidad perturbadora
    perturb = CantPerturbMin(x,factor);
    //perturbamos la coordenada
    sal = x+signo*perturb;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int Paso1Greiner(vertPoliClip* poliBas,
                 vertPoliClip* poliRec,
                 const double facPer,
                 size_t* nIntersec,
                 size_t* nPerturb)
{
    //estructuras auxiliares que apuntan a los polígonos pasados
    vertPoliClip* auxA=NULL;
    vertPoliClip* auxC=NULL;
    //estructuras auxiliares para trabajar con el siguiente vértice
    vertPoliClip* auxB=NULL;
    vertPoliClip* auxD=NULL;
    //vértices de intersección a insertar
    vertPoliClip* insBas=NULL;
    vertPoliClip* insRec=NULL;
    //coordenadas de la intersección de dos segmentos
    double xI=0.0,yI=0.0;
    //longitudes de segmentos y parámetros alfa
    double lonAB=0.0,lonCD=0.0,alfaAB=0.0,alfaCD=0.0;
    //código de intersección de segmentos
    int intersec=0;
    //variable de salida
    int salida=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el número de intersecciones a 0
    *nIntersec = 0;
    //inicializamos el número de puntos perturbados a 0
    *nPerturb = 0;
    //EL PRIMER PASO DEL ALGORITMO DE GREINER-HORMANN ES EL CÁLCULO DE TODOS LOS
    //PUNTOS DE INTERSECCIÓN ENTRE LOS POLÍGONOS
    //recorremos los vértices del polígono base
    for(auxA=poliBas;auxA->siguiente!=NULL;auxA=auxA->siguiente)
    {
        //sólo trabajamos si el vértice es original
        if(auxA->interseccion==0)
        {
            //recorremos los vértices del polígono de recorte
            for(auxC=poliRec;auxC->siguiente!=NULL;auxC=auxC->siguiente)
            {
                //sólo trabajamos si el vértice es original
                if(auxC->interseccion==0)
                {
                    //siguiente vértice de los segmentos
                    auxB = SiguienteVertOrigPoliClip(auxA);
                    auxD = SiguienteVertOrigPoliClip(auxC);
                    //calculamos la intersección de los segmentos
                    intersec = IntersecSegmentos2D(auxA->xP,auxA->yP,auxB->xP,
                                                   auxB->yP,auxC->xP,auxC->yP,
                                                   auxD->xP,auxD->yP,&xI,&yI);
                    //perturbamos las coordenadas de los extremos de los
                    //segmentos mientras haya una intersección no limpia
                    while((intersec!=GEOC_SEG_NO_INTERSEC)&&
                          (intersec!=GEOC_SEG_INTERSEC))
                    {
                        //distinguimos entre intersecciones donde sólo se toca
                        //un extremo es intersecciones colineales donde se
                        //comparte más de un punto
                        if((intersec==GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN)||
                           (intersec==GEOC_SEG_INTERSEC_EXTREMO_COLIN))
                        {
                            if((xI==auxC->xP)&&(yI==auxC->yP))
                            {
                                //perturbamos el extremo C
                                auxC->xP = PerturbaPuntoMin(auxC->x,facPer);
                                auxC->yP = PerturbaPuntoMin(auxC->y,facPer);
                                //aumentamos el contador de puntos perturbados
                                (*nPerturb)++;
                            }
                            else if((xI==auxD->xP)&&(yI==auxD->yP))
                            {
                                //perturbamos el extremo D
                                auxD->xP = PerturbaPuntoMin(auxD->x,facPer);
                                auxD->yP = PerturbaPuntoMin(auxD->y,facPer);
                                //aumentamos el contador de puntos perturbados
                                (*nPerturb)++;
                            }
                            else
                            {
                                //si el punto de contacto es un extremo de AB y
                                //los segmentos no son paralelos, perturbamos
                                //todo el segmento CD
                                auxC->xP = PerturbaPuntoMin(auxC->x,facPer);
                                auxC->yP = PerturbaPuntoMin(auxC->y,facPer);
                                auxD->xP = PerturbaPuntoMin(auxD->x,facPer);
                                auxD->yP = PerturbaPuntoMin(auxD->y,facPer);
                                //aumentamos el contador de puntos perturbados
                                (*nPerturb) += 2;
                            }
                        }
                        else if((intersec==GEOC_SEG_INTERSEC_MISMO_SEG)||
                                (intersec==GEOC_SEG_INTERSEC_COLIN))
                        {
                            //perturbamos todo el segmento CD
                            auxC->xP = PerturbaPuntoMin(auxC->x,facPer);
                            auxC->yP = PerturbaPuntoMin(auxC->y,facPer);
                            auxD->xP = PerturbaPuntoMin(auxD->x,facPer);
                            auxD->yP = PerturbaPuntoMin(auxD->y,facPer);
                            //aumentamos el contador de puntos perturbados
                            (*nPerturb) += 2;
                        }
                        //volvemos a calcular la intersección de los segmentos
                        intersec = IntersecSegmentos2D(auxA->xP,auxA->yP,
                                                       auxB->xP,auxB->yP,
                                                       auxC->xP,auxC->yP,
                                                       auxD->xP,auxD->yP,
                                                       &xI,&yI);
                    }
                    //comprobamos si los segmentos se cortan limpiamente
                    if(intersec==GEOC_SEG_INTERSEC)
                    {
                        //aumentamos el contador de intersecciones
                        (*nIntersec)++;
                        //calculamos las longitudes de los segmentos
                        lonAB = Dist2D(auxA->xP,auxA->yP,auxB->xP,auxB->yP);
                        lonCD = Dist2D(auxC->xP,auxC->yP,auxD->xP,auxD->yP);
                        //calculamos los parámetros alfa
                        alfaAB = Dist2D(auxA->xP,auxA->yP,xI,yI)/lonAB;
                        alfaCD = Dist2D(auxC->xP,auxC->yP,xI,yI)/lonCD;
                        //creamos los nuevos vértices a insertar
                        insBas = CreaVertPoliClip(xI,yI,NULL,NULL,NULL,0,1,0,0,
                                                  alfaAB);
                        insRec = CreaVertPoliClip(xI,yI,NULL,NULL,NULL,0,1,0,0,
                                                  alfaCD);
                        //comprobamos los posibles errores
                        if((insBas==NULL)||(insRec==NULL))
                        {
                            //liberamos la memoria previamente asignada
                            free(insBas);
                            free(insRec);
                            //mensaje de error
                            GEOC_ERROR("Error de asignación de memoria");
                            //asignamos el código de error
                            salida = GEOC_ERR_ASIG_MEMORIA;
                            //salimos de la función
                            return salida;
                        }
                        //enlazamos los vértices mediante el campo 'vecino'
                        insBas->vecino = insRec;
                        insRec->vecino = insBas;
                        //los insertamos en los polígonos
                        InsertaVertPoliClip(insBas,auxA,auxB);
                        InsertaVertPoliClip(insRec,auxC,auxD);
                    }
                }
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
void Paso2Greiner(vertPoliClip* poliBas,
                  vertPoliClip* poliRec,
                  const enum GEOC_OP_BOOL_POLIG op)
{
    //estructuras auxiliares que apuntan a los polígonos pasados
    vertPoliClip* auxA=NULL;
    vertPoliClip* auxC=NULL;
    //identificador de si una intersección es de entrada o salida
    char entrada=0;
    //variables auxiliares
    char entA=0,entC=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos los valores iniciales a los identificadores de intersección
    switch(op)
    {
        //distinguimos los tipos de operación
        case GeocOpBoolInter:
            //intersección
            entA = 1;
            entC = 1;
            break;
        case GeocOpBoolUnion:
            //unión
            entA = 0;
            entC = 0;
            break;
        case GeocOpBoolAB:
            //A-B
            entA = 0;
            entC = 1;
            break;
        case GeocOpBoolBA:
            //B-A
            entA = 1;
            entC = 0;
            break;
        default:
            //por defecto, intersección
            entA = 1;
            entC = 1;
            break;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //EL SEGUNDO PASO DEL ALGORITMO DE GREINER-HORMANN ES LA IDENTIFICACIÓN DE
    //INTERSECCIONES COMO ENTRADA-SALIDA
    //comprobamos si el primer punto del polígono base está fuera del polígono
    //de recorte
    if(PtoEnPoliClipVertice(poliBas->xP,poliBas->yP,poliRec))
    {
        //si el punto está fuera, la siguiente intersección es de entrada
        entrada = !entA;
    }
    else
    {
        entrada = entA;
    }
    //recorremos los vértices del polígono de recorte
    for(auxA=poliBas;auxA->siguiente!=NULL;auxA=auxA->siguiente)
    {
        //sólo trabajamos si el vértice es intersección
        if(auxA->interseccion!=0)
        {
            //indicamos la dirección
            auxA->entrada = entrada;
            //actualizamos la variable de entrada para la siguiente vuelta
            entrada = !entrada;
        }
    }
    //comprobamos si el primer punto del polígono de recorte está fuera del
    //polígono base
    if(PtoEnPoliClipVertice(poliRec->xP,poliRec->yP,poliBas))
    {
        //si el punto está fuera, la siguiente intersección es de entrada
        entrada = !entC;
    }
    else
    {
        entrada = entC;
    }
    //recorremos los vértices del polígono base
    for(auxC=poliRec;auxC->siguiente!=NULL;auxC=auxC->siguiente)
    {
        //sólo trabajamos si el vértice es intersección
        if(auxC->interseccion!=0)
        {
            //indicamos la dirección
            auxC->entrada = entrada;
            //actualizamos la variable de entrada para la siguiente vuelta
            entrada = !entrada;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
poligGreiner* Paso3Greiner(vertPoliClip* poliBas,
                           vertPoliClip* poliRec)
{
    //vértices colgados al cerrar los polígonos
    vertPoliClip* ultBas=NULL;
    vertPoliClip* ultRec=NULL;
    //estructura auxiliar
    vertPoliClip* aux=NULL;
    //vectores de coordenadas de los vértices del resultado
    double* x=NULL;
    double* y=NULL;
    //número de elementos de los vectores x e y
    size_t nPtos=0;
    //número de elementos para los que ha sido asignada memoria
    size_t nElem=0;
    //polígono de salida
    poligGreiner* resultado=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //cerramos los polígonos, convirtiéndolos en listas circulares
    ultBas = CierraPoliClip(poliBas);
    ultRec = CierraPoliClip(poliRec);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //mientras queden intersecciones sin visitar
    while((aux = SiguienteIntersecNoVisitadaPoliClip(poliBas))!=NULL)
    {
        //aumentamos el contador de elementos para los vectores x e y en 2
        //unidades: una para el marcador de inicio de polígono y la otra para
        //las coordenadas del primer vértice
        nPtos+=2;
        //comprobamos si hay que reasignar memoria a los vectores de coordenadas
        if(nPtos>nElem)
        {
            //actualizamos el número de elementos de los vectores de puntos
            nElem += GEOC_GREINER_BUFFER_PTOS;
            //reasignamos memoria para los vectores
            x = (double*)realloc(x,nElem*sizeof(double));
            y = (double*)realloc(y,nElem*sizeof(double));
            //comprobamos si ha ocurrido algún error
            if((x==NULL)||(y==NULL))
            {
                //liberamos la posible memoria asignada
                free(x);
                free(y);
                //reabrimos los polígonos
                AbrePoliClip(poliBas,ultBas);
                AbrePoliClip(poliRec,ultRec);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
        }
        //asignamos el marcador NaN como identificador de comienzo de polígono
        x[nPtos-2] = GeocNan();
        y[nPtos-2] = GeocNan();
        //asignamos las coordenadas del punto de intersección
        x[nPtos-1] = aux->xP;
        y[nPtos-1] = aux->yP;
        //EN ESTE NIVEL SIEMPRE ESTAMOS ANTE UN PUNTO DE INTERSECCIÓN
        //mientras el punto no haya sido visitado con anterioridad
        do
        {
            //lo marcamos como visitado
            aux->visitado = 1;
            aux->vecino->visitado = 1;
            //comprobamos si el punto es de entrada o no
            if(aux->entrada!=0)
            {
                //mientras no encontremos otra intersección
                do
                {
                    //caminamos en la lista hacia adelante
                    aux = aux->siguiente;
                    //aumentamos el contador de elementos para x e y
                    nPtos++;
                    //comprobamos si hay que reasignar memoria a los vectores de
                    //coordenadas
                    if(nPtos>nElem)
                    {
                        //actualizamos el número de elementos de los vectores de
                        //puntos
                        nElem += GEOC_GREINER_BUFFER_PTOS;
                        //reasignamos memoria para los vectores
                        x = (double*)realloc(x,nElem*sizeof(double));
                        y = (double*)realloc(y,nElem*sizeof(double));
                        //comprobamos si ha ocurrido algún error
                        if((x==NULL)||(y==NULL))
                        {
                            //liberamos la posible memoria asignada
                            free(x);
                            free(y);
                            //reabrimos los polígonos
                            AbrePoliClip(poliBas,ultBas);
                            AbrePoliClip(poliRec,ultRec);
                            //mensaje de error
                            GEOC_ERROR("Error de asignación de memoria");
                            //salimos de la función
                            return NULL;
                        }
                    }
                    //asignamos las coordenadas del punto de intersección
                    x[nPtos-1] = aux->xP;
                    y[nPtos-1] = aux->yP;
                }
                while(aux->interseccion==0); //mientras no sea intersección
            }
            else
            {
                ////mientras no encontremos otra intersección
                do
                {
                    //caminamos hacia atrás
                    aux = aux->anterior;
                    //aumentamos el contador de elementos para x e y
                    nPtos++;
                    //comprobamos si hay que reasignar memoria a los vectores de
                    //coordenadas
                    if(nPtos>nElem)
                    {
                        //actualizamos el número de elementos de los vectores de
                        //puntos
                        nElem += GEOC_GREINER_BUFFER_PTOS;
                        //reasignamos memoria para los vectores
                        x = (double*)realloc(x,nElem*sizeof(double));
                        y = (double*)realloc(y,nElem*sizeof(double));
                        //comprobamos si ha ocurrido algún error
                        if((x==NULL)||(y==NULL))
                        {
                            //liberamos la posible memoria asignada
                            free(x);
                            free(y);
                            //reabrimos los polígonos
                            AbrePoliClip(poliBas,ultBas);
                            AbrePoliClip(poliRec,ultRec);
                            //mensaje de error
                            GEOC_ERROR("Error de asignación de memoria");
                            //salimos de la función
                            return NULL;
                        }
                    }
                    //asignamos las coordenadas del punto de intersección
                    x[nPtos-1] = aux->xP;
                    y[nPtos-1] = aux->yP;
                }
                while(aux->interseccion==0); //mientras no sea intersección
            }
            //saltamos al otro polígono
            aux = aux->vecino;
        }while(aux->visitado==0); //mientras el punto no haya sido visitado
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //aumentamos el contador de puntos para añadir la marca de final de polígono
    nPtos++;
    //comprobamos si hay que reasignar memoria a los vectores de coordenadas
    if(nPtos>nElem)
    {
        //actualizamos el número de elementos de los vectores de puntos
        nElem += GEOC_GREINER_BUFFER_PTOS;
        //reasignamos memoria para los vectores
        x = (double*)realloc(x,nElem*sizeof(double));
        y = (double*)realloc(y,nElem*sizeof(double));
        //comprobamos si ha ocurrido algún error
        if((x==NULL)||(y==NULL))
        {
            //liberamos la posible memoria asignada
            free(x);
            free(y);
            //reabrimos los polígonos
            AbrePoliClip(poliBas,ultBas);
            AbrePoliClip(poliRec,ultRec);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    //asignamos las coordenadas del punto de intersección
    x[nPtos-1] = GeocNan();
    y[nPtos-1] = GeocNan();
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ajustamos los tamaños de los vectores al número final de coordenadas
    if(nElem>nPtos)
    {
        //reasignamos memoria para los vectores
        x = (double*)realloc(x,nPtos*sizeof(double));
        y = (double*)realloc(y,nPtos*sizeof(double));
        //comprobamos si ha ocurrido algún error
        if((x==NULL)||(y==NULL))
        {
            //liberamos la posible memoria asignada
            free(x);
            free(y);
            //reabrimos los polígonos
            AbrePoliClip(poliBas,ultBas);
            AbrePoliClip(poliRec,ultRec);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos la estructura de salida
    resultado = CreaPoligGreinerVectores(nPtos,x,y);
    //comprobamos los posibles errores
    if(resultado==NULL)
    {
        //liberamos la posible memoria asignada
        free(x);
        free(y);
        //reabrimos los polígonos
        AbrePoliClip(poliBas,ultBas);
        AbrePoliClip(poliRec,ultRec);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //reabrimos los polígonos
    AbrePoliClip(poliBas,ultBas);
    AbrePoliClip(poliRec,ultRec);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return resultado;
}
/******************************************************************************/
/******************************************************************************/
poligGreiner* PoliBoolGreiner(vertPoliClip* poliBas,
                              vertPoliClip* poliRec,
                              const enum GEOC_OP_BOOL_POLIG op,
                              const double facPer,
                              size_t* nIntersec,
                              size_t* nPerturb)
{
    //factor de perturbación
    double factor=0.0;
    //identificador de error
    int idError=GEOC_ERR_NO_ERROR;
    //polígono de salida
    poligGreiner* resultado=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si se ha pasado factor de perturbación
    if(facPer<=1.0)
    {
        //utilizamos el valor por defecto
        factor = GEOC_GREINER_FAC_EPS_PERTURB;
    }
    else
    {
        //utilizamos el valor pasado
        factor = facPer;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //PRIMER PASO DEL ALGORITMO DE GREINER-HORMANN: CÁLCULO DE TODOS LOS PUNTOS
    //DE INTERSECCIÓN ENTRE LOS POLÍGONOS
    //calculamos los puntos de intersección
    idError = Paso1Greiner(poliBas,poliRec,factor,nIntersec,nPerturb);
    //comprobamos los posibles errores
    if(idError==GEOC_ERR_ASIG_MEMORIA)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria en la llamada a "
                   "'Paso1Greiner'");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si no hay intersecciones
    if(!(*nIntersec))
    {
        //comprobamos las posibles situaciones relativas entre los polígonos que
        //pueden producir cero intersecciones
        if(PtoEnPoliClipVertice(poliBas->xP,poliBas->yP,poliRec))
        {
            //EL POLÍGONO BASE ESTÁ DENTRO DEL POLÍGONO DE RECORTE
            //distinguimos las operaciones (por defecto, intersección)
            if(op==GeocOpBoolUnion)
            {
                //el resultado es el polígono de recorte
                resultado = CreaPoligGreinerPoliClip(poliRec,0);
            }
            else if(op==GeocOpBoolAB)
            {
                //el resultado es un polígono vacío
                resultado = CreaPoligGreinerPoliClip(NULL,0);
            }
            else if(op==GeocOpBoolBA)
            {
                //el resultado son los dos polígonos
                //polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
                //añadimos el polígono de recorte
                resultado = AnyadePoligClipPoligGreiner(resultado,poliRec,0);
            }
            else
            {
                //el resultado es el polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
            }
        }
        else if(PtoEnPoliClipVertice(poliRec->xP,poliRec->yP,poliBas))
        {
            //EL POLÍGONO DE RECORTE ESTÁ DENTRO DEL POLÍGONO BASE
            //distinguimos las operaciones (por defecto, intersección)
            if(op==GeocOpBoolUnion)
            {
                //el resultado es el polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
            }
            else if(op==GeocOpBoolAB)
            {
                //el resultado son los dos polígonos
                //polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
                //añadimos el polígono de recorte
                resultado = AnyadePoligClipPoligGreiner(resultado,poliRec,0);
            }
            else if(op==GeocOpBoolBA)
            {
                //el resultado es un polígono vacío
                resultado = CreaPoligGreinerPoliClip(NULL,0);
            }
            else
            {
                //el resultado es el polígono de recorte
                resultado = CreaPoligGreinerPoliClip(poliRec,0);
            }
        }
        else
        {
            //NINGÚN POLÍGONO ESTÁ DENTRO DEL OTRO
            //distinguimos las operaciones (por defecto, intersección)
            if(op==GeocOpBoolUnion)
            {
                //el resultado son los dos polígonos
                //polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
                //añadimos el polígono de recorte
                resultado = AnyadePoligClipPoligGreiner(resultado,poliRec,0);
            }
            else if(op==GeocOpBoolAB)
            {
                //el resultado es el polígono base
                resultado = CreaPoligGreinerPoliClip(poliBas,0);
            }
            else if(op==GeocOpBoolBA)
            {
                //el resultado es el polígono de recorte
                resultado = CreaPoligGreinerPoliClip(poliRec,0);
            }
            else
            {
                //el resultado es un polígono vacío
                resultado = CreaPoligGreinerPoliClip(NULL,0);
            }
        }
        //comprobamos los posibles errores
        if(resultado==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //salimos de la función
        return resultado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //SEGUNDO PASO DEL ALGORITMO DE GREINER-HORMANN: IDENTIFICACIÓN DE
    //INTERSECCIONES COMO ENTRADA-SALIDA
    //marcamos los puntos como entrada o salida
    Paso2Greiner(poliBas,poliRec,op);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //TERCER PASO DEL ALGORITMO DE GREINER-HORMANN: EXTRACCIÓN DE LOS POLÍGONOS
    //RESULTADO DE LA OPERACIÓN
    //extraemos los polígonos
    resultado = Paso3Greiner(poliBas,poliRec);
    //comprobamos los posibles errores
    if(resultado==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria en la llamada a "
                   "'Paso3Greiner'");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return resultado;
}
/******************************************************************************/
/******************************************************************************/
poligGreiner* CreaPoligGreinerVectores(const size_t nElem,
                                       double* x,
                                       double* y)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida
    poligGreiner* result=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para la estructura
    result = (poligGreiner*)malloc(sizeof(poligGreiner));
    //comprobamos los posibles errores
    if(result==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //asignamos el número de elementos
    result->nElem = nElem;
    //enlazamos con los vectores de coordenadas
    result->x = x;
    result->y = y;
    //inicializamos los otros campos
    result->nPolig = 0;
    result->posIni = NULL;
    result->nVert = NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los elementos de trabajo
    for(i=0;i<nElem;i++)
    {
        //comprobamos si las coordenadas de trabajo son NaN
        if(EsGeocNan(x[i])&&EsGeocNan(y[i]))
        {
            //aumentamos el contador de polígonos
            (result->nPolig)++;
        }
    }
    //quitamos uno, porque siempre hay un NaN de más
    (result->nPolig)--;
    //sólo continuamos si hay algún polígono
    if(result->nPolig)
    {
        //asignamos memoria para los vectores de posiciones
        result->posIni = (size_t*)malloc(result->nPolig*sizeof(size_t));
        result->nVert = (size_t*)malloc(result->nPolig*sizeof(size_t));
        //comprobamos los posibles errores
        if((result->posIni==NULL)||(result->nVert==NULL))
        {
            //liberamos la memoria asignada hasta ahora, pero no la de los
            //vectores de coordenadas
            free(result->posIni);
            free(result->nVert);
            free(result);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //inicializamos a 0 los vectores de posiciones
        for(i=0;i<result->nPolig;i++)
        {
            result->posIni[i] = 0;
            result->nVert[i] = 0;
        }
        //recorremos los elementos desde el primero hasta el anterior al último,
        //que es NaN
        for(i=0;i<(nElem-1);i++)
        {
            //comprobamos si es NaN
            if(EsGeocNan(x[i])&&EsGeocNan(y[i]))
            {
                //actualizamos la posición en los vectores de posiciones, si ha
                //lugar
                if(i==0)
                {
                    //inicializamos la posición
                    pos = 0;
                }
                else
                {
                    //aumentamos el contador
                    pos++;
                }
                //indicamos la posición de comienzo de coordenadas
                result->posIni[pos] = i+1;
            }
            else
            {
                //si no es NaN, añadimos un vértice más a la cuenta del número
                //de vértices del polígono
                result->nVert[pos] += 1;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return result;
}
/******************************************************************************/
/******************************************************************************/
poligGreiner* CreaPoligGreinerPoliClip(vertPoliClip* poli,
                                       const int coorOrig)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de elementos
    size_t nVert=0,nElem=0;
    //estructura auxiliar
    vertPoliClip* aux=poli;
    //variable de salida
    poligGreiner* result=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contamos todos los vértices del polígono
    nVert = NumeroVertPoliClip(poli);
    //número de elementos de los vectores de coordenadas
    nElem = nVert+2;
    //asignamos memoria para la estructura de trabajo
    result = (poligGreiner*)malloc(sizeof(poligGreiner));
    //comprobamos los posibles errores
    if(result==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //asignamos memoria para los vectores de coordenadas de la estructura
    result->x = (double*)malloc(nElem*sizeof(double));
    result->y = (double*)malloc(nElem*sizeof(double));
    //comprobamos los posibles errores de asignación de memoria
    if((result->x==NULL)||(result->y==NULL))
    {
        //liberamos la posible memoria asignada
        free(result->x);
        free(result->y);
        free(result);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //asignamos memoria para los vectores de posiciones, si ha lugar
    if(nVert>0)
    {
        result->posIni = (size_t*)malloc(sizeof(size_t));
        result->nVert = (size_t*)malloc(sizeof(size_t));
        //comprobamos los posibles errores de asignación de memoria
        if((result->posIni==NULL)||(result->nVert==NULL))
        {
            //liberamos la posible memoria asignada
            free(result->x);
            free(result->y);
            free(result->posIni);
            free(result->nVert);
            free(result);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el número de elementos de los vectores de coordenadas
    result->nElem = nElem;
    //asignamos los campos de posiciones, dependiendo del número de vértices
    if(nVert>0)
    {
        //número de polígonos
        result->nPolig = 1;
        //posición de inicio del único polígono
        result->posIni[0] = 1;
        //número de vértices del único polígono
        result->nVert[0] = nVert;
    }
    else
    {
        //número de polígonos
        result->nPolig = 0;
        //inicializamos a NULL los vectores de posición
        result->posIni = NULL;
        result->nVert = NULL;
    }
    //asignamos los separadores de polígono al principio y al final
    result->x[0] = GeocNan();
    result->y[0] = GeocNan();
    result->x[nElem-1] = GeocNan();
    result->y[nElem-1] = GeocNan();
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los vértices del polígono
    for(i=1;i<=nVert;i++)
    {
        //distinguimos el tipo de coordenadas a copiar
        if(coorOrig)
        {
            //coordenadas originales
            result->x[i] = aux->x;
            result->y[i] = aux->y;
        }
        else
        {
            //coordenadas perturbadas
            result->x[i] = aux->xP;
            result->y[i] = aux->yP;
        }
        //siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return result;
}
/******************************************************************************/
/******************************************************************************/
poligGreiner* AnyadePoligClipPoligGreiner(poligGreiner* poliOrig,
                                          vertPoliClip* poli,
                                          const int coorOrig)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de elementos
    size_t nVert=0,nElem=0;
    //estructura auxiliar
    vertPoliClip* aux=poli;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contamos todos los vértices del polígono
    nVert = NumeroVertPoliClip(poli);
    //sólo continuamos si el nuevo polígono contiene algún vértice
    if(nVert>0)
    {
        //número total de elementos
        nElem = poliOrig->nElem+nVert+1;
        //reasignamos memoria para los vectores de la estructura
        poliOrig->x = (double*)realloc(poliOrig->x,nElem*sizeof(double));
        poliOrig->y = (double*)realloc(poliOrig->y,nElem*sizeof(double));
        poliOrig->posIni = (size_t*)realloc(poliOrig->posIni,
                                           (poliOrig->nPolig+1)*sizeof(size_t));
        poliOrig->nVert = (size_t*)realloc(poliOrig->nVert,
                                           (poliOrig->nPolig+1)*sizeof(size_t));
        //comprobamos los posibles errores de asignación de memoria
        if((poliOrig->x==NULL)||(poliOrig->y==NULL)||(poliOrig->posIni==NULL)||
           (poliOrig->nVert==NULL))
        {
            //liberamos la posible memoria asignada
            LibMemPoligGreiner(poliOrig);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //número total de polígonos
        poliOrig->nPolig += 1;
        //posición de inicio del polígono a añadir
        poliOrig->posIni[poliOrig->nPolig-1] = poliOrig->nElem;
        //número de vértices del polígono a añadir
        poliOrig->nVert[poliOrig->nPolig-1] = nVert;
        //copiamos los nuevos vértices
        for(i=0;i<nVert;i++)
        {
            //distinguimos el tipo de coordenadas a copiar
            if(coorOrig)
            {
                //coordenadas originales
                poliOrig->x[poliOrig->nElem+i] = aux->x;
                poliOrig->y[poliOrig->nElem+i] = aux->y;
            }
            else
            {
                //coordenadas perturbadas
                poliOrig->x[poliOrig->nElem+i] = aux->xP;
                poliOrig->y[poliOrig->nElem+i] = aux->yP;
            }
            //siguiente vértice
            aux = aux->siguiente;
        }
        //elementos totales de los vectores de coordenadas
        poliOrig->nElem = nElem;
        //copiamos la marca de fin de polígono
        poliOrig->x[poliOrig->nElem-1] = GeocNan();
        poliOrig->y[poliOrig->nElem-1] = GeocNan();
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return poliOrig;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPoligGreiner(poligGreiner* poli)
{
    //sólo trabajamos si la estructura pasada tiene memoria asignada
    if(poli!=NULL)
    {
        //liberamos la memoria asignada al vector de coordenadas X
        if(poli->x!=NULL)
        {
            free(poli->x);
        }
        //liberamos la memoria asignada al vector de coordenadas Y
        if(poli->y!=NULL)
        {
            free(poli->y);
        }
        //liberamos la memoria asignada al vector de posiciones de inicio
        if(poli->posIni!=NULL)
        {
            free(poli->posIni);
        }
        //liberamos la memoria asignada al vector de número de vértices
        if(poli->nVert!=NULL)
        {
            free(poli->nVert);
        }
        //liberamos la memoria asignada a la estructura
        free(poli);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
/** @} */
