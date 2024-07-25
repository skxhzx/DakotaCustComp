     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR645     Reprint route - Traffic cop
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*  04/12/04  MLB  4.17
     *    - Enh: Added support to call OR646 - Select Route Trans-
     *      actions for Audit. Changed program to receive route id.
     *
510 A*  03/31/07  DAS  5.10
     *    - Enh: Added support to call OR660C = Catchweight summary
     *
520aA*    07/02/08  DAS  5.20a
     *      - Enh: Added client custom code support.
     *
520bA*    07/02/08  DAS  5.20b
     *      - Fix: ZZCHK1 using wrong indicator for audit field.
     *
520 A*  01/23/08  CWM  5.20
     *    - Enh: Added support to process Over Ride Print File
520cA*  02/13/09  CWM  5.20c
     *    - Enh: Converted changes to current source code
520dA*  03/12/09  CWM  5.20d
     *    - Enh: Converted source to ILE
640aA*  03/03/11  JCJ  6.40a
     *    - Enh: Added reprint options by Transaction and Label.
640bA*  06/14/11  JCJ  6.40b
     *    - Fix: Added option B to Pallet Report.
     *
640cA*  06/29/11  JCJ  6.40c
     *    - Enh: Added label range for reprint by label number.
     *    - Enh: Renamed display file from OR64501 to OR64502 per
     *           GUI standards.
     *
700aA*  10/29/15  JCJ  7.00a
     *    - Enh: Added pallet label reprint.
     *
710aA*  08/25/17  NLK  7.10a   (in progress)
     *    - FIX: Screen allows 7 character for Label and Trax#
     *           need to increase to 10.  MOST Pick Labels
     *           display lbl# so not an issue BUT Saval does not.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWaA*    07/02/08  DAS  CTWa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to reprint
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
700aA*  21 - 34   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640aA ***or645fm   cf   e             workstn
640cD*or64501   cf   e             workstn
700aD*or64502   cf   e             workstn
710aD *or64503   cf   e             workstn
710aMFor64504   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
520aAFreports   if   e           k disk
640aAFpltsum12  if   e           k disk
640aAFlabel     if   e           k disk
     Fwarehs    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
417 D*                   DESC    1   7 60
510 D*                   DESC    1   8 60
520 D*DESC            S             60    DIM(9) CTDATA PERRCD(1)
640aD*DESC            S             60    dim(10) ctdata perrcd(1)
700aD*DESC            S             60    dim(14) ctdata perrcd(1)
700aMD desc            s             60    dim(15) ctdata perrcd(1)
520aA*----------------------------------------------------------------
520aA*  Customer id
520aA*
520aAD  @getcl         c                   'GETCLIENT'
CTWaA /COPY QCOPYSRC,ID#CITYWHO
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
700aAD  $lplid                54     60  0
     *
520aAD $parms          ds
520aAD  $pcmd#                 1      8
520aAD  $pprg#                 9     18
520aAD  $puky#                19     68
520aAD  $prtn#                69     76
520aAD  $perm#                77    136
520aAD  $pmsg#                77     80
520aA*Redefine Key
520aAD  $rdpr#                19     28
520aAD  $rdsq#                29     31    inz('000')
520aAD  $rdwh#                32     34
520aAD  $rdds#                35     64
520aAD  $rdfl#                68     68
     *
417 A*----------------------------------------------------------------
417 A*  Partial key redefinition
417 A*
417 AD $prtky          ds
417 AD  $len50                 1     50
417 AD  $kwhse                 1      3  0
417 AD  $krte                  4      8
417 AD  $krtid                 9     13
417 AD  $kdev                 26     35
417 AD  $kform                36     45
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
CTWaA*----------------------------------------------------------------
CTWaA* Constants
CTWaAD err01           c                   'Not Authorized Reprint Labels'
CTWaAD err02           c                   'Not authorized reprint truck'
CTWaAD err03           c                   'Not authorized reprint audit'
CTWaAD err04           c                   'Not authorized reprint catchweight'
640aAD err05           c                   'Transaction Number required'
640aAD err06           c                   'Label Number required'
640aAD err07           c                   'Selection Zone required'
640cAD err09           c                   'Label range not associated with sam-
640cAD                                     e Transaction.'
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
     D $ppgm           s             10
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
     D wkplts          s             10
     D wktrks          s             10
     D wktsad          s             10
     D wkwght          s             10
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
     *----------------------------------------------------------------
     *  Called programs
     *
