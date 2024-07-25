      /copy qcopysrc,hspecs
710aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LTB02     Left the Building Slot/Item List Display
     *  14 January, 2022
     *  Kenneth Elder
     *
     *  Revisions
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fltb02fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fslot1     if   e           k disk
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
520bAFltb02pr   o    e             printer oflind(*in99)
     f                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     d fkey            s             50    dim(14)
     d ukey            s             50    dim(14)

     *----------------------------------------------------------------
     *  Variables
     *
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D BOT             s              1
     D CANCEL          s              1
     D CLEAR           s              5  0
     D COMAND          s              5  0
     D DSPLYD          s              2  0
     D E               s              2  0
     D ENTER           s              5  0
     D ERROR           s              1
     D FORCEB          s              1
     D FRSTKY          s                   like($PUKY)
     D GOBACK          s              2  0
     D HELP            s              5  0
     D MSGK            s              4  0
     D NOMORE          s              1
     D NXTSCR          s              3
     D OTAKEN          s              1
     D P               s              2  0
     D PAGCMD          s              8
     D RECNO           s              4  0
     D REFRSH          s              1
     D REPOS           s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
     D STOP            s              1
     D TOP             s              1
     D WARN            s              1
     D X               s              3  0
     D Y               s              3  0
     d iPdev           s             10
     d iAdjcde         s              2
     d iReturn         s             10
     d totitems        s              5  0
     d totqty1n        s              5  0
     d totqty2n        s              5  0
     d totqty3n        s              5  0
     d cntrec          s              5  0
     d @command        s            350
     d forever         s               n
     d wkError         s               n
     d wkRerr2         s             50
     d firstrec        s               n
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     d                 ds
     D $prtky                  1     50
     D  iWhse                  1      3  0
     d  iDept                  4      8
     d  iAisl                  9     11
     d  iLoc                  12     14  0
     d  iLvl                  15     16  0
     d  iHand                 17     18
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dskey                  1     50
     D  slwhse                 1      3  0
     d  slwhdp                 4      8
     d  slAisl                 9     11
     d  slLoc                 12     14  0
     d  slLvl                 15     16  0
     d  slHand                17     18

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *  GoCmd used to call external commands
     *  if Returncode is not 0 then error.  Error
     *  code is returned in Errmsgid

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0

     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Called programs
     *
     D @updltb         c                   const('UPDLTBSLT')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
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
     *      pWhse   Warehouse
     *      pDept   Department
     *      pDisp   LTB Parent Display
     *      pPdev   Print Device/Queue
     *      pAdjcde Adjust Code
     *
     *    Returned Parameters
     *      pReturn *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pDept             5
     C                   parm                    pAisl             3
     c                   parm                    pLoc              3 0
     c                   parm                    pLvl              2 0
     C                   parm                    pPdev            10
     C                   parm                    pAdjCde           2
     C                   parm                    pReturn          90
     *----------------------------------------------------------------
     *  Main line
     *
     c                   eval      *inlr=*on
     c                   eval      $prtky=*blanks
     c                   eval      iwhse=pwhse
     c                   eval      idept=pdept
     c                   eval      iAisl=pAisl
     c                   eval      iLoc=pLoc
     c                   eval      iLvl=pLvl
     c                   eval      ipdev=ppdev
     c                   eval      iadjcde=padjcde
     c                   eval      ireturn=preturn
     C                   eval      *in97 = *on
     C                   eval      pReturn= *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   seton                                        lr
     C                   return

      *----------------------------------------------------------------
      *  AdjustQty - Adjust LTB slots to zero when user requests print/update
      *----------------------------------------------------------------

     c     adjustQty     begsr

      /free

             savever# = $slver#;
             clear $slot;
             clear $slot2;
             $slver# = savever#;

       // Move fields to slot data structure for quantity adjustment

             $slwhseu = *on;
             $slwhse  = slwhse;

             $slwhdpu = *on;
             $slwhdp = slwhdp;

             $sldispu = *on;
710dM        $sldisp = sldisp;

             $saitemu = *on;
             $saitem  = slitem;

             $saqtyu = *on;
