function frmt = matfrmt2javafrmt(frmt)
% convert MATLAB time formatting specification string into a Java one

  % translate numeric MATLAB time formats into string ones
  if isnumeric(frmt)
    frmt = time.getdateform(frmt);
  end
  
  for kk = 1:length(frmt)
    switch frmt(kk)
      case 'm'
        frmt(kk) = 'M';
      case 'M'
        frmt(kk) = 'm';
      case 'S'
        frmt(kk) = 's';
      case 'F'
        frmt(kk) = 'S';
      case 'P'
        if frmt(kk+1) == 'M'
          frmt(kk)   = 'a';
          frmt(kk+1) = 'a';
        end
    end
  end

  % properly quote the T into ISO8896 date formats
  frmt = strrep(frmt, 'T', '''T''');
end
