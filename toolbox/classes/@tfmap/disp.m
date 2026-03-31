% DISP overloads display functionality for tfmap objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for tfmap objects.
%
% CALL:        txt    = disp(tfmap)
%
% INPUT:       tfmap  - a tfmap data object
%
% OUTPUT:      txt    - cell array with strings to display the tfmap object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  tfdataObjs = utils.helper.collect_objects(varargin(:), 'tfmap');

  txt = {};

  for i=1:numel(tfdataObjs)
    xyz = tfdataObjs(i);
    banner = sprintf('-------- [%s, %s, %s] --------', xyz.xaxis.name, xyz.yaxis.name, xyz.zaxis.name);
    txt{end+1} = banner;

    txt{end+1} = ' ';

    txt{end+1} = sprintf('     x:  [%d %d], %s', size(xyz.getX), class(xyz.getX));
    txt{end+1} = sprintf('     y:  [%d %d], %s', size(xyz.getY), class(xyz.getY));
    txt{end+1} = sprintf('     z:  [%d %d], %s', size(xyz.getZ), class(xyz.getZ));
    txt{end+1} = sprintf('xunits:  %s', char(xyz.getXunits));
    txt{end+1} = sprintf('yunits:  %s', char(xyz.getYunits));
    txt{end+1} = sprintf('zunits:  %s', char(xyz.getZunits));
    txt{end+1} = sprintf('    fs:  %0.9g', xyz.fs);
    txt{end+1} = sprintf(' nsecs:  %g', xyz.nsecs);
    txt{end+1} = sprintf('    t0:  %s', char(xyz.t0));

    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;

    txt{end+1} = ' ';
  end

  if nargout == 0
    for ii=1:length(txt)
      disp(txt{ii});
    end
  elseif nargout == 1
    varargout{1} = txt;
  end

end

