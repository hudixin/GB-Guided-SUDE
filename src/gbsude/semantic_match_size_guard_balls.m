function [centers,ball_sizes,sample_to_ball,info] = ...
    semantic_match_size_guard_balls( ...
    X,alpha,min_ball_size,max_balls, ...
    root_seed,root_replicates,custom_reps,custom_maxiter)
% SEMANTIC_MATCH_SIZE_GUARD_BALLS
% =========================================================================
% SemanticMatch + sqrt(N) Granularity Safeguard
%
% 与已验证的 SemanticMatch 完全相同，只增加一个无标签粒度保护：
%
%   Mmax = ceil(sqrt(N))
%
% 对任一当前粒球 B：
%
%   正常接受条件：
%       Gain(B) > tau
%
%   新增保护条件：
%       |B| > Mmax
%
% 因此，只要二分候选本身有效（两子球均 >= min_ball_size），
% 便按下式接受：
%
%       Gain(B) > tau  OR  |B| > ceil(sqrt(N))
%
% 解释：
%   Gain控制几何质量；
%   sqrt(N) size guard 防止少数超级大粒球长期停止分裂，
%   从而避免单个anchor代表过多样本。
%
% 不使用真实标签，也不使用K。
% 其余参数、SemanticMatch分裂语义、随机种子全部保持不变。
% =========================================================================

if nargin<8 || isempty(custom_maxiter), custom_maxiter=200; end
if nargin<7 || isempty(custom_reps), custom_reps=5; end
if nargin<6 || isempty(root_replicates), root_replicates=20; end
if nargin<5 || isempty(root_seed), root_seed=2026; end
if nargin<4 || isempty(max_balls), max_balls=20000; end
if nargin<3 || isempty(min_ball_size), min_ball_size=3; end

X=double(X);
[N,D]=size(X);

if any(~isfinite(X(:)))
    error('X包含NaN/Inf。');
end

info=struct();
info.root_gain=NaN;
info.tau=NaN;
info.root_valid=false;
info.accepted_splits=0;
info.rejected_splits=0;
info.attempted_splits=0;
info.num_balls=0;

info.custom_calls=0;
info.custom_time=0;
info.total_replicates=0;

% 直接检验“Stable语义是否阻止了旧Custom的额外分裂”
info.best_invalid_size_rejections=0;
info.no_candidate_rejections=0;
info.valid_best_candidates=0;

% sqrt(N) granularity safeguard diagnostics
info.max_ball_size_limit=ceil(sqrt(N));
info.size_guard_attempts=0;
info.size_guard_forced_accepts=0;
info.size_guard_all_accepts=0;
info.oversized_unsplittable=0;
info.oversized_blocked_by_maxballs=0;
info.final_oversized_balls=NaN;
info.max_final_ball_size=NaN;

root_idx=(1:N)';

%% ======================== 1) 根节点 ===========================
[ok,root1,root2,G0]=try_split_root_matlab( ...
    X,root_idx,min_ball_size,root_seed,root_replicates);

info.root_gain=G0;

if ~ok || ~isfinite(G0) || G0<=0
    centers=mean(X,1);
    ball_sizes=N;
    sample_to_ball=ones(N,1);
    info.num_balls=1;
    return;
end

tau=alpha*G0;
info.tau=tau;
info.root_valid=true;
info.accepted_splits=1;
info.attempted_splits=1;

%% ======================== 2) BFS递归 ==========================
queue=cell(max_balls*2+10,1);
head=1; tail=2;
queue{1}=root1;
queue{2}=root2;

final_balls=cell(max_balls+10,1);
final_count=0;

