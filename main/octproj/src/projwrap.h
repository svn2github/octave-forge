/* -*- coding: utf-8 -*- */
/**
\defgroup octproj octPROJ module
@{
\file projwrap.h
\brief Functions declaration for PROJ4 wrapper.
\author José Luis García Pallero, jgpallero@gmail.com
\date 05-12-2009
\section License License
This program is free software. You can redistribute it and/or modify it under
the terms of the GNU General Public License (GPL) as published by the Free
Software Foundation (FSF), either version 3 of the License, or (at your option)
any later version.
You can obtain a copy of the GPL or contact with the FSF in: http://www.fsf.org
or http://www.gnu.org
*/
/******************************************************************************/
/******************************************************************************/
#ifndef _PROJWRAP_H_
#define _PROJWRAP_H_
/******************************************************************************/
/******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<proj_api.h>
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def PROJ_ERR_NOT_INV_PROJ
\brief Error identifier from PROJ.4. Do not exist inverse step for a defined
       projection.
\date 13-04-2012: Constant creation.
*/
#define PROJ_ERR_NOT_INV_PROJ -17
/******************************************************************************/
/******************************************************************************/
/**
\def PROJWRAP_ERR_NOT_INV_PROJ
\brief Error identifier. Do not exist inverse step for a defined projection.
\date 12-12-2009: Constant creation.
*/
#define PROJWRAP_ERR_NOT_INV_PROJ 10001
/******************************************************************************/
/******************************************************************************/
/**
\brief Wrapper around pj_fwd.
\param[in,out] u Array containing the geodetic longitude, in radians. On output,
               this argument contains the X projected coordinates.
\param[in,out] v Array containing the geodetic latitude, in radians. On output,
               this argument contains the Y projected coordinates.
\param[in] nElem Number of elements in \em u and \em v arrays.
\param[in] incElem Number of positions between each element in the arrays \em u
           and \em v (must be a positive number).
\param[in] params List containing the parameters of the projection, in PROJ.4
           format with \p + signs (see PROJ.4 manual).
\param[out] errorText If an error occurs, explanation text about the error.
\param[out] projectionError Two posibilities:
            - 0: All projected points are OK.
            - Otherwise: Some points have been projected with errors. This value
              only have sense if the returning error code of the function is not
              0.
\return Error code. Two posibilities:
        - 0: No error.
        - Otherwise: Error code of PROJ.4, see documentation.
\note If projection errors occur, the positions of the erroneous points in
      \em u and \em v arrays store the value HUGE_VAL (constant from math.h).
\date 12-12-2009: Function creation.
\date 13-05-2011: Change the name of \em lon and \em lat variables to \em u and
      \em v, add the new variable \em incElem and use internally \em projLP and
      \em projXY stryctures instead only \em projXY (actually, both are
      synonyms).
*/
int proj_fwd(double* u,
             double* v,
             const size_t nElem,
             const size_t incElem,
             const char params[],
             char errorText[],
             int* projectionError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Wrapper around pj_inv.
\param[in,out] u Array containing the X projected coordinates. On output, this
               argument contains the geodetic longitude, in radians.
\param[in,out] v Array containing the Y projected coordinates. On output, this
               argument contains the geodetic latitude, in radians.
\param[in] nElem Number of elements in \em u and \em v arrays.
\param[in] incElem Number of positions between each element in the arrays \em u
           and \em v (must be a positive number).
\param[in] params List containing the parameters of the projection, in PROJ.4
           format with \p + signs (see PROJ.4 manual).
\param[out] errorText If an error occurs, explanation text about the error.
\param[out] projectionError Two posibilities:
            - 0: All projected points are OK.
            - Otherwise: Some points have been projected with errors. This value
              only have sense if the returning error code of the function is not
              0 nor #PROJWRAP_ERR_NOT_INV_PROJ.
\return Error code. Three posibilities:
        - 0: No error.
        - #PROJWRAP_ERR_NOT_INV_PROJ: Do not exist inverse step for the defined
          projection.
        - Otherwise: Error code of PROJ.4, see documentation.
\note If projection errors occur, the positions of the erroneous points in
      \em u and \em v arrays store the value HUGE_VAL (constant from math.h).
\date 12-12-2009: Function creation.
\date 13-05-2011: Change the name of \em x and \em y variables to \em u and
      \em v, add the new variable \em incElem and use internally \em projLP and
      \em projXY stryctures instead only \em projXY (actually, both are
      synonyms).
*/
int proj_inv(double* u,
             double* v,
             const size_t nElem,
             const size_t incElem,
             const char params[],
             char errorText[],
             int* projectionError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Wrapper around pj_transform.
\param[in,out] u Array containing the first coordinate. On output, this argument
                 contains the transformed coordinates. This array can store two
                 types of values:
                 - If the system (start or end) is geodetic, this array contains
                   geodetic longitude, in radians.
                 - Otherwise (geocentric or cartographic coordinates) this array
                   contains \em X euclidean coordinates.
\param[in,out] v Array containing the second coordinate. On output, this argument
                 contains the transformed coordinates. This array can store two
                 types of values:
                 - If the system (start or end) is geodetic, this array contains
                   geodetic latitude, in radians.
                 - Otherwise (geocentric or cartographic coordinates) this array
                   contains \em Y euclidean coordinates.
\param[in,out] z Array containing ellipsoidal heights. This argument can be
               \p NULL. In that case it is not used.
\param[in] nElem Number of elements in \em u, \em v and \em z arrays.
\param[in] incElem Number of positions between each element in the arrays \em u,
           \em v and \em z (must be a positive number).
\param[in] paramsStart List containing the parameters of the start system, in
           PROJ.4 format.
\param[in] paramsEnd List containing the parameters of the end system, in PROJ.4
           format.
\param[out] errorText If an error occurs, explanation text about the error. This
            argument must be assigned enough memory.
\return Error code. Two posibilities:
        - 0: No error.
        - Otherwise: Error code of pj_init_plus() or pj_transform() PROJ.4
          functions. See PROJ.4 documentation.
\date 05-12-2009: Function creation.
\date 13-05-2011: Change the name of \em x and \em y variables to \em u and
      \em v and add the new variable \em incElem.
*/
int proj_transform(double* u,
                   double* v,
                   double* z,
                   const size_t nElem,
                   const size_t incElem,
                   const char paramsStart[],
                   const char paramsEnd[],
                   char errorText[]);
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
