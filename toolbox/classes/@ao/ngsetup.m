% NGSETUP is called by the function fromPzmodel
%
% Inputs calculated by ...
%  ... NGCONV:
%            - den:   denominator coefficients
%
%  ... USER
%            - fs:    sampling frequency given as input to LTPDA_NOISEGEN
%
%      Outputs:
%            - Tinit: matrix to calculate initial state vector
%            - Tprop: matrix to calculate propagation vector
%            - E:     matrix to calculate propagation vector
%

function [Tinit,Tprop,E] = ngsetup(den,fs)

  den=den';
  dt = 1/fs;
  length(den);

  n = length(den)-1;

  %% setting up matrix Aij

  m_a = zeros(n,n);
  for i = 1:n
    for j = 1:n
      if j == i+1
        m_a(i,j) = 1;
      end
      if i == n
        m_a(i,j) = -den(j);
      end
    end
  end

  %% Matrix exponential E
  E = expm(m_a*dt);

  %% setting up matrix Bij
  B = zeros(n,n);
  for i=1:n
    if rem(i,2) ~= 0
      j0 = (i+1)/2;
      s  = (-1)^(j0+1);
      j  = j0;
      for k=1:2:(n+1)
        B(i,j) = s*den(k);
        s   = -s;
        j = j+1;
      end
    end
    if rem(i,2) == 0
      j0 = i/2+1;
      s  = (-1)^j0;
      j  = j0;
      for k=2:2:(n+1)
        B(i,j) = s * den(k);
        s        = -s;
        j        = j+1;
      end
    end
  end

  %% solve B * m = k
  m_k = zeros(n,1);
  m_k(n) = 0.5;
  m_m = B\m_k;

  %% filling covariance matrix Cinit
  Cinit = zeros(n,n);
  for i=1:n
    for j=1:n
      if rem((i+j),2) == 0    % even
        Cinit(i,j) = (-1)^((i-j)/2) * m_m((i+j)/2);
      else
        Cinit(i,j) = 0;
      end
    end
  end


  %cholesky decomposition

  Tinit = chol(Cinit,'lower'); %lower triangular matrix

  %% setting up matrix D
  N = n*(n+1)/2;

  m_d = zeros(N);
  g = zeros(n);
  for i=1:n
    for j=1:n
      if i>=j
        g(i,j) = (i*i-i)/2+(j);
      else
        g(i,j) = (j*j-j)/2+(i);
      end
    end
  end

  for i=1:n
    for j=i:n
      for k=1:n
        m_d(g(i,j),g(j,k)) = m_d(g(i,j),g(j,k)) + m_a(i,k);
        m_d(g(i,j),g(i,k)) = m_d(g(i,j),g(i,k)) + m_a(j,k);
      end
    end
  end


  %% setting up q from D * p = q
  m_q = zeros(1,g(n,n));
  for i=1:n
    for j=i:n
      if i==n
        m_q(g(i,j)) = (E(n,n))*(E(n,n))-1;
      else
        m_q(g(i,j)) = (E(i,n)*E(j,n));
      end
    end
  end

  m_p = m_d\m_q';

  Cprop = zeros(n);
  for i=1:n
    for j=1:n
      Cprop(i,j) = m_p(g(i,j));
    end
  end
  Tprop = chol(Cprop,'lower');

  % %% writing the generator
  % r = randn(n,1);
  % y = Tinit * r;
  % x = zeros(Nfft,1);
  % for i=1:Nfft
  %     r = randn(n,1);
  %     y = E * y + Tprop * r;
  %     x(i) = a*y;
  % end

end

