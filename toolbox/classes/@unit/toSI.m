% toSI converts the units to SI.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: toSI converts the units to SI base units.
%
%       Expand units to be combinations of
%         {'m', 'kg', 's', 'A', 'mol', 'cd', 'K'}
%
% CALL:        u_out = toSI(i_in);
%              u_out = toSI(i_in, ex1, ex2, ...);
%              [u_out, scale] = toSI(i_in);
%
% INPUTS:      i_in  - Single input unit
%              ex1   - Exception we don't want to convert
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = toSI(vi, varargin)
  
  if isempty(vi.strs)
    varargout{1} = vi;
    varargout{2} = 1;
    return;
  end
  
  scale           = 0;
  conversion_fact = 0;
  
  % process the units and exponents
  v = unit;
  for kk = 1:numel(vi.strs)
    [s, conv_f] = siForUnit(vi.strs{kk}, varargin{:});
    conversion_fact = conversion_fact + vi.exps(kk)*log10(conv_f);
    s = unit(s);
    s.exps = vi.exps(kk) .* s.exps;
    scale = scale + (vi.vals(kk) * (vi.exps(kk)));
    v = v .* s;
  end
  v.simplify;
  scale = 10^(double(scale) + conversion_fact);
  
  if scale ~= 1 && nargout ~= 2
    error('We cannot scale the input units %s. Please gather the scale factor [%d] in a second output', char(vi), scale);
  end
  
  % Either modify the input or set the output
  switch nargout
    case 2
      varargout{1} = v;
      varargout{2} = scale;
    case 1
      varargout{1} = v;
    case 0
      vi.strs = v.strs;
      vi.exps = v.exps;
      vi.vals = v.vals;
  end
  
end

function [s, scale_factor] = siForUnit(u, varargin)
  
  persistent constants
  
  exList = varargin;
  
  % output == input in default case
  s            = u;
  scale_factor = 1;
  
  if utils.helper.ismember(u, exList)
    % Don't convert
    return
  end
  
  % Load the physical constants plist
  if isempty(constants)
    constants =  plist(plist('built-in', 'physical_constants'));
  end
  
  switch u
    case 'rad'
      s = 'm m^-1';
    case 'sr'
      s = 'm^2 m^-2';
    case 'Hz'
      s = 's^-1';
    case 'N'
      s = 'm s^-2 kg';
    case 'Pa'
      s = 'm^-1 kg s^-2';
    case 'J'
      s = 'm^2 kg s^-2';
    case 'W'
      s = 'm^2 kg s^-3';
    case 'C'
      s = 'A s';
    case 'V'
      s = 'm^2 kg s^-3 A^-1';
    case 'F'
      s = 'm^-2 kg^-1 s^4 A^2';
    case 'Ohm'
      s = 'm^2 kg s^-3 A^-2';
    case 'S'
      s = 'm^-2 kg^-1 s^3 A^2';
    case 'Wb'
      s = 'm^2 kg s^-2 A^-1';
    case 'T'
      s = 's^-2 A^-1 kg';
    case 'H'
      s = 'm^2 kg s^-2 A^-2';
    case 'degC'
      s = 'K';
    case 'Bq'
      s = 's^-1';
    case 'eV'
      s = 'm^2 kg s^-2';
      scale_factor = find(constants, 'e');
    case 'e'
      s = 'C';
      scale_factor = find(constants, 'e');
    case 'bar'
      s = 'm^-1 kg s^-2';
      scale_factor = 1e5;
    case {'l', 'L'}
      s = 'm^3';
      scale_factor = 1e-3;
    case 'amu'
      s = 'kg';
      scale_factor = 1000 / find(constants, 'Na');
    case 'ly'
      s = 'm';
      scale_factor = 9460730472580800;
    case {'au', 'AU'}
      s = 'm';
      scale_factor = 149597870700;
    case 'pc'
      s = 'm';
      scale_factor = 3.0856776e16;
    case 'deg'
      s = 'm m^-1';
      scale_factor = pi / 180;
    case 'sccm'
      s = 'm^3 s^-1';
      scale_factor = 1e-6 / 60;
    case 'Count'
      s = '';
      scale_factor = 1;
    case 'min'
      s = 's';
      scale_factor = 60;
    case 'h'
      s = 's';
      scale_factor = 3600;
    case {'d', 'D'}
      s = 's';
      scale_factor = 86400;
    case 'cycles'
      s = 'm m^-1';
      scale_factor = 2*pi;
  end
end