710aAD @cvtbarsel      c                   const('CVTBARSEL')
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
417 AC                   parm                    $rtid             5
     C                   parm                    $lbls             1
640aD ***                parm                    $zone             6
640aMC                   parm                    $zone             7
     C                   parm                    $code             6
     C                   parm                    $trk              1
     C                   parm                    $trpl             1
     C                   parm                    $ds               1
510 AC                   parm                    $cwsum            1
     C                   parm                    $prtn             8
     C                   parm                    $dev             10
     C                   parm                    $form            10
520cAC                   parm                    $pots             1
520cAC                   parm                    $potp             1
520cAC                   parm                    $pocw             1
520cAC                   parm                    $polb             1
640aAC                   parm                    $ltype            1
640cAC                   parm                    $pflbl            7
640cAC                   parm                    $ptlbl            7
520aA*
     C                   move      $whse         $pwhse
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
520aAC                   exsr      zzprto
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
520aA*
520aAC                   if        not *in59
520aAC                   eval      $dev = *blanks
520aAC                   eval      $form = *blanks
520aAC                   endif
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
700aMC                   setoff                                       303133
700aAC                   setoff                                       34
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
520  *
520cA**                 MOVE      'N'           W2LBLS
520cAC                   eval      w2audt = 'N'
520cAC                   eval      w2csum = 'N'
520cAC                   eval      w2trpl = 'N'
520cAC                   eval      w2trk = 'N'
520c *
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
CTWaAC                   if        client = citywh
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm            10
CTWaAC                   parm      'ALL'         $copt            20
CTWaAC                   parm      #user         $cuser           10
CTWaAC                   parm      *blanks       $crtn            10
CTWaAC                   if        $crtn = '*NO'
CTWaAC                   eval      alwall = *off
CTWaAC                   endif
CTWaAC                   endif
     *
     *  Verify Y,N option
     *
     C                   if        w1lbls <> 'Y'  and
     C                             w1lbls <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm1001
     C                   endif
700aA*
700aA*  Verify N,Z,T,P option
700aA*
700aAC                   if        w1plt <> 'N'
700aAC                             and w1plt <> 'Z'
700aAC                             and w1plt <> 'T'
700aAC                             and w1plt <> 'P'
700aAC                   eval      error = *on
700aAC                   eval      *in33 = *on
700aAC                   eval      *in13 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     desc(15)      errmsg
700aAC                   exsr      zm1001
700aAC                   endif
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
CTWaAC                   movel     err01         errmsg
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
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err07         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

640aAC                   when      w1type = 'T'
640aAC                             and w1zone =  *blanks
640aAC                   eval      error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err05         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

640aAC                   when      w1type = 'L'
640aAC                             and w1zone =  *blanks
640aAC                   eval      error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     err06         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1

     *  No Initial Error, now check details

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
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(14)      errmsg
640aAC                   exsr      zm1001
640aAC                   goto      endck1
640aAC                   endif

     *  end of when 'Z'

640aAC                   when      w1type = 'T'
640aAC                             and w1zone <> *blanks
640cA*
640cA*  Initialize values.
640cA*
640cAC                   eval      ValPos   = 1
640cAC                   eval      ValCodeLen = %Len(%Trim(w1zone))
640cAC                   eval      ValChar = %Subst(w1zone:ValPos:1)
640aAC                   exsr      zzchkn
640aAC                   if        error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   movel     err08         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1
640aAC                   endif
640aAC                   eval      wktran = %dec(w1zone:7:0)
640aAC     keyps12       chain     pltsum12
640aAC                   if        not %found(pltsum12)
640aAC                   eval      error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(12)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif

     *  end of when 'T'

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
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   movel     err08         errmsg
640aAC                   exsr      zm0105
640aAC                   goto      endck1
640aAC                   endif

