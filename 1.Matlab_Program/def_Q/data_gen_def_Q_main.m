clear;
clc;

rng(1)

data_gen_settings.n=3;
data_gen_settings.m=1;
data_gen_settings.dt=0.01;
data_gen_settings.N = 120;
data_gen_settings.varphi = 5;
data_gen_settings.nof_sys = 200; % We randomly generate 200 systems.
R = eye(data_gen_settings.m);

for sys_id = 1:data_gen_settings.nof_sys
    while true
        A_tmp = randn(data_gen_settings.n);
        B_tmp = randn(data_gen_settings.n,data_gen_settings.m);
        B_tmp = integral(@(t) expm(A_tmp.*t),0,data_gen_settings.dt, ...
            'ArrayValued', true)*B_tmp;
        A_tmp = expm(A_tmp*data_gen_settings.dt);
        
        eig_A_radius = abs(eig(A_tmp));
        eig_A_radius = sort(eig_A_radius,'ascend');
        
        ctrl_mat = B_tmp;
        for iter_index = 1:data_gen_settings.n-1
            ctrl_mat = [ctrl_mat, A_tmp*ctrl_mat(:, end)];
        end
        
        if eig_A_radius(1)>0.4 %&& cond(ctrl_mat)<=200 
            break;
        end
    end
%     A_tmp = [0 1 0 0;
%              0 0 0 0;
%              0 0 0 1;
%              0 0 0 0];
%     A_tmp =expm(A_tmp*data_gen_settings.dt);
%     B_tmp = [0 0;1 0;0 0;0 1];
    B_tmp = integral(@(t) expm(A_tmp.*t),0,data_gen_settings.dt, ...
            'ArrayValued', true)*B_tmp;
    A{sys_id} = A_tmp;
    B{sys_id} = B_tmp;
    while true
        Q_half = randn(data_gen_settings.n);
        Q_tmp = Q_half*Q_half';
        q_tmp = randn(data_gen_settings.n,1);
        Q_tilde = [Q_tmp,q_tmp;q_tmp' 0];
        if norm(Q_tilde,'fro')^2<=data_gen_settings.varphi 
            Q{sys_id} = Q_tmp;
            q{sys_id} = q_tmp;
            break
        end
    end
    
    M = 5;
    [x{sys_id},u{sys_id}] = ...
        generate_data(data_gen_settings,A{sys_id},B{sys_id},Q{sys_id},q{sys_id},R,M);
end

save('training_data_def_Q_noiseless.mat','x','data_gen_settings','A','B','Q','q','R','u')