650aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT376     Item Slot List in Picking Order
     *  Roxanne Harrison
     *  15 January, 2002
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/16/02  RH   4.16
     *      - Created
     *    12/16/02  RH   4.16a
     *      - Add * to print if pick slot.
     *    03/18/03  RH   4.17a
     *      - Change to print for item range.
     *      - Print pick slot first, then overflow in aisle/location
     *        order.
500aA*    06/09/05  RLP  5.00a
     *      - Problem when called from IT110, because $TITEM is blank
     *        the program drops out prematurely, just printing footer.
     *        Added logic to set $TITEM to same value as incoming item.
500bA*    06/09/05  RLP  5.00b
     *      - FIX: Was reporting only 1 pick slot for item and
     *             not picking up all slots for PIR items.
     *      - ENH: added SLSTAT field to report.
500cA*    07/20/05  RH   5.00c
     *      - ENH: Add 1st UPC code found for item.
     *
510 A*    07/14/06  JCJ  5.10
     *      - ENH: Changed program to use SLOT9 (new logical) instead
     *             of SLOT4.  Needed to read the slot file without
     *             department as part of the key list. This will allow
     *             slots that have a different department than the
     *             department of the item to print.
     *
610a *    01/25/10  GJA  6.10a
     *      - ENH: Changed program to print license plate.
     *             Converted to RPGLE
     *
640 A*    07/21/11  MLB  6.40
     *      - Enh: Revised program to make printer file usropn
     *        controlled. Added call to GETRPT to get default
     *        printer and formtype values.
     *
650aA*    07/15/13  RTR  6.50a
     *      - Enh: Major rework to also list repack parents/children
     *
700 A*    09/27/17  JGD  7.00
     *      - Add logic to process information added to report
     *       Mfg item # and Entered date. This info is replacing
     *       UPC # and Status info on report.
     *
700aA*    06/01/16  LMC/RH  7.00a
     *      - Enh: Add itemqty totals at LR
     *
700bA*    11/03/16  LMC  7.00b
     *      - Enh: UPC file has a database change. Recompile only.
     *
720 A*    07/17/18  MLB  7.20
     *      - Enh: Added client custom code support to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    07/17/18  MLB  CWD
     *      - Revised pgm to seton ind 62 so that UPC code will be
     *        printed on report instead of Mfr Item# from UPC file.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
CWD A*  61        Print Mfr Item# on report.
CWD A*  62        Print UPC code on report.
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
510 D*SLOT4   IF  E           K        DISK
510 MFslot9     if   e           k disk
     F                                     rename(slrec:record)
     Fslot3     if   e           k disk
     Fwarehs    if   e           k disk
500c Fupc1      if   e           k disk
700 AFlicactive1if   e           k disk
700a Fitemqty   if   e           k disk
     Fit376pr   o    e             printer oflind(*in90)
640 AF                                     usropn
720 A*----------------------------------------------------------------
720 A*  Customer id
720 A*
720 AD @getcl          c                   const('GETCLIENT')
720 A*
CWD A /copy qcopysrc,id#cashwa
720 A*
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
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS

610aA /COPY *libl/qcopysrc,C#SLOT
610aAD savever#        s                   like($slver#)
610aA*----------------------------------------------------------------
610aA*  Program info data structure
610aA*
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

650aA*----------------------------------------------------------------
650aA*  Standard variables and constants
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,c#stdvar
650aA
650aA*----------------------------------------------------------------
650aA*  Standard SQL variables and constants
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,c#stdsql
650aA
     *----------------------------------------------------------------
     *  Variables
650aAD $item           s             15a
650aAD $item1          s             15a
650aAD $item2          s             15a
650aAD $item3          s             15a
     D $kwhse          s              3  0
     D $plen           s              3  0
     D $pstr           s             60
650aAD $titem          s             15a
     D count           s              3  0
650aAD curritem        s             15a
     D eof1            s              1
     D first           s              1
650aAD it2ind          s              5i 0
650aAD it3ind          s              5i 0
     D prtlin          s              3  0
     D qty1            s              5  0
     D qty2            s              3  0
     D qty3            s              3  0
     D svitem          s             15
     D svwhdp          s                   like(slwhdp)
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $whse             3
650aDC*                  parm                    $item            15
650aDC*                  parm                    $titem           15
650aMC                   parm                    $pitem           15
650aMC                   parm                    $ptitem          15
     C                   move      $whse         $kwhse
