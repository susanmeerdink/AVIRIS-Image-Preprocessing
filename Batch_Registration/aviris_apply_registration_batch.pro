PRO aviris_apply_registration_batch
;This code does image to image registration using GCPs collected
;
;Susan Meerdink
;2/2/17

;-------------------------------------------------------------------------------------
;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;

;;; INPUTS ;;;
main_path = 'F:\Image-To-Image-Registration\AVIRIS\' ; Set directory that holds all flightlines
;fl_list = ['FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] ;Create the list of folders
fl_list = ['FL02'] ;Create the list of folders
basemap = 'F:\Imagery\NAIP Imagery\Santa Barbara\SBbox_18m_flightline_1_to_11_PA' ;Set to basemap for GCPs

;;; ADDITIONAL VARIABLES FOR MEMORY PURPOSES ;;;
outImage = MAKE_ARRAY([800, 250, 10000], TYPE = 2, VALUE = 0) ;Create empty array that is large for memory allocation purposes
outImage = 0 ;Set to zero for memory purposes

;;; OPEN BASEFILE
ENVI_open_file, basemap, R_FID = fidBase ;Open the file

;;; PROCESSING ;;;
FOREACH single_flightline, fl_list DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
  flightline_path = main_path + single_flightline + '\' ; Set path for flightline that is being processed
  cd, flightline_path ;Change Directory to flightline that is being processed
  gcpFile = file_search('*.pts') ;Get the GCPs for this flightline
  gcp = read_ascii(gcpFile,TEMPLATE = ASCII_TEMPLATE(gcpFile))
  print, size(gcp)
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search('*_rot35') ;Get list of all images in flightline that have been rotated
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    print, single_image
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header,text, or GCP file proceed
      ;;; BASIC FILE INFO ;;;
      print, 'Processing: ' + single_image
      ENVI_open_file, single_image, R_FID = fidOrg ;Open the file
      ENVI_file_query, fidOrg,$ ;Get information about file
        DIMS = raster_dims,$ ;The dimensions of the image
        NB = raster_bands,$ ;Number of bands in image
        BNAMES = raster_band_names,$ ;Band names of image
        NS = raster_samples, $ ;Number of Samples
        NL = raster_lines,$ ;Number of lines
        WL = raster_wl,$ ;WAvelengths of image
        DATA_TYPE = raster_data_type, $ ;File data types
        SNAME = raster_file_name, $ ;contains the full name of the file (including path)
        BBL = raster_bbl ;Bad Band List
      map_info_raster = envi_get_map_info(FID = fidRaster) ;Get Raster map info
      ;;; DONE BASIC FILE INFO ;;;  
      
      ;;; REGISTRATION ;;;
      outputName = flightline_path + raster_file_name + '_Reg' ;Set output name for registration image
      ENVI_DOIT,'ENVI_REGISTER_DOIT', $
        B_FID = fidBase, $ ;keyword to specify the file ID for the base file
        PTS = gcpFile, $ ; keyword to specify an array of double-precision values representing the x and y positions of the base and warp tie points
        W_FID = fidIn, $ ;keyword to specify the file ID for the warp file
        W_POS = INDGEN(raster_bands), $ ;keyword to specify an array of band positions for the warp image indicating the band numbers on which to perform the operation
        W_DIMS = raster_dims, $ ;specify the spatial dimensions of the warp image (W_FID) on which to perform the operation
        OUT_NAME = outputName, $ ;keyword to specify a string with the output filename for the resulting data
        R_FID = fidOut ;returned FID
        
     ENDIF ;End of if statement to select image files (not header, text, or GCP files)
  ENDFOREACH ;End of loop through images in a flightline
ENDFOREACH ;End of loop through flightline
END ;END of file
