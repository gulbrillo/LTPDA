% GETDC get the DC gain factor for a pole-zero model
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
% the zero-frequency-gain (zfg) or DC gain of this object is obtained by
% the equation, for s = 0.
% LTPDA pzmodels are constructed by poles, zeros and DC gain. This means
% that the value stored in the 'gain' field of the model is the dc gain!
% This function calculate k.
% 
% CALL:
% 
%     dc = getdc(z,p,k)
% 
% INPUT:
% 
%     z: zeros
%     p: poles
%     k: gain coefficient
%       
% 
% OUTPUT:
% 
%     dc: dc gain of the model 
% 
% NOTE:
% 
%     
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dc = getdc(z,p,k)

zrs = prod(-1*z);
pls = prod(-1*p);

dc = k*zrs/pls;

end







