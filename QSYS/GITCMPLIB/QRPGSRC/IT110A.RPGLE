600bA /copy *libl/qcopysrc,hspecs
     H SrtSeq(*LangIDShr) AltSeq(*Ext)
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT110A    Item maintenance (one whse) - Display
     *  09 July 1994
     *  Dave Sommerville
     *
     *  SK110 - 1.01
     *
     *  Revisions
     *
     *  07 September, 1994
     *  Hemant Kapadia
     *  - Option 12 = Work with slots, added.
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
     *
     *    05/08/96  HNK  2.12
     *      - Added option 8 to work with tie/highs.
     *
     *    06/28/96  HNK  2.14
     *      - Added option 3 to copy an item.
     *
     *    03/06/97  RH   2.19
     *      - Added extended description using ITEMDSC file
     *      - Added DSPSFL1 subfile for extended descriptions.
     *
     *    04/30/97  RH   2.20
     *      - Refresh screen to reset pointer if CANCEL or EXIT was
     *        used during F6 ADD.
     *    07/07/97  RH   2.23
     *      - Change to position to item for screen1.
411  *    05/07/99  DAS  4.11
     *      - If no warehouse is defined, $KWHSE contains blanks.
     *        Add code to Z-ADD 0 to $KWHSE.
411  *    06/13/99  KDE  4.11
     *      - Change to call IT111 for adds/changes versus IT112. This
     *        programs allows for the maintenance of item types.
411  *    06/19/99  HNK  4.11
     *      - Change to pass base item number to IT130 for contract
     *        and alias items.  Item type and Contract/Alias item
     *        number is also passed.
412  *    09/16/99  RH   4.12
     *      - Change to pass base item number to IT130 for breakdown
     *        and same slot breakdown.  Item type and breakdown/same
     *        slot breakdown item number is also passed.
412  *    09/17/99  RH   4.12
     *      - Change to pass base item number & item type to IT810
     *        for Alias and Same slot breakdown items (A&S) to view
     *        quantities.
     *      - Add option 13=Linked Items to view linked items IT170CL
413  *    11/24/99  DAS  4.13
     *      - Took out 412 changes when calling IT810. IT810 has
     *        been modified to identify the type of item being sent.
     *      - Took out 412 changes when call IT130. IT130 has been
     *        modified to identify the type of item being sent.
     *
413a *    02/25/00  DAS  4.13a
     *      - Changed warehouse position cursor indicator from 01
     *        to 03.
     *      - Revised SFLDSP routine to output the POSTN record last.
     *      - Revised SFLDSP routine display POSTN record base on
     *        error condition. If error is on, write record in normal
     *        sequence. Otherwise, write it last.
     *        Re: Before change,the system would only position the
     *            cursor correctly on the first display of the screen.
     *            After that, the cursor would always be positioned
     *            to the first field, warehouse.
     *
415 A*    04/24/01  DAS  4.15
     *      - Added non-displayed options V1 & V2.
     *      - Added non-display option V? to display an explanation
     *        of the 'V' options on the option line. Note: This option
     *        line is automatically set back to the original option
     *        line the next time the screen is displayed.
416aA*    01/17/02  RH   4.16a
     *      - Added option 6 to print item slot list.
     *
500 A*    03/24/05  DAS  5.00
     *      - Identified with 530a for clarity.
     *      - Added non-displayed option LI.
     *      - Added non-display option L? to display an explanation
     *        of the 'L' options on the option line. Note: This option
     *        line is automatically set back to the original option
     *        line the next time the screen is displayed.
     *
500a *    05/17/05  HNK  5.00a
     *      - Added option 91 to display pending receiving transactions
     *
500b *    06/01/05  HNK  5.00b
     *      - Added option 92 to display pending replenishments       s
     *      - Added option 93 to display receipts                     s
     *      - Added F23=More options
     *      - Added support for F24=More keys.
500cA*    06/09/05  MLB  5.00c
     *      - Fix: Revised program to pass item# in field $TITEM.
     *        when calling IT376.
500dA*    06/21/05  MLB  5.00d
     *      - Fix: Revised FGET, FGETP to load $KWHSE into $POUKY
     *        and $POFKY when record not found. Clearing $POUKY and
     *        $POFKY was causing a data decimal error in ITWHSE.
500eA*    09/23/05  RH   5.00e
     *      - Fix: Revised SFLDS1 to position cursor to item each time
     *        Was only positioning to item the first time for extended
     *        description.
510 A*    08/27/06  JCJ  5.10
     *      - Enh: Revised program to add support for Client id
510aA*    12/06/06  RH   5.10a
     *      - Enh: Remove BFCADR, no longer used.
510bA*    02/20/07  JCJ  5.10b
     *      - Enh: Add repack item type.
520aA*    11/28/08  CWM  5.20a    (applied by GJA)
     *      - Enh: Add sort by item description
     *
600 A*    05/26/08  DAS  6.00  P#00045
     *      - Licesne Tracking
     *
600aA*    05/26/08  DAS  6.00a  P#00045
     *      - 500 added from Jordano's code.
     *      - Numbered 530a for clarity.
     *
600bA*    02/26/09  DAS  6.00b
     *      - Converted to ILE
     *      - Added option 80 = Licenses
     *
