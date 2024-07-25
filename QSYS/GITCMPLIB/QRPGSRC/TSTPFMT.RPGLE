      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTPFMT      Test PFMT
     *  08 April 2021
     *  Dave Sommerville
     *
     *  Revisions:
     *
750 A*    05/08/21  DAS  7.50
     *      - Created.
     *
750aA*    09/29/21  DAS  7.50a
     *      - Revised to get template code if LWTRUK not a template
     *      - Switched to get *PICKLBA instead of PICKLBL
     *
750bA*    12/22/21  DAS  7.50b
     *      - Fixed the device override
     *
770aA*    05/04/23  DAS  7.70a
     *      - Revised zzchk1 to not force lbl# or trn#, as some
     *        commands do not require them.
     *      - Mad some corrections to zzchk1
     *
770bA*    05/24/23  DAS  7.70b
     *      - Added output type verification
     *      - Added output type D = Normal with device override.
     *      - Revised to only send device for output type 'D'
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstpfmtfm cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpirtranw  if   e           k disk
     Fworklblw  if   e           k disk
     Fworklb94  if   e           k disk    rename(lwrec: lw94rec)
     Foptionz   if   e           k disk
     Frtehed    if   e           k disk
750aAFtruckh    if   e           k disk

     I*----------------------------------------------------------------
     I*  *PICKLBL  -  Picking label options
     I*----------------------------------------------------------------
     I*
     I* Fields
     I*
     I*    OPCLVL  -  Qty level for combined labels.
     I*    OPCWRB  -  Print combined label warning before.
     I*    OPCWRA  -  Print combined label warning after.
     I*    OPUWRB  -  Print unit of measure warning before.
     I*    OPUWRA  -  Print unit of measure warning after.
     I*    OPTEXT  -  Text for last line of label.
     I*    OPERR   -  Error label ratio.
     I*    OPCWGT  -  Catch weight label ratio.
     I*    OPLPGM  -  Picking label program.
     I*    OPPDEV  -  Printer device.
     I*    OPPFRM  -  Printer form.
     I*
     I* Data structure
     I*
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

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
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whse            s              3  0
750fAd $pOutStr        s           3072    varying
750fAd outStart        s              5  0
750fAd outEnd          s              5  0

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
      /free

        // Test for *BLTTEST

        if w1cmd = '*BLTTEST';
          // Set must be entered
          if w1set = '';
            error = *on;
            errmsg = 'Label set must be entered for *BLTTEST';
            exsr zm0105;
            leavesr;
          endif;
          leavesr;
        endif;

770bA   // Verify Output Type
770bA
770bA   if w1outtype<>'' and w1outtype<>'N' and w1outtype<>'D'
770bA    and w1outtype<>'O' and w1outtype<>'I' and w1outtype<>'R'
770bA    and w1outtype<>'Q';
770bA       error = *on;
770bA       errmsg = 'Invalid Output Type entered';
770bA       exsr zm0105;
770bA       leavesr;
770bA   endif;

770bA   // Device only allowed with output type D
770bA
770bA   if w1outtype <> 'D' and w1dev <> '';
770bA     error = *on;
770bA     errmsg = 'Device only allowed for Output Type D';
770bA     exsr zm0105;
770bA     leavesr;
770bA   endif;

770bA   // Device must be entered when output type is D
770bA
770bA   if w1outtype = 'D' and w1dev = '';
770bA     error = *on;
770bA     errmsg = 'Device must be entered for Output Type D';
770bA     exsr zm0105;
770bA     leavesr;
770bA   endif;

        // Tran or lbl must be entered
770aD   // Decided not to force this right now because
770aD   // some commands don't need them

