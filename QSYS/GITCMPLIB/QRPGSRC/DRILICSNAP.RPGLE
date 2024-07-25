      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  DRILICSNAP  Dakota realtime interface - License Snapshot
     *  14 January 2014
     *  Rod Roller
     *
700a *    01/14/14  RTR  7.00a
     *      - Created
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)
     *
     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------
     *  Sub-Command Notes
     *
     *      *OPEN        Open program and return.
     *
     *      *CLOSE       Close program with *INLR = *ON
     *
     *      *WRTSNAP     Write Snapshot record for LICLOG record.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fliclog    if   e           k disk
     Fslot2     if   e           k disk
     Fitemqty   if   e           k disk
     Fliclogss  o  a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#LICSNAP

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D DakotaCall      s               n
     D firstNonExp     s               n
     D firstRec        s               n
     D frmZero         s               n
     D HostCall        s               n
     D kydisp          s                   like(lldisp)
     D kyitem          s                   like(llitem)
     D kywhdp          s                   like(llwhdp)
     D kywhse          s                   like(llwhse)
     D kyadduc         s                   like(lladduc)
     D logmsg          s           1024a
     D debugnode       s               n   inz(*on)
     D recCount        s              3  0
     D todayYMD        s              8  0

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     D cError          c                   '*ERROR    '

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------
     D/copy qcopysrc,c#pgminfds

     ** Write record to BFCLOG file
     D WrtLog          pr                  extpgm('WRTLOG')
     D                               10    const
     D                               10    const
     D                             1024    const

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $pwhse     Warehouse
      *      $pltrn     License Trans
      *      $pltrnseq  License Trans Sequence
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata
     C                   parm                    $pdata2

      /free
         $preturn = '*OK';
         $pmessage = ' ';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       dou 1=1; //bottom

         // See which system is calling the program.

         if %subst($psubcmd:1:1) = '%';
           DakotaCall = *on;
           HostCall = *off;
           %subst($psubcmd:1:1) = '*';
         else;
           HostCall = *on;
           DakotaCall = *off;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             $preturn = '*OK';
             $pmessage = ' ';
             leave; //bottom

           when $psubcmd = '*CLOSE';
             $preturn = '*OK';
             $pmessage = ' ';
             exsr aaaclose;
             *inlr = *on;
             leave; //bottom

         endsl;

         // Otherwise, do some initialization and move on.

         exsr aaainit;
         error = *off;

         // Do what user has requested.

         select;

           when $psubcmd = '*WRTSNAP';
             exsr WrtSnap;

           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;

       enddo; //bottom

       // We are finished so get out

       return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

      /free
       begsr aaainit;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

      /free
       begsr aaaclose;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getItemQty   Get item qty info.
     *----------------------------------------------------------------

      /free
       begsr getItemQty;

         chain (kywhse: kyitem) itemqty;
         if not %found(itemqty);
           clear iqrec;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getSlot  Get slot info.
     *----------------------------------------------------------------

      /free
       begsr getSlot;

         chain (kywhse: kywhdp: kydisp) slot2;
         if not %found(slot2)
           or slstat = 'V'
           or slstat = 'Z';
             clear slrec;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtSnap    Write Snapshot Record
     *----------------------------------------------------------------

      /free
       begsr WrtSnap;

         // Get liclog record
         clear $licsnap;
         $licsnap = $pdata;
         chain ($lssWhse: $lssLcns: $lssAddUC) liclog;
         if not %found(liclog);
           logmsg = 'Error: LICLOG record not found. Whse:' + %char($lssWhse)
                  + ' License:' + $lssLcns + ' AddUC:' + %char($lssAddUC);
           WrtLog(#pgm: cError: logmsg);
           error = *on;
           leavesr;
         endif;

         lrwhse = llwhse;
         lritem = llitem;
         lrsitem = llsitem;
         lrltrn = llltrn;
         lrltrnseq = llltrnseq;
         lrdisp = lldisp;
         lrbase = llbase;

         lraddts = lladdts;
         lradduc = lladduc;
         lraddcpgm = lladdcpgm;
         lraddjpgm = lladdjpgm;
         lraddemp = lladdemp;
         lraddeusr = lladdeusr;
         lraddcusr = lladdcusr;
         lraddjusr = lladdjusr;
         lraddjob = lladdjob;
         lraddnbr = lladdnbr;
         clear lrexpts;
         clear lrexpuc;
         lrexpjusr = *blank;
         lrexpjob = *blank;
         lrexpnbr = *zero;

         // Get slot info
         kywhse = llWhse;
         kywhdp = llWhdp;
         kydisp = llDisp;
         exsr getSlot;

         lrsstk1 = slstk1;
         lrsstk2 = slstk2;
         lrsstk3 = slstk3;
         lrsalc1 = slalc1;
         lrsalc2 = slalc2;
         lrsalc3 = slalc3;
         lrstfr1 = sltfr1;
         lrstfr2 = sltfr2;
         lrstfr3 = sltfr3;
         lrspck1 = slpck1;
         lrspck2 = slpck2;
         lrspck3 = slpck3;
         lrsrcv1 = slrcv1;
         lrsrcv2 = slrcv2;
         lrsrcv3 = slrcv3;

         // Get itemqty info
         kywhse = llWhse;
         kyitem = llItem;
         exsr getItemQty;

         lrwstk1 = iqstk1;
         lrwstk2 = iqstk2;
         lrwstk3 = iqstk3;
         lrwalc1 = iqalc1;
         lrwalc2 = iqalc2;
         lrwalc3 = iqalc3;
         lrwhld1 = iqhld1;
         lrwhld2 = iqhld2;
         lrwhld3 = iqhld3;
         lrwtri1 = iqtri1;
         lrwtri2 = iqtri2;
         lrwtri3 = iqtri3;
         lrwtro1 = iqtro1;
         lrwtro2 = iqtro2;
         lrwtro3 = iqtro3;

         monitor;
           write(e) lrrec;
         on-error;
           logmsg = 'Error writing LICLOGSS for Whse:' + %char(llwhse)
                  + ' Trans:' + %char(llltrn) + ' Seq:' + %char(llltrnseq);
           WrtLog(#pgm: cError: logmsg);
         endmon;

         clear lrrec;

       endsr;
      /end-free

