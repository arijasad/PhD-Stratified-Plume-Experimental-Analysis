# Experimental analysis code

MATLAB scripts accompanying Arij Asad's PhD thesis, *Mixing behaviour of plumes* (University of Bristol).

| Folder | Entry points |
| --- | --- |
| [chapter-02-plif](chapter-02-plif) | `test_forward_ray_A.m`, `validate_plif_reconstruction.m` |
| [chapter-03-rectangular-quiescent](chapter-03-rectangular-quiescent) | `auto_vorticity_length.m` |
| [shared](shared) | `densityheight.m`, `detect_stratification_depth.m`, `stratification_height_tolerances.m`, `image_saver.m`, `Propanolweight.m` |

Each folder has a README with the required inputs and saved outputs. Add the relevant folder to the MATLAB path, supply the settings for the image sequence, and run its entry point. The PLIF drivers also require the supporting functions alongside them; `auto_vorticity_length.m` uses `auto_vorticity_length_config.m`.

MATLAB and Image Processing Toolbox are required for image processing. Interactive image review requires a graphical MATLAB session.

Source images, empirical calibrations and completed run configurations are not included. Supply the image selections, timing, geometry, crop and calibration values from the corresponding data set.

## Stratification-depth method

The current code follows the greyscale method in thesis Section 2.5.4 and Table 2.4: first-frame background subtraction, normalisation within each frame, then the first row above a fixed dimensionless threshold when scanning upwards. Depth is measured below the ceiling. See [the shared-function guide](shared/README.md) for the complete workflow and sensitivity bounds.

This is the master version of the software accompanying the thesis.

## Density-reconstruction method

The density-reconstruction workflow in `chapter-02-plif` adapts Horne-Jones, J. T., Glinnan, D. J., Lawrie, A. G. W. and Williams, R. J. R. (2026), *Controlled accelerations for Rayleigh–Taylor instability*, Experiments in Fluids 67, 96, Section 3.2, equations (16)-(18). [doi:10.1007/s00348-026-04249-4](https://doi.org/10.1007/s00348-026-04249-4).

This citation applies to density reconstruction. The greyscale boundary measurement is described in the thesis.

## Citation and licence

Cite *Stratified plume experimental analysis: Thesis code*, version `thesis-code-2026-10-27.4` ([doi:10.5281/zenodo.23692106](https://doi.org/10.5281/zenodo.23692106)). The all-versions DOI is [10.5281/zenodo.23545911](https://doi.org/10.5281/zenodo.23545911). Citation metadata are provided in [CITATION.cff](CITATION.cff).

The source code is available under the [MIT licence](LICENSE). Supporting documentation is provided in the folder READMEs under CC BY 4.0.
