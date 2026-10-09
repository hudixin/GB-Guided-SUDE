function T = run_all_benchmarks()
%RUN_ALL_BENCHMARKS Run all 12 datasets using the paper configuration.

root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')));
startup_gbsude(root);

cfg = config_benchmarks();
rows = cell(numel(cfg.datasets),1);

for i=1:numel(cfg.datasets)
    fprintf('\n[%d/%d] %s\n',i,numel(cfg.datasets),cfg.datasets(i).name);
    rows{i} = run_one_benchmark(cfg.datasets(i),cfg);
end

T = vertcat(rows{:});
out = fullfile(root,'results','gbsude_results.csv');
writetable(T,out);
fprintf('\nSaved: %s\n',out);
end
