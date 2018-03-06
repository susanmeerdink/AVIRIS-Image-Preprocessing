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
path = 'D:\Imagery\AVIRIS\'
;fl_list = ['FL02', 'FL03', 'FL04', 'FL05', 'FL06', 'FL07', 'FL08', 'FL09', 'FL10', 'FL11']
fl_list = ['FL04']

;;; Loop through flightlines ;;
foreach fl, fl_list do begin
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  dir = path + fl + '\0 - Original Files\'
  image_list = file_search(dir + '*crop') ;Get list of all files in flightline
  
  ;;; Loop through all images for a single flightline ;;;
  FOREACH single_image, image_list DO BEGIN 
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header file proceed     
      print, 'Started Processing for: ' + single_image            
      raster = e.OpenRaster(single_image); Open an input file
      
      ; generate a mask
      binary = raster.GetData(BANDS=[14]) GT 0 ;Get all locations where every band is greater than 0, so it has a value of 1 on mask 
      outMaskLocation = single_image + '_temp'     
      mask = ENVIRaster(binary, URI = outMaskLocation) ; write out the mask to a file
      mask.Save
            
      ; create a masked raster
      rasterWithMask = ENVIMaskRaster(raster, mask)
      outMaskRaster = single_image + '_mask'
      rasterWithMask.Export, outMaskRaster, 'ENVI'  ;Save new masked image

      ;;; CLOSING ;;;
      print, 'Completed Processing for : ' + single_image 
      rasterWithMask.close ;close newly masked image
      mask.close ;close mask file
      raster.close ;Close original image
      ;;; DONE CLOSING ;;;
      
    ENDIF ;end of if statement checking if header file
  ENDFOREACH ;end of loop through images in single flightline
ENDFOREACH ;;; DONE LOOP THROUGH FLIGHTLINES ;;;
END ; End of File