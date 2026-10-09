function Y = replay_embedding_external_sude(Xu,orig_id,G,id_samp,varargin)
%REPLAY_EMBEDDING_EXTERNAL_SUDE Embed a supplied landmark set with SUDE.
%   The official SUDE MATLAB implementation must be installed separately.
%   This repository intentionally does not redistribute the upstream MATLAB
%   source. See external/README.md.

p = inputParser;
addParameter(p,'NumDimensions',30,@(x)isnumeric(x)&&isscalar(x)&&x>0);
addParameter(p,'InitMethod','le',@(x)ischar(x)||isstring(x));
addParameter(p,'AggCoef',1.2,@(x)isnumeric(x)&&isscalar(x)&&x>0);
addParameter(p,'MaxEpoch',50,@(x)isnumeric(x)&&isscalar(x)&&x>0);
addParameter(p,'LargeData',true,@islogical);
parse(p,varargin{:});

needed = {'learning_l','learning_s','opt_scale','clle'};
for i=1:numel(needed)
    if exist(needed{i},'file') ~= 2
        error('%s was not found. Run setup_external_sude.m first.',needed{i});
    end
end

no_dims = p.Results.NumDimensions;
initialize = char(p.Results.InitMethod);
agg_coef = p.Results.AggCoef;
T_epoch = p.Results.MaxEpoch;
large = p.Results.LargeData;

n = size(Xu,1);
id_samp = unique(id_samp(:),'stable');
X_samp = Xu(id_samp,:);

if large
    [Y_samp,k2] = learning_l(X_samp,G.k1,G.get_knn,G.rnn,id_samp, ...
        no_dims,initialize,agg_coef,T_epoch);
else
    [Y_samp,k2] = learning_s(X_samp,G.k1,G.get_knn,G.rnn,id_samp, ...
        no_dims,initialize,agg_coef,T_epoch);
end

if G.k1 > 0
    id_rest = setdiff((1:n)',id_samp,'stable');
    X_rest = Xu(id_rest,:);
    Y_rest = zeros(numel(id_rest),no_dims);

    scale = opt_scale(X_samp,Y_samp,k2);
    top_k = min(no_dims+1,size(X_samp,1));

    if n >= 5000 && size(Xu,2) >= 50
        [near_samp,near_dis] = knnsearch(G.proxy(id_samp,:),G.proxy(id_rest,:),'k',top_k);
    else
        [near_samp,near_dis] = knnsearch(X_samp,X_rest,'k',top_k);
    end

    for i=1:numel(id_rest)
        idx = near_samp(i,:);
        N_dis = near_dis(i,1)*scale(idx(1));
        Y_rest(i,:) = clle(X_samp(idx,:),Y_samp(idx,:),X_rest(i,:),N_dis);
    end

    Yu = zeros(n,no_dims);
    Yu(id_samp,:) = Y_samp;
    Yu(id_rest,:) = Y_rest;
else
    Yu = Y_samp;
end

Y = Yu(orig_id,:);
end
