      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
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
     *  File Specs
     *----------------------------------------------------------------

     Fph112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fphrasetbl uf a e           k disk
     F                                     rename(phrec:record)

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pid                  19     23  0
     D  $plang                24     25

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

     D                 ds
     D  wopqndec               1      5  2
     D  dec                    4      5  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D txtFlag         s               n
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

     D xml             s            500
     D pPos            s              3  0
     D xPos            s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
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

     C                   if        nxtscr = '02 '
     C******             exfmt     screen2                              50
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

     *  Get field defaults if this is an add.

     c                   if        $pcmd = '*ADD'
     c                   exsr      zzdft1
     c                   else

     *  Otherwise get existing record(s).

     C                   eval      *in91 = *on
     c                   exsr      zzget1
     c                   exsr      zzfil1
     c                   endif

     C     end01i        endsr

     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzdft2
     C     end02i        endsr

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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif

     *  Test for other command keys

     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Some other key pressed.

     *     Check input and write/update record.

     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr

     *----------------------------------------------------------------
     *  SC2  -  Screen 2
     *----------------------------------------------------------------

     C     sc2           begsr

     *  Test for F3 - Exit

     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif

     *  Test for other command keys

     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2

     *  Some other key pressed.

     *     Check input and write/update record.

     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif

510cD***                 exsr      scr01i
510cD***                 if        error = *off
510cD***                 exsr      zzstart
510cD***                 endif

