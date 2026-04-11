% PARSEFILTERPARAMS parses the input plist and returns a full plist for designing a standard FIR filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARSEFILTERPARAMS parses the input plist and returns a full
%              plist for designing a standard FIR filter. Defaults are used
%              for those parameters missing from the input plist.
%
% CALL:        plo = parseFilterParams(pl)
%
% INPUT:       'type'  - one of 'highpass', 'lowpass', 'bandpass', 'bandreject'.
%               [default: 'lowpass']
%              'gain'  - gain of filter [default: 1.0]
%              'fs'    - sample frequency to design for [default: 1 Hz]
%              'order' - order of filter [default: 64]
%              'fc'    - corner frequencies. This is a two element vector for
%                        bandpass and bandreject filters. [default: 0.1 or [0.1 0.25] Hz]
%              'Win'   - a window object to use in the design. [default: Hamming]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = parseFilterParams(pl)

  plo = plist();
  
  import utils.const.*
  
  % type
  type = find_core(pl, 'type');
  if isempty(type)
    type = 'lowpass';
    utils.helper.msg(msg.OPROC2, 'using default type ''lowpass''');
  end
  plo = append(plo, 'type', type);

  % gain
  gain = find_core(pl, 'gain');
  if isempty(gain)
    gain = 1.0;
    utils.helper.msg(msg.OPROC2, ['using default gain ' num2str(gain)]);
  end
  plo = append(plo, 'gain', gain);

  % order
  order = find_core(pl, 'order');
  if isempty(order)
    order = 64;
    utils.helper.msg(msg.OPROC2, ['- using default order ' num2str(order)]);
  end
  if mod(order,2) == 1
    warning('!!! reseting filter order to even number (+1)')
    order = order + 1;
  end
  plo = append(plo, 'order', order);

  % fc
  fc = find_core(pl, 'fc');
  if isempty(fc)
    if strcmp(type, 'bandreject') || strcmp(type, 'bandpass')
      fc = [0.1 0.25];
    else
      fc = 0.1;
    end
    utils.helper.msg(msg.OPROC2, ['- using default fc ' num2str(fc)]);
  end
  plo = append(plo, 'fc', fc);

  % fs
  fs = find_core(pl, 'fs');
  if isempty(fs)
    fs = 10*max(fc);
    warning([sprintf('!!! no sample rate specified. Designing for fs=%2.2fHz.', fs)...
      sprintf('\nThe filter will be redesigned later when used.')]);
  end
  plo = append(plo, 'fs', fs);

  % win
  win = find_core(pl, 'Win');
  if isempty(win)
    % then we use the default window
    win = specwin('Hamming', order+1);
  elseif ischar(win)
    if strcmpi(win, 'kaiser')
      win = specwin(win, order+1, win.psll);
    else
      win = specwin(win, order+1);
    end
  end
  if length(win.win) ~= order + 1
    warning('!!! setting window length to filter order !!!');
    switch lower(win.type)
      case 'kaiser'
        win = specwin(win.type, order + 1, win.psll);
      otherwise
        win = specwin(win.type, order + 1);
    end
  end
  plo = append(plo, 'Win', win);
end


