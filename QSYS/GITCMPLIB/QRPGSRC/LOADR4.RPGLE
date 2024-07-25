      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LOADR4    Pallet Entry Screen - Loader Module
     *  May 24, 2006
     *  Jose Duque
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/11/08  RBD  5.20    P#00060
     *      - Enh: Added client custom code support to program.
     *
530 A*    01/26/10  RBD  5.30
     *      - Converted to ILE.
     *      - Enh: Create a new LOAD transaction record for each
     *        pallet loaded.
     *
530aA*    06/24/10  RBD  5.30a
     *      - Fix: Trailer id on screen changed from 6 bytes to 8.
     *        Changed scrn fmt from LOADR4FM to LOADR401.
     *
530bA*    07/08/10  RH   5.30b
     *      - Enh: Display dock door assinged in truck builder.
     *
530cA*    07/27/10  RBD  5.30c
     *      - Fix: Added route id to keys HDRKEY and DTLKY2.
     *
640 A*    02/21/11  JGD  6.40
     *      - Enh: Modify error message displayed when loading
     *      - Enh: a pallet on the wrong trailer, now besides
     *      - Enh: displaying the error message, it displays
     *      - Enh: also the right trailer number.
640aA*    06/05/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    08/18/14  RBD  6.50a
     *      - Fix: Need to reset $pltid if user changes pallet id
     *        and also verify the new pallet entered.
650bA*    01/20/15  RBD  6.50b
     *      - Recompiled, LDRDETL and LDRDTLBK files changed.
     *
710aA*    01/20/17  RBD  7.10a
     *      - NOT recompiled, notes only.  Loadr9 logic was changed
     *        to call ADJTRAN2 ... did not bother to make the same
     *        change in this program because loaders would never be
     *        be using this program to load pallets.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  City Line
     *
CLD A*    07/11/08  RBD  CLD     P#00060
     *      - Added logic to require pallet loading in pallet id seq.
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Halsey
     *
HSY A*    04/27/10  RH   HSY
     *      - Added logic to require pallet loading in pallet id seq.
     *      - Added to CLD mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Coastal
     *
CSP A*    08/18/14  RBD  CSP
     *      - Added logic to require pallet loading in pallet id seq.
     *
CSPaA*    08/25/16  RBD  CSPa
     *      - Reverse mod CSP, allow pallets to be loaded in any order.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  60        Display product temps at item level.
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530aDF*Loadr4fm  cf   e             workstn
530aMFLoadr401  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
     Fpiruser1  if   e           k disk
     F                                     rename(usrec:usrec1)
     Fequip     if   e           k disk
     Fordh1     if   e           k disk
     Frtehed    if   e           k disk
530bAFDocmtrx2  if   e           k disk
     FLdrhdr    uf   e           k disk
     FLdrdetl   uf   e           k disk
     FLdrdtlbk  uf a e           k disk
530 AFpirtran   o  a e           k disk
530 AFtask      if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
640 DD*desc            s             70    dim(4) ctdata perrcd(1)
640 MD desc            s             70    dim(5) ctdata perrcd(1)
     *----------------------------------------------------------------
520 A*  Client ID's
     *
CLD A /COPY QCOPYSRC,ID#CITYLIN
HSY A /COPY QCOPYSRC,ID#HALSEY
CHY A /COPY QCOPYSRC,ID#CHENEY
CSP A /copy qcopysrc,id#coastal
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pwhse                 1      3  0
     D  $prte#                 4      8
     D  $prtid                 9     13
     D  $pltid                14     20  0
     D  $plstd                21     26  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
530 A*  Data structure for time calculations
     *
530 AD                 ds
530 AD  dshms                  1      6  0
530 AD  dshm                   1      4  0
530 AD  dshh                   1      2  0
530 AD  dsmm                   3      4  0
530 AD  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
     *
     D                 ds
     D  dsmisc                 1     20
     D  dssdte                 1      8
     D  dsspcl                 9     11
     D  dsrpck                12     12
     D  dsdoor                13     14
     D  dsmeat                15     15
     D  dscode                16     16
     D  dsrvs                 19     19
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
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D fname           s             12
     D help            s              5  0
     D hldtrl          s              8
     D lname           s             16
     D msgk            s              4  0
     D nxtscr          s              3
     D pstrd           s              8  0
     D pstrt           s              6  0
     D p1              s              2  0
     D p2              s              2  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtid            s              5
     D sclear          s              1
