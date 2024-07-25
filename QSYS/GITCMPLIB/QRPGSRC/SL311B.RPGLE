     *----------------------------------------------------------------
     *  SL311B     Load SL311B work file (exclude virtual slots)
     *             SL311 records are processed with the purpose
     *             of excluding base locations having virtual(s)
     *             attached to it that are holding an item.
     *
     *  July 22, 2009
     *  Jose G. Duque
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fsl311     if   e           k disk
     F                                     rename(oqrec:oqrec1)
     Fslot2     if   e           k disk
     Fsl311b    o    e           k disk
     *
     *
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D cntr            s              6  0
     D loc1            s              8
     D loc2            s              8
     D svactv          s              2
     D svdept          s              5
     D svdesg          s              5
     D svdisp          s             12
     D svsdef          s              2
     D svstyp          s              1
     D svwhse          s              3  0
     D yes             s              1
     *----------------------------------------------------------------
     *
     *
     C                   eval      cntr = *zeros
     *
     *----------------------------------------------------------------
     *
     C     slot2k        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     *----------------------------------------------------------------
     C                   read      sl311                                  lr
     *
     C                   dow       not *inlr
     *
     *    Saving current SL311 record being processed
     C                   eval      svwhse = slwhse
     C                   eval      svdept = slwhdp
     C                   eval      svstyp = slstyp
     C                   eval      svdesg = sldesg
     C                   eval      svsdef = slsdef
     C                   eval      svactv = slactv
     C                   eval      svdisp = sldisp
     *
     *    For trouble shooting purpose
     C                   if        sldisp = 'CW-125-2'
     C                   eval      yes = 'Y'
     C                   endif
     *
     C                   subst     sldisp:1      loc1
     *
     *    All pick locs are written into output file SL311B.
     *
     *    The logic that follows applies to overstock locs only.
     C     slot2k        chain     slot2                              79
     C                   if        not *in79  and
     C                             slpick = 'N'
     *
     C                   read      slot2                                  78
     C                   if        not *in78
     C                   subst     sldisp:1      loc2
     *
     *    Compare the first 8 char from SL311/record against the
     *    first 8 char loc# from the SLOT2 record read above.
     *    If they match, it means that the SLOT2 record is a virtual loc#
     *    and if this loc is not empty then the base loc# record(SL311/Rec)
     *    is discharged by not writing it into the output file (Sl311B).
     C                   if        loc1 = loc2  and
     C                             slpick = 'N'  and
     C                             slhand <> ' '  and
     C                             slitem <> *blanks
     C                   goto      read
     C                   else
     C                   exsr      loadbk
     C                   write     oqrec
     C                   add       1             cntr
     *
     C                   endif
     C                   else
     C                   exsr      loadbk
     C                   write     oqrec
     C                   endif
     C                   else
     C                   exsr      loadbk
     C                   write     oqrec
     C                   endif
     *
     C     read          tag
     C                   read      sl311                                  lr
     C                   enddo
     *----------------------------------------------------------------
     *
     C     loadbk        begsr
     *
     *    Reloading current record being processed, saved above,
     *    back into SL311 file.
     C                   eval      slwhse = svwhse
     C                   eval      slwhdp = svdept
     C                   eval      slstyp = svstyp
     C                   eval      sldesg = svdesg
     C                   eval      slsdef = svsdef
     C                   eval      slactv = svactv
     C                   eval      sldisp = svdisp
     *
     C                   endsr
