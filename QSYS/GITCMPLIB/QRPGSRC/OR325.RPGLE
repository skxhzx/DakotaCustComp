     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   Glen Ellyn, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR325     Print SOS Slot Transfer Quantity
     *  1 June 2011
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    06/01/11  RH   6.40
     *      - Created using RU365
     *
640aA*    08/10/11  RBD  6.40a
     *      - Fix: Do not print report if there are no detail records.
640bA*    08/11/11  RH   6.40b
     *      - Fix: Only process SOS Stage/holding slots (desg = SOSSG)
     *        Was printing warehouse slots when nothing was picked on line.
640cA*    11/10/11  RH   6.40c
     *      - Ehh:Add call to DUPPRTCL to duplicate the spool file.
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
EI  A*  40        Print Exp. Date entry line on report.
EI  A*  41        Print Box Nbr. entry line on report.
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     For325a    ip   e           k disk
     Fordh      if   e           k disk
     Fpiritem   if   e           k disk
     Freports   if   e           k disk
     Frtehed    if   e           k disk
     Fwarehs    if   e           k disk
GSC AFslot2     if   e           k disk
     For325pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D pcs             s              5  0 dim(3)
417 A*----------------------------------------------------------------
417 A*  Customer id
417 A*
DRYaA /COPY QCOPYSRC,ID#Dairyla
EIa A*
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
640c *----------------------------------------------------------------
640c *  Program info data structure
640c *
640c D                sds
640c D  #prog            *proc
640c D  #job                 244    253
640c D  #user                254    263
640c D  #jobn                264    269
640c D  #jobdt               276    281  0
640c D  #jobtm               282    287  0
     *----------------------------------------------------------------
     * Working variables
     D hmsmdy          s             12  0
     D $plen           s              3  0
     D $pstr           s             60
     D l               s              1  0
     D m               s                   like(l)
     D p1cord          s              7  0
     D p1desc          s             21
     D p1disp          s             12
     D p1item          s             15
     D p1pal           s              7  0
     D p1qyso          s              9  0
640aAD recFound        s               n
     D tfrqt1          s              7  0
     D tfrqt2          s              5  0
     D tfrqt3          s              5  0
     D wkprtf          s             10
     *----------------------------------------------------------------
     Ioqrec
     I                                          lbwhse        l2
     I                                          lbrte         l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PRINT   - Print SOS Slot tranfer qty list
     *      $PWHSE  Warehouse number
     *      $Prtid  Route ID
     *
     *    Returned Parameters
     *      *None
     *
     *----------------------------------------------------------------
     *
     C     *ENTRY        PLIST
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *
     *  Report Heading
     *
     *
640aDC**                 if        *in90  or
640aMC                   if        *in90  and recFound or
640aDC**                           *inl1
640aMC                             *inl1 and recFound
     C                   exsr      zrzero
     *
     *
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Route
     *
     C                   if        *inl1
640aAC                             and recFound
     C                   eval      l = 1
     C                   endif
     *
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *
     *  Get Customer Order number.
     C     ohkey         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohcord = 0
     C                   endif
     *
     *  Get Item Master record.
     *
     C     itkey         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = ' '
     C                   endif
     *
     *  Get Slot record.
     *
     C     slkey         chain     slot2
     C                   if        not %found(slot2)
     C                   eval      tfrqt1 = 0
     C                   eval      tfrqt2 = 0
     C                   eval      tfrqt3 = 0
     C                   else
640bAC                   if        sldesg <> 'SOSSG'
640bAC                   eval      tfrqt1 = 0
640bAC                   eval      tfrqt2 = 0
640bAC                   eval      tfrqt3 = 0
640bAC                   else
     C                   eval      tfrqt1 = (slstk1-slalc1)-slpck1
     C                   eval      tfrqt2 = (slstk2-slalc2)-slpck2
     C                   eval      tfrqt3 = (slstk3-slalc3)-slpck3
640bAC                   endif
     C                   endif
     *  Only print detail if tranfer qty exists.
     C                   if        tfrqt1 > 0 or
     C                             tfrqt2 > 0 or
     C                             tfrqt3 > 0
     *
