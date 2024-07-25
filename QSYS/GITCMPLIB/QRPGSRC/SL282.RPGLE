      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SL282    Change pick slot (must have zero qty)
     *  19 October 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    10/19/15  DAS  7.00
     *      - Created
     *
     F*----------------------------------------------------------------
     F*  Client Custom Revisions - Cheney
     F*
CBIbAF*    09/09/08  CBI-JGD (taken from PIRMODSCBI/IT352, added by DAS)
     F*      - Add logic to load new update log file.
     F*        Item location changes will be monitored
     F*        thru this new file.
CBIdAA*    08/04/11  CBI-JGD (taken from PIRMODSCBI/IT352, added by DAS)
     A*      - Maintain new file TIHIGHSND, keeps track of daily
     A*        item location change, also used by IT112/tie-high change
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fsl282fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fslotstat  if   e           k disk
CBIdAFtihighsnd uf a e           k disk    usropn
CBIbAFLOCSLOG   O    E           K DISK    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(3) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Program parameters
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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @sltdt          c                   const('UPDSLTDTE')
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
     D  $ldisp                27     38
     D  $litem                39     53
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfitm                 1     15
     D  erfdsp                16     27
     D  ertitm                28     42
     *
     D  erdisp                 1     12
     D  erstat                13     15
     *
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
600aA /COPY *libl/qcopysrc,C#PGMINFDS
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
600aAD chk4err         s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nbrpck          s              5  0
     D nxtscr          s              3
     D ovrrid          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D today           s              8  0
     D warn            s              1
600aAD zmflag          s               n
600aAD zmsflag         s               n

500cAD #fromslwhdp     s                   like($slwhdp)
500cAD #fromsldisp     s                   like($sldisp)
500cAD #fromslaisl     s                   like($slaisl)
500cAD #fromslloc      s                   like($slloc)
500cAD #fromslpseq     s                   like($slpseq)
500cAD #fromslrlvl     s                   like($slrlvl)
500cAD #fromslhand     s                   like($slhand)
640aAD #fromslstat     s                   like($slstat)
500cAD #fromslpick     s                   like($slpick)
500cAD #fromslstyp     s                   like($slstyp)
500cAD #fromslitem     s                   like($slitem)
500cAD #fromslavl1     s                   like($slavl1)
500cAD #fromslavl2     s                   like($slavl2)
500cAD #fromslavl3     s                   like($slavl3)
600eAD #fromToLcns     s                   like($saToLcns)
600eMD #fromToPos      s                   like($satopos)
600eAD #fromOLcns      s                   like($saOLcns)

500cAD #toslwhdp       s                   like($slwhdp)
500cAD #tosldisp       s                   like($sldisp)
500cAD #toslaisl       s                   like($slaisl)
500cAD #toslloc        s                   like($slloc)
500cAD #toslrlvl       s                   like($slrlvl)
500cAD #toslhand       s                   like($slhand)
640aAD #toslstat       s                   like($slstat)
500cAD #toslpick       s                   like($slpick)
500cAD #toslitem       s                   like($slitem)

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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
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
     *  Refresh screen fields if requested.
     *
     C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   endif
     C                   eval      ovrrid = *off
     C                   eval      refrsh = *off
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
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
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*    DRI0001  Local system caused error
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

600aA*----------------------------------------------------------------
600aA*    DRI0001s Local system caused error (send to different program)
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
600aA*----------------------------------------------------------------
600aA*      0105s
600aA*
600aAC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  New slot can't be blank.
     *
     C                   if        w1disp = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'New slot cannot be blank'
     C                   exsr      zm0105
     C                   leavesr
     C                   endif
     *
     *  New slot can't be same as old slot
     *
     C                   if        w1disp = #fromsldisp
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   eval      errmsg = 'New slot cannot be the '
     C                                    + 'same as From slot'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *   Get New Slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   leavesr
     C                   endif

     *   Error if not a Pick slot

     C                   if        $slpick <> 'Y'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'New slot is not a Pick slot'
     C                   exsr      zm0105
     C                   leavesr
     C                   endif

     *   Error if status is not 'V'

     C                   if        $slstat <> 'V'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'New slot is not status "V"'
     C                   exsr      zm0105
     C                   leavesr
     C                   endif

     C                   eval      #toslwhdp = $slwhdp
     C                   eval      #tosldisp = $sldisp
     C                   eval      #toslaisl = $slaisl
     C                   eval      #toslloc  = $slloc
     C                   eval      #toslrlvl = $slrlvl
     C                   eval      #toslhand = $slhand
     C                   eval      #toslpick = $slpick
     C                   eval      #toslstat = $slstat
