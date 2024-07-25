      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  For some clients, use CHGDSPF to set RSTDSP to *YES for the
     *  screen specs.  When running pgms OR910 or OR920 using iSeries
     *  Access, and the user selects an item with an error, OR200
     *  would blow up with an I/O error.
     *----------------------------------------------------------------
     *
     *  OR920     RF single order pick by slot - Display
     *  03 June 2002
     *  Dave Sommerville
     *
     *  Note:  This program uses F4 to call position to program.
     *         The position to logic is executed in CMD01.
     *       8 X 20 Screens for hand held scanners
     *  Revisions
     *
416 A*    06/03/02  DAS  4.16
     *      - Created.
     *
640aA*    04/27/11  DAS  6.40a
     *      - Revised to use ORDDSOS1 instead of LABEL9.
     *
640bA*    06/23/11  DAS  6.40b
     *      - Revised to get label number.
     *
640cA*    06/27/11  RBD  6.40c
     *      - Added client logic.
     *      - Moved chain to ORDD from ZZFILL routine to ZZFGTN
     *        and ZZFGTP so qty's ordered can be checked.
     *
640dA*    07/07/11  DAS  6.40d
     *      - Added sql indicator to sql statements. This was done
     *        to prevent job log entries from being created when
     *        no record was found.
     *
640eA*    08/11/11  RBD  6.40e
     *      - Fix: Corrected population of key fields in ZZPOS,
     *        was not re-positioning to correct slot.
640fA*    08/11/11  RH   6.40f
     *      - Enh: Add F7 to display only lines with balance to pick
     *        OR F7 to display all lines.
640gA*    08/25/11  RBD  6.40g
     *      - Added logic to flag a label as 'in use' by updating
     *        lbvrfy with an 'I' if the label is selected.
     *        Note, OR200 will update lbvrfy with a blank when
     *        the selector completes the transaction or does F12.
     *      - Do not allow selection if the label is 'in use'.
     *        This prevents multiple selectors from being able to
     *        pick the same line item at the same time, thus,
     *        opening the door for the item to be overpicked, which
     *        is not allowed.
640hA*    09/14/11  RBD  6.40h
     *      - Fix:  Populate odseq, wrong record was getting selected
     *        if user selected multiple records at the same time.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Eastland
     *
EFCaA*    06/27/11  RBD  EFCa
     *      - Do not display items with 0 qty ordered, was causing
     *        dec data error if user selected the item.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *   - The OPTNS routine is not standard. This program originally
     *     started as just a selection program and has expanded into
     *     a semi-normal list display.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  09        Allow F9 to be used
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  91        Protect "POSITION TO" field #1
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     For920fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fworkopt   uf a e           k disk
640aDF*abel9    if   e           k disk
640aMForddsos1  if   e           k disk
     F                                     rename(odsrec:record)
     Fpiritem   if   e           k disk
     Fordd      if   e           k disk
640gAFlabel     uf   e           k disk
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
640fMD cmd             s             75    dim(2) ctdata perrcd(1)
640fDD*cmd             s             75    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
640cA*  Customer id
640cA*----------------------------------------------------------------
EFCaA /copy qcopysrc,id#eastland
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $pparm          ds
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
     D  $pord                 22     28  0
     D  $pseq                 29     33  0
     D  $pitem                34     48
     D  $prtid                49     53
     D  $ppbat                54     60  0
     D  $plbl#                61     67  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
640bAD  odswhs                 1      3  0 inz(0)
640bAD  odsord                 4     10  0 inz(0)
640bAD  odsseq                11     15  0 inz(0)
640bAD  odsitem               16     30
640bDD* lbpbat                 1      7  0 inz(0)
640bDD* lbwhse                 8     10  0 inz(0)
640bDD* lbrte                 11     15
640bDD* lbstyp                16     16
640bDD* lbtype                17     17
640bDD* lbwhdp                18     22
640bDD* lbaisl                23     25
640bDD* lbpseq                26     30  0 inz(0)
640bDD* lbrlvl                31     32  0 inz(0)
640bDD* lbhand                33     34
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukord                  4     10  0 inz(0)
     D  ukseq                 11     15  0 inz(0)
     D  ukitem                16     30
     D  ukrtid                31     35
     D  ukpbat                36     42  0 inz(0)
     D  uklbl#                43     49  0 inz(0)
     *
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
     D  $lpo                  22     30
     D  $lseq                 31     35  0
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
     D $tuky           s             15
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
640fAD bal             s              1
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D gobsdk          s              2  0
     D help            s              5  0