710aA*  if Trax#, will need to find label#
710aA*     check for all labels
710a  **                 if        ValCodeLen > 7
710aAC                   movel     w1zone        $pbarcode
710aAC                   exsr      zzchklbl
710aAC                   if        error = *on
710aAC                   eval      *in22 = *on
710aAC                   eval      *in02 = *on
710aAC                   movel     err08         errmsg
710aAC                   exsr      zm0105
710aAC                   goto      endck1
710aAC                   else
710aAC                   move      *blanks       w1zone
710aAC                   movel     $plbl#        w1zone
710aAC                   endif
710a  **                 endif

640aAC                   eval      labelfound = 'N'
640aAC                   eval      wklabel = %dec(w1zone:7:0)
640aAC     wklabel       setll     label
640aAC                   dou       %eof(label)
640aAC     wklabel       reade     label
640aAC                   if        not %eof(label)
640aAC                   if        lbrte = $rtid
640aAC                   eval      labelfound = 'Y'
640cAC                   eval      wrktrn1 = lbtrn#
640aAC                   leave
640aAC                   endif
640aAC                   endif
640aAC                   enddo
640aAC                   if        labelfound = 'N'
640aAC                   eval      error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(13)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif
640cAC                   endif
640cA*  to label
710a *     It was decided when using 'L', don't allow 2nd range field
710a *     Remove lots of code below.
640cAC                   if        w1zon2 <> *blanks
710aAC                             and w1zon2 <> w1zone
710aAC                   eval      error = *on
710aAC                   eval      w1zon2 = *blanks
640cA *                  eval      ValPos   = 1
640cA *                  eval      ValCodeLen = %Len(%Trim(w1zon2))
640cA *                  eval      ValChar = %Subst(w1zon2:ValPos:1)
640cA *                  exsr      zzchkn
640cAC                   if        error = *on
640cAC                   eval      *in31 = *on
640cAC                   eval      *in11 = *on
710aAC                   eval      err08 = 'Range not for L type-Press +
710aAC                                        Enter for single label'
640cAC                   movel     err08         errmsg
640cAC                   exsr      zm0105
640cAC                   goto      endck1
640cAC                   endif

640cA **                 eval      labelfound = 'N'
640cA **                 eval      wklabel = %dec(w1zon2:7:0)
640cA **   wklabel       setll     label
640cA **                 dou       %eof(label)
640cA **   wklabel       reade     label
640cA **                 if        not %eof(label)
640cA **                 if        lbrte = $rtid
640cA **                 eval      labelfound = 'Y'
640cA **                 eval      wrktrn2 = lbtrn#
640cA **                 leave
640cA **                 endif
640cA **                 endif
640cA **                 enddo
640cA **                 if        labelfound = 'N'
640cA **                 eval      error = *on
640cA **                 eval      *in31 = *on
640cA **                 eval      *in11 = *on
640cA **                 eval      errmsg = *blanks
640cA **                 movel     desc(14)      errmsg
640cA **                 exsr      zm1001
640cA **                 endif
640cA **                 if        wrktrn1 <> wrktrn2
640cA **                           and error = *off
640cA **                 eval      error = *on
640cA **                 movel     err09         errmsg
640cA **                 exsr      zm0105
640cA **                 goto      endck1
640cA **                 endif
640cAC                   endif
     *  end of when 'L'
640aAC                   endsl

640bA*
640cAC                   if        w1zone <> *blanks
640cAC                             and w1zon2 = *blanks
640cAC                             and error <> *on
640cAC                   eval      w1zon2 = w1zone
640cAC                   endif
640cA*
640aAC                   endif
700aA*
700aA*  Verify Z,T,P option for pallet label reprint
700aA*
700aAC                   if        w1plt <> 'N'
700aA*
700aA*  Verify ZONE option
700aA*
700aAC                   select
700aAC                   when      w1plt = 'Z'
700aAC                             and w1ptyp = *blanks
700aAC                   eval      error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     err07         errmsg
700aAC                   exsr      zm0105
700aAC                   goto      endck1
700aA*
700aA*  Verify Transaction
700aA*
700aAC                   when      w1plt = 'T'
700aAC                             and w1ptyp = *blanks
700aAC                   eval      error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     err07         errmsg
700aAC                   exsr      zm0105
700aAC                   goto      endck1
700aA*
700aA*  Verify Pallet number
700aA*
700aAC                   when      w1plt = 'P'
700aAC                             and w1ptyp = *blanks
700aAC                   eval      error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     err07         errmsg
700aAC                   exsr      zm0105
700aAC                   goto      endck1

