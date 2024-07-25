     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *  04 October 2006
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510  *  04 October 2006  RAH  5.10
     *     Revision:  Removed PAKERCW and replaced with UCICW
510a *  01 November 2006 RAH  5.10
     *     Revision:  Changed subfile select to compare item
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fce190fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(cwesfl:recno)
     F                                     sfile(msgrec:msgk)
510 aFucicw7    if   e           k disk
510 aF                                     rename(ucirec:record)
     Flabel7    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(7) ctdata perrcd(1)
     D fkey            s             50    dim(14)
     D ukey            s             50    dim(14)
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D dsfkey          ds
     D  wtran                  1      7  0
     D  word                   8     14  0
     D  wseq                  15     19  0
     D  witm                  20     34
     D  wseqq                 35     37  0
     *
     D dsukey          ds
     D  wtran#                 1      7  0
     D  word#                  8     14  0
     D  wseq#                 15     19  0
     D  witm#                 20     34
     D  wseqq#                35     37  0
     *----------------------------------------------------------------
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lcode                22     27
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erfld                  1     30
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
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
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
     * Work Fields
     *----------------------------------------------------------------

     d $ptrn#          s              7  0
     d $time           s              6  0
     d $rtncd          s             10
     d dsplyd          s              2  0
     d w3item          s             15
     d w3qrmn          s              5  0
     d w3scan          s              5  0
510 ad lbordin         s                   like(lbord)
510 ad lbseqin         s                   like(lbpseq)
     d lbitmin         s                   like(lbitem)
     d lbtrn#in        s                   like(lbtrn#)
     d goback          s              2  0
     d $msgf           s             10
     d #msgid          s              7
     d #msgtp          s              7
     d #pgmq           s             10
     d @pwhse          s              3  0
     d bot             s              1
     d clear           s              5  0
     d cmdtkn          s              1
     d comand          s              5  0
     d enter           s              5  0
     d error           s              1
     d first           s              1
     d forceb          s              1
     d forevr          s              1
     d help            s              5  0
     d hld_status      s              5  0
     d moreln          s              7
     d msgk            s              4  0
     d nxtscr          s              3
     d p               s              2  0
     d pagcmd          s              8
     d recno           s              4  0
     d repos           s              1
     d rolldn          s              5  0
     d rollup          s              5  0
     d sclear          s              1
     d stop            s              1
     d top             s              1
     d warn            s              1
     d y               s              4  0

     *----------------------------------------------------------------
     *  Main line
     *
     *  Entry from call
     C     *entry        plist
     C                   parm                    lbordin
     C                   parm                    lbseqin
     C                   parm                    lbitmin
     C                   parm                    lbtrn#in
     C                   parm                    portn             8
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      scr01i
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98=*on
     C                   else
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       212223
     C                   setoff                                       249002
     C                   eval      cmdtkn = *off
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   endif
     *
     *  Overlay screen with screen to be processed.
     *
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   if        recno = 0
     C                   eval      nxtscr = 'EOJ'
     C                   eval      portn = '*NOGOOD'
     C                   else
     C                   exsr      sfldsp
     *                  EXSR      ZMDMSG
     C                   write     cmdline
     *
     C                   read      cwectl                                 50
     C                   eval      hld_status = status
     *
     *   Initialize error subfile
     *
     *                  EXSR      ZMCMSG
     C                   endif
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      pagcmd = '*REFRESH'
     C                   eval      wtran# = lbtrn#in
     C                   eval      word# = lbordin
     C                   eval      wseq# = lbseqin
     C                   eval      witm# = lbitmin
     C                   eval      wseqq# = 1
     C                   eval      wtran = lbtrn#in
     C                   eval      word = lbordin
     C                   eval      wseq = lbseqin
     C                   eval      witm = lbitmin
     C                   eval      wseqq = 1
     C                   exsr      pag01
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     C                   if        word<>lbordin or wtran<>lbtrn#in
     C                             or wseq<>lbseqin or witm<>lbitmin
     C                   eval      wtran = lbtrn#in
     C                   eval      word = lbordin
     C                   eval      wseq = lbseqin
     C                   eval      witm = lbitmin
     C                   eval      wseqq = 1
     C                   eval      wtran# = lbtrn#in
     C                   eval      word# = lbordin
     C                   eval      wseq# = lbseqin
     C                   eval      witm# = lbitmin
     C                   eval      wseqq# = 1
     C                   endif
     *
     *  TEST FOR ROLLUP
     *
     C                   if        hld_status = rollup
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT'
510ad*    fileky        setgt     record
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        hld_status = rolldn
     C     1             chain     cwesfl                             65
510 aC  n65fileky        chain     record                             65
510 aC                   if        %found
510 aC                   eval      wtran = ucipkt
     C                   eval      word = lbordin
     C                   eval      wseq = lbseqin
     C                   eval      witm = lbitmin
510 d*                  eval      wseqq = w1seq-1
     C                   if        wseqq = 0
     C                   eval      pagcmd = '*TOP'
     C                   goto      rol01e
     C                   endif