while head<=tail

    idx=queue{head};
    queue{head}=[];
    head=head+1;

    if isempty(idx), continue; end

    m=numel(idx);

    if m<2*min_ball_size
        final_count=final_count+1;
        final_balls{final_count}=idx;
        continue;
    end

    active_count=max(0,tail-head+1);
    current_total=final_count+active_count+1;

    if current_total>=max_balls
        final_count=final_count+1;
        final_balls{final_count}=idx;
        continue;
    end

    info.attempted_splits=info.attempted_splits+1;

    split_seed=make_ball_seed(idx,13579);

    ts=tic;
    [ok,a,b,gain,diaginfo]=try_split_custom_semantic( ...
        X,idx,min_ball_size,split_seed,custom_reps,custom_maxiter);
    info.custom_time=info.custom_time+toc(ts);
    info.custom_calls=info.custom_calls+1;
    info.total_replicates=info.total_replicates+diaginfo.replicates_run;

    if diaginfo.no_candidate
        info.no_candidate_rejections=info.no_candidate_rejections+1;
    end

    if diaginfo.best_invalid_size
        info.best_invalid_size_rejections= ...
            info.best_invalid_size_rejections+1;
    end

    if diaginfo.best_valid
        info.valid_best_candidates=info.valid_best_candidates+1;
    end

    oversized = (m > info.max_ball_size_limit);

    if oversized
        info.size_guard_attempts=info.size_guard_attempts+1;
    end

    valid_split = ok && isfinite(gain) && ~isempty(a) && ~isempty(b);
    accept_by_gain = valid_split && (gain>tau);
    accept_by_size = valid_split && oversized;

    if accept_by_gain || accept_by_size

        projected=final_count+max(0,tail-head+1)+2;

        if projected<=max_balls
            tail=tail+1; queue{tail}=a;
            tail=tail+1; queue{tail}=b;
            info.accepted_splits=info.accepted_splits+1;

            if oversized
                info.size_guard_all_accepts=info.size_guard_all_accepts+1;
            end

            if accept_by_size && ~accept_by_gain
                info.size_guard_forced_accepts= ...
                    info.size_guard_forced_accepts+1;
            end
        else
            final_count=final_count+1;
            final_balls{final_count}=idx;
            info.rejected_splits=info.rejected_splits+1;

            if oversized
                info.oversized_blocked_by_maxballs= ...
                    info.oversized_blocked_by_maxballs+1;
            end
        end

    else
        final_count=final_count+1;
        final_balls{final_count}=idx;
        info.rejected_splits=info.rejected_splits+1;

        if oversized
            info.oversized_unsplittable=info.oversized_unsplittable+1;
        end
    end
end

final_balls=final_balls(1:final_count);
g=final_count;

if g<1
    error('最终粒球数为0。');
end

%% ======================== 3) 输出 =============================
centers=zeros(g,D);
ball_sizes=zeros(g,1);
sample_to_ball=zeros(N,1);

for b=1:g
    idx=final_balls{b};

    if isempty(idx)
        error('第%d个粒球为空。',b);
    end

    centers(b,:)=mean(X(idx,:),1);
    ball_sizes(b)=numel(idx);

    if any(sample_to_ball(idx)~=0)
        error('样本重复分配。');
    end

    sample_to_ball(idx)=b;
end

if any(sample_to_ball==0)
    error('存在未覆盖样本。');
end

if sum(ball_sizes)~=N
    error('ball_sizes总和不等于N。');
end

info.num_balls=g;
info.max_final_ball_size=max(ball_sizes);
info.final_oversized_balls=sum(ball_sizes>info.max_ball_size_limit);
end

%% ========================================================================
% 根节点：严格照 Stable-5 的 MATLAB kmeans 语义
% =========================================================================
function [ok,idx1,idx2,gain]=try_split_root_matlab( ...
    X,idx,min_ball_size,seed,replicates)

ok=false; idx1=[]; idx2=[]; gain=NaN;

if isempty(idx) || numel(idx)<2*min_ball_size
    return;
end

Xi=X(idx,:);

c=mean(Xi,1);
d=Xi-c;
sse_parent=sum(d(:).^2);

if ~isfinite(sse_parent) || sse_parent<=eps
    return;
end

try
    rng(seed,'twister');
    lab=kmeans(Xi,2, ...
        'MaxIter',200, ...
        'Replicates',replicates, ...
        'Start','plus');
catch
    return;
end

l1=find(lab==1);
l2=find(lab==2);

if numel(l1)<min_ball_size || numel(l2)<min_ball_size
    return;
end

sse1=finite_sse(Xi(l1,:));
sse2=finite_sse(Xi(l2,:));

if ~isfinite(sse1) || ~isfinite(sse2)
    return;
end

gain=(sse_parent-sse1-sse2)/(sse_parent+eps);

if ~isfinite(gain)
    return;
end

idx1=idx(l1);
idx2=idx(l2);
ok=true;
end

%% ========================================================================
% Custom K=2 多启动 + Stable-compatible selection semantics
% =========================================================================
function [ok,idx1,idx2,gain,diaginfo]=try_split_custom_semantic( ...
    X,idx,min_ball_size,seed,reps,max_iter)

ok=false; idx1=[]; idx2=[]; gain=NaN;