640gAD hldlbl          s              7  0
     D maxval          s              3  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D otakn1          s              1
     D p               s              2  0
     D pagcmd          s              8
640aAD pick1           s              7  0
640aAD pick2           s              7  0
640aAD pick3           s              7  0
     D ptinp1          s             15
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
640dAD sqlind          s              2b 0 inz(0)
     D stop            s              1
     D top             s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *SELECT  - Selection lookup.
     *              *SELEC16 - Selection lookup (16-Line display).
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
     *              *FIXED   - Goto FIXED slot lookup.
     *      $PERM   Error message or pointer to message in pgmq.
     *              -or- Description of verified code.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pparm
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
     C                   eval      $prtn = *blanks
     C                   exsr      zzinz2
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   eval      $ec = 0
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
     *R                   READ POSTNREC                 50
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   read      d16sfc                                 50
     C                   other
     C                   read      dspsfc                                 50
     C                   endsl
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
640cA* Get client id.
640cA*
640cAC                   call      'GETCLIENT'
640cAC                   parm                    client           10
640cAC                   parm                    clientloc        10
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     d16sfl                               79
     C                   other
     C                   write     dspsfl                               79
     C                   endsl
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
     C                   eval      $prtn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD4 - Call for position to.
     *
     C                   if        *inkd
     C                   eval      $tuky = *blanks
     C                   call      'PO920P'
     C                   parm                    $tuky
     C                   eval      ptinp1 = $tuky
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
     C                   goto      cmd01e
     C                   endif
     C                   endif
     *
640fA*  TEST FOR CMD7 - Display Balance only or all item lines
640fA*
640fAC                   if        *inkg
640fAC                   if        bal = *on
640fAC                   eval      bal = *off
640fAC                   movel     cmd(2)        cmdln1
640fAC                   else
640fAC                   eval      bal = *on
640fAC                   movel     cmd(1)        cmdln1
640fAC                   endif
640fAC                   eval      pagcmd = '*REFRESH'
640fAC                   exsr      pag01
640fAC                   goto      cmd01e
640fAC                   endif
     *
     *  TEST FOR CMD9 - Display in Line order.
     *
     C                   if        *inki
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*F9     '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - CANCEL
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C                   if        $pcmd = '*SELEC16'
     C                   eval      maxval = 10
     C                   else
     C                   eval      maxval = 3
     C                   endif
     **         1         DO   3         X
     C     1             do        maxval        x
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C     x             chain     d16sfl                             79
     C                   other
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   move      '  '          option
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   update    d16sfl
     C                   other
     C                   update    dspsfl
     C                   endsl
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
     C                   sub       3             row#
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
     *R                   MOVE *OFF      REPOS   1
     *R                   EXSR ZZPOS
     *R         REPOS     IFEQ *ON
     *R                   MOVE DSFKEY    $POFKY
     *R                   MOVE '*POSTN2 '$POCMD
     *R                   EXSR FGTWAY
     *R                   MOVE '*REPOS  'PAGCMD
     *R                   EXSR PAG01
     *R                   GOTO ENT01E
     *R                   END
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  If option 1 was taken, return to calling program.
     *
     C                   if        otakn1 = *on
640bAC                   exsr      zzlbl#
     C                   eval      $prtn = '*SELECT '
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     **         OTAKEN    IFEQ '0'
     **                   MOVE '*CANCEL '$PRTN
     **                   ELSE
     **                   MOVE '*SELECT '$PRTN
     **                   END
     **                   MOVE 'EOJ'     NXTSCR
     *R                   SETON                     LR
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
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     C                   eval      otakn1 = *off
     *
     *  Do options in the order they were entered.
     *     Skip option '1' records.
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = *on  or
     C                             cancel = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '  and
     C                             wkoopt <> ' 1'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      zzopt
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop = *on
     C                   if        error = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        cancel = *on
     C                   goto      optnse
     C                   endif
     *
     *  Now see if option '1' was taken. If so, take first one, only.
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   endif
     C                   if        not *in79  and
     C                             wkoopt = ' 1'
     C                   eval      otaken = *on
     C                   eval      otakn1 = *on
     C                   eval      $puky = wkokyu
