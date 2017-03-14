# AVIRIS-Image-Preprocessing
Project related to various AVIRIS pre processing functions
Susan Meerdink

## Summary
In order to get AVIRIS Images ready for analysis there are 6 steps images must go through:
1. Masking
	* Images from JPL do not have borders with a value of 0. Instead the border has residual values from atmospheric correction. This code replaces the borders with a value of 0.
2. Resize Plus Border
	* This code outputs images that will be inputs for Alex Koltunov's Image to Image Registration code.
3. Coregistration
	* This code is not included in this github repository 
4. Rotate 35 degrees
	* This code rotates the outputs from the coregistration code by 35 degrees to prepare for registration
5. Register Images
	* This code applies final registration (using GCPs) to the image
6. Apply Spectral Correction & Update Metadata
	* This code applies a multiplication factor to the imagery to correct for differences in atmospheric correction between image dates. In addition, this code makes the metadata uniform between dates.
	
## Masking
Images from JPL do not have borders with a value of 0. Instead the border has residual values from atmospheric correction. This code replaces the borders with a value of 0.
This code utlizes the masking_with_tiles function to mask out the margins.
This code uses the function to create and apply a mask for AVIRIS imagery,specifically the HyspIRI simulated dataset which does not contain a single value in the margin, but instead spectrum that is residue
from atmospheric correction processes.
It outputs an ENVI file in the same directory with the ending 'mask'
This code uses new ENVI (NOT CLASSIC)

## Resize Plus Borders
For AVIRIS imagery to be ready for image-to-image registration the following steps must be followed:

1. Move the new files to a flightline specific folder (currently in R:\Image-To-Image Registration\)
	Miscellaneous > moving_files.py
2. Rename files so that they start with the flightline number and add extra zero for base file.
	Miscellaneous > rename_files.py
3. Crop base file to area of interest in ENVI (by hand no code)
4. Some AVIRIS imagery does not have the border set to zero, run code to ensure a zero value border
	Batch_Masking > aviris_create_apply_mask_batch.pro
5. Run resizing code that adds borders. 
	Batch_Resize_Plus_Borders > resize_plus_borders_master.pro
6. Run renaming code to add .dat onto file name
	Miscellaneous > rename_files_with_dat.py
NOTES:
* Images must have same number of bands and be in zero rotation (aka North to South - NO angle).	
* Files will end in _ResizePlusBorder.dat 
* The resulting images has a border around outside of 10 pixels and images have the same number of samples and lines.
* add_borders_aviris.pro: This code just adds a border of 10 pixels around outside of image. No other resizing is conducted. This was used for Base Images.

## Coregistration
* This code is not included in this github repository. It was written by Alex Koltunov and run by Zach Tane
* Files will end in _fr_#_REGlinear or _fr_#_REGaffine.dat 
* These referred to the correction that was applied to line up images to the base date image.
* There are two steps to the Coregistration process, where step one you have to analyze intermediate products to determine the best band and method. This IDL Program was written to help faciliate this process: analyze_registration_intermediate_products.pro

## Rotate 35 Degrees
This code uses new ENVI (NOT CLASSIC)
Code is not working! 
Get error: POLY_2D: Expression must be an array in this context: I.
Rotating images using ENVI Queue Manager

## Apply Spectral Correction & Update Metadata
* Atmospheric correction on AVIRIS images varies quite a bit from date to date for the HyspIRI Airborne Campaign. Using the Storke Post Office ASD spectra and spectra from FL06 across all dates, I have derived a multiplying factor for each date to correct for spectral differences. See file Determining AVIRIS Correction Factors.xlsx for calculations 
* This code will also updated the band names, wavelengths, and bad band list in all metadata.
* Output image will have all Bad Bands with a value of 0
