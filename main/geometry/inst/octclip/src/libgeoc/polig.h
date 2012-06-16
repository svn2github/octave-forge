/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file polig.h
\brief Definición de estructuras y declaración de funciones para el trabajo con
       polígonos.
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
#ifndef _POLIG_H_
#define _POLIG_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include"libgeoc/errores.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/** \struct polig
\brief Estructura contenedora de los vértices que definen el contorno de un
       polígono.
\date 20 de abril de 2011: Creación de la estructura.
*/
typedef struct
{
    /** \brief Número de elementos de los vectores de coordenadas. */
    size_t nElem;
    /**
    \brief Vector de \em nElem elementos, que almacena las coordenadas X de los
           vértices del polígono. El primer elemento se repite al final.
    */
    double* x;
    /**
    \brief Vector de \em nElem elementos, que almacena las coordenadas Y de los
           vértices del polígono. El primer elemento se repite al final.
    */
    double* y;
    /** \brief Posiciones de separación entre los elementos del vector \em x. */
    size_t incX;
    /** \brief Posiciones de separación entre los elementos del vector \em y. */
    size_t incY;
}polig;
/******************************************************************************/
/******************************************************************************/
/**
\brief Asigna memoria para una estructura \ref polig.
\param[in] nElem Número de elementos del polígono. Ha de ser igual al número de
           vértices del polígono más uno, ya que el primer vértice se repite al
           final.
\return Estructura \ref polig, con memoria asignada para \em nElem elementos. Si
        ocurre un error de asignación de memoria se devuelve NULL.
\note Si el argumento \em nElem vale 0, los campos #polig::x y #polig::y se
      inicializan a NULL.
\note Los campos #polig::incX y #polig::incY se inicializan con el valor 1.
\date 20 de abril de 2011: Creación de la estructura.
*/
polig* AsigMemPolig(const size_t nElem);
/******************************************************************************/
/******************************************************************************/
/**
\brief Reasigna memoria a una estructura \ref polig.
\param[in] datos Estructura \ref polig a redimensionar.
\param[in] nElem Número de elementos del polígono después de la reasignación. Ha
           de ser igual al número de vértices del polígono final más uno, ya que
           el primer vértice se repite al final.
\param[in] copiaPrimVert Identificador para, después de la reasignación de
           memoria, copiar o no el primer vértice del polígono en la última
           posición de los listados de coordenadas. Dos posibilidades:
           - 0: No se copia el primer vértice al final.
           - Distinto de 0: Sí se copia.
\return Estructura \ref polig, con la memoria reasignada para \em nElem
        elementos. Si ocurre un error de asignación de memoria se devuelve NULL.
\note Si el argumento \em nElem vale 0 esta función actúa igual que si se
      llamase a la función \ref AsigMemPolig con su argumento igual a 0.
\date 20 de abril de 2011: Creación de la estructura.
*/
polig* ReasigMemPolig(polig* datos,
                      const size_t nElem,
                      const int copiaPrimVert);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera la memoria asignada a una estructura \ref polig.
\param[in] datos Estructura \ref polig.
\date 20 de abril de 2011: Creación de la estructura.
*/
void LibMemPolig(polig* datos);
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
#endif
/******************************************************************************/
/******************************************************************************/
/** @} */
