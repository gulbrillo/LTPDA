%
% Get the default plist for the MCMC algorithm.
%
function pl = buildplist(set)
  
  if ~utils.helper.ismember(lower(MCMC.SETS), lower(set))
    error('### Unknown set [%s]', set);
  end
  
  pl = plist();
  pl = MCMC.addGlobalKeys(pl);
  pl = buildplist@ltpda_uoh(pl, set);
  
  switch lower(set)
    
    case 'default'
      
      % LIKELIHOOD VERSION
      p = param({'LIKELIHOOD VERSION', 'The version of the likelihood, for the case of MFH models. For more information type: >> help mfh_model_loglikelihood. '}, paramValue.STRING_VALUE('chi2'));
      p.addAlternativeKey('LLH VERSION');
      p.addAlternativeKey('LLH VER');
      pl.append(p);
      
      % SIMPLEX
      p = param({'SIMPLEX','Set to true to perform a simplex search to find the starting parameters of the MCMC chain.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % MHSAMPLE
      p = param({'MHSAMPLE','Set to true to perform a mhsample search. This is set to true by default. Only to be set to false by the user if we does not want to perform the mcmc search.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      % FREQUENCIES
      p = param({'FREQUENCIES','Array of frequencies where the analysis is performed. NOTE: Not the maximum and minimum frequency. In this case please use the ''F1'' and ''F2'' keys.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % F1
      p = plist({'F1', 'Initial frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % F2
      p = plist({'F2', 'Maximum frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % INNAMES
      p = param({'INNAMES','The input names. Used in the SSM case.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % OUTNAMES
      p = param({'OUTNAMES','The output names. Used in the SSM case.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % PINV
      p = plist({'PINV','Use the Penrose-Moore pseudoinverse.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % TOL
      p = plist({'TOL','Tolerance for the Penrose-Moore pseudoinverse.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % JDES
      p = plist({'JDES','The desired number of spectral frequencies to compute. Used in the case of ''LPSD'' method.'}, paramValue.DOUBLE_VALUE(1000));
      pl.append(p);
      
      % REGULARIZE
      p = plist({'REGULARIZE', 'If the resulting fisher matrix is not positive definite, try a numerical trick to continue sampling.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % NARESTSPD
      p = param({'nearestSPD', 'Try to find the nearest symmetric and positive definite covariance matrix, with the ''nearestSPD'' method from MATLAB file exchange.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % YUNITS
      p = param({'YUNITS', 'The Y units of the noise time series, in case the MFH object is a ''core'' type.'}, paramValue.STRING_VALUE('m s^-2'));
      pl.append(p);
      
      % WINDOW
      pl.combine(plist.WELCH_PLIST);
      
      % ICSM
      icsm_dpl = MCMC.getInfo('MCMC.computeICSMatrix').plists;
      pl = combine(pl, icsm_dpl);
      
      % Get keys for simplex function
      smplx_dpl = MCMC.getInfo('MCMC.simplex').plists;
      pl = combine(pl, smplx_dpl);
      
      % Get keys for mhsample function
      mhsample_dpl = MCMC.getInfo('MCMC.mhsample').plists;
      pl = combine(pl, mhsample_dpl);
      
      % Combine plists for different versions of log-likelihoods
      cor_pl = mfh_model_loglikelihood('plist','chi2');
      log_pl = mfh_model_loglikelihood('plist','log');
      eta_pl = mfh_model_loglikelihood('plist','noise fit v1');
      stt_pl = mfh_model_loglikelihood('plist','student-t');
      tdc_pl = mfh_model_loglikelihood('plist','td core');
      
      pl = remove(combine(pl, cor_pl, log_pl, eta_pl, stt_pl, tdc_pl), 'version');
      
  end
  
end

% END