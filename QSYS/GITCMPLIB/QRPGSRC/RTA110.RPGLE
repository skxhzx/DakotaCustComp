      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  RTA110   Returns StuffIt Adjustment
     *  07 October 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    10/07/04  DAS  4.17
     *      - Created (based on RTS110).
     *
417aA*    10/07/04  DAS  4.17a
     *      - Removed W1WHDP from screen, along with check logic.
     *      - Not capturing expiration date.
     *
500 A*    11/16/04  DAS  5.00
     *      - Added breakdown quantity to Screen3.
     *      - Added logic to allow or disallow entry of brkdn qty.
     *      - Updated to use ILE DRI logic for slots.
     *      - Changed to verify item using DRIITEM.
     *      - Remove PIRITEM file.
500aA*    03/23/05  MLB  5.00a
     *      - Enh: Revised program to add support for catchweight
     *        entry to screen 3.
500bA*    05/10/05  MLB  5.00b
     *      - Fix: Revised ZZFIL3 to clear W3QTY2 during setup.
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frta110fm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fworkopt   uf a e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     Fslot2     if   e           k disk
     F                                     rename(slrec:recordu)
     Fpiruser   if   e           k disk
     Fupc       if   e           k disk
417aAFLabel     if   e           k disk
500 AFunmesr    if   e           k disk
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
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     D desc            s             40    dim(5) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)
410 AD*slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  slstat                19     20
     D  slpick                21     21
     D  slprty                22     22  0 inz(0)
     D  slexpd                23     30  0 inz(0)
     D  slentd                31     38  0 inz(0)
     D  slwhdp                39     43
     D  slstyp                44     44
     D  slaisl                45     47
     D  slpseq                48     52  0 inz(0)
     D  slrlvl                53     54  0 inz(0)
     D  slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('*NONE')
     D @vewpg          c                   const('*NONE')
     D @delpg          c                   const('*NONE')
     D @prtpg          c                   const('*NONE')
     D @adjt2          c                   const('ADJTRAN2 ')
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
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
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
     D  $litem                22     36
     D  $litm1                22     36
     D  $lupc                 22     41
     *
     *
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
     *  Replenishment error messages(s).
     *
     D msg101          c                   const('Slot not available')
     D msg102          c                   const('for replenishment.')
     D msg103          c                   const('Expired:')
     D msg104          c                   const('Try new slot. ')
     *
     D msg201          c                   const('Slot has expired  ')
     D msg202          c                   const('product.')
     *
     D msg301          c                   const('Slot selected out')
     D msg302          c                   const('of FIFO order.')
     *
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     D llp01           c                   const('Scan license plate')
     D llp02           c                   const('Scan lot number   ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     *                                      16  27 ERDISP
     D  erdisp                 1     12
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *
     D                 ds
     D  wkyy                   3      4
     D  wkmm                   5      6
     D  wkdd                   7      8
     D  wkexpd                 1      8  0
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
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
     *  Variables
     *
     D $disp           s             12
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D #sitem          s                   like(slitem)
     D a58             s             58
     D bot             s              1
     D cancel          s              1
     D ckexpd          s                   like(today)
     D ck4err          s              1
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
     D drierr          s              1
     D drizm           s              1
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D fintim          s                   like(ptetim)
     D forceb          s              1
     D forevr          s              1
     D goback          s              2  0
     D help            s              5  0
     D keysta          s                   like(slstat)
     D kydisp          s                   like(sldisp)
     D kyexpd          s                   like(slexpd)
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D moreln          s              7
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtvslt          s              4
     D sclear          s              1
500 AD ssbflg          s               n
     D stop            s              1
     D strtim          s                   like(ptstim)
     D tempa2          s              2
     D today           s              8  0
     D top             s              1
     D trndte          s              8  0
     D trntim          s              6  0
     D tstdte          s                   like(today)
     D upcctr          s              3  0
     D warn            s              1
     D woslt           s             12
     D wsitem          s             15
     D w1crew          s                   like(uscrew)
     D w1emp#          s                   like(usemp#)
     D w1shft          s                   like(usshft)
     D w1styp          s                   like(usstyp)
     D w1up20          s             20
     D w1whdp          s                   like(lbwhdp)
     D w3expd          s              6  0
     D x               s              3  0
     D y               s              3  0
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
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
     C                   exsr      zzinz2
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
     C                   exsr      clrsch
500 AC                   exsr      zzzdriclose
     *                    SETON                     LR
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
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       202122
     C                   setoff                                       010204
500aDC*                  setoff                                       0323
500aMC                   setoff                                       032324
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   if        nxtscr = '02 '
     C                   select
     C                   when      #lline = '16'
     C                   read      d16sfc                                 50
     C                   other
     C                   read      dspsfc                                 50
     C                   endsl
     C                   endif
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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
500bAC                   eval      optcnt = 0
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   write     clr0306
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C     end03i        endsr
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
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     C     endsc3        endsr
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
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   eval      optcnt = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   exsr      zzabrt
     C                   exsr      scr01i
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   exsr      zzabrt
     C                   exsr      scr01i
     C                   goto      cmd02e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR F5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        dsplyd        x
     C                   select
     C                   when      #lline = '16'
     C     x             chain     d16sfl                             79
     C                   other
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
     C                   select
     C                   when      #lline = '16'
     C                   update    d16sfl
     C                   other
     C                   update    dspsfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   goto      cmd02e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd02e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR F10 - MOVE RECORD THAT CUSOR IS ON TO TOP
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
     C                   goto      cmd02e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD02E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag02
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR F17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag02
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR F18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag02
     C                   goto      cmd02e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent02e
     *
     *  CHECK IF SLOT WAS ENTERED.
     *
     C                   if        w2disp <> *blanks
     C                   exsr      zzchk2
     C     error         cabeq     *on           ent02e
     C     redspl        cabeq     *on           ent02e
     C     cancel        cabeq     *on           ent02e
     C                   eval      $disp = w2disp
     C                   eval      $puky = dsukey
     C                   exsr      zzupd2
     C                   goto      ent02e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     C     ent02e        endsr
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
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
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
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
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
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
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
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C*****????          eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag02
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     C                   select
     *
     *   Select slot for putaway.
     *
     C                   when      wkoopt = ' 1'
     C                   eval      dsukey = $puky
     C                   exsr      zzslct
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG02E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag2fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag2bk
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
     *R         CLERR     CABEQ'1'       PAG02E
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      offlag = *off
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
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     **         P         IFGE 10
     *R         P         IFGE 3
     C                   if        recno >= 3  and
     C                             #lline <> '16'  or
     C                             recno >= 10  and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
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
     C                   eval      forceb = *off
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
     **         DSPLYD    ADD  10        GOBACK  20
     *R         DSPLYD    ADD  8         GOBACK  20
     C                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   if        bot = '1'
     **         GOBACK    IFEQ 10
     *R         GOBACK    IFEQ 8
     C                   if        goback = 3  and
     C                             #lline <> '16'  or
     C                             goback = 10  and
     C                             #lline = '16'
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
     C                   exsr      pag2fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     *R                   MOVE *ZEROS    OPTCNT  30
     C                   dou       nomore = '1'
     *R                   MOVE '0'       *IN21
     C                   eval      *in85 = *off
     C                   select
     C                   when      #lline = '16'
     C                   readc     d16sfl                                 79
     C                   other
     C                   readc     dspsfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C                   if        option = ' 1'
     C                   add       1             optcnt
     C                   if        optcnt > 1
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0105
500bAC                   eval      optcnt = 0
     C                   endif
     *
     *    Force SFLNXTCHG to be on each time.
     C                   eval      *in85 = *on
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     *R                   MOVE *IN21     WKOERR
     C                   move      *in85         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     *R                   MOVE *IN21     WKOERR
     C                   move      *in85         wkoerr
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
     *R         RECNO     IFLT 11
     C                   if        recno < 3  and
     C                             #lline <> '16'  or
     C                             recno < 10  and
     C                             #lline = '16'
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
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
     C                   write     c16rec
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   select
     C                   when      #lline = '16'
     *R                   WRITEMORREC16
     C                   other
     *R                   WRITEMORREC
     C                   endsl
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *R                   WRITESCANREC
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                   select
     C                   when      #lline = '16'
     C     1             chain     d16sfl                             79
     C                   other
     C     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
     C                   write     d16sfc
     C                   other
     C                   write     dspsfc
     C                   endsl
     C                   write     scanrec
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     *R         1         DO   10        X       30
     *R         1         DO   3         X       30
     C     1             do        dsplyd        x
     C                   select
     C                   when      #lline = '16'
     C     x             chain     d16sfl                             79
     C                   other
     C     x             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in85 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   eval      *in85 = *off
     C                   endif
     C                   select
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
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
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   select
     C                   when      #lline = '16'
     *R                   WRITECLRSCR
     C                   other
     *R                   WRITECLRSCR
     C                   endsl
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   DRI0001  Interface error.
     *
     C     zm0001        begsr
     C                   movel     $drimessage   tempa2
     C                   if        tempa2 = 'H:'
     C                   eval      #msgid = 'DRI0002'
     C                   move      $drimessage   a58
     C                   eval      $drimessage = a58
     C                   else
     C                   eval      #msgid = 'DRI0001'
     C                   endif
     C                   eval      erdmsg = $drimessage
     C                   eval      erdrtn = $drireturn
     C                   eval      erdcmd = $dricommand
     C                   eval      erdsub = $drisubcmd
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
223 A*   PIR0204  Enter only one value.
223 A*
223 AC     zm0204        begsr
223 AC                   eval      #msgid = 'PIR0204'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
223 A*----------------------------------------------------------------
223 A*   PIR0205  Must enter one value.
223 A*
223 AC     zm0205        begsr
223 AC                   eval      #msgid = 'PIR0205'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w2disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IT27101  SLOT
     *
     C     zm7101        begsr
     C                   eval      #msgid = 'IT27101'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*     ZM0109   Quantity cannot be less than zero.
500 A*
500 AC     zm0109        begsr
500 AC                   eval      #msgid = 'PIR0110'
500 AC                   eval      #msgtp = '*DIAG  '
500aDC*                  eval      errmsg = desc(1)
500 AC                   movea     errmsg        $md(1)
500 AC                   exsr      zmpmsg
500 AC                   endsr
     *----------------------------------------------------------------
     *     ZM0110   Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
500aDC*                  eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR2007  Invalid slot, slot inactive.
     *
     C     zm2007        begsr
     C                   eval      #msgid = 'PIR2007'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
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
     *    LP11022  License not on file.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      wsitem = *blanks
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
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   endif
     C                   endif
417aA*
417aA*  Verify label#
417aA*
     C                   if        w1lbl# <> 0

     C     w1lbl#        chain     label                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Label # not found'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
417aA*
417aA*    Verify label is a selection label.
417aA*
     C                   if        lbtype <> 'O' and lbtype <> 'B'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Label # not a Selection label'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
417aA*
417aA*    Move department and item number into work fields.
417aA*
     C                   eval      w1whdp = lbwhdp
     C                   eval      w1item = lbitem

     C                   endif
417aD**
417aD** Verify warehouse department
417aD**
417aD**                   MOVE '*VERIFY '$LCMD
417aD**                   Z-ADDW1WHSE    $LWHSE
417aD**                   MOVE W1WHDP    $LWHDP
417aD**                   CALL 'WD900'
417aD**                   PARM           $LPARM
417aD**         $LRTN     IFEQ '*ERROR  '
417aD**                   MOVE *ON       ERROR
417aD**                   MOVE *ON       *IN22
417aD**                   MOVE *ON       *IN02
417aD**                   MOVEL$LERM     ERRMSG
417aD**                   EXSR ZM0105
417aD**                   ELSE
417aD**         $LRTN     IFEQ '*PGMQ   '
417aD**                   MOVE *ON       ERROR
417aD**                   MOVE *ON       *IN22
417aD**                   MOVE *ON       *IN02
417aD**                   MOVE $LMSG     #MSGK
417aD**                   EXSR ZMQMSG
417aD**                   ELSE
417aD**                   ENDIF
417aD**                   ENDIF
     *
     *  Must enter one, either item or UPC
     *
     C                   if        w1item = *blanks  and
     C                             w1upc = *blanks  and
417aAC                             w1lbl# = 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm0205
     C                   endif
     *
     *  Verify UPC
     *
     C                   select
     *  UPC entered
     C                   when      w1upc <> *blanks
     C                   if        w1item = *blanks
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   eval      $cbbar = w1upc
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w1upc = $cbv2
     C                   movel     $cbv2         w1up20
     C                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w1upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     C                   eval      upcctr = 0
     C     upckey        setll     upc
     C                   dow       forevr = forevr
     C     upckey        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
     C                   add       1             upcctr
     C                   endif
     *
     C                   enddo
     *
     C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm022
     C                   goto      endck1
     C                   endif
     *
     *   Multiple items exist for UPC
     C                   if        upcctr > 1
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   move      w1upc         $lupc
     C                   call      'UC920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   eval      upitem = $litem
     *
     C                   endif
     C                   eval      wsitem = upitem
     *
     C                   else
     *  Error, more than one value entered.
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0204
     C                   goto      endck1
     C                   endif
     *
     C                   endsl
     *
     *  Get item # from other field entered.
     *
     C                   if        w1item = *blanks  and
     C                             wsitem <> *blanks
     C                   eval      w1item = wsitem
     C                   endif
     *
     *  Verify ITEM
     *
     C                   if        w1item <> *blanks

     C                   exsr      clr$item

     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = w1item

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      drizm = *on
     C                   exsr      zzzdricop

     C                   if        error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      rtvslt = '*NO '
     *
     C                   eval      noslt = *off
     *
     *  SLOT not entered.
     *
     C                   if        w2disp = *blanks
     C                   eval      noslt = *on
     C                   eval      woslt = *blanks
     C                   goto      endck2
     C                   endif
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w2disp
     C                   parm      1             worow
     C                   parm      27            wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck2
     C                   endif
     *
     *  Verify Slot
     *
     C                   exsr      clr$slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1whdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w2disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      drizm = *off
     C                   exsr      zzzdricop
     *
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm04
     C                   goto      endck2
     C                   endif
     *
     C                   exsr      zzzd2s
     *
     *    Scanned slot not active.
     C                   if        $slstat <> 'A '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm2007
     C                   goto      endck2
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
500 A*
500 A*  Both qtys can not be less than or equal to 0.
500 A*
500 AC                   if        w3qty <= 0 and w3qty2 <= 0
500 AC                   eval      error = *on
500 AC                   eval      *in21 = *on
500 AC                   eval      *in22 = *on
500 AC                   eval      *in01 = *on
500 AC                   eval      errmsg = 'At least one quantity'
500 AC                   exsr      zm0110
500 AC                   endif
     *
500 M*  Quantity can not be less than 0.
     *
500 MC                   if        w3qty < 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Quantity'
     C                   exsr      zm0109
     C                   endif
500 A*
500 A*  Quantity 2 can not be less than 0.
500 A*
500 AC                   if        w3qty2 < 0
500 AC                   eval      error = *on
500 AC                   eval      *in23 = *on
500 AC                   eval      *in03 = *on
500 AC                   eval      errmsg = 'Quantity 2'
500 AC                   exsr      zm0109
500 AC                   endif
500aA*
500aA*  Catchweight can not be less than 0.
500aA*
500aAC                   if        w3cwtr < 0 and $itcwgt = 'Y'
500aAC                   eval      error = *on
500aAC                   eval      *in24 = *on
500aAC                   eval      *in04 = *on
500aAC                   eval      errmsg = 'Weight'
500aAC                   exsr      zm0109
500aAC                   endif
     *
     *  Adjustment code cannot be blank
     *
     C                   if        w3code = ' '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Adjustment code cannot be blank'
     C                   exsr      zm0105
     C                   endif
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse.
     *
416aD**         ROW#      WHEQ 7
416aMC                   when      row# = 2
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *R         FILUKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain     recordu                            79
     *
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
     C     *in79         cabeq     *on           endgtn
     C                   if        slstat <> 'A '
     C                   goto      try1
     C                   endif
     *
     C     endgtn        endsr
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
     C     *in79         cabeq     *on           endgtp
     C                   if        slstat <> 'A '
     C                   goto      try2
     C                   endif
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   eval      w2disp = *blanks
     *   Change priority from negative to positive.
     *
     C                   eval      w1prty = -(slprty)
     *
     *   Expiration date
     *
     C                   eval      svexpd = slexpd
     C                   if        slexpd = 0
     C                   eval      w1expd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     C                   endif
     *
     *   Entered date
     *
     C                   if        slentd = 0
     C                   eval      w1entd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
     C                   endif
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1qty = $pqstr
     *
     *   User
     *
     *R                   MOVELIQADJB    W1ADJB
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     C**                 eval      w1whdp = *zeros
     C                   eval      w1lbl# = 0
     C                   eval      w1upc  = ' '
     C                   eval      w1item = ' '
     C                   eval      *in02 = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   eval      w3qty = 0
500bAC                   eval      w3qty2 = 0
     C                   eval      w3expd = 0
500aAC                   eval      w3cwtr = 0
     C                   if        $itflgd = 'Y'
     C                   eval      *in91 = *on
     C                   else
     C                   eval      *in91 = *off
     C                   endif
500aA*
500aA*    Catchweight item, allow entry of catchweight.
500aAC                   if        $itcwgt = 'Y'
500aAC                   eval      *in68 = *off
500aAC                   else
500aAC                   eval      *in68 = *on
500aAC                   endif
500aA*
     C                   eval      w3code = 'RA'
     C                   eval      w3memo = ' '
500 A
500 A*   Get SSB item, if one exists

500 AC                   move      *off          ssbflg
500 AC                   if        $ittype = ' '
500 AC                   call      'GETSSB'
500 AC                   parm      $itwhse       $gwhse            3 0
500 AC                   parm      $ititem       $gitem           15
500 AC                   parm      ' '           #bitem           15
500 AC                   parm                    #bdesc           30
500 AC                   parm                    #bpdsc           15
500 AC                   parm                    #bwhdp            5
500 AC                   parm                    #bstyp            1
500 AC                   parm                    #bum              2
500 AC                   parm                    #bum2             2
500 AC                   parm                    #bumq2            3 0
500 AC                   parm                    #bum3             2
500 AC                   parm                    #bumq3            3 0
500 AC                   parm                    #brtn             8
     *
500 AC                   if        #brtn = '*FOUND  '
500 AC                   move      *on           ssbflg
500 AC                   endif
500 AC                   endif
500 A
500 A*  Get unit of measure.
500 A
500 AC                   exsr      zzuom

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     C                   eval      curtrn = 0
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   eval      msgtyp = *blanks
     C                   eval      rtvslt = '*NO '
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slstat
     C                   kfld                    slpick
     C                   kfld                    slprty
     C                   kfld                    slexpd
     C                   kfld                    slentd
     C                   kfld                    slwhdp
     C                   kfld                    slstyp
     C                   kfld                    slaisl
     C                   kfld                    slpseq
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    w1whse
     C                   kfld                    #sitem
     C**                 kfld                    w1item
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
     *
     *  Define key for warehouse department.
     *
     C     wdkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     *  Define key for SLOT file.
     *
     C     slkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w2disp
     *
     *  Define key for SLOT2 file. (From slot)
     *
     C     slfkey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    $disp
     *
     *  Define key for SLOT2 file. (To slot)
     *
     C     sltkey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w2disp
     *
     *  Define key for SLOT2 file.
     C     slfiky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    kydisp
     *
     *  Define key for SLOT3 file.
     C     slky3a        klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
     C                   kfld                    keysta
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     *
     C     slky3b        klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
     C                   kfld                    keysta
     C                   kfld                    kypick
     *
     C     uskey         klist
     C                   kfld                    #user
     *
     C     uskey         chain     piruser                            79
     C                   if        not *in79
     C                   eval      w1whse = uswhse
     C                   move      uswhdp        w1whdp
     C                   eval      w1emp# = usemp#
     C                   eval      w1styp = usstyp
     C                   eval      w1shft = usshft
     C                   eval      w1crew = uscrew
     C                   else
     C                   eval      w1emp# = 0
     C                   eval      w1styp = *blanks
     C                   eval      w1shft = *blanks
     C                   eval      w1crew = *blanks
     C                   endif
     *
     C     upckey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1up20
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     *  Convert today's date into century format.
     *
     *  Moved date retrieve code into ZZINZ2 to be done every time
     *  program is called.
     *R                   MOVE '*CURCMD '$CVCMD
     *R                   CALL @CVTDT
     *R                   PARM           $CVTDT
     *R                   Z-ADD$CVD8O    TODAY   80
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      today = $cvd8o
417bA*
417bA*   Get screen size being used.
417bA*
417bAC                   call      'PIRRFSCR'
417bAC                   parm      '*GET'        #lcmd             8
417bAC                   parm                    #lline            2
417bAC                   parm                    #lcol             3
     *
     C                   exsr      clrsch
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCVDT  Convert date to proper format.
     *
     C     zzcvdt        begsr
     *
     *    Convert date into proper format.
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C     endcvd        endsr
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
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   slwhse
     C                   clear                   slitem
     C                   clear                   slstat
     C                   clear                   slpick
     C                   clear                   slprty
     C                   clear                   slexpd
     C                   clear                   slentd
     C                   clear                   slwhdp
     C                   clear                   slstyp
     C                   clear                   slaisl
     C                   clear                   slpseq
     C                   clear                   slrlvl
     C                   clear                   slhand
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = slwhse
     C                   eval      ukwhdp = slwhdp
     C                   eval      ukdisp = sldisp
     C                   eval      ukitem = slitem
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
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
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
     *
     *  Update transaction record.
     *
     C                   call      @adjt2
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype            8
     C                   parm                    @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm                    #user
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *  Start Idle Task.
     *
     C                   call      @adjt2
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype
     C                   parm      0             @ptrn#
     C                   parm      'IDLE'        @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm                    #user
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     C     endabr        endsr
     *----------------------------------------------------------------
     *
     *  ZZSLCT   Select a slot for replenishment.
     *
     C     zzslct        begsr
     *
     C                   eval      w2disp = ukdisp
     C                   exsr      zzchk2
     C     error         cabeq     *on           endslc
     C     cancel        cabeq     *on           endslc
     *
     C                   eval      $disp = sldisp
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C     endslc        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
500 A*           Note: Program does not allow Breakdown2.
500 A*
500 AC     zzuom         begsr
     C                   eval      *in95 = *off
     C                   eval      *in96 = *off

     C                   eval      wouom1 = *blanks
     C                   eval      wouom2 = *blanks

     *   Get Unit of Measures.
     *    *IN95=Protect & non-display breakdown1 unit of measure
     *    *IN96=Protect & non-display breakdown2 unit of measure

     C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in95 = *on
     C                   endif
     C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in96 = *on
     C                   endif
     *
     C                   if        $ittype = 'S'
     C     $itum2        chain     unmesr
     C                   else
     C     $itum1        chain     unmesr
     C                   endif
     C                   if        %found
     C                   eval      wouom1 = umshrt
     C                   else
     C                   eval      wouom1 = *blanks
     C                   endif
     *
     C                   if        not *in95
     C                   if        $ittype = 'S'
     C     $itum3        chain     unmesr
     C                   else
     C     $itum2        chain     unmesr
     C                   endif
     C                   if        %found
     C                   eval      wouom2 = umshrt
     C                   else
     C                   eval      wouom2 = *blanks
     C                   endif
     C                   endif
     *
     C*                  if        not *in96
     C*    $itum3        chain     unmesr
     C*                  if        %found
     C*                  eval      wouom3 = umshrt
     C*                  else
     C*                  eval      wouom3 = *blanks
     C*                  endif
     C*                  endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     C                   if        w1upc <> *blanks
     C                   eval      w1item = upitem
     C                   endif
     *
     *    Capture date/time user entered program to be used
     *    for starting transaction. This will more accurately
     *    reflect when the process started.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      trndte = $cvd8o
     C                   time                    trntim
     *
     *   Get item description.
     *
     C                   eval      woitem = %trim(w1item) + ' - ' + $itdesc
     C                   eval      w1whdp = $itwhdp
     *
     *   Get slot item.
     *
     C                   if        $ittype = 'A'  or
     C                             $ittype = 'C'  or
     C                             $ittype = 'S'
417mMC                   call      'GETSLOTITM'
417mAC                   parm      $itwhse       $gwhse            3 0
417mAC                   parm      $ititem       $gitem           15
417mAC                   parm      ' '           #sitem
417mAC                   parm                    #sityp            1
417mAC                   parm                    #sdesc           30
417mAC                   parm                    #spdsc           15
417mAC                   parm                    #srtn            10
417mAC                   parm                    #smsg            60
     C                   parm      '*END    '    $lcmd
     C                   else
     C                   eval      #sitem = $ititem
     C                   endif
     *
     *  Create/Start transaction
     *
     C                   call      @adjt2
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype
     C                   parm      0             @ptrn#
     C                   parm      'PUTRTN'      @ptask
     C                   parm      slwhse        @pwhse
     C                   parm      slwhdp        @pwhdp
     C                   parm      slstyp        @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
     C                   parm      'R'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      trndte        @pdate
     C                   parm      trntim        @ptime
     C                   parm                    #user
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     C                   if        @prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = @pmsg
     C                   exsr      zmqmsg
     C                   goto      endup1
     C                   endif
     *
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 2.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *  Update slot quantity, create adjust and label records.
     *
     C                   exsr      clr$slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1whdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w2disp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1item
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1item
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w3code
     C                   eval      $samemou = *on
     C                   eval      $samemo  = w3memo
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = w3qty
500 AC                   eval      $saqty2  = w3qty2
500aA*
500aA*  Catchweight item, send weight entered by user.
500aAC                   if        $itcwgt = 'Y'
500aAC                   eval      $sacwtau = *on
500aAC                   eval      $sacwta  = w3cwtr
500aAC                   else
500aAC                   eval      $sacwtau = *off
500aAC                   eval      $sacwta  = 0
500aAC                   endif
500aA*
     C                   eval      $satrn#  = @ptrn#
     C                   eval      $satask  = @ptask

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLSRCVADJ'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      drizm = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endup3
     C                   endif
     *
     *  Update transaction record.
     *
     C                   eval      @ppcs  = w3qty
     C                   eval      @pcube = w3qty * $itcube
     C                   eval      @pswgt = w3qty * $itswgt

500 AC                   if        w3qty2 <> 0
500 AC                   eval      @ppcs  = @ppcs + w3qty2
500 AC                   if        $itcube > 0
500 AC                   eval      @pcube = @pcube +
500 AC                                      (w3qty2 * ($itcube / $itumq2))
500 AC                   endif
500 AC                   if        $itswgt > 0
500 AC                   eval      @pswgt = @pswgt +
500 AC                                      (w3qty2 * ($itswgt / $itumq2))
500 AC                   endif
500 AC                   endif

     C                   call      @adjt2
     *
     C                   parm      '*INCTTL'     @pcmd
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype
     C                   parm                    @ptrn#
     C                   parm      ' '           @ptask
     C                   parm      0             @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm                    @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm                    #user
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *  Close transaction.
     *
     C                   call      @adjt2
     C                   parm      '*CLOSE'      @pcmd
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype
     C                   parm                    @ptrn#
     C                   parm      ' '           @ptask
     C                   parm      0             @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm                    #user
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *  Start Idle Task.
     *
     C                   call      @adjt2
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*BATCH'      @ptype
     C                   parm      0             @ptrn#
     C                   parm      'IDLE'        @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      ' '           @pwhdp
     C                   parm      ' '           @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      0             @pdate
     C                   parm      0             @ptime
     C                   parm                    #user
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C     endup3        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *     ZZZD2S - Copy data structure fields into slot fields.
     *----------------------------------------------------------------

     C     zzzd2s        begsr

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = $slwhdp
     C                   eval      sldisp = $sldisp
     C                   eval      slaisl = $slaisl
     C                   eval      slloc  = $slloc
     C                   eval      slrlvl = $slrlvl
     C                   eval      slhand = $slhand
     C                   eval      slside = $slside
     C                   eval      slstyp = $slstyp
     C                   eval      slstat = $slstat
     C                   eval      slsdte = $slsdte
     C                   eval      slstim = $slstim
     C                   eval      slsdef = $slsdef
     C                   eval      sldesg = $sldesg
     C                   eval      slactv = $slactv
     C                   eval      slbld  = $slbld
     C                   eval      slpick = $slpick
     C                   eval      slpseq = $slpseq
     C                   eval      slprty = $slprty
     C                   eval      slentd = $slentd
     C                   eval      slexpd = $slexpd
     C                   eval      slslfd = $slslfd
     C                   eval      slrsrv = $slrsrv
     C                   eval      slitem = $slitem
     C                   eval      slstk1 = $slstk1
     C                   eval      slstk2 = $slstk2
     C                   eval      slstk3 = $slstk3
     C                   eval      slalc1 = $slalc1
     C                   eval      slalc2 = $slalc2
     C                   eval      slalc3 = $slalc3
     C                   eval      sltfr1 = $sltfr1
     C                   eval      sltfr2 = $sltfr2
     C                   eval      sltfr3 = $sltfr3
     C                   eval      slpck1 = $slpck1
     C                   eval      slpck2 = $slpck2
     C                   eval      slpck3 = $slpck3
     C                   eval      slrcv1 = $slrcv1
     C                   eval      slrcv2 = $slrcv2
     C                   eval      slrcv3 = $slrcv3

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

500 AC                   if        $dricommand = '*ITEM'
500 AC                   call(e)   'DRICOP'
500 AC                   parm                    $dricommand
500 AC                   parm                    $drisubcmd
500 AC                   parm                    $drisys2upd
500 AC                   parm      #prog         $driprogram
500 AC                   parm      ' '           $drireturn
500 AC                   parm      ' '           $drimessage
500 AC                   parm                    $dridata
500 AC                   parm                    $dridata2
500 AC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
500 AC                   endif

     C                   select

     C                   when      %error
     C                   if        ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105
     C                   endif

     C                   when      $drireturn <> '*OK'
     C                   if        ck4err = *on
     C                   eval      error = *on
     C                   if        drizm = *on
     C                   exsr      zm0001
     C                   endif
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      ck4err = *off
     C                   eval      drizm = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1
**  OPTLN - Option display line
  1=Select
**  CMDLN - Command display line
F3=Exit F5=Refresh F12=Cancel
**  DESC - Description
Available Quantity
Verify Zero
Pick slot not allowed for replenishment.
1=Select can be used only once.
Slot error logged for slot:
