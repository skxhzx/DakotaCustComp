     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UC225     FTP Import Item UPC Code Updates - Post
     *  30 August 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    08/30/04  MLB  5.00
     *      - Created.
     *
520 A*    07/30/09  MLB  5.20
     *      - Enh: Revised program to process new fields added to
     *        import file, IMPFUPC. UCVEN, UCVNAM, UCVITM.
     *      - Added file, ITEMMSC to pgm.
520aA*    07/30/09  MLB  5.20a
     *      - Enh: Revised program to check for upc/item combination
     *        already on file. If not found, then add to file.
     *      - Added file, UPC2 to pgm.
     *
700aA*    11/02/16  LMC  7.00a
     *      - Enh: UPC file has database change, we now store the UOM
     *        for the UPC code. We will assume in this program that
     *        the UPC codes being added are for the normal UOM.
730aA*    10/03/19  LMC  7.30a
     *      - Enh: Since people are using this to load UPC's for SSB
     *        items the upc file needs to be loaded correctly.
750a *    04/08/21  RTR  7.50a
     *      - Enh: Added UOM field to import file, so will use from
     *        the file instead of assuming normal UOM in mod 700a.
     *        if file UOM is blank, use logic from 700a/730a.
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there are only UPC codes for one
     *    warehouse in the member.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for IMPFUPC
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfupc   uf   e           k disk
     Fpiritem   if   e           k disk
520 AFitemmsc   if   e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fupc       uf a e           k disk
520aAFupc2      if   e           k disk    rename(uprec:uprec2)
     Fuc225pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     D desc            s             40    dim(11) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Working variables
     *
     D addrcd          s              1
     D eofi            s              1
     D error           s              1
     D first           s              1
     D forevr          s              1
     D impdte          s              6  0
     D imptim          s              6  0
     D kyupc           s                   like(upupc)
     D len             s              1  0
