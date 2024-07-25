     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LOADR2    Loader Assignment - Loader Module
     *  May 24, 2006
     *  Jose Duque
     *
     *  Revisions:
     *
520 A*    07/17/08  RBD  5.20    P#00060
     *      - Enh: Added client custom code support to program.
     *
530 A*    06/23/10  JCJ  5.30
     *      - Enh: Converted to RPG4.
     *      - Enh: Recompiled - Increase W1TRL# field size from 6 to 8.
     *
530bA*    07/08/10  RH   5.30b
     *      - Enh: Display dock door assinged in truck builder.       .
     *
640 A*    02/17/11  JGD  6.40
     *      - Enh: Add F4 prompt key to display a list of existing
     *        Enh: trailers numbers. Also revision of the error
     *        Enh: message routine that warn the user when asigning
     *        Enh: a trailer already used by another route. Change
     *        Enh: Dspf name to Loadr201.
     *
650aA*    01/17/14  RBD  6.50a
     *      - Enh: Added add-on route functionality by changing logic to
     *        allow a trailer to be assigned to multiple routes if the
     *        routes are all part of the same parent/child merge in the
     *        Trax merge file. Client does not have to be a Trax user.
     *
750aA*    03/01/22  RBD  7.50a
     *      - Fix: replaced logic where whse was hardcoded as 1 to
     *        whse from plist instead.
770aA*    09/08/23  RH   7.70a
     *      - Enh: Non-display Loader # and name, loader in header
     *        LDRHDR is who assigned trailer, pallet loader is in
     *        LDRDETL detail file. Display for Cheney only.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Cheney
     *
CBI A*    07/17/08  RBD  CBI     P#00060
     *      - Revised hardcoded reason code logic as specific
     *        to Cheney.
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
     FLoadr201  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
     Fpiruser1  if   e           k disk
     F                                     rename(usrec:usrec1)
     Fequip     if   e           k disk
     FLrsncode  if   e           k disk
     FLdrhdr    if   e           k disk
     FLdrhdr2   if   e           k disk
     F                                     rename(lhrec:lhrec2)
     FLdrexcp2  if   e           k disk
     Fordh1     if   e           k disk
     Frtehed    if   e           k disk
530bAFDocmtrx2  if   e           k disk
650aAFttmerg    if   e           k disk
650aAFttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             70    dim(15) ctdata perrcd(1)
     *----------------------------------------------------------------
520 A*  Client ID's
     *
CBI A /COPY QCOPYSRC,ID#CHENEY
     *
     D @getcl          c                   const('GETCLIENT')
640 a*----------------------------------------------------------------
640 A*  Partial key redifinition
640 A*
640 AD $prtky          ds
640 AD $len50                  1     50
640 AD  $kwhse                 1     30
640 AD  $kcode                 4      9
     *----------------------------------------------------------------
     *  Program parameters
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D  $lcode                22     23
     *
640 AD  $ltcode               22     29
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
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
650aAd AssignedRtPar   s                   like(ttmpri)
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D fname           s             12
     D help            s              5  0
     D hldtrl          s              8
650aAd kyrtid          s                   like(ttmpri)
     D lname           s             16
     D msgk            s              4  0
     D nxtscr          s              3
     D one             s              2  0
650aAD ParentChild     s              1
     D pstrd           s              8  0
     D pstrt           s              6  0
     D p1              s              2  0
     D p2              s              2  0
     D rolldn          s              5  0
     D rollup          s              5  0
