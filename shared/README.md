# Shared experimental utilities

Add this folder to the MATLAB path before calling its functions. Image processing requires Image Processing Toolbox.

## Greyscale profiles and stratification depth

This workflow follows the completed thesis, Section 2.5.4, equations (2.19)-(2.20), and Table 2.4. It uses greyscale intensity to locate the boundary. The separate density-reconstruction workflow is in `chapter-02-plif`.

`densityheight.m` sums the selected columns, subtracts the first retained frame's profile, and normalises each corrected frame using its own minimum and maximum:

`G_n(z,t) = (I_c(z,t) - min_z I_c(z,t)) / (max_z I_c(z,t) - min_z I_c(z,t))`.

A constant corrected profile has no boundary. It is stored as zero with `hasContrast = false`; only floating-point subtraction roundoff is treated as zero contrast. The crop and selected columns must remain fixed throughout the sequence. By default all retained columns are used.

```matlab
config.imageFolder = imageFolder;
config.imageFiles = retainedImageNames;     % In time order, first frame included.
config.timeSeconds = retainedImageTimes_s; % Or frameIntervalSeconds.
config.referenceFrame = 1;                 % Required by the thesis method; default 1.
config.cropRows = retainedRows;
config.cropColumns = retainedColumns;
config.rowCoordinates_m = distancesBelowCeiling_m;
config.outputFolder = outputFolder;
profiles = densityheight(config);

H = 0.300; % Actual tank height; use H_r for a reduced-height configuration.
z_m = H - profiles.rowCoordinates; % Detector expects height above the floor.
thresholds = stratification_height_tolerances();
k = 3; % Example: rectangular H = 0.300 m, Q = 30 cm^3/min.
depth = detect_stratification_depth( ...
    profiles.normalisedProfiles, z_m, thresholds.Epsilon(k), H);
```

The detector scans upwards from the lowest physical height and takes the first row with `G_n > epsilon`. It returns the boundary `z_b_m`, depth below the ceiling `h_m = H-z_b_m`, original image-row index and a detection flag. A constant profile or one with no crossing returns `NaN` and `detected = false`. Use the method once a distinct stratified region has developed, as described in the thesis. There is no neighbouring-density-jump or ambient-return condition.

`rowCoordinates_m` in `densityheight` means distance below the ceiling; the detector takes height above the floor. Always make the conversion shown above. Without physical coordinates, `densityheight` returns a dimensionless image coordinate, which must not be passed to the detector as metres.

The central thresholds and sensitivity ranges are dimensionless. `EpsilonLower` and `EpsilonUpper` are the Table 2.4 range limits, not values for separate repeats. Apply them to the same profile at each sampled time:

```matlab
if isfinite(thresholds.EpsilonLower(k))
    lowerThreshold = detect_stratification_depth( ...
        profiles.normalisedProfiles, z_m, thresholds.EpsilonLower(k), H);
    upperThreshold = detect_stratification_depth( ...
        profiles.normalisedProfiles, z_m, thresholds.EpsilonUpper(k), H);
    hLower_m = upperThreshold.h_m;
    hUpper_m = lowerThreshold.h_m;
end
```

Keep a missing crossing as `NaN`; do not replace it by zero or another frame's height. For logarithmic error bars, transform the positive central and endpoint heights as in Section 2.5.6. No sensitivity range is supplied where Table 2.4 gives a dash.

With `outputFolder` set, `densityheight` writes `results.mat`, `profiles.csv`, `diagnostics.csv` and any displayed JPEG figures. The profile CSV contains `SummedImageIntensity`, `BackgroundCorrectedIntensity` and `NormalisedProfile`. Save the detector results separately with the chosen thresholds and run settings.

### Optional diagnostics

`averagingColumns` selects columns to sum. Omit it to use the full crop. Without `imageFiles`, filenames matching `imagePattern` (default `*.png`) are sorted lexically; check the order against the timestamps.

`gradientDiagnostic` reports the position beside the largest adjacent greyscale difference. `legacyDiagnostic` returns a separate sequence-scaled, time-ordered profile-value signal. Neither determines the thesis boundary. The default `fitTarget` is `'none'`; optional diagnostic fits remain available. `inspectionFrames`, `inspectionRows` and `inspectionColumns` select raw image sections.

Run the synthetic checks from the repository root:

```matlab
addpath('shared');
test_detect_stratification_depth;
test_greyscale_pipeline;
test_densityheight_time_order;
```

They cover threshold equality, flat profiles, sensitivity limits, reversed row order, Table 2.4, image input, frame-specific scaling, timestamp order and saved outputs. They do not reproduce experimental measurements without the source images and calibration.

## TIFF selection

```matlab
selectedFiles = image_saver(sourceFolder, destinationFolder, ...
    firstIndex, stride, lastIndex, 'copy');
```

The selection is `firstIndex:stride:lastIndex`, applied to case-insensitively sorted `.tif` and `.tiff` filenames. Set `lastIndex = []` to continue through the last TIFF. The default operation copies; pass `'move'` to move files. Existing destination files are checked before transfer.

## Refractive-index matching

```matlab
[Grams, Prop, NaCln, segment] = Propanolweight( ...
    saltDensity, baseFluidDensity, baseFluidVolume, ...
    saltCalibration, propanolCalibration);
```

Densities are in kg m^-3 and base-fluid volume in m^3. Supply measured calibration arrays `[density, refractive_index]` and `[refractive_index, mass_ratio_percent]` with matched rows. `Prop` is grams of propanol per 100 grams of base fluid, `Grams` is the mass to add, and `NaCln` is the interpolated salt-solution refractive index.
