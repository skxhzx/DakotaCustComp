600aA /copy *libl/qcopysrc,hspecs
750aAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN246L     Customer Returns VIRTUAL SLOTS, No license.
     *  05 January, 2001
     *  Roxanne Harrison
     *    Created using RN246
     *  NOTES
     *    Program creates records in LABEL file, calls
     *    ADDSTDTRN to create PIRTRAN record.
     *
     *  SK112 - 1.02
     *
     *  Revisions
416aA*    11/01/01  RH   4.16a
     *      - If $PPO is *NOSTOCK for returns, no putaway is done,
     *        Label allocated = returned qty, label pick = 0 put away.
416bA*    03/21/02  RH   4.16b
     *      - FIX - create label and trans for each qty UOM.
     *
600 A*    05/17/09  DAS  6.00   P#00045
     *      - Converted to ILE
     *
600aA*    05/17/09  DAS  6.00a
     *      - Added logic to create license
     *      - Added logic to update LICINFO
     *      - Added input parms
     *
600bA*    05/26/09  DAS  6.00b
     *      - Revised to call DRILICENSE with %NOSTOCK instead
     *        of DRISLOT with %RCVIN if PO is *NOSTOCK.
600cA*    05/29/09  GJA  6.00c
     *      - Fix:  License plate was not getting populated in the
     *        LICINFO file for *NOSTOCK processing (zzurcvnostock)
600dA*    06/10/09  DAS  6.00d
     *      - Fix:  Wasn't initializin olcns correctly.
610aA*    08/21/09  DAS  6.10a
     *      - Fix:  Wasn't creating licactive, liclog and licinfo
     *        qty correctly when a normal and brkdn entered together.
610bA*    08/27/09  DAS  6.10b
     *      - Fix:  SSB wasn't being handled correctly everywhere.
640aA*    07/18/12  LMC  6.40a
     *      - Enh:  Added incoming parms to create new LICINFO records.
640bA*    10/11/12  LMC  6.40b
     *      - Fix:  Don't make third call to drilicinfo if lncode(1) is
     *              blank. Items that are not date sensitive were getting
     *              an error.
650aA*    05/24/13  LMC  6.50a
     *      - Enh: RCVRTN transaction for MRC reporting.
650bA*    12/05/12  LMC  6.50b
     *      - Enh:  Added GS1/UCI Scanning                            .
650cA*    06/20/13  LMC  6.50c
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
     *        Added logic to handle PTI for whole order return
650dA*    10/31/13  LMC  6.50d
     *      - Enh: Add incoming parm for the entered pti#
650eA*    12/02/14  LMC  6.50e
     *      - Fix: Need to write batctl records when we return from
     *      the call to PIRBAT# retrieving the next batch# to be used.
700aA*    06/29/15  RH   7.00a
     *      - Enh: Revised to put RCV slot into label record like
     *      PO Receiving PO236 mod 600a.
700bA*    01/05/17  LMC  7.00b
     *      - Enh - Change command from RCVIN to RTNIN to allow
     *        returns slot to be RTNDOCK instead of RCVDOCK.
720aA*    08/09/16  LMC  7.20a   reserved
     *      - Enh: UCI Tracking.
750aA*    06/11/21  LMC  7.50a
     *      - Enh - Adding new return pallet license process.
760aA*    05/02/22  LMC  760a
     *     - The host system FRESHBYTE requires a lot code.
     *       They tell us the lot code is the po&line number
     *       On a call today 4/29/22 they said the lot# was
     *       8 positions, 6 for po with leading zeros and 2 for line
     *       I am assuming the 2 positions for line# should have a
     *       leading zero also. so po 00030001 300 is po line 1.
     *       We will pull the lot code from the license that was
     *       shipped from liclog if the original label was scanned
     *       for the return, and attach that lot coee to the license
     *       entered on the return.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
750aA*----------------------------------------------------------------
750aA*  Binding Directories
750aA*----------------------------------------------------------------

750aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
600aAFLicense   uf a e           k disk
600aDF*iritem   if   e           k disk
     FLabel     o  a e           k disk
650eAFbatctl    o    e           k disk
750aAFpltlcns   if a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
600aA /COPY *libl/qcopysrc,C#SLOT
600aA /COPY *libl/qcopysrc,C#LICINFO
600aA /COPY *libl/qcopysrc,C#LICENSE
600aA /COPY *libl/qcopysrc,C#ITEM
650bA /COPY *libl/qcopysrc,C#UCIINFO
600aAD savever#        s                   like($slver#)

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
     D  $pitem                22     36
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0
     D  $prpal                61     63  0

600aA*  Extra parameters not part of data structure.

600aAD $pindt          s              8  0
600aAD $pfifo          s              8  0
760aA*----------------------------------------------------------------
760aA*  Name constants
760aA*
760aAD freshbyte       c                   const('FRESHBYTE')
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
416aAD  $ltype                81     88
     *
     *   Redefine key
     *
     *                                      19  210$LWHSE
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
416 AD  $lwhse                19     21  0
416 AD  $lrte                 22     26
416 AD  $lpo                  27     35
416 AD  $ltrn#                36     42  0
     *
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
650aAD @crtrcv         c                   const('CRTRCVTRN')
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
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
     * Data structure
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
600aA /COPY *libl/qcopysrc,C#PGMINFDS
600aAD*               sds
600aAD* #prog            *proc
600aAD* #job                 244    253
600aAD* #user                254    263
600aAD* #jobn                264    269
600aAD* #jobdt               276    281  0
600aDD* #jobtm               282    287  0
750aA*----------------------------------------------------------------
750aA* Function prototypes.
750aA*----------------------------------------------------------------

750aA /copy qcopysrc,p.bfcdteti

650cA*----------------------------------------------------------------
650cA*  Prototypes
650cA*----------------------------------------------------------------
650cAD calcpti         pr                  extpgm('CALCPTI')
650cA * Input
650cAD   pGTIN                             like($lgtin)
650cAD   pLOT                              like(pplot)
650cAD   pPackDate                         like($lbcProdD)
650cAD   pPTI                              like(pppti)
650cAD ucilic#         pr                  extpgm('UCILIC#')
650cA * Input
650cAD   unext                       13  0 const
650cAD   uwhse                        3  0 const
750aA*----------------------------------------------------------------
750aA*  Time variables
750aA*----------------------------------------------------------------

