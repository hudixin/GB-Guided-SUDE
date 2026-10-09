function id = pps_select(knn, rnn, order)
%PPS_SELECT Independent implementation of Plum-Pudding Sampling (PPS).
%   id = PPS_SELECT(knn,rnn,order) ranks samples by reverse-nearest-neighbor
%   count. After selecting a landmark, its neighbors up to the requested
%   order are suppressed from the candidate queue.
%
%   This implementation is written for the GB-Guided SUDE release and does
%   not copy the upstream SUDE MATLAB source.

if nargin < 3, order = 1; end
rnn = rnn(:);
[~, queue] = sort(rnn,'descend');
id = zeros(0,1);

while ~isempty(queue)
    anchor = queue(1);
    id(end+1,1) = anchor; %#ok<AGROW>

    remove_ids = anchor;
    frontier = anchor;
    for t = 1:order
        frontier = unique(knn(frontier,:));
        frontier = frontier(:);
        remove_ids = unique([remove_ids; frontier]); %#ok<AGROW>
    end
    queue(ismember(queue,remove_ids)) = [];
end
end
