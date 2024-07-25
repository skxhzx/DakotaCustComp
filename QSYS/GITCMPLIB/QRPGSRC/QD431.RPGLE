      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QD431     Fixed items with multiple pick slots.
     *  Hemant Kapadia
     *  27 August, 1997
     *
     *  Note: Openquery file in CL program restricts to warehouse/
     *        Department/Fixed section and Pick slots records only
     *        for SLOT4 file.
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    08/27/97  HNK 4.04
     *      - Created.
     *
413 A*    03/15/00  DAS 4.13
     *      - Added slot fields to output.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYLa *    03/15/00  RTR  RYLa
     *      - Converted to RPGLE.
     *      - Added client processing.
     *      - Added DETAIL2 with 1 slot per line.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    03/12/13  MLB  CWD
     *      - Revised pgm to print all items without pick slots, not
     *        just items with product in overflow and no pick slot.
     *      - Request per Skype from Hemant.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf
     *
GLPa *    08/30/13  RH   GLPa
     *      - Added Detail3 to shorten item # and add item type
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WILa *    11/10/14  RH   WILa
     *      - Skip bulk areas, aisle 82, 83, 84, 85 and CC
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
     *
SGCa *    08/29/18  RH   SGCa
     *      - Add to Royal mod to display slot quantity.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   ip   e           k disk
     Fslot4     if   e           k disk
413 AFslot3     if   e           k disk
     F                                     rename(slrec:record)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fqd431pr   o    e             printer oflind(*in90)
     *****************************************************************
     **REC
     **                                            ITWHDPL1
     *****************************************************************
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
RYLaA*----------------------------------------------------------------
RYLaA*  Customer id
RYLaA*
RYLaAD @getcl          c                   const('GETCLIENT')
RYLaA*
RYLaA /COPY QCOPYSRC,ID#ROYAL
CWD A /COPY QCOPYSRC,ID#cashwa
GLPaA /COPY QCOPYSRC,ID#GLP
WILaA /COPY QCOPYSRC,ID#WIL
SGCaA /COPY QCOPYSRC,ID#SGC
     *
     *----------------------------------------------------------------
     *  Variables
     *
     D $kwhse          s              3  0
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D dspcnt          s              3  0
     D eof             s              1
     D first           s              1
     D forevr          s              1
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D ovrflg          s              1
     D pckflg          s              1
     D prtlin          s              3  0
     D svdesc          s             30
     D svwhdp          s                   like(slwhdp)
     D w1styp          s              5
     D w1whdp          s                   like(slwhdp)
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $whdp             5
     C                   move      $whse         $kwhse
     *----------------------------------------------------------------
     *
     *  Key fields
     *
     C     slkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    itwhdp
     C                   kfld                    ititem
413 AC     slkey2        klist
413 AC                   kfld                    $kwhse
413 AC                   kfld                    ititem
413 AC                   kfld                    kystat
413 AC                   kfld                    kypick
     *
     C     idkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    ititem
     C                   kfld                    slsdef
     *
     C     whkey         klist
     C                   kfld                    $kwhse
     *
     C     wdkey         klist
     C                   kfld                    $kwhse
     C                   kfld                    w1whdp
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             first = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     * Find out if the item has more than one slot.
     *
     C                   exsr      find
     *
     * Detail Calcs
     *
     C                   if        ovrflg = *on  and
     C                             pckflg = *off
     *
CWD AC                             or client = Cashwa
CWD AC                             and ovrflg = '0'
CWD AC                             and pckflg = '0'
     *
     *  Start a new page, if change in department.
     *
     C                   if        $whdp = '*ALL '  and
     C                             svwhdp <> *blanks  and
     C                             slwhdp <> svwhdp
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     C                   eval      svwhdp = slwhdp
413 A*
413 A*  Get slots for item
413 A*
RYLaAC                   select
     *
RYLaAC                   when      client = royal
RYLaAC                   exsr      getslt2
     *
SGCaAC                   when      client = sgc
SGCaAC                   exsr      getslt2
     *
