     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR675     Reprint closed route - Traffic cop
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    08/15/00  DAS  4.14
     *      - Created
     *
415 A*    12/14/00  DAS  4.15
     *      - Added option to reprint labels.
     *        This should only be used for testing purposes since
     *        there should be no reason to reprint labels to be used
     *        for picking after a route has been closed.
415bA*    07/06/01  RH   4.15b
     *      - Change to reprint route stop detail/summary/both
     *
510 A*  03/31/07  DAS  5.10
     *    - Rev 510 was missing ... brought from PIR510 to PIRENH520
     *      on 12/2/08, RBD.
     *    - Enh: Added support to call OR660C = Catchweight summary
     *
520aA*    07/02/08  DAS  5.20a
     *      - Enh: Added client custom code support.
     *
520bA*    03/23/09  CWM  5.20b
     *      - Enh: Added Print Override Report Distribution
     *
530 A*  02/20/10  MLB  5.30  Note: Was formerly 5.20 on MJ Kellner.
     *    - Enh: Added Option to route stop detail/summary/both to
     *      include new option 'E' for exceptions.
     *    - Changed dspf to OR67501 from OR675FM.
     *
640AA*  03/18/11  JCJ  6.40A
     *    - Enh: Converted source to ILE
     *    - Enh: Added reprint options by Transaction and Label.
     *    - Enh: Changed program to receive route id.
     *
640bA*  06/15/11  JCJ  6.40b
     *    - Enh: Add edit to not allow reprints if Truck has been
     *           deleted.
     *
640cA*  06/29/11  JCJ  6.40c
     *    - Enh: Added label range for reprint by label number.
     *    - Enh: Renamed display file from OR67502 to OR67503 per
     *           GUI standards.
     *
700aA*  10/18/15  JCJ  7.00a
     *    - Enh: Added pallet label reprint logic.
     *
700bA*  09/06/16  JCJ  7.00b
     *    - Enh: Added Manager Ship List reprint logic.
     *
710aA*  01/17/17  JCJ  7.10a
     *    - Enh: Added pallet label reprint.
     *
710bA*  07/05/18  JCJ  7.10b
     *    - Enh: Renamed display file from OR67505 to OR67506 per
     *           GUI standards.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    07/25/08  DAS  CTWa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to reprint
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers.
     *
700 A*   01/04/17  JGD 7.00
     *     - Add Cheney Brothers to verify if user is allowed to
     *       reprint labels.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
710aM*  21 - 34   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 D*OR675FM CF  E                    WORKSTN
640aD*or67501   cf   e             workstn
640cD*or67502   cf   e             workstn
700aD*or67503   cf   e             workstn
700bD*or67504   cf   e             workstn
710bD*or67505   cf   e             workstn
710bMFor67506   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
640aAFpltsum12  if   e           k disk
640aAFlabel     if   e           k disk
640bAFrtehed    if   e           k disk
640bAFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
415 D**                  DESC    1   7 60
415 M**                  DESC    1   8 60
510 D**                  DESC    1   9 60
520bD**                  DESC    1  10 60
640aD** desc            s             60    dim(11) ctdata perrcd(1)
700aD** desc            s             60    dim(15) ctdata perrcd(1)
700bD** desc            s             60    dim(16) ctdata perrcd(1)
700bMD desc            s             60    dim(17) ctdata perrcd(1)
520aA*----------------------------------------------------------------
520aA*  Customer id
520aA*
     D @getcl          c                   const('GETCLIENT')
