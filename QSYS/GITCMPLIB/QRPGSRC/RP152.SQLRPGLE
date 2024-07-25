      *copy qcopysrc,hspecs
     Hcopyright('(c) Copyright BFC Software, Inc - 2007')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     H**truncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)
     Hdftactgrp(*NO)
      *------------------------------------------------------------------
      *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *------------------------------------------------------------------
      *
      *  RP152 - Report Print File Override Maintenance
      *  03/ March /2009
      *  Chuck Manny
      *
      *------------------------------------------------------------------
      *  Revisions:
      *
      *  03/05/09  CM   5.20
      *   - Created from original RP152
      *
      *  04/08/10  JCJ  5.30
      *   - Changed CPI edit for 2 to 12.
      *
700aA *  06/13/16  DAS  7.00a
      *   - Fix: Revised to have F3=Exit work correctly.
      *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Vitco Foods
     *
VFIa *    01/30/20  KDE   VFIa
     *      - Enh:  Override Truck Summary to different printer based
     *              on first character of Truck code
     *
VFIb *    03/18/20  KDE   VFIb
     *      - Enh:  Fix issue from mod VFIa
     *
     *----------------------------------------------------------------
      *  Indicator usage
      *
      *  XX        XXXXXXXX XXXXXXXXX
      *
      *------------------------------------------------------------------
      *
      * ********************************
      ** File Specs
      * ********************************
      *
     frp152fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     frptovrdtl uf a e           k disk
     f                                     rename(rdrec:record)
     freports   if   e           k disk
     fwarehs    if   e           k disk
VFIaA*----------------------------------------------------------------
VFIaA*  Customer id
VFIaA*
VFIaA /COPY QCOPYSRC,ID#VFI
      *
      *------------------------------------------------------------------
      *
      * Sub Procedure Prototypes
      *
     d prDspScr        pr
      *
     d prScr01i        pr
      *
     d prSc1           pr
      *
     d prZmcMsg        pr
      *
     d prZmdMsg        pr
      *
     d prZmiMsg        pr
      *
     d prZmpMsg        pr
      *
     d prZmsMsg        pr
      *
     d prZm01          pr
      *
     d prZm02          pr
      *
     d prZm03          pr
      *
     d prZm71          pr
      *
     d prZm72          pr
      *
     d prZm73          pr
      *
     d prZm74          pr
      *
     d prZsClr         pr
      *
     d prZzBld         pr
      *
     d prZzChk1        pr
      *
     d prZzDft1        pr
      *
     d prZzFil1        pr
      *
     d prZzGet1        pr
      *
     d prZzHlpTx1      pr
      *
     d prZzHlpTx2      pr
      *
     d prZzInz2        pr
      *
     d prZzUpd         pr
      *
      *------------------------------------------------------------------
      *  Table and array definitions
      *
     d a10             s              1    dim(10)
     d desc            s             60    dim(1) ctdata perrcd(1)
      *
      *------------------------------------------------------------------
      *  Internaly Defined Work Fields
      *
     d wkCmdTkn        s              1
     d e               s              2  0
     d error           s              1
     d msgk            s              4  0
     d nxtscr          s              3
     d sclear          s              1
     d warn            s              1
      *
     d #msgid          s              7
     d #msgtp          s              7
     d #pgmq           s             10
      *
     d $msgf           s             10
      *
     d clear           s              5  0
VFIaAd client          s             10
     d comand          s              5  0
     d enter           s              5  0
     d help            s              5  0
