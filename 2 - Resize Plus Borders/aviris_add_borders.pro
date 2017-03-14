PRO add_borders_aviris
;Created for images from the HyspIRI campaign (same area flown three times in 2013 and 2014).
;Images must have same number of bands and be in zero rotation (aka North to South - NO angle).
;Some files were not successfully resized using resize_plus_borders_aviris.pro due to various file issues.
;This Code reads in manually cropped images (using ENVI) and adds a 10 sample/line border to all sides the flightline that has a value of zero. 
;The resulting files will be a BSQ image that has the same number of samples and lines for all files in the flightline folder.
;This code outputs images that will be inputs for Alex Koltunov's Image to Image Registration code.
; Susan Meerdink
; Created 5/3/2016
; 
; --------------------------------------------------------------------------------------------------------------------------
;;; INPUTS ;;;
main_path = 'R:\users\susan.meerdink\Add_Border_Images\' ; Set directory that holds all flightlines
all_image_id = 'FL*' ;search term which needs to apply to all images in the file path you want co-registered
flightbox_name = 'SB' ;Name of flightbox to be processed (SB for Santa Barbara, SN for Sierra Nevada) 
;;; INPUTS DONE ;;

;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit
;;; DONE SETTING UP ENVI/IDL ENVIRONMENT ;;;

;;; SETTING UP FLIGHTLINE FOLDERS ;;;
fl_list = ['SB_FL08'] ; Which flightlines do the files belong to
;;; DONE SETTING UP FLIGHTLINE FOLDERS ;;;

;;; ADDITIONAL VARIABLES FOR MEMORY PURPOSES ;;;
outImage = MAKE_ARRAY([800, 250, 10000], TYPE = 2, VALUE = 0) ;Create empty array that is large for memory allocation purposes
outImage = 0 ;Set to zero for memory purposes
;;; DONE ADDITIONAL VARIABLES FOR MEMORY PURPOSES ;;;