CTWaA /copy qcopysrc,id#citywho
700 A /copy qcopysrc,id#cheney
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
640aAD  $lrtid                22     26
640aAD  $lszon                27     32
640aAD  $ltrn#                33     39  0
640aAD  $llbl#                40     46  0
700aAD  $lplt#                47     53  0
710aAD  $lplid                54     60  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
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
CTWaA*----------------------------------------------------------------
CTWaA* Constants
CTWaAD err01           c                   'Not Authorized Reprint Labels'
CTWaAD err02           c                   'Not authorized reprint truck'
CTWaAD err03           c                   'Not authorized reprint audit'
640aAD err05           c                   'Transaction Number required'
640aAD err06           c                   'Label Number required'
640aAD err07           c                   'Selection Zone required'
640bAD err09           c                   'Reprint not allowed-Truck Template -
640bAD                                     Deleted.'
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $dev            s             10
     D $form           s             10
     D $msgf           s             10
     D $pwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D alwall          s              1
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D work1a          s              1
640aAD wktran          s              7  0
640aAD wklabel         s              7  0
640aAD labelfound      s              1
640aAD Forever         C                   1
640aAD Numbers         C                   '0123456789'
640aAD ChkNumb         S              3P 0
640aAD ValChar         S              1
640aAD ValCodeLen      S              3P 0
640aAD ValPos          S              3P 0
640aAD err08           S             50
640cAD wrktrn1         s              7  0
640cAD wrktrn2         s              7  0
700aAD wrkplt#         s              7
700aAD w1dev           S             10
700aAD w1form          S             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *PIR     - Select only PIR items
     *              *FIXED   - Select only Fixed items
     *              *BOTH    - Select all items
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $rte              5
640aAC                   parm                    $rtid             5
415 AC                   parm                    $lbls             1
640aD ***                parm                    $zone             6
640aMC                   parm                    $zone             7
     C                   parm                    $rtes             1
415b C                   parm                    $rtds             1
     C                   parm                    $trk              1
     C                   parm                    $trpl             1
     C                   parm                    $ds               1
510 AC                   parm                    $cwsum            1
     C                   parm                    $prtn             8
520bAC                   parm                    $rsdt             1
520bAC                   parm                    $pots             1
520bAC                   parm                    $potp             1
520bAC                   parm                    $pocw             1
640aAC                   parm                    $ltype            1
640cAC                   parm                    $pflbl            7
640cAC                   parm                    $ptlbl            7
     *
520bMC                   move      $whse         $pwhse
520bD*                    PARM           $DEV   10
520bD*                    PARM           $FORM  10
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
640cAC                   setoff                                       091011
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
640cMC                   setoff                                       303133
700aAC                   setoff                                       343536
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
     C                   exsr      zznxt1
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
     *R                   WRITECLRSCR
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
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
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint everything.
CTWaA*
CTWaAC                   eval      alwall = *on
700 MC                   if        client = citywh or
700 MC                             client = cheney
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm            10
CTWaAC                   parm      'ALL'         $copt            20
CTWaAC                   parm      #user         $cuser           10
CTWaAC                   parm      *blanks       $crtn            10
CTWaAC                   if        $crtn = '*NO'
CTWaAC                   eval      alwall = *off
CTWaAC                   endif
CTWaAC                   endif
415 A*
415 A*  Verify Y,N option for labels
415 A*
415 AC                   if        w1lbls <> 'Y'  and
415 AC                             w1lbls <> 'N'
415 AC                   eval      error = *on
415 AC                   eval      *in26 = *on
415 AC                   eval      *in06 = *on
415 AC                   eval      errmsg = *blanks
415 AC                   movel     desc(8)       errmsg
415 AC                   exsr      zm1001
415 AC                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint labels
CTWaA*
700 MC                   if        client = citywh or
700 MC                             client = cheney
CTWaAC                   if        w1lbls = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'LABELS'      $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO '
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in21 = *on
CTWaAC                   eval      *in01 = *on
CTWaAC                   eval      errmsg = err01
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
710aA*
710aA*  Verify N,Z,T,P option
710aA*
710aAC                   if        w1plt <> 'N'
710aAC                             and w1plt <> 'Z'
710aAC                             and w1plt <> 'T'
710aAC                             and w1plt <> 'P'
710aAC                   eval      error = *on
710aAC                   eval      *in33 = *on
710aAC                   eval      *in13 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     desc(16)      errmsg
710aAC                   exsr      zm1001
710aAC                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint labels
CTWaA*
CTWaAC                   if        client = citywh
CTWaAC                   if        w1lbls = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'LABELS'      $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO '
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in21 = *on
CTWaAC                   eval      *in01 = *on
CTWaAC                   eval      errmsg = err01
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
640aA*
640aA*  Verify Z,T,L option
640aA*
640aAC                   if        w1lbls = 'Y'
640aA*
640aAC                   if        w1type <> 'Z'
640aAC                             and w1type <> 'T'
640aAC                             and w1type <> 'L'
640aAC                   eval      error = *on
640aAC                   eval      *in28 = *on
640aAC                   eval      *in08 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(11)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif
640aA*
640aA*  Verify ZONE option
640aA*
640aAC                   select
640aAC                   when      w1type = 'Z'
640aAC                             and w1zone =  *blanks
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err07         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