700aAC                   when      w1plt = 'Z'
700aAC                             and w1ptyp <> *blanks
700aAC                             and w1ptyp <> '*ALL'
700aAC                   eval      $lcmd = '*VERIFY '
700aAC                   move      $whse         $lwhse
700aAC                   eval      $lrtid = $rtid
700aAC                   eval      $lszon = w1ptyp
700aAC                   eval      $ltrn# = *zeros
700aAC                   eval      $llbl# = *zeros
700aAC                   call      'OR901'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*PGMQ   '
700aAC                   eval      error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     desc(14)      errmsg
700aAC                   exsr      zm1001
700aAC                   goto      endck1
700aAC                   endif

700aAC                   when      w1plt = 'T'
700aAC                             and w1ptyp <> *blanks
700aAC                             and w1zone <> '*ALL'
700cA*
700cA*  Initialize values.
700cA*
700cAC                   eval      ValPos   = 1
700cAC                   eval      ValCodeLen = %Len(%Trim(w1ptyp))
700cAC                   eval      ValChar = %Subst(w1ptyp:ValPos:1)
700aAC                   exsr      zzchkn
700aAC                   if        error = *on
700aAC                   eval      *in34 = *on
700aAC                   eval      *in14 = *on
700aAC                   movel     err08         errmsg
700aAC                   exsr      zm0105
700aAC                   goto      endck1
700aAC                   endif
700aAC                   eval      wktran = %dec(w1ptyp:7:0)
700aAC     keyps12       chain     pltsum12
700aAC                   if        not %found(pltsum12)
700aAC                   eval      error = *on
640aAC                   eval      *in34 = *on
640aAC                   eval      *in14 = *on
640aAC                   eval      errmsg = *blanks
640aAC                   movel     desc(12)      errmsg
640aAC                   exsr      zm1001
640aAC                   endif
700aAC                   endsl
700aAC                   endif

     *
     *  Verify ZONE option
     *
     *R         W1ZONE    IFNE 'Y'
     *R         W1ZONE    ANDNE'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN22
     *R                   MOVE *ON       *IN02
     *R                   MOVE *BLANKS   ERRMSG
     *R                   MOVELDESC,2    ERRMSG
     *R                   EXSR ZM1001
     *R                   ENDIF
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
CTWaAC                   movel     err02         errmsg
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
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
CTWaAC                   movel     err02         errmsg
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
     *
     *  Verify D,S option
     *
     C                   if        w1ds <> 'D'