diaginfo=struct();
diaginfo.replicates_run=0;
diaginfo.no_candidate=false;
diaginfo.best_invalid_size=false;
diaginfo.best_valid=false;
diaginfo.best_child_sse=NaN;
diaginfo.best_n1=NaN;
diaginfo.best_n2=NaN;

if isempty(idx) || numel(idx)<2*min_ball_size
    diaginfo.no_candidate=true;
    return;
end

Xi=X(idx,:);
m=size(Xi,1);

c0=mean(Xi,1);
R0=Xi-c0;
sse_parent=sum(R0(:).^2);

if ~isfinite(sse_parent) || sse_parent<=eps
    diaginfo.no_candidate=true;
    return;
end

rng(seed,'twister');

best_sse=inf;
best_lab=[];

for r=1:reps

    diaginfo.replicates_run=diaginfo.replicates_run+1;

    % ----------------------------------------------------------
    % KMeans++ 风格 K=2 初始化
    % ----------------------------------------------------------
    ia=randi(m);
    c1=Xi(ia,:);

    d1=sum((Xi-c1).^2,2);
    sd=sum(d1);

    if ~isfinite(sd) || sd<=eps
        continue;
    end

    u=rand()*sd;
    cs=cumsum(d1);
    ib=find(cs>=u,1,'first');

    if isempty(ib)
        [~,ib]=max(d1);
    end

    if ib==ia
        [~,ib]=max(d1);
    end

    if ib==ia
        continue;
    end

    c2=Xi(ib,:);

    last_lab=zeros(m,1);
    lab=[];

    % ----------------------------------------------------------
    % Lloyd，最多 max_iter=200
    % ----------------------------------------------------------
    for it=1:max_iter

        dist1=sum((Xi-c1).^2,2);
        dist2=sum((Xi-c2).^2,2);

        lab=ones(m,1);
        lab(dist2<dist1)=2;

        n1=sum(lab==1);
        n2=m-n1;

        % 模拟 singleton empty-action：
        % 若某簇为空，把“离当前所属中心最远”的样本移到空簇。
        if n1==0
            [~,ii]=max(dist2);
            lab(ii)=1;
        elseif n2==0
            [~,ii]=max(dist1);
            lab(ii)=2;
        end

        if isequal(lab,last_lab)
            break;
        end

        last_lab=lab;

        c1=mean(Xi(lab==1,:),1);
        c2=mean(Xi(lab==2,:),1);

        if any(~isfinite(c1)) || any(~isfinite(c2))
            lab=[];
            break;
        end
    end

    if isempty(lab)
        continue;
    end

    l1=find(lab==1);
    l2=find(lab==2);

    if isempty(l1) || isempty(l2)
        continue;
    end

    % 关键：这里不检查 min_ball_size。
    % 先无条件计算本replicate的child SSE。
    sse1=finite_sse(Xi(l1,:));
    sse2=finite_sse(Xi(l2,:));

    if ~isfinite(sse1) || ~isfinite(sse2)
        continue;
    end

    child_sse=sse1+sse2;

    if child_sse<best_sse
        best_sse=child_sse;
        best_lab=lab;
    end
end

if isempty(best_lab)
    diaginfo.no_candidate=true;
    return;
end

l1=find(best_lab==1);
l2=find(best_lab==2);

diaginfo.best_child_sse=best_sse;
diaginfo.best_n1=numel(l1);
diaginfo.best_n2=numel(l2);

% 关键语义：
% 只检查“全局最低SSE的那个replicate”。
% 若它的child太小，整次节点分裂直接失败。
if numel(l1)<min_ball_size || numel(l2)<min_ball_size
    diaginfo.best_invalid_size=true;
    return;
end

diaginfo.best_valid=true;

gain=(sse_parent-best_sse)/(sse_parent+eps);

if ~isfinite(gain)
    return;
end

idx1=idx(l1);
idx2=idx(l2);
ok=true;
end

%% ========================================================================
function sse=finite_sse(X)
c=mean(X,1);
R=X-c;
sse=sum(R(:).^2);

if ~isfinite(sse)
    sse=NaN;
end
end

%% ========================================================================
function s=make_ball_seed(idx,base_seed)

idx=double(idx(:));
m=numel(idx);

h=mod( ...
    104729*idx(1) + ...
    13007*idx(end) + ...
    8191*m + ...
    17*mod(sum(idx),1000003) + ...
    double(base_seed), ...
    2147483000);

s=max(1,floor(h));
end
