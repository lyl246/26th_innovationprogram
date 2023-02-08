function [eta,g]=riccati_iteration_eta_time_varying(q,N,A,B,d,mathfrak_R,mathfrak_S,P)
[n,m]=size(B);
g = zeros(m,N-1);
eta = zeros(n,N);
eta(:,N) = q(:,N);

for t=N-1:-1:1
    g(:,t) = B'*eta(:,t+1)+B'*P(:,:,t+1)*d;
    eta(:,t) = (A-B*(mathfrak_R(:,:,t)\mathfrak_S(:,:,t)))'*(eta(:,t+1)+P(:,:,t+1)*d)+q(:,t);
end

end