600cA*    05/13/09  GJA  6.00c
     *      - Increased PRCREC because with convert to ILE
     *        receivers were too small and sending pgm error.
     *
600dA*    05/31/09  CWM  6.00d
     *      - Fixed sort by item desc
     *
610aA*    12/16/10  DAS  6.10a
     *      - Revised to convert position field to upper case
     *        when positioning by item number.
     *
640aA*    05/16/11  DAS  6.40a
     *      - Added option 90=View Summary to call SL440.
640bA*    06/26/12  LMC  6.40b
     *      - Added RC option to pass Item to recall.
     *
640cA*    09/05/12  RBD  6.40c
     *      - Added option 11=Subs (item substitutes) to call IT190CL.
     *
710 A*    04/17/17  KDE  7.10
     *      - Added option 14=Cost to maintain item cost in Dakota
     *
710bA*    04/04/18  TDF  7.10b
     *      - Add item search by description
     *      - Renamed IT110AFM to IT110A01 Per webfacing standards
     *      - Previous mod mark was CBIa
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
     *
PCK A*    08/27/06  JCJ  PCK
     *      - Add option 7 & 10 to option line / option list
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CWa A*    11/26/07  RH   CWa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2, change.
     *----------------------------------------------------------------
     *  Client Custom Revisions: MenuMaker
     *
GMMa *    04/23/12  GJA  GMMa
     *      - Revised to convert lower case to upper case for
     *        description.
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
     *
