% GETDSFROMYFS grows an evenly spaced frequency vector of N points for samplerate fs.

function f = getFfromYFs(N,fs)
  f = linspace(0, fs/2, N);
end