750aAD CurrStamploc    s               z
750aAD CurrStampsys    s               z
750aAD CurrStampuc     s               z
750aAD FromStamp       s               z
750aAD ToStamp         s               z
750aAD oldeststamp     s               z
750aAD ts              s               z

750aAD Duration        s              7  2
750aAD TtlMin          s              5  0
750aAD TtlMinSec       s              9  0
750aAD TtlSec          s              9  0
750aAD RemSec          s              3  0

750aAD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Variables
     *
650cAD $lgtin          s             14
650cAD $lbcProdD       s              6  0
650cAD $lbclot         s             20
     D $msgf           s             10
650dAD $pw1pti         s              4  0
650aAD $rtnord         s              9
650cAD $unext          s             13  0
     D #pgmq           s             10
600aAD ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D forevr          s              1
650bAD gs1seqqty       s              5  0
     D help            s              5  0
650bAD j               s              2  0
650cAd k               s                   like($lnrcvqty)
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D pctr            s              3  0
     D ptqty           s              6  0
650cAd pplot           s             20
650cAd pppti           s              4  0
     D q1flg           s              1
     D q1lft           s              5  0
     D q2flg           s              1
     D q2lft           s              5  0
     D q3flg           s              1
     D q3lft           s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D tmpflg          s              1
     D today           s              8  0
     D today6          s              6  0
650cAD unexta          s             13
600aAD w1qty           s                   like($prq1)
600aAD w1umt           s              1
600aAD zmflag          s               n
600aAD zmsflag         s               n
760aAD client          s             10
760aAD client2         s             10
760aAD clientinit      s              3
760aAD clienthost      s             10

600aAD #rcvarea        s              6
600aAD #rcvitem        s                   like($ititem)
600aAD #rcvtype        s                   like($ittype)
600aAD #rcvdesc        s                   like($itdesc)
600aAD #rcvpdsc        s                   like($itpdsc)
600aAD #rcvwhdp        s                   like($itwhdp)
600aAD #rcvstyp        s                   like($itstyp)
600aAD #rcvdesg        s                   like($itdesg)
600aAD #rcvum1         s                   like($itum1)
600aAD #rcvflg1        s                   like($itflg1)
600aAD #rcvum2         s                   like($itum2)
600aAD #rcvumq2        s                   like($itumq2)
600aAD #rcvflg2        s                   like($itflg2)
600aAD #rcvum3         s                   like($itum3)
600aAD #rcvumq3        s                   like($itumq3)
600aAD #rcvdday        s                   like($imdday)
600aAD #rcvmday        s                   like($immday)
600aAD #rcvmflg        s                   like($immflg)
600aAD #rcvuday        s                   like($imuday)
600aAD #rcvnrpk        s                   like($imnrpk)
600aAD #rcvflgd        s                   like($itflgd)
600aAD #rcvcube        s                   like($itcube)
600aAD #rcvswgt        s                   like($itswgt)
600aAD #rcvupc         s                   like($itupc)

600aAD #slotitem       s                   like($ititem)
600aAD #slottype       s                   like($ittype)
600aAD #rcvcwgt        s                   like($itcwgt)
750aAD $rtnpltlcns     s             10
750aAD $hldpicklbl     s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Unchanged.
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
223 D*                    PARM           $PUM1   5
223 D*                    PARM           $PUM2   5
223 D*                    PARM           $PUM3   5
     C                   parm                    $pord             7 0
600aAC                   parm                    $plbl#            7 0
600aAC                   parm                    $pcwgt            9 2
600aAC                   parm                    $pexpd            8 0
600aMC                   parm                    $pindt
600aAC                   parm                    $pfifo
640aAC                   parm                    $pdecvalue       15
640aAC                   parm                    $pmfexpd          8 0
640aAC                   parm                    $pmfgdt           8 0
650aAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $lcns            15
650bAC                   parm                    $plotc           30
650cAC                   parm                    $lgtin
650cAC                   parm                    $lbcProdD
650cAC                   parm                    $lbclot
650dAC                   parm                    $pw1pti
750aAC                   parm                    $rtnpltlcns
750aAC                   parm                    $hldpicklbl
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
600aDC**                 exsr      zzgeti
     *
     C                   exsr      zzusub
     *
     *   Do some clean up before leaving.
     *
     C                   return
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
760aA*
760aA* Get client id.
760aA*
760aAC                   call      'GETCLIENT'
760aAC                   parm                    client
760aAC                   parm                    client2
760aAc                   parm                    clientinit
760aAc                   parm                    clienthost
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
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
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
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
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
600aD *----------------------------------------------------------------
600aD *
600aD *  ZZGETI   Get item info.
600aD **
600aDC**   zzgeti        begsr
600aD **
600aDC**   itkey         chain     piritem                            79
600aDC**                 if        *in79
600aDC**                 eval      itdesc = *blanks
600aDC**                 eval      itpdsc = *blanks
600aDC**                 goto      endgti
600aDC**                 endif
600aD **
600aDC**   endgti        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
600aA*
600aA*  Define key for LICENSE file.
600aA*
600aAC     fileky        klist
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $saToLcns
     *
     *  Define partial key for item LABEL file.
     *
     C     partk2        klist
     C                   kfld                    $pord
     C                   kfld                    $pwhse
600aD **
600aD ** Define key for PIRITEM file.
600aD **
600aDC**   itkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    $pitem
     *
     *
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      e = 0
     *
     *  Initialize quantity left.
     *
     C                   eval      q1lft = $prq1
     C                   eval      q2lft = $prq2
     C                   eval      q3lft = $prq3
     *
     *  Initialize variables.
     *
     C                   eval      need1 = 0
     C                   eval      need2 = 0
     C                   eval      need3 = 0
     C                   eval      pctr = 0
     *
     *
     *   Get total quantity
     C                   eval      ptqty = $prq1
     C                   add       $prq2         ptqty
     C                   add       $prq3         ptqty
     *
     *   Move PO
     *
     ***                  MOVE $PPO      W1ORD
     *
