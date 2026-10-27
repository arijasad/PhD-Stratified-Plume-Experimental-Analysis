## thesis-code-2026-10-27.7

Date: 2026-10-27
DOI: https://doi.org/10.5281/zenodo.23708559

- Pass `kappa0` explicitly into the PLIF reconstruction row solver, fixing the undefined local variable in `rtrace`.
- Keep the thesis configuration at `kappa0 = 0`; the existing regression fixture also checks nonzero background extinction without treating it as fluorescence.
- Update the PLIF methods cross-reference to Section 2.5.3.

## thesis-code-2026-10-27.6

DOI: https://doi.org/10.5281/zenodo.23701600

- Corrected the PLIF optical model so background extinction attenuates the ray without being counted as fluorescence. Calibration fitting separates background and dye attenuation. The default settings use `kappa0 = 0`, matching the thesis model.
- Updated the synthetic background case to use non-fluorescent background attenuation.

## thesis-code-2026-10-27.5

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23693977

- The standalone reconstructed-field PNG is now a masked preview, with a separate validity-mask PNG. Per-image MAT files expose `maskedReconstructedField`, `validMask` and `coverageMask` for quantitative analysis; the unmasked solver field remains available for forward projection.

## thesis-code-2026-10-27.4

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23692106

- Removed the optional physical-parameter prescribed model because its exponent was dimensionally inconsistent with the thesis model in Eqs. 3.106–3.107. Explicit coefficient prescriptions and fitted power laws are unchanged.

# Release notes

## thesis-code-2026-10-27.3

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23689541

- Increased the similarity-profile λ slider maximum to 2.5 so the circular laminar-fit value (λ = 2.22532) can be displayed.

## thesis-code-2026-10-27.2

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23688686

- Corrected `calcbfracs2a` to initialise cumulative tube area at the clipped image boundary. Reconstruction and forward projection use the same corrected overlap calculation.

## thesis-code-2026-10-27

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23679906

- The PLIF calibration fit uses row index multiplied by per-row ray-step length.
- Synthetic fluorescence is calculated from pixel concentrations and apportions absorbed ray intensity by each pixel's optical-depth contribution.
- PLIF reconstruction results include coverage and convergence masks.

## thesis-code-2026-10-27.1

Date: 2026-10-27  
DOI: https://doi.org/10.5281/zenodo.23687661

- Correct handling of zero predicted fluorescence in PLIF reconstruction; update archive links and documentation.
