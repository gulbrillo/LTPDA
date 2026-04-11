% STRING writes a command string that can be used to recreate the input plotinfo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input plotinfo object.
%
% CALL:        cmd = string(plotinfo)
%
% INPUT:       plotinfo - plotinfo object
%
% OUTPUT:      cmd       - command string to create the input object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

  objs = [varargin{:}];

  cmd = '';

  for ii = 1:numel(objs)

    obj = objs(ii);
    
    % plotinfo(linestyle, linewidth, color, marker, markersize, includeInLegend, showErrors, axes, figure);
    cmd = sprintf('plotinfo(''%s'', %g, %s, ''%s'', %s, %d, %d, %s, %s)', ...
      char(obj.style.getLinestyle()), ...
      double(obj.style.getLinewidth()), ...
      mat2str(utils.prog.jcolor2mcolor(obj.style.getColor)), ...
      char(obj.style.getMarker()), ...
      char(obj.style.getMarkersize()), ...
      obj.includeInLegend, ...
      obj.showErrors, ...
      mat2str(obj.axes), ...
      mat2str(obj.figure));
          
  end

  %%% Wrap the command only in bracket if the there are more than one object
  if numel(objs) > 1
    cmd = ['[' cmd(1:end-1) ']'];
  end

  %%% Prepare output
  varargout{1} = cmd;
end