640 MC                             and w1ds <> 'S'
640 AC                             and w1ds <> 'B'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
417 A*
417 A*  Verify Transaction Audit Y,N option
417 A*
417 AC                   if        w1audt <> 'Y'  and
417 AC                             w1audt <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in26 = *on
417 AC                   eval      *in06 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   movel     desc(8)       errmsg
417 AC                   exsr      zm1001
417 AC                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint truck rpts
CTWaA*
CTWaAC                   if        client = citywh
CTWaAC                   if        w1audt = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'AUDIT'       $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO'
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in26 = *on
CTWaAC                   eval      *in06 = *on
CTWaAC                   movel     err03         errmsg
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
510 A*
510 A*  Verify Catchweight summary Y,N option
510 A*
510 AC                   if        w1csum <> 'Y'  and
510 AC                             w1csum <> 'N'
510 AC                   eval      error = *on
510 AC                   eval      *in27 = *on
510 AC                   eval      *in07 = *on
510 AC                   eval      errmsg = *blanks
510 AC                   movel     desc(9)       errmsg
510 AC                   exsr      zm1001
510 AC                   endif
CTWaA*
CTWaA*  See if City Wholesale user is allowed to reprint truck rpts
CTWaA*
CTWaAC                   if        client = citywh
CTWaAC                   if        w1audt = 'Y'  and
CTWaAC                             alwall = *off
CTWaAC                   call      'CHKLIST'
CTWaAC                   parm      #prog         $cpgm
CTWaAC                   parm      'CATCHWGT'    $copt
CTWaAC                   parm      #user         $cuser
CTWaAC                   parm      *blanks       $crtn
CTWaA*   User not authorized to reprint labels
CTWaAC                   if        $crtn = '*NO '
CTWaAC                   eval      error = *on
CTWaAC                   eval      *in26 = *on
CTWaAC                   eval      *in06 = *on
CTWaAC                   movel     err04         errmsg
CTWaAC                   exsr      zm0105
CTWaAC                   goto      endck1
CTWaAC                   endif
CTWaAC                   endif
CTWaAC                   endif
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
520aA*
520aA*  Verify Default Print Override Flags
520aA*
520aAC                   select
520aA*
520aA**   W2LBLS        WHENNE    'Y'
520aA**   W2LBLS        ANDNE     'N'
520aA**   W2LBLS        ANDNE     'X'
520aA**                 MOVE      *ON           ERROR
520aA**                 MOVE      *BLANKS       ERRMSG
520aA**                 MOVEL     DESC(10)      ERRMSG
520aA**                 EXSR      ZM1001
520aA**                 MOVE      *ON           *IN20
520aA*
520aAC                   when      w2audt <> 'Y'  and
520aAC                             w2audt <> 'N'  and
520aAC                             w2audt <> 'X'
520aAC                   eval      error = *on
520aAC                   eval      errmsg = *blanks
520aAC                   movel     desc(8)       errmsg
520aAC                   exsr      zm1001
520aAC                   eval      *in26 = *on
520aA*
520aAC                   when      w2trpl <> 'Y'  and
520aAC                             w2trpl <> 'N'  and
520aAC                             w2trpl <> 'X'
520aAC                   eval      error = *on
520aAC                   eval      errmsg = *blanks
520aAC                   movel     desc(4)       errmsg
520aAC                   exsr      zm1001
520aAC                   eval      *in24 = *on
520aa*
520aAC                   when      w2trk <> 'Y'  and
520aAC                             w2trk <> 'N'  and
520aAC                             w2trk <> 'X'
520aAC                   eval      error = *on
520aAC                   eval      errmsg = *blanks
520aAC                   movel     desc(3)       errmsg
520aAC                   exsr      zm1001
520aAC                   eval      *in23 = *on
520aA*
520aAC                   when      w2csum <> 'Y'  and
520aAC                             w2csum <> 'N'  and
520aAC                             w2csum <> 'X'
520aAC                   eval      error = *on
520aAC                   eval      errmsg = *blanks
520aAC                   movel     desc(9)       errmsg
520aAC                   exsr      zm1001
520aAC                   eval      *in27 = *on
520aA*
520aAC                   endsl
520aA*
     *
     C     endck1        endsr

710aA*----------------------------------------------------------------
710aA*
710aA*  ZZchklbl  Verify and grab label #
710aA*
710aAC     ZZchklbl      begsr
710aAC                   move      w1whse        $pwhseb
710aAC                   call      @cvtbarsel
710aAC                   parm                    $pwhseb           3
710aAC                   parm                    $pbarcode        15
710aAC                   parm                    $plbl#            7 0
710aAC                   parm                    $prtid            5
710aAC                   parm                    $punq#            5
710aAC                   parm                    $preturn          8
710aAC                   parm                    $perrmsg         60
710aAC                   if        $preturn = '*OK'
710aAC                   eval      wklabel = $plbl#
710aAC                   else
710aAC                   eval      error = *on
710aAC                   if        ValCodeLen > 7
710aAC                   eval      err08 = 'Invalid value entered for +
710aAC                                        Trax Number'
710aAc                   else
710aAC                   eval      err08 = 'Invalid value entered for +
710aAC                                        Label Number'
710aAC                   endif
710aAC                   endif

710a C     endchklbl     endsr

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
     C                   eval      ValPos   = 1
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
     *  Get character
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
     *     Pick Zone
     *
     C                   when      row# = 09
     C                             and w1type = 'Z'
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
     C                   call      'OR901'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1zone = $lszon
     C                   endif
     *
     *     Transaction
     *
     C                   when      row# = 09
     C                             and w1type = 'T'
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
640cAC                   eval      $lszon = *blanks
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
     C                   call      'OR900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   move      $ltrn#        w1zone
     C                   endif
     *
     *     Label
     *
     C                   when      row# = 09
     C                             and w1type = 'L'
