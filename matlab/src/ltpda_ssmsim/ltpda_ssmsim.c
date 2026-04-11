#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>

#include "matrix.h"
#include "version.h"
#include "ltpda_ssmsim.h"

#define DEBUG 0
/*
 * A mex file to propagate an input signal with the given SS model
 *
 * M Hewitson  19-08-10
 *
 * $Id$
 */


/* 
 * function [y,lx] = ltpda_ssmsim(lastX, A.', Coutputs.', Cstates.', Baos.', Daos.', input);
 */
void  mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  
  /* outputs */
  double  *y, *yptr;
  
  /* inputs */
  double *input, *iptr;
  double *Daos, *Dptr;
  double *Baos, *Bptr;
  double *Cstates;
  double *Coutputs, *Coptr;
  double *A, *Aptr;
  double *lastX;
  double *SSini;
  double *tmpX;
  
  mwSize Ninputs, Nsamples, Nstates, Nstatesout, Noutputs;
  int kk,jj,ll;
  int mm,nn;
  int ki;  
  
  
  /* parse input functions */
  
  if( (nrhs == 0) || (nlhs == 0) )
  {
    print_usage(VERSION);
  }
  
  if( (nrhs == 7) && (nlhs == 2) )/* let's go */
  {    
    /*----------------- set inputs*/
    SSini    = mxGetPr(prhs[0]);
    A        = mxGetPr(prhs[1]);
    Coutputs = mxGetPr(prhs[2]);
    Cstates  = mxGetPr(prhs[3]);
    Baos     = mxGetPr(prhs[4]);
    Daos     = mxGetPr(prhs[5]);
    input    = mxGetPr(prhs[6]); 
    
    Ninputs    = mxGetM(prhs[4]);
    Nsamples   = mxGetN(prhs[6]);
    Nstates    = mxGetM(prhs[1]);
    Nstatesout = mxGetM(prhs[3]);
    Noutputs   = mxGetN(prhs[2]);    

    #if DEBUG
    mexPrintf("Ninputs: %d\n", Ninputs);
    mexPrintf("Nsamples: %d\n", Nsamples);
    mexPrintf("Nstates: %d\n", Nstates);
    mexPrintf("Nstatesout: %d\n", Nstatesout);
    mexPrintf("Noutputs: %d\n", Noutputs);
    
    mexPrintf("N Coutputs: %d\n", mxGetNumberOfElements(prhs[2]));  
    
    mexPrintf("input: %dx%d\n", mxGetM(prhs[6]), mxGetN(prhs[6]));
    mexPrintf("D: %dx%d\n", mxGetN(prhs[5]), mxGetM(prhs[5]));    
    #endif
            
    /* output y */
    plhs[0] = mxCreateDoubleMatrix(Noutputs, Nsamples, mxREAL);
    y = mxGetPr(plhs[0]);
    
    /* output state vector*/
    plhs[1] = mxCreateDoubleMatrix(Nstates, 1, mxREAL);
    lastX = mxGetPr(plhs[1]);
    
    tmpX  = (double*)calloc(Nstates, sizeof(double));
    memcpy(lastX, SSini, Nstates*sizeof(double));
    
    /* do the business */
    yptr = &(y[0]);
    for (kk=0; kk<Nsamples; kk++) {
      
      ki = kk*Ninputs;
      
      /* observation equation */
      Coptr = &(Coutputs[0]);
      Dptr  = &(Daos[0]);
      for (jj=0; jj<Noutputs; jj++) {
        *yptr = 0.0;
        for (ll=0; ll<Nstates; ll++) {
          *yptr += *Coptr * lastX[ll] ;
          Coptr++;
        }        
        iptr = &(input[ki]);
        for (ll=0; ll<Ninputs; ll++) {
          *yptr += *Dptr * (*iptr);
          Dptr++;
          iptr++;
        }
        yptr++;
      }  
            
      /* state propagation */
      memcpy(tmpX, lastX, Nstates*sizeof(double));
      Bptr = &(Baos[0]);
      Aptr = &(A[0]);
      for (jj=0; jj<Nstates; jj++) {      
        lastX[jj] = 0;
        for (ll=0; ll<Nstates; ll++) {
          lastX[jj] += *Aptr * tmpX[ll]; 
          Aptr++;
        }        
        iptr = &(input[ki]);
        for (ll=0; ll<Ninputs; ll++) {
          lastX[jj] += *Bptr * (*iptr);
          Bptr++;
          iptr++;
        }
      }  
      
      
    } /* end sample loop */
    
    
    free(tmpX);
    
    
  }
  else
  {
    print_usage(VERSION);
  }
}

void print_usage(char *version)
{
  mexPrintf("ltpda_ssmsim version %s\n", version);
  mexPrintf("  usage:    [y,lx] = ltpda_ssmsim(lastX, A.', Coutputs.', Cstates.', Baos.', Daos.', input);");
  mexErrMsgTxt("### incorrect usage");
}
 