650aAd sav_ttmpri      s                   like(ttmpri)
     D sclear          s              1
     D warn            s              1
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
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prte#            5
     C                   parm                    $prtid            5
     C                   parm                    $pstrd            8
     C                   parm                    $pstrt            6
     C                   parm                    $ptlr#            8
     C                   parm                    $pemp#            5
     C                   parm                    $pprg            10
     C                   parm                    $paorc            1
     C                   parm                    $pcom1           35
     C                   parm                    $pcom2           35
     C                   parm                    $prcde            2
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz1
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc1
     C     nxtscr        caseq     '04 '         sc1
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
     C                   exfmt     windw1                               50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     windw2                               50
     C                   endif
     *
     C                   if        nxtscr = '04 '
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
CBI AC                   if        client = cheney
770aAC                   eval      *in55 = *off
770aAC                   eval      w1LDRO = 'Loader:'
770aAC                   else
770aAC                   eval      *in55 = *on
770aAC                   endif
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
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     *
     C                   eval      $prtn = '*OK     '
     *
     C                   eval      nxtscr = 'EOJ'
     *
     *
     C     endsc1        endsr
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
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
     C                   move      usemp#        w1ldr#
     C                   move      usemp#        $pemp#
     C     ' '           scan      usfnam        p1
     C     p1            subst     usfnam:1      fname
     C     ' '           scan      uslnam        p2
     C     p2            subst     uslnam:1      lname
     C     fname         cat       lname:1       w1user
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
     *
520 A*  Get Client ID
     *
520 AC                   call      @getcl
520 AC                   parm                    client           10
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
     *      PIR0105 Gneric message
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     *----------------------------------------------------------------
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Window1 and Window2 error checking.
     *
     *----------------------------------------------------------------
     C     zzchk1        begsr
     *
     C                   eval      error = *off
     C                   eval      errmsg = *blanks
     *
     *  Check if user id is found in user file.
     *
     C     #user         chain     piruser                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   movea     desc(15)      errmsg
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     *          Validate comments only if Unloading trailer.
     *
     C                   if        $paorc = 'U'
     C                   goto      chkcom
     C                   endif
     *
     *          Validate input trailer# if in assign route mode.
     *
     C                   if        $paorc = 'A'
     C                   exsr      zztrlr
     C                   goto      load
     C                   endif
     *
     *
     *          Check input data, pgm is in change mode
     *
     C                   if        w1ldr2 = *zeros  and
     C                             w1trl# = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in27 = *on
     C                   eval      *in01 = *on
     C                   movea     desc(4)       errmsg
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     *          Disp error msg if loader & trailer didn't change
     *
     C                   if        w1ldr2 = *zeros  and
     C                             w1trl# = $ptlr#
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in27 = *on
     C                   eval      *in01 = *on
     C                   movea     desc(12)      errmsg
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     C                   if        w1ldr2 <> *zeros
     C     w1ldr2        chain     piruser1                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0203
     C                   endif
     C                   endif
     C                   endif
     *
     *          Validate input trailer#
     *
     C                   exsr      zztrlr
     *
     *          Validate reason code
     *
     C                   if        w1rcde = '7'  and
     C                             $paorc <> 'U'  and
CBI AC                             client = cheney
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      *in24 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(14)      errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *
     C     rcdeky        chain     lrsncode                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in25 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
     C                   endif
     *
     *          Make sure it is the right reason code
     *          (Trailer change code is '4')
     *          (Trailer and Loader change code is '6')
     *
CBI AC                   select
CBI AC                   when      client = cheney
     *
     C                   if        w1trl# <> $ptlr#  and
     C                             w1ldr2 = *zeros  and
     C                             w1rcde <> '4'  and
     C                             w1rcde <> '5'
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in25 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(8)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     C                   if        w1rcde >= '4'  and
     C                             w1rcde <= '6'  and
     C                             w1trl# = $ptlr#
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in25 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(11)      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     C                   if        w1trl# <> $ptlr#  and
     C                             w1ldr2 <> w1ldr#  and
     C                             w1ldr2 <> *zeros  and
     C                             w1rcde <> '6'
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in25 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(9)       errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
CBI AC                   endsl
     *
     C     chkcom        tag
     *
     *          Validate comments.
     *
