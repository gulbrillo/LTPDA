%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ssmFromss
%
% DESCRIPTION: Construct a ltpda statespace object from a matlab statespace
%               object
%
% CALL:        see ssm, this function is private
%
% TODO:        inplement multiple i/o when subassign function is done
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys = ssmFromss(varargin)
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  % get info
  % Set the method version string in the minfo object
  
  if nargin ~=2
    error('ssmFromss need 2 inputs : (obj, plist) ')
  elseif isa(varargin{1}, 'ss') && isa(varargin{2}, 'plist')
    pl = varargin{2};
    ssin = varargin{1};
  else
    error('### Please input  (<object>,<plist>)');
  end
  
  sys = ssm.initObjectWithSize(1,1);
  sys.name = ssin.Name;
  if ~ isempty(ssin.Notes)
    sys.description = ssin.Notes;
  end
  
  [a,b,c,d,Ts] = ssdata(ssin) ;
  sys.amats = {a};
  sys.bmats = {b};
  sys.cmats = {c};
  sys.dmats = {d};
  sys.timestep = Ts;
  
  inputstr = 'input';
  outputstr = 'output';
  ssstr =  'state';
  
  sys.inputs = ssmblock.makeBlocksWithData({inputstr},{ssin.inputName}, [], [], [] );
  sys.outputs = ssmblock.makeBlocksWithData({outputstr},{ssin.outputName}, [], [], [] );
  sys.states = ssmblock.makeBlocksWithData({ssstr}, {ssin.stateName}, [], [], [] );
  
  if ~strcmp(pl.find('name'),'None')
    sys.name = pl.find('name');
  end
  if ~strcmp(pl.find('description'),'')
    sys.description = pl.find('description');
  end
  
end
