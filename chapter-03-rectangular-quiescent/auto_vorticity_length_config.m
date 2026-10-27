function cfg = auto_vorticity_length_config()
%AUTO_VORTICITY_LENGTH_CONFIG Settings for image-edge measurements.
%   Fill the empty required fields using the image sequence being analysed.
%   Pixel positions are one-based. Lengths are measured within the crop.

cfg.inputFolder = '';                 % Folder containing the source images
cfg.outputFolder = '';                % A separate folder for the results
cfg.imagePattern = '*.png';
cfg.imageOrder = [];                   % []: natural filename order
% A custom order is a permutation of the lexically sorted filenames.
cfg.framePositions = [];               % []: analyse the complete ordered sequence
cfg.cropRect = [];                     % Required [x y width height], in pixels
cfg.bandRows = [];                     % Required [first last] rows within the crop
cfg.referenceWidthPx = [];             % Required scale for normalised lengths

% Supply times for every ordered image, before selecting frames.
% The plotted coordinate is (timeValues - timeOrigin)/timeScale.
% Use consistent time units. Frame positions may also be used explicitly.
cfg.timeValues = [];
cfg.timeOrigin = [];
cfg.timeScale = [];

cfg.detector.smoothWindow = [];        % Required odd smoothing window, in pixels
cfg.detector.selectionMode = 'outermost'; % 'outermost' or 'best-pair'
cfg.detector.centreX = [];             % []: midpoint of the crop
cfg.detector.minWidthPx = [];          % Required minimum edge separation
cfg.detector.maxWidthPx = [];          % []: full width of the crop
cfg.detector.centreGapPx = [];         % Required gap excluded about the centre
cfg.detector.polarity = 'either';      % 'bright', 'dark' or 'either'
cfg.detector.minContrast = [];         % Required fraction of the intensity scale
cfg.detector.noiseMultiplier = 4;
cfg.detector.minPairRatio = 1.15;       % Minimum score ratio in 'best-pair' mode
cfg.detector.maxCandidatesPerSide = 10; % Candidate limit in 'best-pair' mode

cfg.showDiagnostics = true;
cfg.saveDiagnostics = true;
cfg.reviewEachFrame = true;            % Confirm, replace or skip each measurement
cfg.enablePlotEditor = true;           % Remove points/curves, undo and export
% Closing the review dialog saves the measurements already confirmed.
% Plot edits change only the displayed comparison; curves are not refitted.

cfg.powerMode = 'fit';                 % 'fit' or 'prescribed'
cfg.earlyFitPositions = [];            % Positions in the selected sequence; []: no fit
cfg.powerFitPositions = [];            % Positions in the selected sequence; []: all

% A prescribed curve uses explicit dimensionless coordinates:
% L = amplitude*t^exponent.
cfg.model.kind = 'coefficients';       % Use explicit coefficients
cfg.model.amplitude = [];              % Required only for a prescribed curve
cfg.model.exponent = [];               % Required for a prescribed curve
end
