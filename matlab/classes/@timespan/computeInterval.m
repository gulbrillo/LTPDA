% COMPUTEINTERVAL compute the interval of the time span.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMPUTE_INTERVAL compute the interval of the time span.
%
% CALL:        str = compute_interval(t1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function interval = computeInterval(ts)

  interval = '';

  number = abs(ts.startT.utc_epoch_milli-ts.endT.utc_epoch_milli);

  if (ts.endT.utc_epoch_milli-ts.startT.utc_epoch_milli < 0)
    interval = '-';
  end

  form = java.text.SimpleDateFormat;
  form.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));

  form.applyPattern('yyyy')
  num_y = char(form.format(java.util.Date(number)));
  num_y = str2double(num_y);
  num_y = num_y - 1970;
  num_y = sprintf('%02d', num_y);

  form.applyLocalizedPattern('DD')
  num_d = char(form.format(java.util.Date(number)));
  num_d = sprintf('%02d', str2double(num_d)-1);

  form.applyLocalizedPattern('HH')
  num_h = char(form.format(java.util.Date(number)));

  form.applyLocalizedPattern('mm')
  num_m = char(form.format(java.util.Date(number)));

  form.applyLocalizedPattern('ss')
  num_s = char(form.format(java.util.Date(number)));

  form.applyLocalizedPattern('SSS')
  num_milli_s = char(form.format(java.util.Date(number)));

  if ~strcmp(num_y, '00')
    interval = [interval num_y ' Years '];
  end

  if ~strcmp(num_d, '00')
    interval = [interval num_d ' Days '];
  end

  if ~strcmp(num_h, '00')
    interval = [interval num_h ' Hours '];
  end

  if ~strcmp(num_m, '00')
    interval = [interval num_m ' Minutes '];
  end

  if ~strcmp(num_s, '00')
    interval = [interval num_s ' Seconds '];
  end

  if ~strcmp(num_milli_s, '000')
    interval = [interval num_milli_s ' Milliseconds '];
  end
  
  if isempty(interval)
    interval = '0 Seconds';
  end
  
end


