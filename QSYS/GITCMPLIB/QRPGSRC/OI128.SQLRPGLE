      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI128     Import Stop Flags - Post
     *  12 January 2011
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
     *  To compile:  COMMIT = *NONE
     *               DLYPRP = *YES
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/12/11  RBD  6.40
     *      - Created.
     *
650 A*    01/30/13  RBD  6.50
     *      - IMPFORSF changed and this pgm is now called directly
     *        from the import pgm which processes order header. This
     *        pgm has not yet been used anywhere so to keep things
     *        neat and clean I did not add mod marks.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *
     Fimpforsf  if   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fttstpflg  if a e           k disk
     Foi128pr   o    e             printer oflind(*in91)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(1) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Constants
     *
     *
     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Working variables
     *
     D dummy           s              3  0
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D len             s              1  0
     D linppg          s              3  0
     D mischdrupd      s              4    inz('*NO ')
     D miscupdate      s              4    inz('*NO ')
     D pos             s              1  0
     D work3a          s              3

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     * Function prototypes.

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Sub-procedure prototypes

     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse   Warehouse
     *      $pRte    Route
     *      $pRteId  Route Id
     *      $pOrd    Customer order
     *      $pOrdId  Order Id
     *      $pLinCnt Line counter for report
     *
     *    Returned Parameters
     *      $pLinCnt Line counter for report
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRte             5
     C                   parm                    $pRteId           5
     C                   parm                    $pStop            2 0
     C                   parm                    $pOrd             7 0
     C                   parm                    $pOrdId           7 0
     C                   parm                    $pLinCnt          2 0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     * Main line
     *
     C                   if        *inlr
     C                   return
     C                   endif
     *
     * Whip through the imported Stop Flags for the order passed in
     *
     C     impkey        setll     impforsf
     C                   dow       forevr = forevr
     C     impkey        reade     impforsf
     *
     C                   if        %eof
     C                   leave
     C                   endif
     *
     C                   eval      detmsg = *blanks
     *
     C                   exsr      fillsf
     C                   write     ttfrec                               49
     *
     *    If error occurs writing Stop Flag record, assume it
     *    was caused by a duplicate record.
     C                   if        *in49
     C                   eval      detmsg = desc(1)
     C                   endif
     *
     *    Print report heading if overflow.
     *
     C                   if        $pLinCnt >= linppg
     C                   eval      $pLinCnt = 0
     C                   write     head1
     C                   write     head2
     C                   add       4             $pLinCnt
     C                   endif
     *
     *    Print detail
     *
     C                   write     detail
     C                   add       3             $pLinCnt
     *
     *    Update grand totals
     *
     C                   add       1             grdflg
     *
     C                   enddo
     *
     *  Print Stop Flag grand totals
     *
     C                   if        $pLinCnt >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     *
     *  Good-bye
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     * Open IMPFORSF file.
     C                   open(e)   impforsf
     C                   if        %error
     C                   eval      *inlr = *on
     C                   endif
     *
     * IMPKEY Imported Stop Flags key
     *
     C     impkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    $pord
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields.
     *
     C                   eval      grdflg = 0
     *
     C                   eval      linppg = 55
     C                   eval      $pLinCnt = 0
     *
     *  Create warehouse heading.
     *
     C                   eval      whcode = $pWhse
     C     whcode        chain     warehs
     C                   if        not %found
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      $pWhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     *    Get report override if any.
     C                   exsr      opnprt
     *
     *    Print report heading for first time.
     *
     C                   write     head1
     C                   write     head2
     C                   add       4             $pLinCnt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLSF   Fill Stop Flag fields.
     *
     C     fillsf        begsr
     *
     *  Initialize record
     *
     C                   clear                   ttfrec
     *
     C                   eval      ttfwhs = $pWhse
     C                   eval      ttfrte = $pRte
     C                   eval      ttfrti = $pRteId
     C                   eval      ttford = $pOrdId
     C                   eval      ttfstp = $pStop
     C                   eval      ttfchr = oischr
     C                   eval      ttfale = oisale
     C                   eval      ttfuid = oisuid
     C                   eval      ttfdsp = oisdsp

     C                   exsr      GetAddChgInfo
     *
     *    Load print field for report.
     C                   eval      prtrte = $pRteId
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OI128PR '    $lrpt            10
     C                   parm      $pWhse        $whse             3 0
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Override printer file.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      oi128pr
     *
     C                   endsr
     *----------------------------------------------------------------
     *  GetAddChgInfo  Get add/chg info

      /free

       begsr GetAddChgInfo;

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

         ttfaddts = CurrStampSys;
         ttfadduc = CurrStampUC;
         ttfaddusr = #user;
         ttfaddjob = #job;
         ttfaddnbr = #jobnbr;
         ttfchgts = CurrStampSys;
         ttfchguc = CurrStampUC;
         ttfchgusr = #user;
         ttfchgjob = #job;
         ttfchgnbr = #jobnbr;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
-- ALREADY EXISTS --
**
Import Stop Flags
**   OVRPRTF statement
OVRPRTF FILE(OI128PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
