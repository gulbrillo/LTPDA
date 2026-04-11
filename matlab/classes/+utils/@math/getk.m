% GETK get the mathematical gain factor for a pole-zero model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION
% 
% A zpk model in matlab notation is an object of the type:
% 
%         (s-z1)...(s-zN)
% zpk = k*----------------
%         (s-p1)...(s-pn)
% 
% the zero-frequency-gain (zfg) of this object is obtained by the equation,
% for s = 0.
% LTPDA pzmodels are constructed by poles, zeros and zero-frequency-gain
% (zfg). This means that the value stored in the 'gain' field of the model
% is the zfg!
% This function calculate k.
% 
% CALL:
% 
%     k = getk(z,p,zfg)
% 
% INPUT:
% 
%     z zeros
%     p poles
%     zfg zero frequency gain (model resp at zero frequency)
%       
% 
% OUTPUT:
% 
%     k mathematical gain
% 
% NOTE:
% 
%     
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function k = getk(z,p,zfg)

zrs = prod(-1*z);
pls = prod(-1*p);

k = zfg*pls/zrs;

end







