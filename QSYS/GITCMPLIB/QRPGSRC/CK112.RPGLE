650aA /Copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CK112     RF Checker Detail
     *  10 October, 2001
     *  Hemant Kapadia
     *
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *
     *
     *  Revisions
     *    10/10/01  HNK 4.16
     *      - Created
416A *    04/29/02  HNK 4.16A
     *      - REMOVE WOROW AND WOCOL
416b *    05/10/02  HNK 4.16b
     *      - Call GETTPL to get Merge label number.
     *      - Use SVLBL# and SVQPCK to update CHKLBL file.
416C *    06/03/02  HNK 4.16c
     *      - Use SVLBL# for CLKEY.
416d *    06/06/02  HNK 4.16d
     *      - Comment out line that moves $GMPID to W1PLID
416e *    08/02/02  HNK 4.16e
     *      - Use LBQALC instead of LBQPCK.  Merge record for bulk
     *        pick does not have qty in LBQPCK field.
640aA*    08/21/11  JCJ 6.40a
     *      - Converted to RPGIV.
650aA*    02/04/13  RTR 6.40a
     *      - Added check for Trax labels.
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
650aDF**ck112fm   cf   e             workstn
650aMFck11201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     FLabel     if   e           k disk
     FLabel31   if   e           k disk
     Fchklbl1   if   e           k disk
     F                                     rename(clrec:clrec1)
     Fchklbl    uf a e           k disk
     Fchktrn    o  a e           k disk
     Fchkplt    uf a e           k disk
     Fpiritem   if   e           k disk
     Foptionz   if   e           k disk
     Fworklbl   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D desc            s             60    dim(3) ctdata perrcd(1)
     D hnd             s              2    dim(702)
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
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
650aAD @cvtbarsel      c                   const('CVTBARSEL')
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
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $litm                 22     36
     *
     *
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
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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
     D $kcmd           s              8
     D $kcrew          s              6
     D $kemp#          s              5  0
     D $kmsg           s              4
     D $kprg           s             10
     D $kqpck          s              5  0
     D $krtn           s              8
     D $kshft          s              6
     D $kstyp          s              1
     D $kwhdp          s              5
     D $kwhse          s              3  0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D exist           s              1
     D forevr          s              1
     D help            s              5  0
     D kycode          s                   like(opzcod)
     D more            s              1
     D msgk            s              4  0
     D newvs           s              1
     D nxtscr          s              3
     D ovrrid          s              1
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svlbl#          s              7  0
     D svqpck          s              5  0
     D today           s              8  0
     D warn            s              1
     D w1emp#          s              5  0
     D w1lbl#          s              7  0
     D w1plid          s              7  0
     D w1trn#          s              7  0
     D w1whse          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $pwhdp            5
     C                   parm                    $pemp#            5
     C                   parm                    $pshft            6
     C                   parm                    $pcrew            6
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $pplid            7
     C                   parm                    $ppal#            7
     C                   parm                    $prtn             8
     *
     C                   eval      *in99 = *off
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   End current task.
     *
     C                   exsr      zzend
     *
     *   Create idle task.
     *
     C                   exsr      zzidle
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
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
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
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
     C                   eval      refrsh = *on
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
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
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
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
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
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
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
     C                   write     clrscr
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
     *   PIR0105  Invalid slot entered.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT28001  Invalid slot entered.
     *
     C     zm2801        begsr
     C                   eval      #msgid = 'IT28001'
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
     *    PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *   IT11213  Invalid route for item.
     *
     C     zm1213        begsr
     C                   eval      #msgid = 'IT11213'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11214  Invalid pallet for item.
     *
     C     zm1214        begsr
     C                   eval      #msgid = 'IT11214'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11215  Item scan not allowed.
     *
     C     zm1215        begsr
     C                   eval      #msgid = 'IT11215'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11217  Item already scanned.
     *
     C     zm1217        begsr
     C                   eval      #msgid = 'IT11217'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11218  Invalid label number.
     *
     C     zm1218        begsr
     C                   eval      #msgid = 'IT11218'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL16001 No more zero slots.
     *
     C     zm1601        begsr
     C                   eval      #msgid = 'SL16001'
     C                   eval      #msgtp = '*DIAG  '
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
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
650aAC*
650aA*  Convert barcode scanned in case it is Trax
650aAC                   move      w1whse        $pwhseb
650aAC                   movel     w1lbla        $pbarcode
650aAC                   call      @cvtbarsel
650aAC                   parm                    $pwhseb           3
650aAC                   parm                    $pbarcode        15
650aAC                   parm                    $plbl#            7 0
650aAC                   parm                    $prtid            5
650aAC                   parm                    $punq#            5
650aAC                   parm                    $preturn          8
650aAC                   parm                    $perrmsg         60
650aAC                   if        $preturn = '*OK'
650aAC                   eval      w1lbl# = $plbl#
650aAC                   else
650aAC                   eval      error = *on
650aAC                   eval      *in21 = *on
650aAC                   eval      *in01 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movea     desc(3)       errmsg
650aAC                   exsr      zm1001
650aAC                   goto      endck1
650aAC                   endif
650aAC*
650aDC*                  move      w1lbla        w1lbl#
416bAC                   eval      svlbl# = w1lbl#
416bA*  Use the scanned label # to save LBL# and QTY
416bAC     lbkey         chain     label                              79
416bAC                   if        not *in79
416eMC                   eval      svqpck = lbqalc
416eD**                   Z-ADDLBQPCK    SVQPCK  50
416bAC                   else
416bAC                   eval      svqpck = 0
416bAC                   endif
     *