YHAaA*    11/26/07  RH   YHAa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2, change.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCa *    12/06/11  RTR  GFCa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *      - Also removed option 7 from ZOPT, already off screen.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
SVLaA*    04/07/14  RH   SVLa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
FPRaA*    03/26/15  RH   FPRa
     *      - Revised to convert position to desc to all caps.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRY A*    02/11/17  MLB  DRY
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *      - Added DRY to GFCa mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Lieber's
LKFaA*    11/15/19  RH   LKFa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
HPCaA*    11/15/19  RH   HPCa
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
CBI A*    09/02/15  MLB  CBI
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option 2-change, 3-copy, 4-delete.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
710bD*it110a01  cf   e             workstn
710bMFit110a01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(dspsfl1:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fpiritem   if   e           k disk
     F                                     rename(itrec:record)
520aAFpiritem5  if   e           k disk
520aAF                                     rename(itrec:recrd2)
219 AFitemdsc   if   e           k disk
219 AFoptions   if   e           k disk
210 D*IRUSER IF  E           K        DISK
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
640cDD*zopt            s              2    dim(21) ctdata perrcd(21)
710 DD*zopt            s              2    dim(22) ctdata perrcd(22)
710 AD zopt            s              2    dim(23) ctdata perrcd(23)
640cDD*zop2            s              2    dim(20) ctdata perrcd(20)
710 DD*zop2            s              2    dim(22) ctdata perrcd(22)
710 AD zop2            s              2    dim(23) ctdata perrcd(23)
415 D**                  OPTLN   1   2 75
500b **                  OPTLN   1   3 75
600aD**                  OPTLN   1   5 75
600aMD optln           s             75    dim(6) ctdata perrcd(1)
600aD**                  OPTL2   1   5 75
600aMD optl2           s             75    dim(6) ctdata perrcd(1)
500b *                   CMDLN   1   1 79
600dDD*cmdln           s             79    dim(2) ctdata perrcd(1)
600dAD cmdln           s             79    dim(4) ctdata perrcd(1)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
510 A /COPY QCOPYSRC,ID#PACKERS
510 A /COPY QCOPYSRC,ID#CITYWHO
510 A /COPY QCOPYSRC,ID#YHATA
GFCaA /COPY QCOPYSRC,ID#GLAZIER
SVLaA /COPY QCOPYSRC,ID#SAVAL
FPRaA /COPY QCOPYSRC,ID#FPR
GMMaA /COPY QCOPYSRC,ID#GMM
DRY A /COPY QCOPYSRC,ID#DAIRYLA
LKFaA /COPY QCOPYSRC,ID#LKF
HPCaA /COPY QCOPYSRC,ID#HPC
CBI A /COPY QCOPYSRC,ID#Cheney
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kitem                 4     18
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  itwhse                 1      3  0 inz(0)
     D  ititem                 4     18
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
510 AD  $litem                22     36
PCK AD  $lcode                37     38
PCK AD  $ltype                39     39
     *
     *----------------------------------------------------------------
219 A* Data structure
219 A*
219 AD opdata          ds
219 AD  opstyp                 1      1
219 AD  opwhdp                 2      6
219 AD  opum1                  7      8
219 AD  opdum                  9     23
219 AD  opcum                 24     43
219 AD  opcdiv                44     52  2
219 AD  opcaut                53     53
219 AD  opcwrn                54     54
219 AD  opcrng                55     57  1
219 AD  opwum                 58     72
219 AD  opxdsc                73     73
219 AD  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
411 D*             'IT112'               C         @CHGPG
     D @chgpg          c                   const('IT111')
     D @cpypg          c                   const('IT113')
     D @delpg          c                   const('IT114')
     D @prtpg          c                   const('*NONE')
     D @cwght          c                   const('UI110')
     D @lstpg          c                   const('UI300')
640cAD @subpg          c                   const('IT190CL')
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
     D  $pitpe               137    137
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
219 AD  $pxflg                37     37
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
413 AD  errit1                 1     15
413 AD  errtyp                16     16
413 AD  errit2                17     31
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
CWa A* Status message(s)
     D err01           c                   const('Not authorized t-
     D                                     o use option  ')
600dAD*----------------------------------------------------------------
600dA* Status message(s)
600dAD ptdsci          c                   'Position to Item. . . .'
600dAD ptdscd          c                   'Position to Desc. . . .'
     *----------------------------------------------------------------
CWa A* Variables
CWa A*
     D $msgf           s             10
640cAD $subcmd         s              8
     D $titem          s             15
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D k               s              3  0
     D maxvwo          s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nr              s              2  0
     D nxtscr          s              3
     D ocode           s              8
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
600cDD*prcrec          s              2  0
600cMD prcrec          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D uxflag          s              1
     D v               s              2  0
     D viewo           s              1  0
     D warn            s              1
     D whse            s              3  0
     D whsea           s              3
     D x               s              3  0
     D y               s              3  0
520aAD wkitsr          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
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
     *
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
219 A*
219 A*     OPTIONS
219 A*
219 AC     opkey         klist
219 AC                   kfld                    $kwhse
219 AC                   kfld                    ocode
219 A*
219 A*     EXTENDED ITEM DESCRIPTION
219 A*
219 AC     idkey         klist
219 AC                   kfld                    $kwhse
219 AC                   kfld                    ititem
411 A*
411 A*     ITEMLNK file.
411 A*
411 AC     ilkey         klist
411 AC                   kfld                    $kwhse
411 AC                   kfld                    ititem
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
510aD*                    CALL 'BFCADR'
510aD*                    PARM           $RTN    8
510aD*          $RTN      IFEQ '*EXPIRED'
510aD*                    MOVE 'EOJ'     NXTSCR
510aD*                    MOVE '*EXIT   '$RTNCD
510aD*                    ELSE
     C                   exsr      zzinz2
510aD*                    END
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
PCK AC                   select
PCK AC                   when      client = packers
415 AC                   eval      optln1 = optl2(1)
415 AC                   eval      optln2 = optl2(2)
PCK AC                   other
415 AC                   eval      optln1 = optln(1)
415 AC                   eval      optln2 = optln(2)
PCK AC                   endsl
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     C                   seton                                        lr
     C                   endif
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
219 AC                   if        uxflag = *off
     C                   exsr      sfldsp
     C                   read      postnrec                               50
219 AC                   else
219 AC                   exsr      sflds1
219 AC                   read      postnrec                               50
219 AC                   endif
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
413aAC                   setoff                                       03
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
219 AC                   if        uxflag = *off
     C                   read      dspsfc                                 50
219 AC                   else
219 AC                   read      dspsfc1                                50
219 AC                   endif
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
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
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
510aA*
510aA* Get client id.
510aA*
510aAC                   call      @getcl
510aAC                   parm                    client           10
510aA*
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
219 AC                   write     dspsfl1                              79
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
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
710bA*     Search item by description
710bA*
710bAc                   if        *inkh
710bAc                   move      itwhse        pwhse
710bAc                   call      'IT125R'
710bAc                   parm                    scitem           15
710bAc                   parm      'X'           pfrom             1
710bAc                   parm                    psearch          30
710bAc                   parm                    pwhse             3
710bAc                   movel     scitem        ptinp2
710bAc                   endif
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
219 AC                   if        uxflag = '0'
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
219 AC                   else
219 AC     1             do        05            x
219 AC     x             chain     dspsfl1                            79
219 AC                   if        not *in79
219 AC                   eval      option = '  '
219 AC                   update    dspsfl1
219 AC                   endif
219 AC                   enddo
219 AC                   endif
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
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
219 AC                   eval      $pxflg = uxflag
KDE  C                   eval      $pitpe = *blanks
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
520aDC*                  z-add     0             row#
520aDC*                  eval      row = rowin
520aDC*                  z-add     0             col#
520aDC*                  eval      col = colin
520aAC*
520aAC* DISPLAY BY ITEM OR DESCRIPTION
520aAC*
520aAC                   if        wkitsr='I'
520aAC                   eval      wkitsr='D'
600dAC                   eval      k = 3
600dAC                   eval      cmdln1 = cmdln(k)
600dAC                   eval      ptdsc2 = ptdscd
520aAC                   else
520aAC                   eval      wkitsr='I'
600dAC                   eval      k = 4
600dAC                   eval      cmdln1 = cmdln(k)
600dAC                   eval      ptdsc2 = ptdsci
520aAC                   endif
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
219 D*R                   SUB  10        ROW#
219 MC*                  sub       prcrec        row#
520aDC*                  if        row# < 1  or
520aDC*                            row# > dsplyd
520aDC*                  eval      error = *on
520aDC*                  eval      errmsg = *blanks
520aDC*                  exsr      zm0106
520aDC*                  goto      cmd01e
520aDC*                  endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
520aDC*                  eval      $pocmd = '*POSTN2U'
520aDC*                  eval      $pouky = ukey(row#)
520aDC*                  exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
520aDC*                  eval      pagcmd = '*REPOS  '
520aDC                   eval      pagcmd = '*TOP    '
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
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
219 AC                   eval      nr = prcrec
219 AC                   add       1             nr
219 D*R         RECNO     IFLT 11
219 AC                   if        recno < nr
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
219 AC                   if        uxflag = '0'
     C                   write     dspsfl
219 AC                   else
219 AC                   write     dspsfl1
219 AC                   endif
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
219 AC                   if        uxflag = '0'
     C                   write     dspsfc
219 AC                   else
219 AC                   write     dspsfc1
219 AC                   endif
     C                   endsr
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
     C                   eval      repos = *off
     C                   exsr      zzpos
     C     error         cabeq     '1'           ent01e
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
GFCaA*
GFCaA*     Check if user is authorized to use this option.
GFCaAC                   if        client = glazier or
SVLaAC                             client = saval
LKFaAC                             or client = Liebers
HPCaAC                             or client = holtpaper
CBI AC                             or client = Cheney
DRY AC                             or client = dairyland
GFCaAC                   call      'CHKLIST'
GFCaAC                   parm      #prog         $cpgm            10
GFCaAC                   parm      wkoopt        $copt            20
GFCaAC                   parm      #user         $cuser           10
GFCaAC                   parm      *blanks       $crtn            10
GFCaA*       User not authorized to use this option.
GFCaAC                   if        $crtn = '*NO '
GFCaAC                   eval      error = *on
GFCaAC                   eval      cancel = *on
GFCaAC                   eval      errmsg = err01
GFCaAC                   exsr      zm0105
GFCaAC                   goto      ent02e
GFCaAC                   endif
GFCaAC                   endif
GFCaA*
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
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
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
500dAC                   movel     $kwhse        $pouky
     C                   eval      $pofky = *blanks
500dAC                   movel     $kwhse        $pofky
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
     C                   eval      $pouky = *blanks
500dAC                   movel     $kwhse        $pouky
     C                   eval      $pofky = *blanks
500dAC                   movel     $kwhse        $pofky
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
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
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
520aAC*
520aAC                   select
520aAC*
520aAC                   when      wkitsr='I'
     C     fileky        setll     record
520aAC*
520aAC                   when      wkitsr='D'
520aAC     fildky        setll     recrd2
520aAC*
520aAC                   endsl
520aAC*
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
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
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
     C                   eval      refrsh = *on
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
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
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
     *   Change
     *
     C                   when      wkoopt = ' 2'
CWa  *
CWa  *     Check if user is authorized to use this option.
CWa  C                   if        client = citywh
CWa  C                             or client = yhata
SVLaAC                             or client = saval
LKFaAC                             or client = Liebers
HPCaAC                             or client = holtpaper
CBI AC                             or client = Cheney
GFCaAC                             or client = glazier
DRY AC                             or client = dairyland
CWa  C                   call      'CHKLIST'
CWa  C                   parm      #prog         $cpgm            10
CWa  C                   parm      wkoopt        $copt            20
CWa  C                   parm      #user         $cuser           10
CWa  C                   parm      *blanks       $crtn            10
CWa  *       User not authorized to use this option.
CWa  C                   if        $crtn = '*NO '
CWa  C                   eval      error = *on
CWa  C                   eval      cancel = *on
CWa  C                   eval      errmsg = err01
CWa  C                   exsr      zm0105
CWa  C                   goto      endop2
CWa  C                   endif
CWa  C                   endif
CWa  *
     C                   eval      $pcmd = '*CHANGE '
219 AC                   eval      $pxflg = uxflag
KDE  C                   eval      $pitpe = ittype
     C                   call      @chgpg
     C                   parm                    $parms
214 A*
214 A*   Copy
214 A*
214 AC                   when      wkoopt = ' 3'
GFCaA*
GFCaA*     Check if user is authorized to use this option.
GFCaAC                   if        client = glazier or
SVLaAC                             client = saval
LKFaAC                             or client = Liebers
HPCaAC                             or client = Holtpaper
DRY AC                             or client = dairyland
CBI AC                             or client = Cheney
GFCaAC                   call      'CHKLIST'
GFCaAC                   parm      #prog         $cpgm            10
GFCaAC                   parm      wkoopt        $copt            20
GFCaAC                   parm      #user         $cuser           10
GFCaAC                   parm      *blanks       $crtn            10
GFCaA*       User not authorized to use this option.
GFCaAC                   if        $crtn = '*NO '
GFCaAC                   eval      error = *on
GFCaAC                   eval      cancel = *on
GFCaAC                   eval      errmsg = err01
GFCaAC                   exsr      zm0105
GFCaAC                   goto      endop2
GFCaAC                   endif
GFCaAC                   endif
GFCaA*
KDE AC                   if        ittype = ' '  or
KDE AC                             ittype = 'B'  or
510bAC                             ittype = 'R'
KDE  C                   eval      $pitpe = ittype
214 AC                   eval      $pcmd = '*COPY   '
219 AC                   eval      $pxflg = uxflag
214 AC                   call      @cpypg
214 AC                   parm                    $parms
KDE  C                   else
KDE  C                   eval      $prtn = '*ERROR  '
KDE AC                   endif
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
219 AC                   eval      $pxflg = uxflag
KDE  C                   eval      $pitpe = ittype
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   Print Item slot list
     *
     C                   when      wkoopt = ' 6'
416aD*                    MOVE '*PRINT  '$PCMD
416aD*                    CALL @PRTPG
416aD*                    PARM           $PARMS
416a *
416a C                   move      $pwhse        whsea
500cD*R                   MOVE ' '       $TITEM 15
500cMC                   eval      $titem = $pitem
gja  C                   call      'IT375CL'
416a C*****              call      'IT376'
416a C                   parm                    whsea
gja  C                   parm                    $rtncd
gja  C                   parm                    $jobq            10
gja  C                   parm                    $dev             10
gja  C                   parm                    $form            10
416a C                   parm                    $pitem
416a C                   parm                    $titem
     *
     *
     *   View warehouse quantities.
     *
     C                   when      wkoopt = ' 9'
     C                   eval      whse = $pwhse
     *
     C                   call      'IT810'
     C                   parm                    whse
     C                   parm                    $pitem
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
CWa  C     endop2        tag
     C                   endsr
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
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
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
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
219 A*  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
219 D*R         P         IFGE 10
219 MC                   if        p >= prcrec
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
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
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
219 D*R         DSPLYD    ADD  10        GOBACK  20
219 MC     dsplyd        add       prcrec        goback
     C                   if        bot = '1'
219 D*R         GOBACK    IFEQ 10
219 MC                   if        goback = prcrec
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
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
219 A*  OR EXTENDED DESCRIPTION- STOP AFTER 5 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
219 D*R         P         IFGE 10
219 MC                   if        p >= prcrec
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
219 D*R         DSPLYD    ADD  10        GOBACK  20
219 MC     dsplyd        add       prcrec        goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
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
     *  READ FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
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
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
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
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
219 AC                   if        uxflag = '0'
     C                   readc     dspsfl                                 79
219 AC                   else
219 AC                   readc     dspsfl1                                79
219 AC                   endif
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
PCK AC                   select
PCK AC                   when      client = packers
PCK AC     option        lookup    zop2                                   50
PCK AC                   other
     C     option        lookup    zopt                                   50
PCK AC                   endsl
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
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
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
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
219 AC                   if        uxflag = '0'
     C                   if        recno < 11
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
     C                   write     dspsfl
     C                   endif
219 AC                   endif
219 A*
219 A*  Use extended description
219 A*
219 AC                   if        uxflag = '1'
219 AC                   if        recno < 6
219 AC                   add       1             recno
219 AC                   z-add     recno         y
219 A*
219 A*  SAVE FILE AND UNIQUE KEYS
219 A*
219 AC                   eval      fkey(y) = $pofky
219 AC                   eval      ukey(y) = $pouky
219 A*
219 A*  WRITE DISPLAY LINE TO SUBFILE
219 A*
219 AC                   exsr      zzfill
219 AC                   write     dspsfl1
219 AC                   endif
219 AC                   endif
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
219 AC                   if        uxflag = '0'
     C                   write     dspsfc
219 AC                   else
219 AC                   write     dspsfc1
219 AC                   endif
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
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
413aD*  POSITION CURSOR TO ITEM FIELD WHEN NO ERRORS EXIST
413aAC                   if        error = '1'
413aD**                   MOVE '0'       *IN02
413aMC                   eval      *in02 = *off
     C                   write     postnrec
413aAC                   endif
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
223 D*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        not *in79
223 D*R                   MOVE '1'       *IN20
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     *
413aA*  POSITION CURSOR TO ITEM FIELD WHEN NO ERRORS EXIST
413aAC                   if        error <> '1'
413aAC                   eval      *in02 = *on
413aAC                   write     postnrec
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
219 A*
219 A*  SFLDS1   Display subfile 1 , Extended description
219 A*
219 AC     sflds1        begsr
219 A*
219 A*  WRITE OPTION AND COMMAND LINES TO DISPLAY
219 A*
219 AC                   write     optrec
219 AC                   write     cmdrec
219 A*
219 A*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
219 A*
219 AC                   write     morrec
219 A*
219 A*  WRITE POSITION TO FIELD TO DISPLAY
219 A*
223 A*  POSITION CURSOR TO ITEM FIELD WHEN NO ERRORS EXIST
500eAC                   if        error = '1'
500eMC                   eval      *in02 = *off
500eD**                   MOVE '1'       *IN02
219 AC                   write     postnrec
500eAC                   endif
219 A*
219 A*  GET ANY EXISTING VALUES FOR THE OPTIONS
219 A*
219 AC                   exsr      sflop1
219 A*
223 D*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
219 A*
219 AC                   if        error <> '1'
219 AC     1             chain     dspsfl1                            79
219 AC                   if        not *in79
223 D*R                   MOVE '1'       *IN20
219 AC                   update    dspsfl1
219 AC                   endif
219 AC                   endif
219 A*
219 A*  WRITE SUBFILE TO DISPLAY
219 A*
219 AC                   eval      *in01 = *on
219 AC                   eval      recno = 1
219 AC                   write     dspsfc1
500eA*  POSITION CURSOR TO ITEM FIELD WHEN NO ERRORS EXIST
500eAC                   if        error <> '1'
500eAC                   eval      *in02 = *on
500eAC                   write     postnrec
500eAC                   endif
     *
219 AC                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
219 D*R         1         DO   10        X       30
219 MC     1             do        prcrec        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
219 A*
219 A*  SFLOP1   Initialize options for subfile 1, extended description
219 A*
219 AC     sflop1        begsr
219 AC     1             do        05            x
219 AC     x             chain     dspsfl1                            79
219 AC                   if        not *in79
219 AC                   eval      wkokyf = fkey(x)
219 AC                   eval      wkokyu = ukey(x)
219 AC     wkounq        chain     workopt                            78
219 AC                   if        not *in78
219 AC                   eval      option = wkoopt
219 AC                   eval      *in21 = wkoerr
219 AC                   eval      *in20 = wkoerr
219 AC                   else
219 AC                   eval      option = *blanks
219 AC                   eval      *in21 = *off
219 AC                   eval      *in20 = *off
219 AC                   endif
219 AC                   update    dspsfl1
219 AC                   endif
219 AC                   enddo
219 AC                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
413 A*----------------------------------------------------------------
413 A*   IT11001  Work with Tie/Highs not allowed.
413 A*
413 AC     zm1101        begsr
413 AC                   eval      #msgid = 'IT11001'
413 AC                   eval      #msgtp = '*DIAG  '
413 AC                   eval      errmsg = *blanks
413 AC                   eval      errit1 = ititem
413 AC                   eval      errtyp = ittype
413 AC                   eval      errit2 = #bitem
413 AC                   movea     errmsg        $md(1)
412 AC                   exsr      zmpmsg
412 AC                   endsr
     *----------------------------------------------------------------
     *
413 A*  ZZBASE   Get corresponding base item for selected item
     *
413 AC     zzbase        begsr
     *
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum1             2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
500b *
500b *  TEST FOR CMD23 - More options
500b *
500b C                   if        *inkx
500b C                   if        viewo = maxvwo
500b C                   eval      viewo = 1
500b C                   else
500b C                   add       1             viewo
500b C                   endif
500b C                   eval      v = viewo * 2
PCK AC                   select
PCK AC                   when      client = packers
500b C                   eval      optln2 = optl2(v)
500b C                   eval      v = v - 1
500b C                   eval      optln1 = optl2(v)
PCK AC                   other
500b C                   eval      optln2 = optln(v)
500b C                   eval      v = v - 1
500b C                   eval      optln1 = optln(v)
PCK AC                   endsl
500b C                   goto      endcm1
500b C                   endif
     *
500b *  Test for F24 - More keys
500b *
500b C                   if        *inky
     c*
600dAC                   select
     c*
600dAC                   when      K = 2 and wkitsr = 'I'
600dAC                   eval      k = k + 2
     c*
600dAC                   when      K = 2 and wkitsr = 'D'
600dAC                   eval      k = k + 1
     c*
600dAC                   when      K = 3
600dAC                   eval      k = k - 1
     c*
600dAC                   when      K = 4
600dAC                   eval      k = k - 2
     c*
600dAC                   endSl
     c*
600dDC*                  add       1             k
600dDC*                  if        k > 2
600dDC*                  eval      k = 1
600dDC*                  endif
     c*
600dAc                   if        k = 1 or k = 0
600dAc                   eval      k = 4
600dAC                   endif
     C*
500b C                   eval      cmdln1 = cmdln(k)
500b C                   endif
500b *
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 38
413aD**                   MOVE '1'       *IN01
413aMC                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  Test for F9 - Display all warehouses
     *
     C                   if        *inki
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*F9     '
     C                   goto      endcm1
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
520aDC*    filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
520aAC                   select
520aAC*
520aAC                   when      wkitsr='I'
520aDC     filuky        chain     record                             79
520aAC*
520aAC                   when      wkitsr='D'
520aDC     fildky        chain     recrd2                             79
520aAC*
520aAC                   endsl
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
520aDC*    partky        reade     record                                 79
     *
520aAC*
520aAC                   select
520aAC*
520aAC                   when      wkitsr='I'
520aDC     partky        reade     record                                 79
520aAC*
520aAC                   when      wkitsr='D'
520aDC     partky        reade     recrd2                                 79
520aAC*
520aAC                   endsl
     C                   endsr
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
520aDC*    partky        readpe    record                                 79
520aAC*
520aAC                   select
520aAC*
520aAC                   when      wkitsr='I'
520aDC     partky        readpe    record                                 79
520aAC*
520aAC                   when      wkitsr='D'
520aDC     partky        readpe    recrd2                                 79
520aAC*
520aAC                   endsl
520aAC*
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
219 AC     idkey         chain     itemdsc                            79
219 AC                   if        *in79
219 AC                   eval      ixdsc1 = *blanks
219 AC                   eval      ixdsc2 = *blanks
219 AC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    itwhse
520aA*
520aA*  PIRITEM5-warehouse/item description
520aA*
520aAC     fildky        klist
520aAC                   kfld                    itwhse
520aAC                   kfld                    itdesc
     *
     *  Setup option and command display lines.
     *
500b C                   eval      viewo = 1
500b C                   eval      maxvwo = 2
600dAC                   eval      k = 3
600dDC*                  eval      k = 1
600aAC                   eval      wkitsr='I'
600aAC                   eval      ptdsc2 = ptdsci
PCK AC                   select
PCK AC                   when      client = packers
PCK AC                   eval      optln1 = optl2(1)
PCK AC                   eval      optln2 = optl2(2)
PCK AC                   other
     C                   eval      optln1 = optln(1)
212 AC                   eval      optln2 = optln(2)
PCK AC                   endsl
600dDC*                  eval      cmdln1 = cmdln(1)
600dAC                   eval      cmdln1 = cmdln(4)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
411 AC                   eval      $kwhse = 0
     *
     *   Get warehouse for user.
     *
210 D*R         USKEY     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *OFF
210 D*R                   Z-ADDUSWHSE    ITWHSE
210 D*R                   ELSE
210 D*R                   Z-ADD1         ITWHSE
210 D*R                   ENDIF
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     itwhse        parm      0             #whse             3 0
210 A*
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = itwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = itwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aD**                   MOVE '1'       *IN01
413aMC                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aD**                   MOVE '1'       *IN01
413aMC                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = itwhse
     C                   eval      whcode = itwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
223 AC                   eval      *in02 = *on
219 AC                   exsr      zzxopt
     C                   exsr      clrsch
     C                   exsr      scr01i
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
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
212 AC                   select
PCK A*
PCK A*   Work with slots
PCK A*
PCK AC                   when      wkoopt = ' 7'
PCK AC                   eval      $litem = ititem
PCK AC                   call      @cwght
PCK AC                   parm                    $lparm
212 A*
212 A*   Work with tie/highs
212 A*
212 AC                   when      wkoopt = ' 8'
413 AC                   if        ittype = ' '  or
413 AC                             ittype = 'B'  or
510bAC                             ittype = 'R'
212 AC                   eval      $pcmd = '*WORKTIE'
212 AC                   eval      $pxflg = uxflag
212 AC                   call      @chgpg
212 AC                   parm                    $parms
413 AC                   else
413 AC                   eval      error = *on
413 AC                   eval      cancel = *on
413 AC                   exsr      zzbase
413 AC                   exsr      zm1101
413 AC                   endif
PCK A*
PCK A*   Work with slots
PCK A*
PCK AC                   when      wkoopt = '10'
PCK AC                   eval      $litem = ititem
PCK AC                   call      @lstpg
PCK AC                   parm                    $lparm
640cA*
640cA*   Item substitutes
640cA*
640cAC                   when      wkoopt = '11'
640cAC                   eval      $litem = ititem
640cAC                   call      @subpg
640cAC                   parm                    $subcmd
640cAC                   parm                    $lparm
212 M*
212 M*   Work with slots
212 M*
212 MC                   when      wkoopt = '12'
212 MC                   call      'IT130'
212 MC                   parm                    $puky
212 MC                   parm                    $prtn
212 M*
412 M*
412 M*   Linked Items
412 M*
412 MC                   when      wkoopt = '13'
412 MC                   call      'IT170CL'
412 MC                   parm                    itwhse
412 MC                   parm                    ititem
412 MC                   parm                    $prtn
710 A*
710 A*
710 A*   Maintain Cost
710 A*
710 AC                   when      wkoopt = '14'
710 Ac                   eval      $pcmd = '*CHANGE'
710 AC                   call      'IS100'
710 AC                   parm                    $parms
415 A*
415 A*   V? - Display option line for 'V' options
415 A*
415 AC                   when      wkoopt = 'V?'
PCK AC                   select
PCK AC                   when      client = packers
PCK AC                   eval      optln1 = optl2(5)
PCK AC                   other
500bMC                   eval      optln1 = optln(5)
PCK AC                   endsl
     C                   eval      optln2 = *blanks
415 A*
415 A*   V1 - Edit item quantities
415 A*
415 AC                   when      wkoopt = 'V1'
     C                   call      'IT830'
     C                   parm      '?'           $scmd             8
     C                   parm                    $pwhse
     C                   parm                    $pitem
415 A*
415 A*   V2 - Display open label records for item.
415 A*
415 AC                   when      wkoopt = 'V2'
     C                   call      'LB842CL'
     C                   parm      '?'           $scmd
     C                   parm      $pwhse        $swhse            3 0
     C                   parm                    $pitem
600aA*
600aA*   L? - Display option line for 'L' options
600aA*
600aAC                   when      wkoopt = 'L?'
600aAC                   select
600aAC                   when      client = packers
600aAC                   eval      optln1 = optl2(6)
600aAC                   other
600aMC                   eval      optln1 = optln(6)
600aAC                   endsl
600aAC                   eval      optln2 = *blanks
600aA*
600aA*   LP - View license phrase for Item.
600aA*
600aAC                   when      wkoopt = 'LP'
600aAC                   call      'PH310'
600aAC                   parm      'LI'          $sopt             2
600aAC                   parm      $pwhse        $swhse
600aAC                   parm      ' '           $swhdp            5
600aAC                   parm      $pitem        $svalu           15
600bA*
600bA*   70 - View active licenses
600bA*
600bAC                   when      wkoopt = '70'
     C                   call      'LT310'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      ' '           $swhdp
     C                   parm      ' '           $sdisp           12
     C                   parm      $pitem        $sitem           15
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
600eA*
600eA*   72 - View item history
600eA*
600eAC                   when      wkoopt = '72'
     C                   call      'LT320'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      ' '           $swhdp            5
     C                   parm      ' '           $sdisp           12
     C                   parm      $pitem        $sitem           15
     C                   parm      ' '           $slcns           15
     C                   parm      0             $semp#            5 0
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
640aA*
640aA*   90 - View Summary
640aA*
640aAC                   when      wkoopt = '90'
     C                   call      'SL440'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      $pitem        $sitem           15
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
500a *
500a *   91 - Display pending receiving transactions
500a *
500a C                   when      wkoopt = '91'
500a C                   call      'IT940CL'
500a C                   parm                    $pitem
     *
500b *   92 - Display pending replenishment transactions
500b *
500b C                   when      wkoopt = '92'
500b C                   call      'IT945CL'
500b C                   parm                    $pitem
     *
500b *   93 - Display all receipts
500b *
500b C                   when      wkoopt = '93'
500b C                   call      'IT951CL'
500b C                   parm                    $pwhse
500b C                   parm                    $pitem
     *
     *
640bA*   RC - Recall Listing
640bA*
640bAC                   when      wkoopt = 'RC'
640bAC                   call      'LT330'
640bAC                   parm      '*DISPITM'    $tcmd             8
640bAC                   parm      $pwhse        $twhse            3 0
640bAC                   parm      '*ALL'        $tpo              9
640bAC                   parm      $pitem        $titem           15
640bAC                   parm      ' '           $tdev            10
640bAC                   parm      ' '           $tform           10
640bAC                   parm                    $pitem

212 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     C                   if        ptinp1 <> 0
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aD**                   MOVE '1'       *IN01
413aMC                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aD**                   MOVE '1'       *IN01
413aMC                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      itwhse = ptinp1
     C                   eval      $kwhse = itwhse
     C                   eval      ititem = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
223 AC                   eval      *in02 = *on
219 AC                   exsr      zzxopt
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp2 <> *blanks
610aAC                   if        wkitsr='D'
FPRaAC                   select
FPRa *  convert to upper case.
FPRaAC                   when      client = foodpro
FPRaAC                   call      'CVTCASE'
FPRaAC                   parm      '*LOW2UPR'    $ccCmd           10
FPRaAC                   parm      ptinp2        $ccIn           500
FPRaAC                   parm      ' '           $ccOut          500
GMMaAC                   when      client = MenuMaker
GMMaAC                   call      'CVTCASE'
GMMaAC                   parm      '*LOW2UPR'    $ccCmd           10
GMMaAC                   parm      ptinp2        $ccIn           500
GMMaAC                   parm      ' '           $ccOut          500
GMMdAC                   eval      itdesc = $ccout
FPRaAC                   other
600dAC                   eval      itdesc = ptinp2
FPRaAC                   endsl
610aAC                   else
610aAC                   call      'CVTCASE'
610aAC                   parm      '*LOW2UPR'    $ccCmd           10
610aAC                   parm      ptinp2        $ccIn           500
610aAC                   parm      ' '           $ccOut          500
610aDC**                 eval      ititem = ptinp2
610aMC                   eval      ititem = $ccOut
610aAC                   endif
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
     C                   endif
     C     endzps        endsr
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
520aAC                   select
520aAC                   when      wkitsr='I'
     C     partky        setll     record
520aAC                   when      wkitsr='D'
520aAC     partky        setll     recrd2
520aAC                   endsl
     C                   else
     C                   if        $pocmd = '*BOTTOM'
520aAC                   select
520aAC                   when      wkitsr='I'
     C     partky        setgt     record
520aAC                   when      wkitsr='D'
520aAC     partky        setgt     recrd2
520aAC                   endsl
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
219 A*  ZZXOPT   Get use extended description option
     *
219 AC     zzxopt        begsr
     *
219 A*   Get extended description option.
219 AC                   eval      prcrec = 10
219 AC                   eval      uxflag = *off
219 AC                   eval      ocode = '*ITEMMNT'
     *
219 AC     opkey         chain     options                            79
219 AC                   if        not *in79
219 AC                   if        opxdsc = 'Y'
219 AC                   eval      uxflag = *on
219 AC                   eval      prcrec = 5
219 AC                   endif
219 AC                   endif
     *
219 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 3 4 5 6 8 9111213147072V?V1V290919293L?LPRC
**  ZOP2 - Valid options
 2 3 4 5 6 7 8 910111213147072V?V1V2919293L?LP
**  OPTLN - Option display line
  2=Change  3=Copy  4=Delete  5=View  6=Print slots  8=Work with tie/highs
  9=View qty  11=Subs  12=Slots  13=Linked items  14=Maintain Cost
  70=Licenses  72=Item hist  90=View Summary  91=Open rcv tran
  92=Open replen trans  93=Receipts  RC=Recall Listing
  V1=Edit item quantities  V2=View open label records for item
  LP=Phrases
**  OPTL2 - Option display line
  2=Change  3=Copy  4=Delete  5=View  6=Print slots  7=UCI Maintenance
  8=Work with tie/high  9=View qty  10=Print UCI  11=Subs  12=Work w/ slots
  13=Linked items  14=Maintain Cost  91=Open rcv tran  92=Open replen trans
  93=Receipts  70=Licenses  72=Item hist
  V1=Edit item quantities  V2=View open label records for item
  LP=Phrases
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F6=Create  F9=All warehouse  F24=More keys
F8=Search Items  F12=Cancel  F23=More options  F24=More keys
F3=Exit F4=Prompt F5=Refresh F6=Create F9=All Whse F10=Sort Item# F24=More Keys
F3=Exit F4=Prompt F5=Refresh F6=Create F9=All Whse F10=Sort Desc. F24=More Keys