640cAC                             and col# >= 38
640cAC                             and col# <= 44
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
640cAC                   eval      $lszon = *blanks
640cAC                   eval      $ltrn# = *zeros
640cAC                   eval      $llbl# = *zeros
     C                   call      'OR902'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   move      $llbl#        w1zone
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
     C                   endif
640cA*
640cA*     Label
640cA*
640cAC                   when      row# = 09
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
     C                   when      row# = 12
     C                             and w1plt = 'Z'
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
     C                   eval      $ltrn# = *zeros
     C                   eval      $llbl# = *zeros
     C                   call      'OR901'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1ptyp = $lszon
     C                   endif
700aA*
700aA*     Transaction
700aA*
     C                   when      row# = 12
     C                             and w1plt = 'T'
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
     C                   eval      $lszon = *blanks
     C                   eval      $ltrn# = *zeros
     C                   eval      $llbl# = *zeros
     C                   call      'OR900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   move      $ltrn#        w1ptyp
     C                   endif
700aA*
700aA*     Pallet
700aA*
     C                   when      row# = 12
     C                             and w1plt = 'P'
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   move      $whse         $lwhse
     C                   eval      $lrtid = $rtid
     C                   eval      $lszon = *blanks
     C                   eval      $ltrn# = *zeros
     C                   eval      $llbl# = *zeros
700aAC                   eval      $lplt# = *zeros
700aAC                   eval      $lplid = *zeros
     C                   call      'OR904'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
700aAC                   eval      w1ptyp  = %char($lplid)
700aAC                   eval      wrkplt# = %char($lplt#)
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
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
     C                   eval      w1lbls = 'N'
     C                   eval      w1zone = '*ALL  '
     C                   eval      w1trk = 'N'
     C                   eval      w1trpl = 'N'
     C                   eval      w1ds = 'S'
417 AC                   eval      w1audt = 'N'
510 AC                   eval      w1csum = 'N'
640aAC                   eval      w1type = 'Z'
700aAC                   eval      w1plt  = 'N'
700aAC                   eval      w1ptyp = '*ALL'
     *
     C                   movel     '*JOB    '    w1dev
     C                   movel     '*STD    '    w1form
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
520aA*
520aA* Get client id.
520aA*
520aAC                   call      @getcl
520aAC                   parm                    client           10
     C     whkey         klist
     C                   kfld                    $pwhse
640aA*
640aA*  Define partial key for PLTSUM1 file.
640aA*
640aAC     keyps12       klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    $rtid
640aAC                   kfld                    wktran
     *
     C                   eval      $lprg = #prog
     *
520cAC                   movel     'OR695PR'     wktsad
520cAC                   movel     'PS311PR'     wktrks
520cAC                   movel     'OR660PR'     wkplts
520cAC                   movel     'OR660CPR'    wkwght
520cAC                   movel     'OR645  '     $ppgm
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
700aAC                   select
700aAC                   when      w1lbls = 'Y'
     C                   eval      $lbls = w1lbls
     C                   eval      $zone = w1zone
700aAC                   when      w1plt <> 'N'
700aAC                   eval      $lbls = 'P'
700aAC                   eval      $zone = w1ptyp
700aAC                   eval      $pflbl = wrkplt#
700aAC                   endsl
     *
     C                   eval      $trk = w1trk
     *
     C                   eval      $trpl = w1trpl
     *
     C                   eval      $ds = w1ds
510 A*
510 AC                   eval      $cwsum = w1csum
     *
417 A*    Print Transaction Audit Report.
417 A*
417 AC                   if        w1audt = 'Y'
520cA*
520cAC                   if        w2audt = 'Y'
520cAC                   eval      $pcmd# = '*ADD    '
520cAC                   eval      $rdpr# = wktsad
520cAC                   eval      $rdwh# = $whse
520cAC                   eval      $pprg# = $ppgm
520cAC                   eval      $rdfl# = 'Y'
520cAC                   call      'RP152   '
520cAC                   parm                    $parms
520cAC                   endif
520cAC                   if        %subst($parms:69:8) = '*CANCEL '
520cAC                   eval      $prtn = %subst($parms:69:8)
520cAC                   endif
520cA*
417 AC                   move      $whse         $kwhse
417 AC                   eval      $krte = $rte
417 AC                   eval      $krtid = $rtid
520aA*
520aAC                   if        w2audt <> 'X'
520aAC                   eval      $kdev = *blanks
520aAC                   eval      $kform = *blanks
520aAC                   else
520aA*
417 AC                   eval      $kdev = w1dev
417 AC                   eval      $kform = w1form
520aAC                   endif
     *
