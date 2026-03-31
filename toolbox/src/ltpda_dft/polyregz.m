(*

/home/ghh/math/polyreg/polyregz.m  17.01.2008 Gerhard Heinzel AEI

This is version 1.1

history:
 version 1.0 17.1.08 initial release
 version 1.1 18.1.08 fixed two typos in comment

Mathematica code to produce C code for efficient polynomial detrending

The polynomials are defined in terms of z = 2i/(n-1)-1, i=0...n
such that the range 0...n-1 is mapped to -1...+1 

Thereby the high dynamic range of i^n is reduced to -1..1,
and furthermore every second entry in the matrix of
the normal equations and its inverse vanishes due to symmetry.

The regression is done via explicit solution of the normal equations.

These are of dimension (p+1) for degree p:

( s_0 s_1 s_2 .. s_p    )  ( a_0 )  = ( b_0 ) 
( s_1 s_2 s_3 .. s_p+1  )  ( a_1 )    ( b_1 )
( ...                   )  ( ... )    ( ... )
( s_p s_p+1 .. s_2p     )  ( a_p )    ( b_p )

with 
s_k = Sum(i=0...n-1) z^k,
b_k = Sum(i=0...n-1) x_i z^k,
a_k = The unknown coefficient of z^k in the best-fit regression.

The Matrix with s depends only on p and n, not on the data.

The Mathematica code below finds exact explicit expressions for 
the Matrix and its Inverse and writes the corresponding C code.

If any modifications of the C code are desired apart from "indent"ing,
this file below should be altered but not the C code.

*)

<<clear.m

(*
<<polyregz.m
*)

z[i_,n_] := 2 i /(n-1) -1;

s[k_,n_] := Sum[z[i,n]^k,{i,0,n-1}];

m[n_,p_] := Table[s[i+j,n],{i,0,p},{j,0,p}];

sol[p_] := sol[p] = Simplify[Inverse[m[n, p]]];

cln[x_] := CoefficientList[Numerator[x],n];
cld[x_] := CoefficientList[Denominator[x],n];

max[x_] := Max[cln[x],cld[x]];

pn[x_] := "0" /; x== 0;
pn[x_] := ToString[CForm[x]] <> "L";

ncln[x_] := Map[pn, N[cln[x] / max[x], 22]];
ncld[x_] := Map[pn, N[cld[x] / max[x], 22]];

polyprint[p_, x_] := p[[1]] /; Length[p]==1;
polyprint[p_, x_] := "(" <> polyprint[Drop[p,1], x] <> " * " <> x <> " + " <> p[[1]] <> ")" /; Length[p]>1 ;

cform[x_] := "0" /; FreeQ[x,n];
cform[x_] := polyprint[ncln[x], "n"] <> " / " <> polyprint[ncld[x], "n"];

wlist[sbeg_, list_, sep_, send_] := 
  Write[fp, sbeg <> Apply[StringJoin, Riffle[list, sep]] <> send];

out[p_] := Module[ {fn, s, i, j, s1, list},
  fn="polyreg"<>ToString[p] <> ".c";
  fp=OpenWrite[fn,FormatType->OutputForm, PageWidth->1024];
  Write[fp,"void"];
  Write[fp,"polyreg",p," (double *x, int nn, double *y, double *a)"];
  Write[fp,"{"];
  Write[fp,""];
  Write[fp,"/*"];
  Write[fp,"polynominal detrending of a time series, order ",p];
  Write[fp,"machine-generated file, do not edit!"];
  Write[fp,"made by polyregz.m (Mathematica )"];
  Write[fp,"Gerhard Heinzel AEI 17.01.2008"];
  Write[fp,""];
  Write[fp,"x[]: input, read-only: time series to be detrended"];
  Write[fp,"nn: input, read-only: length of x[]"];
  Write[fp,"y[]: output: time series with trend subtracted"];
  Write[fp,"a[]: fitting coefficients in for z^0, z^1, z^2,... with"];
  Write[fp,"     z = 2*i/(nn-1)-1 ; i=0,...,nn-1"];
  Write[fp,"*/"];
  Write[fp,""];
 Write[fp,"  long double n = nn, n1 = 2.L / (n - 1), z;"];
  For[i=0, i<=p, i++, 
    Write[fp,"  long double a",i,", temp",i,", sum",i," = 0;"];
  ];  
  Write[fp,"  int i;"];
  Write[fp,"  for (i = 0; i < nn; i++)"];
  Write[fp,"    {"];
  Write[fp,"      z = n1 * i - 1.L;"];
  list={"x[i]"};
  For[i=0, i<=p, i++,
     s1="      sum" <> ToString[i] <> " += ";
     wlist[s1, list, " * ", ";"];
     list=Append[list,"z"];
  ];
  Write[fp,"/* the above code is efficiently optimized by GCC4 */"];
  Write[fp,""];
  Write[fp,"    }"];

  s=sol[p];
  For[i=0, i<=p, i++,
    list={};
    For[j=0, j<=p, j++,
      If[!FreeQ[s[[i+1,j+1]],n],
	Write[fp, "temp", j, " = ", cform[s[[i+1,j+1]]], ";"];
	list=Append[list,"temp" <> ToString[j] <> " * sum" <> ToString[j]];
      ]  
    ];  
    s1 = "a" <> ToString[i] <> " = ";
    wlist[s1, list, " + ", ";"];
    ];
  Write[fp,"  for (i = 0; i < nn; i++)"];
  Write[fp,"    {"];
  Write[fp,"      z = n1 * i - 1.L;"];
  list={};
  For[i=0, i<=p, i++,
     list=Append[list, "a" <> ToString[i]];
  ];
  
  Write[fp,"      y[i] = x[i] - ", polyprint[list, "z"], ";"];
  Write[fp,"    }"];
  For[i=0, i<=p, i++, 
    Write[fp,"  a[",i,"] = a",i,";"];
  ];
  Write[fp,"}"];
  Close[fp];
];

For[i=0, i<=10, i++, 
  out[i];
  Print["degree ",i," done."];
]  

