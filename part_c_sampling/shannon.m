function y = shannon(x,t,T)
%
%  y = shannon(x,t,T)
%
%	Reconstruct a band-limited approximation to the signal in x after
%	subsampling at intervals T (samples).
%	t is the time axis array
%

N = length(x);
if N == 0;
	error('Invalid input array');
end
y = recon(x,T);

%
%  plot original and reconstruction on same axes
%

M = length(t);
if M < 2;
	t = linspace(0,1,N);
elseif M < N;
	t = linspace(t(1),(N-1)*t(M)/(M-1),N);
end

x1 = x([1:T:N]);
t1 = t([1:T:N]);
figure(1)
plot(t,x,'r',t,y,'g',t1,x1,'ob');
