PRO aviris_create_apply_mask_batch
;This code utlizes the masking_with_tiles function to mask out the margins.
;This code uses the function to create and apply a mask for AVIRIS imagery,
;specifically the HyspIRI simulated dataset
;which does not contain a single value in the margin, but instead spectrum that is residue
;from atmospheric correction processes.
;It out puts an ENVI file in the same directory with the ending 'mask'
;This code uses new ENVI (NOT CLASSIC)
;Susan Meerdink
;5/2/2016

;-------------------------------------------------------------------------------------
;Start Application
COMPILE_OPT IDL2
e = ENVI(/HEADLESS)

;;; INPUTS ;;;
main_path = 'D:\Imagery\AVIRIS\' ; Set directory that holds all flightlines 
all_image_id = '*_corr_018m*' ;search term which needs to apply to all images in the file path you want co-registered
number_of_flightlines = 3 ;total number of flightlines in flightbox (Santa Barbara has 11 flightlines) 
;;; INPUTS DONE ;;

path = 'D:\Imagery\AVIRIS\FL02\0 - Original Files\'
;;; PROCESSING ;;;
;FOR i = 2,number_of_flightlines,1 DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
;  if (i LT 10) then begin ;Add zero in front of number/counter
;    stri = string(0) + string(i)
;  endif else begin ;Unless it's 10 or Greater (don't add zero in front)
;    stri = string(i)
;  endelse
;  single_flightline = STRCOMPRESS('FL' + stri,/REMOVE_ALL)
;  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
;  flightline_path = main_path + single_flightline + '\0 - Original Files\'  ; Set path for flightline that is being processed
;  cd, flightline_path ;Change Directory to flightline that is being processed
cd, path
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search(all_image_id) ;Get list of all files in flightline
  print, image_list
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header file proceed     
                  
      raster = e.OpenRaster(single_image); Open an input file
      Metadata = raster.METADATA ;Get metadata
      
      ; generate a mask   
      mask = (raster.GetData() LT 0) ;Get all locations where every band is less than 0      
      
      ; write out the mask to a file
      outMaskLocation = single_flightline + 'mask'     
      mask = ENVIRaster(mask, URI = outMaskLocation)
      mask.Save
            
      ; create a masked raster
      rasterWithMask = ENVIMaskRaster(raster, MaskRaster)
      
      ;Save new masked image
      outMaskRaster = single_image + 'masked'
      maskRaster = ENVIRaster(mask, URI = outMaskRaster)
      maskRaster.Save
          
      ;;; CLOSING ;;;
      print, 'Completed Processing for : ' + single_image 
      maskRaster.close ;close newly masked image
      mask.close ;close mask file
      raster.close ;Close original image
      ;;; DONE CLOSING ;;;
      
    ENDIF ;end of if statement checking if header file
  ENDFOREACH ;end of loop through images in single flightline
  print, 'Finished with ' + single_flightline 
;ENDFOR ;;; DONE LOOP THROUGH FLIGHTLINES ;;;
END ; End of File