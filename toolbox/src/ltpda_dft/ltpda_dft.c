/*
 * Mex file that implements the core DFT part of the LPSD algorithm.
 *
 * M Hewitson  15-01-08
 *
 * $Id$
 */


#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>

#include "ltpda_dft.h"
#include "version.h"
#include "../c_sources/polyreg.c"

#define DEBUG 0


/*
 * Rounding function
 *
 */
int myround(double x) {
  return ((int) (floor(x + 0.5)));
}


/*
 * Matlab mex file to make a dft at a single frequency
 *
 * Inputs
 *  - data
 *  - seg length
 *  - DFT coefficients
 *  - overlap (%)
 *  - order of detrending
 *
 * function [P, navs] = ltpda_dft(x, seglen, DFTcoeffs, olap, order);
 *
 */
void  mexFunction(  int nlhs,       mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
  /* Parse inputs */
  if( (nrhs == 0) && (nlhs == 0) ) {
    print_usage(VERSION);
    return;
  }
  else if ( (nrhs == 5) && (nlhs == 3) ) /* let's go */ {
    double    Pr, Vr;
    double   *xdata, *Cr, *Ci;
    double    olap;
    long int  nData;
    long int  nSegs;
    long int  segLen;
    int       order;
    double   *ptr;
    
    if( !mxIsComplex(prhs[2]) )
      mexErrMsgTxt("DFT coefficients must be complex.\n");
    
    /* Extract inputs */
    xdata     = mxGetPr(prhs[0]);                 /* Pointer to data */
    nData     = mxGetNumberOfElements(prhs[0]);   /* Number of data points */
    segLen    = (int)mxGetScalar(prhs[1]);        /* Segment length */
    Cr        = mxGetPr(prhs[2]);                 /* Real part of DFT coefficients */
    Ci        = mxGetPi(prhs[2]);                 /* Imag part of DFT coefficients */
    olap      = mxGetScalar(prhs[3]);             /* Overlap percentage */
    order     = (int)mxGetScalar(prhs[4]);        /* Order of detrending */
    
    if (order > 10 || order < -1)
      mexErrMsgTxt("Detrending order must be between -1 and 10");
    
    /*mexPrintf("Input data: %d samples\n", nData);*/
    /*mexPrintf("Segment length: %d\n", segLen);*/
    /*mexPrintf("Overlap: %f\n", olap);*/
    
    /* Compute DFT */
    dft(&Pr, &Vr, &nSegs, xdata, nData, segLen, Cr, Ci, olap, order);
    
    /* Set output matrices */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    plhs[2] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    
    /* Get pointers to output matrices */
    ptr    = mxGetPr(plhs[0]);
    ptr[0] = Pr;
    ptr    = mxGetPr(plhs[1]);
    ptr[0] = Vr;
    ptr    = mxGetPr(plhs[2]);
    ptr[0] = nSegs;
    
  }
  else if ( (nrhs == 6) && (nlhs == 5) ) /* let's go */ {
    double    Mr, Mi, XX, YY, M2;
    double   *xdata, *ydata, *Cr, *Ci;
    double    olap;
    long int  nData, nxData, nyData;
    long int  nSegs;
    long int  segLen;
    int       order;
    double   *ptr;
    
    if( !mxIsComplex(prhs[3]) )
      mexErrMsgTxt("DFT coefficients must be complex.\n");
    
    /* Extract inputs */
    xdata     = mxGetPr(prhs[0]);                 /* Pointer to data */
    ydata     = mxGetPr(prhs[1]);                 /* Pointer to data */
    nxData    = mxGetNumberOfElements(prhs[0]);   /* Number of data points */
    nyData    = mxGetNumberOfElements(prhs[0]);   /* Number of data points */
    segLen    = (int)mxGetScalar(prhs[2]);        /* Segment length */
    Cr        = mxGetPr(prhs[3]);                 /* Real part of DFT coefficients */
    Ci        = mxGetPi(prhs[3]);                 /* Imag part of DFT coefficients */
    olap      = mxGetScalar(prhs[4]);             /* Overlap percentage */
    order     = (int)mxGetScalar(prhs[5]);        /* Order of detrending */
    
    if (order > 10 || order < -1)
      mexErrMsgTxt("Detrending order must be between -1 and 10");
    
    if (nxData != nyData)
      mexErrMsgTxt("The two input data vector should be the same length.");
    
    nData = nxData;
    
    /*mexPrintf("Input data: %d samples\n", nData);*/
    /*mexPrintf("Segment length: %d\n", segLen);*/
    /*mexPrintf("Overlap: %f\n", olap);*/
    
    /* Compute DFT */
    xdft(&Mr, &Mi, &XX, &YY, &M2, &nSegs, xdata, ydata, nData, segLen, Cr, Ci, olap, order);
    
    /* Set output matrices */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[4] = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    /* Get pointers to output matrices */
    ptr    = mxGetPr(plhs[0]);
    ptr[0] = Mr;
    ptr    = mxGetPi(plhs[0]);
    ptr[0] = Mi;
    ptr    = mxGetPr(plhs[1]);
    ptr[0] = XX;
    ptr    = mxGetPr(plhs[2]);
    ptr[0] = YY;
    ptr    = mxGetPr(plhs[3]);
    ptr[0] = M2;
    ptr    = mxGetPr(plhs[4]);
    ptr[0] = nSegs;
    
    
  }
  else /* we have an error */ {
    print_usage(VERSION);
    mexErrMsgTxt("### incorrect usage");
  }
}

