% MATH helper class for math utility functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MATH is a helper class for math utility functions.
%
% To see the available static methods, call
%
% >> methods utils.math
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef math
  
  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)
    
    
    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    varargout = welchscale(varargin);
    varargout = intfact(varargin); % Compute two integers P and Q
    varargout = cpf(varargin)
    varargout = lp2z(varargin)
    p         = phase(resp)
    r         = deg2rad(deg, min, sec)
    [G,ri]    = fq2ri(f0, Q)
    ri        = fq2ri2(f0, Q)
    [f0, q]   = ri2fq(c)
    deg       = unwrapdeg(phase)
    val       = rand(r1, r2)
    fs        = chop(fs,limits)
    z         = filtpz(x, pole, Gain)
    y         = cauchy( theta )
    varargout = psd(varargin)
    varargout = cpsd(varargin)
    [res,poles,dterm,mresp,rdl,rmse] = autocfit(y,f,params)
    [res,poles,dterm,mresp,rdl,rmse] = autodfit(y,f,fs,params)
    [res,poles,dterm,mresp,rdl] = ctfit(y,f,poles,weight,fitin)
    [res,poles,dterm,mresp,rdl] = dtfit(y,f,poles,weight,fitin)
    [res,poles,dterm,mresp,rdl,rmse] = vcfit(y,f,poles,weight,fitin)
    [res,poles,dterm,mresp,rdl,rmse] = vdfit(y,f,poles,weight,fitin)
    [h11,h12,h21,h22] = eigpsd(psd1,csd,psd2,varargin)
    [h11,h12,h21,h22] = eigcsd(csd11,csd12,csd21,csd22,varargin)
    varargout = pfallps(ir,ip,id,mresp,f,varargin)
    [nr,np,nd,nmresp] = pfallpsymz(r,p,d,mresp,f,fs)
    [nr,np,nd,nmresp] = pfallpsyms(r,p,d,f)
    varargout = pfallpz(ir,ip,id,mresp,f,fs,varargin)
    varargout = psd2tf(varargin)
    varargout = psd2wf(varargin)
    spoles = startpoles(order,f,params)
    weight = wfun(y,weightparam)
    [ext,msg] = stopfit(y,rdl,rmse,ctp,lrscond,rmsevar)
    pfr = pfresp(pfparams)
    Deriv = fpsder(a, params)
    zi = iirinit(a,b)
    sw = spflat(S)
    d = ctmult(C, A)
    d = mult(C, A)
    out = randelement(arr, N)
    covmat = jr2cov(J,resid)
    J = getjacobian(coeff,model,X)
    h = ndeigcsd(csd,varargin)
    ostruct = csd2tf(csd,f,params)
    [res,poles,fullpoles,mresp,rdl,mse] = psdzfit(y,f,poles,weight,fitin)
    varargout = computepsd(Sxx,Svxx,w,range,nfft,Fs,esttype)
    res = isequal(varargin)
    [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linfitsvd(varargin)
    [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linlsqsvd(varargin)
    Zi = getinitstate(res,poles,S0,varargin)
    varargout = pfallpz2(ip,mresp,f,fs)
    ostruct = csd2tf2(csd,f,params)
    varargout = pfallpsymz2(ip,mresp,f,fs)
    varargout = pfallpsyms2(ip,mresp,f)
    varargout = pfallps2(ip,mresp,f)
    X = getCorr(C, dbg_info)
    status = psre(varargin)
    X = ymcd(C, dbg_info, plot_diag)
    [logRatio, answer] = Decision(L1, L2, betta, proposalpdf, priors, issymmetric)
    FisMat = fisher_2x2(i1,i2,n,mdl,params,numparams,freqs,N,fs,pl,inNames,outNames)
    [FisMat, step]= fisher(fin,S,mdl,params,numparams,lp,freqs,dstep,ngrid,ranges,inNames,outNames)
    [d,FisMat]= dispersion_2x2(i1,i2,n,mdl,params,numparams,freqs,N,pl,inNames,outNames);
    [d,FisMat]= dispersion_1x1(i1,i2,n,mdl,params,numparams,freqs,N,pl,inNames,outNames);
    FisMat = fisher_1x1(i1,n,mdl,params,numparams,freqs,N,fs,pl,inNames,outNames)
    best = diffStepFish(fin,S,meval,params,ngrid,ranges,freqs,inNames,outNames)
    best = diffStepFish_1x1(fs,i1,S11,N,meval,params,numparams,ngrid,ranges,freqs,inNames,outNames)
    varargout = loglikelihood(varargin)
    [xn, hjump] = jump(xo,cov,hjump,jumps,nacc,search,Tc,proposalSampler)
    [loglk, snr] = loglikelihood_ssm(varargin)
    [loglk, snr] = loglikelihood_matrix(varargin)
    snrexp = stnr(in, out, S, TF)
    loglk = loglikelihood_ssm_td(xp,in,out,parnames,model,inNames,outNames,Noise,varargin)
    loglk = loglikelihood_td(res,noise,varargin)
    params = fitPrior(prior,nparam,chain,bins)
    Xt = blwhitenoise(npts,fs,fl,fh)
    [smpl, smplr] = mhsample(mmdl,fin,fout,mnse,cvar,N,rang,param,Tc,xi,xo,search,jumps,FIM_pl,parplot,debug,inNames,outNames,fpars,anneal,SNR0,DeltaL,inModel,outModel);
    [A,B,C,D] = pf2ss(res,poles,dterm)
    [w_i,powers,w_mse,p_mse] = rootmusic(x,p,varargin)
    [music_data,msg] = music(x,p,varargin)
    k = getk(z,p,zfg)
    dc = getdc(z,p,k)
    [A,B,C,D] = pzmodel2SSMats(pzm)
    varargout = filtfilt_filterbank(fbk,in)
    cmat = xCovmat(x,y,varargin)
    chi2 = chisquare_ssm_td(xp,in,out,parnames,model,inNames,outNames,varargin)
    [CorrC,SigC] = cov2corr(Covar)
    Covar = corr2cov(CorrC,SigC)
    R = Rcovmat(x)
    betta = computeBetta(nacc,Tc,xi,anneal,SNR,SNR0)
    logL = getLoglikelihood(fin,fout,S,model,param,freqs,lp,inModel,outModel,inNames,outNames)
    smpl = mhsample_td(model,in,out,cov,number,limit,parnames,Tc,xi,xo,search,jumps,parplot,dbg_info,inNames,outNames,inNoise,inNoiseNames,cutbefore,cutafter)
    [Bxy, LogLambda, chains] = rjsample(mmdl,fin,fout,mnse,cvar,N,rang,param,Tc,xi,xo,search,jumps,parplot,debug,inNames,outNames,inModel,outModel);
    [Fout,x] = ecdf(y)
    [L, snr] = logLmath(in, out, ns, h)
    cVal = SKcriticalvalues(n1,n2,alph)
    x = Finv(p,n1,n2)
    [mn, cv, cr, PSRE, T, X, KStest] = processChain(smpl, Tc, dbg_info, print_diag)
    p = Fcdf(x,n1,n2)
    rsp = mtxiirresp(fil,freq,fs,bank)
    rsp = mtxiirresp2(A,B,freq,fs)
    rsp = mtxratresp2(A,B,freq)
    f = getfftfreq(nfft,fs,type)
    h = cdfplot(y1,y2,ops)
    h = qqplot(y1,y2,ops)
    h = ppplot(y1,y2,ops)
    boxplot(varargin)
    p = Normcdf(x,mu,sigma)
    [logRatio, answer] = logDecision(L1, L2, betta, proposalpdf, priors, issymmetric)
    p = normalPDF(x,m,sig)
    x = Norminv(p,mu,sigma)
    p = Chi2cdf(x,v)
    x = Chi2inv(p,v)
    [H, KSstatistic, criticalValue, pValue] = kstest(y1, y2, alpha, varargin)
    [test,critValue,pValue] = Ftest(F,dof1,dof2,alpha,twoTailed)
    test = SFtest(X,Y,alpha,showPlots)
    s = Skew(x)
    k = Kurt(x)
    [rw,s] = crank(w)
    [rs,pValue,TestRes] = spcorr(y1,y2,alpha)
    [chi2,g] = chi2(p,data,models,Dmodels,lb,ub)
    pValue = KSpValue(KSstatistic,n1,n2)
    R = freqCorr(w,eta,T)
    varargout = overlapCorr(wname,N,navs,olap)
    Gf = dft(gt,f,T)
    Sf = computeDftPeriodogram(x,fs,f,order,win,psll)
    Sf = welchdft(x,fs,f,Ns,olap,navs,order,win,psll)
    y = stpdf(X, Sigma, N)
    y = unitStep(x);
    y = heaviside(x);
    z = drawSample(mu,Sigma);
    sample = drawSampleT(mu, Sigma, N)
    [x,fval,exitflag,output] = fminsearchbnd_core(fun,x0,LB,UB,options)
    out = linfit (x, y, dy, varargin)
    out = slopefit (x, y, dy, varargin)
    x = roundn(x, n)
    varargout = fftdelay_core(x,tau,fs)
    varargout = fdfilt_delay_core(y,D,N,w)
    [res,poles,dterm,psdmod] = psdvectorfit(y,f,params)
    p = gammapdf(x,A,B)
    p = gammacdf(x,A,B)
    [xd,yd] = downsampleSpectrum(x,y,factor)
    yr = regularizePSDForFit(y,psdmod,regularizecoeff,navs)
    wn = randomWalkGen(processLength,stepSize,positiveStepProb,varargin)
    varargout = free_flight_ode(varargin)
    %-------------------------------------------------------------
    %-------------------------------------------------------------
    
  end % End static methods
  
  
end

% END
