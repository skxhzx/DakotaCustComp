     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT730B    FTP Re-Export closed replenishment trans - Post
     *  24 February 2005
     *  Max Blacknik
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    02/24/05  MLB  5.00
     *      - Created.
     *
510aA*    06/25/06  MLB  5.10a
     *      - Fix: Revised program to write out a "dummy" record at
     *        program end so that at least 1 record is always sent
     *        back to Host system.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpt730     ip   e           k disk
     FLabel90   if   e           k disk
     Fpiruser1  if   e           k disk
     Fvslot1    if   e           k disk
     Fflgtran2  uf   e           k disk
     Fexpfrpl   o  a e           k disk
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM

     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     D bslot           s                   like(lbdisp)
     D doflag          s              1
     D kydisp          s                   like(lbdisp)
     D today           s              8  0
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
     *
     C     keylb         reade     label90
     C                   dow       not %eof(label90)
     *
     *  Only process for replenishment records.
     C                   If        lbtype = 'R'
     *
     *  Only process for replenishment records.
     *
     C                   eval      peltyp = lbtype
     C                   eval      doflag = *on
     *
     *   Check if task code is REPLBK and if so go out and get base item
     C                   if        pttask = 'REPLBK'
     C                   exsr      getitem
     C                   if        error
     C                   eval      error = *off
     C                   eval      pefit1 = '** NOT FOUND **'
     C                   endif
     *   Load "FROM" slot/item info.
     C                   eval      pefit1 = $ititem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
     *   Load "TO" slot/item info.
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp

     *
     *   Process Normal item replenishment or replenishment/transfer.
     C                   else

     *   Load "FROM" slot/item info.
     C                   eval      pefit1 = lbitem
     C                   eval      pefsl1 = lbdisp
     C                   eval      kydisp = pefsl1
     C                   exsr      zzslot
     C                   eval      pefsl1 = kydisp
     *
     *   Load "TO" slot/item info.
     C                   eval      petit1 = lbitem
     C                   eval      petsl1 = lbdsp2
     C                   eval      kydisp = petsl1
     C                   exsr      zzslot
     C                   eval      petsl1 = kydisp
     C                   endif
     C                   eval      pelqpl = lbqpck
     *
     *   When processing REPLBK, Eaches qty replen'd is stored
     *   Label qty remaining field.
     C                   if        pttask = 'REPLBK'
     C                   eval      pelqrp = lbqrmn
     C                   else
     C                   eval      pelqrp = lbqpck
     C                   endif
     C                   eval      peuom1 = lbutyp
     *
     C                   endif
     *
     C     keylb         reade     label90
     *
     C                   enddo
     *
     *
     C                   if        doflag = *on
     *  Add record to export file.
     C                   write     rplrec
     *
     *  Add record to history file FLGTRAN.
     *
     C                   exsr      fillfg
     C                   if        not *in78
     C                   update    fgrec
     C                   endif
     C                   else
     C                   clear                   rplrec
     C                   endif
     *
     C     bottom        tag
510aA*
510aA*      Write out trailer record so that at least one record
510aA*      in file, even when no replenishments found.
510aACLR                 clear                   rplrec
510aACLR                 eval      petask = 'END   '
510aACLR                 write (e) rplrec
510aA*
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
     *   Define partial key for LABEL file.
     *
     C     keylb         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     *
     *   Define key for FLGTRAN2 file.
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
     C                   clear                   rplrec
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
     C     keyfg         chain     flgtran2                           78
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
     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      error = *off
     C                   clear                   $item

     C                   eval      $itwhse = ptwhse
     C                   eval      $ititem = lbitem

     C                   call(e)   'DRIITEM'
     C                   parm      '*GETBASE  '  $drisubcmd
     C                   parm      'PT730'       $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + 'PT730'
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