600aA
600aA*  Use DRI interface to get item.
600aA
600aAC                   exsr      clr$item
600aAC                   eval      $itwhse  = $pwhse
600aAC                   eval      $ititem  = $pitem
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETALL'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      ck4err = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   clear                   #rcvitem
600aAC                   clear                   #rcvtype
600aAC                   clear                   #rcvdesc
600aAC                   clear                   #rcvpdsc
600aAC                   clear                   #rcvwhdp
600aAC                   clear                   #rcvstyp
600aAC                   clear                   #rcvdesg
600aAC                   clear                   #rcvum1
600aAC                   clear                   #rcvflg1
600aAC                   clear                   #rcvum2
600aAC                   clear                   #rcvumq2
600aAC                   clear                   #rcvflg2
600aAC                   clear                   #rcvum3
600aAC                   clear                   #rcvumq3
600aAC                   clear                   #rcvnrpk
600aAC                   clear                   #rcvmflg
600aAC                   clear                   #rcvdday
600aAC                   clear                   #rcvmday
600aAC                   clear                   #rcvuday
600aAC                   clear                   #rcvflgd
600aAC                   clear                   #rcvcube
600aAC                   clear                   #rcvswgt
600aAC                   clear                   #slotitem
600aAC                   clear                   #slottype
600aAC                   clear                   #rcvcwgt
600aAC                   goto      enditm
600aAC                   endif
600aA
600aAC                   eval      #rcvitem = $ititem
600aAC                   eval      #rcvtype = $ittype
600aAC                   eval      #rcvdesc = $itdesc
600aAC                   eval      #rcvpdsc = $itpdsc
600aAC                   eval      #rcvwhdp = $itwhdp
600aAC                   eval      #rcvstyp = $itstyp
600aAC                   eval      #rcvdesg = $itdesg
600aAC                   eval      #rcvum1  = $itum1
600aAC                   eval      #rcvflg1 = $itflg1
600aAC                   eval      #rcvum2  = $itum2
600aAC                   eval      #rcvumq2 = $itumq2
600aAC                   eval      #rcvflg2 = $itflg2
600aAC                   eval      #rcvum3  = $itum3
600aAC                   eval      #rcvumq3 = $itumq3
600aAC                   eval      #rcvnrpk = $imnrpk
600aAC                   eval      #rcvmflg = $immflg
600aAC                   eval      #rcvdday = $imdday
600aAC                   eval      #rcvmday = $immday
600aAC                   eval      #rcvuday = $imuday
600aAC                   eval      #rcvflgd = $itflgd
600aAC                   eval      #rcvcube = $itcube
600aAC                   eval      #rcvswgt = $itswgt
600aAC                   eval      #rcvcwgt = $itcwgt
600aA
600aAC     enditm        tag
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
650aAc                   exsr      zzrcvrtncheck
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  ZZLICINFO   Update licinfo
600aA*----------------------------------------------------------------
600aA
600aAC     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $saToLcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*ITEM'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $pitem
     C                   eval      $lnvalnum(1) = 0


     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*RCVTRN#'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = pttrn#


     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*RCVLQTY'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = w1qty

     C*                  if        $plotc <> ' '
     C*                  eval      $lncodeu(4) = *on
     C*                  eval      $lncode(4) = '*LOT'
     C*                  eval      $lncseq(4) = 1
     C*                  eval      $lnvaltyp(4) = 'A'
     C*                  eval      $lnvalchr(4) = $plotc
     C*                  eval      $lnvalnum(4) = 0
     C*                  endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $saToLcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lblbl#

     C                   if        $pexpd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pexpd
     C                   endif

     C                   if        $pindt > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = $pindt
     C                   endif

     C                   if        $pfifo > 0
     C                   eval      $lncodeu(4) = *on
     C                   eval      $lncode(4) = '*FIFODTE'
     C                   eval      $lncseq(4) = 1
     C                   eval      $lnvaltyp(4) = 'N'
     C                   eval      $lnvalchr(4) = ' '
     C                   eval      $lnvalnum(4) = $pfifo
     C                   endif

     C*                  eval      $lncodeu(5) = *on
     C*                  eval      $lncode(5) = '*AVGWGT'
     C*                  eval      $lncseq(5) = 1
     C*                  eval      $lnvaltyp(5) = 'N'
     C*                  eval      $lnvalchr(5) = ' '
     C*                  eval      $lnvalnum(5) = $pcwgt

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
640aA*  Write out Mfg standard and optional license information.

640aAC                   exsr      clr$licinfo
640aA
640aAC                   eval      $lnpgm  = #pgm
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr  = #jobnbr

640aAC                   eval      $lnwhse  = $pwhse
640aAC                   eval      $lntype  = 'P'
640aAC                   eval      $lnlcns  = $saToLcns

640aAC                   if        $pdecvalue > ' '
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGDCOD'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'A'
640aAC                   eval      $lnvalchr(1) = %trim($pdecvalue)
640aAC                   eval      $lnvalnum(1) = 0

640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGEXP'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfexpd
640aAC                   endif

640aAC                   eval      $lncodeu(3) = *on
640aAC                   eval      $lncode(3) = '*MFGDTE'
640aAC                   eval      $lncseq(3) = 1
640aAC                   eval      $lnvaltyp(3) = 'N'
640aAC                   eval      $lnvalchr(3) = ' '
640aAC                   eval      $lnvalnum(3) = $pmfgdt
     c                   else
640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGEXP'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'N'
640aAC                   eval      $lnvalchr(1) = ' '
640aAC                   eval      $lnvalnum(1) = $pmfexpd
640aAC                   endif

640bAC                   if        $pmfgdt  > 0
640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGDTE'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfgdt
640bAC                   endif
640aAC                   endif

640bAc                   if        $lncode(1)  = ' '
640bAc                   else
640aAC                   eval      $dricommand = '*LICINFO'
640aAC                   eval      $drisubcmd  = '%ADD'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      ck4err = *on
640aAC                   exsr      zzzdricop
640bAc                   endif
640aAC                   if        error
640aAC                   endif

