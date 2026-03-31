% ECDF Compute empirical cumulative distribution function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute empirical cumulative distribution function for a series of data
% 
% CALL 
% 
% [F,X] = ecdf(Y);
% 
% INPUT
% 
% - Y, a data series
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,X] = ecdf(Y)

  % sort input data
  X = sort(Y);
  
  % define variable for cumulative sum
  sw = ones(size(X));
  n = numel(sw);

  jj = 2; 
  idd = false(size(sw));
  % Fi is calculated practically as Fi = ni/n where ni is the position of
  % the ith element of the sorted input array. If two or more elements are
  % equal then only the ni corresponding to the last one is considered and
  % the other elements are removed. ni is obtained by a cumulative sum of
  % an arrays of ones. If k elements are equal they are removed and
  % substituted by a single k.
  while jj < n+1
    if X(jj) ~= X(jj-1); % if successive elements are different we can go on
      jj = jj+1;
    else % if some elements are equal than we have to count the equal elements
      jt = jj+1;
      while jt<=n+1 && X(jt-1)==X(jj-1) % counting equal elements
        jt = jt + 1;
      end

      for ji=jj:jt-2
        idd(ji-1) = true; % make the assignement for successive removal of elements
      end
      t = jt-jj;
      % set the value corresponding to the number of equal elements in
      % correspondence to the last element of the series of eqials
      sw(jt-2) = t; 

      jj = jt;
    end
  end

  % remove unwanted elements corresponding to duplicates
  sw(idd) = [];
  
  % calculate cumulative distribution by cumulative sum
  F = cumsum(sw)./n;
  
  % remove elements corresponding to replicas
  X(idd) = [];

end