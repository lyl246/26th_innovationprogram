clear;
clc
yalmip('clear');
load('training_data_def_Q_noiseless.mat')

dt = data_gen_settings.dt;
N = data_gen_settings.N;
varphi = data_gen_settings.varphi;
nof_sys = data_gen_settings.nof_sys;
n = data_gen_settings.n;
m = data_gen_settings.m;

bar = waitbar(0,'Start solving IOC problems...');
for sys_id=1:nof_sys
    str = ['Solving the (',num2str(sys_id),' / ',num2str(nof_sys),') th IOC problem'];
    waitbar(sys_id/nof_sys,bar,str);
    M(sys_id) = size(x{sys_id},3);
    
    [status(sys_id), estimated_Q{sys_id},estimated_q{sys_id},errors{sys_id},opt_val{sys_id}] = ...
        solve_ioc_def_Q_noiseless(x{sys_id},u{sys_id},A{sys_id},B{sys_id},varphi,Q{sys_id},q{sys_id});
    
    err(sys_id) = norm([estimated_Q{sys_id} estimated_q{sys_id};estimated_q{sys_id}' 0]-[Q{sys_id} q{sys_id};q{sys_id}' 0],'fro');
end
close(bar)

for i=1:nof_sys
    max_err_u(i) = max(errors{i}.u);
    opt_obj_val(i) = errors{i}.opt_val;
    
end