/*
 *  Output usage to MATLAB terminal
 *
 */
void print_usage(char *version) {
  mexPrintf("ltpda_dft version %s\n", version);
  mexPrintf("  usage:    function [P, navs] = ltpda_dft(x, seglen, DFTcoeffs, olap, order); \n");
}

/*
 * Short routine to compute the DFT at a single frequency
 *
 */
void dft(double *Pr, double *Vr, long int *Navs,
        double *xdata, long int nData, long int segLen, double *Cr, double *Ci, double olap, int order) {
  long int  istart;
  double    shift, start;
  double    *px, *cr, *ci;
  double    rxsum, ixsum;
  double    Xr, Mr, M2, Qr;
  double    p, *x, *a;
  long int  jj, ii;
    
  
  /* Compute the number of averages we want here */
  double   ovfact = 1. / (1. - olap / 100.);
  double   davg = ((double) ((nData - segLen)) * ovfact) / segLen + 1;
  long int navg = myround(davg);
    
  /* Compute steps between segments */
  if (navg == 1)
    shift = 1;
  else
    shift = (double) (nData - segLen) / (double) (navg - 1);
  
  if (shift < 1)
    shift = 1;
  
  /*   mexPrintf("Seglen: %d\t | Shift: %f\t | navs: %d\n", segLen, shift, navg);*/
  
  /* allocate vectors */
  x = (double*)mxCalloc(segLen, sizeof(double));  /* detrending output */
  a = (double*)mxCalloc(order+1, sizeof(double)); /* detrending coefficients */
  
  /* Loop over segments */
  start = 0.0;
  Xr = 0.0;
  Qr = 0.0;
  Mr = 0.0;
  M2 = 0.0;
  
  for (ii = 0; ii < navg; ii++) {
    /* compute start index */
    istart = myround(start);
    start += shift;
    
    /* pointer to start of this segment */
    px = &(xdata[istart]);
    
    /* pointer to DFT coeffs */
    cr = &(Cr[0]);
    ci = &(Ci[0]);
    
    /* Detrend segment */
    switch (order) {
      case -1:
        /* no detrending */
        memcpy(x, px, segLen*sizeof(double));
        break;
      case 0:
        /* mean removal */
        polyreg0(px, segLen, x, a);
        break;
      case 1:
        /* linear detrending */
        polyreg1(px, segLen, x, a);
        break;
      case 2:
        /* 2nd order detrending */
        polyreg2(px, segLen, x, a);
        break;
      case 3:
        /* 3rd order detrending */
        polyreg3(px, segLen, x, a);
        break;
      case 4:
        /* 4th order detrending */
        polyreg4(px, segLen, x, a);
        break;
      case 5:
        /* 5th order detrending */
        polyreg5(px, segLen, x, a);
        break;
      case 6:
        /* 6th order detrending */
        polyreg6(px, segLen, x, a);
        break;
      case 7:
        /* 7th order detrending */
        polyreg7(px, segLen, x, a);
        break;
      case 8:
        /* 8th order detrending */
        polyreg8(px, segLen, x, a);
        break;
      case 9:
        /* 9th order detrending */
        polyreg9(px, segLen, x, a);
        break;
      case 10:
        /* 10th order detrending */
        polyreg10(px, segLen, x, a);
        break;
    }
    
    /* Go over all samples in this segment */
    rxsum = ixsum = 0.0;
    for (jj=0; jj<segLen; jj++) {
      p      = x[jj];
      rxsum += (*cr) * p; /* cos term */
      ixsum += (*ci) * p; /* sin term */
      
      /* increment pointers */
      cr++;
      ci++;
    }
    /*mexPrintf("   xsum=(%g +i %g), ysum=(%g + i%g)\n", rxsum, ixsum, rysum, iysum);*/
    
    /* Average the cross-power
     * Rsum += rxsum*rxsum + ixsum*ixsum;
     */
    
    /* Welford's algorithm to update mean and variance */
    if (ii == 0) {
      Mr = (rxsum*rxsum + ixsum*ixsum);
    } else {
      Xr = (rxsum*rxsum + ixsum*ixsum);
      Qr = Xr - Mr;
      Mr += Qr/ii;
      M2 += Qr * (Xr - Mr);
    }
    
  }
  
  /* mexPrintf("     start: %f \t istart: %d | %d \n", start, istart, nData-istart);*/
  /*mexPrintf(" Rsum=%g, MR=%g \n", Rsum,MR); */
  
  /* clean up */
  mxFree(x);
  mxFree(a);
  
  /* Outputs */
  *Pr = Mr;
  if(navg == 1){
    *Vr = Mr*Mr;
  } else {
    *Vr = M2/(navg-1);
  }
  *Navs = navg;
}

