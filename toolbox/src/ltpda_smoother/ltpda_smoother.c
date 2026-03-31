#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>

#include "version.h"
#include "ltpda_smoother.h"
#include "quick.c"

#define DEBUG 0
/*
 * A smoother function that uses various methods to smooth data.
 *
 * M Hewitson  28-08-01
 *
 * $Id$
 */


/*
   function sy = ltpda_smoother(y, bw, ol, method);
 
 */
void  mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int status;
  int buff_len;
  
  /* outputs */
  double  *outputPtr;
  double  *nxx;
  int      a;
  
  /* inputs */
  double *xx;
  int     bw;
  double  ol;
  int     nx;
  char   *method;
  
  /* parse input functions */
  
  if( (nrhs == 0) || (nlhs == 0) )
  {
    print_usage(VERSION);
  }
  
  if( (nrhs == 4) && (nlhs == 1) )/* let's go */
  {    
    /*----------------- set inputs*/
    xx = mxGetPr(prhs[0]);
    bw = (int)floor(mxGetScalar(prhs[1]));
    ol = mxGetScalar(prhs[2]);
    nx = mxGetNumberOfElements(prhs[0]);

    /* Read the method*/
    buff_len = (mxGetM(prhs[3]) * mxGetN(prhs[3])) + 1;
    method = mxCalloc(buff_len, sizeof(char));
    status = mxGetString(prhs[3], method, buff_len);
    if(status != 0) 
      mexWarnMsgTxt("Not enough space. String is truncated.");
    
    /* create output vector*/
    nxx = (double*)mxCalloc(nx, sizeof(double));
    
    /* nfest*/
    smooth(nxx, xx, nx, bw, ol, method);
    
    /* output noise-floor vector*/
    plhs[0] = mxCreateDoubleMatrix(1,nx,mxREAL);
    outputPtr = mxGetPr(plhs[0]);
    for(a=0; a<nx; a++)
      outputPtr[a] = nxx[a];
    
    mxFree(nxx);
  }
  else
  {
    print_usage(VERSION);
  }
}

void print_usage(char *version)
{
  mexPrintf("ltpda_smoother version %s\n", version);
  mexPrintf("  usage:    function sy = ltpda_smoother(y, bw, ol, method); \n");
  mexErrMsgTxt("### incorrect usage");
}
/*
 * Smoother
 */
int smooth(double *nxx, double *xx, int nx, int bw, double ol, char *method)
{
  int     k, j, idx;
  int     hbw;
  double *seg;
  
  seg = (double*)mxCalloc(bw+1, sizeof(double));
  
  /* go through each element */  
  for(k=0; k<nx; k++)
  {
    /* get segment*/
    for(j=0; j<=bw; j++)
    {
      idx = k+j-bw/2;
      if (idx<0)
        idx = 0;
      if (idx>=nx)
        idx = nx-1;      
      seg[j] = xx[idx];
    }
    /* sort segment*/
    quickSort(seg, bw-1);
    /* stop index*/
    idx = (int)floor(ol*bw);
    /* Which smoothing method? */
    if (strcmp(method, "median")==0)
    {
      /* make median estimate of selected samples */
      nxx[k] = median(seg, idx);
    }
    else if (strcmp(method, "mean")==0)
    {
      /* make mean estimate of selected samples */
      nxx[k] = mean(seg, idx);
    }
    else if (strcmp(method, "min")==0)
    {
      /* make min estimate of selected samples */
      nxx[k] = smin(seg, idx);
    }
    else if (strcmp(method, "max")==0)
    {
      /* make max estimate of selected samples */
      nxx[k] = smax(seg, idx);
    }
  }
  
  /* Clean up */
  mxFree(seg);
  
  return 0;
}


double smin(double *x, int nx)
{
  double m;
  int    j;
  
  m = x[0];
  
  for (j=1; j<nx; j++)
    if (x[j] < m)
      m = x[j];

  return m;  
}

double smax(double *x, int nx)
{
  double m;
  int    j;
  
  m = x[0];
  
  for (j=1; j<nx; j++)
    if (x[j] > m)
      m = x[j];

  return m;  
}

double mean(double *x, int nx)
{
  int    j;
  double sx = 0.0;
  
  for (j=0; j<nx; j++)
    sx += x[j];

  return sx/nx;  
}

double median(double *x, int nx)
{
  double m;
  
  if (nx%2 == 0) /* even*/
    m = (x[nx/2] + x[nx/2 -1])/2.0;
  else
    m = x[(nx-1)/2];
  
  return m;
}