VFIaAd rdPrfO          s                   like(rdprf)
     d rollDn          s              5  0
     d rollUp          s              5  0
     d wkSeqNew        s              3  0  inz
     d wkPosNum        s              5  0  inz
     d wkDays          s              6     inz
     d wkWhs           s              3  0  inz
     d wkPrPrf         s             10     inz
     d wkPrces         s              3     inz
      *
     d wkMdy           s               d   datfmt(*mdy)
     d wkDat           s               d   datfmt(*mdy)
     d wkRptTyp        s             10    inz
      *
      *------------------------------------------------------------------
      *  Program parameters
      *
      *
     d $parms          ds
     d  $pCmd                  1      8
     d  $pPrg                  9     18
     d  $pUky                 19     68
     d  $pRtn                 69     76
     d  $pErm                 77    136
     d  $pMsg                 77     80
      *
      ** Redefine key
      *
     d  $rdPrf                19     28
     d  $rdSeq                29     31
     d  $rdWhs                32     34
     d  $rdDes                35     64
     d  $rdFlg                68     68
      *
      *------------------------------------------------------------------
      *  Data structure
      *
     d                 ds
     d dsRdDev                 1     10    inz
     d  dsDvElm1               1      1    inz
     d  dsDvElm2               2     10    inz
      *
      *------------------------------------------------------------------
      ** Called programs
     D @getcl          c                   const('GETCLIENT')
      *
      *------------------------------------------------------------------
      *  Data structure for error message parameters
      *
     d $mdt            ds
     d  errMsg                 1     50
      *
     d  erpo#                  1      5p 0
     d  eritem                 6     20
     d                 ds
     d  $ec                    1      2p 0
      *------------------------------------------------------------------
      *  Message control
      *
     d #msgf           c                   const('PIRMSGF   ')
     d ceoj            c                   'EOJ'
     d cone            c                   '01 '
      *
      *------------------------------------------------------------------
      *  Constants
      *
     d cAdd            c                   '*ADD    '
     d cDev            c                   '*DEV      '
     d cJob            c                   '*JOB      '
     d cYes            c                   '*YES'
     d cNo             c                   '*NO '
     d cExit           c                   '*EXIT   '
     d cPgmq           c                   '*PGMQ   '
     d cView           c                   '*VIEW   '
     d cClear          c                   '*CLEAR  '
     d cChange         c                   '*CHANGE '
     d cCancel         c                   '*CANCEL '
     d cNull           c                   '*NULL  '
     d cSysval         c                   'SYSVAL   '
     d cChkNum         c                   '0123456789 '
      *
     d                 ds
     d  #msgDt                 1    128
     d  $md                    1    128
     d                                     DIM(128)
      *------------------------------------------------------------------
      *  Program info data structure
      *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
      *------------------------------------------------------------------
      *  Workstation exception data structure
      *
     d infds           ds
     d  status           *status
     d  rowIn                370    370
     d  colIn                371    371
      *
      *------------------------------------------------------------------
      *  Workstation exception redefinition data structure
      *
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
      *
      *------------------------------------------------------------------
      *
     d                                     inz
      *
     d dsw4          e ds                  extname(rptovrdtl) prefix(w4)
     d                                     inz
      *
     d dsRpt         e ds                  extname(rptovrdtl)
     d                                     inz
      *
     d dsWs          e ds                  extname(rptovrdtl) prefix(ws)
     d                                     inz
      *
      *------------------------------------------------------------------   ----
     d dsHld         e ds                  extname(rptovrdtl) prefix(hld)
     d                                     inz
      *
      *------------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $PCMD   *ADD     - Create new batch.
      *              *EDIT    - Edit batch.
      *              *DELETE  - Delete batch.
      *              *PRINT   - Print batch edit listing.
      *              *POST    - Post batch.
      *      $PPRG   Program to send messages back to.
      *      $PUKY   Contains key for everything by *ADD.
      *
      *    Returned Parameters
      *      $PUKY   Contains new batch number for *ADD.
      *              Unchanged for everything else.
      *      $PRTN   blank    - No problem encountered.
      *              *ERROR   - Error occured. Message in $PERM
      *              *PGMQ    - Error occured. Message sent to pgmq.
      *              *CCANCEL - F12 Pressed. Return to report selection.
      *      $PERM   Error message or pointer to message in pgmq.
      *
      *------------------------------------------------------------------
      *  Let the show begin
      *
     c     *entry        plist
     c                   parm                    $parms
      *
      *------------------------------------------------------------------
      *  Main line
      *

     c                   move      $rdWhs        wkWhs

      /free

         // Initialize message handling

         callp  prZmiMsg();

           eval *in97 = *on;
             eval  *in90 = *off;
               eval  *in91 = *off;
                 eval  *in92 = *off;

                     eval  error = *off;
                       eval  $pRtn = *blanks;
                         eval  $perm = *blanks;

                           callp  prZzInz2();

                             if  error = *on;
                              eval  nxtScr = cEoj;
                               endif;

                               dow  nxtScr <> cEoj;
                              callp  prDspScr();

                            if  nxtScr = cOne;
                           callp prSc1();
                          endIf;

                      endDo;

                 // Do some clean up before leaving.

               callp  prZsClr();

            eval  *inlr = *on;

         return;

      /end-free
      **
      **---------------------------------------------------------------------
      **
      **  *INZSR  Initialization subrotine
      **
     c     *inzsr        begsr
      *
      ** Initialize special keys
      *
     c                   z-add     0             enter
     c                   z-add     2             comand
     c                   z-add     01122         rollup
     c                   z-add     01123         rolldn
     c                   z-add     01124         clear
     c                   z-add     01125         help
      *
     c     RptPfKey1     klist
     c                   kfld                    $rdprf
     c                   kfld                    w4rdseq
      *
     c                   endsr
      *
      *---------------------------------------------------------------------
      *
      *  PRDSPSCR - Display Screen
      *
      *-------------------------------------------------------------------------
      *
     p prDspScr        b
     d  prDspScr       pi
      *
      *
      /free

         // Set ON 98 Alarm indicator if error occured
         if  error = *on;
           eval  *in98 = *on;
             endif;

               // Overlay screen with error messages

                callp  prZmdMsg();

                 // Overlay screen with screen to be processed.

                  if  nxtscr = cone;

                   select;
                  when  $pcmd = cChange;
                      eval  w4action = cChange;
                  when  $pcmd = cAdd;
                      eval  w4action = cAdd;
                  when  $pcmd = cView;
                      eval  w4action = cView;
                   endSl;

                 // Match Type of Report to OverRide Screen

                   select;
                  when  w4type <> 'Label    ';
                      exfmt screen1;
                  when  w4type = 'Label     ';
                      exfmt screen2;
                   endSl;

                     eval *in98 = *off;
                  endif;

                // Initialize error indicators and fields

                  eval  warn = *off;
                 eval  error = *off;
                eval  wkCmdTkn = *off;
               eval  e = 0;

            // Initialize error subfile

            callp  prZmcMsg();

          return;

      /end-free

     p prDspScr        e
      *
      *------------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *------------------------------------------------------------------
      *
      *  Screen 01 initialization
      *
     p prScr01i        b
     d  prScr01i       pi
      *
      /free

         eval  nxtscr = cone;

           if  $pcmd = cview;
             eval  *in90 = *on;
               eval  *in92 = *on;
                 endif;

                  // Get field defaults if this is an add.

                    if  *inka <> *on;

                      if  $pcmd = cadd;
                        callp prZzDft1();
                        else;

                       // Otherwise get existing record(s).

                         eval  *in91 = *on;
                       callp  prZzGet1();
                      callp   prZzFil1();
                    endif;

            endif;

          return;

      /end-free

     p prScr01i        e
      *
      *------------------------------------------------------------------
      *
      *              Screen Processing Routines
      *
      *------------------------------------------------------------------
      *
      ** SC1  -  Screen 1
      *
     p prSc1           b
     d  prSc1          pi
      *
      /free

           // Test for F1 - Help

            select;

             when  *inka = *on;
               eval  nxtscr = cone;
                eval  dshld = dsw4;

                 if w4type <> 'Label     ';
                  callp  prZzHlpTx1();
                  else;
                  callp prZzHlpTx2();
                  endIf;

                eval  dsw4 = dshld;

