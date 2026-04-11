% CHAR convert a specwin object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a specwin object into a string.
%
% CALL:        string = char(sw);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  %%% Get input
  objs = [varargin{:}];

  pstr = [];
  for kk = 1:numel(objs)
    w = objs(kk);

    pstr = ['(' pstr w.type];
    pstr = [pstr ', length=' num2str(w.len)];
    pstr = [pstr ', alpha=' num2str(w.alpha)];
    pstr = [pstr ', psll=' num2str(w.psll)];
    pstr = [pstr ', rov=' num2str(w.rov)];
    pstr = [pstr ', nenbw=' num2str(w.nenbw)];
    pstr = [pstr ', w3db=' num2str(w.w3db)];
    pstr = [pstr ', flatness=' num2str(w.flatness) '), '];

    pstr = strrep(pstr, '_', '\_');
  end

  varargout{1} = pstr(1:end-2);

end

