     *----------------------------------------------------------------
     *
     *  SL385     View slots with negative quantity by slot
     *  24 May, 2004
     *  Roxanne Harrison
     *
     *  Revisions:
     *
     *  05/24/04  RH   4.17a
     *   - Created
     *
640a *  07/05/11  GJA  6.40a
     *   - Fix:  When negative normal UOM and positive brk1, show as
     *           negatvie brk1
     *           Converted RPGLE
640b *  09/27/11  RH   6.40b
     *   - Enh: Add license, remove transfer & receive qty
710a *  09/08/17  MR   7.10a
     *   - Fix: Comment out line so the *ALL function will work
     *          properly.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  91        Protect "Position to" field #1
     *  92        Protect "Position to" field #2
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fsl385fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno2)
     F                                     sfile(msgrec:msgk)
     Fsl381b    if   e           k disk
     F                                     rename(wkrec:record)
     *LOT2   IF  E           K        DISK
     Fpiritem   if   e           k disk
     Fwhdept    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(24)
     D ukey            s             50    dim(24)
VW2 AD cmdln           s             79    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     *PRTKY      DS
     *                                       1  50 $LEN50
     *                                       1   30$KWHSE
     *                                       4   8 $KWHDP
     *                                       9   9 $KWTYP
     *----------------------------------------------------------------
     *  Max lines in display file
     *
     D maxlin          c                   const(10)
     *
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  wkwhse                 1      3  0
     D  wkwhdp                 4      8
     D  wkstyp                 9      9
     D  wkdisp                10     21
     D  wkitem                22     36
     *           DS
     *                                       1   30UTWHSE
     *                                       4   8 UTWHDP
     *                                       9   9 UTSTYP
     *                                      10  24 UTITEM
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
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
     *  Called program parameters
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $ldesg                19     23
640bA*----------------------------------------------------------------
640bA*  DRI parameters
640bA*----------------------------------------------------------------
640bA
640bA /COPY *libl/qcopysrc,C#DRIPARMS

640bA /COPY *libl/qcopysrc,C#SLOT
640bAD savever#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
640bAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $kwhse          s              3  0
     D $msgf           s             10
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
     D maxvw           s              1  0
     D msgk            s              4  0
     D nxtscr          s              3
     D p               s              2  0
     D pagcmd          s              8
     D reccnt          s              4  0
     D recno           s              4  0
     D recno2          s              4  0
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D wkumq           s              3  0
     D w1alc           s             10
     D w1pck           s             10
     D w1qty           s             10
     D w1rcv           s             10
     D w1stk           s             10
     D w1tfr           s             10
     D y               s              2  0
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $kwhdp            5
     C                   parm                    $kwtyp            1
     C                   move      $whse         $kwhse
     *
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   exsr      zzinz2
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
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       111213
     C                   setoff                                       313233
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
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   read      dspsfc                                 50
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   endsl
VW2 D*R                   READ DSPSFC                   50
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
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
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
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - CANCEL
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
VW2 A*
VW2 A*  TEST FOR CMD10 - Next view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
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
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R                   MOVE '*CANCEL '$LRTN
     *R                   MOVE 'EOJ'     NXTSCR
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
     *      $PORTN   *NOMORE  - Beginning/End of file was reSDhed
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took plSDe
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
     C                   eval      dsukey = $pouky
     C     fileky        chain     record                             79
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pofky = *blanks
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
     C                   eval      $pofky = *blanks
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
     C                   eval      $pofky = *blanks
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
     *  GET MAXLIN RECORDS TO DISPLAY
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
     C                   goto      endfsd
     C                   endif
     *
     *  RECORD READ - STOP AFTER MAXLIN GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= maxlin
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfsd        tag
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
     C     dsplyd        add       maxlin        goback
     C                   if        bot = '1'
     C                   if        goback = maxlin
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
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno <= maxlin
VW2 D*R                   ADD  1         RECNO
VW2 D*R                   Z-ADDRECNO     Y       20
VW2  C                   add       1             reccnt
VW2  C                   z-add     reccnt        y
VW2  C                   eval      recno = reccnt
VW2 AC                   eval      recno2 = reccnt
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
VW2 AC                   write     vw2sfl
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
VW2 AC                   write     vw2sfc
     C                   eval      recno = 0
