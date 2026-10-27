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