700aAD Ntype           s              7
     D pos             s              1  0
     D today           s              8  0
     D updrcd          s              1
     D work3a          s              3

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  $litem                22     36
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PINUP - Include invalid UPC codes (*YES/*NO).
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
     C     *entry        plist
     C                   parm                    $pinup            4
     *
     * Whip through all the download Update Item UPC records
     *
     C                   eval      first = *on
     C                   eval      *in91 = *on
     C                   eval      eofi = *off
     *
     C                   dou       eofi = *on
     *
     C                   read      impfupc                                79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
     C                   goto      enddiu
     C                   endif
     *
     C                   add       1             grdlin
     C                   eval      addrcd = *off
     C                   eval      updrcd = *off
     *   Control printing on detail line.
     C                   eval      *in40 = *on
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Print report heading if necessary.
     *
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     *    Make sure warehouse was entered.
     *
     C                   if        ucwhse = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   add       1             noitem
     *
     C                   write     detail                               91
     C                   goto      enddiu
     C                   endif
     *
     *    Make sure item was entered.
     *
     C                   if        ucitem = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     *
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     detail                               91
     C                   goto      enddiu
     C                   endif
     *
     *    Retrieve item description.
     C                   exsr      zzgtit
520 A*    Retrieve item misc. record.
520 AC                   exsr      zzgtim
     *
     C                   if        error = *on
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   eval      detmsg = desc(2)
     C                   write     detail                               91
     C                   goto      enddiu
     C                   endif
     *
     *
     C                   select
     *    Delete UPC code from file.
     C                   when      ucutyp = 'D'
     C                   eval      kyupc = *blanks
     C                   evalr     kyupc = %trimr(ucupc)
     C                   exsr      zzgtuc
     *  UPC code on file. Okay to delete.
     C                   if        not *in76
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   exsr      zzdelu
     *
     C                   eval      detmsg = desc(3)
     C                   write     detail                               91
     C                   endif
     *
     *
     *    Add/Update UPC Code imported for item.
     C                   when      ucutyp <> 'D'
     *
     C                   eval      kyupc = *blanks
     C                   evalr     kyupc = %trimr(ucupc)
520aA*
520aAC                   exsr      zzgtuc2
520aAC                   if        %found(upc2)
     C                   exsr      zzgtuc
520aAC                   endif
     *
     *  Validate UPC code imported for item.
     C                   exsr      zzckup
     *
     C                   select
     *    Invalid UPC code imported for item.
     C                   when      $cbrtn <> '*OK     '
     *
700aAc                   eval      ntype = %trimr($cbrtn)
     C                   add       1             badupc
     *  UPC code not on file and code is invalid.
     *  Okay to add invalid codes.
     C                   if        *in76
     C                   if        $pinup = '*YES'
     C                   eval      detmsg = desc(4)
     C                   eval      addrcd = *on
     *
     C                   else
     *  Not Okay to add invalid codes.
     C                   eval      detmsg = desc(5)
     C                   endif
     *
     C                   else
     *  UPC code on file and code is invalid.
     *  Okay to update invalid codes.
     C                   if        $pinup = '*YES'
     C                   eval      detmsg = desc(6)
     C                   eval      updrcd = *on
     *
     C                   else
     *  Not Okay to update invalid codes.
     C                   eval      detmsg = desc(7)
     C                   endif
     C                   endif
     *
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     detail                               91
     *
     *       Load 2nd level error message text.
     C                   eval      *in40 = *off
     C                   movel     $cberm        detmsg
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     detail                               91
     C                   eval      *in40 = *on
     *
     *
     *    Valid UPC code imported for item.
     C                   when      $cbrtn = '*OK     '
700aAc                   eval      ntype = %trimr($cbdsc)
     *
     *  UPC code not on file and code is valid.
     C                   if        *in76
     C                   eval      detmsg = desc(8)
     C                   eval      addrcd = *on
     *
     C                   else
     *  UPC code on file and code is valid.
     C                   eval      detmsg = desc(9)
     C                   eval      updrcd = *on
     C                   endif
     *
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     detail                               91
     C                   endsl
     *
     *  Update UPC code file.
     C                   if        addrcd     = *on
     C                             or updrcd  = *on
     C                   exsr      zzupdu
     C                   endif
     *
     C                   endsl
     *
     *       Delete detail record from download file
     *
     C                   delete    ucrec
     *
     C     enddiu        tag
     C                   enddo
     *
     *
     *  Print order grand totals
     *
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     grndttl                              91
     *
     *  Print End of report footer.
     C                   if        *in91
     C                   exsr      zrhead
     C                   endif
     *
     C                   write     foot1                                91
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Key definitions
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    ucwhse
     C                   kfld                    ucitem
     *
     *  Define key for UPC file.
     *
     C     uckey         klist
     C                   kfld                    ucwhse
     C                   kfld                    kyupc
520aA*
520aA*  Define key for UPC2 file.
520aA*
520aAC     uc2key        klist
520aAC                   kfld                    ucwhse
520aAC                   kfld                    ucitem
520aAC                   kfld                    kyupc
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKUP   Validate UPC code.
     *
     C     zzckup        begsr
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = ucupc
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDELU   Delete selected UPC code.
     *
     C     zzdelu        begsr
     *
     C                   delete    uprec
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGTIT   Get item master record.cking ITEMQTY.
     *
     C     zzgtit        begsr
     *
     C     itkey         chain     piritem                            77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      itdesc = *blanks
520 AC                   eval      itven# = 0
520 AC                   eval      itvit# = ' '
     C                   endif
     *
     C                   endsr
520 A*
520 A*----------------------------------------------------------------
520 A*
520 A*  ZZGTIM   Get item master Miscelleaneous record.
520 A*
520 AC     zzgtim        begsr
520 A*
520 AC     itkey         chain     itemmsc
520 AC                   if        not %found(itemmsc)
520 AC                   eval      imvnam = ' '
520 AC                   eval      imbrnd = ' '
520 AC                   endif
520 A*
520 AC                   endsr
520 A*
     *----------------------------------------------------------------
     *
     *  ZZGTUC   Get item UPC code.
     *
     C     zzgtuc        begsr
     *
     C     uckey         chain     upc                                76
     C                   if        *in76
     C                   clear                   uprec
     C                   endif
     *
     C                   endsr
520aA*
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZGTUC2   Get item UPC code.
520aA*
520aAC     zzgtuc2       begsr
520aA*
520aAC     uc2key        chain     upc2
520aAC                   if        not %found(upc2)
520aAC                   eval      *in76 = '1'
520aAC                   endif
520aA*
520aAC                   endsr
520aA*
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd6o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'UC225PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     ucwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      ucwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = *zeros
     C                   eval      noitem = *zeros
     C                   eval      badupc = *zeros
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPDU   Update UPC file.
     *
     C     zzupdu        begsr
     *
     *  UPC code not on file. Add record.
     C                   if        *in76 = *on
     C                   eval      upwhse = ucwhse
     C                   eval      upitem = ucitem
     C                   eval      upupc = kyupc
750aAc                   eval      upuom = ucuom
700aAc* load up the new upc fields
700aA /free
730aA   if ittype <> 'S';
700aA     uputyp = 'N';
750aA     if upuom  = *blanks;
700aA       upuom  = itum1;
750aA     endif;
730aA   else;
730aA     uputyp = '1';
750aA     if upuom  = *blanks;
730aA       upuom  = itum2;
750aA     endif;
730aA   endif;
700aA   Select;
700aA     when ntype = 'UPC-12';
700aA       upctyp = '1';
700aA     when ntype = 'EAN-13';
700aA       upctyp = '2';
700aA     when ntype = 'GTIN';
700aA       upctyp = '3';
700aA     when ntype = 'SCC-14';
700aA       upctyp = '4';
700aA     when ntype = 'SSCC-18';
700aA       upctyp = '5';
700aA     other;
700aA       upctyp = '6';
700aA   endsl;
700aA /end-free
520 A*
520 A*  Load vendor number sent from Host.
520 AC                   if        ucven > 0
520 AC                   eval      upven = ucven
520 AC                   else
520 AC                   eval      upven = itven#
520 AC                   endif
520 AC
520 A*
520 A*  Load vendor name sent from Host.
520 AC                   if        ucvnam > ' '
520 AC                   eval      upvnam = ucvnam
520 AC                   else
520 AC                   eval      upvnam = imvnam
520 AC                   endif
520 AC
520 A*
520 A*  Load vendor item# sent from Host.
520 AC                   if        ucvitm > ' '
520 AC                   eval      upvitm = ucvitm
520 AC                   else
520 AC                   eval      upvitm = itvit#
520 AC                   endif
520 AC
     C                   write (e) uprec
     C                   if        %error
     C                   if        *in91 = *on
     C                   exsr      zrhead
     C                   endif
     C                   eval      detmsg = desc(10)
     C                   write     detail                               91
     C                   endif
     *
     *  UPC code on file. Release record lock.
     C                   else
     *
     C                   eval      upitem = ucitem
520 A*
520 A*  Load vendor number sent from Host.
520 AC                   if        ucven > 0
520 AC                   eval      upven = ucven
520 AC                   endif
520 AC
520 A*
520 A*  Load vendor name sent from Host.
520 AC                   if        ucvnam > ' '
520 AC                   eval      upvnam = ucvnam
520 AC                   endif
520 AC
520 A*
520 A*  Load vendor item# sent from Host.
520 AC                   if        ucvitm > ' '
520 AC                   eval      upvitm = ucvitm
520 AC                   endif
520 AC
     C                   update(e) uprec
     C                   if        %error
     C                   if        *in91 = *on
     C                   exsr      zrhead
     C                   endif
     C                   eval      detmsg = desc(11)
     C                   write     detail                               91
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   write     head1                                91
     *
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*Invalid warehouse
*Invalid item
*UPC code deleted.
*Invalid UPC code. Record added.
*Invalid UPC code. Record not added.
*Invalid UPC code. Record updated.
*Invalid UPC code. Record not updated.
*UPC code added.
*UPC code updated.
Duplicate UPC code. Record not added.
Duplicate UPC code. Record not updated.
