function row = run_one_benchmark(ds,cfg)
%RUN_ONE_BENCHMARK Run GB-Guided SUDE on one benchmark dataset.

[X,y,source_note] = load_benchmark_dataset(ds);
X = double(X);
y = y(:);

t_all = tic;
[Xu_raw,~,orig_id] = unique(X,'rows');
xmin = min(Xu_raw,[],1);
xmax = max(Xu_raw,[],1);
den = xmax-xmin; den(den<=eps)=1;
Xu = (Xu_raw-xmin)./den;

G = prepare_shared_graph(Xu,cfg.TargetDim);
P = numel(G.id_pps);

if G.k1 == 0
    L = P;
else
    L = min(P,max(cfg.TargetDim+2,ceil(cfg.LandmarkCoef*sqrt(size(Xu,1)))));
end

t_comp = tic;
if L < P
    [id_final,id_core,id_fill,cinfo] = gb_guided_pps_compression( ...
        G.proxy,G.id_pps,G.rnn,L, ...
        'GBAlpha',cfg.GBAlpha, ...
        'GBMinBallSize',cfg.GBMinBallSize, ...
        'GBRootSeed',cfg.GBRootSeed, ...
        'GBRootReplicates',cfg.GBRootReplicates, ...
        'GBCustomReps',cfg.GBCustomReps, ...
        'GBCustomMaxIter',cfg.GBCustomMaxIter);
else
    id_final = G.id_pps;
    id_core = G.id_pps;
    id_fill = zeros(0,1);
    cinfo = struct();
end
compression_time = toc(t_comp);

t_sude = tic;
Y = replay_embedding_external_sude(Xu,orig_id,G,id_final, ...
    'NumDimensions',cfg.TargetDim,'InitMethod',cfg.InitMethod, ...
    'AggCoef',cfg.AggCoef,'MaxEpoch',cfg.MaxEpoch,'LargeData',true);
sude_time = toc(t_sude);

rng(cfg.KMeansSeed,'twister');
t_km = tic;
pred = kmeans(Y,ds.K,'Replicates',cfg.KMeansReplicates, ...
    'MaxIter',cfg.KMeansMaxIter,'Start','plus','Display','off');
kmeans_time = toc(t_km);

M = clustering_metrics(y,pred);

% Do not expose absolute local paths in public result files.
source_note = regexprep(string(source_note),'([A-Za-z]:[\\/][^|]+)','local file');
source_note = regexprep(source_note,'/[^|]+','local file');

row = table(string(ds.name),size(X,1),size(X,2),ds.K,P,numel(id_final), ...
    numel(id_core),numel(id_fill),numel(id_final)/max(P,1), ...
    M.ACC,M.NMI,M.ARI,compression_time,sude_time,kmeans_time,toc(t_all), ...
    source_note, ...
    'VariableNames',{'Dataset','N','D','K','PPS','Landmarks','GBCore','RNNFill', ...
    'Retention','ACC','NMI','ARI','CompressionTime','SUDETime','KMeansTime','TotalTime','Source'});
end
