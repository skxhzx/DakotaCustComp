      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT741B    FTP RE-Export closed transfer/putaway trans - Post
     *  24 November 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
530 A*    11/24/09  MLB  5.30
     *      - Created.
530aA*    12/09/09  MLB  5.30a
     *      - Enh: Revised program to add support to retrieve
     *        license plate info for export to Host.
     *
640aA*    06/11/11  DAS  6.40a
     *      - Recompiled because of change to LICLOG file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC A*    11/24/09  MLB  SGC
     *      - Revised program to add support to process
     *        replenishment transactions.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpt741     ip   e           k disk
     FLabel90   if   e           k disk
     Fliclog2   if   e           k disk
     Fpiruser1  if   e           k disk
     Fvslot1    if   e           k disk
     Fflgtran   uf   e           k disk
     Fexpftrn3  o  a e           k disk
     *----------------------------------------------------------------
     *  Client ID
     *
SGC A /COPY QCOPYSRC,ID#SGC
     *----------------------------------------------------------------
     *  Working variables
     *
     D bslot           s                   like(lbdisp)
     D doflag          s              1
     D kydisp          s                   like(lbdisp)
     D today           s              8  0
     D x               s              2  0
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
     *  Move transaction info to export fields
     C                   exsr      fillpe
     *  Get user info.
     C     ptemp#        chain     piruser1                           79
     C                   if        not *in79
     C                   eval      peuser = uscode
     C                   endif
     C                   eval      doflag = *off
     *  Get label info.
     C     keylb         setll     label90
     C     1             do        10            x
     C     keylb         reade     label90                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *  Only process for putaway or transfer records.
     C                   if        lbtype <> 'P'  and
     C                             lbtype <> 'T'
SGC AC                             and client <> SGC
SGC A*
SGC A*  Only process for putaway, replenishment or transfer records.
SGC AC                             or client = SGC
SGC AC                             and lbtype <> 'P'
SGC AC                             and lbtype <> 'R'
SGC AC                             and lbtype <> 'T'
SGC A*
     C                   iter
     C                   endif
530aA*
530aA*  Get license plate info from license log file.
530aAC                   exsr      getlicloginf
     *
     C                   eval      peltyp = lbtype
     C                   eval      doflag = *on
     *
     *  Reset counter back to 1 so that label info is loaded
     *  into first occurence.
     C                   if        pttask = 'TFRMOV'
     C                             and x = 2
     C                   eval      x = x - 1
     C                   endif
     *
     C                   select
     ***
     C                   when      x = 1
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit1 = lbitem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdisp
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   endif
     C                   eval      pelqp1 = lbqpck
     C                   eval      peuom1 = lbutyp
530aAC                   eval      peolc1 = llolcns
530aAC                   eval      peflc1 = llflcns
530aAC                   eval      petlc1 = lllcns
     ***
     C                   when      x = 2
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit2 = lbitem
     C                   eval      pefsl2 = lbdisp
     C                   eval      kydisp = pefsl2
     C                   exsr      zzslot
     C                   eval      pefsl2 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit2 = lbitem
     C                   eval      petsl2 = lbdisp
     C                   eval      kydisp = petsl2
     C                   exsr      zzslot
     C                   eval      petsl2 = kydisp
     C                   endif
     C                   eval      pelqp2 = lbqpck
     C                   eval      peuom2 = lbutyp
530aAC                   eval      peolc2 = llolcns
530aAC                   eval      peflc2 = llflcns
530aAC                   eval      petlc2 = lllcns
     ***
     C                   when      x = 3
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit3 = lbitem
     C                   eval      pefsl3 = lbdisp
     C                   eval      kydisp = pefsl3
     C                   exsr      zzslot
     C                   eval      pefsl3 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit3 = lbitem
     C                   eval      petsl3 = lbdisp
     C                   eval      kydisp = petsl3
     C                   exsr      zzslot
     C                   eval      petsl3 = kydisp
     C                   endif
     C                   eval      pelqp3 = lbqpck
     C                   eval      peuom3 = lbutyp