CBI AC                   select
CBI AC                   when      client = cheney
     *
     C                   if        w1rcde = '4'  or
     C                             w1rcde = '7'
     C                   if        w1com1 = *blanks  and
     C                             w1com2 = *blanks
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      *in24 = *on
     C                   eval      *in22 = *on
     C                   if        w1rcde = '7'
     C                   movea     desc(13)      errmsg
     C                   endif
     C                   if        errmsg = *blanks
     C                   movea     desc(6)       errmsg
     C                   endif
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     C                   if        w1rcde = '6'  and
     C                             w1trl# <> $ptlr#  and
     C                             w1ldr2 <> w1ldr#  and
     C                             w1com1 = *blanks  and
     C                             w1com2 = *blanks
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      *in24 = *on
     C                   eval      *in22 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(10)      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
CBI AC                   endsl
     *
     *          If no error, set values to send back to calling pgm
     *
     C     load          tag
     C                   if        error <> *on
     C                   if        w1ldr2 <> *zeros
     C                   move      w1ldr2        $pemp#
     C                   endif
     C                   movel     w1trl#        $ptlr#
     C                   eval      $pcom1 = w1com1
     C                   eval      $pcom2 = w1com2
     C                   eval      $prcde = w1rcde
     C                   endif
     *
     *
     C     endck1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     *----------------------------------------------------------------
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
     *     Warehouse
     *
     C                   select
     C                   when      csrfld = 'W1RCDE'  and
     C                             $paorc <> 'U'
     C                   eval      $lcmd = '*LOOKUP '
750aDC**                 eval      $lwhse = 1
750aMC                   eval      $lwhse = $pwhse
     C                   eval      $lprg = #prog
     C                   eval      $lcode = *blanks
     C                   call      'RC903'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1rcde = $lcode
     C                   if        $lcode = '7'  and
     C                             $paorc <> 'U'  and
CBI AC                             client = cheney
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(14)      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
640 AC     csrfld        wheneq    'W1TRL#'
640 AC     $paorc        andne     'U'
640 AC                   move      '*LOOKUP '    $lcmd
750aDC**                 z-add     1             $lwhse
750aMC                   z-add     $pwhse        $lwhse
640 AC                   movel     $lwhse        $kwhse
640 AC                   move      #prog         $lprg
640 AC                   movel     'TRAILR'      $kcode
640 AC                   move      *blanks       $ltcode
640 AC                   move      '1'           $sort             1
640 AC                   call      'EQ910'
640 AC                   parm                    $prtky
640 AC                   parm                    $lrtn
640 AC                   parm                    $ltcode
640 AC                   parm                    $kcode
640 AC                   parm                    $sort
640 AC     $lrtn         ifeq      '*SELECT '
640 AC                   movel     $ltcode       w1trl#
640 AC     $lcode        ifeq      '7'
640 AC     $paorc        andne     'U'
640 AC                   move      *on           error
640 AC                   move      *on           *in01
640 AC                   move      *on           *in25
640 AC                   move      *blanks       errmsg
640 AC                   movea     desc(14)      errmsg
640 AC                   exsr      zm0105
640 AC                   else
640 AC                   exsr      zztrlr
640 AC                   endif
640 AC                   endif
     *                                                                -----
     C                   other
     *
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
     *  ZZTRLR   Validate trailer.
     *
     *----------------------------------------------------------------
     C     zztrlr        begsr
     *
     C                   movel     w1trl#        hldtrl
     *
     C     trlkey        chain     equip                              79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   if        errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0203
     C                   endif
     C                   goto      endtrl
     C                   endif
     *
     C     trlkey        chain     ldrhdr2                            79
     C                   if        not *in79
     C                   if        w1rte# <> lhrte or
640 AC                             $prtid <> *blanks and
640 AC                             $prtid <> lhrtid
     *
