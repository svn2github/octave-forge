/* -*- coding: utf-8 -*- */
/**
\ingroup geom interp
@{
\file eucli.h
\brief Declaración de funciones para la realización de cálculos de geometría
       euclídea.
\author José Luis García Pallero, jgpallero@gmail.com
\date 27 de octubre de 2009
\section Licencia Licencia
Copyright (c) 2009-2010, José Luis García Pallero. All rights reserved.

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
#ifndef _EUCLI_H_
#define _EUCLI_H_
/******************************************************************************/
/******************************************************************************/
#include<math.h>
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la distancia euclídea entre dos puntos en el plano.
\param[in] x1 Coordenada X del punto inicial.
\param[in] y1 Coordenada Y del punto inicial.
\param[in] x2 Coordenada X del punto final.
\param[in] y2 Coordenada Y del punto final.
\return Distancia euclídea entre los dos puntos.
\note Esta función asume que todas las coordenadas vienen dadas en las mismas
      unidades.
\todo Esta función no está probada.
\date 27 de octubre de 2009: Creación de la función.
*/
double Dist2D(const double x1,
              const double y1,
              const double x2,
              const double y2);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la distancia euclídea entre dos puntos en el plano y realiza la
       propagación de errores correspondiente.
\param[in] x1 Coordenada X del punto inicial.
\param[in] y1 Coordenada Y del punto inicial.
\param[in] x2 Coordenada X del punto final.
\param[in] y2 Coordenada Y del punto final.
\param[in] varx1 Varianza de la coordenada X del punto inicial.
\param[in] varx1y1 Covarianza entre las coordenadas X e Y del punto inicial.
\param[in] vary1 Varianza de la coordenada Y del punto inicial.
\param[in] varx2 Varianza de la coordenada X del punto final.
\param[in] varx2y2 Covarianza entre las coordenadas X e Y del punto final.
\param[in] vary2 Varianza de la coordenada Y del punto final.
\param[out] dist Distancia euclídea entre los dos puntos.
\param[out] varDist Varianza de la distancia calculada.
\note Esta función asume que todas las coordenadas vienen dadas en las mismas
      unidades.
\note Las unidades de las matrices de varianza-covarianza han de ser congruentes
      con las de las coordenadas pasadas.
\todo Esta función no está probada.
\date 27 de octubre de 2009: Creación de la función.
*/
void Dist2DVC(const double x1,
              const double y1,
              const double x2,
              const double y2,
              const double varx1,
              const double varx1y1,
              const double vary1,
              const double varx2,
              const double varx2y2,
              const double vary2,
              double* dist,
              double* varDist);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la distancia euclídea entre dos puntos en el espacio.
\param[in] x1 Coordenada X del punto inicial.
\param[in] y1 Coordenada Y del punto inicial.
\param[in] z1 Coordenada Z del punto inicial.
\param[in] x2 Coordenada X del punto final.
\param[in] y2 Coordenada Y del punto final.
\param[in] z2 Coordenada Z del punto final.
\return Distancia euclídea entre los dos puntos.
\note Esta función asume que todas las coordenadas vienen dadas en las mismas
      unidades.
\todo Esta función no está probada.
\date 27 de octubre de 2009: Creación de la función.
*/
double Dist3D(const double x1,
              const double y1,
              const double z1,
              const double x2,
              const double y2,
              const double z2);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la distancia euclídea entre dos puntos en el espacio y realiza la
       propagación de errores correspondiente.
\param[in] x1 Coordenada X del punto inicial.
\param[in] y1 Coordenada Y del punto inicial.
\param[in] z1 Coordenada Z del punto inicial.
\param[in] x2 Coordenada X del punto final.
\param[in] y2 Coordenada Y del punto final.
\param[in] z2 Coordenada Z del punto final.
\param[in] varx1 Varianza de la coordenada X del punto inicial.
\param[in] varx1y1 Covarianza entre las coordenadas X e Y del punto inicial.
\param[in] varx1z1 Covarianza entre las coordenadas X y Z del punto inicial.
\param[in] vary1 Varianza de la coordenada Y del punto inicial.
\param[in] vary1z1 Covarianza entre las coordenadas Y y Z del punto inicial.
\param[in] varz1 Varianza de la coordenada Z del punto inicial.
\param[in] varx2 Varianza de la coordenada X del punto final.
\param[in] varx2y2 Covarianza entre las coordenadas X e Y del punto final.
\param[in] varx2z2 Covarianza entre las coordenadas X y Z del punto final.
\param[in] vary2 Varianza de la coordenada Y del punto final.
\param[in] vary2z2 Covarianza entre las coordenadas Y y Z del punto final.
\param[in] varz2 Varianza de la coordenada Z del punto final.
\param[out] dist Distancia euclídea entre los dos puntos.
\param[out] varDist Varianza de la distancia calculada.
\note Esta función asume que todas las coordenadas vienen dadas en las mismas
      unidades.
\note Las unidades de las matrices de varianza-covarianza han de ser congruentes
      con las de las coordenadas pasadas.
\todo Esta función no está probada.
\date 27 de octubre de 2009: Creación de la función.
*/
void Dist3DVC(const double x1,
              const double y1,
              const double z1,
              const double x2,
              const double y2,
              const double z2,
              const double varx1,
              const double varx1y1,
              const double varx1z1,
              const double vary1,
              const double vary1z1,
              const double varz1,
              const double varx2,
              const double varx2y2,
              const double varx2z2,
              const double vary2,
              const double vary2z2,
              const double varz2,
              double* dist,
              double* varDist);
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
