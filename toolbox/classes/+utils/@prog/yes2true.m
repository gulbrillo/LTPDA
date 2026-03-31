function out = yes2true(in)
% YES2TRUE converts strings containing 'yes'/'no' into boolean true/false
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: YES2TRUE converts: 
%              - strings containing 'yes'/'no' into boolean true/false
%              - strings containing 'true'/'false' into boolean true/false
%              - double containing 1/0/-1 etc into boolean true/false
%
% CALL:       out = yes2true(in)
%
% INPUTS:     in - the variable to scan (may be a boolean, a double, or a
%                  string)
%
% OUTPUTS:    out - a boolean value calculated according to the following
%                   table:
%             INPUT CLASS   INPUT VALUE      OUTPUT VALUE
%             boolean       true             true
%             boolean       false            false
%             string        'true'           true
%             string        'false'          false
%             string        'yes'            true
%             string        'no'             false
%             double         >= 1            true
%             double         <= 0            false
%             empty         empty            false
%
% EXAMPLE:    >> pl = plist('variance', 'yes');
%             >> v = find(pl, 'variance');
%             >> yes2true(v)
%             ans =
%                   1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(in)
  out = false;
elseif iscell(in)
  out = in;
elseif ischar(in)
  switch lower(in)
    case {'yes', 'true', 'on', 'y', '1'}
      out = true;
    case {'no', 'false', 'off', 'n', '0', '-1'}
      out = false;
    otherwise
      error('Unknown option %s', in);
  end
elseif isfloat(in)
  out = (in > 0);
elseif islogical(in)
  out = in;
else
  error('Unsupported type %s', class(in));
end

% END