VW2 AC                   eval      recno2 = 0
VW2 AC                   eval      reccnt = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE COMMAND LINE TO DISPLAY
     *
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
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
VW2 AC                   eval      recno2 = recno
VW2 D*R                   WRITEDSPSFC
VW2 AC                   select
VW2 AC                   when      view = 1
VW2 AC                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   endsl
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *                                         T
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
     *     11021  Invalid value for section.
     *
     C     zm1021        begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     *
     C                   select
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp <> 'A'
     C     partky        reade     record                                 79
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp = 'A'
     C     partk2        reade     record                                 79
     C                   other
     C     partk1        reade     record                                 79
     C                   endsl
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
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     *
     C                   select
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp <> 'A'
     C     partky        readpe    record                                 79
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp = 'A'
     C     partk2        readpe    record                                 79
     C                   other
     C     partk1        readpe    record                                 79
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *
     *  Calculate Qty available (stock + rcv) - (aloc + pick + trans)
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    wkstk1
     C                   parm                    wkstk2
     C                   parm                    wkstk3
     *
     C                   parm                    wkalc1
     C                   parm                    wkalc2
     C                   parm                    wkalc3
     *
     C                   parm                    wktfr1
     C                   parm                    wktfr2
     C                   parm                    wktfr3
     *
     C                   parm                    wkpck1
     C                   parm                    wkpck2
     C                   parm                    wkpck3
     *
     C                   parm                    wkrcv1
     C                   parm                    wkrcv2
     C                   parm                    wkrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      w1desc = *blanks
     C                   else
     C                   movel     itdesc        w1desc
640aA*   If negative normal stock and positive brk1 convert
640aAC                   if        wkstk1 < 0  and
640aAC                             wkstk2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkstk1        mult      itumq2        wkumq
640aAC     wkumq         add       wkstk2        wkstk2
640aAC                   eval      wkstk1 = 0
640aAC                   endif
640aA*   If negative normal recv and positive brk1 convert
640aAC                   if        wkrcv1 < 0  and
640aAC                             wkrcv2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkrcv1        mult      itumq2        wkumq
640aAC     wkumq         add       wkrcv2        wkrcv2
640aAC                   eval      wkrcv1 = 0
640aAC                   endif
640aA*   If negative normal alc and positive brk1 convert
640aAC                   if        wkalc1 < 0  and
640aAC                             wkalc2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkalc1        mult      itumq2        wkumq
640aAC     wkumq         add       wkalc2        wkalc2
640aAC                   eval      wkalc1 = 0
640aAC                   endif
640aA*   If negative normal tfr and positive brk1 convert
640aAC                   if        wktfr1 < 0  and
640aAC                             wktfr2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wktfr1        mult      itumq2        wkumq
640aAC     wkumq         add       wktfr2        wktfr2
640aAC                   eval      wktfr1 = 0
640aAC                   endif
640aA*   If negative normal pck and positive brk1 convert
640aAC                   if        wkpck1 < 0  and
640aAC                             wkpck2 > 0  and
640aAC                             itumq2 <> 0
640aAC     wkpck1        mult      itumq2        wkumq
640aAC     wkumq         add       wkpck2        wkpck2
640aAC                   eval      wkpck1 = 0
640aAC                   endif
     C                   endif
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     C                   exsr      zzcqty
     C                   eval      w1qty = $pqstr
     *
     C                   eval      $pqty1 = wkstk1
     C                   eval      $pqty2 = wkstk2
     C                   eval      $pqty3 = wkstk3
     C                   exsr      zzcqty
     C                   eval      w1stk = $pqstr
     *
     C                   eval      $pqty1 = wkrcv1
     C                   eval      $pqty2 = wkrcv2
     C                   eval      $pqty3 = wkrcv3
     C                   exsr      zzcqty
     C                   eval      w1rcv = $pqstr
     *
     C                   eval      $pqty1 = wkalc1
     C                   eval      $pqty2 = wkalc2
     C                   eval      $pqty3 = wkalc3
     C                   exsr      zzcqty
     C                   eval      w1alc = $pqstr
     *
     C                   eval      $pqty1 = wktfr1
     C                   eval      $pqty2 = wktfr2
     C                   eval      $pqty3 = wktfr3
     C                   exsr      zzcqty
     C                   eval      w1tfr = $pqstr
     *
     C                   eval      $pqty1 = wkpck1
     C                   eval      $pqty2 = wkpck2
     C                   eval      $pqty3 = wkpck3
     C                   exsr      zzcqty
     C                   eval      w1pck = $pqstr
     *
