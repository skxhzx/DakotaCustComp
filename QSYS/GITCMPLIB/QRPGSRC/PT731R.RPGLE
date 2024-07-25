      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   Glen Ellyn, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT731R    FTP Export closed transfer/putaway trans - Post
     *  06 MAY 2008
     *  Max Blacknik
     *
     *  CREATED FROM PT729R - CREATED FOR FRF TO PROCESS ONLY PTTASK
     *  EQUAL TO 'PUTEMP' AND THEN WRITE THE EXPORT RECORDS WITH
     *  PETASK = RECV AND PESL1 = DUMMY WAREHOUSE AREAS.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    05/06/08  MLB  5.20
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    05/07/08  MLB  FRF
     *      - Added code to set PETSL1 to dummy slot based on PTWHDP
     *        for task code PUTEMP.
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
     Fflgtranr  o  a e           k disk
     Fexpftrn2  o  a e           k disk
     *----------------------------------------------------------------
     *  Client ID
     *
FRF A /COPY QCOPYSRC,ID#FRF
     *----------------------------------------------------------------
     *  Constants
     *
     D forever         c                   const('1')
     *----------------------------------------------------------------
     *  Working variables
     *
     D bslot           s                   like(lbdisp)
     D doflag          s              1
     D first           s              1  0
     D grtrn#          s              7  0
     D kydisp          s                   like(lbdisp)
     D today           s              8  0
     D x               s              2  0
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
     *  Use first transaction as group transaction.
     C                   if        first = 0
     C                   eval      grtrn# = pttrn#
     C                   eval      first = 1
     C                   endif
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
     C                   iter
     C                   endif
     *
     C                   eval      peltyp = lbtype
     C                   eval      doflag = *on
     *
     C                   select
     ***
     C                   when      x = 1
     *  If type 'A' item is "FROM" item.
     C                   if        lbgrp2 = 'A'
     C                   eval      pefit1 = lbitem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
     C                   else
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
     C                   eval      pefit2 = lbitem
     C                   eval      pefsl2 = lbdisp
     C                   eval      kydisp = pefsl2
     C                   exsr      zzslot
     C                   eval      pefsl2 = kydisp
     C                   else
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
     C                   eval      pefit3 = lbitem
     C                   eval      pefsl3 = lbdisp
     C                   eval      kydisp = pefsl3
     C                   exsr      zzslot
     C                   eval      pefsl3 = kydisp
     C                   else
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
     C                   eval      pefit4 = lbitem
     C                   eval      pefsl4 = lbdisp
     C                   eval      kydisp = pefsl4
     C                   exsr      zzslot
     C                   eval      pefsl4 = kydisp
     C                   else
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
     C                   eval      pefit5 = lbitem
     C                   eval      pefsl5 = lbdisp
     C                   eval      kydisp = pefsl5
     C                   exsr      zzslot
     C                   eval      pefsl5 = kydisp
     C                   else
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
     C                   eval      pefit6 = lbitem
     C                   eval      pefsl6 = lbdisp
     C                   eval      kydisp = pefsl6
     C                   exsr      zzslot
     C                   eval      pefsl6 = kydisp
     C                   else
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
     C                   eval      pefit7 = lbitem
     C                   eval      pefsl7 = lbdisp
     C                   eval      kydisp = pefsl7
     C                   exsr      zzslot
     C                   eval      pefsl7 = kydisp
     C                   else
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
     C                   eval      pefit8 = lbitem
     C                   eval      pefsl8 = lbdisp
     C                   eval      kydisp = pefsl8
     C                   exsr      zzslot
     C                   eval      pefsl8 = kydisp
     C                   else
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
     C                   eval      pefit9 = lbitem
     C                   eval      pefsl9 = lbdisp
     C                   eval      kydisp = pefsl9
     C                   exsr      zzslot
     C                   eval      pefsl9 = kydisp
     C                   else
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
     C                   eval      pefit0 = lbitem
     C                   eval      pefsl0 = lbdisp
     C                   eval      kydisp = pefsl0
     C                   exsr      zzslot
     C                   eval      pefsl0 = kydisp
     C                   else
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
     *  Add record to export file.
     C                   write     perec
     *
     *  Add record to history file FLGTRAN.
     *
     C                   exsr      fillfg
     C                   write     fgrec
     C                   else
     C                   clear                   perec
     C                   endif
     *
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     C*
     *
     *   Define partial key for LABEL file.
     *
     C     keylb         klist
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
FRF D**                   MOVE PTTASK    PETASK
FRF AC                   eval      petask = 'RECV  '
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
     *  Initialize record
     *
     C                   clear                   fgrec
     *
     *  Move fields from transaction to flag file.
     *
     C                   eval      fgwhse = ptwhse
     C                   eval      fgtrn# = pttrn#
     C                   eval      fgedte = today
     C                   time                    fgetim
     C                   eval      fggtrn = grtrn#
     C                   eval      fgrdte = 0
     C                   eval      fgrtim = 0
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
