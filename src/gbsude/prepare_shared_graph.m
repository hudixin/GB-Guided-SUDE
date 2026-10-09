function G = prepare_shared_graph(Xu,target_dim)
%PREPARE_SHARED_GRAPH Build the shared KNN/RNN graph and PPS landmarks.
%   Requires the official SUDE MATLAB dependency on the MATLAB path because
%   the large/high-dimensional branch uses SUDE's init_pca helper.

[n,d] = size(Xu);

if n > 20000
    k1 = 50;
elseif n > 10000
    k1 = 20;
elseif n > 2000
    k1 = 10;
else
    k1 = 0;
end

if k1 > 0
    if n >= 5000 && d >= 50
        if exist('init_pca','file') ~= 2
            error(['init_pca was not found. Run setup_external_sude.m ', ...
                   'or add the official SUDE MATLAB folder to the path.']);
        end
        proxy = init_pca(Xu,target_dim,0.8);
    else
        proxy = Xu;
    end

    [get_knn,~] = knnsearch(proxy,proxy,'k',k1+1);

    % Reverse-nearest-neighbor count without relying on TABULATE.
    rnn = accumarray(get_knn(:),1,[n 1]);
    id_pps = pps_select(get_knn,rnn,1);
else
    proxy = Xu;
    get_knn = zeros(n,0);
    rnn = zeros(n,1);
    id_pps = (1:n)';
end

G = struct('proxy',proxy,'get_knn',get_knn,'rnn',rnn, ...
           'id_pps',id_pps(:),'k1',k1);
end
