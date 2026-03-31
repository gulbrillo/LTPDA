% Compile all necessary mex files.
% 

path_mem = cd;

path_src = which('CompileAll');
path_src = fileparts(path_src);
cmd = sprintf('cd %s', path_src);
eval(cmd);

% LTPDA_DFT
cd ltpda_dft
compile()
cd ..

% LTPDA_POLYREG
cd ltpda_polyreg
compile()
cd ..

% LTPDA_SMOOTHER
cd ltpda_smoother
compile()
cd ..

% LTPDA_SSMSIM
cd ltpda_ssmsim
compile()
cd ..

% Back to starting directory
cmd = sprintf('cd %s', path_mem);
eval(cmd);

% END