416bA*  If there is a merge label, use merge label.
     *
416bAC                   call      'GETTPLT'
416bAC                   parm      w1lbl#        $glbl#            7 0
416bAC                   parm                    $gtplt            7 0
416bAC                   parm                    $gmlbl            7 0
416bAC                   parm                    $gmpid            7 0
416bAC                   parm                    $gsplt            1
416bAC                   parm                    $glow             1
416bAC                   parm                    $grtn             8
416bAC                   if        $grtn = '*OK     '
416bAC                   eval      w1lbl# = $gmlbl
416dA**                   Z-ADD$GMPID    W1PLID
416bAC                   endif
     *
     *  Invalid item
     *
     C     lbkey         chain     label                              79
     C                   if        not *in79  and
     C                             lbrte <> $prtid
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1213
     C                   endif
     *
     C                   if        not *in79  and
     C                             lbpal# <> w1plid
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1214
     C                   endif
     *  Must be selection record
     C                   if        not *in79  and
     C                             lbgrp1 <> 'S'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1218
     C                   endif
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Error when scanned qty = Total qty.
     *
     C                   if        w1sqty = w1tqty
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1215
     C                   endif
     *
     *  Item already scanned.
     *
     *R         CLKEY     CHAINCHKLBL              N79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN21
     *R                   MOVE *ON       *IN01
     *R                   MOVE *BLANKS   ERRMSG
     *R                   EXSR ZM1217
     *R                   ENDIF
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
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
     C                   if        *inku
     C                   eval      cmdtkn = *on
     C                   exsr      scr03i
     C                   goto      endcm1
     C                   endif
     *
     C                   if        *inkq
     C                   eval      cmdtkn = *on
     C                   call      'CK120CL'
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $pplid
     C                   parm                    $prtn
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *      F10 - Accept Warning.
     *
     C                   if        *inkj
     C                   eval      ovrrid = *on
     C                   else
     C                   eval      ovrrid = *off
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   if        *inku
     C                   eval      cmdtkn = *on
     C                   eval      nxtscr = 'EOJ'
     C                   exsr      zzupd
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *  Total pieces on pallet
     *
     C                   eval      w1tqty = 0
     C     lb3key        setll     label31
     C                   dow       forevr = forevr
     C     lb3key        reade     label31                                79
     C                   if        not *in79
