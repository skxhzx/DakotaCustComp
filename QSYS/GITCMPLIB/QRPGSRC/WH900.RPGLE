500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  WH900     Simple table lookup/verify
     *  06 July, 1994
     *  Hemant Kapadia
     *
     *  SK900 - 1.00
     *
     *  Revisions
     *
500 A*    05/24/06  DAS  5.00
     *      - Added Multilingual logic.
     *
730aA*    12/07/19  DAS  7.30a
     *      - Converted to ILE
     *      - Enh: Validating warehouse against glousr file
     *
750aA*    04/15/21  DAS  7.50a
     *      - Revised to only open format file when running
     *        interactively. It is assumed this will only
     *        happen *VERIFY'
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  91        PROTECT "POSITION TO" FIELD #1
     *  92        PROTECT "POSITION TO" FIELD #2
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fwh900fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(msgrec:msgk)
750aAF                                     usropn
     Fworkopt   uf a e           k disk
     Fwarehs    if   e           k disk
     F                                     rename(whrec:record)
730aAFglousr    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D desc            s             20    dim(1) ctdata perrcd(1)
500 AD descsp          s             20    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lcode                19     21  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dskey                  1     50
     D  whcode                 1      3  0 inz(0)
     *----------------------------------------------------------------
     *  Data structure for PgUp/Dn routines
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
     D #msgsp          c                   const('PIRMSGFSP ')
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
     *  Variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D goback          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
730aAD alphaWhse       s              3
730aAD dbWhse          s              3  0
730aAD forever         s               n
730aAD fromWhse        s              3  0
730aAD glousrFound     s               n
730aAD pos             s              3  0
730aAD startPos        s              3  0
730aAD toWhse          s              3  0
730aAD whseAllowed     s               n
730aAD whsLength       S              3s 0
730aAd wkpos           s              5s 0
730aAD wkwhse          S              3a
730aAD wkwhs1B         s              2a
730aAD wkwhsB1B        s              3a
730aAD wkwhs2B         s              3a
730aAD wkwhsB2B        s              4a
730aAD wkwhs3B         s              4a
730aAD wkwhsB3B        s              5a
750aAD usingScreen     s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $LCMD   *SELECT  - Selection lookup.
     *              *VERIFY  - Verify key.
     *      $LPRG   Program to send messages back to.
     *      $LUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $LUKY   Contains first key selected.
     *      $LRTN   blank    - No problem encountered.
     *              *OK      - Unique key exists for *VERIFY
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *              -or- Description of verified code.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $lparm
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $lrtn = *blanks
     C                   exsr      zzinz2
     C                   if        $lcmd = '*VERIFY '
     C                   exsr      zzvrfy
     C                   eval      nxtscr = 'EOJ'
     C                   else
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endif
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
750aAC                   if        usingScreen
     C                   exsr      zsclr
750aAC                   endif
     C                   return
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
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     titlesp
500 AC                   other
     C                   write     title
500 AC                   endsl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   read      postnsp                                50
500 AC                   other
     C                   read      postnrec                               50
500 AC                   endsl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   read      dspsfcsp                               50
500 AC                   other
     C                   read      dspsfc                                 50
500 AC                   endsl
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
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
     C                   cas                     ent01
     C                   endcs
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
750aA*
750aA*  See if we should work with screens
750aA*
750aAC                   call      'GETJTYPE'
750aAC                   parm                    usingScreen
750aAC                   if        usingScreen
750aAC                   open      wh900fm
750aAC                   endif
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

750aAC                   if        usingScreen

     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsflsp                             79
500 AC                   other
     C                   write     dspsfl                               79
500 AC                   endsl
     *
     *   Make sure option work file is empty.
     *
     C                   exsr      clrsch

750aAC                   endif
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     dspsflsp                           79
500 AC                   other
     C     x             chain     dspsfl                             79
500 AC                   endsl
     C                   if        not *in79
     C                   move      '  '          option
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   other
     C                   update    dspsfl
