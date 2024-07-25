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
     F*  CE120     Catch Weight Entry Display
     F*  21 August 2004
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
     FCE120FM   CF   e             WORKSTN
     F                                     INFDS(infds)
     F                                     sfile(cwesfl:recno)
     F                                     SFILE(msgrec:msgk)
     Fpiruser1  if   e           K disk
     Fpirtran   if   e           k disk
     flabel7    if   e           k disk
     f                                     rename(l7rec:record)
     fpakerlb   if   e           k disk
     fpakercw   uf a e           k disk
     fpakercw1  if   e           k disk
     f                                     rename(pcrec:pcrec1)
     fordc1     uf a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(10) CTDATA PERRCD(1)
     d fkey            s             50    dim(14)
     d ukey            s             50    dim(14)
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     d @ADJTRN         C                   CONST('ADJTRAN2')
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
     d  wblbl#                 1      7  0
     d*
     d dsukey          ds
     d  uklbl#                 1      7  0
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
     I*----------------------------------------------------------------
     C*  Main line
     C*
      *
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     C                   DOW       NXTSCR <> 'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C     NXTSCR        CASEQ     '03 '         SC3
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
     c     repeat        tag
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   EXSR      ZMDMSG
     C                   EXFMT     cwentry                              50
     c                   eval      first = '0'
     C                   EXSR      ZMCMSG
     C*
     C                   when      nxtscr = '03 '
     C                   EXSR      ZMDMSG
     C                   EXFMT     Spakerlb                             50
     c                   eval      first = '0'
     C                   EXSR      ZMCMSG
     C*
     C                   when      nxtscr = '02 '
     c                   exsr      sfldsp
     c                   if        nxtscr<>'01 '
     C                   EXSR      ZMDMSG
     c                   write     cwcmdline
     C*
     C                   read      cwectl                                 50
     c                   else
     c                   eval      nxtscr = '01 '
     c                   goto      repeat
     c                   endif
     C*
     C*   Initialize error subfile
     C*
     C                   EXSR      ZMCMSG
     C                   ENDSL
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     C     SCR01I        BEGSR
     C                   MOVE      '01 '         NXTSCR            3
     C                   EXSR      ZZFIL1
     C                   MOVE      *OFF          REFRSH            1
     C     END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     C     SCR03I        BEGSR
     C                   MOVE      '03 '         NXTSCR            3
     C                   EXSR      ZZFIL3
     C                   MOVE      *OFF          REFRSH            1
     C     END03I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     C     SCR02I        BEGSR
     C                   MOVE      '02 '         NXTSCR            3
     c                   eval      wblbl# = w1tran
     C                   MOVE      '*REFRESH'    PAGCMD
     C                   EXSR      PAG02
     C     END02I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C                   IF        *inkc = *ON or *inkl = *on
     C                   MOVE      'EOJ'         NXTSCR
     C*
     c                   exsr      srIdle
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     c*
     c*  create transaction in PIRTRAN to track time
     c*
     c                   call      @ADJTRN
     c                   parm      '*CRTSTRT'    @pcmd            10
     c                   parm                    #job
     c                   parm      '*INTER'      @ptype            8
     c                   parm      *zeros        @ptrn#            7 0
     c                   parm      'CWENTRY'     @ptask            6
     c                   parm                    @pwhse            3 0
     c                   parm      *blanks       @pwhdp            5
     c                   parm      *blanks       @pstyp            1
     c                   parm      *zeros        @pcube            9 3
     c                   parm      *zeros        @pswgt            9 2
     c                   parm      *zeros        @ppcs             5 0
     c                   parm      *zeros        @paisl            5 0
     c                   parm      *zeros        @pqty1            5 0
     c                   parm      *zeros        @pqty2            5 0
     c                   parm      *zeros        @pqty3            5 0
     c                   parm      *blanks       @prte             5
     c                   parm      *blanks       @ppo              9
     c                   parm      'S'           @pgrp1            1
     c                   parm      'S'           @pgrp2            1
     c                   parm      *zeros        @pdate            8 0
     c                   parm      *zeros        @ptime            6 0
     c                   parm      uscode        @puser           10
     c                   parm      *blanks       @prtn             8
     c                   parm      *blanks       @pmsg             4
     c                   z-add     @ptrn#        hldPtrn#          7 0
     c                   exsr      scr02i
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC3  -  Screen 3
     C*
     C     SC3           BEGSR
     C*
     C*  Test for F12 - Cancel
     C*
     C                   IF        *inkl = *on or *inkt = *on
     C                   MOVE      '02 '         NXTSCR
     C*
     C                   GOTO      ENDSC3
     C                   ENDIF
     C*
     C*  Test for other command key2 BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK3
     C     ERROR         CABEQ     *ON           ENDSC3
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD3
     C     CMDTKN        CABEQ     *ON           ENDSC3
     C     ERROR         CABEQ     *ON           ENDSC3
     c                   exsr      zzupd3
     c                   eval      w3lbl# = ' '
     c*                  exsr      scr03i
     C*
     C     ENDSC3        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ROLL03   Screen 3 roll up/down routine
     C*
     CSR   roll02        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     C                   if        status = rollup
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*NEXT'
     C                   exsr      pag02
     C                   goto      rol02e
     C                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     C                   if        status = rolldn
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag02
     c                   goto      rol02e
     C                   end
     C     rol02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG02    Screen 2 page routines
     C*
     C     pag02         begsr
     C*
     C*  NEXT PAGE
     C*
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag2fw
     C                   else
     C*
     C*  PREVIOUS PAGE
     C*
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag2bk
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
     C                   exsr      pag2fw
     C                   else
     C*
     C*  BOTTOM
     C*
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag2bk
     C                   else
     C*
     C*  REFRESH SCREEN
     C*
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     c                               or nxtscr = '02'
     c                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   end
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag2fw
     C                   else
     C*
     C*  REPOSITIONING
     C*
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag2fw
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   move      *blanks       pagcmd            8
     C     pag02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG2FW   Let's see that next page of records
     C*
     C     pag2fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     C     bot           cabeq     '1'           endf
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     C                   exsr      sflclr
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
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
     C*  PAG2BK   Let's see the previous page
     C*
     C     pag2bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     C                   select
     C                   when      #lline<>16
     C     dsplyd        add       3             goback            2 0
     C                   other
     C     dsplyd        add       14            goback
     C                   endsl
     C                   if        bot = '1'
     C                   if        goback = 3
     C                             and #lline<>16
     C                             or goback=14
     C                             and #lline<>16
     C                   eval      forceb = '1'
     C                   end
     C                   eval      $pocmd = '*BOTTOM'
     C                   exsr      fgtway
     C                   eval      goback = goback +1
     C                   end
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
     C                   exsr      pag2fw
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
     C     $POCMD        CASEQ     '*POSTN2'     fpos2
     C     $POCMD        CASEQ     '*POSTN2U'    fpos2u
     C     $POCMD        CASEQ     '*TOP'        zzpos2
     C     $POCMD        CASEQ     '*BOTTOM'     zzpos2
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
     C                   eval      UKLBL# = lblbl#
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     C     zzkeyu        begsr
     C                   eval      uklbl# = lbLBL#
     C                   eval      $pouky = DSUKEY
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
     C                   readp     record                                 79
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
     C                   if        *in79  = '1'
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
     C*  FPOS2    Position to record
     C*
     C     fpos2         begsr
     C                   eval      dsfkey = $POFKY
     C     fileky        setll     record
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS2U   Position to record using unique key
     C*
     C     fpos2u        begsr
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     C                   exsr      fget
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     C                   exsr      fpos2
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SC2     Screen 2
     C*
     C     SC2           BEGSR
     C*
     c                   exsr      zzcmd2
     c                   if        nxtscr<>'01'
     c                   exsr      zzchk2
     c     error         cabeq     *on           endsc2
     c                   if        optionsel = 'N' and w2scnl=0
     c                   exsr      scr02i
     c                   endif
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C                   cas                     ent02
     C                   end
     c                   endif
     C*
     C     ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   Screen 1 command key routine
     C*
     C     ZZCMD2        begsr
     C*
     C*  TEST FOR F3 - EXIT
     C*
     C                   if        *inkc
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*EXIT'
     C                   goto      cmd02e
     C                   end
     C*
     C*  TEST FOR F12 - PREVIOUS
     C*
     C                   if        *inkl
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*CANCEL'
     C                   goto      cmd02e
     C                   end
     C*
     C     error         cabeq     '1'           cmd02e
     c*
     C     cmd02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT02    Screen 1 enter key routine
     C*
     C     ent02         begsr
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     c                   if        not *inkc and not *inkl
     c*
     c*  display screen three for valid label or option 1 on given line
     c*
     c                   z-add     *zeros        w2hlbl            7 0
     c                   z-add     1             sub2              3 0
     c     sub2          chain     cwesfl                             79
     c                   dow       sub2<4
     c                   if        w2scnl<>*zeros and w2scnl = w2lbl#
     c                               or (w2opt='1 ' or w2opt=' 1'
     c                                    or w2opt='01')
     c                   if        w2scnl<>*zeros and w2scnl = w2lbl#
     c                   eval      w2hlbl = w2scnl
     c                   else
     c                   eval      w2hlbl = w2lbl#
     c                   endif
     c                   exsr      scr03i
     c                   eval      w2scnl = *zeros
     c                   eval      w2opt = *blanks
     c  n79              update    cwesfl
     c                   endif
     c                   eval      sub2 = sub2 + 1
     c     sub2          chain     cwesfl                             79
     c                   enddo
     c                   endif
     c*
     C     ent02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     C     zzfgtn        begsr
     C     try1          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   READ      record                                 79
     C*
     C     endgtn        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     C     zzpos2        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   if        $pocmd = '*TOP'
     C     w1tran        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     w1tran        setll     record
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
     C                   EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     c*---------------------------------------------------------------
     c*  SUBROUTINE - srIdle - Create idle transaction when employee
     c*                exits from catch weight entry
     c*---------------------------------------------------------------
     c     srIdle        begsr
     c*
     c*
     c*  create an idle transaction once employee comes off particular load
     c*
     c                   call      @ADJTRN
     c                   parm      '*CRTSTRT'    @pcmd            10
     c                   parm                    #job
     c                   parm      '*INTER'      @ptype            8
     c                   parm      *zeros        @ptrn#            7 0
     c                   parm      'IDLE '       @ptask            6
     c                   parm                    @pwhse            3 0
     c                   parm      *blanks       @pwhdp            5
     c                   parm      *blanks       @pstyp            1
     c                   parm      *zeros        @pcube            9 3
     c                   parm      *zeros        @pswgt            9 2
     c                   parm      *zeros        @ppcs             5 0
     c                   parm      *zeros        @paisl            5 0
     c                   parm      *zeros        @pqty1            5 0
     c                   parm      *zeros        @pqty2            5 0
     c                   parm      *zeros        @pqty3            5 0
     c                   parm      *blanks       @prte             5
     c                   parm      *blanks       @ppo              9
     c                   parm      'S'           @pgrp1            1
     c                   parm      'S'           @pgrp2            1
     c                   parm      *zeros        @pdate            8 0
     c                   parm      *zeros        @ptime            6 0
     c                   parm      uscode        @puser           10
     c                   parm      *blanks       @prtn             8
     c                   parm      *blanks       @pmsg             4
     c*
     c                   endsr
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
     C*  ZZCHK1   Screen 1 error checking.
     C*
     C     zzchk1        BEGSR
     C                   MOVE      *OFF          ERROR
     C*
     c*  Verify Transaction Scanned
     C*
     C     w1tran        chain     pirtran                            79
     C                   if        *in79 = *on
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     c*
     c*  do not allow status 4 transactions
     c*
     c                   if        *in79 = *off and ptstat='4'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
     c                   endif
     C*
     C     endck1        tag
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     c     zzchk2        begsr
     c*
     C                   MOVE      *On           ERROR
     C*
     c*  Verify that scanned label exist in subfile
     C*
     C                   if        w2scnl<>0
     c                   z-add     1             sub2              3 0
     c     sub2          chain     cwesfl                             79
     c                   dow       sub2<4 and w2item<>*blanks
     c                               and error = *on
     c                   if        *in79 = *off and w2scnl = w2lbl#
     c                   eval      error = *off
     c                   endif
     c                   eval      sub2 = sub2 + 1
     c     sub2          chain     cwesfl                             79
     c                   enddo
     C                   if        error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   goto      endck2
     C                   endif
     C                   endif
     c*
     c*  Verify that option field is valid
     c*
     c                   movel     'N'           optionsel         1
     c                   eval      error = *off
     c                   z-add     1             sub2              3 0
     c     sub2          chain     cwesfl                             79
     c                   dow       sub2<4
     c                   if        w2opt<>*blanks and w2opt<>'1 ' and
     c                               w2opt<>'01' and w2opt<>'1'
     c                   eval      error = *on
     c                   else
     c*  set indicator to know at least one option was selected
     c                   if        w2opt<>*blanks
     c                   eval      optionsel = 'Y'
     c                   endif
     c                   endif
     c                   eval      sub2 = sub2 + 1
     c     sub2          chain     cwesfl                             79
     c                   enddo
     C                   if        error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     C                   goto      endck2
     c                   else
     c                   if        optionsel = 'N' and w2scnl=0
     c                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(8)
     C                   exsr      zm1001
     C                   goto      endck2
     c                   endif
     C                   endif
     C     endck2        endsr
     C*----------------------------------------------------------------
     C*
     c*    zzchk3 - Check for valid entry on screen three
     C*
     c     zzchk3        begsr
     c*
     C                   MOVE      *Off          ERROR
     c*
     c*  Verify that label entered is found in pakerlb
     c*
     c     w3lbl#        chain     paKerlb                            79
     C                   if        *in79 = *on or plitem<>w3item
     C                   eval      *in24 = *on
     c                   eval      error = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm1001
     C                   goto      endck3
     C                   endif
     c*
     c*  Verify that label has not already been scanned
     c*
     c     plblky        chain     paKercw1                           79
     C                   if        *in79 = *off
     C                   eval      *in24 = *on
     c                   eval      error = *on
     C                   eval      errmsg = desc(7)
     C                   exsr      zm1001
     C                   goto      endck3
     C                   endif
     c*
     c*  Verify that quantity scanned does not exceed quantity on order
     c*
     c                   if        w3scan >= w3qrmn
     C                   eval      *in24 = *on
     c                   eval      error = *on
     C                   eval      errmsg = desc(9)
     C                   exsr      zm1001
     C                   goto      endck3
     C                   endif
     c*
     C     endck3        endsr
     c*----------------------------------------------------------------
     c*
     c*    zzupd3 - Update screen three - Write record to PAKERCW
     c*
     c     zzupd3        begsr
     c*
     c                   eval      w3scan = w3scan + 1
     c*
     c                   eval      pcord = lbord
     c                   eval      pcseq# = lbseq
     c                   eval      pcitem = w3item
     c                   eval      pccseq = w3scan
     c                   eval      pccwgt = plcwgt
     c                   eval      pctran = w1tran
     c                   eval      pclbl# = w3lbl#
     c                   write     pcrec
     c*
     c                   eval      ocwhse = lbwhse
     c                   eval      ocord = lbord
     c                   eval      ocseq# = lbseq
     c                   eval      ocseq = w3scan
     c                   eval      ocitem = w3item
     c                   eval      occwgt = plcwgt
     c                   eval      octran = w1tran
     c                   eval      oclbl# = w2hlbl
     c                   write     ocrec
     c*
     c                   endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     CSR                 SELECT
     C*
     CSR                 OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 GOTO      ENDCM1
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD3   User defined command keys for screen 3.
     C*
     CSR   ZZCMD3        BEGSR
     C*
     C                   if        *inkl = *on or *inkq = *on or *inku = *on
     c                   eval      cmdtkn = *on
     c*
     c*  command 12 previous screen
     c                   if        *inkl = *on
     c                   eval      nxtscr = '02'
     c                   goto      endcm3
     c                   endif
     c*
     c*  command 16 Catch Weight Detail Display
     c                   if        *inkq = *on
     c                   eval      $portn = '*NORMAL'
     c                   call      'CE190'
     c                   parm                    lbord
     c                   parm                    lbseq
     c                   parm                    w3item
     c                   parm                    w1tran
     c                   parm                    $portn
     c*
     c*  Verify that label had catch weight entries to display
     c*
     C                   if        $portn = '*NOGOOD'
     C                   eval      *in24 = *on
     c                   eval      error = *on
     C                   eval      errmsg = desc(10)
     C                   exsr      zm1001
     C                   goto      endcm3
     C                   endif
     c                   endif
     c*
     c*  command 20 Complete
     c                   if        *inku = *on
     c                   eval      nxtscr = '02'
     c                   endif
     c*
     c                   endif
     C*
     C     ENDCM3        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  zzfIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     CSR                 eval      w1tran = *zeros
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  zzfIL3   Fill screen 3 fields with info from file.
     C*
     C     ZZFIL3        BEGSR
     C*
     C                   eval      w3item = w2item
     c                   eval      w3qrmn = w2qrmn
     c                   eval      w3lbl# = *blanks
     c*
     c     labkey        setgt     label7
     c                   readp     label7                                 77
     c                   eval      w3desc = itdesc
     c*  get last sequence scanned from ordc
     c     ordkey        setgt     ordc1
     c                   readp     ordc1                                  77
     c                   if        *in77 = *off and oclbl# = lblbl#
     c                   eval      w3scan = ocseq
     c                   else
     c                   eval      w3scan = 0
     c                   endif
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     c     zzfil2        begsr
     c*
     c                   eval      w2item = lbitem
     c                   eval      w2desc = itdesc
     c                   eval      w2qrmn = lbqpck
     c                   eval      w2lbl# = lblbl#
     c*
     C     endfl2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile
     C*
     C     sfldsp        begsr
     C*
     C*  INVALID IF NO SUBFILE RECORDS LOADED
     C*
     C                   if        recno = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(3)
     c                   eval      nxtscr='01 '
     C                   exsr      zm1001
     c                   else
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     C                   if        error<>'1'
     C     1             chain     cwesfl                             79
     C                   if        *in79 = '*off'
     c                   eval      *in20 = '1'
     C                   update    cwesfl
     C                   end
     C                   end
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     C                   eval      *in01 = '1'
     C                   eval      recno = 1
     C                   write     cwectl
     c                   endif
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   Add record to subfile
     C*
     C     sfladd        begsr
     c*
     c*  only display in subfile if selected transaction, catch weight item,
     c*   and open quantity remaining
     c*
     c                   if        lbtrn# = w1tran and itcwgt='Y'
     c                               and lbqpck<>0
     c                   eval      recno = recno +1
     c                   eval      recnox = recno
     C                   z-add     recno         y                 4 0
     C*
     C*  SAVE FILE AND UNIQUE KEYS
     C*
     C                   eval      fkey(y) = $POFKY
     C                   eval      ukey(y) = $POUKY
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     C                   exsr      zzfil2
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
     C                   Z-ADD     #WHSE         @pwhse
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
     C                   kfld                    uklbl#
     C*
     C*  Define full key for main file.
     C*
     C     fileky        klist
     C                   kfld                    lblbl#
     C*
     c*  Define key to get last sequence number assigned per the label
     c     ordkey        klist
     c                   kfld                    lbwhse
     c                   kfld                    lblbl#
     c*
     c     labkey        klist
     c                   kfld                    w1tran
     c                   kfld                    w3item
     c*
     c     plblky        klist
     c                   kfld                    w3lbl#
     c                   kfld                    lbord
     c                   kfld                    lbseq
     c                   kfld                    w3item
     c*
     C                   ENDSR
     O*  COMPILE TIME TABLES
     O*
**
Transaction.
Transaction.  Already at status 4.
Transaction.  No valid catch weight entries.
BFC Label. Not on screen.
Option.  Must be 1.
PP Label.  Not found in Pakerlb.
PP Label.  Already been scanned.
BFC Label.  Label or Option required.
PP Label.  Exceeds pick quantity.
Option.  No CW Entries Exists.
