A 4D Flow Processing Module to Compute the Pulsatility Index Transmission Coefficient (PITC) (Based on [Quantitative Velocity Tool (QVT)](https://github.com/uwmri/QVT))
=========
## Introduction ##
This library was developed to measure Pulsatility Transmission ($p_{tc}$), some extra functionality has been added to extract time continuous boundary conditions which can be used to drive flow in cerebral hemodynamic models as well. 
An example extrapolation of $p_{tc}$ is shown below.

![TestSizeCoarse400](https://github.com/ABI-Animus-Laboratory/QVTplus/assets/108192400/0f48fa5a-f434-4e9f-852f-3f3d02526581)

Major changes from QVT include the development of a flow quality metric ($Q$) which allows the automatic extraction of high quality flow from each cerebral vessel, or to drive weighted optimisation using all 4D flow data. Can also use the flow profile as input into patient specific modelling or when weighting the measurement of $p_{tc}$.

## Installation ##
Requires MATLAB version > 2018
### Dependencies ###
**Required Matlab Add-Ons** \
Image Processing Toolbox (for medfilt3) \
Curve Fitting Toolbox (for csaps) \
Statistics and Machine Learning Toolbox (for kmeans)
### Compatibility ###
Currently, .hdf5 and .dat formatting is not supported with the PITC measurement and only loading DICOMS allow this functionality. Resolutions can now be anisotropic.
* If using Matlab 2023a and beyond, the xml write will not work, so be careful if you are using the regular QVT save function to store flow data in the regular excel.  
## Usage
Run paramMap as per QVT, and follow standard background correction. If you are loading DICOMS, the following interactive table will load once the data  has been processed, fill in the table appropriately. For the $pi_{tc}$ analysis, a selected number of cells must be filled (P1:P4) (refer to Figure below for numbering):
 * **P1:** Each root vessel value must be input (ICAs and BA). Typically, only one value is needed in each root.
 * **P2:** If, for instance, the carotid siphon folds on itself and causes non-physiological branches in QVT, a connected vessel number array can be entered.
 * **P3:** In the ``Exclude'' row, communicating arteries must be included; otherwise, the algorithm will connect vessels from the ICA to the PCAs. Other vessels can be inputted (as an array format) to stop the connectivity algorithm if desired. 
 * **P4:** In the case where the ACAs are close together, incorrect hemispheric crossovers can occur in the algorithm. To avoid this, the left and right vessel numbers can be supplied for the ACAs, respectively.
 * **P5:** Optionally, for selected CoW vessels, the vessel number and the centreline number can be entered; this can be used to output local $p_{\mathrm{pi}}$ for other analyses, but it is not necessary to initialise the $p_{\mathrm{tf}}$ algorithm.

![Figure2_Interaction](https://github.com/ABI-Animus-Laboratory/QVTplus/assets/108192400/c52a5d6a-3cee-49e1-9559-9ca4bcfbbbd4)

**NOTE:** It you wish to automatically process root dependant damping factor as well, fill out the entire table for all vessels including label numbers.

In functions under wrappers, run "main.m" which will ask you to point to where the subject data is saved. Currently, the library supports batching so long as the data is organised in a BIDS style, ie, QVT.mats are saved in \derivatives\QVT\sub-001,sub--2, etc. Successful organisation  will load your QVT data and labels and begin processing $pi_{tc}$. Eventually, an interactive figure will open which directs you to input a search distance for vessels, appropriately move the slider under the entire vasculature is corrected. 

![example](https://github.com/ABI-Animus-Laboratory/QVTplus/assets/108192400/2a2fc2c1-38bb-49a4-b477-0829f57751e7)

**NOTE:** The slider must be moved at least once.
**NOTE:** Be conservative with the distance as large distances may cause erroneous connections. If the slider is not working correctly, please contact below as this is in development as we get more 4D flow cases.

Once a search distance has been input, click done and the rest of the measurements will proceed automatically using weights by first connecting the branches and then assigning pulsatility distance (see manuscript for details). The results will then save to the derivatives subject directory.

**Note:** Ongoing functionality is being added including efforts for reproducability by desigining a parameters structure fed into all algorithms. This includes optionality to plot results as they are processed similar to the manuscript plots for each subject, these images will save to respective directories. 

**Note:** There is also support for BIDS formatted datasets provided subject data is stored BIDS_dir\derivatives\QVT\sub-001, sub-002 etc. Inputing just BIDS_dir, the entire directory can be run.

### Acknowledging ### 
Standing on the shoulders of giants, this module would not be possible without the original creators work. Please properly cite and acknowledge the following publications:

- [Roberts GS, Hoffman CA, Rivera-Rivera LA, Berman SE, Eisenmenger LB, Wieben O. Automated hemodynamic assessment for cranial 4D flow MRI. Magn Reson Imaging. 2022 Dec 26:S0730-725X(22)00231-4. doi: 10.1016/j.mri.2022.12.016. Epub ahead of print. PMID: 36581214](https://pubmed.ncbi.nlm.nih.gov/36581214/)
- [Schrauben E, Wahlin A, Ambarki K, Spaak E, Malm J, Wieben O, Eklund A. (2015). Fast 4D flow MRI intracranial segmentation and quantification in tortuous arteries. J Magn Reson Imaging, 42(5), 1458-1464. doi:10.1002/jmri.24900](https://pubmed.ncbi.nlm.nih.gov/25847621/)

And our own
- [Dempsey, S., Safaei, S., Holdsworth, S.J. et al. Measuring global cerebrovascular pulsatility transmission using 4D flow MRI. Sci Rep 14, 12604 (2024). https://doi.org/10.1038/s41598-024-63312-4](https://www.nature.com/articles/s41598-024-63312-4)

### Contact ### 
Please contact Sergio Dempsey for feature requests or if you have a dataset that is not loading correctly and that functionality will be added within a reasonable timeframe.

**Sergio Dempsey**: sdem348@aucklanduni.ac.nz
