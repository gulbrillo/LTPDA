% findShapeParamKStestSpectrum find shape parameter for kstest on the
% spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: Find the shape parameter for a fair Kolmogorov Smirnov test
% on the spectrum
%
% CALL: shp = utils.math.findShapeParamKStestSpectrum(alpha,Nmc,nsecs,fs,freqs,olap,navs,order,win)
% 
% INPUTS: 
%         - alpha: significance level for the KS test
%         - Nmc: Number of Montecarlo iteration on white noise
%         - nsecs: number of seconds in the time series from which the
%         spectrum is calculated
%         - fs: sampling frequency
%         - freqs: frequency vactor for the test comparison
%         - olap: overlapp parameter for spectrum calculation
%         - navs: number of averages in spectrum calculation
%         - order: detrend order
%         - win: window name
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shp = findShapeParamKStestSpectrum(alpha,Nmc,nsecs,fs,freqs,olap,navs,order,win)


  plsp = plist('WIN',win,'order',order,'navs',navs,'olap',olap,'scale','psd');

  KS = zeros(Nmc,1);

  t = [0:1/fs:nsecs-1/fs];
  t = (0:(nsecs*fs-1))/fs;
  Ndat = numel(t);
  for ii=1:Nmc


    a = randn(Ndat,1);
    aa = ao(a,fs);
    axx = psd(aa,plsp);
    % split to remove window effect
    ff = axx.x;
    yy = axx.y;
    idx = freqs(1) <= ff & ff <= freqs(end);
    Sxx = yy(idx);

    S = 2/fs;

    R = Sxx./S;

    % get ECDF
    [F,X] = utils.math.ecdf(R);

    h = navs;
    delta = 1/navs;

    % Expected CDF
    P = gammainc(X./delta,h);

    KS(ii) = max(abs(F-P));
  end

  Nf = numel(freqs);

  x0 = 1;
  % search for the shape parameter
  x = fminsearch(@(x)getshape(x,Nf,alpha,KS,Nmc),x0);

  shp = x;

end

function costparam = getshape(x,Nf,alpha,KS,Nmc)

  Nef = Nf*x;

  CV_mod = utils.math.SKcriticalvalues(Nef,[],alpha/2);

  idx = KS > CV_mod;

  costparam = abs(sum(idx)-Nmc*alpha);

end