/*
 * Short routine to compute the cross-DFT at a single frequency
 *
 */
void xdft(double *Pxyr, double *Pxyi, double *Pxx, double *Pyy, double *Vr, long int *Navs,
        double *xdata, double *ydata, long int nData, long int segLen, double *Cr, double *Ci, double olap, int order) {
  long int  istart;
  double    shift, start;
  double    *px, *py, *cr, *ci;
  double    rxsum, ixsum, rysum, iysum;
  double    XYr, XYi, QXYr, QXYi, QXYrn, QXYin;
  double    MXYr, MXYi, MXY2;
  double    XX, YY, QXX, QYY;
  double    MXX, MYY, MXX2, MYY2;
  double    p, *x, *y, *a;
  double    ct, st;
  long int  jj, ii;
  
  /* Compute the number of averages we want here */
  double   ovfact = 1. / (1. - olap / 100.);
  double   davg = ((double) ((nData - segLen)) * ovfact) / segLen + 1;
  long int navg = myround( davg );
  
  /* Compute steps between segments */
  if (navg == 1)
    shift = 1;
  else
    shift = (double) (nData - segLen) / (double) (navg - 1);
  
  if (shift < 1)
    shift = 1;
  
  /* mexPrintf("Seglen: %d\t | Shift: %f\t | navs: %d\n", segLen, shift, navg); */
  
  /* allocate vectors */
  y = (double*)mxCalloc(segLen, sizeof(double));  /* detrending output */
  x = (double*)mxCalloc(segLen, sizeof(double));  /* detrending output */
  a = (double*)mxCalloc(order+1, sizeof(double)); /* detrending coefficients */
  
  /* Loop over segments */
  start = 0.0;
  MXYr  = 0.0;
  MXYi  = 0.0;
  MXY2   = 0.0;
  MXX   = 0.0;
  MYY   = 0.0;
  MXX2 = 0.0;
  MYY2 = 0.0;
  
  for (ii = 0; ii < navg; ii++) {
    /* compute start index */
    istart = myround(start);
    start += shift;
    
    /* pointer to start of this segment */
    px = &(xdata[istart]);
    py = &(ydata[istart]);
    
    /* pointer to DFT coeffs */
    cr = &(Cr[0]);
    ci = &(Ci[0]);
    
    /* Detrend segment */
    switch (order) {
      case -1:
        /* no detrending */
        memcpy(x, px, segLen*sizeof(double));
        memcpy(y, py, segLen*sizeof(double));
        break;
      case 0:
        /* mean removal */
        polyreg0(px, segLen, x, a);
        polyreg0(py, segLen, y, a);
        break;
      case 1:
        /* linear detrending */
        polyreg1(px, segLen, x, a);
        polyreg1(py, segLen, y, a);
        break;
      case 2:
        /* 2nd order detrending */
        polyreg2(px, segLen, x, a);
        polyreg2(py, segLen, y, a);
        break;
      case 3:
        /* 3rd order detrending */
        polyreg3(px, segLen, x, a);
        polyreg3(py, segLen, y, a);
        break;
      case 4:
        /* 4th order detrending */
        polyreg4(px, segLen, x, a);
        polyreg4(py, segLen, y, a);
        break;
      case 5:
        /* 5th order detrending */
        polyreg5(px, segLen, x, a);
        polyreg5(py, segLen, y, a);
        break;
      case 6:
        /* 6th order detrending */
        polyreg6(px, segLen, x, a);
        polyreg6(py, segLen, y, a);
        break;
      case 7:
        /* 7th order detrending */
        polyreg7(px, segLen, x, a);
        polyreg7(py, segLen, y, a);
        break;
      case 8:
        /* 8th order detrending */
        polyreg8(px, segLen, x, a);
        polyreg8(py, segLen, y, a);
        break;
      case 9:
        /* 9th order detrending */
        polyreg9(px, segLen, x, a);
        polyreg9(py, segLen, y, a);
        break;
      case 10:
        /* 10th order detrending */
        polyreg10(px, segLen, x, a);
        polyreg10(py, segLen, y, a);
        break;
    }
    
    /* Go over all samples in this segment */
    rxsum = ixsum = 0.0;
    rysum = iysum = 0.0;
    for (jj=0; jj<segLen; jj++) {
      ct     = (*cr);
      st     = (*ci);
      p      = x[jj];
      rxsum += ct * p; /* cos term */
      ixsum += st * p; /* sin term */
      p      = y[jj];
      rysum += ct * p; /* cos term */
      iysum += st * p; /* sin term */
      
      /* increment pointers */
      cr++;
      ci++;
    }
    /*mexPrintf("   xsum=(%g +i %g), ysum=(%g + i%g)\n", rxsum, ixsum, rysum, iysum);*/
    
    /* Average XX and YY power
     * XXsum  += rxsum*rxsum + ixsum*ixsum;
     * YYsum  += rysum*rysum + iysum*iysum;
     * XYRsum += rysum*rxsum + iysum*ixsum;
     * XYIsum += iysum*rxsum - rysum*ixsum; */
    
    /* Welford's algorithm to update mean and variance for cross-power */
    if (ii == 0) {
      /* for XY  */
      MXYr = rysum*rxsum + iysum*ixsum;
      MXYi = iysum*rxsum - rysum*ixsum;
      /* for XX  */
      MXX = rxsum*rxsum + ixsum*ixsum;
      /* for YY  */
      MYY = rysum*rysum + iysum*iysum;
    } else {
      /* for XY cross - power */
      XYr = rysum*rxsum + iysum*ixsum;
      XYi = iysum*rxsum - rysum*ixsum;
      QXYr = XYr - MXYr;
      QXYi = XYi - MXYi;
      MXYr += QXYr/ii;
      MXYi += QXYi/ii;
      /* new Qs, using new mean */
      QXYrn = XYr - MXYr;
      QXYin = XYi - MXYi;
      /* taking abs to get real variance */
      MXY2 += sqrt(pow(QXYr * QXYrn - QXYi * QXYin, 2) + pow(QXYr * QXYin + QXYi * QXYrn, 2));
      /* for XX  */
      XX = rxsum*rxsum + ixsum*ixsum;
      QXX = XX - MXX;
      MXX += QXX/ii;
      MXX2 += QXX*(XX - MXX);
      /* for YY  */
      YY = rysum*rysum + iysum*iysum;
      QYY = YY - MYY;
      MYY += QYY/ii;
      MYY2 += QYY*(YY - MYY);      
    }
    
  }
  
  /* mexPrintf("     start: %f \t istart: %d | %d \n", start, istart, nData-istart);*/
  /*mexPrintf(" Rsum=%g, Isum=%g\n", Rsum, Isum);*/
  
  /* clean up */
  mxFree(y);
  mxFree(x);
  mxFree(a);
  
  /* Outputs */
  *Pxyr = MXYr;
  *Pxyi = MXYi;
  if(navg == 1){
    *Vr = MXYr*MXYr; /* set to mean^2 here, but at the end returns Inf in the ao.dy field */
  } else {
    *Vr = MXY2/(navg-1);
  }
  *Pxx  = MXX;
  *Pyy  = MYY;      /* we don't return variance for XX and YY  */
  *Navs = navg;
}

/*
 * Fast linear detrending routine
 *
 */
void remove_linear_drift(double *segm, double *data, int nfft) {
  int i;
  long double sx, sy, stt, sty, a, b, xm;
  
  sx  = (long double) nfft *(long double) (nfft - 1) / 2.0L;
  xm  = (long double) (nfft - 1) / 2.0L;
  stt = ((long double) nfft * (long double) nfft * (long double) nfft - (long double)	 nfft) / 12.0L;
  
  sy=sty = 0;
  for (i = 0; i < nfft; i++) {
    sy += data[i];
    sty += (i-xm) * data[i];
  }
  b = sty / stt;
  a = (sy - sx * b) / nfft;
  for (i = 0; i < nfft; i++) {
    segm[i] = data[i] - (a + b * i);
  }
}


