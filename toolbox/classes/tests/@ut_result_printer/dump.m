% DUMP prints out tests results to the terminal.
%

function dump(printer)
  
  disp(printer.printSummaryString());
  disp(printer.printRuntimeString(10));
  disp(printer.printFailuresString());
 
end