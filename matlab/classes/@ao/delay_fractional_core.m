% DELAY_FRACTIONAL_CORE core method to implement fractional delay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method which computes the fft.
%
% CALL:        ao = delay_fractional_core(y,del,step)
%
% INPUTS:      y:    input time series
%              del:  fractional delay 0< del < 1
%              step: time step (1/fs)    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yd = delay_fractional_core(y,del,step)

del = del/step;
delSeries = [1; -del; del^2/2; -del^3/6; del^4/24];

[cc,fc,bc] = fdc();

cc = cc'*delSeries;
fc = fc'*delSeries;
bc = bc'*delSeries;

% backward
y1 = [0;y(1:end-1)];
y11 = [0;0;y(1:end-2)];

% forward
y2 = [y(2:end);0];
y22 = [y(3:end);0;0];

yd = cc(1)*y11+cc(2)*y1+cc(3)*y+cc(4)*y2+cc(5)*y22;

% handle edge effects
yd(1) = fc(6)*y(1)+fc(7)*y(2)+fc(8)*y(3)+fc(9)*y(4)+fc(10)*y(5)+fc(11)*y(6);
yd(2) = fc(6)*y(2)+fc(7)*y(3)+fc(8)*y(4)+fc(9)*y(5)+fc(10)*y(6)+fc(11)*y(7);
yd(end) = bc(6)*y(end)+bc(5)*y(end-1)+bc(4)*y(end-2)+bc(3)*y(end-3)+bc(2)*y(end-4)+bc(1)*y(end-5);
yd(end-1) = bc(6)*y(end-1)+bc(5)*y(end-2)+bc(4)*y(end-3)+bc(3)*y(end-4)+bc(2)*y(end-5)+bc(1)*y(end-6);

end

function [cc,fc,bc] = fdc()
cc = [0, 0, 1, 0, 0;...
  0, -1/2, 0, 1/2, 0;...
  0, 1, -2, 1, 0;...
  -1/2, 1, 0, -1, 1/2;...
  1, -4, 6, -4, 1];
fc = [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;...
  0, 0, 0, 0, 0, -3/2, 2, -1/2, 0, 0, 0;...
  0, 0, 0, 0, 0, 2, -5, 4, -1, 0, 0;...
  0, 0, 0, 0, 0, -5/2, 9, -12, 7, -3/2, 0;...
  0, 0, 0, 0, 0, 3, -14, 26, -24, 11, -2];
bc = [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;...
  0, 0, 0, 1/2, -2, 3/2, 0, 0, 0, 0, 0;...
  0, 0, -1, 4, -5, 2, 0, 0, 0, 0, 0;...
  0, 3/2, -7, 12, -9, 5/2, 0, 0, 0, 0, 0;...
  -2, 11, -24, 26, -14, 3, 0, 0, 0, 0, 0];
end