640hAC                   eval      odseq = $pseq
     C                   eval      stop = *on
640gA*  Set lbvrfy to in use.
640gAC                   eval      hldlbl = 0
640gAC/EXEC SQL
640gAC+  select min(lblbl#) into :hldlbl
640gAC+  from   label
640gAC+  where  lbwhse = :$pwhse and lbrte = :$prtid and
640gAC+         lbord  = :$pord and lbseq = :$pseq
640gAC/END-EXEC
640gAC     hldlbl        chain     label
640gAC                   eval      lbvrfy = 'I'
640gAC                   update    lbrec
640gAC                   unlock    label
     C                   endif
     C                   enddo
     C                   if        refrsh = *on
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
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
     *R                   MOVE 'Bottom ' MORELN
     C                   goto      endfsd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 3  GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 3  and
     C                             $pcmd <> '*SELEC16'  or
     C                             p >= 10  and
     C                             $pcmd = '*SELEC16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     *R                   MOVE 'Bottom ' MORELN
     C                   else
     *R                   MOVE 'More...' MORELN
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
     *  CALCULATE HOW MANY RECORDS TO GO BSDKWARDS
     *
     C                   if        $pcmd <> '*SELEC16'
     C     dsplyd        add       3             gobsdk
     C                   else
     C     dsplyd        add       10            gobsdk
     C                   endif
     C                   if        bot = '1'
     C                   if        gobsdk = 3  and
     C                             $pcmd <> '*SELEC16'  or
     C                             gobsdk = 10  and
     C                             $pcmd = '*SELEC16'
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             gobsdk
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
     *  RECORD READ - STOP AFTER READING 'GOBSDK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= gobsdk
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS RESDHED THEN POSITION POINTER TO TOP OF FILE
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
     C                   eval      wovrfy = 'N'
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   readc     d16sfl                                 79
     C                   other
     C                   readc     dspsfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid.
     *
     C                   if        option <> *blanks  and
     C                             option <> '1'  and
     C                             option <> 'X'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
640gA*  If option 1, verify that label is not 'in use'.
640gA*
640gAC                   if        option = '1'
640gAC                   eval      hldlbl = 0
640gAC/EXEC SQL
640gAC+  select min(lblbl#) into :hldlbl
640gAC+  from   label
640gAC+  where  lbwhse = :$pwhse and lbrte = :$prtid and
640gAC+         lbord  = :$pord and lbseq = :odseq
640gAC/END-EXEC
640gAC                   if        hldlbl > 0
640gAC     hldlbl        chain     label
640gAC                   if        lbvrfy = 'I'
640gAC                   eval      error = *on
640gAC                   eval      errmsg    = 'Label in use'
640gAC                   eval      *in21 = *on
640gAC                   exsr      zm0105
640gAC                   endif
640gAC                   endif
640gAC                   endif
640gAC                   unlock    label
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
     C                   if        recno < 4  and
     C                             $pcmd <> '*SELEC16'  or
     C                             recno < 11  and
     C                             $pcmd = '*SELEC16'
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     d16sfl
     C                   other
     C                   write     dspsfl
     C                   endsl
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     d16sfc
     C                   other
     C                   write     dspsfc
     C                   endsl
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
     *R                   WRITEOPTREC
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     c16rec
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     *R                   WRITEMORREC
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     *R                   WRITEPOSTNREC
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C     1             chain     d16sfl                             79
     C                   other
     C     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   update    d16sfl
     C                   other
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     d16sfc
     C                   other
     C                   write     dspsfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C                   if        $pcmd = '*SELEC16'
     C                   eval      maxval = 10
     C                   else
     C                   eval      maxval = 3
     C                   endif
     **         1         DO   3         X       30
     C     1             do        maxval        x
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C     x             chain     d16sfl                             79
     C                   other
     C     x             chain     dspsfl                             79
     C                   endsl
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   update    d16sfl
     C                   other
     C                   update    dspsfl
     C                   endsl
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
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
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   select
     C                   when      $pcmd = '*SELEC16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
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
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq
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
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     C     partky        reade     record                                 79
     *
640cAC                   if        %eof
640cAC                   goto      endfgtn
640cAC                   endif
     *
640cA*    Get Order detail record.
640cA*
640cAC     odkey         chain     ordd                               79
640cAC                   if        *in79
640cAC                   eval      odqor1 = 0
640cAC                   eval      odqor2 = 0
640cAC                   eval      odqor3 = 0
640cAC                   endif
     *
EFCaA*    Under certain conditions, bypass item record if qty
EFCaA*    ordered is zero.
EFCaA*
EFCaAC                   if        client = eastland and
EFCaAC                             (odqor1 + odqor2 + odqor3) = 0
EFCaAC                   goto      try1
EFCaAC                   endif
EFCaA*
640fA*    Bypass item record if no pick quantity remains and F7
640fA*    pressed to only see lines with pick balance.
640fA*
640fAC                   if        not %eof and
640fAC                             bal = *on
640fAC                   exsr      zzlbl#
640fAC                   if        pick1=odqor1 and pick2=odqor2
640fAC                             and pick3=odqor3
640fAC                   goto      try1
640fAC                   endif
640fAC                   endif
EFCaA*
640cAC     endfgtn       endsr
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
     C     partky        readpe    record                                 79
     *
640cAC                   if        %eof
640cAC                   goto      endfgtp
640cAC                   endif
     *
640cA*    Get Order detail record.
640cA*
640cAC     odkey         chain     ordd                               79
640cAC                   if        *in79
640cAC                   eval      odqor1 = 0
640cAC                   eval      odqor2 = 0
640cAC                   eval      odqor3 = 0
640cAC                   endif
     *
EFCaA*    Under certain conditions, bypass item record if qty
EFCaA*    ordered is zero.
EFCaA*
EFCaAC                   if        client = eastland and
EFCaAC                             (odqor1 + odqor2 + odqor3) = 0
EFCaAC                   goto      try2
EFCaAC                   endif
EFCaA*
640fA*    Bypass item record if no pick quantity remains and F7
640fA*    pressed to only see lines with pick balance.
640fA*
640fAC                   if        not %eof and
640fAC                             bal = *on
640fAC                   exsr      zzlbl#
640fAC                   if        pick1=odqor1 and pick2=odqor2
640fAC                             and pick3=odqor3
640fAC                   goto      try2
640fAC                   endif
640fAC                   endif
EFCaA*
640cMC     endfgtp       endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *    Get Item description.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
     *
     *    Create main output line.
     *
     C                   eval      woitem = *blanks
640aMC                   movel     odsdsp        woitem
     C     woitem        cat       '/':0         woitem
640aMC     woitem        cat       odsitm:0      woitem
     C     woitem        cat       '/':0         woitem
     C     woitem        cat       itdesc:0      woitem
     *
640cD**   Get Order detail record.
640cD**
640cDC**   odkey         chain     ordd                               79
640cDC**                 if        *in79
640cDC**                 eval      odqor1 = 0
640cDC**                 eval      odqor2 = 0
640cDC**                 eval      odqor3 = 0
640cDC**                 endif
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
640aDC**                 move      '#PROG   '    $cprg
640aMC                   move      #PROG         $cprg
     C                   eval      $cqty1 = odqor1
     C                   eval      $cqty2 = odqor2
     C                   eval      $cqty3 = odqor3
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   movel     $cqstr        woqor

640aAC                   exsr      zzlbl#

     C                   eval      $ccmd = '*QTY2STR'
640aDC**                 move      '#PROG   '    $cprg
640aMC                   move      #PROG         $cprg
640aMC                   eval      $cqty1 = pick1
640aMC                   eval      $cqty2 = pick2
640aMC                   eval      $cqty3 = pick3
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   movel     $cqstr        woqrc
     *
     *    See if line has been touched.  Flag accordingly.
     *
640aDC**                 if        lbqpck = 0
640aMC                   if        pick1=0 and pick2=0 and pick3=0
     C                   eval      touch = *blanks
     C                   else
     C                   eval      touch = 'X'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define full key for main file.
     *
640aDC**   fileky        klist
640aDC**                 kfld                    $ppbat
640aDC**                 kfld                    $pwhse
640aDC**                 kfld                    $prtid
640aDC**                 kfld                    lbstyp
640aDC**                 kfld                    lbtype
640aDC**                 kfld                    lbwhdp
640aDC**                 kfld                    lbaisl
640aDC**                 kfld                    lbpseq
640aDC**                 kfld                    lbrlvl
640aDC**                 kfld                    lbhand
     *
640aMC     fileky        klist
640aMC                   kfld                    $pwhse
640aMC                   kfld                    $prtid
640aMC                   kfld                    $pord
640aMC                   kfld                    odsdsp
640aMC                   kfld                    odsseq
640aMC                   kfld                    odsitm
     *
     *  Define partial key for main file (if needed).
     *
640aDC**   partky        klist
640aDC**                 kfld                    $ppbat
640aDC**                 kfld                    $pwhse
640aDC**                 kfld                    $prtid
     *
640aMC     partky        klist
640aMC                   kfld                    $pwhse
640aMC                   kfld                    $prtid
640aMC                   kfld                    $pord
     *
     C     odkey         klist
     C                   kfld                    odswhs
     C                   kfld                    odsord
     C                   kfld                    odsseq
     C                   kfld                    odsitm
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    odsitm
     *
     *
     C                   eval      $poprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
640fA*   Default to display only lines with balance to be picked
640fAC                   eval      Bal = *on
     *   Format display line 1.
     *
     *   Format command line.
     *
640fAC                   if        Bal = *on
640fAC                   movel     cmd(1)        cmdln1
640fAC                   else
     C                   movel     cmd(2)        cmdln1
640fAC                   endif
640fAC                   eval      *in07 = *off
     C                   eval      *in09 = *off
     *
     C                   clear                   dsfkey
     C                   clear                   dsukey
     *R                   MOVE $PITEM    SLITEM
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
640aMC                   eval      ukwhse = odswhs
640aMC                   move      odsord        ukord
640aMC                   eval      ukseq = odsseq
640aMC                   eval      ukitem = odsitm
640aMC                   eval      ukrtid = odsrid
640aDC**                 eval      ukpbat = lbpbat
640aDC**                 eval      uklbl# = lblbl#
     C                   eval      $pouky = dsukey
     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZLBL#   Get total picked and first label number.
640aA*
640aAC     zzlbl#        begsr
     *
     C                   eval      pick1 = 0
     C                   eval      pick2 = 0
     C                   eval      pick3 = 0
     *
     C/EXEC SQL
640dMC+  select sum(lbqpck) into :pick1 :sqlind
     C+  from   label
     C+  where  lbwhse = :odswhs and lbrte = :odsrid and
     C+         lbord  = :odsord and lbseq = :odsseq and
     C+         lbutyp = 'N'
     C/END-EXEC
     *
     C/EXEC SQL
640dMC+  select sum(lbqpck) into :pick2 :sqlind
     C+  from   label
     C+  where  lbwhse = :odswhs and lbrte = :odsrid and
     C+         lbord  = :odsord and lbseq = :odsseq and
     C+         lbutyp = '1'
     C/END-EXEC
     *
     C/EXEC SQL
640dMC+  select sum(lbqpck) into :pick3 :sqlind
     C+  from   label
     C+  where  lbwhse = :odswhs and lbrte = :odsrid and
     C+         lbord  = :odsord and lbseq = :odsseq and
     C+         lbutyp = '2'
     C/END-EXEC
     *
640bAC/EXEC SQL
640bAC+  select min(lblbl#) into :$plbl#
640bAC+  from   label
640bAC+  where  lbwhse = :$pwhse and lbrte = :$prtid and
640bAC+         lbord  = :odord  and lbseq = :odseq
640bAC/END-EXEC
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS.
     *
     C     zzopt         begsr
     C     endopt        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   if        ptinp1 <> *blanks
640eDC**                 eval      odsitm = ptinp1
640eMC                   eval      odsdsp = ptinp1
640eAC                   eval      odsitm = *blanks
640eAC                   eval      odsseq = 0
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
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Slot Type
**
F7=All F9=Line  F12=Cancel
F7=Bal F9=Line  F12=Cancel