700aA      // Test for F3 - Exit
700aA
700aA        when  *inkc = *on;
700aA          setll (*loval) record;
700aA          eval  nxtscr = ceoj;
700aA          eval  $prtn = ccancel;

           // Test for F5 - Refresh

             when  *inke = *on and
                       $pcmd <> cView;
                 callp   prScr01i();

           // Test for F12 - Previous

             when  *inkl = *on;
               setll (*loval) record;
                 eval  nxtscr = ceoj;
                   eval  $prtn = ccancel;

           // Check input and write/update record.

             other;

               if  $pcmd = cadd or $pcmd = cchange;
                 callp prZzChk1();

                   if  error <> '1';
                     callp  prZzUpd();
                       endif;

                       if  error <> '1';
                     eval nxtscr = ceoj;
                   endif;

               endif;

             endSl;

           return;

      /end-free

     p prSc1           e
      *
      *------------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *-----------------------------------------------------------------
      *
      *  SUBROUTINE ZMxxxx  Control message display subfile
      *
      *    ZMCMSG  Clear message record subfile
      *
     p prZmcMsg        b
     d  prZmcMsg       pi
      *
      /free

         eval  *in97 = *off;
           write  msgctl;
             eval  msgk = *zero;
               write  msgclr;
             eval  #msgid = cclear;
           eval  #msgtp = cnull;
         callp  prZmpMsg();

         return;

      /end-free

     p prZmcMsg        e
      *
      *-----------------------------------------------------------------
      *
      *  ZMDMSG  Display message record subfile
      *
     p prZmdMsg        b
     d  prZmdMsg       pi
      *
      /free

         eval  *in97 = *on;

           if  msgk > 0;
             write  msgctl;
             eval  msgk = *zero;
           endif;

         return;

      /end-free

     p prZmdMsg        e
      *
      *-----------------------------------------------------------------
      *
      *  ZMIMSG  Initialization necessary for message subfile
      *
     p prZmiMsg        b
     d  prZmiMsg       pi
      *
      /free

         eval  #pgmq = #prog;
           callp   prZmcMsg();
         return;

      /end-free

     p prZmiMsg        e
      *
      *-----------------------------------------------------------------
      *
      *  ZMPMSG  Add message record to subfile
      *
     p prZmpMsg        b
     d  prZmpMsg       pi
      *
      /free

         if  $msgf = *blanks;
           eval  $msgf = #msgf;
         endif;

      /end-free
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
      /free

         if  #msgid <> cclear;
           eval  msgk = msgk + 1;
             write  msgrec;
               endif;

               eval  #msgdt = *blanks;
           eval  $msgf = *blanks;
         return;

      /end-free

     p prZmpMsg        e
      *
      *-----------------------------------------------------------------
      *
      *    ZSCLR   Clear screen
      *
     p prZsClr         b
     d  prZsClr        pi
      *
      /free

         write  clrscr;
           eval  sclear = *on;
         return;

      /end-free

     p prZsClr         e
      *
      *-----------------------------------------------------------------
      *
      *    ZMSMSG  Send program message to a different program msgq
      *
     p prZmsMsg        b
     d  prZmsMsg       pi
      *
      /free

         if  $msgf = *blanks;
           eval $msgf = #msgf;
         endif;

      /end-free
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
      /free

         eval  #msgdt = *blanks;
           eval  $msgf = *blanks;
         return;

      /end-free

     p prZmsMsg        e
      *------------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *------------------------------------------------------------------
      *   PIR0201  Code must be entered for create.
      *
     p prZm01          b
     d  prZm01         pi
      *
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
      /free

         eval  #msgid = 'PIR0201';
           eval  #msgtp = '*DIAG  ';
           callp  prZmpMsg();
         return;

      /end-free

     p prZm01          e
      *------------------------------------------------------------------
      *   PIR0202  Code already exists.
      *
     p prZm02          b
     d  prZm02         pi
      *
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
      /free

         eval  #msgid = 'PIR0202';
           eval  #msgtp = '*DIAG  ';
         callp  przmpmsg();

         return;

      /end-free

     p prZm02          e
      *------------------------------------------------------------------
      *            INVALID ENTRY
      *
     p prZm03          b
     d  prZm03         pi

     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   movea     desc          dmsg1

      /free

         eval  *in61 = *on;
          callp   prZmpMsg();
         return;

      /end-free

     p prZm03          e
      *------------------------------------------------------------------
      *   PIR7971  Error in writing a record.
      *
     p prZm71          b
     d  prZm71         pi
      *
      /free

         eval  #msgid = 'PIR7971';
           eval  #msgtp = '*DIAG  ';
             eval  $md = *blanks;

           callp  prZmpMsg();

         return;

      /end-free

     p prZm71          e
      *------------------------------------------------------------------
      *   PIR7972  Error in updating a record.
      *
     p prZm72          b
     d  prZm72         pi
      *
      /free

         eval  #msgid = 'PIR7972';
           eval  #msgtp = '*DIAG  ';
             eval  $md = *blanks;

           callp  prZmpMsg();

         return;

      /end-free

     p prZm72          e
      * -----------------------------------------------------------------
      *     PIR7973  Slot record does not exist.
      *
     p prZm73          b
     d  prZm73         pi
      *
     c                   movea     errmsg        $md(1)
      /free

         eval  #msgid = 'PIR7973';
           eval  #msgtp = '*DIAG  ';
             callp  prZmsMsg();
           eval  $pmsg = #msgk;
         return;

      /end-free

     p prZm73          e
      *------------------------------------------------------------------
      *     PIR7974  Slot record is locked.
      *
     p prZm74          b
     d  prZm74         pi
      *
     c                   movea     errmsg        $md(1)
      /free

         eval #msgid = 'PIR7974';
           eval #msgtp = '*DIAG  ';
             callp prZmsMsg();
           eval $pmsg = #msgk;
         return;

      /end-free

     p prZm74          e
      *
      *------------------------------------------------------------------
      *
      *  ZZCHK1   Screen 1 error checking.
      *
     p prZzChk1        b
     d  prZzChk1       pi
      *
      /free

           eval      error = *off;
             eval      *in36 = *off;
               eval      *in38 = *off;
                 eval      *in39 = *off;
                   eval      *in40 = *off;
                    eval      *in47 = *off;
                   eval      *in48 = *off;
                  eval      *in49 = *off;
                 eval      *in51 = *off;
                eval      *in53 = *off;
              eval      *in59 = *off;
            eval      *in60 = *off;
           eval      wkPrces = *blanks;

           // Validate Print Over Ride Fields

            // On Add Check For Record

         //  if  w4RdSeq <> *zeros and $pCmd = cAdd;
             if  w4RdSeq <> *zeros;

               exec sql
                select rdprf into :wkprprf
                 from rptovrdtl
                  where rdprf = :$rdprf and rdseq = :w4RdSeq;

                   // Record Found/Not Found

                   select;

                     when sqlcod = 000;
                     eval  *in22 = *on;
                //   eval  error = *on;
                    eval wkPrces = 'CHG';

                     // Record Not Found Write Record

                    when sqlcod  =  100;
                    eval *in22 = *off;
                    eval wkPrces = 'ADD';

                  endsl;

             endIf;

            // Validate Auto Print Flag

             if w4rdatp <> 'N' and
              w4rdatp <> 'Y';
               eval w4rdatp = 'N';
             endIf;

            // Validate Device

             if w4rddev = *blanks;
              eval w4rddev = cJob;
               endif;

               if w4rddev <> *blanks and
                        w4rddev <> cJob;
               eval  w4rdoq = cDev;
              eval  w4rdlb = '*LIBL     ';
             endif;

            // Secure

             if w4Rdse <> cNo and
               w4Rdse <> cYes;
               eval  w4Rdse = cNo;
             endif;

            // Formtype - *STD or User Value

             if w4rdfrm = *blanks;
              eval w4rdfrm = '*STD     ';
             endif;

            // Copies - Add Test For Numeric

             eval  wkPosNum = *zeros;

      /end-free
     c     cChkNum       check     w4rdcps       wkPosNum
      /free

             if wkPosNum > 0;
              eval  *in40 = *on;
               eval  error = *on;
                else;
               eval  *in40 = *off;
             endif;

            // Hold

             if w4Rdhd <> cNo and
                  w4Rdhd <> cYes;
               eval w4RdHd = cNo;
             endif;

            // Out Queue

             if w4rdoq = *blank;
              eval  w4rdoq = cJob;
             endif;

            // Out Queue Library

             if w4rdlb = *blanks;
              eval w4rdlb = '*libl     ';
             endif;

            // Schedule

             if w4rdsc <> '*IMMED  ' and
              w4rdsc <> '*FILEEND' and
               w4rdsc <> '*JOBEND';
                eval w4rdsc = '*IMMED  ';
                 endif;

            // Save File

                    if  w4rdsv <> cNo and
                        w4rdsv <> cYes;
                         eval  w4rdsv = cNo;
                    endif;

            // Expiration Date *NONE/*DAYS/ Actual Date

                         select;

                         when      w4rddy > 0 and w4rded <> '*DAYS';
                         eval      *in48 = *on;

                         when      w4rddy < 0 and w4rded = '*DAYS';
                         eval      *in48 = *on;

                         when      w4rddy > 366 and w4rded = '*DAYS';
                         eval      *in48 = *on;

                         when      w4rded = '*DAYS      ' and
                                    w4rddy = *zeros;
                         eval      *in48 = *on;

                         when      w4rded <> '*NONE     ' and
                                     w4rded <> '*DAYS     ' and
                                       w4rded <> *blanks;
      /end-free
     c                   test (D E)              w4rded

     c                   if        not %error()
     c                   eval      wkMdy = %date(w4rded:*mdy)
     c                   movel     wkmdy         w4rded
     c                   else
     c                   eval      *in47 = *on
     c                   endif

      /free

                         other;

                         eval      *in47 = *off;
                         eval      *in48 = *off;

                         endSl;

          // Output Prtestty

                         eval      wkPosNum = *zeros;
      /end-free
     c     cChkNum       check     w4rded        wkPosNum
      /free
                         if        wkPosNum > 0 and
                                   w4rdop <> '*JOB ';
                         eval      *in49 = *on;
                         eval      error = *on;
                         else;
                         eval      *in49 = *off;
                         endif;

                         if        w4rdop = *blanks;
                         eval      w4rdop = '*JOB ';
                         endif;

          // Align

                         if        w4rdal <> cYes and
                                   w4rdal <> cNo;
                         eval w4rdal = cNo;
                         endif;

          // Print Quality

                         if        w4rdql <> '*STD      ' and
                                   w4rdql <> '*DRAFT    ' and
                                   w4rdql <> '*DEVD     ' and
                                   w4rdql <> '*NLQ      ' and
                                   w4rdql <> '*FASTDRAFT';
                         eval w4rdql = '*STD      ';
                         endif;

          // Form Feed

                         if        w4rdff <> '*DEVD     ' and
                                   w4rdff <> '*CONT     ' and
                                   w4rdff <> '*CONT2    ' and
                                   w4rdff <> '*CUT      ' and
                                   w4rdff <> '*AUTOCUT  ';
                         eval      w4rdff =  '*DEVD     ';
                         endIf;

          // Drawer

                         eval      wkPosNum = *zeros;
      /end-free
     c     cChkNum       check     w4rddw        wkPosNum
      /free
                         if        wkPosNum > 0 and
                                   w4rddw <> '*E1       ' and
                                   w4rddw <> '*FORMDF   ';
                         eval      *in53 = *on;
                         eval      error = *on;
                         else;
                         eval      *in53 = *off;
                         endif;

           // Fidelity

                         if        w4rdfd <> '*CONTENT  ' and
                                   w4rdfd <> '*ABSOLUTE ';
                         eval      w4rdfd =  '*CONTENT  ';
                         endif;

          // Duplex

                         if        w4rddx <> '*FORMDF' and
                                   w4rddx <> '*TUMBLE' and
                                   w4rddx <> '*YES   ' and
                                   w4rddx <> '*NO    ';
                         eval      w4rddx =  '*NO    ';
                         endif;

          // Multi Up

                         if        w4rdmu <> '1     ' and
                                   w4rdmu <> '2     ' and
                                   w4rdmu <> '3     ' and
                                   w4rdmu <> '4     ';
                         eval      w4rdmu = '1     ';
                         endif;

          // LPI

                         if        w4Type <> 'Label     ';
                         if        w4rdLpi = '3    ' or
                                   w4rdLpi = '4    ' or
                                   w4rdLpi = '6    ' or
                                   w4rdLpi = '7.5  ' or
                                   w4rdLpi = '8    ' or
                                   w4rdLpi = '9    ' or
                                   w4rdLpi = '12   ';
                         eval      *in59 = *off;
                         else;
                         eval      *in59 = *on;
                         eval      error = *on;
                         endif;
                         endif;

          // CPI
                         if        w4Type <> 'Label     ';
                         if        w4rdCpi = '5    ' or
                                   w4rdCpi = '10   ' or
                                   w4rdCpi = '12   ' or
                                   w4rdCpi = '13.3 ' or
                                   w4rdCpi = '15   ' or
                                   w4rdCpi = '16.7 ' or
                                   w4rdCpi = '18   ' or
                                   w4rdCpi = '20   ';
                         eval      *in60 = *off;
                         else;
                         eval      *in60 = *on;
                         eval      error = *on;
                         endif;
                         endif;

                         if        error = *on;
                         callp   prZm03();
                         endIf;

                         return;
      /end-free

     p prZzChk1        e
      *
      *------------------------------------------------------------------
      *
      ** zzDft1   Get default values for add.
      *
     p prZzDft1        b
     d  prZzDft1       pi
      *
      /free

        eval      w4RdPrf = $rdPrf;

           if  wkSeqNew = 999;
             eval  wkSeqNew = 1;
           endIf;

        eval      w4RdSeq = wkSeqNew + 1;

          eval      w4RdGrp = '*DEFAULT  ';
           eval      w4RdDev = cJob;
            eval      w4rdhd  = cNo;
             eval      w4RdSv  = cNo;
              eval      w4RdOq  = cJob;
               eval      w4RdLb  = '*LIBL      ';

        if w4Type   <>  'Label     ';
               eval      w4RdAtp = 'Y';
              eval      w4rdse  = cNo;
             eval      w4RdFrm = '*STD    ';
            eval      w4RdCps = '1    ';
             eval      w4RdSc  = '*IMMED';
              eval      w4RdEd  = '*NONE';
               eval      w4rddy  = 0;
                eval      w4RdOp  = '*JOB';
                eval      w4RdAl  = cNo;
               eval      w4RdQl  = '*DEVD';
              eval      w4RdFF  = '*DEVD';
             eval      w4RdDW  = '1    ';
            eval      w4RdFD  = '*CONTENT ';
           eval      w4RdDX  = '*NO    ';
          eval      w4RdMU  = '1     ';
         eval      w4RdLpi = '6    ';
        eval      w4RdCpi = '10    ';
        endIf;
         eval      dsws = dsRpt;

          return;

      /end-free

     p prZzDft1        e
      *
      *------------------------------------------------------------------
      *
      *  ZZFIL1   Fill screen 1 fields with info from file.
      *
     p prZzFil1        b
     d  prZzFil1       pi
      *
      /free

         eval  dsw4 = dsRpt;

         return;

      /end-free

     p prZzFil1        e
      *
      *------------------------------------------------------------------
      *
      ** ZZGET1   Get record(s) for screen 1.
      *
     p prZzGet1        b
     d  prZzGet1       pi
      *
      **  Get record from main file.
      *
     c                   if        $pCmd = cView
     c     rptPfKey1     chain(n)  record                             7978  --
     c                   else
     c     rptPfKey1     chain     record                             7978  --
     c                   endif
      /free

         // Record locked.

           select;

            when  *in78 = *on;
              eval  error = *on;
                eval  $pRtn = '*PGMQ   ';
                  callp  prZm74();

                //  Record not found.

            when  *in79 = *on;
              eval      error = *on;
                eval      $pRtn = '*PGMQ   ';
                  callp   prZm73();

           endsl;

         return;

      /end-free

     p prZzGet1        e
      *
      *
      *------------------------------------------------------------------
      *
      ** ZZHLPTX1 Display Help Text for SCREEN1
      *
     p prZzHlpTx1      b
     d  prZzHlpTx1     pi
      *
      /free

         // Get record from main file.

           eval  row# = *zeros;
             eval  col# = *zeros;
             eval  row = rowin;
           eval  col = colin;

         // Warehouse department.

           select;

             when  row# = 10 and col# = 22;
               exfmt  group1;

             when  row# = 11 and col# = 22;
               exfmt  device1;

             when  row# = 12 and col# = 22;
               exfmt  secure1;

             when  row# = 13 and col# = 22;
               exfmt  frmtyp1;

             when  row# = 14 and col# = 22;
               exfmt  copies1;

             when  row# = 15 and col# = 22;
               exfmt  hldspf1;

             when  row# = 16 and col# = 22;
               exfmt  outque1;

             when  row# = 17 and col# = 22;
               exfmt  outqlb1;

             when  row# = 18 and col# = 22;
               exfmt  schdle1;

             when  row# = 19 and col# = 22;
               exfmt  savfil1;

             when  row# = 20 and col# = 22;
               exfmt  lpiHlp1;

             when  row# = 21 and col# = 22;
               exfmt  prtFlg1;

             when  row# = 10 and col# = 61;
               exfmt  expdat1;

             when  row# = 11 and col# = 61;
               exfmt  dystkp1;

             when  row# = 12 and col# = 61;
               exfmt  outpri1;

             when  row# = 13 and col# = 61;
               exfmt  algnpg1;

             when  row# = 14 and col# = 61;
               exfmt  prtqlt1;

             when  row# = 15 and col# = 61;
               exfmt  frmfed1;

             when  row# = 16 and col# = 61;
               exfmt  drawer1;

             when  row# = 17 and col# = 61;
               exfmt  fidlty1;

             when  row# = 18 and col# = 61;
               exfmt  dupLex1;

             when  row# = 19 and col# = 61;
               exfmt  mltiUp1;

             when  row# = 20 and col# = 61;
               exfmt  cpiHlp1;

             when  row# = 21 and col# = 61;
               exfmt  onetime;

           endsl;

           return;

      /end-free

     p prZzHlpTx1      e
      *
      *------------------------------------------------------------------
      *
      ** ZZHLPTX2 Display Help Text for SCREEN2
      *
     p prZzHlpTx2      b
     d  prZzHlpTx2     pi
      *
      /free

         // Get record from main file.

           eval  row# = *zeros;
             eval  col# = *zeros;
             eval  row = rowin;
           eval  col = colin;

         // Retrieve Help Text Panel based on cursor position

           select;

             when  row# = 10 and col# = 22;
               exfmt  group1;

             when  row# = 11 and col# = 22;
               exfmt  device1;

             when  row# = 12 and col# = 22;
               exfmt  hldspf1;

             when  row# = 13 and col# = 22;
               exfmt  savfil1;

             when  row# = 14 and col# = 22;
               exfmt  outque1;

             when  row# = 15 and col# = 22;
               exfmt  outqlb1;

            endsl;

           return;

      /end-free

     p prZzHlpTx2      e
      *
      *------------------------------------------------------------------
      *
      ** ZZBLD    Build OVRPRTF command
      *
     p prZzBld         b
     d  prZzBld        pi
      *
      /free