417 AC                   call      'OR646'
417 AC                   parm                    $prtky
417 AC                   parm      *blanks       $rtncd            8
417 AC                   endif
417 A*
     C                   eval      $dev = w1dev
     *
     C                   eval      $form = w1form
520cA*
520cA**                 MOVE      W2LBLS        $POLB
520cAC                   eval      $pots = w2trk
520cAC                   eval      $potp = w2trpl
520cAC                   eval      $pocw = w2csum

700aAC                   select
700aAC                   when      w1lbls = 'Y'
640aAC                   eval      $ltype = w1type
700aAC                   when      w1plt <> 'N'
700aAC                   eval      $ltype = w1plt
700aAC                   endsl

640cAC                   eval      $pflbl = *blanks
640cAC                   eval      $ptlbl = *blanks
640cAC                   if        w1type = 'L'
640cAC                   eval      $pflbl = w1zone
640cAC                   eval      $ptlbl = w1zon2
640cAC                   endif

700aAC                   if        w1plt = 'P'
700aAC                   eval      $pflbl = wrkplt#
700aAC                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------
520aA*
520aA*  ZZPRTO   Inzintialize Print Over Ride Fields
520aA*
520aAC     zzprto        begsr
520aA*
520aA* DISPLAY TRUCK SUMMARY PRINT OVERRIDE FLAG
520aA*
520aAC     wktrks        chain     reports                            75
520aAC                   if        *in75
520aAC                   eval      *in93 = *on
520aAC                   eval      w2trk = 'X'
520aAC                   else
520aAC                   if        rpscrn <> '3'
520aAC                   eval      *in93 = *on
520aAC                   eval      w2trk = 'X'
520aAC                   endif
520aAC                   endif
520aA*
520aA* DISPLAY TRUCK PALLETS OVER RIDE FLAG
520aA*
520aAC     wkplts        chain     reports                            75
520aAC                   if        *in75
520aAC                   eval      *in94 = *on
520aAC                   eval      w2trpl = 'X'
520aAC                   else
520aAC                   if        rpscrn <> '3'
520aAC                   eval      *in94 = *on
520aAC                   eval      w2trpl = 'X'
520aAC                   endif
520aAC                   endif
520aA*
520aA* DISPLAY WEIGHT PRINT OVER RIDE FLAG
520aA*
520aAC     wkwght        chain     reports                            75
520aAC                   if        *in75
520aAC                   eval      *in95 = *on
520aAC                   eval      w2csum = 'X'
520aAC                   else
520aAC                   if        rpscrn <> '3'
520aAC                   eval      *in95 = *on
520aAC                   eval      w2csum = 'X'
520aAC                   endif
520aAC                   endif
520aA*
520aA* DISPLAY TRANS AUDIT FLAG
520aA*
520aAC     wktsad        chain     reports                            75
520aAC                   if        *in75
520aAC                   eval      *in96 = *on
520aAC                   eval      w2audt = 'X'
520aAC                   else
520aAC                   if        rpscrn <> '3'
520aAC                   eval      *in96 = *on
520aAC                   eval      w2audt = 'X'
520aAC                   endif
520aAC                   endif
520aA*
520aAC                   if        w2trk = 'X'
520aAC                   eval      *in59 = *on
520aAC                   endif
520aA*
520aAC                   if        w2audt = 'X'
520aAC                   eval      *in59 = *on
520aAC                   endif
520aA*
520aAC                   if        w2trpl = 'X'
520aAC                   eval      *in59 = *on
520aAC                   endif
520aA*
520aAC                   if        w2csum = 'X'
520aAC                   eval      *in59 = *on
520aAC                   endif
520aA*
520AAC                   endsr
520aA*    Print Transaction Audit Report.
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Labels
Zone
Truck summary
Truck pallet summary option
Detail/Summary
Printer device
Form type
Transaction audit
Catchweight summary
Label Print Override
Reprint Type
Transaction Number
Label Number
Selection Zone
Pallet Labels
