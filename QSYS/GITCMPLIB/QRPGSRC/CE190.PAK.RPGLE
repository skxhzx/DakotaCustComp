     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  CE190     Catch Weight Detail Display
     F*  29 August 2004
     F*  Kenneth Elder
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*       8 X 20 Screens for hand held scanners
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FCE190FM   CF   e             WORKSTN
     F                                     INFDS(infds)
     F                                     sfile(cwesfl:recno)
     F                                     SFILE(msgrec:msgk)
     fpakercw2  if   e           k disk
     f                                     rename(pcrec:record)
     flabel7    if   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(7) CTDATA PERRCD(1)
     d fkey            s             50    dim(14)
     d ukey            s             50    dim(14)
     I*----------------------------------------------------------------
     I*  Called program parameters
     I*
     d $postn          ds
     d  $pocmd                 1      8
     d  $poprg                 9     18
     d  $pofky                19     68
     d  $pouky                69    118
     d  $podsc               119    307
     d  $popt1               308    322
     d  $popt2               323    335
     d  $portn               336    343
     d  $poerm               344    403
     d  $pomsg               336    339
     d*----------------------------------------------------------------
     d*  Data structure for FKEY and UKEY
     d*
     d dsfkey          ds
     d  wtran                  1      7  0
     d  word                   8     14  0
     d  wseq                  15     19  0
     d  witm                  20     34
     d  wseqq                 35     37  0
     d*
     d dsukey          ds
     d  wtran#                 1      7  0
     d  word#                  8     14  0
     d  wseq#                 15     19  0
     d  witm#                 20     34
     d  wseqq#                35     37  0
     D*----------------------------------------------------------------
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LCODE                22     27
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERFLD                  1     30
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  PIRTRAN record layout for use as parameters
     D*
     D PTPARM        E DS                  EXTNAME(PIRTRAN)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
     d* work fields ---------------------------------------------------
     d $ptrn#          s              7  0
     d $time           s              6  0
     d $rtncd          s             10
     d dsplyd          s              2  0
     d w3item          s             15
     d w3qrmn          s              5  0
     d w3scan          s              5  0
     d lbordin         s                   like(pcord)
     d lbseqin         s                   like(pcseq#)
     d lbitmin         s                   like(lbitem)
     d lbtrn#in        s                   like(lbtrn#)
     d goback          s              2  0
     I*----------------------------------------------------------------
     C*  Main line
     C*
     c*
     c*  Entry from call
     c     *entry        plist
     c                   parm                    lbordin
     c                   parm                    lbseqin
     c                   parm                    lbitmin
     c                   parm                    lbtrn#in
     c                   parm                    portn             8
     c*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     c                   exsr      scr01i
     C                   DOW       NXTSCR <> 'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     c                   eval      *inlr = *on
     c                   return
     C*
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     C                   IF        error = *ON
     C                   eval      *in98=*on
     c                   else
     C*
     C*   Initialize error indicators and fields
     C*
     C                   SETOFF                                       212223
     C                   SETOFF                                       249002
     C                   move      *off          cmdtkn            1
     C                   move      *OFF          WARN              1
     C                   MOVE      *OFF          ERROR             1
     C                   ENDIF
     C*
     C*  Overlay screen with screen to be processed.
     C*
     C*
     C                   SELECT
     C                   when      nxtscr = '01 '
     c                   if        recno = 0
     c                   eval      nxtscr = 'EOJ'
     c                   eval      portn = '*NOGOOD'
     c                   else
     c                   exsr      sfldsp
     C*                  EXSR      ZMDMSG
     c                   write     cmdline
     C*
     C                   read      cwectl                                 50
     c                   z-add     status        hld_status        5 0
     C*
     C*   Initialize error subfile
     C*
     C*                  EXSR      ZMCMSG
     c                   endif
     C                   ENDSL
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   MOVE      '*REFRESH'    PAGCMD
     c                   eval      wtran# = lbtrn#in
     c                   eval      word# = lbordin
     c                   eval      wseq# = lbseqin
     c                   eval      witm# = lbitmin
     c                   eval      wseqq# = 1
     c                   eval      wtran = lbtrn#in
     c                   eval      word = lbordin
     c                   eval      wseq = lbseqin
     c                   eval      witm = lbitmin
     c                   eval      wseqq = 1
     C                   EXSR      PAG01
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ROLL01   Screen 1 roll up/down routine
     C*
     CSR   roll01        begsr
     c*
     c                   if        word<>lbordin or wtran<>lbtrn#in
     c                             or wseq<>lbseqin or witm<>lbitmin
     c                   eval      wtran = lbtrn#in
     c                   eval      word = lbordin
     c                   eval      wseq = lbseqin
     c                   eval      witm = lbitmin
     c                   eval      wseqq = 1
     c                   eval      wtran# = lbtrn#in
     c                   eval      word# = lbordin
     c                   eval      wseq# = lbseqin
     c                   eval      witm# = lbitmin
     c                   eval      wseqq# = 1
     c                   endif
     C*
     C*  TEST FOR ROLLUP
     C*
     C                   if        hld_status = rollup
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT'
     c     fileky        setgt     record
     C                   exsr      pag01
     C                   goto      rol01e
     C                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     C                   if        hld_status = rolldn
     c     1             chain     cwesfl                             65
     c  n65lbtrn#in      chain     pakercw2                           65
     c                   if        *in65 = *off
     c                   eval      wtran = pctran
     c                   eval      word = lbordin
     c                   eval      wseq = lbseqin
     c                   eval      witm = lbitmin
     c                   eval      wseqq = w1seq-1
     c                   if        wseqq = 0
     c                   eval      pagcmd = '*TOP'
     c                   goto      rol01e
     c                   endif
     c                   eval      wtran# = pctran
     c                   eval      word# = lbordin
     c                   eval      wseq# = lbseqin
     c                   eval      witm# = lbitmin
     c                   eval      wseqq# = w1seq-1
     c     fileky        setll     record
     c                   endif
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag01
     c                   goto      rol01e
     C                   end
     C     rol01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG01    Screen 1 page routines
     C*
     C     pag01         begsr
     C*
     C*  NEXT PAGE
     C*
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  PREVIOUS PAGE
     C*
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag1bk
     C                   else
     C*
     C*  TOP
     C*
     C                   if        pagcmd = '*TOP'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  BOTTOM
     C*
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     C*
     C*  REFRESH SCREEN
     C*
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     c                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   end
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  REPOSITIONING
     C*
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag1fw
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   move      *blanks       pagcmd            8
     C     pag01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1FW   Let's see that next page of records
     C*
     C     pag1fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     C     bot           cabeq     '1'           endf
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     C                   exsr      sflclr
     c                   if        pagcmd<>'*TOP'
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
     c                   endif
     C                   move      '0'           bot               1
     C                   move      '0'           top               1
     C                   move      '0'           stop              1
     C                   z-add     0             p                 2 0
     C*
     C*  GET 8 RECORDS TO DISPLAY
     C*
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      bot = '1'
     C                   move      'Bottom '     MORELN            7
     C                   goto      endfwd
     C                   end
     C*
     C*  RECORD READ - STOP AFTER 3 GOOD RECORDS
     C*
     C                   eval      p = p+1
     C                   exsr      sfladd
     C                   if        p = 3
     C                   eval      stop = '1'
     C                   if        forceb = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   end
     C                   end
     C     endfwd        tag
     C                   end
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     C                   z-add     p             dsplyd            2 0
     C                   eval      forceb = '0'
     C     endf          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
     C*
     C     pag1bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb            1
     c                   eval      goback = p + 3
     c*  if eof reached in previous roll function reset pointer
     c*
     c     fileky        setgt     record
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     C                   eval      p = 0
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      stop = '0'
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C*
     C*  HIT TOP OF FILE
     C*
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      top = '1'
     C                   goto      endbk
     C                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     C                   eval      p = p+1
     C                   if        p>goback
     C                   eval      stop = '1'
     C                   end
     C     endbk         tag
     C                   end
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     C                   if        top = '1'
     C                   eval      $POCMD = '*TOP'
     C                   exsr      fgtway
     C                   end
     C                   exsr      pag1fw
     C     endb          endsr
     C*----------------------------------------------------------------
     C*
     C*  FGTWAY   Gateway to file handling routines
     C*
     C*    Input Parameters
     C*      $POCMD   *INIT    - Initialize and return
     C*               *GET     - Get record for $POUKY value
     C*               *GETNEXT - Get next record
     C*               *GETPREV - Get previous record
     C*               *WRITPOS - Write position record to display
     C*               *READPOS - Read position record
     C*               *POSTN2  - Position to $POFKY
     C*               *POSTN2U - Position to $POUKY
     C*               *TOP     - Position to top of file
     C*               *BOTTOM  - Position to bottom of file
     C*      $POFKY   Key for positioning within file
     C*      $POUKY   Unique key used for change/delete operations
     C*
     C*    Returned Parameters
     C*      $PORTN   *NOMORE  - Beginning/End of file was reached
     C*               *NOTFND  - Record not found on a GET
     C*               *FOUND   - Record found
     C*               *REPOS   - Repositioning took place
     C*               *ERROR   - Error occured
     C*      $POERM   Error message
     C*
     CSR   FGTWAY        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $POCMD        CASEQ     '*GETPREV'    fgetp
     C     $POCMD        CASEQ     '*POSTN2'     fpos1
     C     $POCMD        CASEQ     '*POSTN2U'    fpos1u
     C     $POCMD        CASEQ     '*TOP'        zzpos1
     C     $POCMD        CASEQ     '*BOTTOM'     zzpos1
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     c     zzkeyf        begsr
     c                   eval      $pofky = dsfkey
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYI   Initialize keys for files being used.
     C*           Note: You must clear individual field when using
     C*                 partial keys or one of the fields is numeric.
     C*
     C     zzkeyi        begsr
     C*
     C*   Initialize unique key (DSUKEY)
     C*
     c                   eval      word# = pcord
     c                   eval      wseq# = pcseq#
     c                   eval      witm# = pcitem
     c                   eval      wseqq# = pccseq
     c*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     C     zzkeyu        begsr
     C                   eval      word# = pcord
     C                   eval      wseq# = pcseq#
     c                   eval      witm# = pcitem
     c                   eval      wseqq# = pccseq
     C                   eval      $pouky = DSUKEY
     c*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     C     zzfget        begsr
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   Get previous record
     C*
     C     zzfgtp        begsr
     C     try2          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C     fileky        setll     record
     C                   readp     record                                 79
     c                   if        *in79 = *off and (pctran<>lbtrn#in
     c                              or pcord<>lbordin or pcitem<>lbitmin)
     c                   eval      *in79 = *on
     c                   endif
     C*
     C     endgtp        endsr
     C*
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are DIFFERENT.
     C*
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETN    Get next record
     C*
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETP    Get previous record
     C*
     C     fgetp         begsr
     C                   exsr      zzfgtp
     c                   if        *in79 = *on or pctran<>lbtrn#in
     c     fileky        setll     record
     c                   read      record                                 79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS1    Position to record
     C*
     C     fpos1         begsr
     C                   eval      dsfkey = $POFKY
     C     fileky        setll     record
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS1U   Position to record using unique key
     C*
     C     fpos1u        begsr
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     C                   exsr      fget
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     C                   exsr      fpos1
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     C     SC1           BEGSR
     C*
     c                   exsr      zzcmd1
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     C     hld_status    caseq     rollup        roll01
     C     hld_status    caseq     rolldn        roll01
     C                   cas                     ent01
     C                   end
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   Screen 1 command key routine
     C*
     C     ZZCMD1        begsr
     C*
     C*  TEST FOR F3 - EXIT
     C*
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT'
     C                   goto      cmd01e
     C                   end
     C*
     C*  TEST FOR F12 - PREVIOUS
     C*
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL'
     C                   goto      cmd01e
     C                   end
     C*
     C     error         cabeq     '1'           cmd01e
     c*
     C     cmd01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT01    Screen 1 enter key routine
     C*
     C     ent01         begsr
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     c                   if        not *inkc and not *inkl
     c     error         CABEQ     '1'           ent01e
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     C                   move      '0'           repos             1
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = DSFKEY
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      FGTWAY
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   end
     C                   endif
     c*
     C     ent01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     C     zzfgtn        begsr
     C     try1          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   read      record                                 79
     c                   if        *in79 = *off and (pctran<>lbtrn#in
     c                              or pcord<>lbordin or pcitem<>lbitmin)
     c                   eval      *in79 = *on
     c                   endif
     C*
     C     endgtn        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS1   Position to record
     C*
     C     zzpos1        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   if        $pocmd = '*TOP'
     C     fileky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     fileky        setll     record
     C                   end
     C                   end
     C                   endsr
      *
     c     zzpos         begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Initialize special keys
     C*
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
     c                   move      '1'           first             1
     C*
     C*  Initialize message handling
     C*
     C*                  EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      *OFF          *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     CSR   ZMDMSG        BEGSR
     CSR                 MOVE      *ON           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 END
     CSR                 ENDSR
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     CSR   ZMPMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM                    #PGMQ
     CSR                 PARM                    #MSGK
     CSR   #MSGID        IFNE      '*CLEAR '
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 END
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     CSR   ZSCLR         BEGSR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     CSR   ZM71          BEGSR
     CSR                 MOVE      'PIR7971'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     CSR   ZM72          BEGSR
     CSR                 MOVE      'PIR7972'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0106  Invalid cursor position.
     C*
     C     zm0106        begsr
     C                   move      'PIR0106'     #msgid
     C                   move      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   exsr      ZMPMSG
     C                   endsr
     C*----------------------------------------------------------------
     C*      0110  Number must be > 0
     C*
     CSR   ZM0110        BEGSR
     CSR                 MOVE      'PIR0110'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1060  Pallet already scanned
     C*
     CSR   ZM1060        BEGSR
     CSR                 MOVE      'PIR1060'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     C*R                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR0203  Value cannot be blank
     C*
     C     ZM0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      ZMPMSG
     C                   endsr
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0101  Program not found.
     C*
     C     zm0101        begsr
     C                   move      'PIR0101'     #MSGID
     C                   move      '*DIAG  '     #MSGTP
     C                   movea     ERRMSG        $MD(1)
     C                   exsr      ZMPMSG
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 2 error checking.
     C*
     c     zzchk1        begsr
     c*
     C     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
     c*
     c                   eval      w1bfcl = lblbl#
     c                   eval      w1item = itdesc
     c                   eval      w1seq = pccseq
     c                   eval      w1cwgt = pccwgt
     c                   eval      w1pplb = pclbl#
     c*
     C     endfl1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile
     C*
     C     sfldsp        begsr
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     C                   eval      *in01 = '1'
     C                   eval      recno = 1
     C                   write     cwectl
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   Add record to subfile
     C*
     C     sfladd        begsr
     c*
     c     labkey        setll     label7
     c     labkey        reade     label7                                 79
     c*
     c*  only display in subfile if selected transaction, catch weight item,
     c*   and open quantity remaining
     c*
     c                   if        lbtrn# = pctran and lbseq = pcseq#
     c                   eval      recno = recno +1
     C                   z-add     recno         y                 4 0
     C*
     C*  SAVE FILE AND UNIQUE KEYS
     C*
     c                   if        wtran=lbtrn#in and witm=lbitmin
     c                             and word = lbordin and wseq=lbseqin
     C                   eval      fkey(y) = $POFKY
     C                   eval      ukey(y) = $POUKY
     c                   endif
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     C                   exsr      zzfil1
     C                   write     cwesfl
     c                   endif
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   Clear display subfile
     C*
     C     SFLCLR        begsr
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     C                   eval      *IN01 = '0'
     C                   write     cwectl
     C                   z-add     0             recno             4 0
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Initialization.  Called from Mainline
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      *OFF          FOREVR            1
     c                   eval      nxtscr = '01'
     c                   eval      *in02 = *on
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
     C                   Z-ADD     #WHSE         @pwhse            3 0
     C*
     C*   Get screen size being used.
     C*
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #LCMD             8
     C                   parm                    #LLINE            2 0
     C                   parm                    #LCOL             3
     *
     *  Define keys used in program.
     *
     C*
     C*  Define unique file key.
     C*
     C     filuky        klist
     C                   kfld                    wtran#
     C                   kfld                    word#
     C                   kfld                    wseq#
     c                   kfld                    witm#
     c                   kfld                    wseqq#
     C*
     C*  Define full key for main file.
     C*
     C     fileky        klist
     c                   kfld                    wtran#
     C                   kfld                    word#
     C                   kfld                    wseq#
     c                   kfld                    witm#
     c                   kfld                    wseqq#
     C*
     c     labkey        klist
     c                   kfld                    pctran
     c                   kfld                    pcitem
     c                   kfld                    pcseq#
     c*
     C                   ENDSR
     O*  COMPILE TIME TABLES
     O*
**