530 AD timlen          s                   like(ptdmin)
530 AD tmpbeg          s              4  0
530 AD tmpend          s              4  0
     D warn            s              1
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
650aAD w1plt#7         s              7  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $dtlid            5
     C                   parm                    $pstrd            8
     C                   parm                    $pstrt            6
     C                   parm                    $pprg            10
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz1
     *
     C                   if        $prtn = 'PLTOUT  '
     C                   exsr      sc1
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     *
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   seton                                        lr
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
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     windw4                               50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       1314
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                         2526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       36
     C                   setoff                                       98
     *
     C                   if        $prtn <> 'VIEW    '
     C                   setoff                                       90
     C                   endif
     *
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     *
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen1
     *
     *----------------------------------------------------------------
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     C                   if        $prtn = 'VIEW    '
     C                   goto      endsc1
     C                   endif
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     *
     C     dtlkey        chain     ldrdetl                            79
     C                   if        not *in79
     *
     C                   if        ldstrd = *zeros
     *
     * Get current date in century format
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ldstrd = $cvd8o
     *
     C                   time                    ldstrt
     C                   endif
     *
     C                   setoff                                       13
     C                   if        w1trl# <> *blanks  or
     C                             $prtn = 'PLTOUT  '
     *
     * Get current date in century format
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ldendd = $cvd8o
     *
     C                   time                    ldendt
     C                   seton                                        13
     C                   endif
     *
     *  Get loader emp#
     *
     C     #user         chain     piruser                            79
     C                   if        not *in79
     C                   eval      ldemp# = usemp#
     C                   endif
     *
     C                   if        $prtn = 'PLTOUT  '
     *
     *   Backup Pcs and Cubes from pallet being outed to be used
     *   in the event of an unload due to wrong outed pallet.
     C     dtlkey        chain     ldbrec                             78
     C                   if        not *in78
     C                   eval      ldbcub = ldcube
     C                   eval      ldbpcs = ldpcs
     C                   update    ldbrec
     C                   else
     C                   eval      ldbwhs = ldwhse
     C                   eval      ldbrti = ldrtid
     C                   eval      ldbrte = ldrte
     C                   eval      ldbpli = ldplid
     C                   eval      ldbcub = ldcube
     C                   eval      ldbpcs = ldpcs
     C                   write     ldbrec
     C                   endif
     *
     C                   eval      ldcube = *zeros
     C                   eval      ldpcs = *zeros
     C                   endif
     *
     C                   update    lddrec
     *
530 A *  This pallet has now been loaded, so go create a LOAD transaction.
      *
530 AC                   if        $prtn <> 'PLTOUT  '
530 AC                   exsr      zzCrtTrn
530 AC                   endif
     *
     C                   endif
     *
     C                   eval      $prtn = '*OK     '
     *----------------------------------------------------------------
     *
     *  Check if all pallets are laoded for this route to
     *  record its ended date and time in the header record.
     *
     C                   if        *in13
     C                   seton                                        12
     C     dtlky2        setll     ldrdetl
     C     dtlky2        reade     ldrdetl                                79
     C                   dow       not *in79
     C                   if        ldendd = *zeros
     C                   setoff                                       12
     C                   leave
     C                   endif
     C     dtlky2        reade     ldrdetl                                79
     C                   enddo
     *
     C                   if        *in12
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   eval      lhendd = $cvd8o
     C                   time                    lhendt
     C                   eval      lhstat = '3'
     C                   update    lhrec
     C                   endif
     C                   endif
     *
     C                   endif
     *----------------------------------------------------------------
     C                   eval      nxtscr = 'EOJ'
     *
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
520 A*  Get Client ID
     *