640aAC                   when      w1type = 'T'
640aAC                             and w1zone =  *blanks
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err05         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

640aAC                   when      w1type = 'L'
640aAC                             and w1zone =  *blanks
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err06         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

640aAC                   when      w1type = 'Z'
640aAC                             and w1zone <> *blanks
640aAC                             and w1zone <> '*ALL'
640aAC                   eval      $lcmd = '*VERIFY '
640aAC                   move      $whse         $lwhse
640aAC                   eval      $lrtid = $rtid
640aAC                   eval      $lszon = w1zone
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
640aAC                   call      'OR901'
640aAC                   parm                    $lparm
640aAC                   if        $lrtn = '*PGMQ   '
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(15)      errmsg
640aAC                   exsr      zm1001
640aAC                   goto      endck1
640aAC                   endif

640aAC                   when      w1type = 'T'
640aAC                             and w1zone <> *blanks
640aAC                             and w1zone <> '*ALL'
640cA*
640cA*  Initialize values.
640cA*
640cAC                   eval      ValPos   = 1
640cAC                   eval      ValCodeLen = %Len(%Trim(w1zone))
640cAC                   eval      ValChar = %Subst(w1zone:ValPos:1)
640aAC                   exsr      zzchkn
640aAC                   if        error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   movel     err08         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1
640aAC                   endif
640aAC                   eval      wktran = %dec(w1zone:7:0)
640aAC     keyps12       chain     pltsum12
640aAC                   if        not %found(pltsum12)
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(12)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif
640cA*  from label
640aAC                   when      w1type = 'L'
640cMC                   if        w1zone <> *blanks
640cA*
640cA*  Initialize values.
640cA*
640cAC                   eval      ValPos   = 1
640cAC                   eval      ValCodeLen = %Len(%Trim(w1zone))
640cAC                   eval      ValChar = %Subst(w1zone:ValPos:1)
640aAC                   exsr      zzchkn
640aAC                   if        error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   movel     err08         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1
640aAC                   endif
640aAC                   eval      labelfound = 'N'
640aAC                   eval      wklabel = %dec(w1zone:7:0)
640aAC     wklabel       setll     label
640aAC                   dou       %eof(label)
640aAC     wklabel       reade     label
640aAC                   if        not %eof(label)
640aAC                   if        lbrte = $rtid
640aAC                   eval      labelfound = 'Y'
640aAC                   leave
640aAC                   endif
640aAC                   endif
640aAC                   enddo
640aAC                   if        labelfound = 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in29 = *on
640aAC                   eval      *in09 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(14)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif
640cAC                   endif
640cA*  to label
640cAC                   if        w1zon2 <> *blanks
640cAC                   eval      ValPos   = 1
640cAC                   eval      ValCodeLen = %Len(%Trim(w1zon2))
640cAC                   eval      ValChar = %Subst(w1zon2:ValPos:1)
640cAC                   exsr      zzchkn
640cAC                   if        error = *on
640cAC                   eval      *in31 = *on
640cAC                   eval      *in11 = *on
640cAC                   movel     err08         errmsg
640cAC                   exsr      zm0105
640cAC                   goto      endck1
640cAC                   endif
640cAC                   eval      labelfound = 'N'
640cAC                   eval      wklabel = %dec(w1zon2:7:0)
640cAC     wklabel       setll     label
640cAC                   dou       %eof(label)
640cAC     wklabel       reade     label
640cAC                   if        not %eof(label)
640cAC                   if        lbrte = $rtid
640cAC                   eval      labelfound = 'Y'
640cAC                   leave
640cAC                   endif
640cAC                   endif
640cAC                   enddo
640cAC                   if        labelfound = 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in31 = *on
640cAC                   eval      *in11 = *on
640cAC                   eval      errmsg = *blanks
640cAC                   movel     desc(14)      errmsg
640cAC                   exsr      zm1001
640cAC                   endif
640cAC                   endif
640aAC                   endsl
640bA*
640cAC                   if        w1zone <> *blanks
640cAC                             and w1zon2 = *blanks
640cAC                             and error <> *on
640cAC                   eval      w1zon2 = w1zone
640cAC                   endif
640cA*
640bAC     rhkey         chain     rtehed
640bAC                   if        %found(rtehed)
640bAC     trkey         chain     truckh
640bAC                   if        not %found(truckh)
640bAC                   eval      error = *on
640bAC                   eval      *in21 = *on
640bAC                   eval      *in01 = *on
640bAC                   eval      errmsg = err09
640bAC                   exsr      zm0105
640bAC                   goto      endck1
640bAC                   endif
640bAC                   endif
640aAC                   endif
710aA*
710aA*  Verify Z,T,P option for pallet label reprint
710aA*
710aAC                   if        w1plt <> 'N'
700aAC                             and error <> *on
710aA*
710aA*  Verify ZONE option
710aA*
710aAC                   select
710aAC                   when      w1plt = 'Z'
710aAC                             and w1ptyp = *blanks
710aAC                   eval      error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     err07         errmsg
710aAC                   exsr      zm0105
710aAC                   goto      endck1
710aA*
710aA*  Verify Transaction
710aA*
710aAC                   when      w1plt = 'T'
710aAC                             and w1ptyp = *blanks
710aAC                   eval      error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     err07         errmsg
710aAC                   exsr      zm0105
710aAC                   goto      endck1
710aA*
710aA*  Verify Pallet number
710aA*
710aAC                   when      w1plt = 'P'
710aAC                             and w1ptyp = *blanks
710aAC                   eval      error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     err07         errmsg
710aAC                   exsr      zm0105
710aAC                   goto      endck1

