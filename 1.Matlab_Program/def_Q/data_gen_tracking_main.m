clear;
clc;

rng(1)

data_gen_settings.n=2;
data_gen_settings.m=1;
data_gen_settings.p = 2;
data_gen_settings.dt=0.05; %50ms
data_gen_settings.N = 120;
data_gen_settings.varphi = 50; %5;
% data_gen_settings.Sigma_w = 5.3779e-4; %5.3779e-8;
data_gen_settings.Sigma_w = 6.8062e-5;
data_gen_settings.expected_time_horizon_len = floor(5/6*data_gen_settings.N);
% the amplification const between the equipment and coordinate of the dot on the screen
data_gen_settings.amplify_const = 1;
% the oscillation period of the dot on the screen
data_gen_settings.oscillation_period = 4;

R = 1*eye(data_gen_settings.m);

A_tmp = [0 1;
         0 0];
A_tmp =expm(A_tmp*data_gen_settings.dt);
mass = 0.2; %mass attached to the rod
ell = 0.255; %length of the rod
momentum_of_inertia = mass*ell^2;
B_tmp = [0;1/momentum_of_inertia];
B_tmp = integral(@(t) expm(A_tmp.*t),0,data_gen_settings.dt, ...
    'ArrayValued', true)*B_tmp;
A = A_tmp;
B = B_tmp;

% Q_half = randn(data_gen_settings.n);
% Q = Q_half*Q_half';
Q=diag([0.01,0.01]);
% Q = randn(1,2).^2;
% Q = diag(Q);
% target(1,1) = 1.59;
% target(2,1) = 0;
% q = -Q*target;
M = 5000;
[x,u,N_i,x_ref] = ...
        generate_tracking_data(data_gen_settings,A,B,Q,R,M,true,true);

save('training_data_tracking.mat','x','x_ref','N_i','data_gen_settings','A','B','Q','R','u')