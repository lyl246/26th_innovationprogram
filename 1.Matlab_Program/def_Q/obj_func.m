function val = obj_func(Q,q,P,eta,xi,M,A,B,N,XXT,X,U)
n = size(Q,1);
obj = -0.5*trace(P(:,:,1)*XXT(:,:,1)) ...
    -trace((kron(ones(1,M),eta(:,1)))'*X(:,:,1)) ...
    +0.5 * trace(P(:,:,N)*XXT(:,:,N))...
    +trace((kron(ones(1,M),eta(:,N)))'*X(:,:,N));

q_tilde = kron(ones(1,M),q);
for t=1:N-1
    obj = obj + 0.5*trace(Q*XXT(:,:,t)) + trace(q_tilde'*X(:,:,t));
    obj = obj + M*(0.5*xi(t));
    obj = obj + 0.5*trace(U(:,:,t)*U(:,:,t)');
end

for t=1:N-1
%     obj = obj + 1*norm(U(:,:,t)+B'*P(:,:,t+1)*X(:,:,t+1)...
%         +B'*(kron(ones(1,M),eta(:,t+1))),'fro');
      U_est = B\(X(:,:,t+1)-A*X(:,:,t));
      obj = obj + 1e3*norm(U_est+B'*P(:,:,t+1)*X(:,:,t+1)...
        +B'*(kron(ones(1,M),eta(:,t+1))),'fro');
%     obj = obj+norm( (eye(n)+B*B'*P(:,:,t+1))*X(:,:,t+1)+B*B'*(kron(ones(1,M),eta(:,t+1)))-A*X(:,:,t),'fro' );
end

val = obj;
end