/*
	Header for mfnest.c

	$Id$
*/

/* from mnfest.c */
void print_usage(char *version);
int smooth(double *nxx, double *xx, int nx, int bw, double ol, char *method);
double median(double *x, int nx);
double mean(double *x, int nx);
double smax(double *x, int nx);
double smin(double *x, int nx);


/* from quick.c */
 int quickSort(double *arr, int elements);

