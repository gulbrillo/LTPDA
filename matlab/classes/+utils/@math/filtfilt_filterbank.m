% FILTFILT_FILTERBANK computes filtfilt for filterbank objects
%%%
%
% CALL:  filtfilt_filterbank(in,fbk)
%
% INPUTS: input   -  input timeseries AO
%         fbk     -  filterbank object
%

function varargout = filtfilt_filterbank(input,fbk)

% get filter type
type = fbk.type;

% if parallel: loop over filters, add the outputs
if strcmpi(type,'parallel')
    % initialise
    y = zeros(size(input.y));
    % first loop do forward filter
    for ii = 1:numel(fbk.filters)
        filt_in = filter(fbk.filters(ii).a, fbk.filters(ii).b, input.y);
        y = y + filt_in;
    end
    
    % reverse data series
    yy = y(length(y):-1:1);
    
    y = zeros(size(input.y));
    % second loop do backward filter
    for ii = 1:numel(fbk.filters)
        filt_in = filter(fbk.filters(ii).a, fbk.filters(ii).b, yy);
        y = y + filt_in;
    end
    
    % reverse data series again
    y = y(length(y):-1:1);
    
    % if serial: sequentially filter, output of first is input to second
elseif strcmpi(type,'serial')
       
    % first loop do forward filter
    for ii = 1:numel(fbk.filters)
        % initialise
        if ii == 1
            y = input.y;
        end
        % in each iteration the output of filter k                            
        % is the input of filter k+1
        y = filter(fbk.filters(ii).a, fbk.filters(ii).b, y);
    end
    
    % reverse data series
    yy = y(length(y):-1:1);
    
    % second loop do backward filter
    for ii = 1:numel(fbk.filters)
        yy = filter(fbk.filters(ii).a, fbk.filters(ii).b, yy);
    end
    
    % reverse data series again
    y = yy(length(yy):-1:1);
    
else
    error('### filterbank must be either ''serial'' or ''parallel''.');
end


varargout{1} = y;

end





