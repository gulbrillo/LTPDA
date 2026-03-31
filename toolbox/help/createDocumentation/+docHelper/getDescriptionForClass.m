
function desc = getDescriptionForClass(cl)
  
  switch cl
    case 'MCMC'
      desc = 'A class that implements the Markov Chain Monte Carlo algorithm. MCMC sampling with the Metropolis-Hastings algorithm. This method has the capability to automativally pre-process the time-series data to analyse (FFT of signals, PSD of the noise).';
    case 'ao'
      desc = 'A class of object that implements Analysis Objects. Such objects can store various types of numeric data: time-series, frequency-series , x-y data series, x-y-z data series, and arrays of numbers.';
    case 'collection'
      desc = 'A class of object that allows storing other User Objects in a cell-array. This is purely a convenience class, aimed at simplifying keeping a collection of different classes of user objects together. This is useful, for example, for submitting or retrieving a collection of user objects from/to an LTPDA Repository.';
    case 'filterbank'
      desc = 'A class of object that represents a bank of digital filters. The filter bank can be of type ''parallel'' or ''serial''.';
    case 'matrix'
      desc = 'A class of object that allows storing other User Objects in a matrix-like array. There are various methods which act on the object array as if it were a matrix of the underlying data. For example, you can form a matrix of Analysis Objects, then compute the determinant of this matrix, which will yield another matrix object containing a single AO.';
    case 'mfh'
      desc = 'MFH function handle class constructor.';
    case 'mfir'
      desc = 'A class of object that implements Finite Impulse Response (FIR) digital filters.';
    case 'miir'
      desc = ' class of object that implements Infinite Impulse Response (IIR) digital filters.';
    case 'parfrac'
      desc = 'A class of object that represents transfer functions given as a series of partial fractions.';
    case 'pest'
      desc = 'A class of objects that represents parameter estimation which aims to capture details of the various fitting procedures in LTPDA.';
    case 'plist'
      desc = 'A class of object that allows storing a set of key/value pairs. This is the equivalent to a ''dictionary'' in other languages, like python or Objective-C. Since a history step must contain a plist object, this class cannot itself track history, since it would be recursive.';
    case 'pzmodel'
      desc = 'A class of object that represents transfer functions given in a pole/zero format.';
    case 'rational'
      desc = 'A class of object that represents transfer functions given in rational form.';
    case 'smodel'
      desc = 'A class of object that represents a parametric model of a chosen x variable. Such objects can be combined, manipulated symbolically, and then evaluated numerically.';
    case 'ssm'
      desc = 'A class of object that represents a statespace model.';
    case 'timespan'
      desc = 'A class of object that represents a span of time. A timespan object has a start time and an end time.';
    otherwise
      desc = sprintf('### Please define a description for the [%s] class in docHelper.getDescriptionForClass.m', cl);
  end
    
end