for i=1:nof_sys
    rel_err(i) = err(i)/norm([Q{i} q{i};q{i}' 0],'fro');
end

figure(1)
[~,edges] = histcounts(log10(rel_err));
histogram(rel_err,10.^edges,'Normalization','probability');
set(gca, 'xscale','log')
title('Normalized Histogram of Relative Error Q','FontSize',24);
% ylabel('System number','Interpreter','latex','FontSize',20);
ylabel('Relative frequency','Interpreter','latex','FontSize',20);
xlabel('$\|\tilde{Q}_{est}-\tilde{\bar{Q}}\|_F/\|\tilde{\bar{Q}}\|_F$','Interpreter','latex','FontSize',20);
%axis([0 nof_sys+1 -inf inf])
set(gca,'fontsize',24)
%%
% tracking problem
clear;
clc
yalmip('clear');
load('training_data_tracking');

dt = data_gen_settings.dt;
N = data_gen_settings.N;
varphi = data_gen_settings.varphi;
% nof_sys = data_gen_settings.nof_sys;
nof_sys = 497;
n = data_gen_settings.n;
m = data_gen_settings.m;
Sigma_w = data_gen_settings.Sigma_w;

bar = waitbar(0,'Start solving IOC problems...');
for sys_id=1:nof_sys
    str = ['Solving the (',num2str(sys_id),' / ',num2str(nof_sys),') th IOC problem'];
    waitbar(sys_id/nof_sys,bar,str);
%     M(sys_id) = 20+(sys_id-1)*20;
    M(sys_id) = 40+(sys_id-1)*10;
%     M(sys_id) = 1000;
%       M(sys_id) = 100;
    
%     M(sys_id) = size(x{sys_id},3);
    [status{sys_id}, estimated_Q{sys_id}, errors{sys_id}] = ...
        solve_ioc_def_Q_noisy(x(:,:,1:M(sys_id)),u(:,:,1:M(sys_id)),A,B,varphi,Sigma_w,N_i(1:M(sys_id)),Q,R,x_ref,true);
end
close(bar)

for sys_id=1:nof_sys
    rel_err_noisy(sys_id) = norm(estimated_Q{sys_id}-Q,'fro')/norm(Q,'fro');
end
% MA_rel_err_noisy = movmean(rel_err_noisy, 31);

figure(2)
% subplot(2,1,1)
semilogy(M,rel_err_noisy);
% plot(M,rel_err_noisy)
% hold on
% semilogy(M, MA_rel_err_noisy, 'LineStyle', ':', 'Color', [0 0.4470 0.7410], 'LineWidth', 3.5);
% hold off
title('Relative Error Q','FontSize',24);
xlabel('$M$','Interpreter','latex','FontSize',20);
ylabel('$\|Q_{est}-\bar{Q}\|_F/\|\bar{Q}\|_F$','Interpreter','latex','FontSize',20);
% axis([2 1992 -inf inf])
set(gca,'fontsize',18);

%% real experiment
clear;
clc;
yalmip('clear');
load('jwh_tracking_data')
dt = data_gen_settings.dt;
nu_2 = data_gen_settings.N;
varphi = data_gen_settings.varphi;
n = data_gen_settings.n;
m = data_gen_settings.m;
Sigma_w = data_gen_settings.Sigma_w;
Sigma_w = 5.7749e-4;
Sigma_w = 6.8062e-4;
% Sigma_w = 8.3825e-4;
M=size(x,3);
% M=500;
R=1;
A_tmp = [0 1;
         0 0];
A =expm(A_tmp*data_gen_settings.dt);
mass = 0.2; %mass attached to the rod
ell = 0.255; %length of the rod
momentum_of_inertia = mass*ell^2;
B_tmp = [0;1/momentum_of_inertia];
B = integral(@(t) expm(A_tmp.*t),0,data_gen_settings.dt, ...
    'ArrayValued', true)*B_tmp;


[status, estimated_Q, errors] = ...
        solve_ioc_def_Q_noisy(x(:,:,1:M),[],A,B,varphi,Sigma_w,N_i(1:M),[],R,x_ref,false);

%%
% verification
% calculate Riccati iterations using estimated Q
% estimated_Q=[0.005 0.000;0.000 0.0001];
load('jwh_tracking_verification_data-3')

Q_t_est = zeros(n,n,nu_2);
for t = 1:nu_2
    Q_t_est(:,:,t) = estimated_Q;
end

[P,mathfrak_R,mathfrak_S]=riccati_iteration_P_time_varying(Q_t_est,R,nu_2,A,B);
q_est_ver = -estimated_Q*x_ref_ver;
[~,g]=riccati_iteration_eta_time_varying(q_est_ver,nu_2,A,B,zeros(n,1),mathfrak_R,mathfrak_S,P);


time_horizon_lengths = unique(N_i);
index= 1;
box_plot_label = {};
x_pred = zeros(n,nu_2,length(time_horizon_lengths));
time_domain = (1:120)*dt;
for N=time_horizon_lengths
    indices = find(N_i==N);
    if length(indices)<=10
        continue;
    end
    x_average = mean(x_ver(:,:,indices),3);
    
    % Now calculate the state with that time horizon.
    x_pred(:,nu_2-N+1,index) = x_average(:,nu_2-N+1); %initial value
    for t=nu_2-N+2:nu_2
        u_pred(:,t-1,index) = -mathfrak_R(:,:,t-1)\(mathfrak_S(:,:,t-1)* ...
            x_pred(:,t-1,index)+g(:,t-1));
        x_pred(:,t,index) = A*x_pred(:,t-1,index) + B*u_pred(:,t-1,index);
    end
    
    figure(3);
    subplot(1,2,2)
    hold on;
    count = 1;
    for i=indices
        prediction_errors{index}(count,1) = norm(x_pred(:,:,index)-x_ver(:,:,i),'fro')/N;
        h = plot(time_domain,x_ver(1,:,i),time_domain,x_ver(2,:,i));
        h(1).Color = [0 0.4470 0.7410 0.6];
        h(2).Color = [0.8500 0.3250 0.0980 0.6];
        count = count+1;
    end 
    
    h1 = plot(time_domain,x_pred(1,:,index),'b',time_domain,x_pred(2,:,index),'r');
    h1(1).LineWidth=2;
    h1(2).LineWidth=2;
    h2 = plot(time_domain,x_ref_ver(1,:),'-.',time_domain,x_ref_ver(2,:),'-.');
    h2(1).LineWidth=1.5;
    h2(1).Color = [0.9290 0.6940 0.1250];
    h2(2).LineWidth=1.5;
    h2(2).Color = [0.4940 0.1840 0.5560];
    hold off;
    plot_title = sprintf('$N=%d, M^{(N)}=%d$',N,length(indices));
    title(plot_title,'FontSize',24,'Interpreter','latex');
    xlabel('$t(s)$','Interpreter','latex','FontSize',20);
    ylabel('$x_t$','Interpreter','latex','FontSize',20);
    
    legend([h1(1),h1(2),h(1),h(2),h2(1),h2(2)],{'$x_{t,1}^{pred}$',...
       '$x_{t,2}^{pred}$','$x_{t,1}^{i_N}$','$x_{t,2}^{i_N}$','$x_{t,1}^r$','$x_{t,2}^r$'},'Interpreter','latex','FontSize',20,'NumColumns',3);
    index = index+1;
    N
    length(indices)
end
set(gca,'fontsize',18);

% boxplot(prediction_errors,'labels',box_plot_label);
% h = findobj(gca, 'type', 'text');
% set(h, 'Interpreter', 'tex');
% set(gca,'fontsize',20);