640 A*
640 AC                   exsr      opnprt
     *
650aA /free
650aA    // Select all piritem and itemlnk records for the range
650aA    Exec Sql
650aA      declare ItemRange cursor for
650aA        Select ITITEM, ILITEM, ILITM2
650aA        from PIRITEM Left Join ITEMLNK
650aA         on (ititem = ilitem or ititem = ilitm2)
650aA        where ITWHSE = :$whse
650aA         and ITITEM >= :$pitem
650aA         and ITITEM <= :$ptitem
650aA        order by ITITEM;
650aA
650aA    exec sql open ItemRange;
650aA    if sqlstt <> sqlSuccess;
650aA      dump(a);
650aA    endif;
650aA
650aA    dow forever = forever;
650aA
650aA      exec sql fetch next from ItemRange
650aA               into :$item1, :$item2:it2ind, :$item3:it3ind;
650aA
650aA      if sqlstt <> sqlSuccess;
650aA        leave;
650aA      endif;
650aA
650aA      if $item1 <> curritem;     // if new item print it
650aA        curritem = $item1;       // save the item we are working on
650aA        $item = $item1;
650aA        *in90 = *off;
650aA        write head1;
650aA        write columns;
650aA        exsr PrtItm;             // print item
650aA      endif;
650aA
650aA      if it2ind = 0
650aA       and $item2 <> $item1;
650aA        $item = $item2;
650aA        write skip1;
650aA        exsr PrtItm;             // print linked parent/child item
650aA      endif;
650aA
650aA      if it3ind = 0
650aA       and $item3 <> $item1;
650aA        $item = $item3;
650aA        write skip1;
650aA        exsr PrtItm;             // print linked parent/child item
650aA      endif;
650aA
650aA    enddo;
650aA
650aA    exec sql close ItemRange;
650aA
650aA /end-free
     C                   eval      *inlr = *on
700aA /free
700aA    if *inlr = *on;
700aA      chain ($kwhse: $pitem) itemqty;
700aA      write skip1;
700aA      write total1;
700aA    endif;
700aA /end-free
     CLr                 write     skip1
417A CLr                 write     foot1
     CLr                 write     foot2
     *
     *****************************************************************
     *  SUBROUTINES
     *****************************************************************
650aA*
650aAC     PrtItm        begsr
     *
650aAC     itkey         chain     piritem                            78
650aDC**   itkey         setll     piritem                            78
417aD*          ITKEY     READEPIRITEM                  78
650aDC**                 dow       forever = forever
650aDC**                 read      piritem                                78
     C                   if        *in78
     C                   goto      out
     C                   endif
650aDC*                  if        ititem < $item  or
650aDC*                            ititem > $titem  and
650aDC*                            $titem <> *blanks
650aDC*                  goto      out
650aDC*                  endif
     *
650aDC*                  if        itwhse <> $kwhse
     **         ITITEM    ORNE $ITEM
650aDC*                  goto      out
650aDC*                  endif
     *
500c *  Get UPC code.
500c C     itkey         setll     upc1                               79
500c C     itkey         reade     upc1                                   79
500c C                   if        *in79
500c C                   eval      upupc = *blanks
500c C                   endif
     *
     *  Report Foot
650aDC*                  if        svitem <> ititem  and
650aDC*                            first <> *on
650aDC*                  write     skip1
650aDC*                  write     foot1
650aDC*                  endif
     *  Report Heading
     *
     *
650aDC*                  if        *in90  or
650aDC*                            first = *on  or
650aDC*                            svitem <> ititem
650aDC*                  exsr      zrfrmt
650aDC*                  exsr      zrhead
650aDC*                  endif
650aAC                   write     head2
     *
     * Detail Calcs
     *
     C                   eval      prtlin = 0
     C                   seton                                        61
CWD A*
CWD AC                   if        client = CashWa
CWD A*       Print UPC code.
CWD AC                   eval      *in62 = '1'
CWD AC                   else
CWD A*       Print Mfr Item# from UPC file.
CWD AC                   eval      *in62 = '0'
CWD AC                   endif
CWD A*
     * Process pick slot first
417a C     slkey         setll     slot3                              79
500bAC                   move      *in79         eof1
500bAC                   dow       eof1 = *off
417a C     slkey         reade     slot3                                  79
500bAC                   move      *in79         eof1
417a C                   if        not *in79  and
417a C                             slpick = 'Y'
416a C                   eval      *in10 = *on
417a C                   exsr      zzfill
417a C   61              write     skip1
417a C                   write     detail1
500bD*                    WRITESKIP1
417a C                   eval      svitem = ititem
417a C                   endif
500bAC                   enddo
     *
     * Process overflow slots.
510 D**         SLKEY4    SETLLSLOT4                79
510 MC     slkey9        setll     slot9                              79
     C                   move      *in79         eof1
500bAC                   write     skip1
     C                   dow       eof1 = *off
510 D**         SLKEY4    READESLOT4                    79
510 MC     slkey9        reade     slot9                                  79
     C                   move      *in79         eof1
     C                   if        not *in79
416a * Pick slot
416a C                   if        slpick = 'Y'
416a C                   eval      *in10 = *on
416a C                   iter
416a C                   else
416a C                   eval      *in10 = *off
416a C                   endif
     * Retrieve license plate
610aAC                   eval      lcns = *blanks
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = slwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = slwhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = sldisp
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%GET'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   exsr      zzzdricop
610aAC                   if        error = *on
610aAC                   eval      error = *off
610bMC                   eval      $saToPos = 0
610aAC                   endif
     *
610aAC                   eval      lcns = $saToLcns
     *
417a *  Moved code to ZZFILL
417a C                   exsr      zzfill
     *
     *
     *  Do not print item info., if more than 1 item found
     C                   if        prtlin > 1
     C                   setoff                                       61
     C                   endif
     *
     *
     *  Start a new page, if change in department.
     *
     **         SVWHDP    IFNE *BLANKS
     **         SLWHDP    ANDNESVWHDP
     **                   EXSR ZRFRMT
     **                   EXSR ZRHEAD
     **                   ENDIF
     **                   MOVE SLWHDP    SVWHDP
     *
     C   61              write     skip1
     C                   write     detail1
416A C                   write     skip1
417a C                   eval      svitem = ititem
     *
     C                   endif
     C                   enddo
     *
     C                   eval      first = *off
650aDC***                enddo
     *
     C     out           tag
     *
650aAC     PrtItmEnd     endsr
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
720 A*
720 A* Get client id.
720 A*
720 AC                   call      @getcl
720 AC                   parm                    client           10
720 AC                   parm                    clientloc        10
     *
417a C                   eval      forever = *on
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      prtlin = 0
     C                   eval      svwhdp = *blanks
     *
     * If called from IT110, set "To" item = "From" item
     *
500aAC                   if        $titem = *blanks
500aAC                   eval      $titem = $item
500aAC                   endif
     *
     *  Key fields
     *
     C     slkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    ititem
417a *
510 D**         SLKEY4    KLIST
510 D**                   KFLD           $KWHSE
510 D**                   KFLD           ITWHDP
510 D**                   KFLD           ITITEM
510 A*
510 AC     slkey9        klist
510 AC                   kfld                    $kwhse
510 AC                   kfld                    ititem
     *
     C     itkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    $item
     *
     C     whkey         klist
     C                   kfld                    $kwhse
     *