417bAC                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650aA*
650aAC     zzrcvrtncheck begsr
650aA*
650aA*  See if RCVRTN transaction is status 2 - start new if needed
650aA*
650aAc                   move      $pord         $rtnord
650aAC                   call      @crtrcv
650aAC                   parm      '*RETURN'     $lcmdr           10
650aAC                   parm      '*CHECK '     $lsubcmd         10
650aAC                   parm      $itwhse       @lwhse            3 0
650aAC                   parm      0             $lpcs             5 0
650aAC                   parm      0             $lpallets         5 0
650aAC                   parm                    $lsavetrn         7 0
650aAC                   parm                    $rtnord           9
650aAC                   parm      $itstyp       $litstyp          1
650aAC                   parm      $itwhdp       $litwhdp          5
650aAC                   parm                    $lrtnr           10
650aAC                   endsr
650bA*----------------------------------------------------------------
650bA*  ZZLICINFONEW   Update licinfo  - new file format
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzlicinfonew;

650bA     // process whole order return
650bA     // uci selection - need to mark original uci records as returned
650cD     //if $ifsltmth = '2' and $pprg = 'RN122';
650cM     if $ifsltmth <> '1' and $pprg = 'RN122';
650bA       exsr zzwholeorderuci;
650bA     endif;
650bA     // first I need to deal with the cross dock licinfo and uciinfo
650bA     if $lcns <> ' ';
650bA       if $ppo = '*NOSTOCK';
650bA       exsr zznstemplcns;
650bA       else;
650bA       exsr zzultemplcns;
650bA       endif;
650bA     endif;
760aA     // need to determine if wee have a lot number to send
760aA     if clienthost = freshbyte and $plbl# > 0;
760aA       exsr clr$license;
760aA       $lilbl#U = *on;
760aA       $lilbl#  = $plbl#;
760aA       $dricommand = '*LICENSE';
760aA       $drisubcmd  = '%GETLABEL';
760aA       $drisys2upd = 'D';
760aA       ck4err = *off;
760aA       exsr zzzdricop;
760aA       if $drireturn = '*OK';
760aA         // now go get the lot field for this license
760aA         if $liolcns  <> ' ';
760aA           exsr clr$licinfo;
760aA           $lnwhse  = $pwhse;
760aA           $lnlcns  = $liolcns;
760aA           $lnseq = 1;
760aA           $dricommand = '*LICINFO';
760aA           $drisubcmd  = '%GET';
760aA           $drisys2upd = 'D';
760aA           ck4err = *on;
760aA           exsr zzzdricop;
760aA           if $lnlot <> ' ';
760aA           $plotc  = $lnlot;
760aA           endif;
760aA         endif;
760aA       endif;
760aA     endif;
650bA     // Write out standard license information
650bA     exsr clr$licinfo;
650bA     $lnwhse  = $pwhse;
650bA     $lnlcns  = $saToLcns;
650bA     $lnseq = 1;

650bA     // $LCNS    SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     // Need to get existing record so we don't overlay lnseqqty
650bA     select;
650bA       when $lcns <> ' ';
650bA         $dricommand = '*LICINFO';
650bA         $drisubcmd  = '%GET';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         exsr zzzdricop;
650bA         if error;
650bA           gs1seqqty = 0;
650bA         else;
650bA           gs1seqqty = $lnseqqty;
650bA         endif;
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = gs1seqqty;
650bA         endif;
650bA         $lnrcvtrn# = pttrn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;
650bA         $lnttllbs = $pcwgt;
650bA         $lnavglbs = $pcwgt / $lnrcvqty;
650bA       other;

650bA         exsr clr$licinfo;
650bA         $lnwhse  = $pwhse;
650bA         $lnlcns  = $saToLcns;
650bA
650bA         $lnseq = 1;

650bA         $lnpo = ' ';
650bA         $lnposeq = 0;
650bA         // going to need to decide if I always use the w1qty.
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = gs1seqqty;
650bA         endif;
650bA         $lnitem = $pitem;
650bA         // LNRCVTYP notes
650bA         // 1 = Manual quantity (original method)
650bA         // 2 = Manual quantity with initial GS1 scan
650bA         // 3 = UCI using Mfg GS1 barcodes
650bA         // 4 = UCI using Internal GS1 barcodes (start with 99)
650bA         // 5 = ASN file

650bA         select;
650bA           //when $plpn <> ' ';
650bA             //$lnrcvtyp = '5';
650bA           when $ifucicde = ' ';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '1';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '2';
650bA             $lnrcvtyp = '3';
650bA           when $ifucicde = '3';
650bA             $lnrcvtyp = '4';
650bA           // don't know exactly what 2 will represent
650bA         endsl;
650bA         $lnrcvtrn# = pttrn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;

650bA         if $pindt > 0;
650bA           $lnentdate = $pindt;
650bA         else;
650bA           $lnentdate = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnenttype = '*FIFODT';
650bA         else;
650bA           if #rcvflgd = 'Y';
650bA             select;
650bA               when #rcvuday > 0 or
650bA                #rcvdday > 0;
650bA                 if #rcvmflg = 'Y';
650bA                   $lnenttype = '*MFGDTE';
650bA                 else;
650bA                   $lnenttype = '*USEDTE';
650bA                 endif;
650bA               other;
650bA                 $lnenttype = '*EXPDTE';
650bA             endsl;
650bA           else;
650bA             $lnenttype = '*ENTDTE';
650bA           endif;

650bA           $lndateflag = #rcvflgd;
650bA           $lnmfgflag = #rcvmflg;

650bA           $lnmfgdays = #rcvmday;
650bA           $lnusrdays = #rcvuday;
650bA           $lndstdays = #rcvdday;
650bA         endif;

650bA         $lnmfgdate = $pmfgdt;

650bA         if $pmfexpd > 0;
650bA           $lnmfgexp = $pmfexpd;
650bA         else;
650bA           $lnmfgexp = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnfifodate = $pfifo;
650bA         else;
650bA           $lnfifodate = 0;
650bA         endif;

