% MSG class that defines constants for different message levels.
% 
% Supported message levels
% 
%     OFF    = -1;
%     IMPORTANT = 0;
%     MNAME  = 1;    % Show AO method names
%     PROC1  = 2;    % AO processing 1
%     PROC2  = 3;    % AO processing 2
%     PROC3  = 4;    % AO processing 3
%     PROC4  = 5;    % AO processing 4
%     PROC5  = 6;    % AO processing 5
%     OMNAME = 7;    % Other classes method names
%     OPROC1 = 8;    % Other classes processing 1
%     OPROC2 = 9;    % Other classes processing 2
%     OPROC3 = 10;    % Other classes processing 3
%     OPROC4 = 11;   % Other classes processing 4
%     OPROC5 = 12;   % Other classes processing 5
% 
% M Hewitson 08-08-08
% 

classdef msg
  properties (Constant = true)
    OFF    = -1;
    IMPORTANT = 0;
    MNAME  = 1;    % Show AO method names
    PROC1  = 2;    % AO processing 1
    PROC2  = 3;    % AO processing 2
    PROC3  = 4;    % AO processing 3
    PROC4  = 5;    % AO processing 4
    PROC5  = 6;    % AO processing 5
    OMNAME = 7;    % Other classes method names
    OPROC1 = 8;    % Other classes processing 1
    OPROC2 = 9;    % Other classes processing 2
    OPROC3 = 10;    % Other classes processing 3
    OPROC4 = 11;   % Other classes processing 4
    OPROC5 = 12;   % Other classes processing 5
    
    % operating mode constants
    USER      = 0;
    DEBUG     = 1;
    DEVELOPER = 2;
  end
end
