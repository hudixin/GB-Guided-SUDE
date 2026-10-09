function [id_final,id_core,id_fill,info] = ...
    gb_guided_pps_compression(proxy,id_pps,rnn,targetL,varargin)
% GB_GUIDED_PPS_COMPRESSION
% =========================================================================
% Final fixed-30D upstream landmark compression module.
%
% Pipeline:
%   Original PPS landmarks
%     -> granular balls on the PPS proxy cloud
%     -> one real PPS center-medoid per granular ball
%     -> highest-RNN PPS completion to targetL
%
% This function does not accept or use class labels.
% =========================================================================

[id_final,id_core,id_fill,info] = ...
    decompose_pps_gb_compression(proxy,id_pps,rnn,targetL,varargin{:});
end
