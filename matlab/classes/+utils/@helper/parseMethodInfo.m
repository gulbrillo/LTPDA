% PARSEMETHODINFO parses the standard function information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARSEMETHODINFO parses the standard function information.
%
%  out = utils.helper.parseMethodInfo(info, plist, version, category)
%
% The following call returns a parameter list object that contains the
% default parameter values:
%
% >> pl = utils.helper.parseMethodInfo('Params')
%
% The following call returns a string that contains the routine CVS version:
%
% >> version = utils.helper.parseMethodInfo('Version')
%
% The following call returns a string that contains the routine category:
%
% >> category = utils.helper.parseMethodInfo('Category')
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = parseMethodInfo(varargin)

VERSION  = '';
CATEGORY = 'Utility';

if nargin == 1
  % Then return my own values
  out = [];
  switch varargin{1}
    case 'Params'
      out = plist();
    case 'Version'
      out = VERSION;
    case 'Category'
      out = CATEGORY;
  end
else
  % Deal with someone else's values
  out = [];
  switch varargin{1}
    case 'Params'
      out = varargin{2};
    case 'Version'
      out = varargin{3};
    case 'Category'
      out = varargin{4};
  end
end