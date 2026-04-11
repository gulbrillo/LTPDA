% downsample spectrum in order to ensure independence between frequency
% bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xd,yd] = downsampleSpectrum(x,y,factor)

% downsample frequency of a factor in order to ensure independence
% between different bins
iddfreq = 1:factor:numel(x);
idxf = false(size(y));
idxf(iddfreq) = true;

xd = x(idxf);
yd = y(idxf);

end
