function out = structcat(varargin)
% STRUCTCAT concatonate structures to make one large structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRUCTCAT concatonate structures to make one large
%              structure.
%
% CALL:       out = structcat(struct1, struct2, ...)
%
% INPUTS:     struct1 - a structure
%             struct2 - a structure
%
% OUTPUTS:    out - structure with all fields of input structures.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = [];

for s=1:nargin

  % get first input structure
  st = varargin{s};

  % check fields
  fields = fieldnames(st);
  nf     = length(fields);

  for f=1:nf

    field = fields{f};
    % check if this field already exists
    if isfield(out, field)
      warning(sprintf('!!! duplicate field ''%s'' found - skipping.', field));
    else
      % we can add this field
      out.(field) = st.(field);
    end
  end
end

% END