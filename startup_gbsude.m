function startup_gbsude(root)
%STARTUP_GBSUDE Add local code and the separately downloaded SUDE dependency.
if nargin<1
    root = fileparts(mfilename('fullpath'));
end
addpath(genpath(fullfile(root,'src')));
addpath(fullfile(root,'scripts'));

candidates = {
    fullfile(root,'external','sude','sude_mat'), ...
    fullfile(root,'external','sude-master','sude_mat') ...
};
found = false;
for i=1:numel(candidates)
    if isfolder(candidates{i})
        addpath(genpath(candidates{i}));
        found = true;
        break;
    end
end
if ~found
    warning(['Official SUDE MATLAB dependency not found. ', ...
             'Run setup_external_sude.m before running benchmarks.']);
end
end
