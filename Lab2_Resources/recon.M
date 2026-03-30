function y = recon(x,n)
%
%  y = recon(x,n)
%
%  Sample and reconstruct a pariodic array - array must have even length
%  and be strictly periodic for this command to work properly  	
%
dim = length(x);
x1 = zeros(1,dim);
k = [1:n:dim];
x1(k) = x(k);
x1 = [x1 zeros(1,dim)];
theta = pi/n;
%d2 = floor(dim/2);
y1 = [1:dim-1]*theta;
y1 = sin(y1)./y1;
q1 = y1(dim-1:-1:1);
y1 = [1 y1 0 q1];
z1 = fft(x1).*fft(y1);
z = ifft(z1);
y = real(z([1:dim]));
