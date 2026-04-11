% SFtest perfomes a Spectral F-Test on PSDs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SFtest performes a Spectral F-Test on two input PSD objects.
%              The null hypothesis H0 (the two PSDs belong to the same
%              statistical distribution) is rejected at the confidence
%              level for the alternative hypotheis H1 (the two PSDs belong
%              to different statistical distributions) if the test
%              statistic falls in the critical region.
%              SFtest uses utils.math.Ftest which does the test at each
%              frequency bin.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test = SFtest(X,Y,alpha,showPlots)

  % Assume a two-tailed test
  twoTailed = 1;

  % Extract the degree of freedom
  dofX = X.getdof.y;
  dofY = Y.getdof.y;
  
  % Ratio of the two spectra: this test statistic is F-distributed
  F = X/Y;
  F.setYunits('');
  F.setName('F statistic');
  
  n = numel(F.y);
  
  % Interquartile range
  Fy = sort(F.y);
  m = median(Fy);
  q1 = median(Fy(Fy<=m));
  q3 = median(Fy(Fy>=m));
  iqr = q3 - q1;
  
  % Freedman�Diaconis rule
  binSz = 2*iqr*n^(-1/3);
  nBin = round((max(Fy)-min(Fy))/binSz);
  
  % Sample PDF
  samplePDF = hist(F,plist('N',nBin,'norm',1));
  samplePDF.setName('sample PDF');
  
  % Sample PDF moments
%   sampleK = utils.math.Kurt(samplePDF.x);
%   sampleS = utils.math.Skew(samplePDF.x);
  
  % Theor PDF
  theorPDF = copy(samplePDF,1);
  theorPDF.setY(Fpdf(samplePDF.x,dofX,dofY));
  theorPDF.setName('theor. PDF');
  
  % Theor PDF moments
%   theorK = utils.math.Kurt(samplePDF.x);
%   theorS = utils.math.Skew(samplePDF.x);
  
  % Plot PDFs
  if showPlots
    iplot(samplePDF,theorPDF);
    set(get(gca,'YLabel'),'String','PDF')
    set(get(gca,'XLabel'),'String','F statistic')
  end
  
  % Perform test on the hypothesis that both distributions should be
  % chi2-distributed or, equivalently, that the ratio of the two spectra
  % should be F-distributed. The comparison is actually done in chi2 sense.
  sampleHIST = hist(F,plist('N',nBin));
  ix = sampleHIST.y>=5;
  C = sum(sampleHIST.y)*mean(diff(sampleHIST.x));
  NN = sampleHIST.y(ix);
  nn = C*theorPDF.y(ix);
  r = (NN-nn).^2./nn;
  chi2 = sum(r);
  dof = numel(NN) - 1;
  Y2 = dof + sqrt(2*dof/(2*dof+sum(1./nn)))*(chi2-dof);
  critValue(1) = utils.math.Chi2inv(alpha/2,dof);
  critValue(2) = utils.math.Chi2inv(1-alpha/2,dof);
  
  % Perform the test on PDFs
  Chi2test = Y2<critValue(1) | Y2>critValue(2);
  
%   % Sample CDF
%   samplePDF = hist(F,plist('N',1000));
%   sampleCDF = copy(samplePDF,1);
%   sampleCDF.setY(cumsum(samplePDF.y)/sum(samplePDF.y));
%   sampleCDF.setName('sample CDF');
%   
%   % Theor CDF
%   theorCDF = copy(samplePDF,1);
%   theorCDF.setY(Fcdf(samplePDF.x,dofX,dofY));
%   theorCDF.setName('theoretical CDF');
%   
%   % Plot CDFs
%   iplot(sampleCDF,theorCDF);
%   set(get(gca,'YLabel'),'String','CDF')
%   set(get(gca,'XLabel'),'String','F statistic')
   
  % Critical values
  [test,critValue,pValue] = utils.math.Ftest(F.y,dofX,dofY,alpha,twoTailed);
  
  % Build AOs for critical values
%   if twoTailed
    critValueLB = ao(plist('xvals',X.x,'yvals',repmat(critValue(1),size(X.x)),...
      'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','critical values'));
    critValueUB = ao(plist('xvals',X.x,'yvals',repmat(critValue(2),size(X.x)),...
      'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','critical values'));
%   else
%     critValue = ao(plist('xvals',X.x,'yvals',repmat(critValue,size(X.x)),...
%       'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','critical values'));
%   end
    
%   % Build AOs for p-values and confidence levels
%   pValue = ao(plist('xvals',X.x,'yvals',pValue,...
%     'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','p-values'));
% %   pValue.setDy(pValueDy);
%   
%   if twoTailed
%     confLevelUB = ao(plist('xvals',X.x,'yvals',repmat(1-alpha/2/numel(F.y),size(X.x)),...
%       'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','confidence level'));
%     confLevelLB = ao(plist('xvals',X.x,'yvals',repmat(alpha/2/numel(F.y),size(X.x)),...
%       'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','confidence level'));
%   else
%     confLevel = ao(plist('xvals',X.x,'yvals',repmat(1-alpha/n,size(X.x)),...
%       'type','fsdata','fs',X.fs,'xunits',X.xunits,'name','confidence level'));
%   end
  
  % Rejection index
  ix = find(test);
  if ~isempty(ix)
    H1 = F.setXY(plist('x',F.x(ix),'y',F.y(ix)));
    H1.setDy([]);
    H1.setName('H0 rejected');
  end
  
  % Compute the number of sigmal corresponding to the confidence level
%   Ns = erfinv(1-alpha)*sqrt(2);
  
  % Make the test: H0 rejected?
%   if twoTailed
% %     test = any( (F.y-Ns.*F.dy)>critValueUB.y | (F.y+Ns.*F.dy)<critValueLB.y );
%     test = any( F.y>critValueUB.y | F.y<critValueLB.y );
%   else
% %     test = any( (F.y-Ns.*F.dy)>critValue.y );
%     test = any( F.y>critValue.y );
%   end
  
  % Perform the F-test on spectra
  Ftest = any(test);
  
  % Plot results
  pl = plist('yscales',{'All', 'log'},'autoerrors',0);
%   if twoTailed
  if showPlots
    if Ftest
      [hfig, hax, hli] = iplot(F,critValueLB,critValueUB,H1,pl);
      set(hli(4),'linestyle','none','marker','s','MarkerSize',10,'MarkerEdgeColor','r');
    else
      [hfig, hax, hli] = iplot(F,critValueLB,critValueUB,pl);
    end
    set(hli(2:3),'color','r');
%     h2 = iplot(pValue,confLevelLB,confLevelUB,pl);
%   else
%     if Ftest
%       [hfig, hax, hli] = iplot(F,critValue,H1,pl);
%       set(hli(3),'linestyle','none','marker','s','MarkerSize',10,'MarkerEdgeColor','r');
%     else
%       [hfig, hax, hli] = iplot(F,critValue,pl);
%     end
%     set(hli(2),'color','r');
% %     h2 = iplot(pValue,confLevel,pl);
%   end
    set(get(gca,'YLabel'),'String','F statistic')
  end
  
  % Output final result
  test = any(Chi2test | Ftest);
  
end

