function [P,mathfrak_R,mathfrak_S]=riccati_iteration_P_time_varying(Q,R,N,A,B)
n=size(Q,1);
m = size(R,1);
P=zeros(n,n,N);
mathfrak_R = zeros(m,m,N-1);
mathfrak_S = zeros(m,n,N-1);

P(:,:,N) = Q(:,:,N);

for t=N-1:-1:1
    mathfrak_R(:,:,t) = B'*P(:,:,t+1)*B+R;
    mathfrak_S(:,:,t) = B'*P(:,:,t+1)*A;
    P(:,:,t) = A'*P(:,:,t+1)*A+Q(:,:,t)-mathfrak_S(:,:,t)'*(mathfrak_R(:,:,t)\mathfrak_S(:,:,t));
end

end