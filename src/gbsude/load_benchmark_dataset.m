function [X,y,note] = load_benchmark_dataset(ds)
% LOAD_GBSUDE_DATASET
% Robust loader for the exact files in the user's alldata folder.
%
% For MAT files it first tries common feature/label variable names. If the
% names differ, it automatically selects a numeric feature matrix together
% with a numeric label vector whose length matches one matrix dimension.

switch lower(ds.type)
    case 'csvpair'
        X = readmatrix(ds.xfile);
        y = readmatrix(ds.yfile);

        X = cleanup_numeric_matrix(X);
        y = cleanup_numeric_matrix(y);
        y = y(:);

        note = sprintf('CSV: %s | %s',ds.xfile,ds.yfile);

    case 'mat'
        S = load(ds.file);
        [X,y,xname,yname] = pick_xy_from_struct(S,ds.file);
        note = sprintf('MAT: %s | X=%s | y=%s',ds.file,xname,yname);

    otherwise
        error('GBSUDE:UnknownDatasetType','Unknown dataset type: %s',ds.type);
end

X = double(X);

if iscategorical(y)
    y = double(grp2idx(y));
elseif islogical(y)
    y = double(y);
elseif ~isnumeric(y)
    error('GBSUDE:NonNumericLabels','Labels must be numeric/categorical.');
else
    y = double(y);
end

y = y(:);

% Remove accidental all-NaN CSV rows/columns if any survived.
if any(~isfinite(y))
    error('GBSUDE:BadLabels','Label vector contains NaN/Inf.');
end

if size(X,1) ~= numel(y) && size(X,2) == numel(y)
    X = X';
end

if size(X,1) ~= numel(y)
    error('GBSUDE:LoadMismatch', ...
        'Could not align feature matrix and labels: X=%dx%d, y=%d.', ...
        size(X,1),size(X,2),numel(y));
end
end

function A = cleanup_numeric_matrix(A)
A = double(A);
if isempty(A), return; end
if ismatrix(A)
    badRows = all(isnan(A),2);
    A(badRows,:) = [];
    badCols = all(isnan(A),1);
    A(:,badCols) = [];
end
end

function [X,y,xname,yname] = pick_xy_from_struct(S,filePath)
names = fieldnames(S);

xPriority = {'X','x','data','Data','features','Features','fea','feature', ...
    'embeddings','embedding','XData','samples','sample'};
yPriority = {'Y','y','label','labels','Label','Labels','gnd','GND', ...
    'target','targets','class','classes','gt','truth'};

% 1) Strong name-based search.
X = [];
y = [];
xname = '';
yname = '';

for i=1:numel(xPriority)
    if isfield(S,xPriority{i})
        A = S.(xPriority{i});
        if isnumeric(A) || islogical(A)
            if ismatrix(A) && min(size(A)) > 1
                X = A;
                xname = xPriority{i};
                break;
            end
        end
    end
end

if ~isempty(X)
    for i=1:numel(yPriority)
        if isfield(S,yPriority{i})
            b = S.(yPriority{i});
            if (isnumeric(b) || islogical(b) || iscategorical(b)) && isvector(b)
                if numel(b)==size(X,1) || numel(b)==size(X,2)
                    y = b;
                    yname = yPriority{i};
                    break;
                end
            end
        end
    end
end

if ~isempty(X) && ~isempty(y)
    return;
end

% 2) Generic numeric matrix/vector matching.
matNames = {};
vecNames = {};

for i=1:numel(names)
    A = S.(names{i});
    if ~(isnumeric(A) || islogical(A) || iscategorical(A))
        continue;
    end
    if isvector(A) && numel(A) > 1
        vecNames{end+1} = names{i}; %#ok<AGROW>
    elseif isnumeric(A) && ismatrix(A) && min(size(A)) > 1
        matNames{end+1} = names{i}; %#ok<AGROW>
    end
end

bestScore = -inf;
bestX = [];
bestY = [];
bestXN = '';
bestYN = '';

for i=1:numel(matNames)
    A = S.(matNames{i});
    for j=1:numel(vecNames)
        b = S.(vecNames{j});
        nb = numel(b);

        if nb~=size(A,1) && nb~=size(A,2)
            continue;
        end

        score = log(double(numel(A))+1);

        xn = lower(matNames{i});
        yn = lower(vecNames{j});

        if contains(xn,'x') || contains(xn,'data') || ...
                contains(xn,'feat') || contains(xn,'embed')
            score = score + 20;
        end

        if contains(yn,'y') || contains(yn,'label') || ...
                contains(yn,'gnd') || contains(yn,'class') || ...
                contains(yn,'target') || contains(yn,'gt')
            score = score + 30;
        end

        % Prefer a plausible class-label vector.
        try
            nu = numel(unique(double(b(:))));
            if nu >= 2 && nu <= 200
                score = score + 15;
            end
        catch
        end

        if score > bestScore
            bestScore = score;
            bestX = A;
            bestY = b;
            bestXN = matNames{i};
            bestYN = vecNames{j};
        end
    end
end

if isempty(bestX) || isempty(bestY)
    fprintf(2,'Variables found in %s:\n',filePath);
    for i=1:numel(names)
        A = S.(names{i});
        fprintf(2,'  %-30s  class=%s  size=%s\n', ...
            names{i},class(A),mat2str(size(A)));
    end
    error('GBSUDE:AutoLoadFailed', ...
        'Could not automatically identify X and labels in %s.',filePath);
end

X = bestX;
y = bestY;
xname = bestXN;
yname = bestYN;
end
