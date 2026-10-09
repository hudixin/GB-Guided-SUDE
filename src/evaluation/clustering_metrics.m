function M = clustering_metrics(y_true,y_pred)
%CLUSTERING_METRICS ACC, NMI and ARI for clustering evaluation.
%   Labels are used only for external evaluation.

y_true = y_true(:);
y_pred = y_pred(:);
assert(numel(y_true)==numel(y_pred),'Label lengths must match.');

M.ACC = clustering_acc(y_true,y_pred);
M.NMI = clustering_nmi(y_true,y_pred);
M.ARI = clustering_ari(y_true,y_pred);
end

function acc = clustering_acc(a,b)
[~,~,ia] = unique(a);
[~,~,ib] = unique(b);
ka = max(ia); kb = max(ib);
C = accumarray([ib ia],1,[kb ka]);
% matchpairs is a MATLAB function (R2019a+). Maximize matched counts.
pairs = matchpairs(C,0,'max');
matched = sum(C(sub2ind(size(C),pairs(:,1),pairs(:,2))));
acc = matched / numel(a);
end

function z = clustering_nmi(a,b)
[~,~,ia] = unique(a);
[~,~,ib] = unique(b);
n = numel(a);
C = accumarray([ia ib],1);
P = C/n;
pa = sum(P,2);
pb = sum(P,1);
[r,c] = find(P>0);
mi = 0;
for t=1:numel(r)
    p = P(r(t),c(t));
    mi = mi + p*log(p/(pa(r(t))*pb(c(t))));
end
Ha = -sum(pa(pa>0).*log(pa(pa>0)));
Hb = -sum(pb(pb>0).*log(pb(pb>0)));
if Ha<=eps || Hb<=eps
    z = double(isequal(ia,ib));
else
    z = mi/sqrt(Ha*Hb);
end
end

function ari = clustering_ari(a,b)
[~,~,ia] = unique(a);
[~,~,ib] = unique(b);
n = numel(a);
C = accumarray([ia ib],1);
r = sum(C,2);
c = sum(C,1);
c2 = @(x) x.*(x-1)/2;
A = sum(c2(C(:)));
R = sum(c2(r));
Q = sum(c2(c));
T = c2(n);
expected = R*Q/max(T,eps);
den = 0.5*(R+Q)-expected;
if abs(den)<=eps
    ari = 1;
else
    ari = (A-expected)/den;
end
end
