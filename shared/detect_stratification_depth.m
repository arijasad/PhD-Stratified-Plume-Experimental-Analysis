function result = detect_stratification_depth(normalisedProfiles, rowCoordinates_m, epsilon, tankHeight_m)
%DETECT_STRATIFICATION_DEPTH Apply thesis equations (2.19)-(2.20).
%   RESULT = DETECT_STRATIFICATION_DEPTH(GN, Z, EPSILON) scans each greyscale
%   profile from the lowest physical height upwards and retains the first row
%   with GN > EPSILON. GN is rows-by-frames, dimensionless and in [0,1].
%   Before calling, sum each image horizontally, subtract the first-frame
%   profile and normalise each corrected frame by its own minimum and range.
%   densityheight performs these steps and returns normalisedProfiles.
%
%   Z is physical height above the tank floor in metres, in image-row order.
%   EPSILON is one dimensionless threshold held fixed for the sequence.
%   Constant profiles have no detected boundary. No interpolation, density
%   jump or ambient-return test is applied.
%
%   RESULT = ...(..., H) also returns the depth below the ceiling, h = H-z_b.
%   Use the actual tank height H (or H_r for a reduced-height configuration).
%   Apply the detector separately at the two Table 2.4 threshold limits to
%   obtain sensitivity bounds; those limits are not repeat-run thresholds.
%
%   This four-argument greyscale API replaces the September 2026 density API.

    narginchk(3, 4);
    if nargin < 4
        tankHeight_m = [];
    end
    validateattributes(normalisedProfiles, {'numeric'}, ...
        {'real', 'finite', 'nonempty', '2d', '>=', 0, '<=', 1}, ...
        mfilename, 'normalisedProfiles');
    validateattributes(rowCoordinates_m, {'numeric'}, ...
        {'real', 'finite', 'vector', 'nonempty', 'nonnegative'}, ...
        mfilename, 'rowCoordinates_m');
    validateattributes(epsilon, {'numeric'}, ...
        {'real', 'finite', 'scalar', '>=', 0, '<=', 1}, mfilename, 'epsilon');
    if ~isempty(tankHeight_m)
        validateattributes(tankHeight_m, {'numeric'}, ...
            {'real', 'finite', 'scalar', 'positive'}, mfilename, 'tankHeight_m');
    end
    if isvector(normalisedProfiles)
        normalisedProfiles = normalisedProfiles(:);
    end
    rowCoordinates_m = rowCoordinates_m(:);
    if size(normalisedProfiles, 1) ~= numel(rowCoordinates_m) || numel(rowCoordinates_m) < 2
        error('detect_stratification_depth:Rows', ...
            'Supply at least two rows and one physical height per profile row.');
    end
    [zAscending, order] = sort(rowCoordinates_m, 'ascend');
    if any(diff(zAscending) <= 0)
        error('detect_stratification_depth:Coordinates', ...
            'rowCoordinates_m must contain unique physical heights.');
    end
    if ~isempty(tankHeight_m) && tankHeight_m < zAscending(end)
        error('detect_stratification_depth:TankHeight', ...
            'tankHeight_m cannot be below the highest retained row.');
    end
    profiles = normalisedProfiles(order, :);
    nFrames = size(profiles, 2);
    zBoundary = nan(1, nFrames);
    layerDepth = nan(1, nFrames);
    detectedRow = nan(1, nFrames);
    greyscaleAtBoundary = nan(1, nFrames);
    for frame = 1:nFrames
        profile = profiles(:, frame);
        if max(profile) == min(profile)
            continue
        end
        row = find(profile > epsilon, 1, 'first');
        if isempty(row)
            continue
        end
        zBoundary(frame) = zAscending(row);
        detectedRow(frame) = order(row);
        greyscaleAtBoundary(frame) = profile(row);
        if ~isempty(tankHeight_m)
            layerDepth(frame) = tankHeight_m - zBoundary(frame);
        end
    end
    result.z_b_m = zBoundary;
    result.h_m = layerDepth;
    result.detectedRow = detectedRow;
    result.greyscaleAtBoundary = greyscaleAtBoundary;
    result.detected = isfinite(zBoundary);
    result.rowCoordinates_m = rowCoordinates_m;
    result.scanOrder = order;
    result.epsilon = epsilon;
    result.tankHeight_m = tankHeight_m;
    result.method = 'thesis-greyscale-threshold-equation-2.19';
end
