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
main_path = 'R:\Image-To-Image-Registration-Products\AVIRIS\' ; Set directory that holds all flightlines

;;; INPUTS DONE ;;
;
;; OPTION 1 - Loop through all flightlines
;; Makes directory names for each FL would need to change 'SN' if another Flight box and 11 to the number of flight boxes in your series
;number_of_flightlines = 11 ;total number of flightlines in flightbox (Santa Barbara has 11 flightlines)
;fl_list = make_array(1,number_of_flightlines,/string) ;Make array that will hold flightline names
;for i = 1,number_of_flightlines,1 do begin ;Loop through flightline numbers
;  if (i LT 10) then begin ;Add zero in front of number/counter
;    stri = string(0) + string(i)
;  endif else begin ;Unless it's 10 or Greater (don't add zero in front)
;    stri = string(i)
;  endelse
;  fl_list[0,(i-1)]=STRCOMPRESS(flightbox_name + '_FL' + stri,/REMOVE_all) ;Create the list of folders
;endfor

;; OPTION 2 - Only one flightline folder
flightline_name = '10' ;Set the single flightline you want to process (make sure to add 0 in front of flightlines under 10)
fl_list = make_array(1,1,/string);Make array that only holds one flightline name
fl_list[0,0] = STRCOMPRESS(flightbox_name + '_FL' + flightline_name,/REMOVE_all) ;Add flightline name to list
;;; DONE SETTING UP FLIGHTLINE FOLDERS ;;;