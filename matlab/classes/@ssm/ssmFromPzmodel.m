%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ssmFromPzmodel
%
% DESCRIPTION: Construct a statespace model from a pzmodel
%
% CALL:        see ssm, this function is private
%
% TODO :  Modify using ss2zp/zp2ss
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ssmout = ssmFromPzmodel(varargin)
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  % get info
  ii = ssm.getInfo('ssm', 'from pzmodel');
  
  if nargin ~=2
    error('ssmFromPzmodel need 2 inputs : (obj, plist) ')
  elseif isa(varargin{1}, 'pzmodel') && isa(varargin{2}, 'plist')
    pl = combine(varargin{2}, ii.plists);
    pzm = varargin{1};
  else
    error('### Please input  (<object>,<plist>)');
  end
  
  ssmout = ssm.initObjectWithSize(size(pzm,1),size(pzm,2));
  
  for i_pzms=1:numel(pzm)
    [A,B,C,D] = utils.math.pzmodel2SSMats(pzm(i_pzms));
    
    ssmout(i_pzms).dmats = {D};
    ssmout(i_pzms).amats = {A};
    ssmout(i_pzms).bmats = {B};
    ssmout(i_pzms).cmats = {C};
    
    ssmout(i_pzms).name  = pzm(i_pzms).name;
    ssmout(i_pzms).timestep = 0;
    
    inputstr = 'input';
    outputstr = 'output';
    ssstr =  'state';
    Nss = size(A,1);
    
    ssmout(i_pzms).inputs = ssmblock.makeBlocksWithData({inputstr}, [], {{inputstr}}, {pzm(i_pzms).iunits}, []);
    ssmout(i_pzms).outputs = ssmblock.makeBlocksWithData({outputstr}, [], {{outputstr}}, {pzm(i_pzms).ounits}, []);
    ssmout(i_pzms).states = ssmblock.makeBlocksWithSize(Nss, ssstr);
    
    ssmout(i_pzms).addHistory(ii, pl, {''}, pzm(i_pzms).hist);
    
    if ~strcmp(pl.find('name'),'None')
      ssmout(i_pzms).name = pl.find('name');
    end
    if ~strcmp(pl.find('description'),'')
      ssmout(i_pzms).description = pl.find('description');
    end
    
  end
  
  
end