RYLaAC                   other
413 AC                   exsr      getslt
     *
RYLaAC                   endsl
     *
RYLaDC** 61              write     skip1
RYLaDC**                 write     detail1
     *
     C                   endif
     C                   eval      first = *off
     *
     C     out           tag
     CLr                 write     skip1
     CLr                 write     foot1
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
413 AC                   eval      forevr = *on
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      count = 0
     C                   eval      prtlin = 0
     C                   eval      svwhdp = *blanks
RYLaA*
RYLaA* Get client id.
RYLaA*
RYLaAC                   call      @getcl
RYLaAC                   parm                    client           10
RYLaAC                   parm                    cliloc           10
RYLaA*
     C                   endsr
     *****************************************************************
     *
     *  FIND    Find out if the item has more than one pick slot.
     *
     C     find          begsr
     *
     C                   eval      ovrflg = *off
     C                   eval      pckflg = *off
     C     slkey         setll     slot4                              79
     C                   eval      count = 0
     C                   seton                                        61
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     slkey         reade     slot4                                  79
     C                   move      *in79         eof
     C                   if        not *in79
WILaA*
WILaAC                   select
WILaAC                   when      client = willfoods
WILaAC                   if        slaisl = ' 82' or
WILaAC                             slaisl = ' 83' or
WILaAC                             slaisl = ' 84' or
WILaAC                             slaisl = ' 85' or
WILaAC                             slaisl = ' CC' or
WILaAC                             slaisl = 'RCV'
WILaAC                   goto      skipW
WILaAC                   endif
WILaAC                   endsl
WILaA*
     C                   if        slstat = 'A'
     C                   if        slpick = 'Y'
     C                   eval      pckflg = *on
     C                   else
     C                   eval      ovrflg = *on
     C                   endif
     C                   endif
WILaAC     skipW         tag
     C                   endif
     C                   enddo
     *
     C                   endsr