600aA
600aA*  Verify From slot change
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = #fromslwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = #fromsldisp
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = #fromslaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = #fromslloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = #fromslrlvl
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = #fromslhand
600aAC                   eval      $slitemu = *on
600aAC                   eval      $slitem  = ' '
600aAC                   eval      $slstatu = *on
600aAC                   eval      $slstat  = 'Z'
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%VERIFYCHG'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif
600aA
600aA*  Verify New slot change. Ignore too many pick slot error.
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = #toslwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = #tosldisp
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = #toslaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = #toslloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = #toslrlvl
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = #toslhand
600aAC                   eval      $slitemu = *on
600aAC                   eval      $slitem  = #fromslitem
600aAC                   eval      $slstatu = *on
600aAC                   eval      $slstat  = 'A'
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%VERIFYCHG'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   exsr      zzzdricop
600aAC                   if        $drireturn <> '*OK'
600aAC                             and $drireturn <> 'PCKOVRFLW'
     C                   eval      error = *on
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   exsr      zm0001
600aAC                   leavesr
600aAC                   endif
415aA*
     C     endck1        endsr
     *----------------------------------------------------------------
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
     *     Slot
     *
     C                   when      row# = 17
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = #fromslwhdp
     C                   eval      $ldisp = ''
     C                   eval      $litem = ''
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1disp = $ldisp
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     *      F8 - View slot information.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = #fromslwhdp
     C                   eval      $ldisp = #fromsldisp
     C                   eval      $litem = #fromslitem
     C                   call      'IT135'
     C                   parm                    $lparm
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Convert available to string.
     *
     C                   eval      $cqty1 = #fromslavl1
     C                   eval      $cqty2 = #fromslavl2
     C                   eval      $cqty3 = #fromslavl3
     *
     C                   call      'CVTQTY'
     C                   parm      '*QTY2STR'    $ccmd             8
     C                   parm      #prog         $cprg            10
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

     C                   eval      w1curq = $cqstr
     *
     *  Get status description.
     *
     C     #fromslstat   chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = #fromslstat
     C                   endif
