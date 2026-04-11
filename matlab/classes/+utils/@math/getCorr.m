%
% Get autocorrelation of the Chains
%
% NK 2012
%

function ac = getCorr(C, plot_diag)

  if plot_diag
    figure
  end
    
  [r, n]   = size(C);
  maxlag   = floor(r/4);
  ac       = zeros(maxlag,n);
  AutoCors = cell(1,4); 
  downsamp = floor(1e-2*maxlag);
  
  % Calculate auto-correlation for all parts of the chains
  for jj=1:4
    
    cp = C((jj-1)*maxlag+1:jj*maxlag,:);
    
    for i1 = 1:n

      c        = xcorr(cp(:,i1)-mean(cp(:,i1)),maxlag,'coeff');
      c        = c(maxlag+2:end);
      ac(:,i1) = c;

    end
    
    % Store info
    AutoCors{jj} = ac;

    if plot_diag

      % Split chain in 4 parts and plot autocorr
      subplot(2,2,jj)
      xvals = (jj-1)*maxlag+1:jj*maxlag;
      xvals = xvals(1:downsamp:end);
      plot(xvals,AutoCors{jj}(1:50:end,:),'Marker','.','LineStyle','-');

      xlabel('Samples')

    end
  end
  
  if plot_diag
    % put title
    annotation('textbox',   [0 0.85 1 0.1], ...
               'String',    'Auto-correlation of the MCMC chains', ...
               'EdgeColor', 'none', ...
               'FontSize',   18,...
               'HorizontalAlignment', 'center');      
  end
  
end

% END