413 A*****************************************************************
413 A*
413 A*  GETSLT  Get overflow slots
413 A*
413 AC     getslt        begsr
413 A*
413 AC                   eval      w1dsp1 = *blanks
413 AC                   eval      w1dsp2 = *blanks
413 AC                   eval      w1dsp3 = *blanks
413 AC                   eval      w1dsp4 = *blanks
413 AC                   eval      dspcnt = 0
413 A*
413 AC                   eval      kystat = 'A '
413 AC                   eval      kypick = 'N'
413 AC     slkey2        setll     slot3                              79
413 AC                   dow       forevr = forevr
413 AC     slkey2        reade     slot3                                  79
413 AC                   if        *in79
413 AC                   leave
413 AC                   endif
413 AC                   add       1             dspcnt
413 AC                   select
413 AC                   when      dspcnt = 1
413 AC                   eval      w1dsp1 = sldisp
413 AC                   when      dspcnt = 2
413 AC                   eval      w1dsp2 = sldisp
413 AC                   when      dspcnt = 3
413 AC                   eval      w1dsp3 = sldisp
413 AC                   when      dspcnt = 4
413 AC                   eval      w1dsp4 = sldisp
413 AC                   endsl
413 AC                   enddo
413 A*
RYLaAC   61              write     skip1
GLPaAC                   select
GLPaAC                   when      client = greenleaf
GLPaAC                   movel     ititem        w3item
GLPaAC                   write     detail3
GLPaAC                   other
RYLaAC                   write     detail1
GLPaAC                   endsl
413 A*
413 AC                   endsr
RYLaA*****************************************************************
RYLaA*
RYLaA*  GETSLT2  Get overflow slots - one per line
RYLaA*
RYLaAC     getslt2       begsr
RYLaA*
RYLaAC                   eval      w1dsp1 = *blanks
RYLaA*
RYLaAC                   eval      kystat = 'A '
RYLaAC                   eval      kypick = 'N'
RYLaAC     slkey2        setll     slot3                              79
RYLaAC                   dow       forevr = forevr
RYLaAC     slkey2        reade     slot3                                  79
RYLaAC                   if        *in79
RYLaAC                   leave
RYLaAC                   endif
RYLaA*
RYLaA*  Format Stock Qtys
RYLaAC                   select
RYLaAC                   when      slstk3 <> 0
RYLaAC                   eval      w2stk = %trim(%char(slstk1)) + '.'
RYLaAC                                   + %trim(%char(slstk2)) + '.'
RYLaAC                                   + %trim(%char(slstk3))
RYLaAC                   when      slstk2 <> 0
RYLaAC                   eval      w2stk = %trim(%char(slstk1)) + '.'
RYLaAC                                   + %trim(%char(slstk2))
RYLaAC                   other
RYLaAC                   eval      w2stk = %trim(%char(slstk1))
RYLaAC                   endsl
RYLaA*
RYLaA*  Format Alloc Qtys
RYLaAC                   select
RYLaAC                   when      slalc3 <> 0
RYLaAC                   eval      w2alc = %trim(%char(slalc1)) + '.'
RYLaAC                                   + %trim(%char(slalc2)) + '.'
RYLaAC                                   + %trim(%char(slalc3))
RYLaAC                   when      slalc2 <> 0
RYLaAC                   eval      w2alc = %trim(%char(slalc1)) + '.'
RYLaAC                                   + %trim(%char(slalc2))
RYLaAC                   other
RYLaAC                   eval      w2alc = %trim(%char(slalc1))
RYLaAC                   endsl
RYLaA*
RYLaA*  Format Picked Qtys
RYLaAC                   select
RYLaAC                   when      slpck3 <> 0
RYLaAC                   eval      w2pck = %trim(%char(slpck1)) + '.'
RYLaAC                                   + %trim(%char(slpck2)) + '.'
RYLaAC                                   + %trim(%char(slpck3))
RYLaAC                   when      slpck2 <> 0
RYLaAC                   eval      w2pck = %trim(%char(slpck1)) + '.'
RYLaAC                                   + %trim(%char(slpck2))
RYLaAC                   other
RYLaAC                   eval      w2pck = %trim(%char(slpck1))
RYLaAC                   endsl
RYLaA*
RYLaA*  Format Entered Date
RYLaAC                   monitor
RYLaAC                   eval      W2entd = %char(%date(slentd:*iso):*usa/)
     C                   on-error
RYLaAC                   eval      W2entd = *blanks
     C                   endmon
RYLaA*
RYLaA*  Format Expire Date
RYLaAC                   monitor
RYLaAC                   eval      W2expd = %char(%date(slexpd:*iso):*usa/)
     C                   on-error
RYLaAC                   eval      W2expd = *blanks
     C                   endmon
RYLaA*
RYLaAC   61              write     skip1
RYLaAC                   write     detail2
RYLaA*
RYLaAC                   enddo
RYLaA*
RYLaAC                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     C                   if        $whdp <> '*ALL '
     C                   eval      w1whdp = $whdp
     C                   else
     C                   eval      w1whdp = itwhdp
     C                   endif
     *
     *   Section
     *
     C                   eval      w1styp = 'FIXED'
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
     C                   eval      $pstr = *blanks
     C     wdkey         chain     whdept                             79
     C                   if        not *in79
     C                   eval      svdesc = wddesc
     C                   else
     C                   eval      svdesc = *blanks
     C                   endif
     C     wowhse        cat       '/':0         wowhse
     C     wowhse        cat       svdesc:0      wowhse
     C     wowhse        cat       '/':0         wowhse
     C     wowhse        cat       w1styp:0      wowhse
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
     *
RYLaAC                   select
RYLaAC                   when      client = royal
RYLaAC                   write     columns2
SGCaAC                   when      client = sgc
SGCaAC                   write     columns2
GLPaAC                   when      client = greenleaf
GLPaAC                   write     columns3
RYLaAC                   other
     C                   write     columns
RYLaAC                   endsl
     *
     C                   endsr
