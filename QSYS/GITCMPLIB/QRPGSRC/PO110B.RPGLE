417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO110B    PO header maintenance (one whse) - Display
     *  08 October, 1996
     *  Hemant Kapadia
     *
     *  SK110 - 1.01
     *
     *----------------------------------------------------------------
     *  Revisions
     *
218 A*    01/28/97  RH
     *      - Add option 10=UPC Receiving to screen1
     *      - call  full screen UPC receiving.
     *
     *    04/30/97  RH   2.20
     *      - Refresh screen to reset pointer if CANCEL or EXIT was
     *        used during F6 ADD.
     *    06/05/97  RH   2.21
     *      - Remove 10=UPC Receiving from screen1.
401 A*    07/11/97  HNK  4.01
     *      - Add options 8 and 9 to Mark and Unmark PO for export.
412 A*    09/16/99  HNK  4.12
     *      - Display delivery date
413bA*    10/25/99  MLB  4.13b
     *      - Add option 11=HACCP information to ZZOPT.
     *      - Add option 11=HACCP information to array ZOPT.
     *      - Add option 11=HACCP information to array OPTLN.
413 A*    11/09/99  HNK  4.13
     *      - Disable Display delivery date.  There is no corresponding
     *        field in the IMPPOH file and hence cannot be imported.
     *
414 A*    08/20/00  KDE  4.14
     *      - Display delivery date and time.                         g
     *
414 A*    09/05/00  KDE  4.14
     *      - Position by delivery date code added.                   g
     *
414bA*    09/24/00  KDE  4.15
     *      - Change to display error message when trying to export   g
     *        PO and all detail lines have not been touched.
     *
414bA*    10/02/00  KDE  4.15
     *      - Do not allow a delete if receivings have ocurred.
     *
414cA*    10/09/00  DAS  4.14c
     *      - Added OPTIONS file and corresponding data structure.
     *      - Revised ZZOPT to only check if detail lines have been
     *        touched if receiving option field OPFRCM is 'Y'.
     *      - Revised ZZOPT to set on the ERROR and CANCEL flags in
     *        order to highlight the option line in error.
     *
414d *    10/18/00  DAS  4.14d
     *      - Changed warehouse position cursor indicator from 01
     *        to 03.
     *      - Revised SFLDSP routine display POSTN record base on
     *        error condition. If error is on, write record in normal
     *        sequence. Otherwise, write it last.
     *        Re: Before change,the system would only position the
     *            cursor correctly on the first display of the screen.
     *            After that, the cursor would always be positioned
     *            to the first field, warehouse.
     *
416 A*    11/27/01  MLB  4.16
     *      - Added support to program for Super P/O's.
     *      - Added new option 13=Work with Super P/O's
     *      - Added new f-key F7=Create Super P/O.
     *      - Added support for F24=More keys.
416a *    10/11/01  RH   4.16a
     *      - Fix - display delivery date in MMDDYY order.
416bA*    11/09/01  DAS  4.16b
     *      - Removed 414b delete check. No done through PO114.
416cA*    12/18/02  HNK  4.16c
     *      - Put option 15 for Lumper info.
500aA*    11/22/04  RH   5.00a
     *      - Add option 6=Print PO Receiving Receipt
500bA*    12/27/04  RH   5.00b
     *      - Add option 52=Special Receiving (Force directed put away
     *        direct to pick slot, no license plates are used)
     *      - Add option 52=Special Receiving to ZOPT, OPTLN
500cA*    12/30/04  DAS  5.00c
     *      - Changed 52=SpcRecv to 52=StuffIt.
500dA*    04/21/05  RH   5.00d
     *      - ENH: Add F11 to view received PO's only.
     *
500fA*    04/11/06  RH   5.00f
     *      - ENH: Add option 16=Pallet estimate
500gA*    04/27/06  MLB  5.00g
     *      - Enh: Added client custom code support.
510aA*    11/13/06  RAH  5.10a
     *      - Enh: Added call to PO190 - display detail when qty ord
     *             <> qty rcvd.
510bA*    11/16/06  RAH  5.10b
     *      - Enh: Converted to RPGLE
     *      - Enh: Enabled SuperPO's to have HACCP information.
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - Merged in Jordano's custom JDO changes.
     *
610aA*    08/20/09  DAS  6.10a
     *      - Added option RC to call LT330 Recall listing.
     *
610bA*    08/17/09  GJA  6.10b
     *      - Enh:  Add option 18 = Produce Labels
610cA*    08/26/09  RH   6.10c
     *      - Enh:  Change Stuffit to PICKSLT Pick slot receiving
     *
640 A*    09/15/11  MLB  6.40
     *      - Fix: Revised routine FGET to clear p/o number instead of
     *        entire $pouky, $pofky fields which then causes a data decimal
     *        error when the pgm attempts to process the setll cmd.
     *
700 A*    02/02/16  MLB  7.00
     *      - Fix: Revised pgm to reset $LPRG on return from PO110C.
     *        PO110C was corrupting field.
     *
750a *    03/03/21  LMC  7.50a
     *      - Enh: Added check for missing weights.
770aA*    05/18/23  LMC  7.70a
     *      - Added option DV to reset postatus file field POSSTAT
     *        in order to allow the user to resend a po.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    04/27/06  MLB  CLD
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use 52=Stuffit putaway option.
     *
     *----------------------------------------------------------------
     *  EG Forrest Custom Mods
EGFaA*    02/18/10  RH   EGFa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *
     *----------------------------------------------------------------
     *  Jordano's Custom Mods
     *
JDO A*    04/21/05  DAS  JDO
     *      - Revised program to prevent option 12 for Bread P.O.'s,
     *        which are P.O.'s with vendor 3194.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    08/13/09  RH   SVLa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCa *    09/25/10  GJA  GFCa
     *      - Enh:  Force PO receipt when po is marked for export.
     *
     *----------------------------------------------------------------
FBY  *  Client Custom Revisions: Farm Boy
     *    09/09/16  RH   FBYa
FBYa *      - Disable Option 'U' for partial export.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *    03/03/21  LMC  DRYa
DRYaA*      - Edit - do not allow mark for export unless all CW lines
     *        with a quantity received have a weight entered.
     *
416 A*----------------------------------------------------------------
416 A*  Super P/O notes.
416 A*
416 A*    Maintaining a Super P/O
416 A*      - A Super P/O can have individual purchase orders added to it
416 A*        at any point.
416 A*
416 A*    Marking a Super P/O for Export
416 A*      - A Super P/O can only be marked for export when all individual
416 A*        purchase orders attached to the Super P/O have been received.
416 A*        If Force marking of detail lines is active, every purchase
416 A*        order must be fully marked before the Super P/O and all
416 A*        individual purchase orders can be marked for export.
416 A*      - Individual purchase orders attached to a Super P/O cannot be
416 A*        marked for export individually. If a individual p/o needs to
416 A*        exported it has to be removed from the Super P/O and then
416 A*        marked and exported.
416 A*
     *
500eA*    10/26/05  JCJ  5.00e
     *      - Add check to see if a user is allowed to enter HACCP
     *        information when option 11 (HACCP) is tacken.
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
     fpo110bfm  cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(dspsfl:recno)
     f                                     sfile(msgrec:msgk)
     fworkopt   uf a e           k disk
     fpohdr1    if   e           k disk
     f                                     rename(phrec:record)
414bAfpodtl     if   e           k disk
414bAfpodtl3    if   e           k disk
     f                                     rename(pdjrec:ptouch)
416 Afpospo     if   e           k disk
416 Afpospo1    if   e           k disk
     f                                     rename(purec:purec1)
414cAfoptions   if   e           k disk
500aAfreports   if   e           k disk
750aAfpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d a2              s              1    dim(2)
     d a10             s              1    dim(10)
     d a75             s              1    dim(75)
     d fkey            s             50    dim(10)
     d ukey            s             50    dim(10)
     d optlst          s              2    dim(24)
     d cmdlst          s              2    dim(24)
     d zopt            s              2    dim(20) ctdata perrcd(20)
610bMd optln           s             75    dim(4) ctdata perrcd(1)
401 Md******           s             75    dim(2) ctdata perrcd(1)
416 D**                  CMDLN   1   1 79
500dD*                   CMDLN   1   2 79
500dMd cmdln           s             79    dim(4) ctdata perrcd(1)
JDO AD desc            s             50    dim(1) ctdata perrcd(1)
500gA*
500gA*----------------------------------------------------------------
500gA*  Customer id
500gA*
     d @getcl          c                   const('GETCLIENT')