500cA
500cA*  Use DRI interface to get item.
500cA
     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = #fromslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   leavesr
     C                   endif
     *
     C                   eval      woitem = $ititem
     C                   eval      w1styp = #fromslstyp
     *
     *   Format item description for display.
     *
     C                   eval      $iitem = $ititem
     C                   eval      $idesc = $itdesc
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      woitem = *blanks
     C                   movel     $istr         woitem
     *
     C                   eval      w1whdp = $itwhdp
     *
     *   Initialize entry fields
     *
     C                   eval      w1disp = ''

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    cliloc           10
CBIdA*
CBIdA*  Define key for TIHIGHSND file.
CBIdA*
CBIdAC     tisndkey      klist
CBIdAC                   kfld                    $pwhse
CBIdAC                   kfld                    #fromslitem
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
CBIdA
CBIdA*  Open custom files
CBIdA
CBIdAC                   if        client = cheney
CBIdA
CBIdAC                   if        not %open(tihighsnd)
CBIdAC                   open(e)   tihighsnd
CBIdAC                   if        %error
CBIdAC                   eval      error = *on
CBIdAC                   eval      $prtn = '*PGMQ'
CBIdAC                   eval      errmsg = 'Cannot change slot - '
CBIdAC                                    + 'Cannot open file TIHIGHSND'
CBIdAC                   exsr      zm0105s
CBIdAC                   leavesr
CBIdAC                   endif
CBIdAC                   endif
CBIdA
CBIdAC                   if        not %open(locslog)
CBIdAC                   open(e)   locslog
CBIdAC                   if        %error
CBIdAC                   eval      error = *on
CBIdAC                   eval      $prtn = '*PGMQ'
CBIdAC                   eval      errmsg = 'Cannot change slot - '
CBIdAC                                    + 'Cannot open file TIHIGHSND'
CBIdAC                   exsr      zm0105s
CBIdAC                   leavesr
CBIdAC                   endif
CBIdAC                   endif
CBIdA
CBIdAC                   endif
600aA*
600aA*    Get User's employee number to be written to PORCV file
600aA*    if any records are flagged as touched.
600aA*
600aAC                   call      'GETUSER'
600aAC                   parm      #curruser     $code            10
600aAC                   parm      0             $whse             3 0
600aAC                   parm      0             $emp#             5 0
600aAC                   parm      *blanks       $fnam            15
600aAC                   parm      *blanks       $init             1
600aAC                   parm      *blanks       $lnam            20
600aAC                   parm      *blanks       $whdp             5
600aAC                   parm      *blanks       $styp             1
600aAC                   parm      *blanks       $shft             6
600aAC                   parm      *blanks       $crew             6
600aAC                   parm      0             $nhrs             3 1
600aAC                   parm      *blanks       $rtn              8
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     *
     *   Get department description.
     *
     C     keywd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C     keywd         chain     whdept                             79
     C                   if        *in79
     C                   eval      wdcode = *blanks
     C                   eval      wddesc = *blanks
     C                   endif

     *   Get From slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   leavesr
     C                   endif

     *   Return error if not a Pick slot

     C                   if        $slpick <> 'Y'
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'Slot is not a Pick slot'
     C                   exsr      zm0105s
     C                   leavesr
     C                   endif

     *   Return error if slot does not contain an item

     C                   if        $slitem = ' '
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'Slot does not contain item'
     C                   exsr      zm0105s
     C                   leavesr
     C                   endif

     *   Return error if status is not 'A'

     C                   if        $slstat <> 'A'
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'Slot status is not "A"'
     C                   exsr      zm0105s
     C                   leavesr
     C                   endif

     *   Return error if qty is not zero

     C                   if        $slstk1 <> 0 or
     C                             $slstk2 <> 0 or
     C                             $slstk3 <> 0 or
     C                             $slalc1 <> 0 or
     C                             $slalc2 <> 0 or
     C                             $slalc3 <> 0 or
     C                             $sltfr1 <> 0 or
     C                             $sltfr2 <> 0 or
     C                             $sltfr3 <> 0 or
     C                             $slpck1 <> 0 or
     C                             $slpck2 <> 0 or
     C                             $slpck3 <> 0 or
     C                             $slrcv1 <> 0 or
     C                             $slrcv2 <> 0 or
     C                             $slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      errmsg = 'Cannot change slot - '
     C                                    + 'Slot has quantity'
     C                   exsr      zm0105s
     C                   leavesr
     C                   endif

     *   Save From information

     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslstat = $slstat
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
     C                   eval      #fromslavl3 = $slavl3
     *
     *   Select first screen to display.
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
CBIbAC*----------------------------------------------------------------
CBIbAC*
CBIbAC*  ZZLOG  Log the info of the item location change being done.
CBIbAC*
CBIbAC     ZZLOG         BEGSR
CBIbAC*
CBIbAC                   CLEAR                   LOCREC
CBIbAC                   Z-ADD     $pwhse        LOCWHS
CBIbAC                   MOVE      #fromslwhdp   LOCDPT
CBIbDC                   MOVE      #fromslitem   LOCITM
CBIbMC                   MOVE      #fromsldisp   LOCFRM
CBIbAC                   MOVE      #tosldisp     LOCTO
CBIbAC*    Get todays date.
CBIbAC                   MOVE      '*CURCMD '    $CVCMD
CBIbACSR                 CALL      @CVTDT
CBIbACSR                 PARM                    $CVTDT
CBIbAC                   Z-ADD     $CVD8O        LOCDTE
CBIbAC                   TIME                    LOCTIM
CBIbAC                   MOVE      #curruser     LOCUSR
CBIbAC                   Z-ADD     $emp#         LOCEMP
CBIbAC*
CBIbAC                   WRITE     LOCREC
CBIbAC*
CBIdAC     tisndkey      chain     tihighsnd                          79
CBIdAC                   eval      snwhse = $pwhse
CBIdAC                   eval      snitem = #fromslitem
CBIdAC                   eval      sntie  = *zeros
CBIdAC                   eval      snhigh = *zeros
CBIdAC                   eval      snsdef = *blanks
CBIdAC                   eval      snsend = 'N'
CBIdAC                   if        *in79 = *off
CBIdAC                   update    sndrec
CBIdAC                   else
CBIdAC                   write     sndrec
CBIdAC                   endif
CBIbAC*
CBIbAC     ENDLOG        ENDSR
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
600aA
600aA*  Take item out of From slot
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = #fromslwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = #fromsldisp
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = #fromslaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = #fromslloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = #fromslrlvl
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = #fromslhand
600aAC                   eval      $slitemu = *on
600aAC                   eval      $slitem  = ' '
600aAC                   eval      $slstatu = *on
600aAC                   eval      $slstat  = 'Z'
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%CHANGE'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif
600aA
600aA*  Put item into new slot
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = #toslwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = #tosldisp
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = #toslaisl
     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = #toslloc
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = #toslrlvl
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = #toslhand
600aAC                   eval      $slitemu = *on
600aAC                   eval      $slitem  = #fromslitem
600aAC                   eval      $slstatu = *on
600aAC                   eval      $slstat  = 'A'
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%CHANGE'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif

CBIbAC*   Create an update log record
CBIbAC                   if        client = cheney
CBIbAC                   EXSR      ZZLOG
CBIbAC                   endif

     C                   endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and chk4err = *on
     C                   eval      error = *on
600aAC                   eval      errmsg    = 'Error occured on call to '
600aAC                                       + 'DRICOP'
600aAC                                       + '/' + %trim($drisubcmd)
600aAC                                       + ' from ' + #pgm
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0105s
600aAC                   when      zmflag
600aAC                   exsr      zm0105
600aAC                   endsl

417yMC                   when      $drireturn <> '*OK' and chk4err = *on
     C                   eval      error = *on
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0001s
600aAC                   when      zmflag
600aAC                   exsr      zm0001
     C*                  exsr      zzerrind
600aAC                   endsl

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      chk4err = *off
     C     enddricop     endsr
