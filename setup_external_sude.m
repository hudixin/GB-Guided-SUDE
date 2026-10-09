function setup_external_sude()
%SETUP_EXTERNAL_SUDE Download the official SUDE MATLAB repository.
% The upstream source is not redistributed in this repository.

root = fileparts(mfilename('fullpath'));
ext = fullfile(root,'external');
if ~isfolder(ext), mkdir(ext); end

url = 'https://github.com/ZPGuiGroupWhu/sude/archive/refs/heads/master.zip';
zipfile = fullfile(tempdir,'sude-master.zip');
fprintf('Downloading official SUDE from:\n%s\n',url);
websave(zipfile,url);

unzip(zipfile,ext);
src = fullfile(ext,'sude-master');
dst = fullfile(ext,'sude');
if isfolder(dst), rmdir(dst,'s'); end
movefile(src,dst);

startup_gbsude(root);
fprintf('SUDE installed under: %s\n',dst);
fprintf('Please review the upstream repository terms before redistribution.\n');
end