500 AC                   endsl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dskey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     C                   if        otaken = '0'
     C                   eval      $lrtn = '*CANCEL '
     C                   else
     C                   eval      $lrtn = '*SELECT '
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     ent01e        endsr
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
     C     fileky        chain     record                             79
     C                   if        *in79
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
     C     fileky        setll     record
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
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     *
     *  Move first selected value to $LUKY  parameter and set
     *     the option taken flag.
     *
     C                   eval      otaken = *off
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                                79
     C                   if        not *in79
     C                   eval      otaken = *on
     C                   eval      $luky = wkokyu
     C                   endif
     C     optnse        endsr
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
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
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
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
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
     C                   eval      forceb = *off
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
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
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
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
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
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the changed options.
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   readc     dspsflsp                               79
500 AC                   other
     C                   readc     dspsfl                                 79
500 AC                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid.
     *
     C                   if        option <> *blanks  and
     C                             option <> '1'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     *  Save option
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   move      option        wkoopt
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   move      option        wkoopt
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsflsp
500 AC                   other
     C                   write     dspsfl
500 AC                   endsl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsfcsp
500 AC                   other
     C                   write     dspsfc
500 AC                   endsl
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     optrecsp
500 AC                   write     cmdrecsp
500 AC                   other
     C                   write     optrec
     C                   write     cmdrec
500 AC                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     postnsp
500 AC                   other
     C                   write     postnrec
500 AC                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     1             chain     dspsflsp                           79
500 AC                   other
     C     1             chain     dspsfl                             79
500 AC                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   other
     C                   update    dspsfl
500 AC                   endsl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsfcsp
500 AC                   other
     C                   write     dspsfc
500 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     dspsflsp                           79
500 AC                   other
     C     x             chain     dspsfl                             79
500 AC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   move      wkoopt        option
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   other
     C                   update    dspsfl
500 AC                   endsl
     C                   endif
     C                   enddo
     C                   endsr
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
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $lprg         #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR1001  Invalid code.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp        errmsg
500 AC                   other
     C                   movea     desc          errmsg
500 AC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $lmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
730aAC                   dow       forever = forever
     *
     *    Code to use when we are not using a partial key.
     *
     C                   read      record                                 79
     *
     *    Code to use when we do have a partial key to use.
     *
     *R         PARTKY    READERECORD                   79
     *

730aA*    Verify user is allowed to use warehouse.
730aA
730aA /free
730aA
730aA    if *in79 = *on;
730aA      leave;
730aA    endif;
730aA
730aA    dbWhse = whcode;
730aA    exsr ChkWhse;
730aA
730aA    if whseAllowed;
730aA      leave;
730aA    endif;
730aA
730aA /end-free
730aA
730aAC                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
730aAC                   dow       forever = forever
     *
     *    Code to use when we are not using a partial key.
     *
     C                   readp     record                                 79
     *
     *    Code to use when we do have a partial key to use.
     *
     *R         PARTKY    REDPERECORD                   79
     *

730aA*    Verify user is allowed to use warehouse.
730aA
730aA /free
730aA
730aA    if *in79 = *on;
730aA      leave;
730aA    endif;
730aA
730aA    dbWhse = whcode;
730aA    exsr ChkWhse;
730aA
730aA    if whseAllowed;
730aA      leave;
730aA    endif;
730aA
730aA /end-free
730aA
730aAC                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    whcode
     *
     *  Define partial key for main file (if needed).
     *
     *R         PARTKY    KLIST
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initialization every time program is called.
     *
     C     zzinz2        begsr
500aA*
500aA*   Get employee options.
500aA*
500aAC                   call      'GETUSER'
500aAC                   parm      #user         e$code           10
500aAC                   parm                    e$whse            3 0
500aAC                   parm                    e$emp#            5
500aAC                   parm                    e$fnam           15
500aAC                   parm                    e$init            1
500aAC                   parm                    e$lnam           20
500aAC                   parm                    e$whdp            5
500aAC                   parm                    e$styp            1
500aAC                   parm                    e$shft            6
500aAC                   parm                    e$crew            6
500aAC                   parm                    e$nhrs            3 1
500aAC                   parm                    e$rtn             8
500aAC                   parm                    e$bpu             1
500aAC                   parm                    e$lng             2
500aAC                   if        e$rtn <> '*OK'
500aAC                   eval      e$lng = 'EN'
500aAC                   endif

