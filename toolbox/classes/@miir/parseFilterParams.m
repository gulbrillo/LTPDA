% PARSEFILTERPARAMS parses the input plist and returns a full plist for designing a standard IIR filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARSEFILTERPARAMS parses the input plist and returns a
%              full plist for designing a standard IIR filter. Defaults are used
%              for those parameters missing from the input plist.
%
% CALL:        plo = parseFilterParams(pl)
%
% INPUT:       'type'  - one of 'highpass', 'lowpass', 'bandpass', 'bandreject'
%                        [default: 'lowpass']
%              'gain'  - gain of filter
%                        [default: 1.0]
%              'fs'    - sample frequency to design for
%                        [default: 1 Hz]
%              'order' - order of filter
%                        [default: 1]
%              'fc'    - corner frequencies. This is a two element vector for
%                        bandpass and bandreject filters.
%                        [default: 0.1 or [0.1 0.25] Hz]
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
  plo = append(plo, param('type', type));

  % gain
  gain = find_core(pl, 'gain');
  if isempty(gain)
    gain = 1.0;
    utils.helper.msg(msg.OPROC2, ['using default gain ' num2str(gain)]);
  end
  plo = append(plo, param('gain', gain));

  % order
  order = find_core(pl, 'order');
  if isempty(order)
    order = 1.0;
    utils.helper.msg(msg.OPROC2, ['using default order ' num2str(order)]);
  end
  plo = append(plo, param('order', order));

  % fc
  fc = find_core(pl, 'fc');
  if isempty(fc)
    if strcmp(type, 'bandreject') || strcmp(type, 'bandpass')
      fc = [0.1 0.25];
    else
      fc = 0.1;
    end
    utils.helper.msg(msg.OPROC2, ['using default fc ' num2str(fc)]);
  end
  plo = append(plo, param('fc', fc));

  % fs
  fs = find_core(pl, 'fs');
  if isempty(fs)
    fs = 10*max(fc);
    warning([sprintf('!!! no sample rate specified. Designing for fs=%2.2fHz.', fs)...
      sprintf('\nThe filter will be redesigned later when used.')]);
  end
  % Increase fs until the cutoff is ok
  while fs < 2*fc
    fs = fs*2;
  end
  plo = append(plo, param('fs', fs));

  % ripple
  ripple = find_core(pl, 'ripple');
  if isempty(ripple)
    ripple = 0.5;
    utils.helper.msg(msg.OPROC2, ['using default ripple ' num2str(ripple)]);
  end
  plo = append(plo, param('ripple', ripple));
end