640b *
640b *  Get License
640bAC                   exsr      clr$slot
640bAC                   eval      $slwhseu = *on
640bAC                   eval      $slwhse  = wkwhse
640bAC                   eval      $slwhdpu = *on
640bAC                   eval      $slwhdp  = wkwhdp
640bAC                   eval      $sldispu = *on
640bAC                   eval      $sldisp  = wkdisp
640bA
640bAC                   eval      $dricommand = '*SLOT'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   exsr      zzzdricop
640bAC                   if        error = *on
640bAC                   eval      error = *off
640bMC                   eval      $saToPos = 0
640bAC                   endif
640bA*
640bAC                   eval      w1lcns = $saToLcns
     *
     *
     *
     *
     *  Get item description.
     *
     *
     C                   select
     C                   when      itstyp = 'P'
     C                   eval      w1styp = 'PIR  '
     *
     C                   when      itstyp = 'F'
     C                   eval      w1styp = 'FIXED'
     *
     C                   other
     C                   eval      w1styp = *blanks
     C                   endsl
     *
     **                   MOVE OQVDSP    W1VDSP
     C                   eval      w1item = wkitem
     **                   MOVE OQSTAT    W1STAT
     C                   eval      w1disp = wkdisp
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkwhdp
     C                   kfld                    wkstyp
     C                   kfld                    wkdisp
     C                   kfld                    wkitem
     *
     *  Define full key for main file.
     *
     *
     C     fileky        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkwhdp
     C                   kfld                    wkstyp
     C                   kfld                    wkdisp
     C                   kfld                    wkitem
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    $kwtyp
     *
     *  Define partial key for main file (if needed).
     *
     C     partk2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     *
     *  Define partial key for main file (if needed).
     *
     C     partk1        klist
     C                   kfld                    $kwhse
     *
     *  Define key for ITEM file.
     *
     C     keyit         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkitem
     *
     *
     C                   eval      $poprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 2
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
     *   Verify warehouse and get description.
     *
     C                   eval      wkwhse = $kwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $kwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = wkwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     C                   if        $kwhse <> 0
     C                   move      $kwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     C                   endif
     *
     *  Get initial department.
     *
     C     keywd         klist
     C                   kfld                    $kwhse
     C                   kfld                    wdcode
     *
     C                   if        $kwhdp = '*ALL '
710aDC*                  eval      wdcode = *blanks
     C                   else
     C                   eval      wdcode = $kwhdp
     C                   endif
     *
     C     keywd         setll     whdept
     C                   read      whdept                                 79
     C                   if        *in79
     C                   eval      wddesc = *blanks
     C                   endif
