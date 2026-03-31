% STRING writes a command string that can be used to recreate the input history object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input history object.
%
% CALL:        cmd = string(history_obj)
%
% INPUT:       history_obj - history object
%
% OUTPUT:      cmd         - command string to create the input object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

  objs = [varargin{:}];

  cmd = '';

  for ii = 1:numel(objs)
    hh = objs(ii);
    m_info  = hh.methodInfo;
    pl_used = hh.plistUsed;
    in_hist = hh.inhists;

    %%% Create minfo string
    if isempty(m_info)
      minfo_str = '[]';
    else
      minfo_str = string(m_info);
    end

    %%% Create plist string
    if isempty(pl_used)
      pl_str = '[]';
    else
      pl_str = string(pl_used);
    end

    %%% Create history string
    if isempty(in_hist)
      hi_str = '[]';
    else
      hi_str = string(in_hist);
    end
    if isempty(hi_str)
      hi_str = '[]';
    end

    cmd = [cmd 'history(' minfo_str, ', ' pl_str, ', '  hi_str,  ') '];
  end

  if numel(objs) > 1
    cmd = ['[ ' cmd ']'];
  end

  varargout{1} = cmd;
end

