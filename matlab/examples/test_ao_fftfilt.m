% Test script for ao/fftfilt
%
% L Ferraioli 09-10-08
%
% $Id$
%

function test_ao_fftfilt
  
  s = ao(plist('tsfcn', '3.*sin(2.*pi.*0.01.*t) + randn(size(t))', 'fs', 10, 'nsecs', 1e4));
  
  %% Test with a miir filter
  
  % get a miir filter
  plf = plist('type','lowpass',...
    'order',4,...
    'fs',10,...
    'fc',1);
  filt = miir(plf);
  
  % do classical fitering
  fs1 = filter(s,filt);
  iplot(s,fs1)
  
  % do fftfilt
  fs2 = fftfilt(s,filt);
  
  % compare results
  iplot(fs1,fs2)
  iplot(fs1./fs2)
  iplot(fs1-fs2)
  
  %% Test with a miir filter
  
  % get a miir filter
  plf = plist('type','lowpass',...
    'order',4,...
    'fs',10,...
    'fc',1);
  filt = miir(plf);
  
  % do classical fitering
  fs1 = filter(s,filt);
  iplot(s,fs1)
  
  % do fftfilt
  plfft = plist('Npad',5.*length(s.data.y));
  fs2 = fftfilt(s,filt);
  
  % compare results
  iplot(fs1,fs2)
  iplot(fs1./fs2)
  iplot(fs1-fs2)
  
  %%
  
  % imp = zeros(10000,1);
  % imp(1) = 1;
  %
  % imp_resp = filter(num,den,imp);
  %
  %
  % fs1 = filter(num,den,s.y);
  % fs2 = conv(s.y,imp_resp);
  % X = fft([s.y;zeros(length(imp_resp)-1,1)]);
  % Y = fft([imp_resp;zeros(length(s.y)-1,1)]);
  % fs3 = ifft(X.*Y);
  
  %% Test pzmodel fftfilt
  
  poles = [pz(1e-3,2) pz(1e-2)];
  zeros = [pz(3e-3,3) pz(5e-2)];
  pzm   = pzmodel(10, poles, zeros);
  
  % do fftfilt
  plfft = plist('Npad',5.*length(s.data.y));
  fs = fftfilt(s,pzm);
  
  tf = tfe(s,fs,plist('navs',2));
  rsp = resp(pzm,plist('f',logspace(-4,log10(5))));
  iplot(tf,rsp)
  
  %% Test smodel
  
  str = 'a.*(2.*i.*pi.*f).^2 + b.*2.*i.*pi.*f + c';
  mod = smodel(str);
  mod.setParams({'a','b','c'},{1,2,3});
  mod.setXvar('f');
  
  freq = logspace(-5,log10(5),100);
  mod.setXvals(freq);
  mod.setXunits('Hz');
  mod.setYunits('kg m s^-2');
  
  % eval smodel
  em = eval(mod,plist('output x',freq,'output type','fsdata'));
  
  % make a time series
  dt = ao.randn(10000,10);
  
  % do fftfilt
  sdt = fftfilt(dt,mod);
  
  % test output
  tdt = tfe(dt,sdt);
  iplot(em,tdt)
  
  %% Test initial conditions
  
  str = 'a.*(2.*i.*pi.*f).^2 + b.*2.*i.*pi.*f + c';
  mod = smodel(str);
  mod.setParams({'a','b','c'},{1,2,3});
  mod.setXvar('f');
  
  freq = logspace(-5,log10(5),100);
  mod.setXvals(freq);
  mod.setXunits('Hz');
  mod.setYunits('kg m s^-2');
  
  % eval smodel
  em = eval(mod,plist('output x',freq,'output type','fsdata'));
  
  % make a time series
  dt = ao.randn(10000,10);
  
  % do fftfilt
  sdt = fftfilt(dt,mod);
  
  % do fftfilt with initial conditions assuming a 2nd order equation
  sdt_inCond = fftfilt(dt,mod,plist('initial conditions',[2000,1000]));
  
  % test output
  iplot(sdt_inCond,sdt)
  iplot(sdt_inCond-sdt,plist('yscales',{'all','log'}))
  
  %% Test lowpass
  
  dat = ao.randn(1e4,1);
  
  % get a miir filter
  plf = plist('type','lowpass',...
    'gain',1,...
    'fc',1e-1);
  
  % do fftfilt
  dat2 = fftfilt(dat,plf);
  
  % compare results
  iplot(dat,dat2)
  
  pls = plist('scale','asd','order',1,'navs',4);
  dxx = dat.psd(pls);
  d2xx = dat2.psd(pls);
  
  iplot(dxx,d2xx)
  
  %% Test highpass
  
  dat = ao.randn(1e4,1);
  
  % get a miir filter
  plf = plist('type','highpass',...
    'gain',1,...
    'fc',1e-2);
  
  % do fftfilt
  dat2 = fftfilt(dat,plf);
  
  % compare results
  iplot(dat,dat2)
  
  pls = plist('scale','asd','order',1,'navs',4);
  dxx = dat.psd(pls);
  d2xx = dat2.psd(pls);
  
  iplot(dxx,d2xx)
  
  %% Test bandpass
  
  dat = ao.randn(1e4,1);
  
  % get a miir filter
  plf = plist('type','bandpass',...
    'gain',1,...
    'fc',[1e-2 0.1]);
  
  % do fftfilt
  dat2 = fftfilt(dat,plf);
  
  % compare results
  iplot(dat,dat2)
  
  pls = plist('scale','asd','order',1,'navs',4);
  dxx = dat.psd(pls);
  d2xx = dat2.psd(pls);
  
  iplot(dxx,d2xx)
  
  %% Test bandreject
  
  dat = ao.randn(1e4,1);
  
  % get a miir filter
  plf = plist('type','bandreject',...
    'gain',1,...
    'fc',[1e-2 5e-2]);
  
  % do fftfilt
  dat2 = fftfilt(dat,plf);
  
  % compare results
  iplot(dat,dat2)
  
  pls = plist('scale','asd','order',1,'navs',4);
  dxx = dat.psd(pls);
  d2xx = dat2.psd(pls);
  
  iplot(dxx,d2xx)
  
  %% test with a filterbank
  
  s = ao.randn(1e4,10);
  s.setName('Data');
  
  % create filters
  fp(1) = miir(plist('type', 'lowpass','fs',10,'gain',1,'fc',0.1,'order',2));
  fp(2) = miir(plist('type', 'lowpass','fs',10,'gain',1,'fc',0.02,'order',2));
  fp(3) = miir(plist('type', 'lowpass','fs',10,'gain',1,'fc',0.05,'order',2));
  fp(4) = miir(plist('type', 'lowpass','fs',10,'gain',1,'fc',0.09,'order',2));
  fp.setName('filters')
  
  % group into filterbank
  fbk = filterbank(fp);
  
  a1 = filter(s,fbk);
  a1.setName('Filter')
  a2 = fftfilt(s,plist('filter',fbk));
  a2.setName('FFT-Filt')
  
  iplot(s,a2,a1)
  iplot(abs(1-(a2./a1)),plist('yscales',{'All','log'}))
  
  mm = mean(a2./a1);
  
  if (1-mm.y)<1e-10
    fprintf('\nData filtered with Filter and FFT-Filt are compatible!\n')
  else
    fprintf('\nData filtered with Filter and FFT-Filt are not compatible!\n')
  end
  
  close all
  
end