640aAC                   if        recFound = *off
640aAC                   eval      recFound = *on
640aAC                   exsr      zrzero
640aAC                   exsr      zrhead
640aAC                   eval      l = 1
640aAC                   endif
     *
     *  Load detail line print fields - 1st detail line
     C                   eval      p1disp = lbdisp
     C                   eval      p1item = lbitem
     C                   movel     itdesc        p1desc
     C                   eval      p1qyso = tfrqt1
     C                   eval      p1cord = ohcord
     C                   eval      p1pal = lbpal#
     *
     *  Check for page overflow.
     *
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   endif
     *
     *
     *  Write detail line
     *
     C                   write     detail1
EIa A*
     *
     *
     *  Accumulate totals
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     C                   endif
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     *
     *----------------------------------------------------------------
     *
     * Route totals
     *
640aACL1                 if        recFound = *on
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 if        *in90 = *on
     CL1                 exsr      zrhead
     CL1                 endif
     CL1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *
640aACL1                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
640aACLr                 if        recFound = *on
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 if        *in90 = *on
     CLr                 exsr      zrhead
     CLr                 endif
     CLr                 write     skip1
     CLr                 exsr      zrtotl
     CLr                 write     foot1
     CLr                 endif
     *
640aACLr                 endif
640cACLr                 exsr      dupprt
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
417 A*
417 AC                   call      'GETCLIENT'
417 AC                   parm      *blanks       Client           10
     *
     *   Full PIRITEM key
     *
     C     itkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *   Full REPORTS key
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     *   Full RTEHED key
     C     rhkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     *
     *   Full ORDH key
     C     ohkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
GSC A*
GSC A*   Partial SLOT2 Key
GSC AC     slkey         klist
GSC AC                   kfld                    lbwhse
GSC AC                   kfld                    lbwhdp
GSC AC                   kfld                    lbdisp
EIb A*
     *
     *   Get report title.
     *
     C                   movel     'OR325PR '    wkprtf
     C     rpkey         chain     reports
     C                   if        %found
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
500 A*
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs
     C                   if        %found
500aDC*                  movel     whdesc        $pstr
500aMC                   movel (p) whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
500 DC*                  eval      $plen = 30
500 MC                   eval      $plen = 40
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     *
     C                   eval      *in90 = *on
     C                   time                    hmsmdy
     C                   movel     hmsmdy        rtime
     C                   move      hmsmdy        rdate
     *
     *
     C                   eval      l = 3
     C                   exsr      zrzero

     C                   endsr
EIa A*
640cA*----------------------------------------------------------------
640cA*
640cA*  DUPPRT  Dup. printer file.
640cA*
640cAC     dupprt        begsr
     *
     *      Duplicate printer file.
     *
640c C                   close     or325pr
     *  DUPPRTCL will execute the DUPSPLF command.
     *
640c C                   movel     'OR325PR'     $lfile
640c C                   movel     'BFCEXCP'     $loutq
640c C                   movel     '*LAST'       $lspln
640c C                   movel     'OR325PR'     $lnnam
     *
640cAC                   call      'DUPPRTCL'
640cAC                   parm                    $lfile           10
640cAC                   parm                    #jobn
640cAC                   parm                    #user
640cAC                   parm                    #job
640cAC                   parm                    $loutq           10
640cAC                   parm      '*LIBL'       $lqlib           10
640cAC                   parm                    $lspln            6
640cAC                   parm      1             $lcpys            3 0
640cAC                   parm                    $lnnam           10
640cAC                   parm      '*NO'         $ldlto            4
     *
640cAC                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     *  Get Customer Route number.
     C     rhkey         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      rhrte  = ' '
     C                   endif
     *
     C                   eval      *in90 = *off
     C                   write     head1                                90
     C                   write     head2                                90
     C                   write     columns                              90
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       pcs(l)        pcs(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     *
     C                   if        l = 1
     C                   endif
     *
     C                   if        l = 2
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   eval      pcs(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
