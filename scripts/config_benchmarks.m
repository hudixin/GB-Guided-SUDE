function cfg = config_benchmarks()
%CONFIG_BENCHMARKS Paper configuration for the 12 benchmark datasets.

root = fileparts(fileparts(mfilename('fullpath')));
data_dir = fullfile(root,'data','processed');

cfg.TargetDim        = 30;
cfg.LandmarkCoef     = 16;
cfg.GBAlpha          = 0.2;
cfg.GBMinBallSize    = 3;
cfg.GBRootSeed       = 2026;
cfg.GBRootReplicates = 20;
cfg.GBCustomReps     = 5;
cfg.GBCustomMaxIter  = 200;
cfg.InitMethod       = 'le';
cfg.AggCoef          = 1.2;
cfg.MaxEpoch         = 50;
cfg.KMeansSeed       = 2026;
cfg.KMeansReplicates = 10;
cfg.KMeansMaxIter    = 200;

ds = mk('Kuzushiji-49',49,'mat',fullfile(data_dir,'K49','K49.mat'));
ds(end+1) = mk('EMNIST Balanced',47,'mat',fullfile(data_dir,'EMNIST','EMNIST_Balanced.mat'));
ds(end+1) = mk('MNIST',10,'mat',fullfile(data_dir,'MNIST','MNIST.mat'));
ds(end+1) = mk('Fashion-MNIST',10,'mat',fullfile(data_dir,'fashion','FashionMNIST.mat'));
ds(end+1) = mk('CIFAR10-ResNet50',10,'mat',fullfile(data_dir,'CIFAR10_ResNet50','CIFAR10_ResNet50.mat'));
ds(end+1) = mk('PaviaU',9,'mat',fullfile(data_dir,'paviau','PaviaU_clustering.mat'));
ds(end+1) = mk('UCI HAR',6,'mat',fullfile(data_dir,'UCI HAR','HAR.mat'));
ds(end+1) = mk('USPS',10,'mat',fullfile(data_dir,'USPS','USPS.mat'));
ds(end+1) = mk('ISOLET',26,'mat',fullfile(data_dir,'ISOLET','ISOLET.mat'));
ds(end+1) = mkpair('Gisette',2,fullfile(data_dir,'gisette_X.csv'),fullfile(data_dir,'gisette_Y.csv'));
ds(end+1) = mkpair('COIL20',20,fullfile(data_dir,'COIL20_X_1_0_.csv'),fullfile(data_dir,'COIL20_Y_1_0_.csv'));
ds(end+1) = mkpair('ORL',40,fullfile(data_dir,'ORL_X_1_0_.csv'),fullfile(data_dir,'ORL_Y_1_0_.csv'));
cfg.datasets = ds;
end

function s = mk(name,K,type,file)
s = struct('name',name,'K',K,'type',type,'file',file,'xfile','','yfile','');
end
function s = mkpair(name,K,xfile,yfile)
s = struct('name',name,'K',K,'type','csvpair','file','','xfile',xfile,'yfile',yfile);
end
