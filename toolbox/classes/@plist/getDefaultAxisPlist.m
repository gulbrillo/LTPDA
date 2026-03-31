% GETDEFAULTAXISPLIST returns the default plist for the axis key based on
% the input set.
% 
% CALL:
%          pl = plist.getDefaultAxisPlist(set)
% 
% Supported sets: '1D', '2D', '3D'
% 

function plout = getDefaultAxisPlist(varargin)
  
  if nargin == 0
    set = '';
  else
    set = varargin{1};
    
    if ~ischar(varargin{1})
      error('Incorrect usage: the set needs to be a string.');
    end
  end
  
%   persistent pl;
%   persistent lastset;
%   if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
%     lastset = set;
%   end
  plout = pl;
  
end

function pl = buildplist(set)

  switch set
    case '1D'
      pl = copy(plist.AXIS_1D_PLIST,1);
    case '2D'
      pl = copy(plist.AXIS_2D_PLIST,1);
    case '3D'
      pl = copy(plist.AXIS_3D_PLIST,1);
    case ''
      pl = copy(plist.AXIS_3D_PLIST,1);
    otherwise
      error('Unsupported set for default axis plist [%s]', set);
  end
  
end