VFIbA    rdPrfO = rdPrf;
VFIaA    if  client = vitco;
VFIaA      if rdPrf='PS311PRS';
VFIaA         rdPrfO = 'PS311PR   ';
VFIbD      //else;
VFIbD        //rdPrfO = rdPrf;
VFIaA      endif;
VFIaA    endif;

         if  rddy = *zeros;
           eval  wkDays = *blanks;

             if w4Type  <> 'Label     ';
             eval  rdOvr = 'OVRPRTF '
VFIaD          //+ 'FILE(' + %trim(rdPrf) + ')   '
VFIaM          + 'FILE(' + %trim(rdPrfO) + ')   '
                 + 'DEV(' + %trim(rdDev) + ')    '
                   + 'LPI(' + %trim(rdLpi) + ')    '
                     + 'CPI(' + %trim(rdCpi) + ')    '
                       + 'ALIGN(' + %trim(rdAl) + ')    '
                         + 'DRAWER(' + %trim(rdDw) + '  )  '
                           + 'FORMFEED(' + %trim(rdFf) +   ') '
                             + 'PRTQLTY(' + %trim(rdQL) +   ') '
                               + 'FIDELITY(' + %trim(rdFd) +   ') '
                               + 'MULTIUP(' + %trim(rdMu) +   ') '
                             + 'DUPLEX(' + %trim(rdDx) + '  ) '
                           + 'OUTQ(' + %trim(rdOq) + ')   '
                         + 'FORMTYPE(' + %trim(rdFrm)   + ')                '
                       + 'COPIES(' + %trim(rdCps) +   ') '
                     + 'SCHEDULE(' + %trim(rdSc) +   ') '
                   + 'HOLD(' + %trim(rdHd) + ')   '
                 + 'SAVE(' + %trim(rdSv) + ')   '
               + 'OUTPTY(' + %trim(rdOp) + '  ) '
              + 'SECURE(' + %trim(rdSe) + '  ) ';
            else;
             eval  rdOvr = 'OVRPRTF '
