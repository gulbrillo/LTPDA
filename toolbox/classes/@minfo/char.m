% CHAR convert an minfo object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert an minfo object into a string.
%
% CALL:        string = char(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = utils.helper.collect_objects(varargin(:), 'minfo');

  pstr = '';
  for ii = 1:numel(objs)

    pp   = objs(ii);
    % method class
    pstr = [pstr  sprintf('%s/', pp.mclass)];
    % method name
    pstr = [pstr  sprintf('%s', pp.mname)];
    % method category
    pstr = [pstr  sprintf(', %s', pp.mcategory)];
    % method sets
    if ~isempty(pp.sets)
      pstr = [pstr  sprintf(', %s', utils.prog.cell2str(pp.sets))];
    end
  end

  %%% Prepare output
  varargout{1} = pstr;
end