530aAC                   eval      peolc3 = llolcns
530aAC                   eval      peflc3 = llflcns
530aAC                   eval      petlc3 = lllcns
     ***
     C                   when      x = 4
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit4 = lbitem
     C                   eval      pefsl4 = lbdisp
     C                   eval      kydisp = pefsl4
     C                   exsr      zzslot
     C                   eval      pefsl4 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit4 = lbitem
     C                   eval      petsl4 = lbdisp
     C                   eval      kydisp = petsl4
     C                   exsr      zzslot
     C                   eval      petsl4 = kydisp
     C                   endif
     C                   eval      pelqp4 = lbqpck
     C                   eval      peuom4 = lbutyp
530aAC                   eval      peolc4 = llolcns
530aAC                   eval      peflc4 = llflcns
530aAC                   eval      petlc4 = lllcns
     ***
     C                   when      x = 5
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit5 = lbitem
     C                   eval      pefsl5 = lbdisp
     C                   eval      kydisp = pefsl5
     C                   exsr      zzslot
     C                   eval      pefsl5 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit5 = lbitem
     C                   eval      petsl5 = lbdisp
     C                   eval      kydisp = petsl5
     C                   exsr      zzslot
     C                   eval      petsl5 = kydisp
     C                   endif
     C                   eval      pelqp5 = lbqpck
     C                   eval      peuom5 = lbutyp
530aAC                   eval      peolc5 = llolcns
530aAC                   eval      peflc5 = llflcns
530aAC                   eval      petlc5 = lllcns
     ***
     C                   when      x = 6
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit6 = lbitem
     C                   eval      pefsl6 = lbdisp
     C                   eval      kydisp = pefsl6
     C                   exsr      zzslot
     C                   eval      pefsl6 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit6 = lbitem
     C                   eval      petsl6 = lbdisp
     C                   eval      kydisp = petsl6
     C                   exsr      zzslot
     C                   eval      petsl6 = kydisp
     C                   endif
     C                   eval      pelqp6 = lbqpck
     C                   eval      peuom6 = lbutyp
530aAC                   eval      peolc6 = llolcns
530aAC                   eval      peflc6 = llflcns
530aAC                   eval      petlc6 = lllcns
     ***
     C                   when      x = 7
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit7 = lbitem
     C                   eval      pefsl7 = lbdisp
     C                   eval      kydisp = pefsl7
     C                   exsr      zzslot
     C                   eval      pefsl7 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit7 = lbitem
     C                   eval      petsl7 = lbdisp
     C                   eval      kydisp = petsl7
     C                   exsr      zzslot
     C                   eval      petsl7 = kydisp
     C                   endif
     C                   eval      pelqp7 = lbqpck
     C                   eval      peuom7 = lbutyp
530aAC                   eval      peolc7 = llolcns
530aAC                   eval      peflc7 = llflcns
530aAC                   eval      petlc7 = lllcns
     ***
     C                   when      x = 8
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit8 = lbitem
     C                   eval      pefsl8 = lbdisp
     C                   eval      kydisp = pefsl8
     C                   exsr      zzslot
     C                   eval      pefsl8 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit8 = lbitem
     C                   eval      petsl8 = lbdisp
     C                   eval      kydisp = petsl8
     C                   exsr      zzslot
     C                   eval      petsl8 = kydisp
     C                   endif
     C                   eval      pelqp8 = lbqpck
     C                   eval      peuom8 = lbutyp
530aAC                   eval      peolc8 = llolcns
530aAC                   eval      peflc8 = llflcns
530aAC                   eval      petlc8 = lllcns
     ***
     C                   when      x = 9
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit9 = lbitem
     C                   eval      pefsl9 = lbdisp
     C                   eval      kydisp = pefsl9
     C                   exsr      zzslot
     C                   eval      pefsl9 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit9 = lbitem
     C                   eval      petsl9 = lbdisp
     C                   eval      kydisp = petsl9
     C                   exsr      zzslot
     C                   eval      petsl9 = kydisp
     C                   endif
     C                   eval      pelqp9 = lbqpck
     C                   eval      peuom9 = lbutyp
