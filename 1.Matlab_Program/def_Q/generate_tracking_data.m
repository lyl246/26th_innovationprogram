function [x,u,N_i,x_ref] = generate_tracking_data(data_gen_settings,A,B,Q,R,...
    M,is_rand_time_horizon,is_process_noise)
n = data_gen_settings.n;
m = data_gen_settings.m;
N = data_gen_settings.N;
dt = data_gen_settings.dt;
Sigma_w = data_gen_settings.Sigma_w;
E_N = data_gen_settings.expected_time_horizon_len;
alpha =data_gen_settings.amplify_const;
oscillation_period = data_gen_settings.oscillation_period;

% generate the reference signal
x_ref = zeros(n,N);
%     phase_shift = randi([-30,30]);
%     for t=1:N
%         x_ref(1,t) = alpha*sin(2*pi*dt/oscillation_period*(t+phase_shift));
%         x_ref(2,t) = alpha*cos(2*pi*dt/oscillation_period*(t+phase_shift));
%     end
% x_ref(1,1) = rand(1)*pi/2;
% x_ref(2,1) = -pi/6+rand(1)*pi/3;
% x_ref(2,1) = -0.25;
% x_ref(2,1) = -2*(B(2)*0.01/((2*pi*dt)/oscillation_period))/2; % This should give a perfect sinusiod in x(2, :)
x_ref(1,1) = 0;
x_ref(2,1) = -0.5; % This seems to give a perfect sinusiod in x(1, :)

for t=2:N
    x_ref(:,t) = A*x_ref(:,t-1)+B*0.01*sin(2*pi*dt/oscillation_period*t);
%     x_ref(:,t) = A*x_ref(:,t-1);
%     x_ref(:,t) = A*x_ref(:,t-1)+B*0.01*randn(1);
end

addpath("../../utils")

% there is only terminal penalty, and we only have minimum energy control
% on the way.
Q_t = zeros(n,n,N);
for t = 1:N
    Q_t(:,:,t) = Q;
end

% calculate the P matrix riccati iterations for the time horizon upper 
% bound, we just choose where to start.
[P,mathfrak_R,mathfrak_S]=riccati_iteration_P_time_varying(Q_t,R,N,A,B);

% set the time horizon length for each trajectories.
if ~is_rand_time_horizon
    N_i = ones(1,M)*N;
else
%     N_i = min(N,floor(E_N+randn(1,M)*20));
    lb = max(0,floor(2*E_N-N));
    N_i = randi([lb,N], 1,M);
end

% x_init = 100*randn(n,M);
for i=1:M
    % start somewhere near the reference signal
    x_init(:,i) = x_ref(:,N-N_i(i)+1) + -pi/6+rand(1)*pi/3;
    x_init(2,i) = 0;
%     x_init(2,i) = 0.1*randn(1); %initial velocity zero
end

x = zeros(n,N,M);
u = zeros(m,N-1,M);

for i = 1:M
    x(:,N-N_i(i)+1,i) = x_init(:,i);
end

q_t = zeros(n,N);

for t=1:N
    q_t(:,t) = -Q_t(:,:,t)*x_ref(:,t);
end
[~,g]=riccati_iteration_eta_time_varying(q_t,N,A,B,zeros(n,1),mathfrak_R,mathfrak_S,P);

for i=1:M
    w(:,:,i) = mvnrnd(zeros(m,1),Sigma_w,N)';
    
    for t=N-N_i(i)+2:N
        u(:,t-1,i) = -mathfrak_R(:,:,t-1)\(mathfrak_S(:,:,t-1)* ...
            x(:,t-1,i)+g(:,t-1));
        if ~is_process_noise
            x(:,t,i) = A*x(:,t-1,i) + B*u(:,t-1,i);
        else
            x(:,t,i) = A*x(:,t-1,i) + B*u(:,t-1,i)+B*w(:,t-1,i);
        end
    end
end

end