PRO resize_plus_borders_aviris
  ;Created for images from the HyspIRI campaign (same area flown three times in 2013 and 2014).
  ;Images must have same number of bands and be in zero rotation (aka North to South - NO angle).
  ;This file loops through folders that contain files for a specific flightline from multiple dates.
  ;The goal of this code is to read in a base file that has been cropped to the study area of choice for each flightline folder (FL01, FL02, etc).
  ;The code will crop all other files for that specific flightline to the study area of interested (covered in the base file).
  ;The code will add a 10 sample/line border to all sides the flightline that has a value of zero. 
  ;The resulting files will be a BSQ image that has the same number of samples and lines for all files in the flightline folder.
  ;This code outputs images that will be inputs for Alex Koltunov's Image to Image Registration code.
  ; Susan Meerdink
  ; Created 4/25/2016
  ; 
  ; --------------------------------------------------------------------------------------------------------------------------
  ;Start up ENVI
  COMPILE_OPT STRICTARR
  envi, /restore_base_save_files
  ENVI_BATCH_INIT

  ;;;;;;;;;;;;;;Inputs;;;;;;;;;;;;;;;;
  pre_path = 'R:\users\susan.meerdink\Testing_Imagery_Folder\'
  ;remove for resampled
  mid_path='AVIRIS\'
  ;search term to identify base image (and base image only!) could be worked
  ;into next for loop if different terms apply for different FL boxes needs to have a .dat or other file extension in the search term
  ; or the base file needs to be modified with a string split to ignore the .hdr file
  base_image_id ='*f140416*'
  ;search term which needs to apply to all images in the file path you want co-registered does not need to have a flie extension
  ;but code will run miliseconds faster if it does
  all_image_id='FL*'

  ;;;;;;;;;;;;;;;End Inputs;;;;;;;;;;;;;;;;;;;;;
  ;SETTING UP FLIGHTLINE Folders
  ;;TWO Options: 1) Have list of Flightline folders (processing multiple) 2) Only want to process ONE flightline
  ;Need to comment out one option - do not leave code for both

  ;OPTION 1:
  ;Makes directory names for each FL would need to change 'SN' if another Flight box and 11 to the number of flight boxes in your series
  fl_list = make_array(1,1,/string)
  for i = 2,2,1 do begin ;Right now goes from FL02_FL03
    if (i LT 10) then begin ;Add zero in front of number/counter
      stri = string(0) + string(i)
    endif else begin ;Unless it's 10 or Greater (don't add zero in front)
      stri = string(i)
    endelse
    fl_list[0,(i-2)]=STRCOMPRESS('SB_FL'+stri,/REMOVE_all) ;Create the list of folders
  endfor

  ;OPTION 2 - Only one flightline folder
  ;Fill in folder name that you want to process
  ;fl_list = make_array(1,1,/string)
  ;fl_list[0,0] = STRCOMPRESS('SB_FL03',/REMOVE_all) ;Create the list of folders

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Loop through flightline folders (FL01, FL02, FL03,....)
  foreach element,fl_list do begin
    print, 'Starting with ' + element
    fpath = pre_path+element+'\'+mid_path ;Set filepath and change directory
    cd, fpath

    ;;;;;;;;;Find Base File for the Flightline and get information;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;base file is date of file you want images to be clipped to
    base_file = file_search(base_image_id);Search for the basefile
    envi_open_file, base_file, r_fid = fidBase ;Open the basefile
    map_info_ori = envi_get_map_info(fid = fidBase) ;Get basefile's map information
    ;print, map_info_ori
    envi_file_query, fidBase, $ ;Get information about basefile
      ns = numSamples, $ ;Number of Samples
      nl = numLines, $ ; Number of Lines
      sname = base_file_name, $ ;Short name of base file (no path)
      nb = nbBase ;Number of Bands
    upperCoordE = map_info_ori.mc[2];declaring variable that will hold upper E coordinate
    upperCoordN = map_info_ori.mc[3];declaring variable that will hold upper N coordinate
    print, 'Basefile: ' + base_file_name

    ;;;;;;;;;Loop through the files within a flightline;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    image_list = file_search(all_image_id) ;Get list of all files in flightline
    foreach img,image_list do begin
      if strmatch(img,'*.hdr') EQ 0 then begin ;If it isn't a header file proceed
        print, 'Processing: ' + img
        envi_open_file, img, r_fid = fidRaster ;Open the file
        ENVI_file_query, fidRaster,$ ;Get information about file
          DIMS = dimRaster,$ ;The dimensions of the image
          NB = nbRaster,$ ;Number of bands in image
          BNAMES = bnames,$ ;Band names of image
          NS = nsRaster, $ ;Number of Samples
          NL = nlRaster,$ ;Number of lines
          WL = wl,$ ;WAvelengths of image
          File_Type = ft, $ ;File Type
          DATA_TYPE = data_type, $ ;File data types
          OFFSET = offset, $ ;Use this keyword to specify the offset (in bytes) to the start of the data in the file.
          INTERLEAVE = interleave, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
          FNAME = file_name, $ ;contains the full name of the file (including path)
          BBL = bbl ;Bad Band List
        map_info = envi_get_map_info(fid = fidRaster) ;Get Raster map info

        ;Save and Open Raster Output that does have crop applied
        fileOutputResize = file_name + '_Resize' ;Add crop onto the file name
        fileOutput = file_name + '_ResizePlusBorder' ;Add crop onto the file name
        GET_LUN, U ;The GET_LUN procedure allocates a file unit from a pool of free units
        openw,U,fileOutput

        ;Find new coordinates to resize image too
        ENVI_CONVERT_FILE_COORDINATES, $ ;this procedure to convert x,y pixel coordinates to their corresponding map coordinates, and vice-versa
          fidRaster, $ ;File ID
          upperCoordX, $ ;XF is a named variable that contains the returned x file coordinates for the input XMap and YMap arrays
          upperCoordY, $ ;YF is a named variable that contains the returned y file coordinates for the input XMap and YMap arrays
          upperCoordE, $ ;XMap is a variable that contains the x map coordinates to convert
          upperCoordN ;YMap is a variable that contains the y map coordinates to convert

        upperCoordX = round(upperCoordX)
        upperCoordY = round(upperCoordY)

        ;;;;Figuring out Samples;;;
        startSample = upperCoordX
        offsetSample = 0
        if startSample LT 0 then begin
          startSample = 0
          offsetSample = abs(startSample)
        endif
        endSample = (numSamples-1) + upperCoordX  
        if endSample GT nsRaster then begin
          endSample = (nsRaster-1)
        endif

        ;;;;Figuring out Lines;;;;;
        startLine = upperCoordY
        offsetLine = 0
        if startLine LT 0 then begin
          startLine = 0
          offsetLine = abs(upperCoordY)
        endif
        endLine = (numLines-1) + upperCoordY 
        if endLine GT nlRaster then begin
          endLine = (nlRaster-1)
        endif

        dimOut = [-1L, startSample, endSample, startLine, endLine] ;five-element array of long integers that defines the spatial subset (of a file or array) to use for processing.
        ;  DIMS[0]: A pointer to an open ROI; use only in cases where ROIs define the spatial subset. Otherwise, set to -1L.
        ;  DIMS[1]: The starting sample number. The first x pixel is 0.
        ;  DIMS[2]: The ending sample number
        ;  DIMS[3]: The starting line number. The first y pixel is 0.
        ;  DIMS[4]: The ending line number
        
        ;;RESIZING
        if STRCMP(base_file_name,img) EQ 1 then begin ;If this is the basefile Resizing doesn't need to be done
          fidOutRaster = fidRaster
        endif else begin ;All other files should be resized
          ;Call Function to Resize AVIRIS imagery
          ENVI_DOIT, 'RESIZE_DOIT', $ ;this procedure to spatially resize image data.
            DIMS = dimOut, $ ;five-element array of long integers that defines the spatial subset to use for processing
            FID = fidRaster, $ ;file ID of input Raster
            INTERP = 0, $ ;an integer value corresponding to the interpolation type ( 0 = nearest neighbor)
            OUT_BNAME = bnames, $;keyword to specify a string array of output band names.
            OUT_NAME = fileOutputResize, $ ;string with the output filename for the resulting data.
            POS = INDGEN(nbRaster), $ ;keyword to specify an array of band positions, input is array from 0 to 223
            R_FID = fidOutRaster, $;file ID of output or new image
            ;/IN_MEMORY, $ ; output should be stored in memory.
            RFACT = [1, 1] ;specify a two-element array holding the rebin factors for x and y ( a value of 1 does not change size of the data)
        endelse       

        ;Check to make sure Resizing worked
        if fidOutRaster GT -1 then begin
          ;;Commenting out to see if code works before this;;;;;;;;;;;
          ;;Create new image file (this size will always stay the same and is based on base file size)
          outImage = MAKE_ARRAY([(numSamples+20), (numLines+20), nbBase], TYPE = data_type, VALUE = 0) ;Create empty array for output image
          ;If getting error: "Too many array elements" make sure you are running on IDL 64 bit
          
          ;Get Information from new image
          ENVI_file_query, fidOutRaster,DIMS = dimOutRaster
          samples = dimOutRaster[2]
          lines = dimOutRaster[4]
          startImageSample = 9 + offsetSample
          endImageSample = samples + startImageSample;
          startImageLine = 9 + offsetLine
          endImageLine = lines + startImageLine
          
          ;Assign Data to new image
          for i = 0, nbBase-1 do begin          
            
            ;Get Data from new image
            newImageData = ENVI_GET_DATA(FID = fidOutRaster,DIMS = dimOutRaster,POS = i)

            ;Assign Data to new array
            outImage[startImageSample:endImageSample,startImageLine:endImageLine,i] = newImageData
            
          endfor
          
          ;Write Data to File
          ;writeu, U, outImage
          ENVI_WRITE_ENVI_FILE, outImage, $ ; Data to write to file
            OUT_NAME = fileOutput, $
            NB = nbBase, $; Number of Bands
            NL = (numLines+20), $ ;Number of lines 
            NS = (numSamples+20), $ ;Number of Samples
            OFFSET = 0 ; Use this keyword to specify the offset (in bytes) to the start of the data in the file.        

          ;set up and write the envi header for output image
          ENVI_SETUP_HEAD, $
            fname = fileOutput+'.hdr', $ ;Header file name
            ;file_type = ft, $ ;Specifies file type
            NS = numSamples,$ ;Number of samples
            NL = numLines, $ ;Number of lines
            data_type = data_type,$ ; Data type of file
            interleave =  interleave, $ ;specify the interleave output: 0: BSQ,1: BIL,2: BIP
            NB = nbBase,$ ;Number of Bands
            offset = offset,$ ;Use this keyword to specify the offset (in bytes) to the start of the data in the file.
            wl = wl,$ ;Wavelength list
            bbl = bbl, $ ;Bad Band List
            map_info = map_info,$ ;Map Info
            /write
          
          FREE_LUN, U ;the file can be closed and the file unit can be freed 
          ;close,U ; Close file
          print,'Completed processing for ' + img
        endif else begin
          print,'Error in processing for ' + img
        endelse
          
      endif ;if statement to see if it is a header file

    endforeach ;End for each through images within a flightline

    ;Clear up FIDs so ENVI doesn't become confused
    fids = envi_get_file_ids()
    for j=0, n_elements(fids)-1 do begin
      envi_file_mng, id=fids[j], /remove ;removes specified file from within ENVI classic
    endfor
  endforeach ;End of for each through flightlines

END ;End of file