;;; PROCESSING ;;;
FOREACH single_flightline, fl_list DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
  flightline_path = main_path + single_flightline + '\' ; Set path for flightline that is being processed
  cd, flightline_path ;Change Directory to flightline that is being processed
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search(all_image_id) ;Get list of all files in flightline
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header file proceed
      ;;; BASIC FILE INFO ;;;
      print, 'Processing: ' + single_image 
      ENVI_open_file, single_image, R_FID = fidRaster ;Open the file
      ENVI_file_query, fidRaster,$ ;Get information about file
        DIMS = raster_dims,$ ;The dimensions of the image
        NB = raster_bands,$ ;Number of bands in image
        BNAMES = raster_band_names,$ ;Band names of image
        NS = raster_samples, $ ;Number of Samples
        NL = raster_lines,$ ;Number of lines
        WL = raster_wl,$ ;WAvelengths of image
        DATA_TYPE = raster_data_type, $ ;File data types
        FNAME = raster_file_name, $ ;contains the full name of the file (including path)
        BBL = raster_bbl ;Bad Band List
      map_info_raster = envi_get_map_info(FID = fidRaster) ;Get Raster map info
      ;;; DONE BASIC FILE INFO ;;;
      
      ;;; GET DATA & ASSIGN TO RESIZED IMAGE ;;; 
      outImage = 0 ;This is for memory purposes
      outImage = MAKE_ARRAY([(raster_samples+20), raster_bands, (raster_lines+20)], TYPE = raster_data_type, VALUE = 0) ;Create empty array for output image
      zerosFront = MAKE_ARRAY(10, raster_bands, VALUE = 0) ;Place holders for beginning of line
      zerosEnd = MAKE_ARRAY(10, raster_bands, VALUE = 0) ;Place holders for end of line
      startSample = 0 ;Start sample to pull data
      endSample = raster_samples - 1 ;End sample to pull data
      startLine = 0 ;Start line to pull data
      endLine = raster_lines - 1 ;End line to pull data
      countLine = 9 ;Counter for array assignment in loop (skips first 10 lines for header)
      print,'Assigning Data: ' + single_image
      
      FOR i = startLine, endLine DO BEGIN ;Loop through lines of image
        newImageData = ENVI_GET_SLICE(/BIL, FID = fidRaster, LINE = i, POS = INDGEN(raster_bands), XS = startSample, XE = endSample) ;Get Data from new image (returns in BIL format)
        ;              LINE = keyword to specify the line number to extract the slice from. LINE is a zero-based number.
        ;              POS = keyword to specify an array of band positions
        ;              XE = keyword to specify the x ending value. XE is a zero-based number.
        ;              XS = keyword to specify the x starting value. XS is a zero-based number.
        ;              /BIL = keyword that make data returned in BIL format - dimensions of a BIL slice are always [num_samples, num_bands]               
        outLine = [zerosFront, newImageData, zerosEnd];Assign Data to new array
        outImage[0,0,countLine] = outLine ;Assign Array
        countLine = countLine + 1 ;Advance counter used in array assignment       
        
      ENDFOR 
      ;;; DONE GETTING DATA & ASSIGNING TO RESIZED IMAGE ;;; 

      ;;; WRITE DATA TO ENVI FILE ;;;
      print, 'Writing: ' + single_image 
      fileOutput = raster_file_name + '_ResizePlusBorder' ;Set file name for new image
      fileOutputTemp = raster_file_name + '_ResizePlusBorder_BIL' ;Set file name for new BSQ image
      ENVI_WRITE_ENVI_FILE, outImage, $ ; Data to write to file
        OUT_NAME = fileOutputTemp, $ ;Output file name
        NB = raster_bands, $; Number of Bands
        NL = raster_lines + 20, $ ;Number of lines
        NS = raster_samples + 20, $ ;Number of Samples
        INTERLEAVE = 1 , $ ;Set this keyword to one of the following integer values to specify the interleave output: 0: BSQ 1: BIL 2: BIP
        R_FID = fidTemp, $ ;Set keyword for new file's FID
        OFFSET = 0 ; Use this keyword to specify the offset (in bytes) to the start of the data in the file.      
      ;;; DONE WRITING DATA TO ENVI FILE ;;;
      
      ;;; CONVERT TO BSQ ;;;
      ENVI_FILE_QUERY,fidTemp, DIMS = new_dims, NS = new_samples, NL = new_lines, NB = new_bands
      ENVI_DOIT, 'CONVERT_DOIT', $
        DIMS = new_dims, $ ;five-element array of long integers that defines the spatial subset
        FID = fidTemp, $ ;Set for new file's fid
        OUT_NAME = fileOutput, $ ; Set new files output name
        R_FID = fidFinal, $ ;Set BSQ file fid
        O_INTERLEAVE = 0, $ ;keyword that specifies the interleave output: 0: BSQ, 1: BIL, 2: BIP
        POS =  INDGEN(raster_bands) ;specify an array of band positions  
      ;;; DONE CONVERTING TO BSQ ;;;
      
      ;;; CREATING ENVI HEADER FILE ;;;
      map_info_raster.mc[0] = 10 ;Update x pixel start
      map_info_raster.mc[1] = 10 ;Update y pixel start
      ENVI_SETUP_HEAD, $
        fname = fileOutput + '.hdr', $ ;Header file name
        NS = new_samples,$ ;Number of samples
        NL = new_lines, $ ;Number of lines
        data_type = raster_data_type,$ ; Data type of file
        interleave =  0, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
        NB = new_bands,$ ;Number of Bands
        wl = raster_wl,$ ;Wavelength list
        bbl = raster_bbl, $ ;Bad Band List
        map_info = map_info_raster, $ ;Map Info - set to the base image since raster has been resized.
        bnames = raster_band_names, $ ;Bands Names
        /write
      ;;; DONE CREATING ENVI HEADER FILE ;;;
    
      ;;; CLOSING ;;;
      print, 'Completed Processing for : ' + single_image 
      envi_file_mng, ID = fidRaster, /remove ;Close current Raster image
      envi_file_mng, ID = fidTemp, /remove ;Close current Raster image
      envi_file_mng, ID = fidFinal, /remove ;Close current Raster image
      FILE_DELETE, fileOutputTemp ;Delete the temporary BIL formatted image 
      FILE_DELETE, fileOutputTemp + '.hdr' ;Delete the temporary BIL formatted image 
      ;;; DONE CLOSING ;;;
      
    ENDIF ;end of if statement checking if header file
  ENDFOREACH ;end of loop through images in single flightline
  print, 'Finished with ' + single_flightline 
ENDFOREACH ;;; DONE LOOP THROUGH FLIGHTLINES ;;;
END ; End of File