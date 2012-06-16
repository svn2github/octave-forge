/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file polig.c
\brief Definición de funciones para el trabajo con polígonos.
\author José Luis García Pallero, jgpallero@gmail.com
\date 20 de abril de 2011
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
#include"libgeoc/polig.h"
/******************************************************************************/
/******************************************************************************/
polig* AsigMemPolig(const size_t nElem)
{
    //estructura de salida
    polig* datos;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para la estructura
    datos = (polig*)malloc(sizeof(polig));
    //comprobamos si ha ocurrido algún error
    if(datos==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos los vectores de coordenadas a NULL
    datos->x = NULL;
    datos->y = NULL;
    //asignamos los incrementos a 1
    datos->incX = 1;
    datos->incY = 1;
    //comprobamos si hay que asignar memoria para los listados de coordenadas
    if(nElem>0)
    {
        //asignamos memoria para los vectores de coordenadas
        datos->x = (double*)malloc(nElem*sizeof(double));
        datos->y = (double*)malloc(nElem*sizeof(double));
        //comprobamos si ha ocurrido algún error
        if((datos->x==NULL)||(datos->y==NULL))
        {
            //liberamos la memria asignada hasta ahora
            LibMemPolig(datos);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return datos;
}
/******************************************************************************/
/******************************************************************************/
polig* ReasigMemPolig(polig* datos,
                      const size_t nElem,
                      const int copiaPrimVert)
{
    //estructura de salida
    polig* nuevo=datos;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos el número de elementos final
    if(nElem>0)
    {
        //asignamos el nuevo tamaño
        nuevo->nElem = nElem;
        //reasignamos memoria para los vectores
        nuevo->x = (double*)realloc(nuevo->x,nElem*nuevo->incX*sizeof(double));
        nuevo->y = (double*)realloc(nuevo->y,nElem*nuevo->incY*sizeof(double));
        //comprobamos si ha ocurrido algún error
        if((nuevo->x==NULL)||(nuevo->y==NULL))
        {
            //liberamos la memria asignada hasta ahora
            LibMemPolig(nuevo);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //comprobamos si hay que copiar el primer vértice
        if(copiaPrimVert)
        {
            //copiamos las coordenadas de primer vértice al último
            nuevo->x[nuevo->incX*(nElem-1)] = nuevo->x[0];
            nuevo->y[nuevo->incY*(nElem-1)] = nuevo->y[0];
        }
    }
    else
    {
        //liberamos la memoria de la estructura de entrada
        LibMemPolig(nuevo);
        //la creamos otra vez
        nuevo = AsigMemPolig(nElem);
        //comprobamos si ha ocurrido algún error
        if(nuevo==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return nuevo;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPolig(polig* datos)
{
    //comprobamos si hay memoria que liberar
    if(datos!=NULL)
    {
        //liberamos la memoria asignada al vector de coordenadas X
        if(datos->x!=NULL)
        {
            free(datos->x);
        }
        //liberamos la memoria asignada al vector de coordenadas Y
        if(datos->y!=NULL)
        {
            free(datos->y);
        }
        //liberamos la memoria asignada a la estructura
        free(datos);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
/** @} */