650bA         if $pexpd > 0;
650bA           $lnexpdate = $pexpd;
650bA         else;
650bA           $lnexpdate = 0;
650bA         endif;

650bA         if $pdecvalue > ' ';
650bA           $lnmfgcode = $pdecvalue;
650bA         endif;

650bA         $lnttllbs = $pcwgt;
640bA         $lnavglbs = $pcwgt / $lnrcvqty;

650bA         if $plotc <> ' ';
650bA           $lnlot = $plotc;
650bA         endif;

650bA            //if $pbrand <> ' ';
650bA              //$lnbrand = $pbrand;
650bA            //endif;

650bA            // Clam and Shucked information.
650bA            //if $pcode = Clams
650bA               //or $pcode = Shucked;

650bA         $lnhrvdate = 0;
650bA            //if $phdte > 0;
650bA             //$lnhrvdate = $phdte;
650bA            //endif;

650bA            //if $phloc <> ' ';
650bA             //$lnhrvloc = $phloc;
650bA            //endif;

650bA            //if $pcert <> ' ';
650bA             //$lnhrvcert = $pcert;
650bA            //endif;
650bA       //endif;
650bA     endsl;

650cA       // calculate the PTI.
650cA       if $lbclot <> ' ' and $lgtin <> ' ';
650cA         pplot  = %subst($lbclot: 1 : 20);
650dA         if $pw1pti = 0;
650cA           calcpti ($lgtin: pplot: $lbcProdD: pppti);
650dA         else;
650dA           pppti = $pw1pti;
650dA         endif;
650cA         if pppti > 0;
650cA           $lnlotPTI4 = %editc(pppti:'X');
650cA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650cA           // create detail pti records in UCIINFO for use at selection
650cA           // when item is not UCI receiving method
650cA           k = 0;
650dD           //if $ifrcvmth <> '2';
650dM           if $ifrcvmth <> '2' and $ppo <> '*NOSTOCK';
650cA             dou k = $lnrcvqty;
650cA               k = k + 1;
650cA               exsr clr$uciinfo;
650cA               $uiWhse = $pwhse;
650cA               $uiItem = $pitem;
650cA               $uiuci = %trim(%editc(pppti:'X'));
650cA               ucilic#($unext: $pwhse);
650cA               unexta = %editc($unext:'X');
650cA               $uiuciLcns = 'P:' + unexta;
650cA               $uiLcns = $lnlcns;
650cA               $uiseq = 1;
650cA               $uiSerial = ' ';
650cA               // weight is calculated as average
650cA               $uiwgtlbs = $lnavglbs;
650cA               $uiSelTrn# = 0;
650cA               $uiSelLbl# = 0;
650cA               $uiSelOrd = 0;
650cA               $uiSelSeq = 0;
650cA               $uiSelCSeq = 0;
650cA               $uiSelTrax = ' ';
650cA               $uiCrtBy = '2';
720aA               if w1umt = *blanks;
720aA                  w1umt = 'N';
720aA               endif;
720aA               $uiaUTyp  = w1umt;
720aA               $uiaSlUTyp = w1umt;
720aA               if $lgtin = *blanks;
720aA                  $uiaGtin = 0;
720aA               else;
720aA                  $uiaGtin  = %DEC($lgtin:14:0);
720aA               endif;
720aA               $uiaLot   = $lbclot;
720aA               $uiaExpD  = $lnexpdate;
720aA               $uiaEntD  = today;

650cA               $dricommand = '*UCIINFO';
650cA               $drisubcmd  = '%ADD';
650cA               $drisys2upd = 'D';
650cA               ck4err = *on;
650cA               zmflag  = *off;
650cA               exsr zzzdricop;
650cA             enddo;
650cA           endif;
650cA         endif;
650cA       endif;

650bA     $dricommand = '*LICINFO';
650bA     // $lcns SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     if $lcns = ' ';
650bA       $drisubcmd  = '%ADDS';
650bA     else;
650bA       $drisubcmd  = '%CHANGES';
650bA     endif;
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     exsr zzzdricop;
650bA     if error;
650bA     endif;

650bA   endsr;
650bA /end-free

