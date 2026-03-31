%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ssmFromParfrac
%
% DESCRIPTION: Construct a statespace model from a ssmFromParfrac
%
% CALL:        see ssm, this function is private
%
% TODO:        check must be made there is no pole zero cancelation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssmFromParfrac(varargin)
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  % get info
  ii = ssm.getInfo('ssm', 'From Description');
  
  if nargin ~=2
    error('ssmFromRational need 2 inputs : (obj, plist) ')
  elseif isa(varargin{1}, 'parfrac') && isa(varargin{2}, 'plist')
    pl = combine(varargin{2}, ii.plists);
    parfracsin = varargin{1};
  else
    error('### Please input  (<object>,<plist>)');
  end
  
  ssmout = ssm.initObjectWithSize(size(parfracsin,1),size(parfracsin,2));
  for i =1:numel(parfracsin)
    
    res = parfracsin(i).res;
    poles = parfracsin(i).poles;
    dterm = parfracsin(i).dir;
    pmul = parfracsin(i).pmul;
    
    % check poles multiplicity
    for jj=1:length(pmul)
      if pmul(jj)~=1;
        error('!!! Poles multiplicity higher than 1 is not supported')
      end
    end
    
    % willing to work with columns
    if size(res,2)>1
      res = res.';
    end
    if size(poles,2)>1
      poles = poles.';
    end
    
    Nss = numel(poles);
    
    % convert to state space matrices
    [A,B,C,D] = utils.math.pf2ss(res,poles,dterm);
    
    
    
    ssmout(i).dmats = {D};
    ssmout(i).amats = {A};
    ssmout(i).bmats = {B};
    ssmout(i).cmats = {C};
    
    ssmout(i).name  = parfracsin(i).name;
    ssmout(i).timestep = 0;
    ssmout(i).addHistory(ii, pl, {''}, parfracsin(i).hist);
    
    inputstr = 'input';
    outputstr = 'output';
    ssstr =  'state';
    
    ssmout(i).inputs = ssmblock.makeBlocksWithData({inputstr}, [], {{inputstr}}, {parfracsin(i).iunits}, []);
    ssmout(i).outputs = ssmblock.makeBlocksWithData({outputstr}, [], {{outputstr}}, {parfracsin(i).ounits}, []);
    ssmout(i).states = ssmblock.makeBlocksWithSize(Nss, ssstr);
    
    if ~strcmp(pl.find('name'),'none')
      ssmout(i).name = pl.find('name');
    end
    if ~strcmp(pl.find('description'),'')
      ssmout(i).description = pl.find('description');
    end
  end
  
  varargout = {ssmout};
end


