      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2023 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTZPL       Test ZPL printing
     *  30 April 2023
     *  Dave Sommerville
     *
     *  Revisions:
     *
770 A*    04/30/23  DAS  7.70
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstzplfm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpfmtpr    o    f  198        printer oflind(*in90) usropn

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1

     d @outpt          s            198
     d chunkStart      s             10i 0
     d chunkEnd        s             10i 0
     d chunkLen        s             10i 0
     d ilen            s             10I 0
     d path            s            256    varying
     d rddata          s           1024A
     d fileId          s             10I 0
     d forever         s               n
     d lineByline      s               n
     D ifs_flags       s             10u 0
     D ifs_mode        s             10u 0

     *----------------------------------------------------------------
     *  ZPL Input fields
     *----------------------------------------------------------------

     D w1zpl           ds
     D  w1zpl1
     D  w1zpl2
     D  w1zpl3
     D  w1zpl4
     D  w1zpl5
     D  w1zpl6
     D  w1zpl7
     D  w1zpl8
     D  w1zpl9
     D  w1zpl10
     D  w1zpl11
     D  w1zpl12
     D  w1zpl13
     D  w1zpl14
     D  w1zpl15
     D  w1zpl16

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,c#ifsio_h
     d/copy qcopysrc,errno_h

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d OpenFromFile    pr
     d OpenToFile      pr
     d CopyFile        pr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     *  Close interface

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       13
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     **                   MOVE 'EOJ'     NXTSCR
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = '01 '
     Csr                 leavesr
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     Csr                 leavesr
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     Csr                 leavesr
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     C     endsc2        endsr
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
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #pgm
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      *blanks       #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr

      //
      //  Verify default device
      //
       if %subst(w1dev: 1: 1) = '*'  and
             w1dev <> '*SYSVAL'  and
             w1dev <> '*JOB'  or
             w1dev = *blanks;
         error = *on;
         *in28 = *on;
         *in08 = *on;
         errmsg = 'Invalid asterisk printer device';
         exsr zm0105;
       endif;
       //
       //  Verify default form type
       //
       if %subst(w1form: 1: 1) = '*'  and
             w1form <> '*STD'  or
             w1form = *blanks;
         error = *on;
         *in29 = *on;
         *in09 = *on;
         errmsg = 'Invalid asterisk form';
         exsr zm0105;
       endif;

        // Something must be entered for ZPL or Path

        // ZPL and Path cannot be both entered

        // Verify Path

        lineByLine = *on;


     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
        cmdtkn = *off;

        // Display screen 2 - Command display

        if *inkg;
          cmdtkn = *on;
          exsr scr02i;
        endif;

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
      /free
        w1zpl = '';
        w1path = '';
        w1dev = 'xRTZEBRA1';
        w1form = '*STD';
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr
      /free
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr
     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZGET2   Get record(s) for screen 2.
     *----------------------------------------------------------------

     C     zzget2        begsr
     C     endgt2        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  zzPRTLBL    Process *PRTLBL command
     *----------------------------------------------------------------

     C     zzPRTLBL      begsr
      /free

        // See if we should overrid the device


      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr

        error = *off;

        // Open printer file

         qcmd = 'OVRPRTF FILE(PFMTPR) OUTQ(*DEV) '
              + 'DEV(' + %trim(w1dev) + ') '
              + 'FORMTYPE(' + %trim(w1form) + ')';

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

         open pfmtpr;

        // Print either ZPL or file

        if w1Path <> '';
          exsr zzzPrintFile;
        endif;

        if w1zpl <> '';
          if lineByLine;
            exsr zzzPrintZPL1;
          else;
            exsr zzzPrintZPL2;
          endif;
        endif;

        // Close printer file

        close pfmtpr;

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update record for screen 2
     *----------------------------------------------------------------

     C     zzupd2        begsr
        error = *off;
        nxtscr = '01 ';
     C                   endsr

     *----------------------------------------------------------------
     *  zzzPrintFile  Send IFS file to printer
     *----------------------------------------------------------------

     C     zzzPrintFile  begsr

       error = *off;

       // Open file, get out if error

       path = %trim(w1path);

       // Set file properties

       ifs_flags = o_rdonly + o_textdata;

       // Open file, get out if error

       fileId = open(%addr(path)+2: ifs_flags);
       if fileId < 0;
         error = *on;
         *in23 = *on;
         *in03 = *on;
        // errmsg = 'File open error: '
        //          + %str(strerror(errno));
         exsr zm0105;
         leavesr;
       endif;

       dow forever = forever;

         if lineByLine;
           ilen = readline(fileId: %addr(rddata): %size(rddata));
         else;
           ilen = read(fileId: %addr(rddata): %size(rddata));
         endif;

         if ilen < 0;
           leave;
         endif;

         // Send to printer in chunks less than or eaual to 198 char

         chunkStart = 1;
         chunkEnd = 0;
         chunkLen = 0;

         // We are going to start with simple method
         // If printing doesn't work correctly, then it probably doesn't
         // like a command being split across output lines.

         dow chunkStart <= ilen;
           chunkEnd = chunkStart + 198 - 1;
           if chunkEnd > ilen;
             chunkEnd = ilen;
           endif;
           chunkLen = chunkEnd - chunkStart + 1;
           @outpt = %subst(rddata: chunkStart: chunkLen);
           except #str;
           chunkStart = chunkEnd + 1;
         enddo;

       enddo;

     C                   endsr

     *----------------------------------------------------------------
     *  zzzPrintZPL1   Send each ZPL line to printer separately
     *----------------------------------------------------------------

     C     zzzPrintZPL1  begsr

        error = *off;

        @outpt = w1zpl1;
        except #str;
        @outpt = w1zpl2;
        except #str;
        @outpt = w1zpl3;
        except #str;
        @outpt = w1zpl4;
        except #str;
        @outpt = w1zpl5;
        except #str;
        @outpt = w1zpl6;
        except #str;
        @outpt = w1zpl7;
        except #str;
        @outpt = w1zpl8;
        except #str;
        @outpt = w1zpl9;
        except #str;
        @outpt = w1zpl10;
        except #str;
        @outpt = w1zpl11;
        except #str;
        @outpt = w1zpl12;
        except #str;
        @outpt = w1zpl13;
        except #str;
        @outpt = w1zpl14;
        except #str;
        @outpt = w1zpl15;
        except #str;
        @outpt = w1zpl16;
        except #str;

     C                   endsr

     *----------------------------------------------------------------
     *  zzzPrintZPL2   Combine ZPL lines and send in 198 chunks
     *----------------------------------------------------------------

     C     zzzPrintZPL2  begsr

        error = *off;

       dow forever = forever;

         ilen = %len(%trimr(w1zpl));

         if ilen <= 0;
           leave;
         endif;

         // Send to printer in chunks less than or eaual to 198 char

         chunkStart = 1;
         chunkEnd = 0;
         chunkLen = 0;

         // We are going to start with simple method
         // If printing doesn't work correctly, then it probably doesn't
         // like a command being split across output lines.

         dow chunkStart <= ilen;
           chunkEnd = chunkStart + 198 - 1;
           if chunkEnd > ilen;
             chunkEnd = ilen;
           endif;
           chunkLen = chunkEnd - chunkStart + 1;
           @outpt = %subst(w1zpl: chunkStart: chunkLen);
           except #str;
           chunkStart = chunkEnd + 1;
         enddo;

       enddo;


     C                   endsr

     O*----------------------------------------------------------------
     O*  Output Specs
     O*
     Opfmtpr    e            #str           1
     O                       @outpt             198

