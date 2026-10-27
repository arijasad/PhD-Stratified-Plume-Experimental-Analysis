function test_plif_convergence()
%TEST_PLIF_CONVERGENCE Regression checks through the public reconstruction API.
%   Requires MATLAB and Image Processing Toolbox. No camera, controller,
%   experimental images or external files are used.
%
%   The one-pixel fixture contains an entire narrow light tube. Its centre
%   travels one pixel and its width increases from 0.2 to 0.4 pixels. The
%   mean width is therefore 0.3. Calibrating with uniform chi = 1 and the
%   intensity below gives incident tube intensity 1. Beer--Lambert absorption
%   then supplies an independent oracle: F(chi) = 1-exp(-0.1*chi).

    [cfg, calibration] = singlePixelFixture();

    % This valid faint signal makes the old first Newton step hit chi = 0.
    % A zero prediction must neither trap the iteration nor certify success.
    measured = 0.001;
    expected = -log1p(-measured) / cfg.kappa1;
    result = plif_reconstruct(measured, calibration, cfg);
    assertAccepted(result, measured, expected, 'faint positive signal');
    assert(result.reconstructedField > 0, ...
        'A positive fluorescence measurement was replaced by a false zero.');

    % A genuinely dark, illuminated pixel is covered, valid and exactly zero.
    result = plif_reconstruct(0, calibration, cfg);
    assertAccepted(result, 0, 0, 'covered dark pixel');
    assert(result.reconstructedField == 0 && result.syntheticFluorescence == 0, ...
        'A covered dark pixel must reconstruct and project to zero.');

    % There is no physical solution within 0 <= chi <= 1 for this signal.
    measured = 0.2;
    maximumSignal = -expm1(-cfg.kappa1);
    result = plif_reconstruct(measured, calibration, cfg);
    assert(result.coverageMask, 'The saturated test pixel must be covered.');
    assert(result.reconstructedField == 1, ...
        'An unattainable high signal should reach the upper concentration bound.');
    assert(isequal(result.unconvergedRows, 1) && ~result.validMask, ...
        'Reaching the concentration bound must not imply convergence.');
    assert(isnan(result.maskedReconstructedField), ...
        'An unconverged reconstruction must be excluded by the validity mask.');
    assert(abs(result.syntheticFluorescence - maximumSignal) < 1e-12, ...
        'The projected saturated field must match Beer--Lambert absorption.');

    % Ordinary interior solutions must retain their accuracy after the fix.
    expected = 0.4;
    measured = -expm1(-cfg.kappa1 * expected);
    result = plif_reconstruct(measured, calibration, cfg);
    assertAccepted(result, measured, expected, 'ordinary interior signal');

    % With two image columns the same narrow fan still lies entirely inside
    % column 1. Column 2 has no optical coverage, even though both are dark.
    cfg.calibrationField = ones(1, 2);
    result = plif_reconstruct(zeros(1, 2), ones(1, 2), cfg);
    assert(isequal(result.coverageMask, [true false]), ...
        'Coverage must describe illumination geometry, not nonzero fluorescence.');
    assert(isequal(result.validMask, [true false]) && isempty(result.unconvergedRows), ...
        'The covered dark pixel must be valid and the uncovered pixel invalid.');
    assert(result.maskedReconstructedField(1) == 0 && ...
        isnan(result.maskedReconstructedField(2)), ...
        'The masked field must distinguish a measured zero from no coverage.');
    assert(all(result.syntheticFluorescence == 0), ...
        'The dark fixture must have zero projected fluorescence.');

    % Optically thin absorption must not be lost to subtractive cancellation.
    [cfg, ~] = singlePixelFixture();
    cfg.kappa1 = 1e-12;
    calibration = -expm1(-cfg.kappa1) / 0.3;
    expected = 0.02;
    measured = -expm1(-cfg.kappa1 * expected);
    result = plif_reconstruct(measured, calibration, cfg);
    assertAccepted(result, measured, expected, 'optically thin positive signal');

    % Positive background absorption makes an exactly black covered pixel
    % impossible even at chi = 0. It must remain marked unconverged.
    [cfg, ~] = singlePixelFixture();
    cfg.kappa0 = 0.02;
    calibration = -expm1(-(cfg.kappa0 + cfg.kappa1)) / 0.3;
    result = plif_reconstruct(0, calibration, cfg);
    assert(result.coverageMask && result.reconstructedField == 0, ...
        'The background-absorption case must reach the lower bound in a covered pixel.');
    assert(isequal(result.unconvergedRows, 1) && ~result.validMask && ...
        isnan(result.maskedReconstructedField), ...
        'An unattainable dark signal must not be accepted as converged.');
    assert(abs(result.syntheticFluorescence + expm1(-cfg.kappa0)) < 1e-12, ...
        'The lower-bound projection must retain the background absorption.');

    % Two successive complete tube segments also test propagation of the
    % accepted first-row attenuation into the next reconstruction row.
    [cfg, ~] = singlePixelFixture();
    cfg.calibrationField = ones(2, 1);
    segmentAbsorption = -expm1(-cfg.kappa1);
    calibration = [segmentAbsorption / 0.3; ...
        exp(-cfg.kappa1) * segmentAbsorption / 0.5];
    expected = [-log1p(-0.001) / cfg.kappa1; 0.7];
    measured = [0.001; ...
        exp(-cfg.kappa1 * expected(1)) * -expm1(-cfg.kappa1 * expected(2))];
    result = plif_reconstruct(measured, calibration, cfg);
    assert(all(result.coverageMask) && all(result.validMask) && ...
        isempty(result.unconvergedRows), ...
        'Both successive illuminated tube segments must converge.');
    % A 1e-6 relative fluorescence tolerance permits about 7e-7 absolute
    % concentration error at chi = 0.7; retain that tolerance in the oracle.
    assert(max(abs(result.reconstructedField - expected)) < 1e-6, ...
        'The second row did not use the first row''s accepted attenuation.');
    assert(all(abs(result.syntheticFluorescence - measured) <= 1e-6 * measured), ...
        'The returned two-row field does not reproduce its measured fluorescence.');
    assert(abs(sum(result.syntheticFluorescence) - ...
        -expm1(-cfg.kappa1 * sum(result.reconstructedField))) < 1e-12, ...
        'The two-row projection must conserve incident minus transmitted light.');

    fprintf('PASS: PLIF convergence regression checks (8 cases).\n');
