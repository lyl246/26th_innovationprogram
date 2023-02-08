function [status, estimated_Q, estimated_q, errors, opt_val] = ...
    solve_ioc_def_Q_noiseless(x,u,A,B,varphi,Q_true,q_true)
[n,m] = size(B);
N = size(x,2);
M = size(x,3);
for k = 1:N
    X(:,:,k) = reshape(x(:,k,:),n,[]);
end
for k=1:N-1
    U(:,:,k) = reshape(u(:,k,:),m,[]);
end
for k=1:N
    XXT(:,:,k) = X(:,:,k)*X(:,:,k)';
end

P_est = sdpvar(n,n,N);
Q_est = sdpvar(n,n);
q_est = sdpvar(n,1);
eta_est = sdpvar(n,N);
xi = sdpvar(1,N-1);

obj = obj_func(Q_est,q_est,P_est,eta_est,xi,M,A,B,N,XXT,X,U); 
% the control here is just a constant and would not affect the
% optimization, it is just used for a check.

constraints = [Q_est>=0,P_est(:,:,N) == Q_est,eta_est(:,N)==q_est, ...
    norm([Q_est q_est;q_est' 0],'fro')<=sqrt(varphi)];

for k=1:N-1
    constr = LMI_constr(P_est(:,:,k+1),P_est(:,:,k),eta_est(:,k+1),eta_est(:,k),Q_est,q_est,1,xi(k),A,B);
    constraints = [constraints, constr>=0,P_est(:,:,k)>=0];
end

ops = sdpsettings('solver', 'mosek', 'verbose', 0);

sol = optimize(constraints,obj,ops);
estimated_Q = value(Q_est);
estimated_q = value(q_est);
if strcmp(sol.info,'Successfully solved (MOSEK)')
    status = 1;
else
    status = 0;
end

eta = value(eta_est);
P = value(P_est);
opt_val = value(obj);

% check the true Q and q, if they are truly optimal.
addpath("../../utils")

[P_true,eta_true,mathfrak_R,mathfrak_S,g_true]=riccati_iteration(Q_true, q_true, ...
                eye(m),N, A, B, zeros(n,1));
for t=1:N-1
    err_riccati(t) = norm(A'*P(:,:,t+1)*A+estimated_Q-A'*P(:,:,t+1)*B*((B'*P(:,:,t+1)*B+eye(m))\(B'*P(:,:,t+1)*A))-P(:,:,t),'fro');
    err_eta(t) = norm((A-B*((B'*P(:,:,t+1)*B+eye(m))\(B'*P(:,:,t+1)*A)))'*eta(:,t+1)+estimated_q-eta(:,t),'fro');
    U_est(:,:,t) = -(B'*P(:,:,t+1)*B+eye(m))\( B'*P(:,:,t+1)*A*X(:,:,t) +B'*eta(:,t+1));
    err_U(t) = norm(U(:,:,t)-U_est(:,:,t),'fro')/norm(U(:,:,t),'fro');
    
    xi_true(t) = g_true(:,t)'*((B'*P_true(:,:,t+1)*B+eye(m))\g_true(:,t));
    constr_true = LMI_constr(P_true(:,:,t+1),P_true(:,:,t),eta_true(:,t+1),eta_true(:,t),Q_true,q_true,1,xi_true(t),A,B);
    min_eig_constr_true(t) = min(eig(constr_true));
end
obj_true = obj_func(Q_true,q_true,P_true,eta_true,xi_true,M,A,B,N,XXT,X,U);

errors.riccati = err_riccati;
errors.eta = err_eta;
errors.u = err_U;
errors.opt_val = opt_val;
end