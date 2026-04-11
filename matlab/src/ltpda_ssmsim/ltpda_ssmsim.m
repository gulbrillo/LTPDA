
% LTPDA_SSMSIM A mex file to propagate an input signal for a given SS model.
%
% function [y,x] = ltpda_ssmsim(lastX, A, Coutputs, Cstates, Baos, Daos, input);
%
% Inputs:
%      lastX - the initial states
%          A - The A matrix
%   Coutputs - The C matrix containing elements only for the selected output
%    Cstates - The C matrix containing elements only for the selected states
%       Baos - The B matrix with elements only for the input AOs
%       Daos - The D matrix with elements only for the input AOs
%      input - The input signal vector
%     
% Outputs:
%      y = the output signal
%      x = the output state vector
%
% M Hewitson 19-08-10
% 