750aA*----------------------------------------------------------------
750aA*
750aA*  ZZPLTLCNS     Return pallet license process
750aA*
750aAC     zzpltlcns     begsr
750aA /free
750aA   if $rtnpltlcns = ' ';
750aA     leavesr;
750aA   endif;
750aA     rnlwhse = $pwhse;
750aA     rnlpltlcns = $rtnpltlcns;
750aA     rnllcns = $saToLcns;
750bA     if $PPRG = 'RN122';
750bA       rnlplbl =  %editc($plbl#:'X');
750bA     else;
750aA       rnlplbl = $hldpicklbl;
750bA     endif;
750aA     rnltype = 'P';
750aA     rnlput  = ' ';
750aA     exsr getcurrstamp;
750aA     rnladdts  = currstampsys;
750aA     rnladduc  = currstampuc;
750aA     rnlputts  = *loval;
750aA     rnlputuc  = *loval;
750aA     write rnlrec;
750aA /end-free
750aAC                   endsr
750aA*----------------------------------------------------------------
750aA*  getcurrstamp  Get current timestamps
750aA*----------------------------------------------------------------
750aA
750aAC     getcurrstamp  begsr

750aMC                   callp     getmicrotime(currstampuc:currstampsys)
750aAC     currstampsys  adddur    bfcoffset:*H  currstamploc

750aAC                   endsr

600bA*---------------------------------------------------------------
600bA*
600bA*  zzurcvNoStock  Write license log record for No sotck.
600bA*
600bAC     zzurcvNoStock begsr

     *    Call license program

     C                   exsr      clr$license

     C                   eval      $liActionU = *on
     C                   eval      $liAction = 'RTN'

     C                   eval      $liETrn#U = *on
     C                   eval      $liETrn# = 0

     C                   eval      $liToLcnsU = *on
     C                   eval      $liToLcns = '*RT'
     C                                       + %editc(pttrn#:'X')
600cAC                   eval      $saToLcns = $liToLcns
600dAC                   eval      $liOLcnsU = *on
600dAC                   eval      $liOLcns  = $liToLcns

     C                   eval      $liAQty1U = *on
     C                   eval      $liAQty1 = 0
     C                   eval      $liAQty2 = 0
     C                   eval      $liAQty3 = 0
     C                   select
610bDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610bMC                   when      w1umt = 'N'
     C                   eval      $liAQty1 = w1qty
     C                   when      w1umt = '1'
610bDC**                           or w1umt = 'N' and #rcvtype = 'S'
     C                   eval      $liAQty2 = w1qty
     C                   when      w1umt = '2'
610bDC**                           or w1umt = '1' and #rcvtype = 'S'
     C                   eval      $liAQty3 = w1qty
     C                   endsl

     C                   eval      $liToWhseu = *on
     C                   eval      $liToWhse = $pwhse
     C                   eval      $liToItemU = *on
     C                   eval      $liToItem = #rcvitem

     C                   eval      $liToSItemU = *on
     C                   eval      $liToSItem = #rcvitem

     C                   eval      $liTrn#U = *on
     C                   eval      $liTrn# = pttrn#

     C                   eval      $liLbl#U = *on
     C                   eval      $liLbl# = newlbl#

     C                   eval      $liExcdU = *on
     C                   eval      $liExcd = 'NOSTOCK'

     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%NOSTOCK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvnostock
     C                   endif

     C     endurcvnostockendsr
600aA*---------------------------------------------------------------
600aA*
600aA*  zzurcvSlot   Put license into RCV slot
600aA*
600aAC     zzurcvSlot    begsr

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   select
610bDC**                 when      w1umt = 'N' and #rcvtype <> 'S'
610bMC                   when      w1umt = 'N'
     C                   eval      $saqty1 = w1qty
     C                   when      w1umt = '1'
610bDC**                           or w1umt = 'N' and #rcvtype = 'S'
     C                   eval      $saqty2 = w1qty
     C                   when      w1umt = '2'
610bDC**                           or w1umt = '1' and #rcvtype = 'S'
     C                   eval      $saqty3 = w1qty
     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on

     C                   eval      $saToLcns = '*RT'
     C                                       + %editc(pttrn#:'X')

     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
600dMC                   eval      $saOLcns  = $saToLcns

     C                   eval      $dricommand = '*SLOT'
700bDC*                  eval      $drisubcmd  = '%RCVIN'
700bMC                   eval      $drisubcmd  = '%RTNIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

     C     endurcvslot   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
     C                   eval      @pgrp1 = 'R'
     *
     *
     *  Get batch number for labels.
     *
     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat             7 0
650eA*
650eA*     - Create batch control record.
650eA*
650eAC                   eval      btbat# = $pbat
650eAC                   eval      btwhse = $pwhse
650eAC                   eval      bttype = '*RTN    '
650eAC                   eval      btstat = ' '
650eAC                   eval      btrte = ' '
650eAC                   eval      $cvcmd = '*CURCMD '
650eAC                   call      @cvtdt
650eAC                   parm                    $cvtdt
650eAC                   eval      btstrd = $cvd8o
650eAC                   time                    btstrt
650eAC                   eval      btstrb = #user
650eAC                   write     btrec
     *
416b *  Create transaction and label for each UOM qty.
600aAC                   eval      w1qty = 0
416bAC                   if        $prq1 <> 0
416bAC                   eval      q1flg = *on
610aDC**                 eval      w1umt = 'N'
610aDC**                 eval      w1qty = $prq1
416bAC                   else
416bAC                   eval      q1flg = *off
416bAC                   endif
416bAC                   if        $prq2 <> 0
416bAC                   eval      q2flg = *on
610aDC**                 eval      w1umt = '1'
610aDC**                 eval      w1qty = $prq2
416bAC                   else
416bAC                   eval      q2flg = *off
416bAC                   endif
416bAC                   if        $prq3 <> 0
416bAC                   eval      q3flg = *on
610aDC**                 eval      w1umt = '2'
610aDC**                 eval      w1qty = $prq3
416bAC                   else
416bAC                   eval      q3flg = *off
416bAC                   endif
     *
416bAC     nxtl1         tag
     *        Get transaction number.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
600aA
600aAC                   call      'PIRLBL#'
600aAC                   parm                    newlbl#           7 0
610aA
610aA*  Set w1 fields
610aA
610aAC                   select
610aAC                   when      q1flg = *on
610aAC                   eval      w1umt = 'N'
610aAC                   eval      w1qty = $prq1
610aAC                   when      q2flg = *on
610aAC                   eval      w1umt = '1'
610aAC                   eval      w1qty = $prq2
610aAC                   when      q3flg = *on
610aAC                   eval      w1umt = '2'
610aAC                   eval      w1qty = $prq3
610aAC                   endsl
600aA
600aA*  Create license
600aA
600bAC                   if        $ppo = '*NOSTOCK'
600bAC                   exsr      zzurcvNoStock
600bAC                   else
600aAC                   exsr      zzurcvSlot
600bAC                   endif
600aA
     ***********************************************
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *
     C                   eval      tmpflg = *off
     *
     *
     *        Create label record.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
600aMC                   eval      lbwhdp = #rcvwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = 0
600aMC                   eval      lbstyp = #rcvstyp
     C                   eval      lbqryf = 0
     C                   eval      lbdisp = *blanks
700aAC                   if        $ppo <> '*NOSTOCK'
700aAC                   eval      lbaisl = $slaisl
700aAC                   eval      lbloc = $slloc
700aAC                   eval      lbrlvl = $slrlvl
700aAC                   eval      lbhand = $slhand
700aAC                   eval      lbstyp = $slstyp
700aAC                   eval      lbdisp = $sldisp
700aAC                   endif
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = $pitem
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = $ppo
     C                   eval      lbord = $pord
     C                   eval      lbqalc = $prq1
416bD**         $PPO      IFEQ '*NOSTOCK'
416bD**                   Z-ADD0         LBQPCK
416bD**                   ELSE
416bD**                   Z-ADD$PRQ1     LBQPCK
416bD**                   ENDIF
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *
     C                   select
     *        Create label record for Normal qty.
610bDC**                 when      q1flg = *on
610bMC                   when      q1flg = *on and #rcvtype <> 'S'
416bD**         $PRQ1     IFGT 0
416bAC                   if        $ppo = '*NOSTOCK'
416bAC                   eval      lbqpck = 0
416bAC                   else
416bAC                   eval      lbqpck = $prq1
416bAC                   endif
416bMC                   eval      q1flg = *off
     C                   eval      lbutyp = 'N'
600aMC                   eval      lbucod = #rcvum1
600aMC                   eval      lbucub = #rcvcube
610bMC     lbucub        mult      lbqpck        lbcube
600aMC                   eval      lbuwgt = #rcvswgt
610bMC     lbuwgt        mult      lbqpck        lbswgt
416bD**                   ENDIF
     *
     *        Create label record for breakdown 1 qty.
     *
610bDC**                 when      q2flg = *on
610bMC                   when      q2flg = *on and #rcvtype <> 'S'
610bAC                             or q1flg = *on and #rcvtype = 'S'
416bD**         $PRQ2     IFGT 0
416bAC                   if        $ppo = '*NOSTOCK'
416bAC                   eval      lbqpck = 0
416bAC                   else
610bAC                   if        q1flg = *on and #rcvtype = 'S'
610bAC                   eval      lbqpck = $prq1
610bAC                   else
416bAC                   eval      lbqpck = $prq2
610bAC                   endif
416bAC                   endif
610bAC                   if        q1flg = *on and #rcvtype = 'S'
610bAC                   eval      q1flg = *off
610bAC                   eval      lbutyp = 'N'
610bAC                   else
416bMC                   eval      q2flg = *off
     C                   eval      lbutyp = '1'
610bAC                   endif
600aMC                   eval      lbucod = #rcvum2
600aMC                   if        #rcvumq2 <> 0
600aMC     #rcvcube      div(h)    #rcvumq2      lbucub
610aMC     lbucub        mult      lbqpck        lbcube
600aMC     #RCVswgt      div(h)    #rcvumq2      lbuwgt
610aMC     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
416bD**                   ENDIF
     *
     *        Create label record for breakdown 2 qty.
     *
610bDC**                 when      q3flg = *on
610bMC                   when      q3flg = *on and #rcvtype <> 'S'
610bAC                             or q2flg = *on and #rcvtype = 'S'
416bD**         $PRQ3     IFGT 0
416bAC                   if        $ppo = '*NOSTOCK'
416bAC                   eval      lbqpck = 0
416bAC                   else
610bAC                   if        q2flg = *on and #rcvtype = 'S'
610bAC                   eval      lbqpck = $prq2
610bAC                   else
416bAC                   eval      lbqpck = $prq3
610bAC                   endif
416bAC                   endif
610bAC                   if        q2flg = *on and #rcvtype = 'S'
610bAC                   eval      q2flg = *off
610bAC                   eval      lbutyp = '1'
610bAC                   else
416bMC                   eval      q3flg = *off
     C                   eval      lbutyp = '2'
610bAC                   endif
600aMC                   eval      lbucod = #rcvum3
600aMC                   if        #rcvumq2 <> 0  and
600aMC                             #rcvumq3 <> 0
600aMC     #rcvcube      div(h)    #rcvumq2      lbucub
600aMC     lbcube        div(h)    #rcvumq3      lbucub
610bMC     lbucub        mult      lbqpck        lbcube
600aMC     #rcvswgt      div(h)    #rcvumq2      lbuwgt
600aMC     lbswgt        div(h)    #rcvumq3      lbuwgt
610bMC     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
416bD**                   ENDIF
     *
416bAC                   endsl
     *
     C                   eval      lbtrn# = pttrn#
600aAC                   eval      lblbl# = newlbl#
600aDC**                 call      'PIRLBL#'
600aDC**                 parm                    lblbl#
213 AC                   eval      lbgrp1 = @pgrp1
213 AC                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *
     *        Create transaction record.
     *
600aMC                   eval      @pwhdp = #rcvwhdp
600aMC                   eval      @pstyp = #rcvstyp
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTRTN'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
600aMC                   parm      #rcvwhdp      @pwhdp            5
600aMC                   parm      #rcvstyp      @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $ppo          @ppo              9
     C                   parm      'R'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *
412 AC                   eval      $prtn = '*OK     '
412 AC                   eval      $pord = $pbat
416aA*
416aA*        Close transaction if *RETURN with no put away.
416aA*
416aAC                   if        $ppo = '*NOSTOCK'
416aAC                   eval      $lcmd = '*CLOSE  '
416aAC                   eval      $ltype = '*INTER  '
416aAC                   eval      $lwhse = 0
416aAC                   eval      $lrte = *blanks
416aAC                   eval      $lpo = *blanks
416aAC                   eval      $ltrn# = pttrn#
416aA*
416aAC                   call      'PT132'
416aAC                   parm                    $lparm
416aAC                   endif
600aA
600aA*    Update licinfo.
600aA
650bDC*                  exsr      zzlicinfo
650bMC                   exsr      zzlicinfonew
750aAc                   exsr      zzpltlcns
600aA*
600aA*  Create license record.
600aA*
600aAC     fileky        chain     license                            7978
600aA*
600aAC                   eval      liwhse = $pwhse
600aAC                   eval      lilcns = $saToLcns
600aAC                   eval      litrn# = pttrn#
600aA*     Record not found. Try adding record.
600aA*
600aAC                   if        *in79
600aAC                   write     lirec                                76
600aAC                   endif
     *
416bAC                   if        q1flg = *on  or
416bAC                             q2flg = *on  or
416bAC                             q3flg = *on
416bAC                   goto      nxtl1
416bAC                   endif
     *
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  ZZNSTEMPLCNS Process NO stock temporary license
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zznstemplcns;
650bA   // records that have a NS temporary license from gs1 scanning.
650bA   // These records are used to update the orginal uci that is returned
650bA   // Let's handle the uciinfo file first
650bA     dou $drireturn = '*DONE';
650bA       exsr clr$uciinfo;
650bA
650bA       $uiWhse = $pwhse;
650bA       $uilcns = $lcns;
650bA
650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%GET1UCI  ';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       if $drireturn <> '*DONE';

650bA         // Now get the original uci from selection to update with
650bA         // the return transaction number
650bA
650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%GET2RTN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         else;

720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'RTNORG';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;
650bA         $uirtntrn#  = pttrn#;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%RETURN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA         endif;
650bA         // now delete the originals

650bA         $uilcns = $lcns;
720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'DLTNOSTK';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%DELETE1';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA       endif;
650bA     enddo;
650bA   // Now let's handle the replacement of the licinfo records

650bA   for j = 1 to 99;
650bA   exsr clr$licinfo;

650bA   // Get the temp license record
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;
650bA   $lnseq = j;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%GET';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA     leave;
650bA   endif;

650bA   // Replace with new license - this will actually write a new record
650bA   // With the data from the temporary record
650bA   $lnlcns  = $satolcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%REPLACE';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endfor;
650bA   // Now delete the temporary gs1/uci xdock
650bA   exsr clr$licinfo;
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%DELETEALL';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endsr;
650bA /end-free

650bA*----------------------------------------------------------------
650bA*----------------------------------------------------------------
650bA*  ZZULTEMPLCNS Replace licinfo & uciinfo temp lcns with *RT license
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzultemplcns;
650bA   // records that have a temporary license from gs1 scanning.
650bA   // will need to get the temp license record data, then replace the
650bA   // licinfo with the same data but real license.
650bA   // must loop to process all the licinfo seq#
650bA   // Let's handle the uciinfo file first
650bA      dou $drireturn = '*DONE';
650bA       exsr clr$uciinfo;
650bA
650bA       $uiWhse = $pwhse;
650bA       $uilcns = $lcns;
650bA
650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%GET1UCI  ';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       if $drireturn <> '*DONE';

720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'RTN';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;
650bA         // replace - which will add a new record
650bA         $uilcns = $satolcns;
720aA         $uialcns = $satolcns;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%REPLACE';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA         // now delete the originals

650bA         $uilcns = $lcns;
720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'DLTTEMP';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%DELETE1';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA         // Now get the original uci from selection to update with
650bA         // the return transaction number
650bA
650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%GET2RTN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
720aA         // Lets add some more stuff for tracking
720aA         $uiaction = 'RTNORG';
720aA         $uiaolcns = $uilcns;
720aA         $uiaddpgm  = #pgm;

650bA         $uirtntrn#  = pttrn#;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%RETURN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA       endif;
650bA     enddo;

650bA   // Now let's handle the replacement of the licinfo records

650bA   for j = 1 to 99;
650bA   exsr clr$licinfo;

650bA   // Get the temp license record
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;
650bA   $lnseq = j;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%GET';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA     leave;
650bA   endif;

650bA   // Replace with new license - this will actually write a new record
650bA   // With the data from the temporary record
650bA   $lnlcns  = $satolcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%REPLACE';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endfor;
650bA   // Now delete the temporary gs1/uci xdock
650bA   exsr clr$licinfo;
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%DELETEALL';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endsr;
650bA /end-free

650bA*----------------------------------------------------------------
650bA*  ZZWHOLEORDERUCI - Update original uci with return transation#
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzwholeorderuci;
650bA     // update previously selected UCI and mark with return tran
650bA     exsr clr$uciinfo;
650bA
650bA     $uiWhse = $pwhse;
650bA     $uisellbl# = $plbl#;
650bA     $uirtntrn#  = pttrn#;
650bA     $uilcns = $satolcns;
650bA     $uichgemp = $emp#;
650bA     $uichgusr = #curruser;
650bA     $uichgpgm  = #pgm;
650bA     $uichgjob  = #job;
650bA     $uichgnbr = #jobnbr;
720aA     // Lets add some more stuff for tracking
720aA     $uiaction = 'RTNWHLORD';
720aA     $uiaolcns = $uilcns;
720aA     $uiaddpgm  = #pgm;
650bA
650bA     $dricommand = '*UCIINFO';
650bA     $drisubcmd  = '%RTNWHLORD';
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     zmflag  = *off;
650bA     exsr zzzdricop;
650bA     if error;
650bA     endif;

650bA   endsr;
650bA /end-free
650cA*----------------------------------------------------------------
650cA*  ZZWHOLEORDERPTI - Update original PTI with return transation#
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA   begsr zzwholeorderpti;
650cA     // update previously selected PTI and mark with return tran
650cA     exsr clr$uciinfo;
650cA
650cA     $uiWhse = $pwhse;
650cA     $uisellbl# = $plbl#;
650cA     $uirtntrn#  = pttrn#;
650cA     $uilcns = $satolcns;
650cA     $uichgemp = $emp#;
650cA     $uichgusr = #curruser;
650cA     $uichgpgm  = #pgm;
650cA     $uichgjob  = #job;
650cA     $uichgnbr = #jobnbr;
650cA
650cA     $dricommand = '*UCIINFO';
650cA     $drisubcmd  = '%RTNWHLORD';
650cA     $drisys2upd = 'D';
650cA     ck4err = *on;
650cA     zmflag  = *off;
650cA     exsr zzzdricop;
650cA     if error;
650cA     endif;

650cA   endsr;
650cA /end-free
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
600aA*  clr$license  Clear $license data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$licinfo  Clear $licinfo data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
650bAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

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
650bA*----------------------------------------------------------------
650bA*  clr$uciinfo  Clear $uciinfo data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$uciinfo   begsr
650bAC                   eval      savever# = $uiver#
650bAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650bAC                   eval      $uiver# = savever#
650bAC                   eval      $uiaddemp = $emp#
650bAC                   eval      $uiaddusr = #curruser
650bAC                   eval      $uiaddpgm  = #pgm
650bAC                   eval      $uiaddjob  = #job
650bAC                   eval      $uiaddnbr = #jobnbr
650bAC                   endsr

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
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
650bAC                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
650bAC                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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

     C                   when      %error and ck4err = *on
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

417yMC                   when      $drireturn <> '*OK' and ck4err = *on
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
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
650bAC                   eval      $licinfo2 = $dridata2
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $license = $dridata
600aAC                   eval      $license2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      ck4err = *off
     C     enddricop     endsr
