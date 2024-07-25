      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT731B    FTP RE-Export closed transfer/putaway trans - Post
     *  06 May 2008
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*    05/07/08  MLB  5.20
     *      - Created.
520aA*    06/05/08  MLB  5.20a
     *      - Fix: Revised program to correctly load TFRMOV label
     *        into first from/to fields instead of making 2 rcds.
520bA*    06/05/08  MLB  5.20b
     *      - Fix: Revised program to correctly load label type
     *        R=Replenishments from item/slot info.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    05/07/08  MLB  FRF
     *      - Added code to set PETSL1 to dummy slot based on PTWHDP
     *        for task code PUTEMP.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
SGC A*    06/05/08  MLB  SGC
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
     Fpt731     ip   e           k disk
     FLabel90   if   e           k disk
     Fpiruser1  if   e           k disk
     Fvslot1    if   e           k disk
     Fflgtran   uf   e           k disk
     Fexpftrn2  o  a e           k disk
     *----------------------------------------------------------------
     *  Client ID
     *
FRF A /COPY QCOPYSRC,ID#FRF
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
     *
     C                   eval      peltyp = lbtype
     C                   eval      doflag = *on
520aA*
520aA*  Reset counter back to 1 so that label info is loaded
520aA*  into first occurence.
520aAC                   if        pttask = 'TFRMOV'
520aAC                             and x = 2
520aAC                   eval      x = x - 1
520aAC                   endif
     *
     C                   select
     ***
     C                   when      x = 1
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit1 = lbitem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdisp
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   endif
     C                   eval      pelqp1 = lbqpck
     C                   eval      peuom1 = lbutyp
     ***
     C                   when      x = 2
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit2 = lbitem
     C                   eval      pefsl2 = lbdisp
     C                   eval      kydisp = pefsl2
     C                   exsr      zzslot
     C                   eval      pefsl2 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit2 = lbitem
     C                   eval      petsl2 = lbdisp
     C                   eval      kydisp = petsl2
     C                   exsr      zzslot
     C                   eval      petsl2 = kydisp
     C                   endif
     C                   eval      pelqp2 = lbqpck
     C                   eval      peuom2 = lbutyp
     ***
     C                   when      x = 3
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit3 = lbitem
     C                   eval      pefsl3 = lbdisp
     C                   eval      kydisp = pefsl3
     C                   exsr      zzslot
     C                   eval      pefsl3 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit3 = lbitem
     C                   eval      petsl3 = lbdisp
     C                   eval      kydisp = petsl3
     C                   exsr      zzslot
     C                   eval      petsl3 = kydisp
     C                   endif
     C                   eval      pelqp3 = lbqpck
     C                   eval      peuom3 = lbutyp
     ***
     C                   when      x = 4
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit4 = lbitem
     C                   eval      pefsl4 = lbdisp
     C                   eval      kydisp = pefsl4
     C                   exsr      zzslot
     C                   eval      pefsl4 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit4 = lbitem
     C                   eval      petsl4 = lbdisp
     C                   eval      kydisp = petsl4
     C                   exsr      zzslot
     C                   eval      petsl4 = kydisp
     C                   endif
     C                   eval      pelqp4 = lbqpck
     C                   eval      peuom4 = lbutyp
     ***
     C                   when      x = 5
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit5 = lbitem
     C                   eval      pefsl5 = lbdisp
     C                   eval      kydisp = pefsl5
     C                   exsr      zzslot
     C                   eval      pefsl5 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit5 = lbitem
     C                   eval      petsl5 = lbdisp
     C                   eval      kydisp = petsl5
     C                   exsr      zzslot
     C                   eval      petsl5 = kydisp
     C                   endif
     C                   eval      pelqp5 = lbqpck
     C                   eval      peuom5 = lbutyp
     ***
     C                   when      x = 6
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit6 = lbitem
     C                   eval      pefsl6 = lbdisp
     C                   eval      kydisp = pefsl6
     C                   exsr      zzslot
     C                   eval      pefsl6 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit6 = lbitem
     C                   eval      petsl6 = lbdisp
     C                   eval      kydisp = petsl6
     C                   exsr      zzslot
     C                   eval      petsl6 = kydisp
     C                   endif
     C                   eval      pelqp6 = lbqpck
     C                   eval      peuom6 = lbutyp
     ***
     C                   when      x = 7
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit7 = lbitem
     C                   eval      pefsl7 = lbdisp
     C                   eval      kydisp = pefsl7
     C                   exsr      zzslot
     C                   eval      pefsl7 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit7 = lbitem
     C                   eval      petsl7 = lbdisp
     C                   eval      kydisp = petsl7
     C                   exsr      zzslot
     C                   eval      petsl7 = kydisp
     C                   endif
     C                   eval      pelqp7 = lbqpck
     C                   eval      peuom7 = lbutyp
     ***
     C                   when      x = 8
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit8 = lbitem
     C                   eval      pefsl8 = lbdisp
     C                   eval      kydisp = pefsl8
     C                   exsr      zzslot
     C                   eval      pefsl8 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit8 = lbitem
     C                   eval      petsl8 = lbdisp
     C                   eval      kydisp = petsl8
     C                   exsr      zzslot
     C                   eval      petsl8 = kydisp
     C                   endif
     C                   eval      pelqp8 = lbqpck
     C                   eval      peuom8 = lbutyp
     ***
     C                   when      x = 9
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit9 = lbitem
     C                   eval      pefsl9 = lbdisp
     C                   eval      kydisp = pefsl9
     C                   exsr      zzslot
     C                   eval      pefsl9 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit9 = lbitem
     C                   eval      petsl9 = lbdisp
     C                   eval      kydisp = petsl9
     C                   exsr      zzslot
     C                   eval      petsl9 = kydisp
     C                   endif
     C                   eval      pelqp9 = lbqpck
     C                   eval      peuom9 = lbutyp
     ***
     C                   when      x = 10
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
520bAC                             or lbtype = 'R'
     C                   eval      pefit0 = lbitem
     C                   eval      pefsl0 = lbdisp
     C                   eval      kydisp = pefsl0
     C                   exsr      zzslot
     C                   eval      pefsl0 = kydisp
520bDC*                  else
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
     C                   eval      petit0 = lbitem
     C                   eval      petsl0 = lbdisp
     C                   eval      kydisp = petsl0
     C                   exsr      zzslot
     C                   eval      petsl0 = kydisp
     C                   endif
     C                   eval      pelqp0 = lbqpck
     C                   eval      peuom0 = lbutyp
     ***
     C                   endsl
     C                   iter
     C                   enddo
     *
     C                   if        doflag = *on
FRF A*
FRF AC                   if        client = FRF
FRF A*
FRF AC                   if        pttask = 'PUTEMP'
FRF AC                   eval      petsl1 = *blanks
FRF A*
FRF AC                   select
FRF AC                   when      ptwhdp = 'DRY  '
FRF AC                   movel     '72000'       petsl1
FRF AC                   when      ptwhdp = 'FRZ  '
FRF AC                   movel     '03JIM'       petsl1
FRF AC                   when      ptwhdp = 'CLR  '
FRF AC                   movel     '94COL'       petsl1
FRF AC                   endsl
FRF A*
FRF AC                   endif
FRF A*
FRF AC                   endif
FRF A*
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