CLD A /COPY QCOPYSRC,ID#CITYLIN
JDO A /COPY QCOPYSRC,ID#JORDANO
SVLaA /COPY QCOPYSRC,ID#SAVAL
EGFaA /COPY QCOPYSRC,ID#EGF
GFCaA /COPY QCOPYSRC,ID#GLAZIER
FBY A /COPY QCOPYSRC,ID#FBY
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
500gA*
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     d $prtky          ds
     d  $len50                 1     50
     d  $kwhse                 1      3  0
     d  $kpo                   4     10  0
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     d                 ds
     d  dsfkey                 1     50
     d  dsukey                 1     50
     d  phwhse                 1      3  0 inz(0)
     d  phpo                   4     12
416 Ad                 ds
416 Ad  hldkey                 1     50
     *----------------------------------------------------------------
     *  Called program parameters
     *
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     *
     *   Redefine key
     *
     d  $lwhse                19     21  0
218 Ad  $lpo                  22     30
413bAd  $lseq                 31     35  0
413bAd  $litem                36     50
416 A*
416 Ad  $lspo                 31     39
     *
416cAd  $lhedt                31     38  0
416cAd  $lheti                39     44  0
     *----------------------------------------------------------------
     *  Called programs
     *
     d @cvtdt          c                   const('CVTDTE')
     d @chgpg          c                   const('PO112')
610bAd @lblpg          c                   const('LB400CL')
     d @delpg          c                   const('PO114')
     d @prtpg          c                   const('PO330CL')
500aD*             '*NONE'               C         @PRTPG
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA /copy qcopysrc,c#stdsql
414cA*----------------------------------------------------------------
414cA*  *RCVLBL  -  Receiving options
414cA*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPGM  -  Receiving label program.
     *    OPUPCT  -  Ideal slot usage percentage.
     *    OPPDEF  -  PIR minimum number of slots priority.
     *    OPPBLD  -  PIR same build code priority.
     *    OPPACT  -  PIR same activity zone priority.
     *    OPFDEF  -  Fixed minimum number or slots priority.
     *    OPFASL  -  Fixed same aisle priority.
     *    OPFSID  -  Fixed same side priority.
     *    OPFLVL  -  Fixed highest level priority.
217 A*    OPPASL  -  PIR same aisle priority.
217 A*    OPPFRC  -  Force PIR same aisle priority.
221 A*    OPPLCN  -  Use generic license plates.
409 A*    OPPCHM  -  Check chimney (Y,N)
409 A*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
412 A*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
414 A*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
     *
     * Data structure
     *
     d opdata          ds
     d  oplpgm                 1     10
     d  opupct                11     13  0
     d  oppdef                14     14  0
     d  oppbld                15     15  0
     d  oppact                16     16  0
     d  opfdef                17     17  0
     d  opfasl                18     18  0
     d  opfsid                19     19  0
     d  opflvl                20     20  0
     d  oppasl                21     21  0
     d  oppfrc                22     22
221 Ad  opplcn                23     23
409 Ad  oppchm                24     24
409 Ad  oppmix                25     25
412 Ad  opapck                26     26
414 Ad  opfrcm                27     27
     d  optend               117    117