700bA
             $saqty1 = slstk1*-1;
             $saqty2 = slstk2*-1;
             $saqty3 = slstk3*-1;

             $sacodeu = *on;
             $sacode  = pAdjCde;

             $samemou = *on;
             $samemo  = 'Adjust to Zero';

             $sabyu   = *on;
             $saby    = #user;

             $saemp#u = *on;
             $saemp# = #emp#;

             $saActionU = *on;
             $saAction = 'LTB';

             $saToAreaU = *on;
             $saToArea = 'Slot';

             $dricommand = '*SLOT';
             if $saqty1=0 and $saqty2=0 and $saqty3=0;
               $drisubcmd  = '%ZEROVFY';
               exec sql update slot set slstat='Z'
                    where slwhse=:slwhse and slwhdp=:slwhdp and sldisp=:sldisp;
             else;
               $drisubcmd  = '%ADJUST';
             endif;
             $drisys2upd = 'D';
             exsr zzDriCop2;

             if wkerror;
                pReturn = 'Slot: ' + %trim(sldisp) +
                          '.  Error(' + %trim($driReturn) + ')';
                return;
             else;
               if $saqty1<>0 or $saqty2<>0 or $saqty3<>0;
                 // zero verify the slot since it was set to zero
                 $dricommand = '*SLOT';
                 $drisubcmd  = '%ZEROVFY';
                 $drisys2upd = 'D';
                 exsr zzDriCop2;
               endif;
             endif;

      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   read      dspsfc                                 50
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
     C                   move      '01 '         nxtscr
     C                   move      $prtky        fkey
     C                   move      $prtky        ukey
     C                   write     CLR03END
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   eval      *in90 = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     comand        cmd02
     C                   endcs
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD12 - Return Cancel to display message as such
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      pReturn= '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD7 - Print and Clear LTB Slot Contents
     *
     C                   if        *inkg
      *      set and display prompt screen for F10 toconfirm print/update
     c                   eval      cmdln1='F12-Cancel'
     c                   write     clr03END
     c                   write     Title
     c                   write     Postnrec
     c                   write     cmdrec
     c     redisplay     tag

     c                   exfmt     confirm

     c                   if        *inkl
      *      when F12-Cancel they are returned to sub file list w/o update/print
     c                   goto      cmd01e
     c                   endif

     c                   if        *inkj
      *      when F10-Update we call the process to print the report and
      *      and clear the slots for the specified base slot sent
      *      We return update to display message on screen one that update happened
     c                   exsr      prtSltRpt
     c                   eval      pReturn='*UPDATE'
     c                   return
     c                   endif
      *       should not make it here but redisplay F10 Confirm prompt if
      *       anything other than F10 or F12 pressed
     c                   goto      redisplay
     C                   endif

     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD10 - Confirm to Print and Clear LTB Slot contents
     *
     C                   if        *inkj
     C                   exsr      updltbslot
     C                   eval      nxtscr='01'
     C                   move      '1'           cancel
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   move      '1'           cancel
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dskey = $pouky
      /free
              chain (slwhse:slwhdp:slaisl:slloc:slrlvl:slhand) slot1;
      /end-free
     C                   if        not %found (slot1)
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dskey = $pofky
      /free
           setll (slwhse:slwhdp:slaisl:slloc:slrlvl:slhand) slot1;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   move      '1'           bot
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = $prtky
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           bot
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      $prtky        fkey
     C                   move      $prtky        ukey
     C                   move      '0'           bot
     C                   move      '0'           top
     C                   move      '0'           stop
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   move      '1'           stop
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  Ensure valid status
     *
     c                   if        slstat<>'A'
     c                   iter
     c                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 14
     C                   move      '1'           stop
     C                   if        forceb = '1'
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   move      '0'           forceb
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 14
     C                   if        bot = '1'
     C                   if        goback = 14
     C                   move      '1'           forceb
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   move      '1'           stop
     C                   move      '1'           top
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   move      '1'           stop
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  prtSltRpt - Print Left the Building Slot/Item Report
     *
     C     prtSltRpt     begsr
     *    Determine whether valid device/queue to override output
     *    If invalid then override to qprint
     c                   call      'CHKOBJCL'
     c                   parm                    ipdev
     c                   parm      '*DEVD'       pdevtyp          10
     c                   parm      ' '           pRtn             10
     c                   if        pRtn = 'ERROR'
     *    if no printer device found look for outq
     c                   call      'CHKOBJCL'
     c                   parm                    ipdev
     c                   parm      '*OUTQ'       pdevtyp          10
     c                   parm      ' '           pRtn             10
     c                   endif
     C                   if        pRtn = 'ERROR'
     c                   eval      pdevtyp = '*QPRT'
     C                   endif
      /free
              // Set printer override using printer passed or qprint
               select;
                 when pdevtyp='*DEVD';
                   @command = 'OVRPRTF FILE(LTB02PR) DEV(' +
                              %trim(iPdev) + ') SAVE(*YES)';
                   returnCode = goCmd(%trim(@command));
                 when pdevtyp='*OUTQ';
                   @command = 'OVRPRTF FILE(LTB02PR) OUTQ(' +
                              %trim(iPdev) + ') SAVE(*YES)';
                   returnCode = goCmd(%trim(@command));
                 other;
                   @command = 'OVRPRTF FILE(LTB02PR) OUTQ(QPRINT)' +
                              ' SAVE(*YES)';
                   returnCode = goCmd(%trim(@command));
               endsl;

           // open printer file
            if not %open(ltb02pr);
              open ltb02pr;
            endif;

           // setup and print initial headings
            whsedept = %trim(w1wdsc) + '/' + %trim(w1ddsc);
            exsr prtHead;

           // Loop record set based on values based and print Slot/Item report
            firstrec=*on;
            totitems = 0;
            totqty1n = 0;
            totqty2n = 0;
            totqty3n = 0;
            setll (iWhse:iDept:iAisl:iLoc:iLvl) slot1;
            dow forever = forever;
              reade (iWhse:iDept:iAisl:iLoc:iLvl) slot1;
              if %eof(slot1);
                totitms = %editc(totitems:'Z');
                totqty1 = %editc(totqty1n:'Z');
                totqty2 = %editc(totqty2n:'Z');
                totqty3 = %editc(totqty3n:'Z');
                write total1;
                write foot1;
                leave;
              endif;

              if slstat<>'A';
                iter;
              endif;

              stkq1 = %editc(slstk1:'Z');
              stkq2 = %editc(slstk2:'Z');
              stkq3 = %editc(slstk3:'Z');
              totqty1n = totqty1n + slstk1;
              totqty2n = totqty2n + slstk2;
              totqty3n = totqty3n + slstk3;
              // get item description
              chain (slwhse:slitem) piritem;
              if %found(piritem);
                itmdsc = itdesc;
              else;
                itmdsc=*blanks;
              endif;

             // if indicator 99 then print headings
              if *in99 = *on;
                write head2;
                exsr prtHead;
              endif;

             // write detail line
              totitems = totitems + 1;
              write detail1;

              // zero slot
              exsr adjustQty;

            enddo;

            if %open(ltb02pr);
              close ltb02pr;
            endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  prtHead - Print Headings
     *
     C     prtHead       begsr
      /free
                         *in99=*off;
                         write head1;
                         write columns;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C     error         cabeq     '1'           rol01e
     C                   move      '*NEXT   '    pagcmd
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C     error         cabeq     '1'           rol01e
     C                   move      '*PREV   '    pagcmd
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno < 15
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   write     dspsfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE COMMAND LINE TO DISPLAY
     *
     c                   eval      cmdln1 = cmdln(1)
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  POSITION CURSOR TO FIRST Slot WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE updLtbSlot - Update LTB slot and
     *
     c     updLtbSlot    begsr
      *    Insert code call print program and then zero adjust slots to empty
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   eval      #pgmq = #prog
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   move      'PIR0101'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   move      'PIR0102'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   move      'PIR0103'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   move      'PIR0104'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   move      'PIR0106'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   move      'PIR0107'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C                   read      slot1                                  79
     c                   if        slaisl <> iAisl
     c                             or slloc <> iLoc
     c                             or slrlvl <> ilvl
     c                   eval      *in79='1'
     c                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C                   readp     slot1                                  79
     c                   if        slaisl <> iAisl
     c                             or slloc <> iLoc
     c                             or slrlvl <> ilvl
     c                   eval      *in79='1'
     c                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
      /free
           chain (slwhse:slwhdp:slaisl:slloc:slrlvl:slhand) slot1;
           if not %found(slot1);
             // set subfile fields
             w1item='Invalid';
             w1desc=*blanks;
             w1qty='0';
             w1disp=*blanks;
           else;
             // get item information
             chain (slwhse:slitem) piritem;
             if not %found(piritem);
               w1item='Invalid Item';
               w1qty=*blanks;
               w1desc=*blanks;
             else;
               w1item = slitem;
               w1desc=itdesc;
               select;
                 when itum3 <> *blanks;
                   w1qty = %char(slstk1) + '.' + %char(slstk2) + '.' +
                           %char(slstk3);
                 when itum2 <> *blanks;
                   w1qty = %char(slstk1) + '.' + %char(slstk2);
                 other;
                   w1qty = %char(slstk1);
               endsl;
             endif;
             w1disp=sldisp;
           endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   TIME                    time
     c                   eval      w1whse=%char(iwhse)
      /free
                chain (iwhse) warehs;
                if %found(warehs);
                  w1wdsc=whdesc;
                else;
                  w1wdsc=*blanks;
                endif;
      /end-free
     c                   eval      w1dept=idept
      /free
                chain (iWhse:w1dept) whdept;
                if %found(whdept);
                  w1ddsc=wddesc;
                else;
                  w1ddsc=*blanks;
                endif;
      /end-free
      *
      *   Get default values for the user.
      *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
      /free
              cntrec=0;
              exec sql select count(*) into :cntrec
                          from slot where slwhse=:iwhse and
                          slwhdp=:idept and slaisl=:iaisl and
                          slloc=:iloc and slrlvl=:ilvl and slstat='A';
              if sqlstt<>'00000' or cntrec=0;
                // if no data then return to screen 1
                preturn='*NODATA';
                return;
              endif;
      /end-free
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dskey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dskey
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     C     zzpos2        BEGSR
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   if        $pocmd = '*TOP'
      /free
           setll (iWhse:iDept:iAisl:iLoc:iLvl:'  ') slot1;
      /end-free
     C                   else
     C                   if        $pocmd = '*BOTTOM'
      /free
           setll (iWhse:iDept:iAisl:iLoc:iLvl:'99') slot1;
      /end-free
     C                   end
     C                   end
     C                   endsr

     *----------------------------------------------------------------
     *  zzdricop2  Call DRICOP2
     *----------------------------------------------------------------

     c     zzDriCop2     begsr
      *
     c                   eval      wkError = *off
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   endsl
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP2'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   endsl

     c                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  CMDLN - Command display line
F7=Update/Clear  F12=Cancel
