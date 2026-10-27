# PLIF reconstruction

`test_forward_ray_A.m` reconstructs a dimensionless field from each fluorescence image and saves its forward projection. `validate_plif_reconstruction.m` compares that forward projection with the measured fluorescence. Both drivers use `plif_prepare.m`, `plif_read_image.m` and `plif_reconstruct.m`.

Use MATLAB with Image Processing Toolbox and a release supporting `tiledlayout` and `exportgraphics`. From the repository root:

```matlab
addpath('chapter-02-plif');
cfg = plif_settings();
% Set the paths, image list, calibration and optical geometry for this run.
outputs = test_forward_ray_A(cfg);
summary = validate_plif_reconstruction(cfg);
```

`plif_settings.m` is a template. Its unset fields must be filled with measurements from the data set. In particular:

| Field | Input |
| --- | --- |
| `inputFolder`, `outputFolder`, `calibrationFile`, `imageFiles` | Source folder, destination, calibration image filename and ordered measurement filenames. |
| `cropRect`, `resizeScale` | Common crop `[x y width height]` in one-based source-image pixels (`[]` uses the full image) and resizing factor. |
| `intensityDivisor`, `calibrationScaleFactor` | Raw intensity corresponding to 1, and multiplier placing calibration and measurement images on a common scale. |
| `geometry.sourceCoordinates`, `geometry.wallThickness`, `geometry.unseenFluidDepth` | Source position `[horizontal vertical]` and distances in cropped, unresized image pixels. |
| `geometry.refractiveIndices`, `geometry.fanHalfAngleDegrees` | Refractive indices `[air wall fluid]` and source fan half-angle in degrees. |
| `calibrationField`, `kappa0`, `kappa1`, `attenuationFitRows` | Known field on the resized grid, non-fluorescent background attenuation per resized row (0 for the thesis model), optional field-dependent attenuation coefficient (`[]` fits it), and inclusive resized row range for that fit. |
| `forwardIncidentIntensity` | `'calibration'`, a nonnegative scalar or one value per image column for `test_forward_ray_A`. Validation uses calibration-derived values. |
| `signalThresholdFraction`, `figureResolution`, `overwrite` | Validation signal region, figure dpi and output replacement. |

`calibrationField` accepts an array or a function handle called with `[rows cols]`; its values must be in `[0,1]`. Apply the same crop to calibration and measurement images. Keep the completed settings with the source data.

`test_forward_ray_A` returns one row per image containing the paths to the MAT result, four-panel PNG, masked field-preview PNG and validity-mask PNG. The field preview is for visual inspection. For quantitative use, load `maskedReconstructedField` and `validMask` from the MAT file; `result.reconstructedField` retains the unmasked solver field for forward projection. The mask PNG is named `<image>_valid_mask.png` in `outputFolder/reconstructed_fields`.

`validate_plif_reconstruction` saves per-image MAT files with `maskedReconstructedField`, `validMask` and `coverageMask`, three-panel PNGs, and `PLIF_validation_summary.csv` with residuals and correlation for the full image and selected signal region. This compares reconstruction and projection under the same optical model; it does not independently calibrate density.

## Convergence checks

The solver checks illuminated pixels even when predicted fluorescence is zero and retains a finite derivative at zero optical depth. It keeps the concentration bounds, relative tolerance and 20-update limit; the validity mask excludes uncovered or unconverged pixels.

Run the synthetic checks with MATLAB and Image Processing Toolbox:

```matlab
addpath('chapter-02-plif');
test_plif_convergence;
```

These synthetic Beer–Lambert checks require no experimental data.


## Optical model and thesis settings

The thesis model in Section 2.5.3 uses attenuation proportional to dye concentration and has no additive background-extinction term. Set `kappa0 = 0` to reproduce that model. The generic solver also accepts nonzero `kappa0` as non-fluorescent background attenuation: it contributes to ray attenuation, but not to emitted fluorescence. When `kappa1` is fitted, the calibration slope is separated into dye and background contributions.

The author confirms that the thesis reconstruction used the thesis model (`kappa0 = 0`). The supplied settings file selects that configuration. The generic nonzero option is retained for cases with non-fluorescent background attenuation.
