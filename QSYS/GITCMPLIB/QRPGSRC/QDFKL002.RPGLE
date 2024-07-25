     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   245 W. Roosevelt Rd.  #8-51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDFKL002  Zero verify slots-Process
     F*  Roxanne Harrison
     F*  23 October, 2008
     F*
     F*  Revisions
     F*
     C*  Notes:
     C*  Delete virtual slot records with status 'Z'
      *  Verify base slot records with status 'Z'
     C*
     Fslot2     upe  e           k disk    rename(slrec:slrec2)
     Fvslot1    uf   e           k disk
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     *  Main line
     *
     C*
     C*    Delete virtual slot with 'Z' status & zero qty.
     C* or Init base slot with 'Z' status & zero qty.
     C*
     C                   if            slwhse = kwhse
     C                   if            slstat = 'Z'
     C                             and slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C*
     C                   if        slrsrv = 'V'
     C*     Delete Virtual slot record.
     C                   delete    slrec2
     C*
     C     vskey         chain     vslot1
     C                   if        %found(vslot1)
     C                   delete    vsrec
     C                   endif
     C*
     C*     Initialize base slot fields and remove deleted item.
     C*
     C                   else
     C                   eval      slitem = ' '
     C                   eval      slstat = 'V '
     C                   eval      slsdte = today
     C                   eval      slstim = todayhms
     C                   eval      slentd = 0
     C                   eval      slexpd = 0
     C                   eval      slslfd = 0
     C*
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C*
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C*
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C*
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C*
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     C                   update    slrec2
     C*
     C                   endif
     C*
     C                   endif
     C                   endif
     C*
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        today             8 0
     C                   time                    todayhms          6 0
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   move      $pwhse        kwhse             3 0
     C
     C     vskey         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     C*
     C     itkey         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   endsr