710aDC*                  eval      $kwhdp = wdcode
     C                   eval      wkwhdp = wdcode
     *
     ***                  MOVE *BLANKS   WKDESG
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
640bA*----------------------------------------------------------------
640bA*  clr$slot  Clear $slot data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$slot      begsr
640bAC                   eval      savever# = $slver#
640bAC                   clear                   $slot
640bAC                   clear                   $slot2
640bAC                   eval      $slver# = savever#
640bAC                   endsr
640bA
640bA
     *----------------------------------------------------------------
     *
     C     zzcqty        begsr
     *
     C                   eval      $pcmd = '*QTY2STR'
     *                    Z-ADDAVAIL1    $PQTY1
     *                    Z-ADDAVAIL2    $PQTY2
     *                    Z-ADDAVAIL3    $PQTY3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm
     *
     *                    MOVE $PQSTR    W1QTY  10
     *
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
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *
     *  See if user is trying to change department.
     *
     C                   if        ptinp2 <> *blanks
     *
     *      Verify department entry.
     *
     C                   eval      wdcode = ptinp2
     C                   eval      wddesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $kwhse
     C                   eval      $lwhdp = ptinp2
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   endif
     C                   endif
     C                   eval      wkwhdp = ptinp2
     C                   eval      $kwhdp = ptinp2
     C                   eval      wkdisp = *blanks
     C                   eval      wkstyp = *blanks
     C                   movel     $lerm         wddesc
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     C                   endif
     *
     *  See if user is trying to position to item.
     *
     C                   if        ptinp5 <> *blanks
     C                   eval      wkdisp = ptinp5
     C                   eval      wkitem = *blanks
     C                   eval      ptinp5 = *blanks
     C                   eval      repos = *on
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      wkstyp = 'F'
     C                   else
     C                   eval      wkstyp = itstyp
     C                   endif
     *
     C                   endif
     *
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   ENDIF
     *R                   ENDIF
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     *
     C                   select
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp <> 'A'
     C     partky        setll     record
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp = 'A'
     C     partk2        setll     record
     C                   other
     C     partk1        setll     record
     C                   endsl
     *
     C                   else
     *
     C                   if        $pocmd = '*BOTTOM'
     *
     C                   select
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp <> 'A'
     C     partky        setgt     record
     C                   when      $kwhdp <> '*ALL'  and
     C                             $kwtyp = 'A'
     C     partk2        setgt     record
     C                   other
     C     partk1        setgt     record
     C                   endsl
     *
     C                   endif
     C                   endif
     C                   endsr
640bA*----------------------------------------------------------------
640bA*  zzzdricop  Call DRICOP
640bA*----------------------------------------------------------------
640bA
640bAC     zzzdricop     begsr
640bAC                   eval      error = *off
640bA
640bAC                   select
640bAC                   when      $dricommand = '*SLOT'
640bAC                   eval      $dridata = $slot
640bAC                   eval      $dridata2 = $slot2
640bAC                   endsl
640bA
640bAC                   if        $dricommand = '*ITEM'
640bAC                             or $dricommand = '*SLOT'
640bAC                   call(e)   'DRICOP'
640bAC                   parm                    $dricommand
640bAC                   parm                    $drisubcmd
640bAC                   parm                    $drisys2upd
640bAC                   parm      #pgm          $driprogram
640bAC                   parm      ' '           $drireturn
640bAC                   parm      ' '           $drimessage
640bAC                   parm                    $dridata
640bAC                   parm                    $dridata2
640bAC                   else
640bAC                   call(e)   'DRICOP'
640bAC                   parm                    $dricommand
640bAC                   parm                    $drisubcmd
640bAC                   parm                    $drisys2upd
640bAC                   parm      #pgm          $driprogram
640bAC                   parm      ' '           $drireturn
640bAC                   parm      ' '           $drimessage
640bAC                   parm                    $dridata
640bAC                   endif
640bA
640bAC                   select
640bA
640bAC                   when      %error
640bAC                   eval      error = *on
640bA
640bAC                   when      $drireturn <> '*OK'
640bAC                   eval      error = *on
640bA
640bAC                   endsl
640bA
640bAC                   select
640bAC                   when      $dricommand = '*SLOT'
640bAC                   eval      $slot = $dridata
640bAC                   eval      $slot2 = $dridata2
640bAC                   endsl
640bA
640bAC     enddricop     endsr
640bA
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F10=View 2   F12=Cancel

F3=Exit  F5=Refresh  F10=View 1   F12=Cancel

