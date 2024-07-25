     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   Glen Ellyn, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  GETSHFT   Get Shift information.
     F*  23 August 2006
     F*  Jeff Jahnke
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     Fcrew      if   e           k disk
     Fshift     if   e           k disk
     I*----------------------------------------------------------------
     I*
     I*  Input parameters
     I*
     I*     $PWHSE   -  Warehouse
     I*     $PCREW   -  Crew Code
     I*
     I*  Output parameters
     I*
     I*     $PDESC   - Crew description
     I*     $PSHFT   - Shift code
     I*     $PSHTD   - Shift department
     I*     $PSTIM   - Shift Start Time
     I*     $PETIM   - Shift End Time
     I*     $PRTN    - *OK      -  Shift code found
     I*                *ERROR   -  Shift code not found
     I*
      *----------------------------------------------------------------
      *  Let the show begin .....
      *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pcrew            6
     C                   parm                    $pdesc           30
     C                   parm                    $pshft            6
     C                   parm                    $pshtd           30
     C                   parm                    $pstim            6 0
     C                   parm                    $petim            6 0
     C                   parm                    $prtn             8
      *----------------------------------------------------------------
      *  Main line
      *
      *    Initialize return parameters.
      *
     C                   eval      #pwhsd = *blanks
      *
     C                   eval      $pdesc = *blanks
     C                   eval      $pshft = *blanks
     C                   eval      $pshtd = *blanks
     C                   eval      $pstim = *zeros
     C                   eval      $petim = *zeros
     C                   eval      $prtn = '*OK     '
      *
      *    Get CREW code information.
      *
     C     keycr         chain     crew
     C                   if        not %found(crew)
     C                   eval      $prtn = '*ERROR  '
     C                   else
     C                   eval      $pdesc = crdesc
     C                   endif
      *
      *    Get corresponding shift record.
      *
     C                   eval      $pshft = crshft
     C     keysh         chain     shift
     C                   if        not %found(shift)
     C                   eval      $prtn = '*ERROR  '
     C                   else
     C                   eval      $pshtd = shdesc
     C                   eval      $pstim = shstim
     C                   eval      $petim = shetim
     C                   endif
      *
     C                   return
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
      *  Define key for CREW file.
      *
     C     keycr         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pcrew
      *
      *  Define key for SHIFT file.
      *
     C     keysh         klist
     C                   kfld                    $pwhse
     C                   kfld                    #pwhsd            5
     C                   kfld                    $pshft
      *
     C                   endsr
