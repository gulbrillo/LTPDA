function cb_plot(varargin)
  
  mainfig = varargin{end};
  
  specwinViewer.plotWindow(mainfig, 'Freq-domain');
  
  figure;
  specwinViewer.plotWindow(gca, mainfig, 'Time-domain');
  figure;
  specwinViewer.plotWindow(gca, mainfig, 'Freq-domain');
  
end
