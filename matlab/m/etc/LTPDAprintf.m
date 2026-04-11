
function LTPDAprintf(~, format, varargin)
% LTPDAprintf - styled printf for the LTPDA toolbox.
%
% Originally used com.mathworks internal APIs to render coloured text in
% the Command Window. Those APIs were removed in MATLAB R2025a, so this
% implementation falls back to plain fprintf (colour is silently ignored).
%
% CALL: LTPDAprintf(style, format, ...)
%   style  - RGB colour vector [r g b] (0..1 or 0..255) — ignored
%   format - printf-style format string
%
  fprintf(format, varargin{:});
end
