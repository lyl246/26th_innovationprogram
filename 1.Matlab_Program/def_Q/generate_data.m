function [x,u] = generate_data(data_gen_settings,A,B,Q,q,R,M)
n = data_gen_settings.n;
m = data_gen_settings.m;
N = data_gen_settings.N;
addpath("../../utils")

[P,eta,mathfrak_R,mathfrak_S,g]=riccati_iteration(Q, q, ...
                R,N, A, B, zeros(n,1));

x(:,1,:) = -50+(50+50)*rand(n,M);

for t=2:N
    u(:,t-1,:) = -mathfrak_R(:,:,t-1)\(mathfrak_S(:,:,t-1)* ...
        reshape(x(:,t-1,:),n,[])+kron(ones(1,M),g(:,t-1)));
    x(:,t,:) = A*reshape(x(:,t-1,:),n,[]) + B*reshape(u(:,t-1,:),m,[]);
end

end