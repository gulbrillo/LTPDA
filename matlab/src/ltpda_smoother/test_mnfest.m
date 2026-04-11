clear;


%% Create test data
bw = 20;
ol  = 0.8;

xx = rand(1,1000).^2;
xx(500) = 10;


% Make AO
a = ao(1:length(xx),xx);
s = smoother(a)

nxx = ltpda_smoother(xx, bw, ol, 'median');
b   = ao(1:length(xx), nxx);

iplot(s,b)

iplot(s./b)