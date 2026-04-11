% TEST_AO_WAVEFORM test the waveform constructor for AO class.
%
% M Hewitson 17-05-07
%
% $Id$
%
function test_ao_waveform()
  
  
  % Create parameter list
  pl = plist('fs', 100, 'nsecs', 5);
  
  % sinewave
  spl = append(pl, 'waveform', 'sine wave');
  spl.append('f', 1.23);
  spl.append('phi', 30);
  
  asine = ao(spl);
  
  % noise
  spl = append(pl, 'waveform', 'noise');
  spl.append('type', 'Normal');
  
  anoise = ao(spl);
  
  % chirp
  
  spl = append(pl, 'waveform', 'chirp');
  spl.append('f0', 1);
  spl.append('f1', 50);
  spl.append('t1', 100);
  
  achirp = ao(spl)
  
  % Gaussian pulse
  
  spl = append(pl, 'waveform', 'Gaussian pulse');
  spl.append('f0', 10);
  spl.append('bw', 100);
  
  agp = ao(spl)
  
  % Square wave
  
  spl = append(pl, 'waveform', 'Square wave');
  spl.append('f', 1);
  spl.append('duty', 50);
  
  asquare = ao(spl)
  
  % Sawtooth
  
  spl = append(pl, 'waveform', 'Sawtooth');
  spl.append('f', 1);
  spl.append('width', 0.5);
  
  asaw = ao(spl)
  
  % Plots
  iplot([asine anoise achirp agp asquare asaw])
  
  close all
end
% END