/* -*- coding: utf-8 -*- */
/**
\ingroup octproj
@{
\file projwrap.c
\brief Functions definition for PROJ4 wrapper.
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
#include"projwrap.h"
/******************************************************************************/
/******************************************************************************/
int proj_fwd(double* u,
             double* v,
             const size_t nElem,
             const size_t incElem,
             const char params[],
             char errorText[],
             int* projectionError)
{
    //error code
    int* idErr=NULL;
    //index for loop
    size_t i=0;
    //position in the arrays
    size_t pos=0;
    //input and output coordinates
    projLP in;
    projXY out;
    //proj structure
    projPJ pjStruct;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //projection initialization
    pjStruct = pj_init_plus(params);
    if(!pjStruct)
    {
        //error code
        idErr = pj_get_errno_ref();
        //error text
        sprintf(errorText,"Projection parameters\n\t%s\n\t%s",
                pj_strerrno(*idErr),params);
        //exit
        return *idErr;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //projection error initialization
    *projectionError = 0;
    //transformation
    for(i=0;i<nElem;i++)
    {
        //position in the arrays
        pos = i*incElem;
        //assign input coordinates
        in.u = u[pos];
        in.v = v[pos];
        //projection
        out = pj_fwd(in,pjStruct);
        //testing of results
        if((out.u==HUGE_VAL)||(out.v==HUGE_VAL))
        {
            //the two coordinates must be HUGE_VAL
            out.u = HUGE_VAL;
            out.v = HUGE_VAL;
            //assign error code
            idErr = pj_get_errno_ref();
            //error text (only the first time)
            if(pos==0)
            {
                //error text
                sprintf(errorText,"Projection error\n\t%s",pj_strerrno(*idErr));
            }
            //projection error identificator
            *projectionError = 1;
        }
        //assign output coordinates
        u[pos] = out.u;
        v[pos] = out.v;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //memory free
    pj_free(pjStruct);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    if(*projectionError)
    {
        return *idErr;
    }
    else
    {
        return 0;
    }
}
/******************************************************************************/
/******************************************************************************/
int proj_inv(double* u,
             double* v,
             const size_t nElem,
             const size_t incElem,
             const char params[],
             char errorText[],
             int* projectionError)
{
    //error code
    int* idErr=NULL;
    //index for loop
    size_t i=0;
    //position in the arrays
    size_t pos=0;
    //input and output coordinates
    projXY in;
    projLP out;
    //proj structure
    projPJ pjStruct;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //projection initialization
    pjStruct = pj_init_plus(params);
    if(!pjStruct)
    {
        //error code
        idErr = pj_get_errno_ref();
        //error text
        sprintf(errorText,"Projection parameters\n\t%s\n\t%s",
                pj_strerrno(*idErr),params);
        //exit
        return *idErr;
    }
    //test if inverse step exist
    if(pjStruct->inv==0)
    {
        //error text
        sprintf(errorText,"Inverse step do not exists\n\t%s",params);
        //exit
        return PROJWRAP_ERR_NOT_INV_PROJ;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //projection error initialization
    *projectionError = 0;
    //transformation
    for(i=0;i<nElem;i++)
    {
        //position in the arrays
        pos = i*incElem;
        //assign input coordinates
        in.u = u[pos];
        in.v = v[pos];
        //projection
        out = pj_inv(in,pjStruct);
        //testing of results
        if((out.u==HUGE_VAL)||(out.v==HUGE_VAL))
        {
            //the two coordinates must be HUGE_VAL
            out.u = HUGE_VAL;
            out.v = HUGE_VAL;
            //assign error code
            idErr = pj_get_errno_ref();
            //error text (only the first time)
            if(pos==0)
            {
                //error text
                sprintf(errorText,"Projection error\n\t%s",pj_strerrno(*idErr));
            }
            //projection error identificator
            *projectionError = 1;
        }
        //assign output coordinates
        u[pos] = out.u;
        v[pos] = out.v;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //memory free
    pj_free(pjStruct);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    if(*projectionError)
    {
        return *idErr;
    }
    else
    {
        return 0;
    }
}
/******************************************************************************/
/******************************************************************************/
int proj_transform(double* u,
                   double* v,
                   double* z,
                   const size_t nElem,
                   const size_t incElem,
                   const char paramsStart[],
                   const char paramsEnd[],
                   char errorText[])
{
    //error codes
    int* idErr1=NULL;
    int idErr2=0;
    //proj structures
    projPJ pjStart;
    projPJ pjEnd;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //start projection initialization
    pjStart = pj_init_plus(paramsStart);
    if(!pjStart)
    {
        //error code
        idErr1 = pj_get_errno_ref();
        //error text
        sprintf(errorText,"Start system parameters\n\t%s\n\t%s",
                pj_strerrno(*idErr1),paramsStart);
        //exit
        return *idErr1;
    }
    //end projection initialization
    pjEnd = pj_init_plus(paramsEnd);
    if(!pjEnd)
    {
        //error code
        idErr1 = pj_get_errno_ref();
        //error text
        sprintf(errorText,"End system parameters\n\t%s\n\t%s",
                pj_strerrno(*idErr1),paramsEnd);
        //free memory
        pj_free(pjStart);
        //exit
        return *idErr1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //transformation
    idErr2 = pj_transform(pjStart,pjEnd,nElem,incElem,u,v,z);
    //catching possible errors
    if(idErr2)
    {
        //error text
        sprintf(errorText,"Projection error\n\t%s",pj_strerrno(idErr2));
        //memory free
        pj_free(pjStart);
        pj_free(pjEnd);
        //exit
        return idErr2;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //memory free
    pj_free(pjStart);
    pj_free(pjEnd);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return idErr2;
}
/******************************************************************************/
/******************************************************************************/
/** @} */
