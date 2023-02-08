function lmi = LMI_constr(P_t_plus1,P_t,eta_t_plus1,eta_t,Q,q,R,xi_t,A,B)
% [~,m] = size(B);
g = B'*eta_t_plus1;
beta = q +A'*eta_t_plus1-eta_t;
lmi=[B'*P_t_plus1*B+R, B'*P_t_plus1*A, g;
    A'*P_t_plus1*B, A'*P_t_plus1*A+Q-P_t, beta;
    g', beta',xi_t];
end