710aAC                   when      w1plt = 'Z'
710aAC                             and w1ptyp <> *blanks
710aAC                             and w1ptyp <> '*ALL'
710aAC                   eval      $lcmd = '*VERIFY '
710aAC                   move      $whse         $lwhse
710aAC                   eval      $lrtid = $rtid
710aAC                   eval      $lszon = w1ptyp
710aAC                   eval      $ltrn# = *zeros
710aAC                   eval      $llbl# = *zeros
710aAC                   call      'OR901'
710aAC                   parm                    $lparm
710aAC                   if        $lrtn = '*PGMQ   '
710aAC                   eval      error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     desc(15)      errmsg
710aAC                   exsr      zm1001
710aAC                   goto      endck1
710aAC                   endif

710aAC                   when      w1plt = 'T'
710aAC                             and w1ptyp <> *blanks
710aAC                             and w1ptyp <> '*ALL'
710cA*
710cA*  Initialize values.
710cA*
710cAC                   eval      ValPos   = 1
710cAC                   eval      ValCodeLen = %Len(%Trim(w1ptyp))
710cAC                   eval      ValChar = %Subst(w1ptyp:ValPos:1)
710aAC                   exsr      zzchkn
710aAC                   if        error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   movel     err08         errmsg
710aAC                   exsr      zm0105
710aAC                   goto      endck1
710aAC                   endif
710aAC                   eval      wktran = %dec(w1ptyp:7:0)
710aAC     keyps12       chain     pltsum12
710aAC                   if        not %found(pltsum12)
710aAC                   eval      error = *on
710aAC                   eval      *in34 = *on
710aAC                   eval      *in14 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   movel     desc(13)      errmsg
710aAC                   exsr      zm1001
710aAC                   endif
710aAC                   endsl
710aAC                   endif
     *
     *  Verify Y,N option
     *
     C                   if        w1rtes <> 'Y'  and
     C                             w1rtes <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
415b *
415b *  Verify D,S,B option (detail,summary,both)
415b *
415b C                   if        w1rtds <> 'D'  and
415b C                             w1rtds <> 'S'  and
415b C                             w1rtds <> 'B'  and
530 AC                             w1rtds <> 'E'
415b C                   eval      error = *on
415b C                   eval      *in22 = *on
415b C                   eval      *in02 = *on
415b C                   eval      errmsg = *blanks
415b C                   movel     desc(9)       errmsg
415b C                   exsr      zm1001
415b C                   endif
     *
     *  Verify Y,N option
     *
     C                   if        w1trk <> 'Y'  and
     C                             w1trk <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint truck rpts
CTWaA*
CTWaAC                   if        client = citywh
CTWaAC                   if        w1trk = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'TRUCK'       $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO '
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in23 = *on
CTWaAC                   eval      *in03 = *on
CTWaAC                   eval      errmsg = err02
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
700bA*
700bA*  Verify Y,N option
700bA*
     C                   if        w1mgr <> 'Y'  and
     C                             w1mgr <> 'N'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(17)      errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify Y,N option
     *
     C                   if        w1trpl <> 'Y'  and
     C                             w1trpl <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint truck rpts