510 aC                   eval      wtran# = ucipkt
     C                   eval      word# = lbordin
     C                   eval      wseq# = lbseqin
     C                   eval      witm# = lbitmin
510 d*                  eval      wseqq# = w1seq-1
     C     fileky        setll     record
     C                   endif
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
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
     C                   if        pagcmd<>'*TOP'
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
     C                   endif
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 3 GOOD RECORDS
     *
     C                   eval      p = p+1
     C                   exsr      sfladd
     C                   if        p = 3
     C                   eval      stop = '1'
     C                   if        forceb = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfwd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = '0'
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
     C                   eval      goback = p + 3
     *  if eof reached in previous roll function reset pointer
     *
     C     fileky        setgt     record
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      stop = '0'
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
     C                   eval      stop = '1'
     C                   eval      top = '1'
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   eval      p = p+1
     C                   if        p>goback
     C                   eval      stop = '1'
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
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
     C     $pocmd        caseq     '*POSTN2'     fpos1
     C     $pocmd        caseq     '*POSTN2U'    fpos1u
     C     $pocmd        caseq     '*TOP'        zzpos1
     C     $pocmd        caseq     '*BOTTOM'     zzpos1
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize unique key (DSUKEY)
     *
510 aC                   eval      word# = lbord
510 aC                   eval      wseq# = lbseq
510 aC                   eval      witm# = uciitm
510 aC                   eval      wseqq# = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
510 aC                   eval      word# = lbord
510 aC                   eval      wseq# = lbseq
510 aC                   eval      witm# = uciitm
510 aC                   eval      wseqq# = 0
     C                   eval      $pouky = dsukey
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
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
     C     fileky        setll     record
     C                   readp     record                                 79
510 aC                   if        *in79 = *off and (ucipkt<>lbtrn#in
510 aC                              or uciitm<>lbitmin)
     C                   eval      *in79 = *on
     C                   endif
     *
     C     endgtp        endsr
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
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
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
510 aC                   eval      $portn = '*FOUND  '
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
510 aC                   if        *in79 = *on or ucipkt<>lbtrn#in
     C     fileky        setll     record
     C                   read      record                                 79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS1    Position to record
     *
     C     fpos1         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS1U   Position to record using unique key
     *
     C     fpos1u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     C                   exsr      zzcmd1
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C     hld_status    caseq     rollup        roll01
     C     hld_status    caseq     rolldn        roll01
     C                   cas                     ent01
     C                   endcs
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   Screen 1 command key routine
     *
     C     zzcmd1        begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT'
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL'
     C                   goto      cmd01e
     C                   endif
     *
     C     error         cabeq     '1'           cmd01e
     *
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   if        not *inkc and not *inkl
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     C                   endif
     *
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C                   read      record                                 79
510 aC                   if        *in79 = *off and (ucipkt<>lbtrn#in
510 aC                              or uciitm<>lbitmin)
     C                   eval      *in79 = *on
     C                   endif
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS1   Position to record
     *
     C     zzpos1        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
     C     fileky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     fileky        setll     record
     C                   endif
     C                   endif
     C                   endsr
     *
     C     zzpos         begsr
     C                   endsr
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
     C                   eval      first = *on
     *
     *  Initialize message handling
     *
     *                  EXSR      ZMIMSG
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
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1060  Pallet already scanned
     *
     C     zm1060        begsr
     C                   eval      #msgid = 'PIR1060'
     C                   eval      #msgtp = '*DIAG  '
     *R                 MOVEA     ERRMSG        $MD
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 2 error checking.
     *
     C     zzchk1        begsr
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1bfcl = lblbl#
     C                   eval      w1item = itdesc
510 aC                   eval      w1cwgt = uciwgt
510 aC                   eval      w1pplb = ucinbr
     *
     C     endfl1        endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = '1'
     C                   eval      recno = 1
     C                   write     cwectl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     C     labkey        setll     label7
     C     labkey        reade     label7
     *
     *  only display in subfile if selected transaction, catch weight item,
     *   and open quantity remaining
     *
510 aC                   if        lbtrn# = ucipkt  and
510aaC                             lbitem = lbitmin
     C                   eval      recno = recno +1
     C                   eval      y = recno
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   if        wtran=lbtrn#in and witm=lbitmin
     C
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfil1
     C                   write     cwesfl
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
     C                   eval      *in01 = '0'
     C                   write     cwectl
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Initialization.  Called from Mainline
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
     C                   eval      nxtscr = '01'
     C                   eval      *in02 = *on
     *
     *    - Get default warehouse for the user.
     *
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
     *
     C                   eval      @pwhse = #whse
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2 0
     C                   parm                    #lcol             3
     *
     *  Define keys used in program.
     *
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    wtran#
     C                   kfld                    word#
     C                   kfld                    wseq#
     C                   kfld                    witm#
     C                   kfld                    wseqq#
     *
     *  Define full key for main file.
     *
     C     fileky        klist
510 aC                   kfld                    @pwhse
510 aC                   kfld                    wtran#
     *
     C     labkey        klist
510 aC                   kfld                    ucipkt
510 aC                   kfld                    uciitm
     *
     C                   endsr
     *  COMPILE TIME TABLES
     *
**
