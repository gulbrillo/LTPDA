% PZM2AB convert pzmodel to IIR filter coefficients using bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PZM2AB convert pzmodel to IIR filter coefficients using bilinear
%              transform.
%
% CALL:        [a,b] = pzm2ab(pzm, fs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pzm2ab(varargin)

  import utils.const.*
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  %%% Collect all AOs and plists
  [pzm, pzm_invars, fs] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);

  %%% Check inputs
  if numel(pzm) ~= 1
    error('### Please use only one PZ-Model.');
  end
  if numel(fs) ~= 1 && ~isnumeric(fs)
    error('### Please define ''fs''.');
  else
    fs = fs{1};
  end

  gain  = pzm.gain;
  poles = pzm.poles;
  zeros = pzm.zeros;
  np = numel(poles);
  nz = numel(zeros);

  ao = [];
  bo = [];

  utils.helper.msg(utils.const.msg.OPROC1, 'converting %s', pzm.name)

  % First we should do complex pole/zero pairs
  cpoles = [];
  for j=1:np
    if poles(j).q > 0.5
      cpoles = [cpoles poles(j)];
    end
  end
  czeros = [];
  for j=1:nz
    if zeros(j).q > 0.5
      czeros = [czeros zeros(j)];
    end
  end

  czi = 1;
  for j=1:length(cpoles)
    if czi <= length(czeros)
      % we have a pair
      p = cpoles(j);
      z = czeros(czi);

      [ai,bi] = cpolezero(p.f, p.q, z.f, z.q, fs);
      if ~isempty(ao)
        [ao,bo] = pzmodel.abcascade(ao,bo,ai,bi);
      else
        ao = ai;
        bo = bi;
      end

      % increment zero counter
      czi = czi + 1;
    end
  end

  if length(cpoles) > length(czeros)
    % do remaining cpoles
    for j=length(czeros)+1:length(cpoles)
      utils.helper.msg(msg.OPROC2, 'computing complex pole');
      [ai,bi] = cp2iir(cpoles(j), fs);
      if ~isempty(ao)
        [ao,bo] = pzmodel.abcascade(ao,bo,ai,bi);
      else
        ao = ai;
        bo = bi;
      end
    end
  else
    % do remaining czeros
    for j=length(cpoles)+1:length(czeros)
      utils.helper.msg(msg.OPROC2, 'computing complex zero');
      [ai,bi] = cz2iir(czeros(j), fs);
      if ~isempty(ao)
        [ao,bo] = pzmodel.abcascade(ao,bo,ai,bi);
      else
        ao = ai;
        bo = bi;
      end
    end
  end

  % Now do the real poles and zeros
  for j=1:np
    pole = poles(j);
    if isnan(pole.q) || pole.q < 0.5
      utils.helper.msg(msg.OPROC2, 'computing real pole');
      [ai,bi] = rp2iir(pole, fs);
      if ~isempty(ao)
        [ao,bo] = pzmodel.abcascade(ao,bo,ai,bi);
      else
        ao = ai;
        bo = bi;
      end
    end
  end

  for j=1:nz
    zero = zeros(j);
    if isnan(zero.q) || zero.q < 0.5
      utils.helper.msg(msg.OPROC2, 'computing real zero');
      [ai,bi] = rz2iir(zero, fs);
      if ~isempty(ao)
        [ao,bo] = pzmodel.abcascade(ao,bo,ai,bi);
      else
        ao = ai;
        bo = bi;
      end
    end
  end

  ao = ao.*gain;

  varargout{1} = ao;
  varargout{2} = bo;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    cpolezero
%
% DESCRIPTION: Return IIR filter coefficients for a complex pole and
%              complex zero designed using the bilinear transform.
%
% CALL:        [a,b] = cpolezero(pf, pq, zf, zq, fs)
%
% HISTORY:     18-02-2007 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a,b] = cpolezero(pf, pq, zf, zq, fs)

  import utils.const.*
  utils.helper.msg(msg.OPROC1, 'computing complex pole/zero pair');

  wp = pf*2*pi;
  wp2 = wp^2;
  wz = zf*2*pi;
  wz2 = wz^2;

  k = 4*fs*fs + 2*wp*fs/pq + wp2;

  a(1) = (4*fs*fs + 2*wz*fs/zq + wz2)/k;
  a(2) = (2*wz2 - 8*fs*fs)/k;
  a(3) = (4*fs*fs - 2*wz*fs/zq + wz2)/k;
  b(1) = 1;
  b(2) = (2*wp2 - 8*fs*fs)/k;
  b(3) = (wp2 + 4*fs*fs - 2*wp*fs/pq)/k;

  % normalise dc gain to 1
  g = iirdcgain(a,b);
  a = a / g;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    iirdcgain
%
% DESCRIPTION: Work out the DC gain of an IIR filter given the coefficients.
%
% CALL:        g = iirdcgain(a,b)
%
% INPUTS:      a - numerator coefficients
%              b - denominator coefficients
%
% OUTPUTS      g - gain
%
% HISTORY:     03-07-2002 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function g = iirdcgain(a,b)
  suma = sum(a);
  if(length(b)>1)
    sumb = sum(b);
    g = suma / sumb;
  else
    g = suma;
  end
end
