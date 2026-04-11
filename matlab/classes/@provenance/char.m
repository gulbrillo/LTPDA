% CHAR convert a provenance object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a provenance object into a string.
%
% CALL:        string = char(prov)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = [varargin{:}];

  pstr = '';
  for ii = 1:numel(objs)
    if ~isempty(pstr)
      pstr = [pstr ' | '];
    end

    pstr = [pstr sprintf('created by %s@%s[%s] on %s/%s/%s', ...
      objs(ii).creator,...
      objs(ii).hostname,...
      objs(ii).ip,...
      objs(ii).os,...
      objs(ii).matlab_version,...
      objs(ii).ltpda_version)];
  end

  %%% Prepare output
  varargout{1} = pstr;
end

