function val = obj_func_noisy(Q,x_ref,P,eta,xi,B,X_grouped,XXT_grouped,U,N_i,Sigma_w,time_hor_weight,R,is_sim)
time_horizon_lengths = unique(N_i);
nu_2 = max(time_horizon_lengths);

obj = 0;
M_N = zeros(1, nu_2);
for t=min(time_horizon_lengths):nu_2
    M_N(t) = size(X_grouped{t}, 2);
end

% weight = 1+rand(nu_2-1,1)*10;

for N=min(time_horizon_lengths):nu_2
    if M_N(N) == 0
        continue
    end
    
    obj = obj ...
        + 0.5*trace(P(:,:,nu_2)*XXT_grouped{N}(:,:,nu_2)) ...
        + trace((kron(ones(1,M_N(N)),eta(:,nu_2)))'*X_grouped{N}(:,:,nu_2)) ...
        + (-0.5*trace(P(:,:,nu_2-N+1)*XXT_grouped{N}(:,:,nu_2-N+1)) ...
        - trace((kron(ones(1,M_N(N)),eta(:,nu_2-N+1)))'*X_grouped{N}(:,:,nu_2-N+1)));
    for t=nu_2-N+1:nu_2-1
%         obj = obj+(-0.5*trace(P(:,:,t)*XXT_grouped{N}(:,:,t)) ...
%         -trace((kron(ones(1,M_N(N)),eta(:,t)))'*X_grouped{N}(:,:,t)) ...
%         +0.5 * trace(P(:,:,t+1)*XXT_grouped{N}(:,:,t+1))...
%         +trace((kron(ones(1,M_N(N)),eta(:,t+1)))'*X_grouped{N}(:,:,t+1)))*weight(t);
        
        X_grouped_sum = sum(X_grouped{N}(:,:,t),2);
        obj = obj + (0.5*trace(Q*XXT_grouped{N}(:,:,t))-trace(Q*X_grouped_sum*x_ref(:,t)'));%*weight(t);
    end
end

for t=1:nu_2-1
    obj = obj + (0.5*xi(t)-0.5*trace(B'*P(:,:,t+1)*B*Sigma_w))*time_hor_weight(t);%*weight(t);
    if is_sim
        obj = obj + 0.5*trace(R*U(:,:,t)*U(:,:,t)');%*weight(t);
    end
end

val = obj/sum(M_N);

end