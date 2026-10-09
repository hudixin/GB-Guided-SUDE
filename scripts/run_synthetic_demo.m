function row = run_synthetic_demo()
%RUN_SYNTHETIC_DEMO Generated example; no third-party dataset required.
% This demo uses >2000 samples so the shared KNN/RNN graph, PPS, GB
% compression, SUDE embedding, and K-means evaluation are all exercised.

root = fileparts(fileparts(mfilename('fullpath')));
startup_gbsude(root);

rng(2026,'twister');

n_per_class = 800;
d = 50;

X1 = randn(n_per_class,d)*0.35;
X2 = randn(n_per_class,d)*0.40 + 2.0;
X3 = randn(n_per_class,d)*0.30 - 2.0;

X = [X1; X2; X3];
y = [ones(n_per_class,1); 2*ones(n_per_class,1); 3*ones(n_per_class,1)];

demo_dir = fullfile(root,'data','processed','demo');
if ~isfolder(demo_dir), mkdir(demo_dir); end
save(fullfile(demo_dir,'synthetic_demo.mat'),'X','y');

cfg = config_benchmarks();

ds = struct( ...
    'name','Synthetic demo', ...
    'K',3, ...
    'type','mat', ...
    'file',fullfile(demo_dir,'synthetic_demo.mat'), ...
    'xfile','', ...
    'yfile','');

fprintf('\nRunning the full public-release smoke test...\n');
row = run_one_benchmark(ds,cfg);
disp(row);
end