730aA /free
730aA
730aA    chain (#user) glousr;
730aA    if %found(glousr);
730aA      glousrFound = *on;
730aA    else;
730aA      glousrFound = *off;
730aA    endif;
730aA
730aA /end-free

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
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   if        ptinp1 <> *zeros
     C                   eval      whcode = ptinp1
     C                   eval      ptinp1 = *zeros
     C                   eval      repos = *on
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
     C     *loval        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     *hival        setll     record
     C                   endif
     C                   endif
     *
     *    Code to use when we do have a partial key to use.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         PARTKY    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         PARTKY    SETGTRECORD
     *R                   END
     *R                   END
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZVRFY   Verify unique key.
     *
     C     zzvrfy        begsr
     C                   eval      dskey = $luky
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   eval      $lrtn = '*OK     '
     C                   movel     whdesc        $lerm
     C                   else
     C                   eval      $lrtn = '*PGMQ   '
     C                   exsr      zm1001
     C                   endif
730aA /free
730aA    if $lrtn = '*OK';
730aA
730aA      dbWhse = whcode;
730aA      exsr ChkWhse;
730aA
730aA      if not whseAllowed;
730aA        $lrtn = '*PGMQ';
730aA        exsr zm1001;
730aA      endif;
730aA
730aA    endif;
730aA /end-free
     C                   endsr

730aA*----------------------------------------------------------------
730aA*  ChkWhse   Check user authorized to warehouse
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr ChkWhse;

         whseAllowed = *off;

         // If user is not found in GLOUSR, then allow all warehouses

         if not glousrFound;
           whseAllowed = *on;
           leavesr;
         endif;

         // See if user authorized to warehouse

         select;
           when gurel = 'EQ';
             exsr ChkWhseList;
           when gurel = 'LS';
             exsr ChkWhseList;
           other;
             exsr ChkWhseRange;
         endsl;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  ChkWhseList  Check warehouse against list
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr ChkWhseList;

         wkwhse = %char(dbWhse);
         whsLength = %Len(%Trim(wkWhse));

         select;

           when whsLength = 1;
             wkwhs1B = %trim(wkwhse);
             wkwhsB1B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs1B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB1B: guvalue);
             endif;

           when whsLength = 2;
             wkwhs2B = %trim(wkwhse);
             wkwhsB2B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs2B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB2B: guvalue);
             endif;

           when whsLength = 3;
             wkwhs3B  = %trim(wkwhse);
             wkwhsB3B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs3B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB3B: guvalue);
             endif;

         endsl;

         if wkpos > 0;
           whseAllowed = *on;
         endif;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  ChkWhseRange   Check warehouse against range
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr ChkWhseRange;

         fromWhse = 0;
         toWhse = 0;
         guvalue = %trim(guvalue);

         // Get first value

         wkpos = %scan(' ': guvalue);

         // If string is not 1 - 3 characters,
         // something is defined wrong so get out.

         if wkpos < 2 or wkpos > 4;
           leavesr;
         endif;

         // Turn string into number

         alphaWhse = %subst(guvalue: 1: wkpos-1);
         monitor;
           fromWhse = %dec(alphaWhse: 3: 0);
         on-error;
           leavesr;
         endmon;

         // Do non-RG checks

         select;
           when gurel = 'GT';
             if dbWhse > fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'GE';
             if dbWhse >= fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'LT';
             if dbWhse < fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'LE';
             if dbWhse <= fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
         endsl;

         // Get out for any other non-RG check.

         if gurel <> 'RG';
           leavesr;
         endif;

         // Get second value and check range.

         // If we don't find another non-blank character,
         // something is defined wrong so get out.

         startPos = %check(' ': guvalue: wkpos);
         if startPos = 0;
           leavesr;
         endif;

         // If we don't find a space after the above character,
         // something is defined wrong so get out.

         wkpos = %scan(' ': guvalue: startPos);
         if wkpos = 0;
           leavesr;
         endif;

         // If the length of the string we find is > 3,
         // something is defined wrong so get out.

         if (wkpos - startPos) > 3;
           leavesr;
         endif;

         // Now turn string into number

         alphaWhse = %subst(guvalue: startPos: wkpos-1);
         monitor;
           toWhse = %dec(alphaWhse: 3: 0);
         on-error;
           leavesr;
         endmon;

         // See if whse is within range

         if (dbWhse >= fromWhse) and (dbWhse <= toWhse);
           whseAllowed = *on;
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  DESC
Warehouse Code
**  DESCSP
Warehouse Code
