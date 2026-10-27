# Release notes

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