520 AC                   call      @getcl
520 AC                   parm                    client           10
     *
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
     *   Call user added initialization routine.
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------
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
     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *
     *---------------------------------------------------------------
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZMPMSG  Add message record to subfile
     *
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
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     *---------------------------------------------------------------
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     *---------------------------------------------------------------
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
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
     *      PIR0105 Generic message
     *
     *----------------------------------------------------------------
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *    PIR0203  Value cannot be blank.
     *
     *----------------------------------------------------------------
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
530 AC*   PIR7971  Error in writing a record.
530 AC*
530 AC     ZM71          BEGSR
     C                   MOVE      'PIR7971'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMPMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     *----------------------------------------------------------------
     C     zzchk1        begsr
     C                   eval      error = *off
     C                   eval      errmsg = *blanks
     *
     C                   if        $prtn = 'PLTOUT  '
     C                   goto      endck1
     C                   endif
     *
     *          Verify pallet id in case they changed it from what
     *          was passed in.
     *
650aAC                   eval      w1plt#7 = w1plt#
650aAC     dtlky4        chain(n)  ldrdetl
650aAC                   if        not %found
     *
     *          Validate pallet id
     *
650aDC**                 if        w1plt# <> $pltid
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      endck1
     C                   endif
650aA*
650aAC                   eval      $pltid = w1plt#
     *
CLD AC                   select
     *
HSY AC*                  when      client = cityln
CLD AC                   when      client = cityln or
HSY AC                             client = halsey
CSPaDC**                           client = coastl
CLD AC                   eval      *in77 = *off
CLD AC     dtlkey        setll     ldrdetl
CLD AC     dtlky3        readpe(n) ldrdetl                                77
CLD AC                   if        *in77
CLD AC                   else
CLD AC                   if        ldstrd = 0
CLD AC                   eval      error = *on
CLD AC                   eval      *in26 = *on
CLD AC                   if        errmsg = *blanks
CLD AC                   movea     desc(4)       errmsg
CLD AC                   exsr      zm0105
CLD AC                   endif
CLD AC                   goto      endck1
CLD AC                   endif
CLD AC                   endif
     *
CLD AC                   endsl
     *
     *          Validate input trailer#
     *
     C                   movel     w1trl#        hldtrl
     *
     C     trlkey        chain     equip                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
     C                   goto      endck1
     C                   endif
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     C                   if        hldtrl <> lhtrlr
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
640 DC*                  movea     desc(3)       errmsg
640 AC     desc(5)       cat       lhtrlr:1      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     C     endck1        endsr
     *
     *----------------------------------------------------------------
530 AC*  zzCrtTrn  Create LOAD transaction record.
530 AC*
530 AC     zzCrtTrn      BEGSR
     C*
     *  Get transaction #
     C                   call      'PIRTRN#'
     C                   parm      0             pttrn#            7 0
     C                   eval      ptstat = '4'
     C                   eval      pttask = 'LOAD'
     C     pttask        chain     task
     C                   if        %found(task)
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   else
     C                   eval      ptcat = ' '
     C                   eval      ptsub = ' '
     C                   endif
     C                   eval      ptwhse = ldwhse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = ldemp#
     C                   eval      ptcube = ldcube
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = ldpcs
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = ldstrd
     C                   eval      ptstim = ldstrt
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptedte = ldendd
     C                   eval      ptetim = ldendt
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = ldendd
     C                   eval      ptctim = ldendt
     C                   eval      ptrtpo = ldrtid
     C                   eval      ptgrp1 = *blanks
     C                   eval      ptgrp2 = *blanks
     * Calc direct/indirect time
     C                   exsr      zzTime
     C                   write     ptrec                                79
     C     *in79         ifeq      '1'
     C                   move      '1'           error
     C                   exsr      zm71
     C                   goto      endcrtt
     C                   endif
640aAc                   exsr      zzwrttrand
     C*
     C     endcrtt       endsr
     C*
     *----------------------------------------------------------------
     *
     *  ZZFNAM   Format loader name.
     *
     *----------------------------------------------------------------
     C     zzfnam        begsr
     *
     C                   eval      w1user = *blanks
     C                   eval      fname = *blanks
     C                   eval      lname = *blanks
     *
     C                   if        $prtn = 'VIEW    '
     C                   move      ldemp#        w1ldr#
     C                   else
     C                   move      usemp#        w1ldr#
     C                   endif
     C     ' '           scan      usfnam        p1
     C     p1            subst     usfnam:1      fname
     C     ' '           scan      uslnam        p2
     C     p2            subst     uslnam:1      lname
     C     fname         cat       lname:1       w1user
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     *  Define key for main file.
     *
     C     trlkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    hldtrl
     *
     C     rcdeky        klist
     C                   kfld                    $pwhse
     *
     C     hdrkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte#
