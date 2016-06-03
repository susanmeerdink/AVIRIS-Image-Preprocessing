PRO analyze_registration_intermediate_products
;susan meerdink
;6/2/106
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

origFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS\'
affineFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS_registered_best_affine_2016-05-31_1012\'
linearFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS_registered_best_linear_2016-06-01_1630\'

origFile = FILE_SEARCH(origFolder,'*FL00*')
affineFiles = FILE_SEARCH(affineFolder,'*.bsq')
linearFiles = FILE_SEARCH(linearFolder,'*.bsq')

ENVI_OPEN_FILE, origFile[0], R_FID = origFID
      
FOREACH affine, affineFiles DO BEGIN ;;For each original file
  startPT = strlen(affineFolder)
  endPT = strlen(affine)
  affineFile = STRMID(affine,startPT)
  compareString = ('*' + STRMID(origFile,0,12) + '*')
  linearDisp = linearFiles[WHERE(STRMATCH(linearFiles,compareString) EQ 1)]
     
  ENVI_OPEN_FILE, affineDisp, R_FID = affineFID
  ENVI_OPEN_FILE, linearDisp, R_FID = linearFID
    
  channels = [25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,104,117,120,130,140,150,190,195,200,205,210,220]
    
  foreach c, channels do begin
    ENVI_DISPLAY_BANDS, origFID, c, /NEW ;
    
    ENVI_DISPLAY_BANDS, origFID, c, /NEW
      ;POS ; one- or three-element array of long integers representing band positions
      ;/NEW ;Set this keyword to create a new display group.
    
    ENVI_DISPLAY_BANDS, affineFID, c, /NEW
      ;POS = c,$ ; one- or three-element array of long integers representing band positions
      ;/NEW ;Set this keyword to create a new display group.
      
    ENVI_DISPLAY_BANDS, linearFID, c,/NEW
      ;POS = c,$ ; one- or three-element array of long integers representing band positions
      ;/NEW ;Set this keyword to create a new display group.
      ;
    print, 'Press Y to continue onto next channel, Press N to stop'
    A = GET_KBRD()
    IF A EQ 'Y' OR A EQ 'y' THEN BEGIN
      ENVI_CLOSE_DISPLAY, 1
      ENVI_CLOSE_DISPLAY, 2
      ENVI_CLOSE_DISPLAY, 3
      continue 
    ENDIF ELSE BEGIN
      IF A EQ 'N' OR A EQ 'n' THEN BEGIN
        ENVI_CLOSE_DISPLAY, 1
        ENVI_CLOSE_DISPLAY, 2
        ENVI_CLOSE_DISPLAY, 3
        break
      ENDIF ELSE BEGIN
        print,'Please enter Y or N'
      ENDELSE
    ENDELSE
  endforeach
    
  ENDIF
  
ENDFOREACH ;;End of loop through files

END