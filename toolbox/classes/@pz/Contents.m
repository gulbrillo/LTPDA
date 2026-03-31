%%%%%%%%%%%%%%%%%%%%   class: pz   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help pz/attachToDom">pz/attachToDom</a>         - % Create empty pz node with the attribute 'shape'
%   <a href="matlab:help pz/char">pz/char</a>                -  convert a pz object into a string.
%   <a href="matlab:help pz/copy">pz/copy</a>                -  makes a (deep) copy of the input pz objects.
%   <a href="matlab:help pz/cp2iir">pz/cp2iir</a>              -  Return a,b IIR filter coefficients for a complex pole designed using the bilinear transform.
%   <a href="matlab:help pz/cz2iir">pz/cz2iir</a>              -  return a,b IIR filter coefficients for a complex zero designed using the bilinear transform.
%   <a href="matlab:help pz/disp">pz/disp</a>                -  display a pz object.
%   <a href="matlab:help pz/fq2ri">pz/fq2ri</a>               -  Convert frequency/Q pole/zero representation
%   <a href="matlab:help pz/fromDom">pz/fromDom</a>             - % Get shape
%   <a href="matlab:help pz/fromStruct">pz/fromStruct</a>          -  creates from a structure a PZ object.
%   <a href="matlab:help pz/loadobj">pz/loadobj</a>             -  is called by the load function for user objects.
%   <a href="matlab:help pz/pz">pz/pz</a>                  -  is the ltpda class that provides a common definition of poles and zeros.
%   <a href="matlab:help pz/resp">pz/resp</a>                -  returns the complex response of the pz object.
%   <a href="matlab:help pz/resp_add_delay_core">pz/resp_add_delay_core</a> -  Simple core method to add a pure delay in frequency domain
%   <a href="matlab:help pz/resp_pz_Q_core">pz/resp_pz_Q_core</a>      -  Simple core method to compute the response of a pz model (with Q>=0.5)
%   <a href="matlab:help pz/resp_pz_noQ_core">pz/resp_pz_noQ_core</a>    - resp_pz_Q_core Simple core method to compute the response of a pz model (with Q<0.5)
%   <a href="matlab:help pz/ri2fq">pz/ri2fq</a>               -  Convert comlpex pole/zero into frequency/Q pole/zero representation.
%   <a href="matlab:help pz/rp2iir">pz/rp2iir</a>              -  Return a,b coefficients for a real pole designed using the bilinear transform.
%   <a href="matlab:help pz/rz2iir">pz/rz2iir</a>              -  Return a,b IIR filter coefficients for a real zero designed using the bilinear transform.
%   <a href="matlab:help pz/setF">pz/setF</a>                -  Set the property 'f'
%   <a href="matlab:help pz/setQ">pz/setQ</a>                -  Set the property 'q'
%   <a href="matlab:help pz/setRI">pz/setRI</a>               -  Set the property 'ri' and computes 'f' and 'q'
%   <a href="matlab:help pz/string">pz/string</a>              -  writes a command string that can be used to recreate the input pz object.
%   <a href="matlab:help pz/update_struct">pz/update_struct</a>       -  update the input structure to the current ltpda version