530cAC                   kfld                    $prtid
     *
     C     dtlkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte#
     C                   kfld                    rtid
     C                   kfld                    $pltid
     *
650aAC     dtlky4        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    $prte#
650aAC                   kfld                    rtid
650aAC                   kfld                    w1plt#7
     *
     C     dtlky2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte#
530cAC                   kfld                    $prtid
     *
CLD AC     dtlky3        klist
CLD AC                   kfld                    $pwhse
CLD AC                   kfld                    $prte#
CLD AC                   kfld                    rtid
     *
     C     rtkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C     ohkey         klist
     C                   kfld                    rhpbat
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
530b C     dckey         klist
530b C                   kfld                    $pwhse
530b C                   kfld                    $prtid
     *
     C                   eval      w1rte# = $prte#
     C                   move      $pstrd        pstrd
     C                   move      $pstrt        pstrt
     *
     C                   if        $dtlid = *blanks
     C                   eval      rtid = $prtid
     C                   else
     C                   eval      rtid = $dtlid
     C                   endif
     *
     C                   if        $prtn = 'PLTOUT  '
     C                   goto      endinz
     C                   endif
     *
     C                   if        $prtn = 'VIEW    '
     C                   z-add     $pltid        w1plt#
     C                   seton                                        9091
     *
     C     dtlkey        chain(n)  ldrdetl                            7978
     *
     * Check if record is in use
     C                   if        *in78
     C                   eval      $prtn = '*LOCKED '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endinz
     C                   endif
     *
     C                   if        not *in79
     C     ldemp#        chain     piruser1                           79
     C                   if        not *in79
     C                   exsr      zzfnam
     C                   endif
     C                   else
     C                   eval      w1ldr# = *zeros
     C                   endif
     *
     C     hdrkey        chain(n)  ldrhdr                             79
     C                   if        not *in79
     C                   movel     lhtrlr        w1trl#
     C                   endif
     *
     C                   else
     C     #user         chain     piruser                            79
     C                   if        not *in79
     C                   exsr      zzfnam
     *
     * If want pallet to show
     C                   z-add     $pltid        w1plt#
     C                   eval      w1trl# = *blanks
     C                   seton                                        27
     C                   endif
     *
     * Check if record is in use
     C     dtlkey        chain     ldrdetl                            7978
     C                   if        *in78
     C                   eval      $prtn = '*LOCKED '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endinz
     C                   endif
     *
     C                   endif
     *
     *  Get loading door number
     C                   eval      w1door = *blanks
     C     rtkey         chain     rtehed                             79
     C                   if        not *in79
     *
530b C                   select
530bAC                   when      client = cheney
     C     ohkey         setll     ordh1
     C     ohkey         reade     ordh1                                  79
     C                   if        not *in79
     C                   eval      dsmisc = ohmisc
     C                   movel     dsdoor        w1door
     C                   endif
530bAC                   other
530bAC     dckey         setll     docmtrx2
530bAC     dckey         reade     docmtrx2                               79
530bAC                   if        not *in79
530bAC                   move      dmdoor        w1door
530bAC                   endif
530bAC                   endsl
     C                   endif
     *
     C     bypas1        tag
     C                   eval      nxtscr = '01 '
     C     endinz        endsr
     *----------------------------------------------------------------
530 A*
530 A*  ZZTIME   Calculate direct/indirect time
530 A*
530 AC     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = ptstim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = ptetim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        ptetim < ptstim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     pttask        chain     task
     C                   if        not %found(task)
     C                   eval      ptimin = 0
     C                   eval      ptdmin = 0
     C                   goto      endtim
     C                   endif
     C                   if        tktype = 'I'
     C                   eval      ptimin = timlen
     C                   eval      ptdmin = 0
     C                   else
     C                   eval      ptdmin = timlen
     C                   eval      ptimin = 0
     C                   endif
     *
     C     endtim        endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  DESC
Invalid pallet Id
Valid trailer #
Trailer # is not the one originally assigned                           6
Cannot load plt out of seq, prior plt not loaded
Wrong trailer #, the right trailer # is                                6
