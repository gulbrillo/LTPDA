% RAND return a random number between r1 and r2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RAND return a random number between r1 and r2
%
% CALL:       val = rand(r1, r2)
%
% INPUTS:     r1  - lower limit of the random values
%             r2  - upper limit of the random values
%
% OUTPUTS:    val - random numbers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = rand(r1, r2)
  
  int = r2-r1;
  rng('shuffle');
  val = r1 + int*rand;
  
end
% END

