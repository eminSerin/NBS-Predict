function data = check_workspace(wp_dir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check_workspace checks if the workspace directory contains all necessary
% files
%
% Arguments:
%   wp_dir: Workspace directory
%
% Output:
%   data: Structure containing the paths of the files
%
% Example:
%   data = check_workspace("C:\Users\user\Documents\workspace");
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("Checking workspace directory...\n");

% Check if correlation matrices provided
if ~exist(fullfile(wp_dir, "matrices"), "dir")
    error("No directory 'matrices' found in workspace directory!");
else
    % Check if the directory is empty
    if isempty(dir(fullfile(wp_dir, "matrices")))
        error("Directory 'matrices' is empty, please provide correlation matrices.");
    end
end
data.corrPath = fullfile(wp_dir, "matrices");
corr_files = [dir(fullfile(wp_dir, "matrices", "*.mat")), ...
    dir(fullfile(wp_dir, "matrices", "*.csv"))];

% Check if brain regions is provided
br_file = [dir(fullfile(wp_dir, "brainRegions.mat")), ...
    dir(fullfile(wp_dir, "brainRegions.csv"))];
if size(br_file, 1) > 1
    warning("Multiple brain regions files found in workspace directory!, using the with the latest modification date.");
    [~, idx] = max([br_file.datenum]);
    br_file = br_file(idx);
end
data.brainRegionsPath = fullfile(br_file.folder, br_file.name);
if isempty(br_file)
    error("No brainRegions file found in workspace directory!");
end

% Check if design matrix is provided
dm_file = [dir(fullfile(wp_dir, "design.mat")), ...
    dir(fullfile(wp_dir, "design.csv"))];
if size(dm_file, 1) > 1
    warning("Multiple design files found in workspace directory!, using the with the latest modification date.");
    [~, idx] = max([dm_file.datenum]);
    dm_file = dm_file(idx);
end
data.designPath = fullfile(dm_file.folder, dm_file.name);
if isempty(dm_file)
    error("No designMatrix file found in workspace directory!");
end

% Give user some information about the workspace
fprintf("Workspace directory: %s\n", wp_dir);
fprintf("Number of correlation matrices: %d\n", length(corr_files));
fprintf("Number of brain regions: %d\n", ...
    height(loadData(data.brainRegionsPath)));

dm = loadData(data.designPath);
data.ifClassif = check_classification(dm(:, 2));
if data.ifClassif
    fprintf("Analysis: Classification\n");
else
    fprintf("Analysis: Regression\n");
end
fprintf("Number of covariates: %d\n", size(dm, 2) - 2);
end