CTWaA*
CTWaAC                   if        client = citywh
CTWaAC                   if        w1trpl = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'TRUCK'       $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO '
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in24 = *on
CTWaAC                   eval      *in04 = *on
CTWaAC                   eval      errmsg = err02
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
     *
     *  Verify D,S option
     *
     C                   if        w1ds <> 'D'  and
     C                             w1ds <> 'S'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
510 A*
510 A*  Verify Catchweight summary Y,N option
510 A*
510 AC                   if        w1csum <> 'Y'  and
510 AC                             w1csum <> 'N'
510 AC                   eval      error = *on
510 AC                   eval      *in28 = *on
510 AC                   eval      *in08 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(10)      errmsg
510 AC                   exsr      zm1001
510 AC                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
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
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(7)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
520bA*  Verify Print Override Flags
520bA*
520bAC                   if        w1rsdt <> 'Y'  and
520bAC                             w1rsdt <> 'N'
520bAC                   eval      error = *on
520bAC                   eval      *in31 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   movel     desc(11)      errmsg
520bAC                   exsr      zm1001
520bAC                   endif
520bA*
520bAC                   if        w1pots <> 'Y'  and
520bAC                             w1pots <> 'N'
520bAC                   eval      error = *on
520bAC                   eval      *in32 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   movel     desc(11)      errmsg
520bAC                   exsr      zm1001
520bAC                   endif
520bA*
520bAC                   if        w1potp <> 'Y'  and
520bAC                             w1potp <> 'N'
520bAC                   eval      error = *on
520bAC                   eval      *in33 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   movel     desc(11)      errmsg
520bAC                   exsr      zm1001
520bAC                   endif
520bA*
520bAC                   if        w1pocw <> 'Y'  and
520bAC                             w1pocw <> 'N'
520bAC                   eval      error = *on
520bAC                   eval      *in34 = *on
520bAC                   eval      errmsg = *blanks
520bAC                   movel     desc(11)      errmsg
520bAC                   exsr      zm1001
520bAC                   endif
     *
     C     endck1        endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZchkn  Verify value is all numeric
640aA*
640aAC     ZZchkn        begsr
     *
     *  See if we have reached the end of the barcode.
     *
     *  Initialize values.
     *
700aAC                   eval      ValPos   = 1
700aAC                   select
700aAC                   when      w1type = 'T'
700aAC                             and w1zone <> *blanks
700aAC                   eval      ValCodeLen = %Len(%Trim(w1zone))
700aAC                   when      w1plt = 'T'
700aAC                             and w1ptyp <> *blanks
700aAC                   eval      ValCodeLen = %Len(%Trim(w1ptyp))
700aAC                   endsl
     *
     *  Loop through characters looking for numeric value
     *
     C     Forever       DowEq     Forever
     *
     *  Get Character
     *
700aAC                   select
700aAC                   when      w1type = 'T'
700aAC                             and w1zone <> *blanks
     C                   eval      ValChar = %Subst(w1zone:ValPos:1)
