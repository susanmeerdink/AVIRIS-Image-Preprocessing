# AVIRIS-Image-Preprocessing
Project related to various AVIRIS pre processing functions
Susan Meerdink

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