510cAC                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr

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

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *---------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *---------------------------------------------------------------

     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *---------------------------------------------------------------

     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *----------------------------------------------------------------

     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

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
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR0110  Number must be greater than zero
     *----------------------------------------------------------------

     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR0203  Value can not be blank.
     *----------------------------------------------------------------

     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $pmsg = #msgk
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
     *     PIR7974  Slot record is locked.
     *----------------------------------------------------------------

     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     C                   eval      $prtn = *blanks

     *   ID must be greater than zero

     C                   if        w1id <= 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Id'
     C                   exsr      zm0110
     C                   endif

     *   Verify language

     C                   if        w1lang <> 'EN'
     C                             and w1lang <> 'SP'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Language'
     C                   exsr      zm1001
     C                   endif

     *   Level must be greater than zero

     C                   if        w1level <= 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = 'Level'
     C                   exsr      zm0110
     C                   endif

     *   Phrase must be entered.

     C                   if        w1phrase = ' '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'Phrase'
     C                   exsr      zm0203
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   eval      error = *off

     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Test for F7 - Generate XML

     C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   exsr      zzXML
     C                   endif

     *  Test for F9 - Format Phrase

     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   exsr      zzXML
     C                   if        not error
     C                   call      'PH115'
     C                   parm                    w1Id
     C                   parm                    w1Phrase
     C                   parm                    xml
     C                   endif
     C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   eval      w1id = 0
     C                   eval      w1lang = 'EN'
     C                   eval      w1group = ' '
     C                   eval      w1level = 0
     C                   eval      w1phrase = ' '
     C                   eval      w1xml1   = ' '
     C                   eval      w1xml2   = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZDFT2   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft2        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
     C                   eval      w1id = phId
     C                   eval      w1lang = phLang
     C                   eval      w1group = phGroup
     C                   eval      w1level = phLevel
     C                   eval      w1phrase = phPhrase
     C                   exsr      zzxml

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get record from main file.

     C     fileky        chain     record                             7978

     *  Record locked.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif

     *  Record not found.

     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif

     *   If viewing, release record.

     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif

     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    $pid
     C                   kfld                    $plang

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

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Generate XML. Get out if error occurs.

     C                   exsr      zzxml
     C                   if        error = *on
     C                   goto      endup1
     C                   endif

     *  Move screen fields to record fields

     C                   eval      phid = w1Id
     C                   eval      phlang = w1Lang
     C                   eval      phgroup = w1Group
     C                   eval      phlevel = w1Level
     C                   eval      phphrase = w1Phrase
     C                   eval      phxml = w1xml1 + w1xml2

     *  Add record

     c     $pcmd         ifeq      '*ADD    '
     c                   write     record
     c                   if        %error
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endup1
     c                   end
     c                   else

     *  -OR- Update record (it was read and locked in ZZGET1)

     c                   update    record
     c                   if        %error
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endup1
     c                   end
     c                   end

     *   Move key values to parameters

     C                   eval      $pid = w1id
     C                   eval      $plang = w1lang

     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update record.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off
     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZXML    Generate XML string.
     *----------------------------------------------------------------

      /free
       begsr zzxml;
         error = *off;
         xml = '<P>';
         xPos = 4;
         pPos = 1;
         txtFlag = *off;

         dou pPos > %len(%trimr(w1Phrase));
           select;
             when %subst(w1phrase:pPos:1) = '&';
               exsr zzxmlVar;
             other;
               exsr zzxmlTxtStart;
               %subst(xml:xPos) = %subst(w1phrase:pPos:1);
               xPos += 1;
               pPos += 1;
           endsl;
         enddo;

         exsr zzxmlTxtEnd;
         %subst(xml:xPos) = '</P>';

         w1xml1 = %subst(xml:1:50);
         w1xml2 = %subst(xml:51:50);

       // Check for XML overflow.

         if %len(%trim(xml)) > 100;
           error = *on;
           *in25 = *on;
           *in05 = *on;
           errmsg = 'Converted XML greater than 100 character limit';
           exsr zm0105;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZXMLVAR   Convert variable into XML
     *----------------------------------------------------------------

      /free
       begsr zzxmlVar;

         select;

           when %subst(w1phrase:pPos:4) = '&EMP';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<EMP/>';
             xPos += 6;
             pPos += 4;

           when %subst(w1phrase:pPos:3) = '&ID';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<ID/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:5) = '&ITEM';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<ITEM/>';
             xPos += 7;
             pPos += 5;

           when %subst(w1phrase:pPos:4) = '&LOC';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<LOC/>';
             xPos += 6;
             pPos += 4;

           when %subst(w1phrase:pPos:5) = '&LCNS';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<LCNS/>';
             xPos += 7;
             pPos += 5;

           when %subst(w1phrase:pPos:5) = '&LTRN';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<LTRN/>';
             xPos += 7;
             pPos += 5;

           when %subst(w1phrase:pPos:4) = '&PGM';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<PGM/>';
             xPos += 6;
             pPos += 4;

           when %subst(w1phrase:pPos:4) = '&TRN';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<TRN/>';
             xPos += 6;
             pPos += 4;

           when %subst(w1phrase:pPos:5) = '&USER';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<USER/>';
             xPos += 7;
             pPos += 5;

           when %subst(w1phrase:pPos:3) = '&V1';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<V1/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:3) = '&V2';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<V2/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:3) = '&V3';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<V3/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:3) = '&V4';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<V4/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:3) = '&V5';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<V5/>';
             xPos += 5;
             pPos += 3;

           when %subst(w1phrase:pPos:5) = '&WHDP';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<WHDP/>';
             xPos += 7;
             pPos += 5;

           when %subst(w1phrase:pPos:5) = '&WHSE';
             exsr zzxmlTxtEnd;
             %subst(xml:xPos) = '<WHSE/>';
             xPos += 7;
             pPos += 5;

            other;
             exsr zzxmlTxtStart;
             %subst(xml:xPos) = %subst(w1phrase:pPos:1);
             xPos += 1;
             pPos += 1;

            endsl;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzxmlTxtEnd   End text if necessary
     *----------------------------------------------------------------

      /free
       begsr zzxmlTxtEnd;

         if txtFlag;
           %subst(xml:xPos) = '</T>';
           xPos += 4;
           txtFlag = *off;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzxmlTxtStart  Start text if necessary
     *----------------------------------------------------------------

      /free
       begsr zzxmlTxtStart;

         if not txtFlag;
           %subst(xml:xPos) = '<T>';
           xPos += 3;
           txtFlag = *on;
         endif;

       endsr;
      /end-free
