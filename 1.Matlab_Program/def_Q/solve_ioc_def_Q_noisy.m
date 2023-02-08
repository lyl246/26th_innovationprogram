function [status, estimated_Q, errors] = ...
    solve_ioc_def_Q_noisy(x,u,A,B,varphi,Sigma_w,N_i,Q_true,R,x_ref,is_sim)
[n,m] = size(B);
nu_2 = size(x,2);
M = size(x,3);

P_est = sdpvar(n,n,nu_2);
Q_est = sdpvar(n,n);
% Q_est = diag(sdpvar(n,1));
eta_est = sdpvar(n,nu_2);
xi = sdpvar(1,nu_2-1);

[X,U,XXT,X_grouped,XXT_grouped,time_hor_weight] = ...
    data_struct_process(x,u,N_i,is_sim);

obj = obj_func_noisy(Q_est,x_ref,P_est,eta_est,xi,B,X_grouped,XXT_grouped,U,N_i,Sigma_w,time_hor_weight,R,is_sim);

% calculate the riccati iterations for the time horizon upper bound, we
% just choose where to start.
if is_sim
    Q_t_true = zeros(n,n,nu_2);
    for t=1:nu_2
        Q_t_true(:,:,t) = Q_true;
    end
    [P_true,mathfrak_R,mathfrak_S]=riccati_iteration_P_time_varying(Q_t_true,R,nu_2,A,B);
    [eta_true,g_true]=riccati_iteration_eta_time_varying(-Q_true*x_ref,nu_2,A,B,zeros(n,1),mathfrak_R,mathfrak_S,P_true);
    xi_true = zeros(nu_2-1,1);
    for t=1:nu_2-1
        xi_true(t) = g_true(:,t)'*((B'*P_true(:,:,t+1)*B+eye(m))\g_true(:,t));
    end
    obj_true = obj_func_noisy(Q_true,x_ref,P_true,eta_true,xi_true,B,X_grouped,XXT_grouped,U,N_i,Sigma_w,time_hor_weight,R,is_sim);
    
    q_true = -Q_true*x_ref;
end
q_est = -Q_est*x_ref;
constraints = [Q_est>=0,P_est(:,:,nu_2) == Q_est,eta_est(:,nu_2)==q_est(:,nu_2), ...
    norm(Q_est,'fro')<=sqrt(varphi)];

for k=1:nu_2-1
    constr = LMI_constr(P_est(:,:,k+1),P_est(:,:,k),eta_est(:,k+1),eta_est(:,k),Q_est,q_est(:,k),R,xi(k),A,B);
    constraints = [constraints, constr>=0,P_est(:,:,k)>=0];
end

ops = sdpsettings('solver', 'mosek', 'verbose', 1);

sol = optimize(constraints,obj,ops);
estimated_Q = value(Q_est);
if strcmp(sol.info,'Successfully solved (MOSEK)')
    status = 1;
else
    status = 0;
end

eta = value(eta_est);
P = value(P_est);
estimated_q = value(q_est);
opt_val = value(obj);
errors=[];

if is_sim
    % check the true Q and q, if they are truly optimal.
    for t=1:nu_2-1
        err_riccati(t) = norm(A'*P(:,:,t+1)*A + estimated_Q -A'*P(:,:,t+1)*B*((B'*P(:,:,t+1)*B+R)\(B'*P(:,:,t+1)*A))-P(:,:,t),'fro');
        err_eta(t) = norm((A-B*((B'*P(:,:,t+1)*B+R)\(B'*P(:,:,t+1)*A)))'*eta(:,t+1) + estimated_q(:,t) -eta(:,t),'fro');
        err_K(t) = norm((B'*P(:,:,t+1)*B)\(B'*P(:,:,t+1)*A)-(B'*P_true(:,:,t+1)*B)\(B'*P_true(:,:,t+1)*A),'fro');
        
        for i=1:M
            if t>=nu_2-N_i(i)+1
                U_est(:,i,t) = -(B'*P(:,:,t+1)*B+R)\( B'*P(:,:,t+1)*A*x(:,t,i) +B'*eta(:,t+1));
            else
                U_est(:,i,t) = zeros(m,1);
            end
        end
        rel_err_U(t) = norm(U(:,:,t)-U_est(:,:,t),'fro')/norm(U(:,:,t),'fro');
        err_U(t) = norm(U(:,:,t)-U_est(:,:,t),'fro');
        
        constr_true = LMI_constr(P_true(:,:,t+1),P_true(:,:,t),eta_true(:,t+1),eta_true(:,t),Q_true,q_true(:,t),R,xi_true(t),A,B);
        min_eig_constr_true(t) = min(eig(constr_true));
        
        estimated_xi = value(xi);
        constr_est = LMI_constr(P(:,:,t+1),P(:,:,t),eta(:,t+1),eta(:,t),estimated_Q,estimated_q(:,t),R,estimated_xi(t),A,B);
        min_eig_constr_est(t) = min(eig(constr_est));
    end
    
    for t=1:nu_2
        err_B_eta(t) = norm(B'*(eta(:,t)-eta_true(:,t)));
    end
    
    errors.riccati = err_riccati;
    errors.eta = err_eta;
    errors.opt_val = opt_val;
    
    errors.obj_true = obj_true;
    errors.err_B_eta = err_B_eta;
    errors.err_K = err_K;
    errors.err_P = P_true - P;
    errors.rel_err_U = rel_err_U;
    errors.err_U = err_U;
end
end