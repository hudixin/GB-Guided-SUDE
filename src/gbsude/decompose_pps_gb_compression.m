function [id_final,id_core,id_fill,info] = ...
    decompose_pps_gb_compression(proxy,id_pps,rnn,targetL,varargin)
% DECOMPOSE_PPS_GB_COMPRESSION
% =========================================================================
% Reproduce the current PPS->GB compression, but expose its components:
%
%   id_core : one real PPS landmark nearest each GB center
%   id_fill : highest-RNN PPS landmarks used to complete targetL
%   id_final: [id_core ; id_fill], unique and exactly targetL
%
% This is a DIAGNOSTIC helper. No labels are accepted.
% =========================================================================

p = inputParser;
addParameter(p,'GBAlpha',0.2,@(x)isnumeric(x)&&isscalar(x));
addParameter(p,'GBMinBallSize',3,@(x)isnumeric(x)&&isscalar(x)&&x>=2);
addParameter(p,'GBRootSeed',2026,@(x)isnumeric(x)&&isscalar(x));
addParameter(p,'GBRootReplicates',20,@(x)isnumeric(x)&&isscalar(x)&&x>=1);
addParameter(p,'GBCustomReps',5,@(x)isnumeric(x)&&isscalar(x)&&x>=1);
addParameter(p,'GBCustomMaxIter',200,@(x)isnumeric(x)&&isscalar(x)&&x>=1);
parse(p,varargin{:});

gb_alpha       = p.Results.GBAlpha;
gb_min_ball    = p.Results.GBMinBallSize;
gb_root_seed   = p.Results.GBRootSeed;
gb_root_reps   = p.Results.GBRootReplicates;
gb_custom_reps = p.Results.GBCustomReps;
gb_custom_iter = p.Results.GBCustomMaxIter;

id_pps=unique(id_pps(:),'stable');
P=numel(id_pps);
targetL=max(2,min(round(targetL),P));

Xp=proxy(id_pps,:);

info=struct();
info.targetL=targetL;
info.ppsL=P;
info.actualBalls=NaN;
info.coreCount=NaN;
info.fillCount=NaN;
info.gbTime=0;
info.repTime=0;
info.coverageDistortion=NaN;
info.coverageDistortionNorm=NaN;
info.gbInfo=[];

%% Coarse GBs on PPS landmark cloud
t=tic;

[C,~,map,gbinfo]=semantic_match_size_guard_balls( ...
    Xp,gb_alpha,gb_min_ball,targetL, ...
    gb_root_seed,gb_root_reps,gb_custom_reps,gb_custom_iter);

info.gbTime=toc(t);
info.actualBalls=size(C,1);
info.gbInfo=gbinfo;

R=Xp-C(double(map(:)),:);
Eg=mean(sum(R.^2,2));
Rc=Xp-mean(Xp,1);
E0=mean(sum(Rc.^2,2));

info.coverageDistortion=Eg;
info.coverageDistortionNorm=Eg/max(E0,eps);

%% One center-medoid per GB
t=tic;

G=size(C,1);
local_sel=zeros(G,1);

for b=1:G
    ids=find(map==b);

    if isempty(ids)
        error('Empty GB in PPS-compression stage.');
    end

    dd=sum((Xp(ids,:)-C(b,:)).^2,2);
    [~,jj]=min(dd);
    local_sel(b)=ids(jj);
end

local_sel=unique(local_sel,'stable');
id_core=id_pps(local_sel);

%% Highest-RNN completion
need=targetL-numel(id_core);

id_fill=zeros(0,1);

if need>0
    selected=false(P,1);
    [~,loc]=ismember(id_core,id_pps);
    selected(loc(loc>0))=true;

    cand_local=find(~selected);
    cand_full=id_pps(cand_local);

    key=[-double(rnn(cand_full)), double(cand_full)];
    [~,ord]=sortrows(key,[1 2]);

    add_local=cand_local(ord(1:min(need,numel(ord))));
    id_fill=id_pps(add_local);
end

id_final=unique([id_core(:);id_fill(:)],'stable');

if numel(id_final)~=targetL
    error('Final compressed count %d differs from target %d.', ...
        numel(id_final),targetL);
end

if ~all(ismember(id_final,id_pps))
    error('All compressed landmarks must be original PPS landmarks.');
end

info.repTime=toc(t);
info.coreCount=numel(id_core);
info.fillCount=numel(id_fill);
end
