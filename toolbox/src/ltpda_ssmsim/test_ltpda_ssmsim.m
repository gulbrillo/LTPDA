clear all;
compile

Nsamples   = 10;
Nstates    = 10;
Nstatesout = 1;
Ninputs    = 2;
Noutputs   = 2;


Nruns = 100;


%%
[yx,xx,lxx,y,x,lx] = validate_mex(Nsamples, Nstates, Nstatesout, Ninputs, Noutputs);

sum(sum(yx-y))
% sum(sum(xx-x))
sum(sum(lxx-lx))

return

%%

[tmex,yx,xx] = do_a_run(Nruns, Nsamples, Nstates, Nstatesout, Ninputs, Noutputs);
[tmat,y,x] = do_a_run_mat(Nruns, Nsamples, Nstates, Nstatesout, Ninputs, Noutputs);

tmex
tmat
tmat/tmex


return

%% Run-time Vs Nstates

Nsamples   = 1000;
Nstatesout = 1;
Ninputs    = 2;
Noutputs   = 10;
Nruns      = 10;
Nstates = 5:20:250;
tmex = zeros(length(Nstates),1);
tmat = zeros(length(Nstates),1);
for jj=1:length(Nstates)
  
  disp('-----------------')
  Ns = Nstates(jj) 
  [tmex(jj),y,x] = do_a_run(Nruns, Nsamples, Ns, Nstatesout, Ninputs, Noutputs);
  [tmat(jj),y,x] = do_a_run_mat(Nruns, Nsamples, Ns, Nstatesout, Ninputs, Noutputs);
  tmex(jj)
  tmat(jj)
  drawnow
end

%%
figure
plot(Nstates, tmex, 'r-', Nstates, tmat, 'b-');
legend('mex', 'matlab');
ylabel('Run-time [s]');
xlabel('Nstates')
s = sprintf('Nsamples=%d, Ninputs=%d, Noutputs=%d', Nsamples, Ninputs, Noutputs);
title(s)


%% Run-time Vs Inputs

Nsamples   = 10000;
Nstatesout = 1;
Ninputs    = 1:2:100;
Noutputs   = 10;
Nruns      = 10;
Nstates    = 10;
tmex = zeros(length(Ninputs),1);
tmat = zeros(length(Ninputs),1);
for jj=1:length(Ninputs)
  
  disp('-----------------')
  Ni = Ninputs(jj) 
  [tmex(jj),y,x] = do_a_run(Nruns, Nsamples, Nstates, Nstatesout, Ni, Noutputs);
  [tmat(jj),y,x] = do_a_run_mat(Nruns, Nsamples, Nstates, Nstatesout, Ni, Noutputs);
  tmex(jj)
  tmat(jj)
  drawnow
end

%%
figure
plot(Ninputs, tmex, 'r-', Ninputs, tmat, 'b-');
legend('mex', 'matlab');
ylabel('Run-time [s]');
xlabel('Ninputs')
s = sprintf('Nsamples=%d, Nstates=%d, Noutputs=%d', Nsamples, Nstates, Noutputs);
title(s)


%% Run-time Vs Outputs

Nsamples   = 1000;
Nstatesout = 1;
Ninputs    = 2;
Noutputs   = 1:2:100;
Nruns      = 10;
Nstates    = 10;
tmex = zeros(length(Noutputs),1);
tmat = zeros(length(Noutputs),1);
for jj=1:length(Noutputs)
  
  disp('-----------------')
  No = Noutputs(jj) 
  [tmex(jj),y,x] = do_a_run(Nruns, Nsamples, Nstates, Nstatesout, Ninputs, No);
  [tmat(jj),y,x] = do_a_run_mat(Nruns, Nsamples, Nstates, Nstatesout, Ninputs, No);
  tmex(jj)
  tmat(jj)
  drawnow
end

%%
figure
plot(Noutputs, tmex, 'r-', Noutputs, tmat, 'b-');
legend('mex', 'matlab');
ylabel('Run-time [s]');
xlabel('Noutputs')
s = sprintf('Nsamples=%d, Nstates=%d, Ninputs=%d', Nsamples, Nstates, Ninputs);
title(s)
