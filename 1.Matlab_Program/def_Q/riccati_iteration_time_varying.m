function [P,eta,mathfrak_R,mathfrak_S,g]=riccati_iteration_time_varying(Q,q,R,N,A,B,d)
n=size(Q,1);
m = size(R,1);
P=zeros(n,n,N);
mathfrak_R = zeros(m,m,N-1);
mathfrak_S = zeros(m,n,N-1);
g = zeros(m,N-1);
eta = zeros(n,N);

P(:,:,N) = Q(:,:,N);
eta(:,N) = q(:,N);

for t=N-1:-1:1
    mathfrak_R(:,:,t) = B'*P(:,:,t+1)*B+R;
    mathfrak_S(:,:,t) = B'*P(:,:,t+1)*A;
    g(:,t) = B'*eta(:,t+1)+B'*P(:,:,t+1)*d;
    eta(:,t) = (A-B*(mathfrak_R(:,:,t)\mathfrak_S(:,:,t)))'*(eta(:,t+1)+P(:,:,t+1)*d)+q(:,t);
    P(:,:,t) = A'*P(:,:,t+1)*A+Q(:,:,t)-mathfrak_S(:,:,t)'*(mathfrak_R(:,:,t)\mathfrak_S(:,:,t));
end

end