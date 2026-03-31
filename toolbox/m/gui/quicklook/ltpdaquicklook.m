function varargout = ltpdaquicklook(varargin)

% LTPDAQUICKLOOK allows the user to quicklook LTPDA objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDAQUICKLOOK allows the user to quicklook LTPDA objects.
%
% CALL:        ltpdaquicklook
%
%
% VERSION:     $Id$
%
% HISTORY: 07-03-08 M Hewitson
%             Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Check if I exist already
hs = findall(0);
found = -1;
for j=1:length(hs)
  h = hs(j);
  if strcmp(get(h, 'Tag'), 'LTPDAquicklook')
    found = h;
  end
end
if found ~= -1
  figure(found);
  return
end

% id = findobj('Tag', 'LTPDAquicklook');
% if ~isempty(id)
%   figure(id)
%   return
% end

%% Some initial setup

Gproperties.Gcol    = [240 240 240]/255;
Gproperties.Gwidth  = 600;
Gproperties.Gheight = 400;
Gproperties.Gborder = 10;
fontsize = 12;

Gproperties.Screen   = get(0,'screensize');
Gproperties.Gposition = [150 ...
  100 ...
  Gproperties.Gwidth...
  Gproperties.Gheight];

%  Initialize and hide the GUI as it is being constructed.
mainfig = figure('Name', 'LTPDA Quicklook',...
  'NumberTitle', 'off',...
  'Visible','off',...
  'Position',Gproperties.Gposition,...
  'Color', Gproperties.Gcol,...
  'Toolbar', 'none',...
  'MenuBar', 'none',...
  'Resize', 'off',...
  'HandleVisibility', 'callback', ...
  'Tag', 'LTPDAquicklook');

% Set mainfig callbacks
set(mainfig, 'CloseRequestFcn', {@ltpda_quicklook_close, mainfig});

% Set Application data
setappdata(mainfig, 'Gproperties', Gproperties);


%% GUI Parts

% Objects list
objs = getWorkspaceObjs();
setappdata(mainfig, 'objs', objs);

lbh = uicontrol(mainfig,'Style','listbox',...
  'String',{' '},...
  'Value',1,...
  'BackgroundColor', 'w',...
  'Fontsize', fontsize,...
  'Max', 1000,...
  'Position',[10 90 150 300],...
  'Tag', 'LTPDA_quicklook_objlist');

% Set callback
set(lbh, 'Callback', {@objList, mainfig});

setWorkspaceObjsList(objs)

% Refresh button
pbh = uicontrol(mainfig,'Style','pushbutton',...
  'String','Refresh',...
  'Callback', {@refresh, mainfig}, ...
  'Position',[10 70 60 25]);


% Object display
sth = uicontrol(mainfig,'Style','text',...
  'String','',...
  'BackgroundColor', 'w', ...
  'ForegroundColor', 'b', ...
  'HorizontalAlignment', 'left', ...
  'Tag', 'LTPDA_quicklook_display', ...
  'Position',[170 90 420 300]);

% Plot button
pbh = uicontrol(mainfig,'Style','pushbutton',...
  'String','iplot',...
  'Callback', {@call_iplot, mainfig}, ...
  'Position',[10 10 60 25]);

% history plot
pbh = uicontrol(mainfig,'Style','pushbutton',...
  'String','plot history',...
  'Callback', {@call_histplot, mainfig}, ...
  'Position',[80 10 80 25]);


%% Start the GUI

% Make the GUI visible.
set(mainfig,'Visible','on')

%% Callbacks

%---------------- history plot
function call_histplot(varargin)

mainfig = varargin{end};
objs = getappdata(mainfig, 'objs');

% get selection
olh = findobj(mainfig, 'Tag', 'LTPDA_quicklook_objlist');
idx = get(olh, 'Value');

cmd = sprintf('obj = evalin(''base'', ''%s'');', objs(idx).name);
eval(cmd);

plot(obj.hist);


%---------------- iplot
function call_iplot(varargin)

mainfig = varargin{end};
objs = getappdata(mainfig, 'objs');

% get selection
olh = findobj(mainfig, 'Tag', 'LTPDA_quicklook_objlist');
idx = get(olh, 'Value');

cmd = sprintf('obj = evalin(''base'', ''%s'');', objs(idx).name);
eval(cmd);

iplot(obj);

%---------------- refresh
function refresh(varargin)

mainfig = varargin{end};
objs = getWorkspaceObjs();
setWorkspaceObjsList(objs)
setappdata(mainfig, 'objs', objs);

%---------------- Close function
function ltpda_quicklook_close(varargin)
% Callback executed when the GUI is closed

disp('* Goodbye from the LTPDA Quicklook GUI *')
delete(varargin{1})


%---------------- Get a list of LTPDA objects in the MATLAB workspace
function objs = getWorkspaceObjs()

% get base workspace variables
ws_vars = evalin('base','whos');

objs = [];
for j=1:length(ws_vars)
  cmd = sprintf('obj = evalin(''base'', ''%s'');', ws_vars(j).name);
  eval(cmd)
  if isa(obj, 'ltpda_uo')
    objs = [objs ws_vars(j)];
  end
end


%---------------- Callback for list selection
function objList(varargin)

mainfig = varargin{end};
objs = getappdata(mainfig, 'objs');

% get selection
olh = findobj(mainfig, 'Tag', 'LTPDA_quicklook_objlist');
idx = get(olh, 'Value');

cmd = sprintf('obj = evalin(''base'', ''%s'');', objs(idx).name);
eval(cmd);

txt = display(obj);

dh = findobj(mainfig, 'Tag', 'LTPDA_quicklook_display');
set(dh, 'String', txt);


%---------------- Fill the workspace object list
function setWorkspaceObjsList(objs)

id = findobj('Tag', 'LTPDA_quicklook_objlist');

objlist = [];
for j=1:length(objs)
  obj = objs(j);
  str = sprintf('%s\t\t(%s)', obj.name, obj.class);
  objlist = [objlist cellstr(str)];
end

set(id, 'Value', 1);
set(id, 'String', objlist);


