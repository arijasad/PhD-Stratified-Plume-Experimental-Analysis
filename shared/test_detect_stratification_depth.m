function test_detect_stratification_depth
%TEST_DETECT_STRATIFICATION_DEPTH Synthetic checks of thesis equation (2.19).
    z = (0:4)' * 0.001;
    p = [0; 0.125; 0.25; 0.5; 1];
    r = detect_stratification_depth(p, z, 0.125, 0.004);
    assert(r.detected && r.detectedRow == 3);
    assert(abs(r.z_b_m - 0.002) < 1e-15);
    assert(abs(r.h_m - 0.002) < 1e-15);
    assert(r.greyscaleAtBoundary == 0.25);

    % A return to zero above the first crossing does not reject it.
    r = detect_stratification_depth([0; 0.25; 0; 0.5; 1], z, 0.125);
    assert(r.detectedRow == 2 && abs(r.z_b_m - 0.001) < 1e-15);
    assert(isnan(r.h_m));

    % Physical heights determine scan order, including descending image rows.
    r = detect_stratification_depth(flipud(p), flipud(z), 0.125, 0.004);
    assert(r.detectedRow == 3 && abs(r.h_m - 0.002) < 1e-15);
    r = detect_stratification_depth(p, z, 0.5, 0.004);
    assert(r.detectedRow == 5 && r.h_m == 0);

    % Flat, below-threshold and threshold-equality profiles have no boundary.
    r = detect_stratification_depth([zeros(5,1), ones(5,1), p], z, 1, 0.004);
    assert(~any(r.detected) && all(isnan(r.z_b_m)) && all(isnan(r.h_m)));
    r = detect_stratification_depth(ones(5,1), z, 0.125);
    assert(~r.detected);

    low = detect_stratification_depth(p, z, 0.1, 0.004);
    high = detect_stratification_depth(p, z, 0.3, 0.004);
    assert(abs(low.h_m - 0.003) < 1e-15);
    assert(abs(high.h_m - 0.001) < 1e-15);

    % Reject dimensional density inputs to the greyscale detector.
    rejected = false;
    try
        detect_stratification_depth(1000-p, z, 1000, 0.125);
    catch
        rejected = true;
    end
    assert(rejected);
    rejected = false;
    try
        detect_stratification_depth(p, [0; 0; .002; .003; .004], 0.125);
    catch exception
        rejected = strcmp(exception.identifier, 'detect_stratification_depth:Coordinates');
    end
    assert(rejected);

    % Check central values and sensitivity ranges against thesis Table 2.4.
    t = stratification_height_tolerances();
    expected = [ ...
        .050 NaN NaN; .090 NaN NaN; .040 .010 .070; .080 .030 .130; ...
        .065 .020 .110; .075 .045 .105; .085 .040 .130; .065 .025 .105; ...
        .080 NaN NaN; .115 .035 .195; .085 .020 .150; .0775 .050 .105];
    assert(isequaln(t{:,3:5}, expected));
    assert(isequal(t.Flow_cm3_min, [10;20;30;40;70;30;70;20;40;80;20;50]));
    ranged = isfinite(t.EpsilonLower);
    assert(max(abs(t.Epsilon(ranged) - ...
        (t.EpsilonLower(ranged) + t.EpsilonUpper(ranged))/2)) < 1e-15);
    fprintf('Greyscale boundary, sensitivity and Table 2.4 checks passed.\n');
end