416eMC                   add       lbqalc        w1tqty
416eD**                   ADD  LBQPCK    W1TQTY
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     *  Scanned quantity
     *
     C                   eval      w1sqty = 0
     C     clkey1        setll     chklbl1
     C                   dow       forevr = forevr
     C     clkey1        reade     chklbl1                                79
     C                   if        not *in79
     C                   add       clcqty        w1sqty
     C                   else
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   eval      w1rte = $prte
     C                   move      $ppal#        w1plt
416AAC                   eval      w1lbla = *blanks
416AMC                   eval      w1lbl# = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2rte = $prte
     C                   eval      w2rtid = $prtid
     C                   move      $ppal#        w2plt
416eMC                   eval      w2tqty = lbqalc
416eD**                   Z-ADDLBQPCK    W2TQTY
     C     keyit         chain     piritem                            79
     C                   if        not *in79
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm      ititem        $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      w2itm = *blanks
     C                   movel     $istr         w2itm
     C                   else
     C                   eval      w2itm = *blanks
     C                   endif
     C                   eval      w2qty = 0
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   eval      w3rte = w1rte
     C                   move      w1rtid        w3rtid
     C                   eval      w3plt = w1plt
     C                   eval      w3tqty = w1tqty
     C                   eval      w3sqty = w1sqty
     C     endfl3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      forevr = *off
     *
     *  Define key for LABEL.
     *
     C     lbkey         klist
     C                   kfld                    w1lbl#
     *
     *  Define key for LABEL31
     *
     C     lb3key        klist
     C                   kfld                    w1whse
     *
     *  Define key for CHKLBL.
     *
     C     clkey         klist
416cAC                   kfld                    svlbl#
416cD**                   KFLD           W1LBL#
     *
     *  Define key for CHKLBL1.
     *
     C     clkey1        klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid
     C                   kfld                    w1plid
     *
     *  Define key for CHKPLT.
     *
     C     cpkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid
     C                   kfld                    w1plid
     *
     *  Define key for PIRITEM.
     *
     C     keyit         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    lbwhse
     C                   kfld                    lwtruk
     C                   kfld                    lwszon
     *
     *  Define key for WORKLBL.
     *
     C     keywl         klist
     C                   kfld                    lblbl#
     *
     C                   move      $pwhse        w1whse
     C                   move      $pemp#        w1emp#
     C                   eval      w1rtid = $prtid
     C                   move      $pplid        w1plid
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
416AD**                   Z-ADD0         WOROW
416AD**                   Z-ADD0         WOCOL
     *
     *  End current task.
     *
     C                   exsr      zzend
     *
     *  Create Checker transaction.  PIRTRAN File.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     C                   eval      w1trn# = pttrn#
     *
     C                   call      @addtr
     C                   parm      '*CRTSTRT'    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'CHECK  '     @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      $pwhdp        @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      $prtid        @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'C'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *  Create Checker transaction.  CHKTRN File.
     *
     C                   eval      ctwhse = w1whse
     C                   eval      cttrn# = w1trn#
     C                   eval      ctrtid = w1rtid
     C                   eval      ctplid = w1plid
     C                   write     ctrec
     *
     *  Create Checker pallet.  CHKPLT File.
     *
     *
     C     cpkey         chain     chkplt                             79
     C                   if        *in79
     C                   eval      cpwhse = w1whse
     C                   eval      cprtid = w1rtid
     C                   eval      cpplid = w1plid
     C                   eval      cpcemp = 0
     C                   eval      cpcflg = *blanks
     C                   eval      cplemp = 0
     C                   eval      cpldte = 0
     C                   eval      cpltim = 0
     C                   write     cprec
     C                   endif
     *
     C                   eval      refrsh = *on
     C                   eval      more = *off
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
     C     zzend         begsr
     *
     *  End current task.
     *
     C                   eval      $kcmd = '*ENDCUR '
     C                   movel     'CK112   '    $kprg
     C                   eval      $kemp# = w1emp#
     C                   eval      $kshft = $pshft
     C                   eval      $kcrew = $pcrew
     C                   eval      $kwhse = w1whse
     C                   eval      $kwhdp = $pwhdp
     C                   eval      $kstyp = 'F'
     C                   eval      $kqpck = 0
     C                   eval      $krtn = *blanks
     C                   eval      $kmsg = *blanks
     *
     C                   call      'EPMTSK'
     C                   parm                    $kcmd
     C                   parm                    $kprg
     C                   parm                    $kemp#
     C                   parm                    $kshft
     C                   parm                    $kcrew
     C                   parm                    $kwhse
     C                   parm                    $kwhdp
     C                   parm                    $kstyp
     C                   parm                    $kqpck
     C                   parm                    $krtn
     C                   parm                    $kmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZIDLE Create idle task.
     *
     C     zzidle        begsr
     *  Create Idle task
     C                   call      'EPMTSK'
     C                   parm      '*STRIDL '    $kcmd
     C                   parm      'CK112   '    $kprg
     C                   parm      w1emp#        $kemp#
     C                   parm      $pshft        $kshft
     C                   parm      $pcrew        $kcrew
     C                   parm      w1whse        $kwhse
     C                   parm      $pwhdp        $kwhdp
     C                   parm      'F'           $kstyp
     C                   parm      0             $kqpck
     C                   parm      *blanks       $krtn
     C                   parm      *blanks       $kmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update for CHKPLT file.
     *
     C     zzupd         begsr
     *
     C     cpkey         chain     chkplt                             79
     C                   if        not *in79
     C                   eval      cpcemp = w1emp#
     C                   eval      cpcflg = 'C'
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   eval      cpcdte = today
     C                   time                    cpctim
     C                   update    cprec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C     keywl         chain     worklbl                            79
     C                   if        *in79
     *  Treat as combo label
     C                   eval      opclvl = 1
     C                   else
     *
     *   Get general picking options from options file.
     *
     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain     optionz                            79
     C                   if        *in79
     C                   eval      opclvl = 999
     C                   endif
     *
     C                   endif
     *
     C                   select
     *
     C                   when      lbtype = 'B'
     C                   eval      w2bulk = 'Bulk '
     C                   exsr      scr02i
