     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CW301A    Catch Weight Variance Report
     *  Ginger Andrews
     *  3 June, 2010
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    06/03/10  GJA  5.30
     *      - Created
     *
700 A*    09/15/15  MLB  7.00
     *      - Fix: Revised program to stop pgm from printing page
     *        headings every time tranaction changes instead of
     *        every time catchwgts found to print.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordc      ip   e           k disk
     Fwarehs    if   e           k disk
     Frtehed    if   e           k disk
     Fordh      if   e           k disk
     Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
     Fitemlnk   if   e           k disk
     Fpiritem   if   e           k disk
     Freports   if   e           k disk
     Frptovr1   if   e           k disk
     Fcw301apr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
530b *  Data Variables
     D kywhse          s              3  0
     D wkdte           s              8  0
     D wkrg1c          s              3  3
     D wkrg2c          s              3  3
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     *****************************************************************
405 A*----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
410 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPICW   -  Individual catch weight entry (Y,N).
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414bA*    OPRTHS  -  Number of weeks - exported routes to keep.
414bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510c *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
412 AD  opmpck                14     14
413aAD  oprcdy                15     15  0
413aAD  oppkdy                16     16  0
414bAD  oprths                17     19  0
414bAD  opcrhs                20     22  0
414bAD  oppohs                23     25  0
414bAD  opiahs                26     28  0
414bAD  opmshs                29     31  0
510cAD  optbjq                32     32
     D  optend               117    117
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $FROM  - From date - returned as unpacked numeric
     *      $TO    - To date - returned as unpacked numeric
     *      $ITEM  - Item # or *all
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $pdte             8
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     C                   if        *in90  or
     C                             first = '1'
     C                   eval      *in95 = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
700 AC                   eval      *in90 = *off
     C                   endif
     *
     * Detail Calcs
     *
     C     orhkey        chain     ordh
     C                   if        %found
     C                   if        ohsdte = wkdte
     *
     C                   eval      w1tran = octran
     C                   eval      w1lbl# = oclbl#
     C                   eval      w1ord  = ocord
     C                   eval      w1cwgt = occwgt
     *
     C                   exsr      zzitem
     C                   exsr      zzrtid
     *
     C     w1swgt        mult      wkrg1c        w1low
     C     w1swgt        mult      wkrg2c        w1high
     *
     C     w1swgt        add       w1high        w1high
     C     w1swgt        sub       w1low         w1low
     *
     C                   if        occwgt > w1high or
     C                             occwgt < w1low
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ohsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1dte = $cvd6o
700 DC*                  write     detail1
700 MC                   write     detail1                              90
530bAC                   endif
530bAC                   endif
530bAC                   endif
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     *
     *
     CLr                 return
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *
     *  Define Keys
     *
500aAC     lnkkey        klist
500aAC                   kfld                    ocwhse
500aAC                   kfld                    ocitem
     *
500aAC     itmlkey       klist
500aAC                   kfld                    ocwhse
500aAC                   kfld                    ititem
     *
500aAC     orhkey        klist
500aAC                   kfld                    ocwhse
500aAC                   kfld                    ocord
     *
500 AC     rthkey        klist
500 AC                   kfld                    ohwhse
500 AC                   kfld                    ohrte
     *
500cAC     itmkey        klist
500cAC                   kfld                    ocwhse
500cAC                   kfld                    ocitem
     *
500cAC                   eval      kywhse = *zeros
500cAC                   eval      opcode = '*SYSTEM '
500cAC     opkey         klist
500cAC                   kfld                    kywhse
500cAC                   kfld                    opcode
     *
500cAC                   move      $pwhse        w1whse
500cAC                   move      $pdte         wkdte
     *
     C                   eval      first = *on
     C                   eval      *in91 = *on
     C                   eval      *in92 = *on
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C     w1whse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
     *****************************************************************
     *
     *  Get route
     *
500cAC     zzrtid        begsr
     *
500cAC                   eval      w1rtid = ohrte
500cAC     rthkey        chain     rtehed
500cAC                   if        %found(rtehed)
500cAC                   eval      w1rte = rhrte
500cAC                   else
500cAC                   eval      w1rte = *blanks
500cAC                   endif
     *
500cAC                   endsr
     *****************************************************************
     *
     *  Get item
     *
500cAC     zzitem        begsr
     *
500cAC                   eval      w1item = ocitem
500cAC     itmkey        chain     piritem
500cAC                   if        %found(piritem)
500cAC                   if        ittype <> ' '
500cAC     lnkkey        chain     itemlnk
500cAC                   if        %found(itemlnk)
500cAC     itmlkey       chain     piritem
500cAC                   if        %found(piritem)
500cAC                   eval      w1swgt = itswgt/itumq2
500cAC                   endif
500cAC                   endif
500cAC                   else
500cAC                   eval      w1swgt = itswgt
500cAC                   endif
500cAC                   else
500cAC                   eval      w1swgt = *zeros
500cAC                   endif
500cAC     itmkey        chain     itemmsc
500cAC                   if        %found(itemmsc)
500cAC                   if        imrg1c = *zero and imrg2c = *zero
500cAC     opkey         chain     options
500cAC                   if        %found(options)
500cAC                   eval      wkrg1c = oprg1c * .01
500cAC                   eval      wkrg2c = oprg2c * .01
500cAC                   eval      w1rg1c = oprg1c
500cAC                   eval      w1rg2c = oprg2c
500cAC                   endif
500cAC                   else
500cAC                   eval      w1rg1c = imrg1c
500cAC                   eval      w1rg2c = imrg2c
500cAC                   eval      wkrg1c = imrg1c * .01
500cAC                   eval      wkrg2c = imrg2c * .01
500cAC                   endif
500cAC                   else
500cAC                   eval      wkrg1c = *zeros
500cAC                   eval      wkrg2c = *zeros
500cAC                   eval      w1rg1c = *zeros
500cAC                   eval      w1rg2c = *zeros
500cAC                   endif
     *
500cAC                   endsr