700aAC                   when      w1plt = 'T'
700aAC                             and w1ptyp <> *blanks
700aAC                   eval      ValChar = %Subst(w1ptyp:ValPos:1)
700aAC                   endsl
     *
     *  Character must be numeric.
     *
     C                   eval      ChkNumb = %Scan(ValChar:Numbers)
     C                   if        ChkNumb = 0
     C                   eval      error = *on
     C                   eval      err08 = 'Invalid code found at position '
     C                                        + %Trim(%EditC(ValPos:'Z'))
     C                   leave
     C                   endif
     C                   eval      ValPos  = ValPos + 1
     *
     C                   if        ValPos > ValCodeLen
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C     EndZZchkn     endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
640aA*
640aA*  Test for F4 - Lookup
640aA*
640aAC                   if        *inkd
640aAC                   eval      cmdtkn = *on
640aAC                   z-add     0             row#
640aAC                   eval      row = rowin
640aAC                   z-add     0             col#
640aAC                   eval      col = colin
640aA*
640aAC                   select
640aA*
640aA*     Pick Zone
640aA*
640aAC                   when      row# = 9
640aAC                             and w1type = 'Z'
640aAC                   eval      *in12 = *on
640aAC                   eval      $lcmd = '*LOOKUP '
640aAC                   move      $whse         $lwhse
640aAC                   eval      $lrtid = $rtid
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
640aAC                   call      'OR901'
640aAC                   parm                    $lparm
640aAC                   if        $lrtn = '*SELECT '
640aAC                   eval      w1zone = $lszon
640aAC                   endif
640aA*
640aA*     Transaction
640aA*
640aAC                   when      row# = 9
640aAC                             and w1type = 'T'
640aAC                   eval      *in12 = *on
640aAC                   eval      $lcmd = '*LOOKUP '
640aAC                   move      $whse         $lwhse
640aAC                   eval      $lrtid = $rtid
640cAC                   eval      $lszon = *blanks
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
640aAC                   call      'OR900'
640aAC                   parm                    $lparm
640aAC                   if        $lrtn = '*SELECT '
640aAC                   move      $ltrn#        w1zone
640aAC                   endif
640aA*
640aA*     Label
640aA*
640aAC                   when      row# = 9
640aAC                             and w1type = 'L'
640cAC                             and col# >= 38
640cAC                             and col# <= 44
640aAC                   eval      *in12 = *on
640aAC                   eval      $lcmd = '*LOOKUP '
640aAC                   move      $whse         $lwhse
640aAC                   eval      $lrtid = $rtid
640cAC                   eval      $lszon = *blanks
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
640aAC                   call      'OR902'
640aAC                   parm                    $lparm
640aAC                   if        $lrtn = '*SELECT '
640aAC                   move      $llbl#        w1zone
640cA* get transaction number
640cAC     $llbl#        setll     label
640cAC                   dou       %eof(label)
640cAC     $llbl#        reade     label
640cAC                   if        not %eof(label)
640cAC                   if        lbrte = $rtid
640cAC                   leave
640cAC                   endif
640cAC                   endif
640cAC                   enddo
640cAC                   endif
640cA*
640cA*     Label
640cA*
640cAC                   when      row# = 9
640cAC                             and w1type = 'L'
640cAC                             and col# >= 48
640cAC                             and col# <= 54
640cAC                   eval      *in12 = *on
640cAC                   eval      $lcmd = '*LOOKUP '
640cAC                   move      $whse         $lwhse
640cAC                   eval      $lrtid = $rtid
640cAC                   eval      $lszon = *blanks
640cAC                   eval      $ltrn# = lbtrn#
640cAC                   eval      $llbl# = *zeros
640cAC                   call      'OR902'
640cAC                   parm                    $lparm
640cAC                   if        $lrtn = '*SELECT '
640cAC                   move      $llbl#        w1zon2
640cAC                   endif
700aA*
700aA*     Pick Zone
700aA*
700aAC                   when      row# = 12
700aAC                             and w1plt = 'Z'
700aAC                   eval      *in12 = *on
700aAC                   eval      $lcmd = '*LOOKUP '
700aAC                   move      $whse         $lwhse
700aAC                   eval      $lrtid = $rtid
700cAC                   eval      $ltrn# = *zeros
700cAC                   eval      $llbl# = *zeros
700aAC                   call      'OR901'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
700aAC                   eval      w1ptyp = $lszon
700aAC                   endif
700aA*
700aA*     Transaction
700aA*
700aAC                   when      row# = 12
700aAC                             and w1plt = 'T'
700aAC                   eval      *in12 = *on
700aAC                   eval      $lcmd = '*LOOKUP '
700aAC                   move      $whse         $lwhse
700aAC                   eval      $lrtid = $rtid
700cAC                   eval      $lszon = *blanks
700cAC                   eval      $ltrn# = *zeros
700cAC                   eval      $llbl# = *zeros
700aAC                   call      'OR900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
700aAC                   move      $ltrn#        w1ptyp
700aAC                   endif
700aA*
700aA*     Pallet Number
700aA*
700aAC                   when      row# = 12
700aAC                             and w1plt = 'P'
700aAC                   eval      *in12 = *on
700aAC                   eval      $lcmd = '*LOOKUP '
700aAC                   move      $whse         $lwhse
700aAC                   eval      $lrtid = $rtid
700aAC                   eval      $lszon = *blanks
700aAC                   eval      $ltrn# = *zeros
700aAC                   eval      $llbl# = *zeros
700aAC                   eval      $lplt# = *zeros
710aAC                   eval      $lplid = *zeros
700aAC                   call      'OR904'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
710aAC                   eval      w1ptyp = %char($lplid)
710aAC                   eval      wrkplt# = %char($lplt#)
700aAC                   endif
640aA*
640aA*     Cursor not on a valid lookup field.
640aA*
640aAC                   other
640aAC                   move      *on           error
640aAC                   exsr      zm9905
640aAC                   endsl
640aAC                   goto      endcm1
640aAC                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C     whkey         chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      $whse         w1whse
     C                   eval      w1rte = $rte
