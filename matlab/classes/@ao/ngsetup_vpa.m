function [Tinit,Tprop,E] = ngsetup_vpa(den,fs, ndigits)

  % ALGONAME = mfilename;
  digits(ndigits)
  fs = sym(fs);
  den = sym(den,'d');
  den=den';
  dt = vpa(1/fs);

  n = length(den)-1;
  % digits(d);

  %% setting up matrix Aij
  m_a = vpa(zeros(n,n));
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
  a = m_a*dt;
  E = expm(a);


  %% setting up matrix Bij
  B = vpa(zeros(n,n));
  for i=1:n
    if rem(i,2) ~= 0
      j0 = (i+1)/2;
      s  = (-1)^(j0+1);
      j  = j0;
      for k=1:2:(n+1)
        d1 = den(k);
        d2 = s*d1;
        B(i,j) = d2;
        s   = -s;
        j = j+1;
      end
    end
    if rem(i,2) == 0
      j0 = i/2+1;
      s  = (-1)^j0;
      j  = j0;
      for k=2:2:(n+1)
        d1 = den(k);
        d2 = s*d1;
        B(i,j) = d2;
        s        = -s;
        j        = j+1;
      end
    end
  end

  %% solve B * m = k
  m_k = vpa(zeros(n,1));
  m_k(n) = 0.5;
  m_m = vpa(B\m_k);

  %% filling covariance matrix Cinit
  % Cinit = vpa(zeros(n,n));
  % for i=1:n
  %     for j=1:n
  %         if rem((i+j),2) == 0    % even
  %             d1 = (-1)^((i-j)/2);
  %             d1 = subs(d1)
  %             d2 = vpa('m_m((i+j)/2)');
  %             d2 = subs(d2)
  %             d3 = vpa(ctranspose(d2));
  %             d3 = subs(d3)
  %             d4 = vpa('d1 * d3');
  %             d4 = subs(d4)
  %             Cinit(i,j) = d4;
  %         else
  %             Cinit(i,j) = 0;
  %         end
  %     end
  % end

  Cinit = vpa(zeros(n,n));
  for i=1:n
    for j=1:n
      if rem((i+j),2) == 0    % even
        d1 = (-1)^((i-j)/2);
        d2 = (i+j)/2;
        Cinit(i,j) = d1 * m_m(d2);
        %         else
        %             Cinit(i,j) = 0;
      end
    end
  end
  %cholesky decomposition

  % Tinit = chol(double(Cinit),'lower'); %lower triangular matrix
  Tinit = ao.mchol(Cinit);

  %% setting up matrix D
  N = n*(n+1)/2;

  m_d = vpa(zeros(N));
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
  m_q = vpa(zeros(1,g(n,n)));
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

  Cprop = vpa(zeros(n));
  for i=1:n
    for j=1:n
      Cprop(i,j) = m_p(g(i,j));
    end
  end

  Tprop = ao.mchol(Cprop);
  Tprop = double(Tprop);
  E = double(E);
  Tinit = double(Tinit);

  % Tprop = chol(Cprop,'lower');

  % Tprop = chol(double((Cprop)),'lower');
  % Tprop = mchol(Cprop);

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

