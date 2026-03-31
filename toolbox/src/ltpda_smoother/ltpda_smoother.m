
% LTPDA_SMOOTHER A mex file to compute a running smoothing filter.
%
% function sy = ltpda_smoother(y, bw, ol, method);
%
% Inputs:
%      y     - data vector
%     bw     - bandwidth over which to compute each sample
%     ol     - percentage of outliers to discard from each sample estimate [0-1]
%     method - choose from 'median'
%     
% Outputs:
%     sy - the smoothed data vector
%
% M Hewitson 02-10-06
% 
