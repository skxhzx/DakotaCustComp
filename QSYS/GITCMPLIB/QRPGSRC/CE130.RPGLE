     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CE130   UCI Catch Weight Entry Display
     *
     *  Created using CE120
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  10/17/07  JCJ  5.10
     *    Enh:  Created
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
     Fce130fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl3:recn2)
     F                                     sfile(msgrec:msgk)
     Fpiruser1  if   e           k disk
     Fpirtran   if   e           k disk
     Flabel7    if   e           k disk
     F                                     rename(l7rec:record)
     Flabel     if   e           k disk
     Fucicw     uf   e           k disk
     Fucicwc    if   e           k disk    rename(ucirec:ucirec4)
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D zopt2           s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D optl3           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     D cmdl3           s             79    dim(1) ctdata perrcd(1)
     D desc            s             50    dim(15) ctdata perrcd(1)
     D fkey            s             50    dim(14)
     D ukey            s             50    dim(14)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D status            *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @adjtrn         c                   const('ADJTRAN2')
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
     D  wblbl#                 1      7  0
     *
     D dsukey          ds
     D  uklbl#                 1      7  0
     *----------------------------------------------------------------
     D                 ds
     D  dslb10                 1     10
     D  dslb8                  2      9
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
     * Entry parms
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $plbl                 22     28  0
     D  $pqty                 29     33  0
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
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s              5
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     * Work Fields
     *
     D @pcube          s              9  3
     D @pswgt          s              9  2
     D @pdate          s              8  0
     D hldptrn#        s              7  0
     D $ptrn#          s              7  0
     D w2hlbl          s              7  0
     D @ptrn#          s              7  0
     D $time           s              6  0
     D @ptime          s              6  0
     D w3qrmn          s              5  0
     D w3scan          s              5  0
     D comand          s              5  0
     D enter           s              5  0
     D clear           s              5  0
     D help            s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D #emp#           s              5  0
     D @ppcs           s              5  0
     D @paisl          s              5  0
     D @pqty1          s              5  0
     D @pqty2          s              5  0
     D @pqty3          s              5  0
     D msgk            s              4  0
     D recno           s              4  0
     D recn2           s              4  0
     D y               s              4  0
     D #nhrs           s              3  1
     D sub2            s              3  0
     D #whse           s              3  0
     D @pwhse          s              3  0
     D dsplyd          s              2  0
     D goback          s              2  0
     D p               s              2  0
     D #lnam           s             20
     D w16item         s             16
     D w15itm          s             15
     D w3item          s             15
     D #fnam           s             15
     D $rtncd          s             10
     D $msgf           s             10
     D #pgmq           s             10
     D @puser          s             10
     D @pcmd           s             10
     D @ppo            s              9
     D #rtn            s              8
     D cmdchk          s              8
     D pagcmd          s              8
     D w8lbl#          s              8
     D #lcmd           s              8
     D @ptype          s              8
     D @prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D moreln          s              7
     D #shft           s              6
     D #crew           s              6
     D @ptask          s              6
     D #whdp           s              5
     D @pwhdp          s              5
     D @prte           s              5
     D @pmsg           s              4
     D nxtscr          s              3
     D #lcol           s              3
     D #lline          s              2
     D warn            s              1
     D cmdtkn          s              1
     D error           s              1
     D bot             s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D optionsel       s              1
     D refrsh          s              1
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D #init           s              1
     D #styp           s              1
     D @pstyp          s              1
     D @pgrp1          s              1
     D @pgrp2          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *Pick   -
     *              *Return -
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $PUKY   Contains first key selected.
     *      $PRTN   blank    - No problem encountered.
     *              *OK      - Unique key exists for *VERIFY
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *on
     C                   eval      error = *off
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   eval      first = '0'
     *
     *   Initialize error subfile
     *
     C                   when      nxtscr = '02 '
     C                   exsr      sfldsp
     *
     *   Initialize error subfile
     *
     C                   if        status <> rollup and
     C                             status <> rolldn
     C                   exsr      zmcmsg
     C                   endif
     *
     C                   when      nxtscr = '03 '
     *
     *   Overlay screen with title
     *
     C                   write     title3
     *
     *  Write option and command lines to display
     *
     C                   write     optrec3
     C                   write     cmdrec3
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl3                            79
     C                   if        *in79 = *off
     C                   eval      *in95 = *on
     C                   update    dspsfl3
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in91 = *on
     C                   eval      recn2 = 1
     C                   write     dspsfc3
     C                   read      dspsfc3                              50
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   eval      *in21 = *off
     C                   eval      *in22 = *off
     C                   eval      *in23 = *off
     C                   eval      *in24 = *off
     C                   eval      *in90 = *off
     C                   eval      *in02 = *off
     C                   eval      warn = *off
     C                   eval      cmdtkn = *off
     C                   eval      error = *off
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      wblbl# = w1tran
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     *
     *  INVALID IF NO SUBFILE RECORDS LOADED
     *
     C                   if        recno = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in01 = *on
     C                   eval      w2msg  = desc(3)
     C                   exsr      scr01i
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     c     scr03i        begsr
     c                   eval      nxtscr = '03 '
     c                   exsr      sflclr3

     c                   eval      w3qpck = w2qrmn
     c                   eval      w3ucnt = 0

     c     ucikyc        setll     ucicwc
     c                   dow       forevr = forevr
     C     ucikyc        reade     ucicwc
     c                   if        %eof(ucicwc)
     c                   leave
     c                   endif
     c                   exsr      zzfil3
     c                   enddo

     c                   exsr      zzget3

     c                   eval      refrsh = *off

     c     end03i        endsr
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
     C                   if        *inkc = *on or *inkl = *on
     C                   eval      nxtscr = 'EOJ'
     *
     C                   exsr      sridle
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  create transaction in PIRTRAN to track time
     *
     C                   call      @adjtrn
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*INTER'      @ptype
     C                   parm      *zeros        @ptrn#
     C                   parm      'CWENTRY'     @ptask
     C                   parm                    @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      *blanks       @pstyp
     C                   parm      *zeros        @pcube
     C                   parm      *zeros        @pswgt
     C                   parm      *zeros        @ppcs
     C                   parm      *zeros        @paisl
     C                   parm      *zeros        @pqty1
     C                   parm      *zeros        @pqty2
     C                   parm      *zeros        @pqty3
     C                   parm      *blanks       @prte
     C                   parm      *blanks       @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      'S'           @pgrp2
     C                   parm      *zeros        @pdate
     C                   parm      *zeros        @ptime
     C                   parm      uscode        @puser
     C                   parm      *blanks       @prtn
     C                   parm      *blanks       @pmsg
     C                   eval      hldptrn# = @ptrn#
     C                   exsr      scr02i
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2     Screen 2
     *
     C     sc2           begsr
     *
     C                   if        status <> rollup  and
     C                             status <> rolldn
     C                   exsr      zzcmd2
     C                   if        nxtscr <> '01'
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   if        optionsel = 'N' and w2scnl=0
     C                   exsr      scr02i
     C                   endif
     C                   endif
     C                   endif
     *
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C                   cas                     ent02
     C                   endcs
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F12 - Cancel
     *
     C                   if        *inkl = *on
     C                   eval      nxtscr = '02 '
     *
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Cancel
     *
     C                   if        *inkl = *on
     C                   eval      nxtscr = '02 '
     C                   goto      endsc3
     C                   endif
     *  Test for other command key2 BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*NEXT'
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag2bk
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
     C                   exsr      pag2fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     C                               or nxtscr = '02'
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag2fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
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
     C                   exsr      sfladd
     C                   if        p = 11
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
     *  PAG2BK   Let's see the previous page
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   select
     C                   when      #lline<>'16'
     C     dsplyd        add       3             goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   if        bot = '1'
     C                   if        goback = 3
     C                             and #lline<>'16'
     C                   eval      forceb = '1'
     C                   endif
     C                   eval      $pocmd = '*BOTTOM'
     C                   exsr      fgtway
     C                   eval      goback = goback +1
     C                   endif
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
     C                   if        lbtrn# = w1tran and
     C                             itcwgt = 'Y'    and
     C                             lbqpck <> *zeros
     C                   eval      p = p+1
     C                   endif
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
     C                   exsr      pag2fw
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
     C     $pocmd        caseq     '*POSTN2'     fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
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
     C                   eval      uklbl# = lblbl#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      uklbl# = lblbl#
     C                   eval      $pouky = dsukey
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
     C     w1tran        readpe    record                                 79
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
     C                   if        *in79  = '1'
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
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
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
     *  ZZCMD2   Screen 2 command key routine
     *
     C     zzcmd2        begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*EXIT'
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*CANCEL'
     C                   goto      cmd02e
     C                   endif
     *
     C     error         cabeq     '1'           cmd02e
     *
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   if        not *inkc and not *inkl
     C                   select
     *  Label scanned
     C                   when      optionsel = 'N' and w2scnl <> *zeros
     C                   eval      w2hlbl = w2scnl
     C                   eval      w2scnl = *zeros
     C                   exsr      scr03i
     C                   other
     *
     *  Label selected from screen
     *
     C                   eval      w2hlbl = *zeros
     C                   eval      sub2 = 1
     C     sub2          chain     dspsfl                             79
     C                   dow       sub2<4
     C                   if        w2opt='1 ' or w2opt=' 1'
     C                                        or w2opt='01'
     C                   eval      w2hlbl = w2lbl#
     C                   exsr      scr03i
     C                   eval      w2scnl = *zeros
     C                   eval      w2opt = *blanks
     C  n79              update    dspsfl
     C                   leave
     C                   endif

     C                   if        w2opt='2 ' or w2opt=' 2'
     C                                        or w2opt='02'
     C                   eval      w2hlbl = w2lbl#
     C                   eval      w2scnl = *zeros
     C                   eval      w2opt = *blanks
     C  n79              update    dspsfl
     C                   leave
     C                   endif

     C                   if        w2opt = '16'
     C                   eval      w2hlbl = w2lbl#
     C     w2hlbl        chain     label
     C                   eval      $portn = '*NORMAL'
     C                   call      'CE190'
     C                   parm                    lbord
     C                   parm                    lbseq
     C                   parm                    lbitem
     C                   parm                    lbtrn#
     C                   parm                    portn             8
     *
     *
     *  Verify that label had catch weight entries to display
     *
     C                   if        $portn = '*NOGOOD'
     C                   eval      *in24 = *on
     C                   eval      error = *on
     C                   eval      w2msg  = desc(10)
     C                   leave
     C                   endif
     C                   eval      w2opt = *blanks
     C                   eval      w2scnl = *zeros
     C  n79              update    dspsfl
     C                   endif
     C                   eval      sub2 = sub2 + 1
     C     sub2          chain     dspsfl                             79
     C                   enddo
     C                   endsl
     C                   endif
     *
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C     w1tran        reade     record                                 79
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
     C     w1tran        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     w1tran        setgt     record
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
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *  SUBROUTINE - srIdle - Create idle transaction when employee
     *                exits from catch weight entry
     *---------------------------------------------------------------
     C     sridle        begsr
     *
     *  create an idle transaction once employee comes off particular load
     *
     C                   call      @adjtrn
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*INTER'      @ptype
     C                   parm      *zeros        @ptrn#
     C                   parm      'IDLE '       @ptask
     C                   parm                    @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      *blanks       @pstyp
     C                   parm      *zeros        @pcube
     C                   parm      *zeros        @pswgt
     C                   parm      *zeros        @ppcs
     C                   parm      *zeros        @paisl
     C                   parm      *zeros        @pqty1
     C                   parm      *zeros        @pqty2
     C                   parm      *zeros        @pqty3
     C                   parm      *blanks       @prte
     C                   parm      *blanks       @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      'S'           @pgrp2
     C                   parm      *zeros        @pdate
     C                   parm      *zeros        @ptime
     C                   parm      uscode        @puser
     C                   parm      *blanks       @prtn
     C                   parm      *blanks       @pmsg
     *
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
     C                   eval      #msgdt = errmsg
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
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      #msgdt = errmsg
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
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      *in98 = *off
     C                   eval      error = *off
     C                   eval      w1msg = *blanks
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     c                   eval      w1msg = $lerm
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
510jMC                   eval      w1msg = desc(15)
     C                   endif
     C                   endif
     *
     *  Verify Transaction Scanned
     *
     C     w1tran        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      w1msg  = desc(1)
     C                   goto      endck1
     C                   endif
     *
     *  do not allow status 4 transactions
     *
     C                   if        %found(pirtran) and ptstat='4'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      w1msg  = desc(2)
     C                   endif
     *
     C     endck1        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     *
     C                   eval      optionsel = 'N'
     C                   eval      error     = *off
     C                   eval      sub2      = 1
     C                   eval      w15itm = *blanks
     *
     *  Verify that scanned label is for the pallet transaction being shipped
     *
     C                   if        w2scnl <> *zeros
     C     w2scnl        chain     label                              79
     C                   if        *in79 = *off and lbtrn# <> w1tran
     C                             or *in79 = *on
     *
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      w2msg  = desc(4)
     C                   endif
     c     itmkey        chain     piritem
     c                   if        Not %found(piritem)
     c                             or %found(piritem)
     c                             and itcwgt <> 'Y'
     C                   eval      error  = *on
     C                   eval      *in24  = *on
     C                   eval      w2msg  = desc(11)
     c                   endif
     C
     C                   eval      w2item  = lbitem
     C                   eval      w16item = lbitem
     C                   eval      w2qrmn  = lbqpck
     C
     C                   goto      endck2
     *
     C                   endif
     *
     *  Verify that option field is valid
     *
     C     sub2          chain     dspsfl                             79
     C                   dow       sub2<4
     C                   if        w2opt<>*blanks and w2opt<>'1 '
     C                                            and w2opt<>'01'
     C                                            and w2opt<>' 1'
     C                                            and w2opt<>'2 '
     C                                            and w2opt<>'02'
     C                                            and w2opt<>' 2'
     C                                            and w2opt<>'16'
     C                   eval      error = *on
     C                   else
     *  set indicator to know at least one option was selected
     C                   if        w2opt<>*blanks
     C                   eval      optionsel = 'Y'
     C                   leave
     C                   endif
     C                   endif
     C                   eval      sub2 = sub2 + 1
     C     sub2          chain     dspsfl                             79
     C                   enddo
     C                   if        error = *on
     C                   eval      *in24 = *on
     C                   eval      w2msg  = desc(5)
     C                   goto      endck2
     C                   else
     C                   if        optionsel = 'N' and w2scnl=0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      w2msg  = desc(8)
     C                   goto      endck2
     C                   endif
     C                   endif

     C                   if        error = *off
     C                   eval      w15itm = w2item
     C                   endif

     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *    zzchk3 - Check for valid entry on screen three
     *
     C     zzchk3        begsr
     *
     C                   eval      error = *off
     C                   eval      w3msg = *blanks

     c                   dow       forevr = forevr
     C                   readc     dspsfl3
     c                   if        %eof
     c                   leave
     c                   endif
     C                   if        w3opt <> *blanks and w3opt<>'1 '
     C                                              and w3opt<>'01'
     C                                              and w3opt<>' 1'
     C                                              and w3opt<>'X '
     C                                              and w3opt<>' X'
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   eval      w3msg = desc(6)
     C                   endif

     C                   if        w3opt = '1 ' or  w3opt = '01'
     C                                          or  w3opt = ' 1'
     C                   if        w3qpck <= w3ucnt
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   eval      w3msg = desc(9)
     C                   endif
     C                   endif

     C                   eval      *in95 = *on
     C                   update    dspsfl3

     C                   enddo
     *
     c     endck3        endsr
     *----------------------------------------------------------------
     *
     *    zzupd3 - Update screen three - Write record to PAKERCW
     *
     c     zzupd3        begsr
     *
     c                   dow       forevr = forevr
     C                   readc     dspsfl3
     c                   if        %eof
     c                   leave
     c                   endif

     c                   select
     c                   when      w3opt = '1 '
     c                             or w3opt = '01'
     c                             or w3opt = ' 1'

     c     uciky1        chain     ucicw
     c                   if        %found(ucicw)
     c                   if        ucipkt <> w3tran or ucilbl <> w3lbl#
     c                                              or ucists <> 'N'
     c                                              or ucipck <> 'Y'
     c                   eval      w3ucnt = w3ucnt + 1
     c                   endif
     c                   eval      ucipkt = w1tran
     c                   eval      ucilbl = w2lbl#
     c                   eval      ucists = 'N'
     c                   eval      ucipck = 'Y'
     c                   update    ucirec

     c                   eval      w3opt = '  '
     c                   eval      w3ists = ucists
     c                   eval      w3iwgt = uciwgt
     c                   eval      w3ipck = ucipck
     c                   eval      w3tran = ucipkt
     c                   eval      w3lbl# = ucilbl
     c                   update    dspsfl3
     c                   endif

     c                   when      w3opt = 'X '
     c                             or w3opt = ' X'

     c     uciky1        chain     ucicw
     c                   if        %found(ucicw)

     c                   if        ucipkt = w1tran and ucilbl = w2lbl#
     c                   if        w3ucnt > 0
     c                   eval      w3ucnt = w3ucnt - 1
     c                   endif
     c                   endif

     c                   eval      ucipkt = 0
     c                   eval      ucilbl = 0
     c                   eval      ucists = 'Y'
     c                   eval      ucipck = 'N'
     c                   update    ucirec

     c                   eval      w3opt = '  '
     c                   eval      w3ists = ucists
     c                   eval      w3iwgt = uciwgt
     c                   eval      w3ipck = ucipck
     c                   eval      w3tran = ucipkt
     c                   eval      w3lbl# = ucilbl
     c                   update    dspsfl3
     c                   endif

     c                   endsl

     c                   enddo
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     c     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     c                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     c                   if        *inkd
     c                   eval      cmdtkn = *on
     c                   z-add     0             row#
     c                   eval      row = rowin
     c                   z-add     0             col#
     c                   eval      col = colin
     c                   select
     *
     c                   other
     *
     *     Cursor not on a valid lookup field.
     *
     c                   eval      error = *on
     c                   exsr      zm9905
     c                   endsl
     c                   goto      endcm1
     c                   endif
     c                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     c                   if        cmdchk = '*AFTER  '
     *
     c                   endif
     *
     c     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     c     zzcmd3        begsr
     *
     c                   if        *inkc = *on or *inkh = *on
     c                                         or *inkl = *on
     c                   eval      cmdtkn = *on
     *
     *  command 3 exit screen
     c                   if        *inkc = *on
     c                   eval      nxtscr = 'EOJ'
     c                   goto      endcm3
     c                   endif
     *
     *  command 8 exit screen
     c                   if        *inkh = *on
     c                   select
     c                   when      w3qpck = w3ucnt
     c                   eval      nxtscr = 'EOJ'
     c                   goto      endcm3

     c                   when      w3qpck > w3ucnt
     c                   eval      w3msg = desc(12)

     c                   when      w3qpck < w3ucnt
     c                   eval      w3msg = desc(13)
     c                   endsl
     c                   endif
     *
     *  command 12 previous screen
     c                   if        *inkl = *on
     c                   eval      nxtscr = '02'
     c                   goto      endcm3
     c                   endif
     *
     c                   endif
     *
     c     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  zzfIL1   Fill screen 1 fields with info from file.
     *
     c     zzfil1        begsr
     *
     c                   eval      w1tran = *zeros
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2item = lbitem
     C                   eval      w2desc = itdesc
     C                   eval      w2qrmn = lbqpck
     C                   eval      w2lbl# = lblbl#
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  zzfIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3opt = '  '
     C                   eval      w3inbr = ucinbr
     C                   eval      w3ists = ucists
     C                   eval      w3iwgt = uciwgt
     C                   eval      w3ipck = ucipck
     C                   eval      w3tran = ucipkt
     C                   eval      w3lbl# = ucilbl
     C                   eval      recn2  = recn2 + 1
     C                   eval      *in91 = *on

     C                   write     dspsfl3

     C                   endsr
     *----------------------------------------------------------------
     *
     *  zzget3   get screen 3 uci count.
     *
     c     zzget3        begsr

     c                   eval      w3ucnt = 0

     c     ucikyc        setll     ucicwc
     c                   dow       forevr = forevr
     c     ucikyc        reade     ucicwc
     c                   if        %eof(ucicwc)
     c                   leave
     c                   endif

     c                   if        ucipkt = w3tran and ucilbl = w3lbl#
     c                                             and ucists = 'N'
     c                                             and ucipck = 'Y'
     c                   eval      w3ucnt = w3ucnt + 1
     c                   endif

     c                   enddo

     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *  Write option and command lines to display
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        *in79 = *off
     C                   eval      *in85 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   read      dspsfc                               50
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     *  only display in subfile if selected transaction, catch weight item,
     *   and open quantity remaining
     *
     C                   if        lbtrn# = w1tran and itcwgt='Y'
     C                               and lbqpck<>0
     C                   eval      p = p+1
     C                   eval      recno = recno +1
     C                   eval      recnox = recno
     C                   eval      y = recno
     C                   eval      *in81 = *on
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfil2
     C                   write     dspsfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  Clear display subfile
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   write     dspsfc
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR3  Clear display subfile
     *
     c     sflclr3       begsr
     *
     *  Clear display subfile
     *
     c                   eval      *in91 = *off
     c                   eval      *in92 = *off
     c                   eval      *in93 = *on
     c                   write     dspsfc3
     c                   eval      *in92 = *on
     c                   eval      *in93 = *off
     c                   eval      w3ucnt= 0
     c                   eval      recn2 = 0
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Initialization.  Called from Mainline
     *
     c     zzinz         begsr
     *
     *  Define keys used in program.
     *
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    uklbl#
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    wblbl#
     *
     *  Define key to get last sequence number assigned per the label
     C     ordkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    w2hlbl
     *
     C     labkey        klist
     C                   kfld                    w1tran
     C                   kfld                    w3item
     *
     C     plblky        klist
     C                   kfld                    w8lbl#
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    w3item
     *
     C     rtnkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbpbat
     C                   kfld                    lbitem

     C     uciky1        klist
     C                   kfld                    w1whse
     C                   kfld                    w3inbr

     C     ucikyc        klist
     C                   kfld                    w1whse
     C                   kfld                    w15itm

     C     ordmky        klist
     C                   kfld                    @pwhse
     C                   kfld                    lbord

     C     itmkey        klist
     C                   kfld                    @pwhse
     C                   kfld                    lbitem

     C                   eval      forevr = *off
     C                   eval      nxtscr = '01'
     C                   eval      *in02 = *on
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      optln1 = optln(1)
     C                   eval      optln3 = optl3(1)
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln3 = cmdl3(1)

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse
     C                   parm      0             #emp#
     C                   parm                    #fnam
     C                   parm                    #init
     C                   parm                    #lnam
     C                   parm                    #whdp
     C                   parm                    #styp
     C                   parm                    #shft
     C                   parm                    #crew
     C                   parm      0             #nhrs
     C                   parm                    #rtn
     *
     C                   eval      @pwhse = #whse
     C                   eval      w1whse = #whse
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd
     C                   parm                    #lline
     C                   parm                    #lcol
     *
     *   Get warehouse description.
     *
     C                   eval      wowhse = *blanks

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      @pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
     *
     *   Put warehouse and department together.
     *
     C                   eval      wowhse = $vdesc

     C                   endsr
     *----------------------------------------------------------------
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 16
**  ZOPT2 - Valid options
 1 X
**  OPTLN - Option display line
  1=Uci 16=CtWgt
**  OPTL3 - Option display line
  1=Select  X=Unselect
**  CMDLN - Command display line
F3=Exit  F12=Cancel
**  CMDL3 - Command display line
F3=Exit  F8=Done  F12=Cancel
**
Transaction not found.
Transaction already at Status 4.
Transaction. No valid catch weight entries.
Scanned lbl not for this transaction.
Option must be 1 or 16.
Option must be 1 or X.
UCI Number already been scanned.
BFC Label. Label or Option required.
UCI Number Exceeds pick quantity.
Option.  No CW Entries Exists.
Item not a catchwgt
Not enough UCI's selected.
Lic# not found in UCICW.
UCI Scanning Only
Invalid Warehouse.
