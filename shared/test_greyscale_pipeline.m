function test_greyscale_pipeline
%TEST_GREYSCALE_PIPELINE Exercise image input through the thesis boundary rule.
    folder = tempname;
    mkdir(folder);
    cleanup = onCleanup(@() rmdir(folder, 's')); %#ok<NASGU>
    background = [5; 10; 15; 20; 25];
    signal = [40; 20; 8; 4; 0];
    frames = [background, background + signal, background + 4*signal, ...
        background + 3*ones(5,1)];
    names = cell(1, size(frames,2));
    for i = 1:size(frames,2)
        names{i} = sprintf('%02d.png', i);
        imwrite(uint8(repmat(frames(:,i),1,3)), fullfile(folder,names{i}));
    end
    cfg.imageFolder = folder;
    cfg.imageFiles = names;
    cfg.timeSeconds = [0, 2, 7, 10];
    cfg.rowCoordinates_m = (0:4)' * 0.001; % Distance below ceiling.
    cfg.makePlots = false;
    cfg.outputFolder = fullfile(folder, 'results');
    r = densityheight(cfg);
    expected = [1; .5; .2; .1; 0];
    assert(max(abs(r.normalisedProfiles(:,2) - expected)) < 1e-14);
    assert(max(abs(r.normalisedProfiles(:,3) - expected)) < 1e-14);
    assert(all(r.normalisedProfiles(:,1) == 0));
    assert(~r.hasContrast(4) && all(r.normalisedProfiles(:,4) == 0));
    assert(isequal(r.timeSeconds, cfg.timeSeconds));
    assert(max(abs(r.rawProfiles(:,2) - 3*frames(:,2)/255)) < 1e-14);
    assert(max(abs(r.correctedProfiles(:,2) - 3*signal/255)) < 1e-14);
    z = .004 - r.rowCoordinates;
    depth = detect_stratification_depth(r.normalisedProfiles(:,1:3), z, .125, .004);
    assert(~depth.detected(1));
    assert(max(abs(depth.h_m(2:3) - .002)) < 1e-15);
    assert(isequal(depth.detectedRow(2:3), [3,3]));

    % The same frame keeps its scale when a brighter later frame is omitted.
    cfg.imageFiles = names(1:2);
    cfg.timeSeconds = [0, 2];
    cfg.outputFolder = '';
    shorter = densityheight(cfg);
    assert(isequal(shorter.normalisedProfiles(:,2), r.normalisedProfiles(:,2)));

    % Identical images are valid: no contrast, no boundary and no division by zero.
    cfg.imageFiles = names([1,1]);
    flat = densityheight(cfg);
    assert(~any(flat.hasContrast) && all(flat.normalisedProfiles(:) == 0));
    depth = detect_stratification_depth(flat.normalisedProfiles, z, .125, .004);
    assert(~any(depth.detected));
    cfg.referenceFrame = 2;
    rejected = false;
    try
        densityheight(cfg);
    catch exception
        rejected = strcmp(exception.identifier, 'densityheight:ReferenceFrame');
    end
    assert(rejected);
    saved = load(fullfile(folder, 'results', 'results.mat'));
    assert(isequal(saved.results.normalisedProfiles, r.normalisedProfiles));
    tab = readtable(fullfile(folder, 'results', 'profiles.csv'));
    assert(ismember('BackgroundCorrectedIntensity', tab.Properties.VariableNames));
    fprintf('Image-to-greyscale-boundary and saved-output checks passed.\n');
end