end

function [cfg, calibration] = singlePixelFixture()
    cfg = plif_settings();
    cfg.resizeScale = 1;
    cfg.intensityDivisor = 1;
    cfg.calibrationScaleFactor = 1;
    cfg.geometry.sourceCoordinates = [0.5 -1];
    cfg.geometry.refractiveIndices = [1 1 1];
    cfg.geometry.wallThickness = 0;
    cfg.geometry.unseenFluidDepth = 0;
    cfg.geometry.fanHalfAngleDegrees = atan(0.1) * 180 / pi;
    cfg.calibrationField = 1;
    cfg.kappa0 = 0;
    cfg.kappa1 = 0.1;
    cfg.forwardIncidentIntensity = 'calibration';
    calibration = -expm1(-cfg.kappa1) / 0.3;
end

function assertAccepted(result, measured, expected, description)
    assert(result.coverageMask && result.validMask && isempty(result.unconvergedRows), ...
        'The %s was not accepted as a covered, converged pixel.', description);
    assert(abs(result.incidentIntensity - 1) < 1e-12, ...
        'The analytic fixture must calibrate to unit incident intensity.');
    assert(abs(result.reconstructedField - expected) < 1e-7, ...
        'The %s disagrees with the analytic Beer--Lambert concentration.', description);
    assert(abs(result.maskedReconstructedField - expected) < 1e-7, ...
        'The %s is missing or incorrect in the valid output.', description);
    assert(abs(result.syntheticFluorescence - measured) <= ...
        1e-6 * max(abs(measured), eps), ...
        'The accepted %s does not reproduce its measured fluorescence.', description);
end