650aA*   In order to allow the same trailer to be assigned to multiple routes,
650aA*   all of the routes must be part of the same parent/child merged route
650aA*   in the Trax merge file.
650aA*
650aA*   Find out if the route which already has the trailer assigned is
650aA*   a Trax merged route, and if so, whether it's the parent or a child.
650aA*
650aAC                   eval      ParentChild = *blanks
650aAC                   eval      kyrtid = lhrtid
650aAC     ttmkey        chain     ttmerg
650aAC                   if        %found(ttmerg)
650aAC                   eval      ParentChild = 'P'
650aAC                   eval      AssignedRtPar = ttmpri
650aAC                   else
650aAC     ttmkey        chain     ttmerg2
650aAC                   if        %found(ttmerg2)
650aAC                   eval      ParentChild = 'C'
650aAC                   eval      AssignedRtPar = ttmpri
650aAC                   endif
650aAC                   endif
650aAC                   if        ParentChild = *blanks
650aAC                   goto      trlrErr
650aAC                   endif
650aA
650aAC                   eval      kyrtid = $prtid
650aA
650aAC                   select
650aA
650aAC                   when      ParentChild = 'P'
650aAC     ttmkey        chain     ttmerg2
650aAC                   if        %found(ttmerg2) and ttmpri = AssignedRtPar
650aAC                   goto      endtrl
650aAC                   endif
650aAC
650aAC                   when      ParentChild = 'C'
650aAC                   if        $prtid = AssignedRtPar
650aAC                   goto      endtrl
650aAC                   endif
650aAC
650aAC                   endsl
650aAC
650aAC     trlrErr       tag
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      *in27 = *on
     C                   eval      errmsg = *blanks
     C     desc(5)       cat       lhrte:1       errmsg
640 AC     errmsg        cat       lhrtid:1      errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif
     *
     *
     C     endtrl        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     *----------------------------------------------------------------
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
     C                   kfld                    w1rcde
     *
     C     hdreky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte#
     C                   kfld                    $prtid
     *
     C     hdrkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte#
     C                   kfld                    $prtid
     C                   kfld                    pstrd
     C                   kfld                    pstrt
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
530bAC     dckey         klist
530bAC                   kfld                    $pwhse
530bAC                   kfld                    $prtid
     *
650aAC     ttmkey        KLIST
650aAC                   KFLD                    $pWHSE
650aAC                   KFLD                    kyrtid
     *
     C                   move      $pstrd        pstrd
     C                   move      $pstrt        pstrt
     C                   eval      w1rte# = $prte#
     C                   eval      w1trl# = *blanks
     C                   eval      w1ldr# = *zeros
     C                   eval      w1user = *blanks
     C                   eval      w1ldr2 = *zeros
     C                   eval      w1rcde = *blanks
     C                   eval      w1com1 = *blanks
     C                   eval      w1com2 = *blanks
     C                   eval      w1reas = *blanks
     C                   eval      errmsg = *blanks
     *
770aA*  Set Header Loader non display
CBI AC                   if        client = cheney
770aAC                   eval      *in55 = *off
770aAC                   eval      w1LDRO = 'Loader:'
770aAC                   else
770aAC                   eval      *in55 = *on
770aAC                   endif
     *
     *
     *  Get loading door number
     C                   eval      w1door = *blanks
     C     rtkey         chain     rtehed                             79
     C                   if        not *in79
     *
530bAC                   select
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
530bAC                   movel     dmdoor        w1door
530bAC                   endif
530bAC                   endsl
     C                   endif
     *
     *  Check if viewing assigned route
     *
     C                   if        $paorc = 'V'
     C                   exsr      zzview
     C                   goto      endinz
     C                   endif
     *
     *
     *
     *  Check if assigning route 1st time or changing route loader
     *
     C                   setoff                                         90
     C                   if        $paorc = 'C'
     C                   movel     $ptlr#        w1trl#
     C                   move      $pemp#        w1ldr#
     C                   eval      nxtscr = '02 '
     C                   goto      bypas1
     C                   endif
     *
     C                   if        $paorc = 'U'
     C                   movel     $ptlr#        w1trl#
     C                   move      $pemp#        w1ldr#