530aAC                   eval      peolc9 = llolcns
530aAC                   eval      peflc9 = llflcns
530aAC                   eval      petlc9 = lllcns
     ***
     C                   when      x = 10
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                             or lbtype = 'R'
     C                   eval      pefit0 = lbitem
     C                   eval      pefsl0 = lbdisp
     C                   eval      kydisp = pefsl0
     C                   exsr      zzslot
     C                   eval      pefsl0 = kydisp
     C                   endif
     *
     C                   if        lbtype = 'R'
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   else
     C                   eval      petit0 = lbitem
     C                   eval      petsl0 = lbdisp
     C                   eval      kydisp = petsl0
     C                   exsr      zzslot
     C                   eval      petsl0 = kydisp
     C                   endif
     C                   eval      pelqp0 = lbqpck
     C                   eval      peuom0 = lbutyp
530aAC                   eval      peolc0 = llolcns
530aAC                   eval      peflc0 = llflcns
530aAC                   eval      petlc0 = lllcns
     ***
     C                   endsl
     C                   iter
     C                   enddo
     *
     C                   if        doflag = *on
     *  Add record to export file.
     C                   write     perec
     *
     *  Add record to history file FLGTRAN.
     *
     C                   exsr      fillfg
     C                   if        not *in78
     C                   update    fgrec
     C                   endif
     C                   else
     C                   clear                   perec
     C                   endif
     *
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define partial key for LABEL file.
     *
     C     keylb         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
530aA*
530aA*   Define partial key for LICLOG2 file.
530aA*
530aAC     keylc2        klist
530aAC                   kfld                    lbwhse
530aAC                   kfld                    lbtrn#
530aAC                   kfld                    lblbl#
     *
     *   Define key for FLGTRAN file.
     *
     C     keyfg         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     *
     *   Define partial key for VSLOT1 file.
     *
     C     keyvs         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    kydisp
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
530aA*
     *----------------------------------------------------------------
     *
     *  FILLPE   Fill export transaction fields.
     *
     C     fillpe        begsr
     *
     *  Initialize record
     *
     C                   clear                   perec
     *
     *  Move fields from transaction to export file.
     *
     C                   eval      petrn# = pttrn#
     C                   eval      petask = pttask
     C                   eval      pecat = ptcat
     C                   eval      pesub = ptsub
     C                   eval      pewhse = ptwhse
     C                   eval      pewhdp = ptwhdp
     C                   eval      pestyp = ptstyp
     C                   eval      peshft = ptshft
     C                   eval      pecrew = ptcrew
     C                   eval      peemp# = ptemp#
     C                   eval      pecube = ptcube
     C                   eval      peswgt = ptswgt
     C                   eval      pepcs = ptpcs
     C                   eval      peqty1 = ptqty1
     C                   eval      peqty2 = ptqty2
     C                   eval      peqty3 = ptqty3
     C                   eval      pegdte = ptgdte
     C                   eval      pegtim = ptgtim
     C                   eval      pesdte = ptsdte
     C                   eval      pestim = ptstim
     C                   eval      peedte = ptedte
     C                   eval      peetim = ptetim
     C                   eval      peetyp = ptetyp
     C                   eval      pertpo = ptrtpo
     C                   eval      pegrp1 = ptgrp1
     C                   eval      pegrp2 = ptgrp2
     *
     C                   endsr
530aA*
     *----------------------------------------------------------------
     *
     *  FILLFG  Fill flag fields.
     *
     C     fillfg        begsr
     *
     *
     C     keyfg         chain     flgtran                            78
     *
     *  Move fields from transaction to flag file.
     *
     C                   eval      fgrdte = today
     C                   time                    fgrtim
     *
     C                   endsr
530aA*
530aA*----------------------------------------------------------------
530aA*
530aA*  GETLICLOGINF   Get License Log info from file.
530aA*
530aAC     getlicloginf  begsr
530aA*
530aAC     keylc2        setgt     liclog2
530aAC     keylc2        readpe    liclog2
530aAC                   if        %eof(liclog2)
530aAC                   eval      lllcns  = ' '
530aAC                   eval      llolcns = ' '
530aAC                   eval      llflcns = ' '
530aAC                   endif
530aA*
530aAC                   endsr
530aA*
     *----------------------------------------------------------------
     *
     *  ZZSLOT  Get Base slot for Virtual if host only has base slots.
     *
     C     zzslot        begsr
     *
     *
     C     keyvs         chain     vslot1                             79
     *
     *  Use base slot.
     *
     C                   if        not *in79
     C                   eval      kydisp = vspdis
     C                   endif
     *
     C                   endsr
     *