770aD   //if w1trn# = 0 and w1lbl# = 0;
770aD   //  error = *on;
770aD   //  errmsg = 'Trn# or Lbl# must be entered';
770aD   //  exsr zm0105;
770aD   //  leavesr;
770aD   //endif;

        // Get Transaction if entered

        if w1trn# <> 0;
          chain (w1whse: w1trn#) pirtranw;
          if not %found(pirtranw);
            error = *on;
            errmsg = 'Transaction not found '
                   + '(whs:' + %char(w1whse) + ', '
                   + 'trn:' + %char(w1trn#) +')';
            exsr zm0105;
            leavesr;
          endif;
        endif;

        // If Tran entered, must be Selection

        if w1trn# <> 0 and ptcat <> 'SELECT';
          error = *on;
          errmsg = 'Transaction not for Selection '
                 + '(subcat:' + ptsub + ')';
          exsr zm0105;
          leavesr;
        endif;

        // If Tran entered, get route

        if w1trn# <> 0;
          chain (w1whse: ptrtpo) rtehed;
          if not %found(rtehed);
            error = *on;
            errmsg = 'Route not found for Tran Route Id '
                   + %trimr(ptrtpo);
            exsr zm0105;
            leavesr;
          endif;
        endif;

        // Get Label if entered

        if w1lbl# <> 0;
          chain (w1whse: w1lbl#) worklblw;
          if not %found(worklblw);
            error = *on;
            errmsg = 'WORKLBLW not found '
                   + '(whs:' + %char(w1whse) + ', '
770aM              + 'lbl:' + %char(w1lbl#) +')';
            exsr zm0105;
            leavesr;
          endif;
        endif;

        // If only label entered, get route

        if w1trn# = 0 and w1lbl# > 0;
          chain (w1whse: lwrte) rtehed;
          if not %found(rtehed);
            error = *on;
            errmsg = 'Route not found for Label Route Id '
                   + %trimr(lwrte);
            exsr zm0105;
            leavesr;
          endif;
        endif;

        // If trn# and lbl# entered, lbl must be for same tran;

        if w1trn# <> 0 and w1lbl# <> 0 and pttrn# <> lwtrn#;
          error = *on;
          errmsg = 'Label cannot be for different transaction '
                 + '(pttrn#:' + %char(pttrn#) + ', '
770aA            + '(w1lbl#:' + %char(w1lbl#) + ', '
                 + 'lwtrn#:' + %char(lwtrn#) +')';
          exsr zm0105;
          leavesr;
        endif;

        // If rtid and trn# entered, rtid's must match

        if (w1rtid <> '' and w1trn# <> 0 and w1rtid <> ptrtpo);
          error = *on;
          errmsg = 'Route Id does not match Tran '
                   + '(whs:' + %char(w1whse) + ', '
                   + 'Trn Rtid:' + ptrtpo +')';
          exsr zm0105;
          leavesr;
        endif;

        // If rtid and lbl# entered, rtid's must match

        if (w1rtid <> '' and w1lbl# <> 0 and w1rtid <> lwrte);
          error = *on;
          errmsg = 'Route Id does not match Label '
                   + '(whs:' + %char(w1whse) + ', '
770aM              + 'Lbl Rtid:' + lwrte +')';
          exsr zm0105;
          leavesr;
        endif;

        // If route id not entered, get from tran

        if w1rtid = '' and w1trn# <> 0;
          w1rtid = ptrtpo;
        endif;

        // If route id not entered, get from label

        if w1rtid = '' and w1lbl# <> 0;
          w1rtid = lwrte;
        endif;

        // If type O = LABELOUT and Lbl# entered,
        // Label must be type O or B and have a pick qty

        if w1outtype = 'O' and w1lbl# <> 0;
          if lwtype <> 'O' and lwtype <> 'B';
            error = *on;
            errmsg = 'Label must be Pick or Bulk (' + lwtype + ')';
            exsr zm0105;
            leavesr;
          endif;
          if lwqpck = 0;
            error = *on;
            errmsg = 'Label pick qty cannot be zero';
            exsr zm0105;
            leavesr;
          endif;
        endif;

        // If Lbl# not entered, Check for valid label

770aD   //if w1lbl# = 0;
770aM   if w1lbl# = 0 and w1trn# <> 0;
          setll (w1whse: ptrtpo: w1trn#) worklb94;
          dow 1=1;
770aM       reade (w1whse: ptrtpo: w1trn#) worklb94;
            if %eof(worklb94);
              error = *on;
              errmsg = 'WORKLB94 record not found '
                     + '(whs:' + %char(w1whse) + ', '
                     + 'rtid:' + %char(ptrtpo) + ', '
                     + 'trn:' + %char(w1trn#) +')';
              exsr zm0105;
             leavesr;
            endif;
            // Skip label if not O or B
            if lwtype <> 'O' and lwtype <> 'B';
              iter;
            endif;
            // Skip no qty picked
            if lwqpck = 0;
              iter;
            endif;
            leave;
          enddo;
770aA   endif;

        // Get Picking options

770aA   if w1lbl# <> 0 or w1trn# <> 0;
750aA     if %subst(lwtruk: 1: 1) = '*';
            chain ('*PICKLBA': lwwhse: lwtruk: lwszon) optionz;
750aA     else;
750aM       chain (lwwhse: lwtruk) truckh;
750aM       if not %found(truckh);
750aA         error = *on;
750aA         errmsg = 'TRUCKH record not found for '
750aA                + %char(lwwhse) +'/' + %trim(lwtruk);
750aA         exsr zm0105;
750aA         leavesr;
750aM       else;
750aM         chain ('*PICKLBA': lwwhse: thztmp: lwszon) optionz;
750aM       endif;
750aA     endif;
          if not %found(optionz);
            error = *on;
            errmsg = 'OPTIONZ record not found (*PICKLBL'
                   + '/' + %char(lwwhse) +'/' + %trim(lwtruk)
                   + '/' + %trim(lwszon) + ')';
            exsr zm0105;
            leavesr;
          endif;
770aA   endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
      /free
        w1client = client;
        w1cliloc = cliloc;
        w1hostsys = hostsys;
        w1cmd = '*PRINT';
        w1whse = $whse;
        w1rtid = '';
        w1trn# = 0;
        w1lbl# = 0;
        w1outtype = 'N';
        w1set = '';
        w1dev = '';
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr
     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm      *blanks       client           10
     C                   parm      *blanks       cliloc           10
     C                   parm                    cliInit           3
     C                   parm                    hostSys          10
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

500dA* Get User information.
500dA
500dAC                   call      'GETUSER'
500dAC                   parm      #user         $code            10
500dAC                   parm      0             $whse             3 0
500dAC                   parm      0             $emp#             5 0
500dAC                   parm      *blanks       $fnam            15
500dAC                   parm      *blanks       $init             1
500dAC                   parm      *blanks       $lnam            20
500dAC                   parm      *blanks       $whdp             5
500dAC                   parm      *blanks       $styp             1
500dAC                   parm      *blanks       $shft             6
500dAC                   parm      *blanks       $crew             6
500dAC                   parm      0             $nhrs             3 1
500dAC                   parm      *blanks       $rtn              8
500dA
500dAC                   if        $rtn = '*ERROR'
500dAC                   eval      $whse = 0
500dAC                   endif

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZPFMT    Call PFMT
     *----------------------------------------------------------------

     C     zzpfmt        begsr
     C                   call      'PFMT'
     C                   parm                    $pcmd             8
     C                   parm                    w1set
     C                   parm                    w1format          8
     C                   parm      w1whse        $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
     C                   parm                    $pszon            6
     C                   parm                    $ptruk           10
     C                   parm      rhrte         $prte             5
     C                   parm                    opzdta
     C                   parm      w1trn#        $ptrn#            7 0
     C                   parm      w1lbl#        $plbl#            7 0
     C                   parm                    $pqty             5 0
     C                   parm                    $pcwt             7 2
720aAC                   parm      w1outtype     $pOutType         1
750fAC                   parm                    $pRtnCode        10
750fAC                   parm                    $pRtnMsg         99
     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off
      /free

        error = *off;

        // See if we should overrid the device

770bM   if w1outtype = 'D';
750bM     oppdev = w1dev;
        endif;

750bM   // if Set not entered, use default

        if w1set = '';
          w1set = %subst(oplpgm: 5: 6);
        endif;

        // Call PFMT

        $pcmd  = w1cmd;
        $prtid = lwrte;
        $pcomp = lwcomp;
        $ptzon = lwtzon;
        $pgen  = lwgen;
        $pszon = lwszon;
        $ptruk = lwtruk;
        $ptrn# = lwtrn#;

        exsr zzPFMT;

        $pcmd  = '*CLOSE';
        exsr zzPFMT;

        // Display message sent back

        if $pRtnCode <> '';
          error = *on;
          errmsg = 'PFMT: ' + $pRtnMsg;
          exsr zm0105;
        else;
          errmsg = 'PFMT: Returned without message';
          exsr zm0105;
        endif;

      /end-free
     C                   endsr

