%
% Utility function to plot the traces of the chains
%
% NK 2015
%
function outfigs = plotTraces(outfigs, totparams, whole_chain, names, varargin) 

  % Get more info if available
  if ~isempty(varargin)
    vals      = varargin{1};
    colorpdfs = varargin{2};
    chcol     = varargin{3};
  end
  
  % Check if fugure handles are imported
  if isempty(outfigs)
    CREATE_FIGS = true;
  else
    CREATE_FIGS = false;
  end
  
  % Make sure the names are in a cell
  if ~iscell(names) && ischar(names)
    names = {names};
  end
  
  fig_ind = 1;
  % loop over the chains
  for ii = 1:totparams;
    if (mod(ii,4)==1);
      ind = 1;
      if CREATE_FIGS
        outfigs = [outfigs ; figure];
      else
        figure(outfigs(fig_ind))
        fig_ind = fig_ind + 1;
      end
    end % plot 4 chains per figure
    
    subplot(4,1,ind)
    plot(whole_chain(:,ii), 'color', chcol, 'LineWidth', 1.2);
    set(gca, 'fontsize', 12)
    xlim([1, numel(whole_chain(:,ii))]);
    if ii > 3 && (numel(vals) >= ii-3)
      hold on
      yPos = vals(ii-3);
      plot(get(gca,'xlim'), [yPos yPos], colorpdfs); % Adapts to x limits of current axes
      hold off
    end
    ylabel(names{ii}, 'interpreter', 'none')
    grid on
    set(gca, 'GridLineStyle', '-');
    grid(gca,'minor')
    
    % put xlabel only for the last sublot
    if ind == 4 || ii == totparams
      xlabel('Samples');
    end
    
    ind = ind+1;
    
  end
  
end

% END