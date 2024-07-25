      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PH112   Phrase table mainenance - Entry
     *  16 July 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    07/16/08  DAS  6.00  P#00045
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fph115fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

600bA /copy qcopysrc,p.bfcphras

     *----------------------------------------------------------------
     *  Program Parameters
     *----------------------------------------------------------------

600bAD  $pId           s              5p 0
600bAD  $pPhrase       s             50
600bAD  $pXML          s            100

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
      *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PGMINFDS

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
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D $msgf           s             10
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
     D lasttime        s              6  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D total           s              5  0
     D warn            s              1

600bAD  pPhraseId      s              5p 0
600bAD  pPhrase        s            100
600bAD  pWhse          s              3s 0
600bAD  pEmp#          s              5s 0
600bAD  pUser          s             10
600bAD  pPgm           s             10
600bAD  pItem          s             15
600bAD  pWhdp          s              5
600bAD  pLocation      s             15
600bAD  pTrn#          s              7p 0
600bAD  pLcns          s             15
600bAD  pLtrn          s              7p 0
600bAD  pVars          s            100

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pId      -  Phrase Id
     *      $pPhrase  -  Phrase
     *      $pXML     -  XML string
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pId
     C                   parm                    $pPhrase
     C                   parm                    $pXML

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr

     *   Set ON alarm indicator if error occured

     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif

     *   Overlay screen with error messages

     C                   exsr      zmdmsg

     *  Overlay screen with screen to be processed.

     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif

     *   Initialize error indicators and fields

     C                   setoff                                       010203
     C                   setoff                                       04
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0

     *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   eval      nxtscr = '01 '

     C                   eval      *in91 = *on
     c                   exsr      zzfil1

     C     end01i        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

     C     sc1           begsr

     *  Test for F3 - Exit

     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif

     *  Test for other command keys

     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Some other key pressed.

     *     Check input and write/update record.

     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C****               eval      nxtscr = 'EOJ'
     C     endsc1        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Initialize special keys

     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

     *  Initialize message handling

     C                   exsr      zmimsg

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #pgm
     C                   exsr      zmcmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

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

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr

     *----------------------------------------------------------------
     *---------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *---------------------------------------------------------------

     *----------------------------------------------------------------
     *   PIR0105  Generic message.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     PIR0110  Number must be greater than zero
     *----------------------------------------------------------------

     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     PIR0203  Value can not be blank.
     *----------------------------------------------------------------

     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *----------------------------------------------------------------
     *  ZZ Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off
     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

      /free

         w1XML1 = %subst($pXML:1:50);
         w1XML2 = %subst($pXML:51:50);

         w1Id = $pId;
         w1Whse = 900;
         w1Emp# = 10;
         w1User = #curruser;
         w1Pgm  = #pgm;
         w1Item = 'DA101';
         w1Whdp = 'DRY';
         w1Loc = 'DA-101-1';
         w1Trn# = 12345;
         w1Lcns = 'LIC101';
         w1Ltrn = 2468;
         w1Var1 = ' ';
         w1Var2 = ' ';
         w1Var3 = ' ';
         w1Var4 = ' ';
         w1Var5 = ' ';

         w1Fmt1 = ' ';
         w1Fmt2 = ' ';

         exsr zzupd1;

      /end-free
     C                   endsr

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

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

      /free
       begsr zzupd1;
         error = *off;

         pPhraseId = w1Id;
         pWhse = w1Whse;
         pEmp# = w1Emp#;
         pUser = w1User;
         pPgm  = w1Pgm;
         pItem = w1Item;
         pWhdp = W1whdp;
         pLocation = w1Loc;
         pTrn# = w1Trn#;
         pLcns = w1Lcns;
         pLtrn = w1Ltrn;
         pVars = fmtVars(w1Var1:w1Var2:w1Var3:w1Var4:w1Var5);

         pPhrase = fmtPhrase(pPhraseId:
                         $pXML:
                         pWhse:
                         pEmp#:
                         pUser:
                         pPgm:
                         pItem:
                         pWhdp:
                         pLocation:
                         pTrn#:
                         pLcns:
                         pLtrn:
                         pVars
               );

         w1Fmt1 = %subst(pPhrase:1:50);
         w1Fmt2 = %subst(pPhrase:51:50);

       endsr;
      /end-free
