function varargout = extractTransitionTimes(varargin)
% UTILS.HELPER.EXTRACTTRANSITIONTIMES
% A utility to locate transitions in status flag and list the times and
% transitions.
%
% USAGE:
% [transTimes, transData] = utils.helper.extractTransitionTimes(sFlag)
% [transTimes, transData] = utils.helper.extractTransitionTimes(sFlag,modeMap)
% [transTimes, transData, interval] = utils.helper.extractTransitionTimes(sFlag,modeMap)
%
% Ira Thorpe
% 2015.06.22

% make generic mode map if we don't have one
if nargin < 2;
  for ii = 1:20;
    modeMap{ii} = num2str(ii-1);
  end
else
  modeMap = varargin{2};
end

% locate the status transitions
status = varargin{1};
statusy = status.y;
switch class(statusy)
  case 'uint8'
    statusy = cast(statusy,'int8');
  case 'uint16'
    statusy = cast(statusy,'int16');
  case 'uint32'
    statusy = cast(statusy,'int32');
  case 'uint64'
    statusy = cast(statusy,'int64');
  otherwise
end
dstatus = diff(statusy);
statusRising = find(dstatus > 0);
statusFalling = find(dstatus < 0);

% get t0
t0 = status.t0;

% build messages
for ii = 1:numel(statusRising)
  transTimes(ii) = t0+status.x(statusRising(ii)-1);
  transData{ii} = [...
    modeMap{status.y(statusRising(ii))+1}, ' ---> ',...
    modeMap{status.y(statusRising(ii)+1)+1}];
end
ii = numel(statusRising);

for jj = 1:numel(statusFalling)
  transTimes(ii+jj) = t0+status.x(statusFalling(jj)-1);
  transData{ii+jj} = [...
    modeMap{status.y(statusFalling(jj))+1}, ' ---> ',...
    modeMap{status.y(statusFalling(jj)+1)+1}];
end

% sort by time
if exist('transTimes','var') && ~isempty(transTimes)
  [~,idx] = sort(transTimes.toGPS,'ascend');
  transTimes = transTimes(idx);
  transData = transData(idx);

% generate intervals
delt = transTimes(1:end)-[t0 transTimes(1:end-1)];
for ii = 1:numel(delt)
  intv{ii} = [num2str(double(delt(ii)),'%g'),' s'];
end


varargout{1} = transTimes;
varargout{2} = transData;
varargout{3} = intv;

else
  varargout{1} = [];
  varargout{2} = [];
  varargout{3} = [];
end


end