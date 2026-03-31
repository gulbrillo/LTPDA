% TIME_DATA_WORSENER introduces missing points and/or unvenly sampling time
% inside time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    time_data_worsener
%
% DESCRIPTION: TIME_DATA_WORSENER introduces missing points and/or unvenly
%              sampling times inside time series
%
% CALL:        [t, y] = time_data_worsener(t, y, miss_fraction, shift_fraction, shift_range);
%
% INPUTS:      t              vector of evenly sampled time values (in s)
%              y              vector of evenly sampled y values (in arb units)
%              miss_fraction  fraction of the total point to be skipped
%              shift_fraction fraction of the total point to be shifted
%              shift_range    selection range for shifting the time points (in s)                             
%
% OUTPUTS:     t              vector of unevenly time values
%              y              vector of unevenly sampled y values
%
% EXAMPLES:    [t1,y1] = time_data_worsener(t, y, 0.5, 0, [0 0]);
%              [t1,y1] = time_data_worsener(t, y, 0, 0.1, [-0.05 0.05]);
%              [t1,y1] = time_data_worsener(t, y, 0.1, 0.5, [0 0.01]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [t,y] = time_data_worsener(t, y, miss_fraction, shift_fraction, shift_range)
  
  % Initial checks
  if isempty(t) || isempty(y)
    error('Need to operate on non empty data vectors!')
  end
  
  if length(y) ~= length(t)
    error('t and y vector should have the same lenghts!');
  end
  
  if miss_fraction > 1 || miss_fraction < 0
    error('Missing points fraction f must fulfil 0 <= f <= 1!');
  end
  
  if shift_fraction > 1 || shift_fraction < 0
    error('Shifted points fraction f must fulfil 0 <= f <= 1!');
  end
  
  if length(shift_range) < 2
    error('Please input the shifting freqency range []');
  end
  
  %% Remove an amount of points corresponding to the fractional amount input by user
  
  % Calculate the orginal data vector length
  N_points = length(t);
   
  % Calculate the number of data points to keep
  N_keep = round((1 - miss_fraction) * N_points);
  
  % Randonmly calculate the index of the data to keep
  keep_index = sort(randsample(N_points, N_keep));
  
  % Extract the data from time and y vector
  t = t(keep_index);
  y = y(keep_index);
  
  %% Shift the remaining points by a random amount within the input range
  N_points = length(t);
  
  %  Calculate the number of points to shift
  N_shift = round(shift_fraction * N_points);
  
  % Randonmly calculate the index of the data not to shift
  shift_index = sort(randsample(N_points, N_shift));
  
  % Randomly calculate the delay (positive or negative) and apply it  
  shifts = shift_range(1) + (shift_range(2) - shift_range(1))*rand(N_shift, 1);
  
  for kk = 1 : N_shift    
    t(shift_index(kk)) =  t(shift_index(kk)) + shifts(kk);
  end
  
end