%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ssmFromMiir
%
% DESCRIPTION: Construct a statespace model from a miir
%
% CALL:        see ssm, this function is private
%
% TODO:        check must be made there is no pole zero cancelation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssmFromMiir(varargin)
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  % get info
  ii = ssm.getInfo('ssm', 'from miir');
  
  if nargin ~=2
    error('ssmFromss need 2 inputs : (obj, plist) ')
  elseif isa(varargin{1}, 'miir') && isa(varargin{2}, 'plist')
    pl = combine(varargin{2}, ii.plists);
    miirsin = varargin{1};
  else
    error('### Please input  (<object>,<plist>)');
  end
  
  ssmout = ssm.initObjectWithSize(size(miirsin,1),size(miirsin,2));
  for i =1:numel(miirsin)
    num =  miirsin(i).a;
    den =  miirsin(i).b;
    num = num/den(1);
    den = den/den(1);
    Nss = size(den,2)-1;
    if length(num)<Nss+1
      num = [zeros(1,Nss+1-length(num)) num];
    end
    [q,r] = deconv(num,den);%polynmial division for den = conv(num,q)+r .
    if ~length(q)==1
      error('system may be non caussal');
    end
    
    ssmout(i).dmats = {q};
    ssmout(i).amats = {[zeros(Nss-1,1) eye(Nss-1); fliplr(-den(2:(Nss+1)))]};
    ssmout(i).bmats = {zeros(Nss,1)};
    if Nss>0
      ssmout(i).bmats{1}(Nss) = 1;
    end
    ssmout(i).cmats = {fliplr(r(2:(Nss+1)))};
    
    ssmout(i).name  = miirsin(i).name;
    ssmout(i).timestep = 1/(miirsin(i).fs);
    
    inputstr = 'input';
    outputstr = 'output';
    ssstr =  'state';
    
    ssmout(i).inputs = ssmblock.makeBlocksWithData({inputstr},[],{{inputstr}}, {miirsin(i).iunits},[]  );
    ssmout(i).outputs = ssmblock.makeBlocksWithData({outputstr},[],{{outputstr}}, {miirsin(i).ounits},[] );
    ssmout(i).states = ssmblock.makeBlocksWithSize(Nss, ssstr);
    
    ssmout(i).addHistory(ii, pl, {''}, miirsin(i).hist);
    
    if ~strcmp(pl.find('name'),'None')
      ssmout(i).name = pl.find('name');
    end
    if ~strcmp(pl.find('description'),'')
      ssmout(i).description = pl.find('description');
    end
    
  end
  
  varargout = {ssmout};
end


