/*
  Mex file that implements polynomial detrending of a data vector.
 
  M Hewitson  5-02-08
 
  $Id$
 */


#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>

#include "ltpda_polyreg.h"
#include "version.h"
#include "../c_sources/polyreg.c"

#define DEBUG 0

/*
  Matlab mex file to make polynomial detrending of a data vector
 
 * Inputs
 *  - data
 *  - N
 *
  function [y,a] = ltpda_polyreg(x, N);
 
 */
void  mexFunction(  int nlhs,       mxArray *plhs[],
int nrhs, const mxArray *prhs[])
{
  /* Parse inputs */
  if( (nrhs == 0) && (nlhs == 0) )
  {
    print_usage(VERSION);
    return;
  }
  else if ( (nrhs == 2) && (nlhs >= 1) ) /* let's go */
  {
    double   *xdata;
    long int  nData;
    int       order;
    double   *yptr, *aptr;
    
    
    /* Extract inputs */
    xdata     = mxGetPr(prhs[0]);                 /* Pointer to data       */
    nData     = mxGetNumberOfElements(prhs[0]);   /* Number of data points */
    order     = (int)mxGetScalar(prhs[1]);        /* Order of detrending   */
    
    if (order > 10 || order < -1)
      mexErrMsgTxt("Detrending order must be between -1 and 10");
    
    /* Set output matrices */
    plhs[0] = mxCreateDoubleMatrix(nData, 1, mxREAL);
    
    /* Get pointers to output matrices */
    yptr    = mxGetPr(plhs[0]);
    if (nlhs == 2)
    {
      plhs[1] = mxCreateDoubleMatrix(order+1, 1, mxREAL);
      aptr    = mxGetPr(plhs[1]);
    }
    else
    {
      aptr = (double*)mxCalloc(order+1, sizeof(double));  /* detrending output */
    }
  
    /* Detrend segment */
    switch (order)
    {
      case -1:
        /* no detrending */
        memcpy(yptr, xdata, nData*sizeof(double));
        break;
      case 0:
        /* mean removal */
        polyreg0 (xdata, nData, yptr, aptr);
        break;
      case 1:
        /* linear detrending */
        polyreg1 (xdata, nData, yptr, aptr);
        break;
      case 2:
        /* 2nd order detrending */
        polyreg2 (xdata, nData, yptr, aptr);
        break;        
      case 3:
        /* 3rd order detrending */
        polyreg3 (xdata, nData, yptr, aptr);
        break;
      case 4:
        /* 4th order detrending */
        polyreg4 (xdata, nData, yptr, aptr);
        break;
      case 5:
        /* 5th order detrending */
        polyreg5 (xdata, nData, yptr, aptr);
        break;
      case 6:
        /* 6th order detrending */
        polyreg6 (xdata, nData, yptr, aptr);
        break;
      case 7:
        /* 7th order detrending */
        polyreg7 (xdata, nData, yptr, aptr);
        break;
      case 8:
        /* 8th order detrending */
        polyreg8 (xdata, nData, yptr, aptr);
        break;
      case 9:
        /* 9th order detrending */
        polyreg9 (xdata, nData, yptr, aptr);
        break;
      case 10:
        /* 10th order detrending */
        polyreg10(xdata, nData, yptr, aptr);
        break;
    }
    
/*//     if (nlhs == 2)
//     {
//       // Free coefficient array
//       mxFree(aptr);
//     }*/
  }  
  else /* we have an error */
  {
    print_usage(VERSION);
    mexErrMsgTxt("### incorrect usage");
  }
}

/*
 *  Output usage to MATLAB terminal
 *
 */
void print_usage(char *version)
{
  mexPrintf("ltpda_polyreg version %s\n", version);
  mexPrintf("  usage:    function [y, a] = ltpda_polyreg(x, order); \n");
}