VFIaD          //+ 'FILE(' + %trim(rdPrf) + ')   '
VFIaM          + 'FILE(' + %trim(rdPrfO) + ')   '
                 + 'DEV(' + %trim(rdDev) + ')    '
                  + 'OUTQ(' + %trim(rdOq) + ')   '
                   + 'HOLD(' + %trim(rdHd) + ')   '
                   + 'SAVE(' + %trim(rdSv) + ')   ';
                   endIf;
            else;

      /end-free
     c                   move      rddy          wkDays
      /free

            if w4Type  <> 'Label     ';
             eval  rdOvr = 'OVRPRTF '
VFIaD         //+ 'FILE(' + %trim(rdPrf) + ')   '
VFIaM         + 'FILE(' + %trim(rdPrfO) + ')   '
               + 'DEV(' + %trim(rdDev) + ')    '
                 + 'LPI(' + %trim(rdLpi) + ')    '
                   + 'CPI(' + %trim(rdCpi) + ')    '
                     + 'ALIGN(' + %trim(rdAl) + ')    '
                       + 'DRAWER(' + %trim(rdDw) + '  )  '
                         + 'FORMFEED(' + %trim(rdFf) +   ') '
                           + 'PRTQLTY(' + %trim(rdQL) +   ') '
                             + 'FIDELITY(' + %trim(rdFd) +   ') '
                             + 'MULTIUP(' + %trim(rdMu) +   ') '
                           + 'DUPLEX(' + %trim(rdDx) + '  ) '
                         + 'OUTQ(' + %trim(rdOq) + ')   '
                       + 'FORMTYPE(' + %trim(rdFrm)   + ')                  '
                     + 'COPIES(' + %trim(rdCps) +   ') '
                   + 'SCHEDULE(' + %trim(rdSc) +   ') '
                 + 'HOLD(' + %trim(rdHd) + ')   '
               + 'SAVE(' + %trim(rdSv) + ')   '
             + 'OUTPTY(' + %trim(rdOp) + '  ) '
           + 'EXPDATE(' + %trim(rdEd) +   ') '
         + 'DAYS(' + %trim(wkdays) + '  ) '
         + 'SECURE(' + %trim(rdSe) + '  ) ';
          else;
             eval  rdOvr = 'OVRPRTF '
