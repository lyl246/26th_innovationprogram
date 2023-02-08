function [X,U,XXT,X_grouped,XXT_grouped,time_hor_weight] = ...
    data_struct_process(x,u,N_i,is_sim)
[n,nu_2,M]=size(x);
m=size(u,1);

U=[];
if is_sim
    U=zeros(m,M,nu_2-1);
    for k=1:nu_2-1
        U(:,:,k) = reshape(u(:,k,:),m,[]);
    end
end

X=zeros(n,M,nu_2);
for k = 1:nu_2
    X(:,:,k) = reshape(x(:,k,:),n,[]);
end

XXT = zeros(n,n,nu_2);
for k=1:nu_2
    XXT(:,:,k) = X(:,:,k)*X(:,:,k)';
end

X_grouped = {};
time_horizon_lengths = unique(N_i);
for N = time_horizon_lengths
    indices = find(N_i == N);
    for k=1:nu_2
        X_grouped{N}(:,:,k) = reshape(x(:,k,indices),n,[]);
    end
end

XXT_grouped = {};
for N = time_horizon_lengths
    for k=1:nu_2
        XXT_grouped{N}(:,:,k) = X_grouped{N}(:,:,k)*(X_grouped{N}(:,:,k))';
    end
end

time_hor_mat = zeros(M,nu_2);
for i=1:M
    time_hor_mat(i,nu_2-N_i(i)+1:end) = 1;
end
time_hor_weight = sum(time_hor_mat,1);

end