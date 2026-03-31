% DISP overloads display functionality for data3D objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for data3D objects.
%
% CALL:        txt    = disp(obj)
%
% INPUT:       obj - any data3D object
%
% OUTPUT:      txt - cell array with strings to display the data3D object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  txt = {};
  
  obj = varargin{1};
  
  % --- define values for the x-axis
  xname    = 'N-DEF';
  sxdata   = [nan nan];
  sxddata  = [nan nan];
  clxdata  = '--- OBJECT NOT DEFINED ---';
  clxddata = '--- OBJECT NOT DEFINED ---';
  xunits   = '';
  if ~isempty(obj.xaxis)
    xname    = obj.xaxis.name;
    if ~isempty(obj.xaxis.data)
      sxdata   = size(obj.xaxis.data);
    else
      sxdata   = size(obj.yaxis.data);
    end
    sxddata  = size(obj.xaxis.ddata);
    clxdata  = class(obj.xaxis.data);
    clxddata = class(obj.xaxis.ddata);
    xunits   = char(obj.xunits);
  end
  % --- define values for the y-axis
  yname    = 'N-DEF';
  sydata   = [nan nan];
  syddata  = [nan nan];
  clydata  = '--- OBJECT NOT DEFINED ---';
  clyddata = '--- OBJECT NOT DEFINED ---';
  yunits   = '';
  if ~isempty(obj.yaxis)
    yname = obj.yaxis.name;
    sydata   = size(obj.yaxis.data);
    syddata  = size(obj.yaxis.ddata);
    clydata  = class(obj.yaxis.data);
    clyddata = class(obj.yaxis.ddata);
    yunits   = char(obj.yunits);
  end
  % --- define values for the z-axis
  zname    = 'N-DEF';
  szdata   = [nan nan];
  szddata  = [nan nan];
  clzdata  = '--- OBJECT NOT DEFINED ---';
  clzddata = '--- OBJECT NOT DEFINED ---';
  zunits   = '';
  if ~isempty(obj.zaxis)
    zname = obj.zaxis.name;
    szdata   = size(obj.zaxis.data);
    szddata  = size(obj.zaxis.ddata);
    clzdata  = class(obj.zaxis.data);
    clzddata = class(obj.zaxis.ddata);
    zunits   = char(obj.zunits);
  end
  
  banner = sprintf('-------- %s [%s, %s, %s] --------', class(obj), xname, yname, zname);
  txt{end+1} = banner;
  
  txt{end+1} = ' ';
  
  txt{end+1} = sprintf('     x:  [%d %d], %s', sxdata, clxdata);
  txt{end+1} = sprintf('     y:  [%d %d], %s', sydata, clydata);
  txt{end+1} = sprintf('     z:  [%d %d], %s', szdata, clzdata);
  txt{end+1} = sprintf('    dx:  [%d %d], %s', sxddata, clxddata);
  txt{end+1} = sprintf('    dy:  [%d %d], %s', syddata, clyddata);
  txt{end+1} = sprintf('    dz:  [%d %d], %s', szddata, clzddata);
  txt{end+1} = sprintf('xunits:  %s', xunits);
  txt{end+1} = sprintf('yunits:  %s', yunits);
  txt{end+1} = sprintf('zunits:  %s', zunits);
  
  varargout{1} = txt;
end


