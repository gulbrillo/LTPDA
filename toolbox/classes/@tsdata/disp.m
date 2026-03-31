% DISP overloads display functionality for tsdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for tsdata objects.
%
% CALL:        txt    = disp(tsdata)
%
% INPUT:       tsdata - tsdta object
%
% OUTPUT:      txt    - cell array with strings to display the tsdata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  tsdatas = [varargin{:}];
  
  txt = {};
  
  for i=1:numel(tsdatas)
    ts = tsdatas(i);
    
    % Call super class
    txt = [txt disp@data2D(ts)];
    
    txt{end+1} = sprintf('     fs:  %0.9g', ts.fs);
    txt{end+1} = sprintf('  nsecs:  %g (%s)', ts.nsecs, timespan.doubleToHumanInterval(ts.nsecs));
    txt{end+1} = sprintf('     t0:  %s', char(ts.t0));
    
    banner_end(1:length(txt{1})) = '-';
    txt{end+1} = banner_end;
    
    txt{end+1} = ' ';
  end
  
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  elseif nargout == 1
    varargout{1} = txt;
  end
  
end