416eMC                   when      lbqalc >= opclvl
416eD**         LBQPCK    WHGE OPCLVL
     C                   eval      w2bulk = 'Combo'
     C                   exsr      scr02i
     C                   other
     C     clkey         chain     chklbl                             79
     C                   if        *in79
     C                   eval      clwhse = lbwhse
416bAC                   eval      cllbl# = svlbl#
416bD***                  Z-ADDLBLBL#    CLLBL#
416bAC                   eval      cllqty = svqpck
416bD***                  Z-ADDLBQPCK    CLLQTY
     C                   eval      clrtid = lbrte
     C                   eval      clplid = lbpal#
416eMC                   eval      clcqty = lbqalc
416eD**                   Z-ADDLBQPCK    CLCQTY
     C                   eval      cltrn# = w1trn#
     C                   write     clrec
     C                   else
416bAC                   eval      clcqty = svqpck
416bD***                  Z-ADDLBQPCK    CLCQTY
     C                   update    clrec
     C                   endif
     *
     C                   exsr      scr01i
     C                   endsl
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C     clkey         chain     chklbl                             79
     C                   if        *in79
     C                   eval      clwhse = lbwhse
     C                   eval      cllbl# = lblbl#
416eMC                   eval      cllqty = lbqalc
416eD**                   Z-ADDLBQPCK    CLLQTY
     C                   eval      clrtid = lbrte
     C                   eval      clplid = lbpal#
     C                   eval      clcqty = w2qty
     C                   eval      cltrn# = w1trn#
     C                   write     clrec
     C                   else
     C                   eval      clcqty = w2qty
     C                   update    clrec
     C                   endif
     *
     C                   exsr      scr01i
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Route
Pallet
Item
