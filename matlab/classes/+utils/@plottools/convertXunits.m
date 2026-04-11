%-----------------------------------------------
% Change X data for time-series according to the specified xunits
function [x, xunit, dateTicSpec] = convertXunits(x, t0, xunit, xunitIn)
  
  dateTicSpec = false;
  
  xunit = strtrim(xunit);
  xunitIn = strtrim(xunitIn);
  if ~strcmpi(strtrim(xunitIn), '[s]')
%     warning backtrace off
%     warning('### The original units are not [s]. No conversion to perform');
%     warning backtrace on
    xunit = xunitIn;
  else
    switch strtrim(xunit)
      case {'[us]', 'us'}
        x = x .* 1e6;
      case {'[ms]', 'ms'}
        x = x .* 1e3;
      case {'[s]', 's'}
      case {'[m]', 'm'}
        x = x ./ 60;
      case {'[h]', 'h'}
        x = x ./ 3600;
      case {'[D]', 'D'}
        x = x ./ 86400;
      otherwise
        % then we have a datetic spec
        dateTicSpec = true;
        % first convert x data to serial date
        st = format(t0, 'yyyy-mm-dd hh:mm:ss');
        st = regexp(st, ' ', 'split');
        st = [st{1} ' ' st{2}];
        t0 = datenum(st); % get t0 as a serial date
        x = t0 + x./86400; % convert x to days
    end
  end
  if xunit(1) ~= '['
    xunit = ['[' xunit];
  end
  if xunit(end) ~= ']'
    xunit = [xunit ']'];
  end
  %                          'us'        - microseconds
  %                          'ms'        - milliseconds
  %                          's'         - seconds [default]
  %                          'm'         - minutes
  %                          'h'         - hours
  %                          'D'         - days
  %                          'M'         - months
  %                          'HH:MM:SS'  - using a date/time format
  
end