770aA
770aA*----------------------------------------------------------------
770aA*  *SYSTEM  -  System options.
770aA*----------------------------------------------------------------
770aA*
770aA* Fields
770aA*
770aA*    OPUCI   -  Use UCI processing (Y,N)
770aA*
770aA* Data structure
770aA*
770aAD opdta2          ds
770aMD  opuci                 36     36
770aAd  opdckv                50     50
770aAD  optend2              117    117

     *----------------------------------------------------------------
     * Status message(s)
     d sts00           c                   const('Open')
     d sts01           c                   const('Partial receipt')
     d sts02           c                   const('Received in full')
     d sts03           c                   const('Ready for export')
     d err01           c                   const('Not authorized t-
610cMd                                     o use 52=PickSlt')
SVLa d err03           c                   const('Not authorized t-
     d                                     o use option')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     d $postn          ds
     d  $pocmd                 1      8
     d  $poprg                 9     18
     d  $pofky                19     68
     d  $pouky                69    118
     d  $podsc               119    307
     d                                     dim(3)
     d  $popt1               308    322
     d  $popt2               323    335
     d  $portn               336    343
     d  $poerm               344    403
     d  $pomsg               336    339
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
416 A*
416 A*   Redefine key
416 A*
416 Ad  $pwhse                19     21  0
416 Ad  $ppo                  22     30
416 Ad  $pspo                 31     39
416 Ad  $pspsw                65     68
416aMd $cvtdt          ds
416aMd  $cvcmd                 1      8
416aMd  $cvprg                 9     18
416aMd  $cvd6i                19     24
416aMd  $cvd8i                25     32
416aMd  $cvd6o                33     38  0
416aMd  $cvd8o                39     46  0
416aMd  $cvsto                47     64
416aMd  $cvrtn                65     72
416aMd  $cverm                73    132
416aMd  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     d $mdt            ds
     d  errmsg                 1     50
     d  errcl1                 1     10
     d  errcl2                11     16
     d                 ds
     d  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     d #msgf           c                   const('PIRMSGF   ')
     *
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
610bA*----------------------------------------------------------------
     *   VARIABLES
     *
     D maxvwo          s              1  0
     D v               s              2  0
     D view            s              8
     D viewo           s              1  0
750aAD missingwgt      s              1
750aAD forever         s              1
770aAd dockvue         s               n   inz('0')
770aAd ocode           s              8
770aAD nostamp         s               z     inz
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
     c     *entry        plist
     c                   parm                    $prtky           50
     c                   parm                    $rtncd            8
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     c     wkounq        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    wkokyf
     c                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     c     wkoprt        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     c     *like         define    wkokyf        $wkof
     c     *like         define    wkokyu        $wkou
     c     deltop        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    $wkof
     c                   kfld                    $wkou
     *
     *     USERCODE
     *
     c     uskey         klist
     c                   kfld                    #user
     *
500aAc     rpkey         klist
500aAc                   kfld                    wkprtf           10
     *----------------------------------------------------------------
     *  Main line
     *
     c                   move      *on           *in97
     c                   move      *blanks       $rtncd
     c                   call      'BFCADR'
     c                   parm                    $rtn              8
     c     $rtn          ifeq      '*EXPIRED'
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $rtncd
     c                   else
     c                   exsr      zzinz2
     c                   end
     *
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c     nxtscr        caseq     '02 '         sc2
     c                   end
     c                   end
     *
     *   Do some clean up before leaving.
     *
     c                   exsr      zsclr
     c                   exsr      clrsch
     *
     c     $rtncd        ifeq      '*EXIT   '
     c     $rtncd        oreq      '*CANCEL '
     c                   seton                                        lr
     c                   end
     c                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     c     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     *
     *   Set OFF command key indicators
     *
     c                   setoff                                       kckekf
     c                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     c                   write     title
     *
     *   Overlay screen with error messages
     *
     c                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     c     nxtscr        ifeq      '01 '
     c                   exsr      sfldsp
     c                   read      postnrec                               50
     c                   end
     c     nxtscr        ifeq      '02 '
     c                   exsr      deldsp
     c                   end
     *
     *   Initialize error indicators and fields
     *
     c                   setoff                                       2021
414dAc                   setoff                                       03
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cancel            1
     c                   z-add     0             e                 2 0
     *
     *   Initialize error subfile
     *
     c                   exsr      zmcmsg
     *
     c                   read      dspsfc                                 50
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   write     clr0306
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     c     scr02i        begsr
     c                   move      '02 '         nxtscr
     c                   move      *on           *in90
     c                   move      *loval        $wkof
     c                   move      *loval        $wkou
     c                   write     clr0306
     c                   write     delrec
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag02
     c                   write     cmddel
     c                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     c     scr02e        begsr
     c                   move      '01 '         nxtscr
     c                   move      *off          *in90
     c                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     c     cancel        ifeq      *off
     c                   move      '*POSTN2 '    $pocmd
     c                   move      frstky        $pofky
     c                   exsr      fgtway
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     c     $portn        ifeq      '*NOMORE '
     c                   move      '*TOP    '    $pocmd
     c                   else
     *
     *   Otherwise, position to last record read.
     *
     c                   move      '*POSTN2 '    $pocmd
     c                   end
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   exsr      optns
     c                   else
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     c     sc1           begsr
     c     status        caseq     rollup        roll01
     c     status        caseq     rolldn        roll01
     c     status        caseq     comand        cmd01
     c                   cas                     ent01
     c                   end
     c     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     c     sc2           begsr
     c     status        caseq     rollup        roll02
     c     status        caseq     rolldn        roll02
     c     status        caseq     comand        cmd02
     c                   cas                     ent02
     c                   end
     c     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     c     *inzsr        begsr
500gA*
500gA* Get client id.
500gA*
500gAc                   call      @getcl
500gAc                   parm                    client           10
     *
     *  Initialize special keys
     *
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     *
     *  Initialize message handling
     *
     c                   exsr      zmimsg
     *
     *  Initialize subfile (DSPSFL) record
     *
     c                   z-add     1             recno
     c                   write     dspsfl                               79
     *
     *   Call user added initialization routine.
     *
     c                   exsr      zzinz
     c                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     c     clrsch        begsr
     c     wkoprt        setll     workopt
     c     wkoprt        reade     workopt                              7979
     c     *in79         doweq     *off
     c                   delete    wkorec
     c     wkoprt        reade     workopt                              7979
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     c     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     c     *inkc         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $rtncd
     c                   goto      cmd01e
     c                   end
500d *
500d *  TEST FOR CMD11 - Received or ALL
500d *
500d c     *inkk         ifeq      *on
500d c     noxflg        ifeq      *on
500d c                   move      *off          noxflg
500d c                   else
500d c                   move      *on           noxflg
500d c                   endif
500d c     noxflg        ifeq      *off
500d c                   move      cmdln(1)      cmdln1
500d c                   else
500d c                   move      cmdln(3)      cmdln1
500d c                   endif
500d *
500d c                   move      '*REFRESH'    pagcmd
500d c                   move      *loval        fkey
500d c                   move      *loval        ukey
500d c                   exsr      pag01
500d c                   endif
     *
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     c     *inkl         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $rtncd
     c                   goto      cmd01e
     c                   end
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     c     *inke         ifeq      *on
     c                   exsr      clrsch
     c     1             do        10            x
     c     x             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl
     c                   end
     c                   end
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     c                   exsr      savopt
     c     error         cabeq     *on           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     c     *inkf         ifeq      *on
     c                   exsr      inzpar
     c                   move      '*ADD    '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     c     $prtn         ifne      '*CANCEL '
     c     $prtn         andne     '*EXIT   '
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   end
     c                   end
     c                   end
220 Ac                   move      '*REFRESH'    pagcmd
220 Ac                   exsr      pag01
     c                   goto      cmd01e
     c                   end
416 A*
416 A*  TEST FOR CMD7 - Create Super P/O.
416 A*
416 Ac     *inkg         ifeq      *on
416 Ac                   move      '*ADD    '    $lcmd
416 Ac                   move      $prtky        $luky
416 Ac                   call      'PO110C'
416 Ac                   parm                    $lparm
700 Ac                   eval      $lprg = #prog
416 Ac     $lrtn         ifeq      '*ERROR  '
416 Ac                   move      *on           error
416 Ac                   movel     $perm         errmsg
416 Ac                   exsr      zm0105
416 Ac                   else
416 Ac     $lrtn         ifeq      '*PGMQ   '
416 Ac                   move      *on           error
416 Ac                   move      $pmsg         #msgk
416 Ac                   exsr      zmqmsg
416 Ac                   else
416 Ac     $lrtn         ifne      '*CANCEL '
416 Ac     $lrtn         andne     '*EXIT   '
416 Ac                   move      '*POSTN2U'    $pocmd
416 Ac                   move      $luky         $pouky
416 Ac                   exsr      fgtway
416 Ac                   move      '*REPOS  '    pagcmd
416 Ac                   exsr      pag01
416 Ac                   end
416 Ac                   end
416 Ac                   end
416 Ac                   move      '*REFRESH'    pagcmd
416 Ac                   exsr      pag01
416 Ac                   goto      cmd01e
416 Ac                   end
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     c     *inkj         ifeq      *on
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     c                   sub       10            row#
     c     row#          iflt      1
     c     row#          orgt      dsplyd
     c                   move      *on           error
     c                   move      *blanks       errmsg
     c                   exsr      zm0106
     c                   goto      cmd01e
     c                   end
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     c                   move      '*POSTN2U'    $pocmd
     c                   move      ukey(row#)    $pouky
     c                   exsr      fgtway
     *R         CLERR     CABEQ*ON       CMD01E
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     c     *inkr         ifeq      *on
     c                   move      '*TOP    '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     c     *inks         ifeq      *on
     c                   move      '*BOTTOM '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     *
     *   Process non-standard function keys.
     *
     c                   exsr      zzcmd
     c     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     c     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     c     *inkl         ifeq      *on
     c                   move      *on           cancel
     c                   exsr      scr02e
     c                   goto      cmd02e
     c                   end
     c     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     c     deladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     c                   move      '*GET    '    $pocmd
     c                   move      wkokyu        $pouky
     c                   exsr      fgtway
     *R         CLERR     CABEQ*ON       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     c     recno         ifeq      1
     c                   move      wkokyf        $wkof
     c                   move      wkokyu        $wkou
     c                   end
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     c                   exsr      zzfill
     c                   move      wkoopt        option
     c                   write     dspsfl
     c                   end
     c     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     c     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     c                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     c     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     c                   exsr      savopt
     c     error         cabeq     *on           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     c                   move      *off          repos             1
     c                   exsr      zzpos
     c     error         cabeq     *on           ent01e
     c     repos         ifeq      *on
     c                   move      dsfkey        $pofky
     c                   move      '*POSTN2 '    $pocmd
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      ent01e
     c                   end
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     c                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     c     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     c     ent02         begsr
     *
     *  Save first delete key.
     *
     c     *like         define    $puky         frstky
     c                   move      $puky         frstky
     *
     *  Delete the records that have been selected
     *
     c     wkoprt        setll     workopt
     c                   move      *off          stop
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     *
     c     wkoopt        ifeq      ' 4'
416bD**
416bD**  Check to ensure no receiving has ocurred.
416bD**
416bD**         FILEPO    SETLLPODTL
416bD**         FILEPO    READEPODTL                    85
416bD**                   MOVEL*ON       $OK     1
416bD**         *IN85     DOWEQ*OFF
416bD**         DETLKY    CHAINPODTL3               84
416bD**         PORACT    IFEQ 'R'
416bD**         PORACT    OREQ 'X'
416bD**                   MOVEL*OFF      $OK
416bD**                   ENDIF
416bD**         FILEPO    READEPODTL                    85
416bD**                   ENDDO
     *
     *  Call delete program
     *
416bD**         $OK       IFEQ *ON
     c                   exsr      inzpar
     c                   move      '*DELETE '    $pcmd
     c                   move      wkokyu        $puky
     c                   call      @delpg
     c                   parm                    $parms
416bD**                   ELSE
416bD**                   EXSR ZM0114
416bD**                   ENDIF
     *
     *     Error occured - Error message sent back
     *
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     *
     *     Delete canceled
     *
     c     $prtn         ifeq      '*CANCEL '
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   else
     *
     *     Delete was successful.
     *
     c     $prtn         ifeq      '*OK     '
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   end
     c                   end
     c                   end
     c                   end
     c     cancel        ifeq      *off
     c                   delete    wkorec
     c                   else
     c                   move      *on           wkoerr
     c                   update    wkorec
     c                   end
     c                   end
     *
     c                   end
     c                   end
     c                   exsr      scr02e
     c     ent02e        endsr
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
     c     fgtway        begsr
     c                   move      *blanks       $portn
     c     $pocmd        caseq     '*GET    '    fget
     c     $pocmd        caseq     '*GETNEXT'    fgetn
     c     $pocmd        caseq     '*GETPREV'    fgetp
     c     $pocmd        caseq     '*POSTN2 '    fpos2
     c     $pocmd        caseq     '*POSTN2U'    fpos2u
     c     $pocmd        caseq     '*TOP'        zzpos2
     c     $pocmd        caseq     '*BOTTOM'     zzpos2
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     c     fget          begsr
     c                   move      $pouky        dsukey
     c                   exsr      zzfget
     c     *in79         ifeq      *on
     c                   move      '*NOTFND '    $portn
640 Dc*                  move      *blanks       $pouky
640 Dc*                  move      *blanks       $pofky
640 AC                   eval      phpo = ' '
640 AC                   eval      $pouky = dsukey
640 AC                   eval      $pofky = dsfkey
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     c     fgetn         begsr
     c                   exsr      zzfgtn
     c     *in79         ifeq      *on
     c                   move      '*NOMORE '    $portn
     c                   move      *blanks       $pouky
     c                   move      *blanks       $pofky
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   exsr      zzkeyu
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     c     fgetp         begsr
     c                   exsr      zzfgtp
     c     *in79         ifeq      *on
     c                   move      '*NOMORE '    $portn
     c                   move      *blanks       $pouky
     c                   move      *blanks       $pofky
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   exsr      zzkeyu
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     c     fpos2         begsr
     c                   move      $pofky        dsfkey
     c     fileky        setll     record
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     c     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     c                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     c                   exsr      fpos2
     c                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     c     inzpar        begsr
     c                   clear                   $parms
     c                   move      #prog         $pprg
     c                   move      $prtky        $puky
     c                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     c     optns         begsr
     c                   move      *off          otaken            1
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     c     wkoprt        setll     workopt
     c                   move      *off          stop
     c     wkoprt        reade     workopt                                79
     c     *in79         doweq     *off
     c     wkoopt        andne     ' 4'
     c     wkoprt        reade     workopt                                79
     c                   end
     c     *in79         ifeq      *off
     c     wkoopt        andeq     ' 4'
     c                   move      *on           otaken
     c                   move      wkokyu        $puky
     c                   exsr      scr02i
     c                   goto      optnse
     c                   end
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     c     wkoprt        setll     workopt
     c                   move      *off          cancel            1
     c                   move      *off          stop              1
     c     stop          doueq     *on
     c     cancel        oreq      *on
     c     wkoprt        reade     workopt                                79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     c     wkoopt        ifne      '  '
     c                   move      *on           otaken
     c                   exsr      optns2
     c     wkounq        chain     workopt                            78
     c                   move      *on           refrsh
     c     error         ifeq      *off
     c                   delete    wkorec
     c                   end
     c     cancel        ifeq      *on
     c                   move      *on           stop
     c     error         ifeq      *on
     c                   move      *on           wkoerr
     c                   update    wkorec
     c                   end
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   move      *off          refrsh
     c                   end
     c                   end
     c                   end
     c                   end
     c     refrsh        ifeq      *on
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   move      *off          refrsh            1
     c                   end
     c     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     c     optns2        begsr
     c                   exsr      inzpar
     c                   move      wkokyu        $puky
     *
     *   Change
     *
     c     wkoopt        ifeq      ' 2'
     c                   move      '*CHANGE '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
     *
     *   View
     *
     c     wkoopt        ifeq      ' 5'
     c                   move      '*VIEW   '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
610bAC*
     C*   Print Produce Labels
     C*
     c     wkoopt        ifeq      '18'
     c                   call      @lblpg
     c                   parm      '*BATCH'      $cmd             10
     c                   parm                    $kwhse
     c                   parm                    $rtncd
     c                   parm                    $pdev
     c                   parm                    $pform
     c                   parm                    $ppo
     c                   else
     *
     *   Print
     *
     c     wkoopt        ifeq      ' 6'
500aA*   Print Receiving Receipt
     c                   move      '*PRINT  '    $pcmd
500  c                   movel     'PO330PR '    wkprtf
500  c     rpkey         chain     reports                            79
500a c     *in79         ifeq      *on
500a c                   movel     '*STD'        $pform           10
500a c                   movel     '*JOB'        $pdev            10
500a c                   else
500a c                   move      rpform        $pform
500a c                   move      rpdev         $pdev
500a c                   endif
500a c                   move      $pwhse        $pwhs             3
     c                   call      @prtpg
500aD*R                   PARM           $PARMS
500a c                   parm                    $pwhs
500a c                   parm                    $ppo
500a c                   parm                    $prtn
500a c                   parm                    $pdev
500a c                   parm                    $pform
     c                   else
     c                   exsr      zzopt
     c                   end
     c                   end
610bAc                   end
     c                   end
     *
     c     $prtn         ifeq      '*CANCEL '
     c                   move      *on           cancel
     c                   else
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           cancel
     c                   move      *on           error
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           cancel
     c                   move      *on           error
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   end
     c                   end
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     c     pag01         begsr
     *
     *  NEXT PAGE
     *
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag1fw
     c                   else
     *
     *  PREVIOUS PAGE
     *
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag1bk
     c                   else
     *
     *  TOP
     *
     c     pagcmd        ifeq      '*TOP    '
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          forceb
     c                   exsr      pag1fw
     c                   else
     *
     *  BOTTOM
     *
     c     pagcmd        ifeq      '*BOTTOM '
     c                   move      *on           bot
     c                   z-add     0             dsplyd
     c                   exsr      pag1bk
     c                   else
     *
     *  REFRESH SCREEN
     *
     c     pagcmd        ifeq      '*REFRESH'
     c     fkey(1)       ifeq      *loval
     c                   move      '*TOP    '    $pocmd
     c                   else
     c                   move      '*POSTN2 '    $pocmd
     c                   move      fkey(1)       $pofky
     c                   end
     c                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          bot
     c                   exsr      pag1fw
     c                   else
     *
     *  REPOSITIONING
     *
     c     pagcmd        ifeq      '*REPOS  '
     c                   move      *off          bot
     c                   move      *off          forceb
     c                   exsr      pag1fw
     c                   end
     c                   end
     c                   end
     c                   end
     c                   end
     c                   end
     c                   move      *blanks       pagcmd            8
     c     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     c     pag02         begsr
     *
     *  NEXT PAGE
     *
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag2fw
     c                   else
     *
     *  PREVIOUS PAGE
     *
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag2bk
     c                   else
     *
     *  REFRESH SCREEN
     *
     c     pagcmd        ifeq      '*REFRESH'
     c     deltop        setll     workopt
     c                   move      *off          bot
     c                   exsr      pag2fw
     c                   end
     c                   end
     c                   end
     c                   move      *blanks       pagcmd
     c     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     c     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     c     bot           cabeq     *on           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     c                   exsr      sflclr
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     c     stop          doueq     *on
     c                   move      '*GETNEXT'    $pocmd
     c                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfac
     c                   end
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     c                   add       1             p
     c                   exsr      sfladd
     c     p             ifge      10
     c                   move      *on           stop
     c     forceb        ifeq      *on
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   else
     c                   move      'More...'     moreln
     c                   end
     c                   end
     c     endfac        tag
     c                   end
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     c     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     c     top           cabeq     *on           endb
     c                   move      *off          forceb            1
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     c     dsplyd        add       10            goback            2 0
     c     bot           ifeq      *on
     c     goback        ifeq      10
     c                   move      *on           forceb
     c                   end
     c                   move      '*BOTTOM '    $pocmd
     c                   exsr      fgtway
     c                   add       1             goback
     c                   end
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     c     stop          doueq     *on
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk
     c                   end
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     c                   add       1             p
     c     p             ifge      goback
     c                   move      *on           stop
     c                   end
     c     endbk         tag
     c                   end
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     c     top           ifeq      *on
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     c                   end
     c                   exsr      pag1fw
     c     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     c     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     c     bot           cabeq     *on           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     c                   exsr      sflclr
     c                   move      *loval        $wkof
     c                   move      *loval        $wkou
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfw2
     c                   end
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c                   exsr      deladd
     c     p             ifge      10
     c                   move      *on           stop
     c     forceb        ifeq      *on
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   else
     c                   move      'More...'     moreln
     c                   end
     c                   end
     c                   end
     c     endfw2        tag
     c                   end
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     c     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     c     top           cabeq     *on           endb2
     c                   move      *off          forceb            1
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     c     dsplyd        add       10            goback            2 0
     c     bot           ifeq      *on
     c     wkoprt        setgt     workopt
     c                   add       1             goback
     c                   end
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     *
     *  READ FILE
     *
     c     stop          doueq     *on
     c     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk2
     c                   end
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c     p             ifge      goback
     c                   move      *on           stop
     c                   end
     c                   end
     c     endbk2        tag
     c                   end
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     c     top           ifeq      *on
     c     wkoprt        setll     workopt
     c                   end
     c                   exsr      pag2fw
     c     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     c     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     c     status        ifeq      rollup
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     *
     *  TEST FOR ROLLDOWN
     *
     c     status        ifeq      rolldn
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     c     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     c     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     c     status        ifeq      rollup
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     *
     *  TEST FOR ROLLDOWN
     *
     c     status        ifeq      rolldn
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     c     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     c     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     c                   move      *off          nomore            1
     c     nomore        doueq     *on
     c                   move      *off          *in21
     c                   readc     dspsfl                                 79
     c     *in79         ifeq      *on
     c                   move      *on           nomore
     c                   goto      enddo1
     c                   end
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     c     option        ifne      *blanks
     c                   movea     option        a2
     c     a2(2)         ifeq      ' '
     c                   move      a2(1)         a2(2)
     c                   move      ' '           a2(1)
     c                   movea     a2            option
     c                   end
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     c     option        lookup    zopt                                   50
     c     *in50         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *blanks       errmsg
     c                   exsr      zm0108
     c                   end
     c                   end
JDO A*
JDO A*    For Jordano's ...
JDO A*      Cannot user option 12 for a Bread P.O. (Vendor = 3194)
JDO A*
JDO AC                   if        client = jordanos  and
JDO AC                             option = '12'  and
JDO AC                             phven = 3194
JDO AC                   eval      error = *on
JDO AC                   eval      *in21 = *on
JDO AC                   eval      errmsg = *blanks
JDO AC                   eval      errmsg = desc(1)
JDO AC                   exsr      zm0105
JDO AC                   endif
SVLaA*    For Saval check if user authorized for 4=delete
SVLaAc     client        ifeq      saval
EGFaAc     client        oreq      egf
SVLaAc     option        ifeq      ' 4'
SVLaAc                   call      'CHKLIST'
SVLaAc                   parm      #prog         $cpgm
SVLaAc                   parm      option        $copt
SVLaAc                   parm      #user         $cuser
SVLaAc                   parm      *blanks       $crtn
SVLaAC*       User not authorized to use this option.
SVLaAc     $crtn         ifeq      '*NO '
SVLaAc                   move      *on           error
SVLaAc                   move      *on           cancel
SVLaAc                   movel(p)  err03         errmsg
SVLaAc                   exsr      zm0105
SVLaAc                   endif
SVLaAc                   endif
SVLaAc                   endif
FBYaA*    For Farm Boy ...
FBYaA*      Option 'U' partial export not allowed.
FBYaAC                   if        client = farmboy  and
FBYaAC                             option = ' U'
FBYaAC                   eval      error = *on
FBYaAC                   eval      *in21 = *on
FBYaAC                   eval      errmsg = *blanks
FBYaAC                   exsr      zm0108
FBYaAC                   endif
     *
     *  SAVE OPTION
     *
     c                   z-add     recno         y                 3 0
     c                   move      fkey(y)       wkokyf
     c                   move      ukey(y)       wkokyu
     c     wkounq        chain     workopt                            79
     c     *in79         ifeq      *off
     c     option        ifeq      *blanks
     c                   delete    wkorec
     c                   else
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
     c                   update    wkorec
     c                   end
     c                   else
     c     option        ifne      *blanks
     c                   move      #user         wkousr
     c                   move      #prog         wkopgm
     c                   move      fkey(y)       wkokyf
     c                   move      ukey(y)       wkokyu
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
     c                   write     wkorec
     c                   end
     c                   end
     c     enddo1        tag
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     c     sfladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     c                   move      $pofky        fkey(y)
     c                   move      $pouky        ukey(y)
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     c                   exsr      zzfill
     c                   write     dspsfl
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     c     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     c                   move      *off          *in01
     c                   write     dspsfc
     c                   z-add     0             recno             4 0
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     c     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     c                   write     optrec
     c                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     c                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
414dA*  Write POSTNREC first if error occured.
414dA*
414dAc     error         ifeq      '1'
     c                   write     postnrec
414dAc                   end
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     c                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     c     error         ifne      *on
     c     1             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      *on           *in20
     c                   update    dspsfl
     c                   end
     c                   end
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     *
414dA*  Write POSTNREC last if no error occured.
414dA*
414dAc     error         ifne      '1'
414dAc                   write     postnrec
414dAc                   end
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     c     sflopt        begsr
     c     1             do        10            x                 3 0
     c     x             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      fkey(x)       wkokyf
     c                   move      ukey(x)       wkokyu
     c     wkounq        chain     workopt                            78
     c     *in78         ifeq      *off
     c                   move      wkoopt        option
     c                   move      wkoerr        *in21
     c                   move      wkoerr        *in20
     c                   else
     c                   move      *blanks       option
     c                   move      *off          *in21
     c                   move      *off          *in20
     c                   end
     c                   update    dspsfl
     c                   end
     c                   end
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     c     zmdmsg        begsr
     c                   write     msgclr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      #prog         #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     c     zmqmsg        begsr
     c                   add       1             msgk
     c                   write     msgrec
     c                   endsr
     *
     *    ZSCLR   Clear screen
     *
     c     zsclr         begsr
     *R                   WRITECLRSCR
     c                   move      *on           sclear            1
     c                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      '*PREV'       #pgmq
     c                   parm                    #msgk
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     c     zm0101        begsr
     c                   move      'PIR0101'     #msgid
     c                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     c     zm0102        begsr
     c                   move      'PIR0102'     #msgid
     c                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     c     zm0103        begsr
     c                   move      'PIR0103'     #msgid
     c                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     c     zm0104        begsr
     c                   move      'PIR0104'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     c     zm0106        begsr
     c                   move      'PIR0106'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     c     zm0107        begsr
     c                   move      'PIR0107'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     c     zm0108        begsr
     c                   move      'PIR0108'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     option        errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
414 A*----------------------------------------------------------------
414 A*      1100  All Detail lines not touched
414 A*
414bAc     zm0110        begsr
414bAc                   move      'PO11001'     #msgid
414bAc                   move      '*DIAG  '     #msgtp
414bAc                   movel     option        errmsg
414bAc                   movea     errmsg        $md(1)
414bAc                   exsr      zmpmsg
414bAc                   endsr
414bA*----------------------------------------------------------------
414bA*      1140  Request to delete, but receivings have ocurred.
414bA*
414bAc     zm0114        begsr
414bAc                   move      'PO11402'     #msgid
414bAc                   move      '*DIAG  '     #msgtp
414bAc                   movel     option        errmsg
414bAc                   movea     errmsg        $md(1)
414bAc                   exsr      zmpmsg
414bAc                   endsr
416 A*----------------------------------------------------------------
416 A*      3237  Option 13 not allowed on individual p/o.
416 A*
416 Ac     zm3237        begsr
416 Ac                   move      'PO13237'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 A*----------------------------------------------------------------
416 A*      3238  Option 8 not allowed on individual p/o.
416 A*
416 Ac     zm3238        begsr
416 Ac                   move      'PO13238'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 A*----------------------------------------------------------------
416 A*      3239  Option 9 not allowed on individual p/o.
416 A*
416 Ac     zm3239        begsr
416 Ac                   move      'PO13239'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 A*----------------------------------------------------------------
416 A*      3240  Option 11 not allowed on Super P/O.
416 A*
416 Ac     zm3240        begsr
416 Ac                   move      'PO13240'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     c     zm9905        begsr
     c                   move      'PIR9905'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     c     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     c     *inkd         ifeq      *on
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     *
     *     Warehouse department.
     *
     c     row#          ifeq      4
     c     col#          andge     38
414dD**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   move      '*LOOKUP '    $lcmd
     c                   z-add     ptinp1        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*SELECT '
     c                   z-add     $lwhse        ptinp1
     c                   end
     c                   else
     *
     *     Cursor not on a valid lookup field.
     *
     c                   move      *on           error
     c                   exsr      zm9905
     c                   end
     c                   goto      endcm1
     c                   end
     *
     *  Test for F9 - Display all warehouses
     *
     c     *inki         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*F9     '    $rtncd
     c                   goto      endcm1
     c                   endif
416 A*
     *
     *  TEST FOR CMD23 - More options
     *
     C                   if        *inkx
     C                   if        viewo = maxvwo
     C                   eval      viewo = 1
     C                   else
     C                   add       1             viewo
     C                   endif
     C                   eval      v = viewo * 2
     C                   eval      optln2 = optln(v)
     C                   eval      v = v - 1
     C                   eval      optln1 = optln(v)
     C                   goto      endcm1
     C                   endif
416 A*  Test for F24 - More keys
416 A*
416 Ac     *inky         ifeq      *on
416 Ac                   add       1             k
416 Ac     k             ifgt      2
416 Ac                   z-add     1             k
416 Ac                   endif
500dAc                   select
500dAc     k             wheneq    1
500dAc     noxflg        ifeq      *on
500dAc                   move      cmdln(1)      cmdln1
500dAc                   else
500dAc                   move      cmdln(3)      cmdln1
500dAc                   endif
500dAc                   other
500dAc     noxflg        ifeq      *on
500dAc                   move      cmdln(4)      cmdln1
500dAc                   else
500dAc                   move      cmdln(2)      cmdln1
500dAc                   endif
500dD**                   MOVE CMDLN,K   CMDLN1
500dAc                   endsl
416 Ac                   endif
416 A*
     c     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     c     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     c     filuky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     c     zzfgtn        begsr
     c     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     c     partky        reade     record                                 79
     *
500d **   See if we only want received lines.
500d c     noxflg        ifeq      *on
500d c     *in79         andeq     *off
500d c     phstat        cabeq     '0'           try1
500d c                   endif
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     c     zzfgtp        begsr
     c     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     c     partky        readpe    record                                 79
     *
500d **   See if we only want received lines.
500d c     noxflg        ifeq      *on
500d c     *in79         andeq     *off
500d c     phstat        cabeq     '0'           try2
500d c                   endif
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     c     zzfill        begsr
     c                   movel     phvnam        w1vnam
770aA /free
770aA   hdStat = phStat;
770aA /end-free
     c                   select
     c     phstat        wheneq    '0'
     c                   movel(p)  sts00         w1stat
     c     phstat        wheneq    '1'
     c                   movel(p)  sts01         w1stat
     c     phstat        wheneq    '2'
     c                   movel(p)  sts02         w1stat
     c     phstat        wheneq    '3'
     c                   movel(p)  sts03         w1stat
     c                   other
     c                   move      *blanks       w1stat
     c                   endsl
416aAc     phdate        ifne      0
416aMc                   move      '*CMDMDY '    $cvcmd
416aMc                   move      phdate        $cvd8i
416aMc                   call      @cvtdt
416aMc                   parm                    $cvtdt
416aMc                   move      $cvd6o        w1date
416aD**                   MOVE PHDATE    W1DATE
416AAc                   else
416AAc                   move      *blanks       w1date
416AAc                   endif
414 Ac                   move      phtime        w1time
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     c     zzinz         begsr
     *
     C                   eval      viewo = 1
     C                   eval      maxvwo = 2
     *
     *  Define unique file key.
     *
     c     filuky        klist
     c                   kfld                    phwhse
     c                   kfld                    phdate
     *
     *  Define full key for main file.
     *
     c     fileky        klist
     c                   kfld                    phwhse
     c                   kfld                    phdate
     *
     c     filkey        klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
414bA*
414bA*  Define full key for main using PO.
414bA*
414bAc     filepo        klist
414bAc                   kfld                    phwhse
414bAc                   kfld                    phpo
414bA*
414bA*  Define full key for PODTL3 file.
414bA*
414bAc     detlky        klist
414bAc                   kfld                    pdwhse
414bAc                   kfld                    pdpo
414bAc                   kfld                    pdseq
     *
     *  Define partial key for main file (if needed).
     *
     c     partky        klist
     c                   kfld                    phwhse
414cA*
414cA*  Define key for OPTIONS file.
414cA*
414cAc     keyops        klist
414cAc                   kfld                    opwhse
414cAc                   kfld                    opcode
416 A*
416 A*  Define key for POSPO file.
416 A*
416 Ac     keypu         klist
416 Ac                   kfld                    $pwhse
416 Ac                   kfld                    $ppo
416 A*
416 A*  Define key for POSPO1 file.
416 A*
416 Ac     keypu1        klist
416 Ac                   kfld                    phwhse
416 Ac                   kfld                    phpo
     *
     *  Setup option and command display lines.
     *
     c                   move      optln(1)      optln1
401 Ac                   move      optln(2)      optln2
     c                   move      cmdln(1)      cmdln1
416 Ac                   z-add     1             k                 3 0
416 Ac                   move      *on           forevr            1
416 Ac                   move      '*NO '        sprpo             4
     *
413 D*R                   MOVE #PROG     $CVPRG
     c                   move      #prog         $pprg
     c                   move      #prog         $lprg
770aA*
770aA*  Define key for OPTIONS file.
770aA*
770aAC     opkey         klist
770aAC                   kfld                    opwhse
770aAC                   kfld                    opcode
770aA*
770aAC                   eval      opcode = '*SYSTEM '
770aAC                   eval      opwhse = *zeros
770aA*
770aAC     opkey         chain     options
770aAC                   if        not %found(options)
770aAC                   eval      opuci  = 'N'
770aAC                   eval      opdckv = 'N'
770aAC                   else
770aAC                   movel     opdata        opdta2
770aAC                   endif
770aA /free
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
770aA /end-free
770aA*
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     c     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
210 D*R         USKEY     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *OFF
210 D*R                   Z-ADDUSWHSE    PHWHSE
210 D*R                   ELSE
210 D*R                   Z-ADD1         PHWHSE
210 D*R                   ENDIF
210 A*
210 Ac                   call      'GETWHSE'
210 Ac                   parm                    #user
210 Ac     phwhse        parm      0             #whse             3 0
210 A*
     *
     *   Verify warehouse and get description.
     *
     c                   z-add     phwhse        whcode
     c                   move      *blanks       whdesc
     c                   move      '*VERIFY '    $lcmd
     c                   z-add     phwhse        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           *in21
414dD**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   movel     $lerm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in21
414dD**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   move      $lmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     c                   z-add     phwhse        $kwhse
     c                   z-add     phwhse        whcode
     c                   movel     $lerm         whdesc
     c                   end
     c                   end
     *
500dAc                   move      *off          noxflg            1
     c                   exsr      clrsch
     c                   exsr      scr01i
     c                   endsr
750aAC*----------------------------------------------------------------
750aAC*
750aAC*  ZZCKCW   Check to make sure all CW lines have a weight entered
750aAC*
750aAc     zzckcw        begsr
750aAC*
750aA /free
750aA   setll (phwhse: phpo) podtl;
750aA   dow forever = forever;
750aA     missingwgt = ' ';
750aA     reade (phwhse: phpo) podtl;
750aA     if %eof(podtl);
750aA       leave;
750aA     endif;
750aA     if pdqrc1 > 0 and pddwgt = 0 or
750aA        pdqrc2 > 0 and pddwgt = 0 or
750aA        pdqrc3 > 0 and pddwgt = 0;
750aA       chain (pdwhse: pditem) piritem;
750aA       if %found(piritem);
750aA         if itcwgt = 'Y';
750aA           missingwgt = 'Y';
750aA           leave;
750aA         endif;
750aA       endif;
750aA     endif;
750aA   enddo;
750aA /end-free
750aAC*
750aAc                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZCKRC   Check P/O to ensure that ALL detail lines have been rcvd
416 A*
416 Ac     zzckrc        begsr
416 A*
416 Ac     filkey        setll     podtl
416 Ac     filkey        reade     podtl                                  85
416 Ac   85              movel     *off          $ok
416 Ac     *in85         doweq     *off
416 Ac     detlky        chain     podtl3                             84
416 Ac     *in84         ifeq      *on
416 Ac                   movel     *off          $ok
416 Ac                   endif
416 Ac     filkey        reade     podtl                                  85
416 Ac                   enddo
416 A*
416 Ac                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZCKSP   Check for Super P/O or individual P/O on Super P/O.
416 A*
416 Ac     zzcksp        begsr
416 A*
416 A*    Test p/o selected for receiving is a Super P/O. This
416 A*    will be determined by a two part test. First, if the
416 A*    first two characters of the P/O begin with "SP" and we
416 A*    find the P/O in the Super P/O cross ref file.
416 Ac                   movel     $ppo          spo
416 Ac     keypu         setll     pospo                                  79
416 Ac     *in79         ifeq      *on
416 Ac     spo           andeq     'SP'
416 Ac                   move      '*YES'        sprpo
416 Ac                   else
416 Ac                   move      '*NO '        sprpo
416 Ac     keypu1        setll     pospo1                                 79
416 A*    Individiual p/o found on a Super P/O.
416 A*    Can't be marked for export.
416 Ac     *in79         ifeq      *on
416 Ac                   move      *on           error
416 Ac                   move      *on           cancel
416 Ac                   endif
416 Ac                   endif
416 A*
416 Ac                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     c     zzkeyf        begsr
     c                   move      dsfkey        $pofky
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     c     zzkeyu        begsr
     c                   move      dsukey        $pouky
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     c     zzopt         begsr
416 Ac                   move      *off          error
416 Ac                   move      *off          cancel
610aAC*
610aAC*   Call Recall Listing
610aAC*
610aAc     wkoopt        ifeq      'RC'
610aAc                   move      $puky         dsukey
610aAc                   move      $puky         hldkey
610aAc                   call      'LT330'
610aAc                   parm      '*DISPLAY'    $tcmd             8
610aAc                   parm      phwhse        $twhse            3 0
610aAc                   parm      phpo          $tpo              9
610aAc                   parm      ' '           $titem           15
610aAc                   parm      ' '           $tdev            10
610aAc                   parm      ' '           $tform           10
610aAc                   endif
770aAC*
770aAC*   Reset Postatus file for Dockvue
770aAC*
770aAc     wkoopt        ifeq      'DV'
770aAc                   move      $puky         dsukey
770aAc                   move      $puky         hldkey
770aA /free
770aA   // Set status for DockVue
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = :hdStat,
770aA                     posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :hdStat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
770aAc                   endif
401 A*
401 A*   Mark for export.
401 A*
401 Ac     wkoopt        ifeq      ' 8'
414cAc                   move      $puky         dsukey
416 Ac                   move      $puky         hldkey
416 A*
416 A*    Check if individual P/O on a Super P/O or selected is a Super
416 A*    P/O.
416 Ac                   exsr      zzcksp
416 A*    Individual p/o attached to a Super P/O, marking not allowed.
416 Ac     error         ifeq      *on
416 Ac                   exsr      zm3238
416 Ac                   goto      #notok
416 Ac                   endif
414cA*
414cA*   Get receiving options
414cA*
414cAc                   z-add     phwhse        opwhse
414cAc                   move      '*RCVLBL '    opcode
414cAc     keyops        chain     oprec                              79
414cA*
414cA*   If option not found or force option is not 'Y'
414cA*     then go ahead and mark it for export.
414cA*
414cAc     *in79         ifeq      *on
414cAc     opfrcm        orne      'Y'
4146Mc                   movel     *on           $ok               1
414bA*
414bA*   Otherwise, check to ensure all detail lines have been touched
414bA*
414cAc                   else
416 A*
416 D*R         FILEPO    SETLLPODTL
416 D*R         FILEPO    READEPODTL                    85
416 D*R                   MOVEL*ON       $OK     1
416 D*R 85                MOVEL*OFF      $OK
416 D*R         *IN85     DOWEQ*OFF
416 D*R         DETLKY    CHAINPODTL3               84
416 D*R         *IN84     IFEQ *ON
416 D*R                   MOVEL*OFF      $OK
416 D*R                   ENDIF
416 D*R         FILEPO    READEPODTL                    85
416 D*R                   ENDDO
416 A*
416 Ac                   move      *on           $ok
416 Ac                   select
416 A*
416 A*    Super P/O selected to be marked for export. Chk ALL are marked.
416 Ac     sprpo         wheneq    '*YES'
416 A*
416 Ac     keypu         setll     pospo
416 Ac     forevr        doweq     forevr
416 Ac     keypu         reade     pospo                                  79
416 Ac                   select
416 Ac     *in79         wheneq    *on
416 A*    Restore original key values.
416 Ac                   move      hldkey        dsukey
416 Ac                   leave
416 A*
416 Ac                   other
416 Ac                   move      pupo          phpo
416 Ac                   exsr      zzckrc
750aAc                   exsr      zzckcw
DRYaAC*    Missing weights. Super P/O can't be marked.
DRYaAc     missingwgt    ifeq      'Y'
DRYaAc     client        andeq     dairyland
DRYaAC*    Restore original key values.
DRYaAc                   move      hldkey        dsukey
DRYaAc                   leave
DRYaAc                   endif
416 A*
416 A*    Super P/O not fully received. Super P/O can't be marked.
416 Ac     $ok           ifeq      *off
416 A*    Restore original key values.
416 Ac                   move      hldkey        dsukey
416 Ac                   leave
416 Ac                   endif
416 Ac                   endsl
416 Ac                   enddo
416 A*
416 A*    Check single p/o not attached to a Super P/O.
416 Ac     sprpo         wheneq    '*NO '
416 Ac     error         andeq     *off
416 Ac                   exsr      zzckrc
750aAc                   exsr      zzckcw
416 A*
416 Ac                   endsl
416 A*
414bAc                   endif
750aAC*
750aA /free
750aA    if missingwgt = 'Y';
750aA      select;
DRYaA        when client = dairyland;
DRYaA          error = *on;
DRYaA          cancel = *on;
DRYaA          errmsg = 'Missing Weight - Cannot export';
DRYaA          exsr zm0105;
750aA        other;
750aA      endsl;

750aA    endif;
750aA /end-free
414bA*
414bAc     $ok           ifeq      *on
401 Ac                   exsr      inzpar
401 Ac                   move      '*DELETE '    $pcmd
401 Ac                   move      wkokyu        $puky
401 Ac                   move      $puky         $luky
401 Ac                   move      '*MARK   '    $lcmd
401 Ac                   move      *blanks       $lrtn
401 Ac                   call      'PO111'
401 Ac                   parm                    $lparm
416 A*
416 A*    User selected a Super P/O to mark, mark ALL attached p/o's.
416 Ac     sprpo         ifeq      '*YES'
416 Ac                   exsr      zzspsl
416 Ac                   endif
414bA*
414bAc                   else
414cAc                   move      *on           error
414cAc                   move      *on           cancel
414bAc                   exsr      zm0110
414bAc                   endif
GFCaAC*
GFCaAC                   if        client = glazier
GFCaAC*print po receipt
GFCaAc                   movel     'PO330PR '    wkprtf
GFCaAc     rpkey         chain     reports                            79
GFCaAc     *in79         ifeq      *on
GFCaAC                   movel     '*STD'        $pform           10
GFCaAc                   movel     '*JOB'        $pdev            10
GFCaAc                   else
GFCaAc                   move      rpform        $pform
GFCaAc                   move      rpdev         $pdev
GFCaAc                   endif
GFCaAc                   move      $pwhse        $pwhs             3
GFCaAc                   call      @prtpg
GFCaAc                   parm                    $pwhs
GFCaAc                   parm                    $ppo
GFCaAc                   parm                    $prtn
GFCaAc                   parm                    $pdev
GFCaAc                   parm                    $pform
GFCaAC                   endif
GFCaAC*
416 Ac     #notok        tag
401 Ac                   endif
401 A*
401 A*   Unmark.
401 A*
401 Ac     wkoopt        ifeq      ' 9'
401 Ac                   exsr      inzpar
401 Ac                   move      '*DELETE '    $pcmd
401 Ac                   move      wkokyu        $puky
416 A*
416 A*    Check if this is a Super P/O or ind. attached to a Super P/O.
416 Ac                   exsr      zzcksp
416 A*
416 Ac                   select
416 A*    Super P/O selected for UnMark.
416 Ac     sprpo         wheneq    '*YES'
416 A*    Individual p/o selected for UnMark.
416 Ac     sprpo         oreq      '*NO '
416 Ac     error         andeq     *off
416 A*
401 Ac                   move      $puky         $luky
401 Ac                   move      '*UNMARK '    $lcmd
401 Ac                   move      *blanks       $lrtn
401 Ac                   call      'PO111'
401 Ac                   parm                    $lparm
416 A*
416 A*    User selected a Super P/O to unmark, Unmark ALL attached p/o's.
416 Ac     sprpo         ifeq      '*YES'
416 Ac                   exsr      zzspsl
416 Ac                   endif
416 A*
416 A*    Individual P/O attached to a Super P/O, Unmark not allowed.
416 Ac     error         wheneq    *on
416 A*
416 A*    UnMark not allowed for ind.p/o attached to a Super P/O.
416 Ac                   exsr      zm3239
416 A*
416 Ac                   endsl
401 Ac                   endif
     *
     *   Work with detail
     *
     c     wkoopt        ifeq      '12'
500bAc     wkoopt        oreq      '52'
500bAc                   move      *blanks       $pcmd
CLD A*
CLD A*     Check if user is authorized to use this option.
CLD Ac     client        ifeq      cityline
SVLaAc**   client        oreq      saval
CLD Ac     wkoopt        ifeq      '52'
CLD Ac                   call      'CHKLIST'
CLD Ac                   parm      #prog         $cpgm            10
CLD Ac                   parm      wkoopt        $copt            20
CLD Ac                   parm      #user         $cuser           10
CLD Ac                   parm      *blanks       $crtn            10
CLD A*       User not authorized to use this option.
CLD Ac     $crtn         ifeq      '*NO '
CLD Ac                   move      *on           error
CLD Ac                   move      *on           cancel
CLD Ac                   movel(p)  err01         errmsg
CLD Ac                   exsr      zm0105
CLD Ac                   goto      endopt
CLD Ac                   endif
CLD Ac                   endif
CLD Ac                   endif
416 A*
416 A*    Determine if p/o selected is a Super P/O.
416 Ac                   movel     $ppo          spo               2
416 Ac     keypu         setll     pospo                                  79
416 A*    Super P/O with attached p/o's.
416 Ac     *in79         ifeq      *on
416 Ac     spo           andeq     'SP'
416 A*    Super P/O without attached p/o's.
416 Ac     *in79         oreq      *off
416 Ac     spo           andeq     'SP'
416 Ac                   move      '*YES'        $pspsw
416 Ac                   move      $ppo          $pspo
416 Ac                   move      *blanks       $ppo
416 Ac                   else
416 Ac                   move      '*NO '        $pspsw
416 Ac                   move      *blanks       $pspo
416 Ac                   endif
416 A*
500bAc     wkoopt        ifeq      '52'
500bAc                   move      '*SPRECV '    $pcmd
500bAc                   endif
500bA*
     c                   call      'PO120CL'
500bAc                   parm                    $pcmd
     c                   parm                    $puky
     c                   parm                    $prtn
416 A*
416 A*    On return, load Super P/O number into regular p/o
416 A*    for positioning purposes.
416 Ac     $pspsw        ifeq      '*YES'
416 Ac                   move      $pspo         $ppo
416 Ac                   endif
     c                   endif
218 A*
218 A*   UPC Receiving
218 A*
221 D*R         WKOOPT    IFEQ '10'
221 D*R                   MOVE $PUKY     $LUKY
221 D*R                   CALL 'PO210'
221 D*R                   PARM           $LPARM
221 D*R                   ENDIF
413bA*
413bA*   Enter HACCP information.
413bA*
413bAc     wkoopt        ifeq      '11'
500eA*
500eAc                   move      '*DTLCHK '    $lcmd
500eAc                   movel     $ppo          $lpo
500eAc                   move      *zeros        $lseq
500eAc                   call      'PO170'
500eAc                   parm                    $lparm
500eAc     $lrtn         ifeq      '*PGMQ   '
500eAc                   move      *on           error
500eAc                   move      $lmsg         #msgk
500eAc                   exsr      zmqmsg
500eAc                   endif
416 A*
416 A*    Check if this is a Super P/O.
500eA*
500eAc     $lrtn         ifne      '*PGMQ   '
500eA*
510bd*                  movel     $ppo          spo               2
510bd*    keypu         setll     pospo                                  79
510bd*                  select
510bd*    *in79         wheneq    *off
510bd*    spo           andne     'SP'
416 A*
413bAc                   move      $puky         $luky
413bAc                   move      '*PO     '    $lcmd
413bAc                   move      *zeros        $lseq
413bAc                   move      *blanks       $litem
413bAc                   call      'PO170'
413bAc                   parm                    $lparm
416 A*
510bd*                  other
416 A*
416 A*    Enter HACCP info not allowed for Super P/O.
510bd*                  move      *on           error
510bd*                  exsr      zm3240
416 A*
510bd*                  endsl
413bAc                   endif
500eAc                   endif
416 A*
416 A*   Work with Super P/O.
416 A*
416 Ac     wkoopt        ifeq      '13'
416 A*
416 A*    Check if this is a Super P/O.
416 Ac                   movel     $ppo          spo               2
416 Ac     keypu         setll     pospo                                  79
416 Ac                   select
416 A*    Super P/O with attached p/o's.
416 Ac     *in79         wheneq    *on
416 Ac     spo           andeq     'SP'
416 A*    Super P/O without attached p/o's.
416 Ac     *in79         oreq      *off
416 Ac     spo           andeq     'SP'
416 A*
416 Ac                   move      $puky         $luky
416 Ac                   move      $lpo          $lspo
416 Ac                   move      *blanks       $lpo
416 Ac                   move      '*CHANGE '    $lcmd
416 Ac                   call      'PO110C'
416 Ac                   parm                    $lparm
700 Ac                   eval      $lprg = #prog
416 A*
416 Ac                   other
416 A*
416 A*    Work w/ Super P/O not allowed for individual p/o's.
416 Ac                   move      *on           error
416 Ac                   exsr      zm3237
416 A*
416 Ac                   endsl
416 Ac                   endif
416cA*
416cA*   Enter Lumper information.
416cA*
416cAc     wkoopt        ifeq      '15'
416cA*
416cA*    Check if this is a Super P/O.
416cAc                   movel     $ppo          spo               2
416cAc     keypu         setll     pospo                                  79
416cAc                   select
416cAc     *in79         wheneq    *off
416cAc     spo           andne     'SP'
416cA*
416cAc                   move      $puky         $luky
416cAc                   move      '*PO     '    $lcmd
416cAc                   z-add     0             $lhedt
416aAc                   z-add     0             $lheti
416cAc                   call      'PO180'
416cAc                   parm                    $lparm
416cA*
416cAc                   other
416cA*
416cA*    Enter Lumper info not allowed for Super P/O.
416cAc                   move      *on           error
416cAc                   exsr      zm3240
416cA*
416cAc                   endsl
416cAc                   endif
416 A*
500f *****
     *   Display pallet estimate
     *
500f c     wkoopt        ifeq      '16'
500fAc                   move      *blanks       $pcmd
500fA*
500fA*    Determine if p/o selected is a Super P/O.
500fAc                   movel     $ppo          spo               2
500fAc     keypu         setll     pospo                                  79
500fA*    Super P/O with attached p/o's.
500fAc     *in79         ifeq      *on
500fAc     spo           andeq     'SP'
500fA*    Super P/O without attached p/o's.
500fAc     *in79         oreq      *off
500fAc     spo           andeq     'SP'
500fAc                   move      '*YES'        $pspsw
500fAc                   move      $ppo          $pspo
500fAc                   move      *blanks       $ppo
500fAc                   else
500fAc                   move      '*NO '        $pspsw
500fAc                   move      *blanks       $pspo
500fAc                   endif
500fA*
500fA*
500f c                   call      'PO126CL'
500fAc                   parm                    $pcmd
500f c                   parm                    $puky
500f c                   parm                    $prtn
500fA*
500fA*    On return, load Super P/O number into regular p/o
500fA*    for positioning purposes.
500fAc     $pspsw        ifeq      '*YES'
500fAc                   move      $pspo         $ppo
500fAc                   endif
500f c                   endif
     *
510aAc     wkoopt        ifeq      '17'
510aAc                   move      *blanks       $pcmd
     *    Determine if p/o selected is a Super P/O.
510aAc                   movel     $ppo          spo               2
510aAc     keypu         setll     pospo                                  79
     *    Super P/O with attached p/o's.
510aAc     *in79         ifeq      *on
510aAc     spo           andeq     'SP'
     *    Super P/O without attached p/o's.
510aAc     *in79         oreq      *off
510aAc     spo           andeq     'SP'
510aAc                   move      '*YES'        $pspsw
510aAc                   move      $ppo          $pspo
510aAc                   move      *blanks       $ppo
510aAc                   else
510aAc                   move      '*NO '        $pspsw
510aAc                   move      *blanks       $pspo
510aAc                   endif
     *
510aAc                   call      'PO190'
510aAc                   parm                    $pcmd
510aAc                   parm                    $puky
510aAc                   parm                    $prtn
     *
510aA*    On return, load Super P/O number into regular p/o
510aA*    for positioning purposes.
510aAc     $pspsw        ifeq      '*YES'
510aAc                   move      $pspo         $ppo
510aAc                   endif
510aAc                   endif
CLD Ac     endopt        tag
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     c     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     c     ptinp1        ifne      0
     c                   z-add     ptinp1        whcode
     c                   move      *blanks       whdesc
     c                   move      '*VERIFY '    $lcmd
     c                   z-add     ptinp1        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           *in21
414dD**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   movel     $lerm         errmsg
     c                   exsr      zm0105
     c                   goto      endzps
     c                   else
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in21
414dD**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   move      $lmsg         #msgk
     c                   exsr      zmqmsg
     c                   goto      endzps
     c                   else
     c                   z-add     ptinp1        phwhse
     c                   z-add     phwhse        $kwhse
     c                   move      *blanks       phpo
     c                   z-add     ptinp1        whcode
     c                   movel     $lerm         whdesc
     c                   z-add     0             ptinp1
     c                   move      *on           repos
     c                   end
     c                   end
     c                   end
     *
     *  See if user is trying to position to Delivery Date
     *
     c     ptdate        ifne      *zeros
     c                   movel     ptdate        phdate
     c                   move      *zeros        ptdate
     c                   move      *on           repos
     c                   end
     c     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     c     zzpos2        begsr
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
     c     $pocmd        ifeq      '*TOP'
     c     partky        setll     record
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     partky        setgt     record
     c                   end
     c                   end
     c                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ZZSPSL   Process Super P/O to Mark/UnMark attached p/o's.
416 A*
416 Ac     zzspsl        begsr
416 A*
416 Ac     keypu         setll     pospo
416 Ac     forevr        doweq     forevr
416 Ac     keypu         reade     pospo                                  79
416 Ac                   select
416 Ac     *in79         wheneq    *on
416 Ac                   leave
416 A*
416 Ac                   other
416 A*
416 A*    Call program to mark/unmark individual p/o.
416 Ac                   move      pupo          $lpo
416 Ac                   move      *blanks       $lrtn
416 Ac                   call      'PO111'
416 Ac                   parm                    $lparm
416 A*
416 Ac                   endsl
416 Ac                   enddo
416 A*
416 Ac                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 4 5 6 8 91112131516521718RCDV
**  OPTLN - Option display line
  2=Change  4=Delete  5=View  6=Receipt  8=Mark/export  9=Unmark  11=HACCP
12=Work w/dtl 13=Work w/SuperPO 15=Lumper 16=Plt Est 17=Qty Diff            Labe
18= Produce Labels 52=PickSlt RC=Recall Listing DV=Resend PO

**  CMDLN - Command display line
F3=Exit F4=Prompt F5=Refresh F6=Create Regular P/O F23=more opts F24=More keys
F7=Create Super P/O F9=PO Order F11-Rcvd PO F12=Cancel           F24=More keys
F3=Exit F4=Prompt F5=Refresh F6=Create Regular P/O F23=more opts F24=More keys
F7=Create Super P/O  F9=PO Order  F11-ALL  F12=Cancel            F24=More keys
**  DESC - Error descriptions
Err: Only 52=PickSlt allowed for Vendor 3194
