% REBUILD rebuilds the orignal object using the history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REBUILD rebuilds the orignal object using the history.
%              Necessary for the ltpda_uoh/rebuild method.
%
% CALL:        out = rebuild(h)
%              out = rebuild(h, pl)
%
% INPUTS:      h  - array of history objects
%              pl - configuration PLIST for the history/hist2m method
%
% OUTPUTS:     out - array of rebuilt objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rebuild(varargin)
  
  import utils.const.*
  
  % Get history objects
  hs = varargin{1};
  pl = [];
  
  % Get configuration PLIST
  if nargin >= 2
    pl = varargin{2};
  end
  
  % Go through each input AO
  bs = [];
  for jj = 1:numel(hs)
    
    % convert to commands
    if isempty(hs(jj))
      cmds = {'a_out = [];'};
    else
      if isempty(pl)
        cmds = hist2m(hs(jj));
      else
        cmds = hist2m(hs(jj), pl.find('stop_option'));
      end
    end
    
    % execute each command
    for kk = numel(cmds):-1:1
      utils.helper.msg(msg.PROC4, 'executing command: %s', cmds{kk});
      eval(cmds{kk});
    end
    
    % add to outputs
    bs = [bs a_out];
    
  end % End object loop
  
  % Set output
  varargout{1} = bs;
  
end