VFIaD          //+ 'FILE(' + %trim(rdPrf) + ')   '
VFIaM          + 'FILE(' + %trim(rdPrfO) + ')   '
                 + 'DEV(' + %trim(rdDev) + ')    '
                  + 'OUTQ(' + %trim(rdOq) + ')   '
                   + 'HOLD(' + %trim(rdHd) + ')   '
                   + 'SAVE(' + %trim(rdSv) + ')   ';
                   endIf;
         endIf;

        return;

      /end-free

     p prZzBld         e
      *
      *------------------------------------------------------------------
      *
      ** ZZINZ2   Program initialization. Called from main line.
      *
     p prZzInz2        b
     d  prZzInz2       pi
      *
     c                   move      $rdseq        w4RdSeq
     c                   move      $rdWhs        whCode
      /free

         // Select first screen to display.

           eval       w4RdPrf = $rdPrf;
             eval       whDesc  = $rdDes;

      /end-free

     c     w4RdPrf       chain     reports

      /free

         if  %found(reports);
           eval  w4Type = rpType;
             eval  w4Desc = rpDesc;
         endif;

          // Setup Sequence # for new record.

         if  $pCmd = cadd;
           setll ($rdprf) rptovrdtl;
             dou       %eof(rptOvrDtl);

      /end-free
     c     $rdprf        reade     rptOvrDtl
      /free

         if  not %eof(rptOvrDtl);
           eval      wkSeqNew = rdSeq;
         endIf;

             endDo;

         endIf;

      /end-free