415 AC                   eval      w1lbls = 'N'
415 AC                   eval      w1zone = '*ALL  '
     C                   eval      w1rtes = 'N'
415b C                   eval      w1rtds = 'S'
     C                   eval      w1trk = 'N'
700bAC                   eval      w1mgr = 'N'
     C                   eval      w1trpl = 'N'
     C                   eval      w1ds = 'S'
510 AC                   eval      w1csum = 'N'
640aAC                   eval      w1type = 'Z'
700aAC                   eval      w1plt  = 'N'
700aAC                   eval      w1ptyp = '*ALL'
     *
     C                   movel     '*JOB    '    w1dev
     C                   movel     '*STD    '    w1form
     *
520bAC                   eval      w1rsdt = 'N'
520bAC                   eval      w1pots = 'N'
520bAC                   eval      w1potp = 'N'
520bAC                   eval      w1pocw = 'N'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
520aA*
520aA* Get client id.
520aA*
520aAC                   call      @getcl
520aAC                   parm                    client           10
520aAC                   parm                    cliloc           10
     *
     C     whkey         klist
     C                   kfld                    $pwhse
640aA*
640aA*  Define partial key for PLTSUM1 file.
640aA*
640aAC     keyps12       klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    $rtid
640aAC                   kfld                    wktran
640bA*
640bA*  Define partial key for PLTSUM1 file.
640bA*
640bAC     rhkey         klist
640bAC                   kfld                    $pwhse
640bAC                   kfld                    $rtid
640bA*
640bA*  Define key for TRUCKH file.
640bA*
640bAC     trkey         klist
640bAC                   kfld                    $pwhse
640bAC                   kfld                    rhtruk
     *
     C                   eval      $lprg = #prog
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
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
710aAC                   select
710aAC                   when      w1lbls = 'Y'
415 AC                   eval      $lbls = w1lbls
415 AC                   eval      $zone = w1zone
710aAC                   when      w1plt <> 'N'
710aAC                   eval      $lbls = 'P'
710aAC                   eval      $zone = w1ptyp
710aAC                   endsl
     *
     C                   eval      $rtes = w1rtes
415b *
415b C                   eval      $rtds = w1rtds
     *
     C                   eval      $trk = w1trk
     *
     C                   eval      $trpl = w1trpl
     *
     C                   eval      $ds = w1ds
510 A*
510 AC                   eval      $cwsum = w1csum
     *
700bAC                   if        w1mgr = 'Y'
700bAC                   call      'CK370'
700bAC                   parm      $pwhse        $lwhse
700bAC                   parm      $rtid         $lrtid
700bAC                   parm      $rte          $lrte             5
700bAC                   parm      *blanks       $lrtn
700bAC                   endif
     *
     C                   eval      $dev = w1dev
     *
     C                   eval      $form = w1form
     *
520bAC                   eval      $rsdt = w1rsdt
520bAC                   eval      $pots = w1pots
520bAC                   eval      $potp = w1potp
520bAC                   eval      $pocw = w1pocw

710aAC                   select
710aAC                   when      w1lbls = 'Y'
640aAC                   eval      $ltype = w1type
710aAC                   when      w1plt <> 'N'
710aAC                   eval      $ltype = w1plt
710aAC                   endsl

640cAC                   eval      $pflbl = *blanks
640cAC                   eval      $pflbl = *blanks
640cAC                   if        w1type = 'L'
640cAC                   eval      $pflbl = w1zone
640cAC                   eval      $ptlbl = w1zon2
640cAC                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Route stop summary option
Zone
Truck summary
Truck pallet summary option
Detail/Summary
Printer device
Form type
Labels
Detail/Summary/Both
Catchweight summary                                               510 A
Print Override Flag                                               510 A
Reprint Type
Transaction Number
Label Number
Selection Zone
Pallet Labels
Manager Ship List
