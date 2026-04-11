% STOPFIT verify fit accuracy checking for specified condition.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     Verify fit accuracy checking for a specified condition. Available
%     conditions are:
% 
%     Log Residuals difference
%     Check if the minimum of the logarithmic difference between data and
%     residuals is larger than a specified value. ie. if the conditioning
%     value is 2, the function ensures that the difference between data and
%     residuals is at lest 2 order of magnitude lower than data itsleves.
%     Checking algorithm is:
%     lsr = log10(abs(y))-log10(abs(rdl));
%     min(lsr) > lrscond;
% 
%     Log Residuals difference and Root Mean Squared Error
%     Check if the log difference between data and residuals is in
%     larger than the value indicated in lsrcond and that the variation of
%     the root mean squared error is lower than 10^(-1*msevar).
%     Checking algorithm is:
%     lsr = log10(abs(y))-log10(abs(rdl));
%     (lsr > lrscond) && (mse < 10^(-1*lrsvarcond));
% 
% CALL:
% 
%      [ext,msg] = stopfit(y,rdl,mse,ctp,lrscond,msevar)
% 
% INPUTS:
% 
%     - y are the fitting data (in case of 'lrs' and 'lrsmse') or the
%     fitted model (in case of 'rft' and 'rftmse')
%     - rdl are the fit residuals
%     - mse is a vector storing the values of root mean squared errors
%     difference for the present and previuos iterations
%     - order is the model order
%     - ctp defines the conditioning type. Admitted values are:
%       1) 'chival' check if the value of the Mean Squared Error is lower
%       than 10^(-1*lsrcond).
%       2) 'chivar' check if the value of the Mean Squared Error is lower
%       than 10^(-1*lsrcond) and if the relative variation of mean squared error is
%       lower than 10^(-1*msevar).
%       3) 'lrs' check if the log difference between data and residuals is
%       point by point larger than the value indicated in lsrcond. This
%       mean that residuals are lsrcond order of magnitudes lower than
%       data.
%       4) 'lrsmse' check if the log difference between data and
%       residuals is larger than the value indicated in lsrcond and if the
%       relative variation of root mean squared error is lower than
%       10^(-1*msevar).
%       5) 'rft' check if the spectral flatness coefficient for the
%       rersiduals is larger than the value passed in lrscond. In this case
%       only values 0 < lrscond < 1 are allowed.
%       6) 'rftmse' check if the spectral flatness coefficient for the
%       rersiduals is larger than the value passed in lrscond and if the
%       relative variation of root mean squared error is lower than 10^(-1*msevar).
%       In this case only values 0 < lrscond < 1 are allowed.
% 
% OUTPUT:
% 
%     - ext is 1 if the specified condition is satisfied or 0 if not
%     - msg is a string containing a messagge
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ext,msg] = stopfit(y,rdl,mse,ctp,lrscond,msevar)

  % switching between conditions
  switch ctp
    case 'chival'
      if isempty(lrscond)
        lrscond = 2; % Default value
      end

      hh = length(mse);
      lsr = -1*log10(mse(hh));
      if lsr > lrscond
        msg = 'Reached tolerance for Mean Squared Error Value';
        ext = true;
      else
        ext = false;
        msg = '';
      end

    case 'chivar'

      if isempty(lrscond)
        a = 2; % Default value
      else
        a = lrscond;
      end
      if isempty(msevar)
        b = 2; % Default value
      else
        b = msevar;
      end

      hh = length(mse);
      tlsr = -1*log10(mse(hh));
      if hh == 1
        stc = 1;
      else
        stc = diff(mse(hh-1:hh))/mse(hh-1);
      end
      if all(tlsr > a) && (abs(stc) < 10^(-1*b))
        msg = 'Reached tolerance for Mean Squared Error Value and Variation';
        ext = true;
      else
        ext = false;
        msg = '';
      end
    
    case 'lrs'
      if isempty(lrscond)
        lrscond = 2; % Default value
      end

      lsr = log10(abs(y))-log10(abs(rdl));
      if min(lsr) > lrscond
        msg = 'Reached tolerance for Log residuals';
        ext = true;
      else
        ext = false;
        msg = '';
      end

    case 'lrsmse'

      if isempty(lrscond)
        a = 2; % Default value
      else
        a = lrscond;
      end
      if isempty(msevar)
        b = 2; % Default value
      else
        b = msevar;
      end

      tlsr = log10(abs(y))-log10(abs(rdl));
      hh = length(mse);
      if hh == 1
        stc = 1;
      else
        stc = diff(mse(hh-1:hh))/mse(hh-1);
      end
      if all(tlsr > a) && (abs(stc) < 10^(-1*b))
        msg = 'Reached tolerance for Log Residuals and Mean Squared Error variation';
        ext = true;
      else
        ext = false;
        msg = '';
      end
      
    case 'rft' % Check that residuals flatness is larger than a certain value
      % Calculate residual flatness
      rf = utils.math.spflat(abs(rdl));
      
      % Checking that lrscond has the correct value
      a = lrscond;
      if (a >= 1) || (a < 0)
        a = 0.5;
      end
      if rf > a
        msg = 'Reached tolerance for residuals spectral flatness';
        ext = true;
      else
        ext = false;
        msg = '';
      end
      
    case 'rftmse'
      
      % Calculate residual flatness
      rf = utils.math.spflat(abs(rdl));
      
      % Checking that lrscond has the correct value
      a = lrscond;
      if (a >= 1) || (a < 0)
        a = 0.5;
      end
      
      if isempty(msevar)
        b = 2; % Default value
      else
        b = msevar;
      end

      hh = length(mse);
      if hh == 1
        stc = 1;
      else
        stc = diff(mse(hh-1:hh))/mse(hh-1);
      end
      if (rf > a) && (abs(stc) < 10^(-1*b))
        msg = 'Reached tolerance for residuals spectral flatness and Mean Squared Error variation';
        ext = true;
      else
        ext = false;
        msg = '';
      end
      
        

  end