VFIaA*
VFIaA* Get client id.
VFIaA*
VFIaAC                   call      @getcl
VFIaAC                   parm                    client
     c     wkWhs         chain     warehs

      /free

         if  not %found;
           eval  whdesc = '*Not Found';
         endIf;

         if  $pcmd = '*ADD     ';
           callp  prZzDft1();
         endIf;

         callp  prScr01i();

         return;

      /end-free

     p prZzInz2        e
      *
      *------------------------------------------------------------------
      *
      ** ZZUPD    Update record.
      *
     p prZzUpd         b
     d  prZzUpd        pi
      *
      /free

         eval  error = *off;

            // Move screen fields to record fields

              eval  dsrpt = dsw4;

                // Add record

                   callp  prZzBld();

                  // if  $pcmd = cadd;

                      if  dsws <> dsRpt;
                        eval  rdOne = $rdFlg;
                         endIf;

                          select;

                         when  wkPrces = 'CHG';
                            update  record;
                            eval *inkl = *on;

                         when  wkPrces = 'ADD';
                            write  record;
                            eval *inkl = *on;

                         other;
                            eval   error = *on;

                         endSl;

                           if     *in79 = *on;
                           eval   error = *on;
                           callp  prZm71();
                           endif;

                   //      if  *in79 = *on;
                  //     eval   error = *on;
                 //    callp  prZm72();
                //   endif;

              //  endSl;

           //  endif;

         return;

      /end-free

     p prZzUpd         e
     O*
     O*---------------------------------------------------------------------****
     O*
     O*  COMPILE TIME TABLES
     O*
      **
     *** RTF FILE(EX128PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXX  XXXX)
      **
