function set_seed(seed)
    % Get MATLAB release information
    releaseInfo = matlabRelease();
    releaseName = char(releaseInfo.Release);
    
    % Extract the year and letter from the release name
    releaseYear = str2double(releaseName(2:5));
    releaseLetter = releaseName(6);
    
    % Check if the release is higher than R2023b
    if releaseYear > 2023 || (releaseYear == 2023 && releaseLetter >= 'b')
        % MATLAB release is higher than R2023b
        rng(seed, 'twister');
    else
        % MATLAB release is R2023b or lower
        rng(seed);
    end
end 