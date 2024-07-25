      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB390   Runner label - options
     *  16 April 2009
     *  Retha Davis
     *
     *  Revisions
     *
520 A*    04/16/09  RBD  5.20  P#00196
     *      - Created.
530aA*    11/12/10  JCJ  5.30a
     *      - Enh: increase label entry to 10 positions for Trax.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client custom revisions - City Line
     *
CLD A*    04/21/09  RBD  CLD   P#00196
     *      - Pass cmd *PRTLBL and label set BLTCTL to PFMT.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 MFlb39001   cf   e             workstn
530 D * lb390fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Flabel     if   e           k disk
     Foptionz   if   e           k disk
     Fpltsum12  if   e           k disk
     Frtehed    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(3) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------


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
     D  $lwhse                19     21  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem#                1     15
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#cheneyo
      /COPY QCOPYSRC,id#cheneyr
      /COPY QCOPYSRC,id#citylin

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opzdta          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D @plcmd          S              8
     D @plset          S              6
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D kycode          s                   like(opzcod)
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
     D wkwhse          s              3  0
     D work1a          s              1
     D w1whse          s              3  0
     D forevr          s               n
530aAD w1lbl           s              7  0
530aA*----------------------------------------------------------------
530aA*  Called programs
530aA*
530aAD @cvtbarsel      c                   const('CVTBARSEL')
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $label            7 0
     C                   parm                    $dev             10
     C                   parm                    $form            10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
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
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010809
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr

     *----------------------------------------------------------------

     *  getPltsum     Get Pltsum.

     C     getPltsum     begsr

     C     keyps12       chain(e)  pltsum12
     C                   if        not %found(pltsum12)
     C                   eval      pswhse = 0
     C                   eval      pscomp = ' '
     C                   eval      pstruk = ' '
     C                   eval      pstzon = ' '
     C                   eval      psszon = ' '
     C                   eval      psgen  = 0
     C                   endif

     C                   endsr

     *----------------------------------------------------------------

     *----------------------------------------------------------------

     *  getZoneOpts   Get zone options

     C     getZoneOpts   begsr

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain(e)  optionz
     C                   if        not %found(optionz)
     C                   eval      opclvl = *hival
     C                   eval      opcwra = 'N'
     C                   eval      opcwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      optext = ' '
     C                   eval      operr  = 0
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = ' '
     C                   eval      optend = ' '
     C                   endif

     C                   eval      oppdev = w1dev
     C                   eval      oppfrm = w1form

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
     *
     *  Get existing record.
     *
     C                   exsr      zzfil1
     C     end01i        endsr
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
     C                   eval      $prtn = '*EXIT   '
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
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      getPltsum
     C                   exsr      getZoneOpts
     C                   exsr      zzPrint
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   move      *on           forevr
     *
     C                   select

CLD AC                   when      client = cityline
CLD AC                   eval      @plcmd = '*PRTLBL'
CLD AC                   eval      @plset = 'BLTCT2'

     C                   other
     C                   eval      @plcmd = '*PICK'
     C                   eval      @plset = ' '

     C                   endsl
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
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110 - Starting number
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify label
     *
530aMC                   if        w1lbl#b <> *blanks
     * grab label#
530aAC                   move      w1whse        $pwhseb
530aAC                   movel     w1lbl#b       $pbarcode
530aAC                   call      @cvtbarsel
530aAC                   parm                    $pwhseb           3
530aAC                   parm                    $pbarcode        15
530aAC                   parm                    $plbl#            7 0
530aAC                   parm                    $prtid            5
530aAC                   parm                    $punq#            5
530aAC                   parm                    $preturn          8
530aAC                   parm                    $perrmsg         60
530aAC                   if        $preturn = '*OK'
530aAC                   eval      w1lbl  = $plbl#
530aAC                   eval      w1lbl#b = *blanks
530aAC                   move      $plbl#        w1lbl#b
530aAC                   else
530aAC                   eval      error = *on
530aAC                   eval      errmsg = *blanks
530aAC                   eval      *in01 = *on
530aAC                   eval      *in21 = *on
530aAC                   eval      errmsg = desc(1)
530aAC                   exsr      zm1001
530aAC                   endif
530aAC                   endif

     C     w1lbl         chain     label
     C                   if        not %found(label)
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
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
     *     Prompt
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1lbl   = 0
530gAC                   eval      w1lbl#b = *blanks
     *
     C                   eval      w1dev = '*JOB    '
     C                   eval      w1form = '*STD    '
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

     *    OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
     C                   kfld                    pstruk
     C                   kfld                    psszon
     C

     *    PLTSUM12 file.

     C     keyps12       klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     C                   kfld                    lbtrn#
     C                   kfld                    lbpal#

     *    RTEHED file

     C     keyrh         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte

     C                   eval      $pstr  = 'Runner label - options'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPRINT  Print runner label.
     *
     C     zzPrint       begsr
     *
     C     keyrh         chain(e)  rtehed
     C                   if        not %found(rtehed)
     C                   eval      rhtruk = ' '
     C                   eval      rhrte  = ' '
     C                   endif
     *
     C                   call      'PFMT'
     C                   parm      @plcmd        $pcmd             8
     C                   parm      @plset        $plset            6
     C                   parm                    $plfmt            8
     C                   parm                    lbwhse
     C                   parm                    lbrte
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    rhtruk
     C                   parm                    rhrte
     C                   parm                    opzdta
     C                   parm                    lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbqpck
     C                   parm      0             $xcwt             7 2
     *
     C                   eval      w1lbl  = 0
530gAC                   eval      w1lbl#b = *blanks
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Label
Printer device
Form type