700 AC     lickey        klist
700 AC                   kfld                    $kwhse
700 AC                   kfld                    slwhdp
700 AC                   kfld                    sldisp
700 AC                   kfld                    slitem
700  *
     C                   endsr
     *****************************************************************
     *
     *  FRMQTY  Format quantity.
     *
     C     frmqty        begsr
     *
     *  STOCK QUANTITY
     C                   eval      qty1 = slstk1
     C                   eval      qty2 = slstk2
     C                   eval      qty3 = slstk3
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = qty1
     C                   eval      $pqty2 = qty2
     C                   eval      $pqty3 = qty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     C                   eval      w1stk = $pqstr
     *  ALLOCATED QTY
     C                   eval      qty1 = slalc1
     C                   eval      qty2 = slalc2
     C                   eval      qty3 = slalc3
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = qty1
     C                   eval      $pqty2 = qty2
     C                   eval      $pqty3 = qty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $pum1
     C                   parm                    $pum2
     C                   parm                    $pum3
     C                   parm                    $pqstr
     C                   parm                    $pustr
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1alc = $pqstr
     *  PICKED QTY
     C                   eval      qty1 = slpck1
     C                   eval      qty2 = slpck2
     C                   eval      qty3 = slpck3
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = qty1
     C                   eval      $pqty2 = qty2
     C                   eval      $pqty3 = qty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $pum1
     C                   parm                    $pum2
     C                   parm                    $pum3
     C                   parm                    $pqstr
     C                   parm                    $pustr
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1pck = $pqstr
     *  TRANSFER QTY
     C                   eval      qty1 = sltfr1
     C                   eval      qty2 = sltfr2
     C                   eval      qty3 = sltfr3
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = qty1
     C                   eval      $pqty2 = qty2
     C                   eval      $pqty3 = qty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $pum1
     C                   parm                    $pum2
     C                   parm                    $pum3
     C                   parm                    $pqstr
     C                   parm                    $pustr
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1tfr = $pqstr
     *  RECEIVE QTY
     C                   eval      qty1 = slrcv1
     C                   eval      qty2 = slrcv2
     C                   eval      qty3 = slrcv3
     *
     *    Create a quantity string to print.
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = qty1
     C                   eval      $pqty2 = qty2
     C                   eval      $pqty3 = qty3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $pum1
     C                   parm                    $pum2
     C                   parm                    $pum3
     C                   parm                    $pqstr
     C                   parm                    $pustr
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1rcv = $pqstr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      wowhse = *blanks
     C     whkey         chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        wowhse
     C                   else
     C                   eval      wowhse = *blanks
     C                   endif
     *
     C                   eval      $pstr = wowhse
     C                   eval      $plen = 60
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   eval      wowhse = $pstr
     *
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     C                   write     head1
     C                   write     columns
417a C                   write     head2
     *
     C                   endsr
     *****************************************************************
     *
417a C     zzfill        begsr
     *
     * Expired date
     *
     C                   if        slexpd <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     C                   else
     C                   eval      w1expd = 0
     C                   endif
700 A*
700 A* Entered date
700 A*
700 AC     lickey        chain     licactive1                         78
700 AC                   if        not *in78

700 AC                   if        laentd <> 0
700 AC                   eval      $cvcmd = '*CMDMDY '
700 AC                   move      laentd        $cvd8i
700 AC                   call      @cvtdt
700 AC                   parm                    $cvtdt
700 AC                   eval      w1edte = $cvd6o
700 AC                   else
700 AC                   eval      w1edte = 0
700 AC                   endif

700 AC                   else
700 AC                   eval      w1edte = 0
700 AC                   endif
     *  Format quantity
     C                   exsr      frmqty
     C                   add       1             prtlin
     *
     C                   endsr
610aA*----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

640 A*----------------------------------------------------------------
640 A*  opnprt    Open printer and process ovrprtf cmd
640 A*----------------------------------------------------------------
640 A
640 AC     opnprt        begsr
640 A*
640 AC                   if        %open(it376pr)
640 AC                   close     it376pr
640 AC                   endif
640 A*
640 AC                   call      'GETRPT'
640 AC                   parm      '*DEVFORM'    $cmd              8
640 AC                   parm      'IT376PR'     $lrpt            10
640 AC                   parm      $kwhse        $whs              3 0
640 AC                   parm      ' '           $styp             1
640 AC                   parm      ' '           $whdp             5
640 AC                   parm      ' '           $desc            50
640 AC                   parm      ' '           $dev             10
640 AC                   parm      ' '           $form            10
640 AC                   if        $dev = ' '
640 AC                   eval      $dev = '*JOB'
640 AC                   endif
640 AC                   if        $form = ' '
640 AC                   eval      $form = '*STD'
640 AC                   endif
640 A*
640 A*  Override printer file
640 A*
640 AC                   eval      qcmd = 'OVRPRTF '
640 AC                                  + 'FILE(IT376PR) '
640 AC                                  + 'OUTQ(' + %trim($dev) + ') '
640 AC                                  + 'FORMTYPE(' + %trim($form) + ') '
640 A
640 AC                   call      'QCMDEXC'
640 AC                   parm                    qcmd             80
640 AC                   parm      80            qlen             15 5
640 A
640 A*  Open printer file
640 A
640 AC                   open(e)   it376pr
640 AC                   if        %error
640 AC                   endif
640 A*
640 aC                   endsr

610aA*----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
