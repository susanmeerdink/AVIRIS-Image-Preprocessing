PRO aviris_rotate_35_batch
;This code rotates aviris images 35 degrees.
;USED NEW ENVI ( not classic )
;Susan Meerdink
;3/13/17
;----------------------------------------------------------------------

;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT IDL2
e = ENVI(/HEADLESS)

;;; INPUTS ;;;
main_path = 'F:\Image-To-Image-Registration\AVIRIS\' ; Set directory that holds all flightlines
;fl_list = ['FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] ;Create the list of folders
fl_list = ['FL02'] ;Create the list of folders

;;; PROCESSING ;;;
FOREACH single_flightline, fl_list DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
  flightline_path = main_path + single_flightline + '\' ; Set path for flightline that is being processed
  cd, flightline_path ;Change Directory to flightline that is being processed

  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search('*_test.dat') ;Get list of all images in flightline that have been rotated
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header,text, or GCP file proceed
      ;;; BASIC FILE INFO ;;;
      print, 'Processing: ' + single_image
      fidIn = e.OpenRaster(single_image); Open an input file
      rasterIn = fidIn.GetData()

      ;;; ROTATION ;;;
      fidOut = ROT(rasterIn,35);Rotate AVIRIS image by 35 degrees (for santa barbara flightlines)

      ;;; SAVE ;;;     
      I = strpos(raster_file_name,'.dat')
      strput,raster_file_name,'_rot35',I
      outPath = single_image + raster_file_name;Set output name for rotated image
      outImage = ENVIRaster(fidOut, URI = outPath)
      outImage.Save
      
      ;;; CLEANING UP ;;;
      fidOut.close
      fidIn.close
      outImage.close
      
    ENDIF ;End of if statement to select image files (not header files)
  ENDFOREACH ;End of loop through images in a flightline
ENDFOREACH ;End of loop through flightline

END