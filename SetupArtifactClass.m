function SetupArtifactClass(varargin)

if isempty(varargin)
    currentFolder = pwd;
else
    currentFolder = varargin{1,1};
end
addpath(genpath(currentFolder));