CBI AC                   if        client = cheney
     C                   eval      w1rcde = '7 '
CBI AC                   endif
     C                   eval      nxtscr = '04 '
     C                   goto      bypas1
     C                   endif
     *
     *  Set name of initially assigned loader
     *  assigning loader and trailer 1st time
     *
     C     #user         chain     piruser                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in26 = *on
     C                   movea     desc(15)      errmsg
     C                   exsr      zm0105
     C                   else
     C                   exsr      zzfnam
     C                   endif
     *
     C                   eval      nxtscr = '01 '
     C     bypas1        tag
     *
     C     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZVIEW   Trailer/Loader info (View Mode).
     *
     *----------------------------------------------------------------
     C     zzview        begsr
     *
     *
     C     top           tag
     C                   setoff                                       202124
     C                   seton                                        2990
     C                   eval      one = 1
     *
     C     hdrkey        chain     ldrhdr                             79
     C                   if        not *in79
     *   Load current Trailer/Loader info on screen
     C                   eval      w1rte# = lhrte
     C                   move      lhemp#        w1ldr#
     C                   movel     lhtrlr        w1trl#
     C                   eval      w1timc = lhstrt
     C     lhemp#        chain     piruser1                           78
     C                   if        not *in78
     C                   exsr      zzfnam
     C                   endif
     *
     C                   if        lhstrd = 0
     C                   eval      w1dtec = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lhstrd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1dtec = $cvd6o
     C                   endif
     *
     *
     *
     *   Set read pointer to header exception file 'Ldrexcp2'
     *
     C     hdreky        setll     ldrexcp2
     C                   dow       one = 1
     C                   exfmt     windw3                               50
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   leave
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   leave
     C                   endif
     *
     *   See if this route has any exception record
     *
     C     hdreky        reade     ldrexcp2                               79
     C                   if        *in79  and
     C                             *in29
     C                   eval      error = *on
     *
     C                   if        errmsg = *blanks
     C                   movea     desc(7)       errmsg
     C                   exsr      zm0105
     *
     *   Overlay screen with informative messages
     *
     C                   exsr      zmdmsg
     C                   endif
     C                   goto      doback
     C                   endif
     *
     *   End of exception records.
     *
     C                   if        *in79  and
     C                             not *in29
     C                   setoff                                       28
     C                   goto      top
     C                   endif
     *
     *   Load exception record on screen
     *
     C                   if        not *in79
     C                   seton                                        202128
     C                   seton                                        30
     C                   setoff                                       29
     C                   eval      w1rte# = lerte
     C                   move      leemp#        w1ldr#
     C                   movel     letrlr        w1trl#
     C                   eval      w1time = lestim
     C                   eval      w1com1 = lecom1
     C                   eval      w1com2 = lecom2
     C                   eval      w1rcde = lereas
     C     rcdeky        chain     lrsncode                           79
     C                   eval      w1reas = lrsdsc
     C     leemp#        chain     piruser1                           78
     C                   if        not *in78
     C                   exsr      zzfnam
     C                   endif
     C                   endif
     *
     C                   if        lesdte = 0
     C                   eval      w1dtee = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lesdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1dtee = $cvd6o
     C                   endif
     *
     *
     C     doback        tag
     C                   enddo
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     *----------------------------------------------------------------*********
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *
**  DESC
Valid trailer #                                                           1
Valid reason code                                                         2
Valid employee #                                                          3
Invalid input values, they can not be blanks                              4
Input trailer # is being used by route                                    5
Comment is required when changing trailer                                 6
No exception found for this route                                         7
Trailer changed, reason code must be '4'                                  8
Loader & trailer changed, reason code must be '6'                         9
Comment is required when changing loader & trailer                       10
Wrong reason code, trailer was not changed                               11
Make a change or press F3 or F12 to go to prev screen                    12
Comment is required when unloading trailer                               13
Reason code 7 allowed when unloading trailer only                        14
Rte can't be assigned, user not found in user file                       15
