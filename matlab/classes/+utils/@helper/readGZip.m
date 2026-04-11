% Reads a GZip file in full and puts the contents into the output variable.
%
% Usage:
%   contents = readGZip(filename)
%
% Inputs:
%   filename - the GZip file
%
% Outputs:
%   contents - the file contents in string format.
%
% 2017 M.Armano
%
function contents = readGZip(filename)
  
  streampointer = java.io.FileInputStream(java.io.File(filename));
  gzStream = java.util.zip.GZIPInputStream(streampointer);
  
  buffer = java.io.ByteArrayOutputStream();
  org.apache.commons.io.IOUtils.copy(gzStream, buffer);
  contents = char(buffer.toString());
  
  gzStream.close();
  
end
