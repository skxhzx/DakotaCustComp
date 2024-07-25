417cA /copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PO110A    PO header maintenance (one whse) - Display
     F*  08 October, 1996
     F*  Hemant Kapadia
     F*
     F*  SK110 - 1.01
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
218 AF*    01/28/97  RH
     F*      - Add option 10=UPC Receiving to screen1
     F*      - call  full screen UPC receiving.
     F*
     F*    04/30/97  RH   2.20
     F*      - Refresh screen to reset pointer if CANCEL or EXIT was
     F*        used during F6 ADD.
     F*    06/05/97  RH   2.21
     F*      - Remove 10=UPC Receiving from screen1.
401 AF*    07/11/97  HNK  4.01
     F*      - Add options 8 and 9 to Mark and Unmark PO for export.
412 AF*    09/16/99  HNK  4.12
     F*      - Display delivery date
413bAF*    10/25/99  MLB  4.13b
     F*      - Add option 11=HACCP information to ZZOPT.
     F*      - Add option 11=HACCP information to array ZOPT.
     F*      - Add option 11=HACCP information to array OPTLN.
413 AF*    11/09/99  HNK  4.13
     F*      - Disable Display delivery date.  There is no corresponding
     F*        field in the IMPPOH file and hence cannot be imported.
     F*
414 AF*    08/20/00  KDE  4.14
     F*      - Display delivery date and time.                         g
     F*
414 AF*    09/19/00  KDE  4.14
     F*      - Change to display error message when trying to export   g
     F*        PO and all detail lines have not been touched.
     F*
414bAF*    10/02/00  KDE  4.14b
     F*      - Do not allow a delete if receivings have ocurred.
     F*
414cAF*    10/09/00  DAS  4.14c
     F*      - Added OPTIONS file and corresponding data structure.
     F*      - Revised ZZOPT to only check if detail lines have been
     F*        touched if receiving option field OPFRCM is 'Y'.
     F*      - Revised ZZOPT to set on the ERROR and CANCEL flags in
     F*        order to highlight the option line in error.
     F*
414d F*    10/18/00  DAS  4.14d
     F*      - Changed warehouse position cursor indicator from 01
     F*        to 03.
     F*      - Revised SFLDSP routine display POSTN record base on
     F*        error condition. If error is on, write record in normal
     F*        sequence. Otherwise, write it last.
     F*        Re: Before change,the system would only position the
     F*            cursor correctly on the first display of the screen.
     F*            After that, the cursor would always be positioned
     F*            to the first field, warehouse.
     F*
416 AF*    10/26/01  MLB  4.16
     F*      - Added support to program for Super P/O's.
     F*      - Added new option 13=Work with Super P/O's
     F*      - Added new f-key F7=Create Super P/O.
     F*      - Added support for F24=More keys.
416a F*    10/11/01  RH   4.16a
     F*      - Fix - display delivery date in MMDDYY order.            g
416bAF*    11/09/01  DAS  4.16b
     F*      - Removed 414b changed. Now handled through PO114.
416cAF*    12/18/02  HNK  4.16c
     F*      - Put option 15 for Lumper info.
416dAF*    02/28/03  DAS  4.16d
     F*      - Initialized $CVPRG in ZZINZ.
500aAF*    11/22/04  RH   5.00a
     F*      - Add option 6=Print PO Receiving Receipt
500bAF*    12/27/04  RH   5.00b
     F*      - Add option 52=Special Receiving (Force directed put away
     F*        direct to pick slot, no license plates are used)
     F*      - Add option 52=Special Receiving to ZOPT, OPTLN
500cAF*    12/30/04  DAS  5.00c
     F*      - Changed 52=SpcRecv to 52=StuffIt.
500dAF*    04/21/05  RH   5.00d
     F*      - ENH: Add F11 to view received PO's only.
     F*
500eAF*    10/26/05  JCJ  5.00e
     F*      - Add check to see if a user is allowed to enter HACCP
     F*        information when option 11 (HACCP) is tacken.
500fAF*    04/11/06  RH   5.00f
     F*      - ENH: Add option 16=Pallet estimate
500gAF*    04/27/06  MLB  5.00g
     F*      - Enh: Added client custom code support.
510bAF*    11/13/06  RAH  5.10b
     F*      - Enh: Added call to PO190 - display detail when qty ord
     F*             <> qty rcvd.
510cAF*    11/16/06  RAH  5.10c
     F*      - Enh: Converted to RPGLE
     F*      - Enh: Enabled SuperPO's to have HACCP information.
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
610d *    04/30/10  GJA  6.10c     P#00243
     *      - Enh: change UCI to be option driven.  OPUCI
     *
610e *    05/11/10  GJA  6.10e     P#00243
     *      - Fix: change UCI option position.
     *
640 A*    09/15/11  MLB  6.40
     *      - Fix: Revised routine FGET to clear p/o number instead of
     *        entire $pouky, $pofky fields which then causes a data decimal
     *        error when the pgm attempts to process the setll cmd.
      *
640aA*    05/24/12  LMC  6.40a
     *      - Enh: Replace existing HACCP programs with new user
     *        definable programs.                                     cimal
650aA*    03/07/13  LMC  6.50a
     *      - Enh: Add logic to print new haccp if log records exist
650bA*    03/22/13  LMC  6.50b
     *      - Enh: Add logic for passing parms needed for haccp cross
     *      reference file.
650cA*    04/05/13  RTR  6.50c
     *      - Enh: Add option 'U' for partial exports.
650dA*    04/05/13  LMC  6.50d
     *      - Enh: Change command lines, move F6 to second line, move
     *      F7 to first line. Just swap these two on the command lines
650eA*    04/16/13  LMC  6.50e
     *      - Enh: Change warehouse field passed to ha300 to 15.5
650fA*    07/16/13  LMC  6.50e
     *      - Enh: Added warning window on HACCP change for super PO
     *      Notify user that all po's attached to the super PO will
     *      be updated with the Haccp information entered.
     *      - Enh: changed display file to PO110A01.
650gA*    10/11/13  LMC  6.50g
     *      - Fix: Need to print for each po linked to the super PO
650hA*    01/16/14  RH   6.50h
     *      - Fix: Add code missed in update.
650i *    04/15/14  RTR  6.50i
     *      - Enh: Added status 5 for import error from PI265S
     *
700 A*    02/02/16  MLB  7.00
     *      - Fix: Revised pgm to reset $LPRG on return from PO110C.
     *        PO110C was corrupting field.
     *
710aA*    02/14/17  DAS  7.10a
     *      - Enh: Call GETDEV to get device for F6=Receipt.
710b *    02/15/17  GJA  7.10b
     *      - Enh: ability to change where PO receipts will print by
     *        department.  You will need to change RP110CL to be entry
     *        level of "2".  Then you will call RP120CL so you can
     *        designate a printer to the user default department.
     *
720a *    02/26/18  RTR  7.20a
     *      - Enh: Make Partial Export option controlled.
     *
750a *    03/03/21  LMC  7.50a
     *      - Enh: Added check for missing weights.
770aA*    05/18/23  LMC  7.70a
     *      - Added option DV to reset postatus file field POSSTAT
     *        in order to allow the user to resend a po.
     *
     *----------------------------------------------------------------
     *
     *  Client Custom Revisions:
     *
     F*  Client Custom Revisions: City Line
     F*
CLD AF*    04/27/06  MLB  CLD
     F*      - Add call to program CHKLIST to see if user
     F*        is authorized to use 52=Stuffit putaway option.
     F*
     F*  Client Custom Revisions: Packers
     F*
PCK AF*    11/06/06  JCJ  PCK
     F*      - Add call to program CW135 to see if all UCI'S have been
     F*        entered before allowing the PO to be Marked for export.
     F*
     F*----------------------------------------------------------------
     F* Renzi Brothers
RNZaAF*    07/23/08  RH   RNZa
     F*      - Revise to not allow option 52=Stuffit.
     F*
     *----------------------------------------------------------------
     *  EG Forrest Custom Mods
     *
EGFaA*    02/18/10  RH   EGFa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *
     *----------------------------------------------------------------
     *  Inter County Bakers
     *
ICB A*    03/19/14  RH   ICB
     *      - Revised program to prevent option 'U' for ICB.
     *----------------------------------------------------------------
     *  Jordano's Custom Mods
     *
JDO A*    04/21/05  DAS  JDO
     *      - Revised program to prevent option 12 for Bread P.O.'s,
     *        which are P.O.'s with vendor 3194.
     *
     *  Kohl Custom Mods
     *
KHLaA*    08/10/14  RH   KHLa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *
     *  Saval Custom Mods
     *
SVLaA*    08/13/09  RH   SVLa
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  Glazier
     *
GFCaA*    09/25/10  GJA  GFCa
     *      - Add call to program PO330 to print receipt
     *        when marked open.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:  A&D Foods
ADFaA*    04/18/17  RH   ADFa
     *      - Disable partial export options, Entree can't use.
     *
416 AF*----------------------------------------------------------------
416 AF*  Super P/O notes.
416 AF*
416 AF*    Maintaining a Super P/O
416 AF*      - A Super P/O can have individual purchase orders added to it
416 AF*        at any point.
416 AF*
416 AF*    Marking a Super P/O for Export
416 AF*      - A Super P/O can only be marked for export when all individual
416 AF*        purchase orders attached to the Super P/O have been received.
416 AF*        If Force marking of detail lines is active, every purchase
416 AF*        order must be fully marked before the Super P/O and all
416 AF*        individual purchase orders can be marked for export.
416 AF*      - Individual purchase orders attached to a Super P/O cannot be
416 AF*        marked for export individually. If a individual p/o needs to
416 AF*        exported it has to be removed from the Super P/O and then
416 AF*        marked and exported.
416 AF*
510A F*   06/19/06  RMC  5.10  PACKERS only
     F*     - If Destination storage location is blank
     F*       send message before export.
     F*
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    02/13/13  MLB  GFS
     *      - Add call to program CHKLIST to see if user
     *        is authorized to use delete option.
     *      - Per Hemant Skype on 02/12/13.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy
FBYaA*    09/09/16  RH   FBYa
     *      - Disable Option 'U' for partial export.
FBYbA*    01/11/17  RH   FBYb
     *      - Enh: Print PO receipt and HACCP report when mark for
     *        export.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *    07/12/17  MLB  DRY
DRY A*      - Disable Option 'U' for partial export.
     *      - Added DRY to FBYa mod.
     *
DRYaA*      - Edit - do not allow mark for export unless all CW lines
     *        with a quantity received have a weight entered.
     *
416 AF*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        POSITION CURSOR
     F*  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  79        CHAIN INDICATOR
     F*  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
650fDf*po110afm  cf   e             workstn
650fMfpo110a01  cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(dspsfl:recno)
     f                                     sfile(msgrec:msgk)
     fworkopt   uf a e           k disk
     fpohdr     if   e           k disk
     f                                     rename(phrec:record)
     fpodtl     if   e           k disk
414 Afpodtl3    if   e           k disk
     f                                     rename(pdjrec:ptouch)
416 Afpospo     if   e           k disk
416 Afpospo1    if   e           k disk
     f                                     rename(purec:purec1)
414cAfoptions   if   e           k disk
500aAfreports   if   e           k disk
710bAfpiruser   if   e           k disk
750aAfpiritem   if   e           k disk
510A F*POHDRM  UF  E           K        DISK                      A
510A fpohdrm    uf a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a2              s              1    dim(2)
     d a10             s              1    dim(10)
     d a75             s              1    dim(75)
     d fkey            s             50    dim(10)
     d ukey            s             50    dim(10)
     d optlst          s              2    dim(24)
     d cmdlst          s              2    dim(24)
     d zopt            s              2    dim(20) ctdata perrcd(20)
610bMd optln           s             75    dim(4) ctdata perrcd(1)
401 Md****             s             75    dim(2) ctdata perrcd(1)
416 DD**                  CMDLN   1   1 79
500dDD*                   CMDLN   1   2 79
500dMd cmdln           s             79    dim(4) ctdata perrcd(1)
JDO AD desc            s             50    dim(1) ctdata perrcd(1)
500gAD*
650bAd $lparm1         s             48    dim(20)
500gAD*----------------------------------------------------------------
500gAD*  Customer id
500gAD*
     d @getcl          c                   const('GETCLIENT')
CLD A /COPY QCOPYSRC,ID#CITYLIN
RNZaA /COPY QCOPYSRC,ID#RENZI
500gAD*
510A D*
510A  /COPY QCOPYSRC,ID#PACKERS
JDO A /COPY QCOPYSRC,ID#JORDANO
SVLaA /COPY QCOPYSRC,ID#SAVAL
EGFaA /COPY QCOPYSRC,ID#EGF
KHLaA /COPY QCOPYSRC,ID#KHL
GFCaA /COPY QCOPYSRC,ID#GLAZIER
GFS A /COPY QCOPYSRC,ID#GFS
ICB A /COPY QCOPYSRC,ID#ICB
ADF A /COPY QCOPYSRC,ID#ADF
FBY A /COPY QCOPYSRC,ID#FBY
DRY A /COPY QCOPYSRC,ID#DAIRYLA
510A  * Destination Storage Location - Packers
510A d                 ds
510A d  phmm5                  1     40
510A d  phdest                 1      4
     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     d $prtky          ds
     d  $len50                 1     50
     d  $kwhse                 1      3  0
     d  $kpo                   4     10  0
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     d                 ds
     d  dsfkey                 1     50
     d  dsukey                 1     50
     d  phwhse                 1      3  0 inz(0)
     d  phpo                   4     12
416 Ad                 ds
416 Ad  hldkey                 1     50
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $lwhse                19     21  0
218 Ad  $lpo                  22     30
413bAd  $lseq                 31     35  0
413bAd  $litem                36     50
416 AD*
416 Ad  $lspo                 31     39
     D*
416cAd  $lhedt                31     38  0
416cAd  $lheti                39     44  0
640aA* used for haccp processing
640aAD  $llevel               22     25
640aAD  $llicense             26     40
640aAD  $lhpo                 41     49
640aAD  $lhseq                50     54  0
640aAD  $ltype                55     57
640aAD  $lhspo                58     61
720aAd*----------------------------------------------------------------
720aAd*  Called Program Prototypes
720aA /copy *libl/qcopysrc,p.getopint
720aAd*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     d @chgpg          c                   const('PO112')
     d @delpg          c                   const('PO114')
610bAd @lblpg          c                   const('LB400CL')
     d @prtpg          c                   const('PO330CL')
500aDD*             '*NONE'               C         @PRTPG
     d @ucict          c                   const('CW135')
414cAD*----------------------------------------------------------------
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA /copy qcopysrc,c#stdsql
414cAD*  *RCVLBL  -  Receiving options
414cAD*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPLPGM  -  Receiving label program.
     D*    OPUPCT  -  Ideal slot usage percentage.
     D*    OPPDEF  -  PIR minimum number of slots priority.
     D*    OPPBLD  -  PIR same build code priority.
     D*    OPPACT  -  PIR same activity zone priority.
     D*    OPFDEF  -  Fixed minimum number or slots priority.
     D*    OPFASL  -  Fixed same aisle priority.
     D*    OPFSID  -  Fixed same side priority.
     D*    OPFLVL  -  Fixed highest level priority.
217 AD*    OPPASL  -  PIR same aisle priority.
217 AD*    OPPFRC  -  Force PIR same aisle priority.
221 AD*    OPPLCN  -  Use generic license plates.
409 AD*    OPPCHM  -  Check chimney (Y,N)
409 AD*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
412 AD*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
414 AD*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
     D*
     D* Data structure
     D*
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
610dA
610dA*----------------------------------------------------------------
610dA*  *SYSTEM  -  System options.
610dA*----------------------------------------------------------------
610dA*
610dA* Fields
610dA*
610dA*    OPUCI   -  Use UCI processing (Y,N)
610dA*
610dA* Data structure
610dA*
610dAD opdta2          ds
610eDD**opuci                 33     33
610eMD  opuci                 36     36
770aAd  opdckv                50     50
610dAD  optend2              117    117

     D*----------------------------------------------------------------
     D* Status message(s)
     d sts00           c                   const('Open')
     d sts01           c                   const('Partial receipt')
     d sts02           c                   const('Received in full')
     d sts03           c                   const('Ready for export')
     d sts04           c                   const('Partial export')
650iAd sts05           c                   const('Import error')
     d err01           c                   const('Not authorized t-
610cMd                                     o use 52=Pickslt')
     d err02           c                   const('Not all UCIs are ent-
     d                                     ered.  can not expor-
     d                                     t.')
SVLa d err03           c                   const('Not authorized t-
     d                                     o use option')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
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
416 AD*
416 AD*   Redefine key
416 AD*
416 Ad  $pwhse                19     21  0
416 Ad  $ppo                  22     30
416 Ad  $pspo                 31     39
416 Ad  $pspsw                65     68
     D*
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
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d  errcl1                 1     10
     d  errcl2                11     16
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
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
720aAd optPartExp      s               n   inz('0')
     D v               s              2  0
     D view            s              8
     D viewo           s              1  0
650gAD hapo            s              9
750aAD missingwgt      s              1
750aAD forever         s              1
770aAd dockvue         s               n   inz('0')
770aAd ocode           s              8
770aAD nostamp         s               z     inz
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PRTKY  Partial key
     C*
     C*    Returned Parameters
     C*      $RTNCD  *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $prtky           50
     c                   parm                    $rtncd            8
     C*
     C*  Define keys
     C*
     C*     WORKOPT  (Unique key)
     C*
     c     wkounq        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    wkokyf
     c                   kfld                    wkokyu
     C*
     C*     WORKOPT  (Partial key)
     C*
     c     wkoprt        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     C*
     C*     WORKOPT  (Save key for top record on delete display)
     C*
     c     *like         define    wkokyf        $wkof
     c     *like         define    wkokyu        $wkou
     c     deltop        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    $wkof
     c                   kfld                    $wkou
     C*
     C*     USERCODE
     C*
     c     uskey         klist
     c                   kfld                    #user
     C*----------------------------------------------------------------
     C*  Main line
     C*
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
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c     nxtscr        caseq     '02 '         sc2
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   exsr      clrsch
     C*
     c     $rtncd        ifeq      '*EXIT   '
     c     $rtncd        oreq      '*CANCEL '
     c                   seton                                        lr
     c                   end
     c                   return
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Set OFF command key indicators
     C*
     c                   setoff                                       kckekf
     c                   setoff                                       kl
     C*
     C*   Overlay screen with title
     C*
     c                   write     title
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*   Overlay screen with subfile screen
     C*
     c     nxtscr        ifeq      '01 '
     c                   exsr      sfldsp
     c                   read      postnrec                               50
     c                   end
     c     nxtscr        ifeq      '02 '
     c                   exsr      deldsp
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       2021
414dAc                   setoff                                       03
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cancel            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   read      dspsfc                                 50
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   write     clr0306
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 wrap-up
     C*
     c     scr02e        begsr
     c                   move      '01 '         nxtscr
     c                   move      *off          *in90
     c                   write     clr0306
     C*
     C*   If delete was not canceled (no errors)
     C*     then reposition to record just before first deleted rec.
     C*
     c     cancel        ifeq      *off
     c                   move      '*POSTN2 '    $pocmd
     c                   move      frstky        $pofky
     c                   exsr      fgtway
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     c     $portn        ifeq      '*NOMORE '
     c                   move      '*TOP    '    $pocmd
     c                   else
     C*
     C*   Otherwise, position to last record read.
     C*
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
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     c     status        caseq     rollup        roll01
     c     status        caseq     rolldn        roll01
     c     status        caseq     comand        cmd01
     c                   cas                     ent01
     c                   end
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     c     sc2           begsr
     c     status        caseq     rollup        roll02
     c     status        caseq     rolldn        roll02
     c     status        caseq     comand        cmd02
     c                   cas                     ent02
     c                   end
     c     endsc2        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
500gA*
500gA* Get client id.
500gA*
500gAc                   call      @getcl
500gAc                   parm                    client           10
     C*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*  Initialize subfile (DSPSFL) record
     C*
     c                   z-add     1             recno
     c                   write     dspsfl                               79
     C*
720aA
720aA /free
720aA   // Get Allow Partial PO Exports option
720aA   optint.type = 'Interface   ';
720aA   optint.cat  = 'Export POs          ';
720aA   optint.name = 'Allow Partial Export';
720aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
720aA             optint.valn: optint.vala: optint.return);
720aA   if optint.return = '*OK'
720aA    and optint.vala = 'Y';
720aA     optPartExp = *on;
720aA   else;
720aA     optPartExp = *off;
720aA   endif;
720aA /end-free
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  CLRSCH   Clear everything out of work file
     C*
     c     clrsch        begsr
     c     wkoprt        setll     workopt
     c     wkoprt        reade     workopt                              7979
     c     *in79         doweq     *off
     c                   delete    wkorec
     c     wkoprt        reade     workopt                              7979
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  CMD01    Screen 1 command key routine
     C*
     c     cmd01         begsr
     C*
     C*  TEST FOR CMD3 - EXIT
     C*
     c     *inkc         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $rtncd
     c                   goto      cmd01e
     c                   end
500d C*
500d C*  TEST FOR CMD11 - Received or ALL
500d C*
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
500d C*
500d c                   move      '*REFRESH'    pagcmd
500d c                   move      *loval        fkey
500d c                   move      *loval        ukey
500d c                   exsr      pag01
500d c                   endif
     C*
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     c     *inkl         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $rtncd
     c                   goto      cmd01e
     c                   end
     C*
     C*  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     C*
     C*     TEST FOR CMD5 - REFRESH
     C*
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
     C*
     C*  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     C*
     c                   exsr      savopt
     c     error         cabeq     *on           cmd01e
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     C*
     C*  TEST FOR CMD6 - ADD RECORD
     C*
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
416 AC*
416 AC*  TEST FOR CMD7 - Create Super P/O.
416 AC*
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
     C*
     C*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     C*
     c     *inkj         ifeq      *on
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     C*
     C*     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     C*
     c                   sub       10            row#
     c     row#          iflt      1
     c     row#          orgt      dsplyd
     c                   move      *on           error
     c                   move      *blanks       errmsg
     c                   exsr      zm0106
     c                   goto      cmd01e
     c                   end
     C*
     C*     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     C*
     c                   move      '*POSTN2U'    $pocmd
     c                   move      ukey(row#)    $pouky
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       CMD01E
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     C*
     c     *inkr         ifeq      *on
     c                   move      '*TOP    '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     C*
     c     *inks         ifeq      *on
     c                   move      '*BOTTOM '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*   Process non-standard function keys.
     C*
     c                   exsr      zzcmd
     c     cmd01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  CMD02    Screen 2 command key routine
     C*
     c     cmd02         begsr
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     c     *inkl         ifeq      *on
     c                   move      *on           cancel
     c                   exsr      scr02e
     c                   goto      cmd02e
     c                   end
     c     cmd02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  DELADD   Add record to subfile for delete display
     C*
     c     deladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     C*
     C*  GET RECORD INFO
     C*
     c                   move      '*GET    '    $pocmd
     c                   move      wkokyu        $pouky
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       DELADE
     C*
     C*  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     C*
     c     recno         ifeq      1
     c                   move      wkokyf        $wkof
     c                   move      wkokyu        $wkou
     c                   end
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     c                   exsr      zzfill
     c                   move      wkoopt        option
     c                   write     dspsfl
     c                   end
     c     delade        endsr
     C*----------------------------------------------------------------
     C*
     C*  DELDSP   Display subfile of records marked for deletion
     C*
     c     deldsp        begsr
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     c                   write     morrec
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT01    Screen 1 enter key routine
     C*
     c     ent01         begsr
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     c                   exsr      savopt
     c     error         cabeq     *on           ent01e
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
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
     C*
     C*  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     C*
     c                   exsr      optns
     C*
     C*  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     C*
     C*R         OTAKEN    IFEQ *OFF
     C*R                   MOVE 'EOJ'     NXTSCR
     C*R                   GOTO ENT01E
     C*R                   END
     c     ent01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT02    Screen 2 enter key routine
     C*
     c     ent02         begsr
     C*
     C*  Save first delete key.
     C*
     c     *like         define    $puky         frstky
     c                   move      $puky         frstky
     C*
     C*  Delete the records that have been selected
     C*
     c     wkoprt        setll     workopt
     c                   move      *off          stop
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     C*
     c     wkoopt        ifeq      ' 4'
416bDC**
416bDC**  Check to ensure no receiving has ocurred.
416bDC**
416bDC**         FILEKY    SETLLPODTL
416bDC**         FILEKY    READEPODTL                    85
416bDC**                   MOVEL*ON       $OK     1
416bDC**         *IN85     DOWEQ*OFF
416bDC**         DETLKY    CHAINPODTL3               84
416bDC**         PORACT    IFEQ 'R'
416bDC**         PORACT    OREQ 'X'
416bDC**                   MOVEL*OFF      $OK
416bDC**                   ENDIF
416bDC**         FILEKY    READEPODTL                    85
416bDC**                   ENDDO
     C*
     C*  Call delete program
     C*
416bDC**         $OK       IFEQ *ON
     c                   exsr      inzpar
     c                   move      '*DELETE '    $pcmd
     c                   move      wkokyu        $puky
     c                   call      @delpg
     c                   parm                    $parms
416bDC**                   ELSE
416bDC**                   EXSR ZM0114
416bDC**                   ENDIF
     C*
     C*     Error occured - Error message sent back
     C*
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     C*
     C*     Error occured - Error message sent to program msgq
     C*
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     C*
     C*     Delete canceled
     C*
     c     $prtn         ifeq      '*CANCEL '
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   else
     C*
     C*     Delete was successful.
     C*
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
     C*
     c                   end
     c                   end
     c                   exsr      scr02e
     c     ent02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  FGTWAY   Gateway to file handling routines
     C*
     C*    Input Parameters
     C*      $POCMD   *INIT    - Initialize and return
     C*               *GET     - Get record for $POUKY value
     C*               *GETNEXT - Get next record
     C*               *GETPREV - Get previous record
     C*               *WRITPOS - Write position record to display
     C*               *READPOS - Read position record
     C*               *POSTN2  - Position to $POFKY
     C*               *POSTN2U - Position to $POUKY
     C*               *TOP     - Position to top of file
     C*               *BOTTOM  - Position to bottom of file
     C*      $POFKY   Key for positioning within file
     C*      $POUKY   Unique key used for change/delete operations
     C*
     C*    Returned Parameters
     C*      $PORTN   *NOMORE  - Beginning/End of file was reached
     C*               *NOTFND  - Record not found on a GET
     C*               *FOUND   - Record found
     C*               *REPOS   - Repositioning took place
     C*               *ERROR   - Error occured
     C*      $POERM   Error message
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are the same.
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  FGETN    Get next record
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  FGETP    Get previous record
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  FPOS2    Position to record
     C*
     c     fpos2         begsr
     c                   move      $pofky        dsfkey
     c     fileky        setll     record
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS2U   Position to record using unique key
     C*
     c     fpos2u        begsr
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     c                   exsr      fget
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     c                   exsr      fpos2
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  INZPAR   Initialize parameters for calling add/chg/del program
     C*
     c     inzpar        begsr
     c                   clear                   $parms
     c                   move      #prog         $pprg
     c                   move      $prtky        $puky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  OPTNS    Perform options that user entered
     C*
     c     optns         begsr
     c                   move      *off          otaken            1
     C*
     C*     DO ALL DELETES FIRST (OPTION 4)
     C*
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
     C*
     C*  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     C*     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  OPTNS2   Execute individual options
     C*
     c     optns2        begsr
     c                   exsr      inzpar
     c                   move      wkokyu        $puky
     C*
     C*   Change
     C*
     c     wkoopt        ifeq      ' 2'
     c                   move      '*CHANGE '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
     C*
     C*   View
     C*
     c     wkoopt        ifeq      ' 5'
     c                   move      '*VIEW   '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
610bAC*
     C*   Print Produce Labels
     C*
     c     wkoopt        ifeq      '18'
610bAc                   movel     'PRODUCE '    wkprtf
610bAc     rpkey         chain     reports                            79
610bAc     *in79         ifeq      *on
610bAc                   movel     '*STD'        $pform           10
610bAc                   movel     '*JOB'        $pdev            10
610bAc                   else
610bAc                   move      rpform        $pform
610bAc                   move      rpdev         $pdev
610bAc                   endif
     c                   call      @lblpg
     c                   parm      '*BATCH'      $cmd             10
     c                   parm                    $kwhse
     c                   parm                    $rtncd
     c                   parm                    $pdev
     c                   parm                    $pform
     c                   parm                    $ppo
     c                   else
     C*
     C*   Print
     C*
     c     wkoopt        ifeq      ' 6'
500aAC*   Print Receiving Receipt
500a C*R                   MOVE '*PRINT  '$PCMD
500  c                   movel     'PO330PR '    wkprtf
500  c     rpkey         chain     reports                            79
500a c     *in79         ifeq      *on
500a c                   movel     '*STD'        $pform           10
500a c                   movel     '*JOB'        $pdev            10
500a c                   else
710bAc                   if        rpscrn = '2'
710bAC     uskey         Chain     piruser                            79
710bAC                   if        *in79=*on
710bAC                   eval      uswhse=1
710bAC                   eval      usWHDP=*BLANKS
710bAC                   endif
710bAc                   call      'GETRPT'
710bAc                   parm      '*DEVFORM'    $rcmd             8
710bAC                   PARM      'PO330PR'     $LRPT            10
710bAC                   PARM      USwhse        $WHSE             3 0
710bAC                   PARM      ' '           $STYP             1
710bAC                   PARM      uswhdp        $WHDP             5
710bAC                   PARM                    $DESC            50
710bAC                   PARM                    $DEV             10
710bAC                   PARM                    $FORM            10
710bAc                   move      $form         $pform
710bAc                   move      $dev          $pdev
710bAC                   else
500a c                   move      rpform        $pform
500a c                   move      rpdev         $pdev
710aAC                   endif
500a c                   endif
710aA
710aAC*   Call program to allow override of device/form
710aA
710aAc                   call      'GETDEV'
710aAc                   parm                    $pdev
710aAc                   parm                    $pform
710aAc                   parm                    $wrtn            10
710aAc                   if        $wrtn <> '*OK'
     c                   eval      cancel = *on
710aAc                   leavesr
710aAc                   endif
710aA
500a c                   move      $pwhse        $pwhs             3
     c                   call      @prtpg
500aDC*R                   PARM           $PARMS
500a c                   parm                    $pwhs
500a c                   parm                    $ppo
500a c                   parm                    $prtn
500a c                   parm                    $pdev
500a c                   parm                    $pform
      * Now print Haccp log
650aA * check for new or old haccp
650aA * check to make sure programs exist or don't do call
650aAC                   eval      qcmd = 'CHKOBJ '
650aAC                                  + 'OBJ(HA301) '
650aAC                                  + 'OBJTYPE(*PGM)'
650aAC                   call      'QCMDEXC'                            78
650aAC                   parm                    qcmd            256
650aAC                   parm      80            qlen             15 5
650aAc                   if        *in78 = *off
650gAc                   movel     $ppo          spo
650gA * super
650gAc                   if        spo = 'SP'
650gAc     keypu         setll     pospo                                  79
650gAc                   dow       not %eof(pospo)
650gAc     keypu         reade     pospo                                  79
650gAc                   if        not %eof(pospo)
650gAc                   eval      hapo = pupo
650gAc                   exsr      PrtLog
650gAc                   endif
650gAc                   enddo
650gAc                   else
650gAc                   eval      hapo = $ppo
650gAc                   exsr      PrtLog
650gAc                   endif
650gAc                   endif

650gA * moved to prtlog subr
650gDc*                  call      'HA301'
650gDc*                  parm      ' '           $hacmd            8
650gDc*                  parm      $pwhse        $hawhse           3 0
650gDc*                  parm      $ppo          $lhapo            9
650gDc*                  parm      ' '           $lhaitem         15
650gDc*                  parm                    $hanew            1
650gDc*                  if         $hanew = '1'
650gDc*                  call      'HA300'
650gDc*                  parm      '*PRINT'      $hacmd            8
650gDc*                  parm      $pwhse        $hawhse           3 0
650gDc*                  parm      $pwhse        $hawhse15        15 5
650gDc*                  parm      $ppo          $lhapo            9
650gDc*                  parm      ' '           $lhaitem         15
650gDc*                  else
650gDc*                  endif
650gDc*                  else
650gDc*                  eval      *in78 = *off
650gDc*                  endif
     c                   else
     c                   exsr      zzopt
     c                   end
     c                   end
610bAc                   end
     c                   end
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  PAG01    Screen 1 page routines
     C*
     c     pag01         begsr
     C*
     C*  NEXT PAGE
     C*
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag1fw
     c                   else
     C*
     C*  PREVIOUS PAGE
     C*
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag1bk
     c                   else
     C*
     C*  TOP
     C*
     c     pagcmd        ifeq      '*TOP    '
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          forceb
     c                   exsr      pag1fw
     c                   else
     C*
     C*  BOTTOM
     C*
     c     pagcmd        ifeq      '*BOTTOM '
     c                   move      *on           bot
     c                   z-add     0             dsplyd
     c                   exsr      pag1bk
     c                   else
     C*
     C*  REFRESH SCREEN
     C*
     c     pagcmd        ifeq      '*REFRESH'
     c     fkey(1)       ifeq      *loval
     c                   move      '*TOP    '    $pocmd
     c                   else
     c                   move      '*POSTN2 '    $pocmd
     c                   move      fkey(1)       $pofky
     c                   end
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          bot
     c                   exsr      pag1fw
     c                   else
     C*
     C*  REPOSITIONING
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  PAG02    Screen 2 page routines
     C*
     c     pag02         begsr
     C*
     C*  NEXT PAGE
     C*
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag2fw
     c                   else
     C*
     C*  PREVIOUS PAGE
     C*
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag2bk
     c                   else
     C*
     C*  REFRESH SCREEN
     C*
     c     pagcmd        ifeq      '*REFRESH'
     c     deltop        setll     workopt
     c                   move      *off          bot
     c                   exsr      pag2fw
     c                   end
     c                   end
     c                   end
     c                   move      *blanks       pagcmd
     c     pag02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1FW   Let's see that next page of records
     C*
     c     pag1fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     c     bot           cabeq     *on           endf
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   exsr      sflclr
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     c     stop          doueq     *on
     c                   move      '*GETNEXT'    $pocmd
     c                   exsr      fgtway
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfac
     c                   end
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
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
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
     C*
     c     pag1bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     c     top           cabeq     *on           endb
     c                   move      *off          forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     c     dsplyd        add       10            goback            2 0
     c     bot           ifeq      *on
     c     goback        ifeq      10
     c                   move      *on           forceb
     c                   end
     c                   move      '*BOTTOM '    $pocmd
     c                   exsr      fgtway
     c                   add       1             goback
     c                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     c     stop          doueq     *on
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     C*
     C*  HIT TOP OF FILE
     C*
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk
     c                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     c                   add       1             p
     c     p             ifge      goback
     c                   move      *on           stop
     c                   end
     c     endbk         tag
     c                   end
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     c     top           ifeq      *on
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     c                   end
     c                   exsr      pag1fw
     c     endb          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG2FW   Let's see that next page of delete records
     C*
     c     pag2fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     c     bot           cabeq     *on           endf2
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   exsr      sflclr
     c                   move      *loval        $wkof
     c                   move      *loval        $wkou
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfw2
     c                   end
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
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
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf2         endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG2BK   Let's see the previous page of delete records
     C*
     c     pag2bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     c     top           cabeq     *on           endb2
     c                   move      *off          forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     c     dsplyd        add       10            goback            2 0
     c     bot           ifeq      *on
     c     wkoprt        setgt     workopt
     c                   add       1             goback
     c                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     C*
     C*  READ FILE
     C*
     c     stop          doueq     *on
     c     wkoprt        readpe    workopt                                79
     C*
     C*  HIT TOP OF FILE
     C*
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk2
     c                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c     p             ifge      goback
     c                   move      *on           stop
     c                   end
     c                   end
     c     endbk2        tag
     c                   end
     C*
     C* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     C*
     c     top           ifeq      *on
     c     wkoprt        setll     workopt
     c                   end
     c                   exsr      pag2fw
     c     endb2         endsr
650gAC*----------------------------------------------------------------
650gAC*
650gAC*  PrtLog   Print the haccp log
650gAC*
650gAc     PrtLog        begsr
650gAC*
650gAc                   if        *in78 = *off
650gAc                   call      'HA301'
650gAc                   parm      ' '           $hacmd            8
650gAc                   parm      $pwhse        $hawhse           3 0
650gAc                   parm      hapo          $lhapo            9
650gAc                   parm      ' '           $lhaitem         15
650gAc                   parm                    $hanew            1
650gAc                   if         $hanew = '1'
650gAc                   call      'HA300'
650gAc                   parm      '*PRINT'      $hacmd            8
650gMc                   parm      $pwhse        $hawhse15        15 5
650gAc                   parm      hapo          $lhapo            9
650gAc                   parm      ' '           $lhaitem         15
710bAc                   parm      ' '           $levl             4
710bAc                   parm                    $dev             10
650gAc                   else
650gAc                   endif
650gAc                   else
650gAc                   eval      *in78 = *off
650gAc                   endif
650gAc                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ROLL01   Screen 1 roll up/down routine
     C*
     c     roll01        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     c     status        ifeq      rollup
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     c     status        ifeq      rolldn
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     c     rol01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ROLL02   Screen 2 roll up/down routine
     C*
     c     roll02        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     c     status        ifeq      rollup
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     c     status        ifeq      rolldn
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     c     rol02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  SAVOPT   Verify and save options that were entered
     C*
     c     savopt        begsr
     C*
     C*  READ ONLY THE CHANGED OPTIONS
     C*
     c                   move      *off          nomore            1
     c     nomore        doueq     *on
     c                   move      *off          *in21
     c                   readc     dspsfl                                 79
     c     *in79         ifeq      *on
     c                   move      *on           nomore
     c                   goto      enddo1
     c                   end
     C*
     C*  DISPLAY ERROR IF OPTION IS NOT VALID
     C*
     c     option        ifne      *blanks
     c                   movea     option        a2
     c     a2(2)         ifeq      ' '
     c                   move      a2(1)         a2(2)
     c                   move      ' '           a2(1)
     c                   movea     a2            option
     c                   end
     C*
     C*    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     C*
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
ICB A*
ICB A*    For Inter County Bakers
ICB A*      Cannot use option U for partial update export
ICB AC                   if        client = icb  and
ICB AC                             option = ' U'
ICB AC                   eval      error = *on
ICB AC                   eval      *in21 = *on
ICB AC                   eval      errmsg = *blanks
ICB AC                   exsr      zm0108
ICB AC                   endif
ICB AC*
SVLaA*    For Saval check if user authorized for 4=delete
SVLaAc     client        ifeq      saval
EGFaAc     client        oreq      egf
GFS Ac     client        oreq      getfresh
KHLaAc     client        oreq      kohl
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
720aDC*                  if        (client = farmboy
720aDC*                            or client = Dairyland)
720aMC                   if        optPartExp = *off
FBYaAC                             and option = ' U'
FBYaAC                   eval      error = *on
FBYaAC                   eval      *in21 = *on
FBYaAC                   eval      errmsg = *blanks
FBYaAC                   exsr      zm0108
FBYaAC                   endif
     C*
     C*  SAVE OPTION
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   Add record to subfile
     C*
     c     sfladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     C*
     C*  SAVE FILE AND UNIQUE KEYS
     C*
     c                   move      $pofky        fkey(y)
     c                   move      $pouky        ukey(y)
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     c                   exsr      zzfill
     c                   write     dspsfl
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   Clear display subfile
     C*
     c     sflclr        begsr
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     c                   move      *off          *in01
     c                   write     dspsfc
     c                   z-add     0             recno             4 0
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile
     C*
     c     sfldsp        begsr
     C*
     C*  WRITE OPTION AND COMMAND LINES TO DISPLAY
     C*
     c                   write     optrec
     c                   write     cmdrec
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     c                   write     morrec
     C*
     C*  WRITE POSITION TO FIELD TO DISPLAY
     C*
414dAC*  Write POSTNREC first if error occured.
414dAC*
414dAc     error         ifeq      '1'
     c                   write     postnrec
414dAc                   end
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     c                   exsr      sflopt
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     c     error         ifne      *on
     c     1             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      *on           *in20
     c                   update    dspsfl
     c                   end
     c                   end
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     C*
414dAC*  Write POSTNREC last if no error occured.
414dAC*
414dAc     error         ifne      '1'
414dAc                   write     postnrec
414dAc                   end
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOPT   Initialize options for subfile
     C*
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
     C*----------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   write     msgclr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
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
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     c     zmqmsg        begsr
     c                   add       1             msgk
     c                   write     msgrec
     c                   endsr
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     C*R                   WRITECLRSCR
     c                   move      *on           sclear            1
     c                   endsr
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
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
     C*
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0101  Program not found.
     C*
     c     zm0101        begsr
     c                   move      'PIR0101'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0102  Program not found.
     C*
     c     zm0102        begsr
     c                   move      'PIR0102'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0103  Program not found while exec. subroutine.
     C*
     c     zm0103        begsr
     c                   move      'PIR0103'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0104  Pressed an invalid key.
     C*
     c     zm0104        begsr
     c                   move      'PIR0104'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0105
     C*
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0106  Invalid cursor position.
     C*
     c     zm0106        begsr
     c                   move      'PIR0106'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0107  Invalid value for "position To"
     C*
     c     zm0107        begsr
     c                   move      'PIR0107'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0108  Invalid Option.
     C*
     c     zm0108        begsr
     c                   move      'PIR0108'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     option        errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
414 AC*----------------------------------------------------------------
414 AC*      1100  All Detail lines not touched
414 AC*
414 Ac     zm0110        begsr
414 Ac                   move      'PO11001'     #msgid
414 Ac                   move      '*DIAG  '     #msgtp
414 Ac                   movel     option        errmsg
414 Ac                   movea     errmsg        $md(1)
414 Ac                   exsr      zmpmsg
414 Ac                   endsr
414bAC*----------------------------------------------------------------
414bAC*      1140  Request to delete, but receivings have ocurred.
414bAC*
414bAc     zm0114        begsr
414bAc                   move      'PO11402'     #msgid
414bAc                   move      '*DIAG  '     #msgtp
414bAc                   movel     option        errmsg
414bAc                   movea     errmsg        $md(1)
414bAc                   exsr      zmpmsg
414bAc                   endsr
416 AC*----------------------------------------------------------------
416 AC*      3237  Option 13 not allowed on individual p/o.
416 AC*
416 Ac     zm3237        begsr
416 Ac                   move      'PO13237'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*      3238  Option 8 not allowed on individual p/o.
416 AC*
416 Ac     zm3238        begsr
416 Ac                   move      'PO13238'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*      3239  Option 9 not allowed on individual p/o.
416 AC*
416 Ac     zm3239        begsr
416 Ac                   move      'PO13239'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*      3240  Option 11 not allowed on Super P/O.
416 AC*
416 Ac     zm3240        begsr
416 Ac                   move      'PO13240'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   move      *blanks       errmsg
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
510A C*----------------------------------------------------------------
510A C*      3249  Option 8 not allowed with destination stg loc blank
510A C*            PACKERS
510A c     zm3249        begsr
510A c                   move      'PO13249'     #msgid
510A c                   move      '*DIAG  '     #msgtp
510A c                   move      *blanks       errmsg
510A c                   exsr      zmpmsg
510A c                   endsr
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     c     zm9905        begsr
     c                   move      'PIR9905'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD    Process non-standard function keys
     C*
     c     zzcmd         begsr
     C*
     C*  Test for F4 - Lookup
     C*
     c     *inkd         ifeq      *on
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     C*
     C*     Warehouse department.
     C*
     c     row#          ifeq      4
     c     col#          andge     38
414dDC**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   move      '*LOOKUP '    $lcmd
     c                   z-add     ptinp1        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*SELECT '
     c                   z-add     $lwhse        ptinp1
     c                   end
     c                   else
     C*
     C*     Cursor not on a valid lookup field.
     C*
     c                   move      *on           error
     c                   exsr      zm9905
     c                   end
     c                   goto      endcm1
     c                   end
     C*
     C*  Test for F9 - Display all warehouses
     C*
     c     *inki         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*F9     '    $rtncd
     c                   goto      endcm1
     c                   endif
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
416 AC*
416 AC*  Test for F24 - More keys
416 AC*
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
500dDC***                  MOVE CMDLN,K   CMDLN1
500dAc                   endsl
416 Ac                   endif
416 AC*
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     c     zzfget        begsr
     C*
     C*    Code to use when file key and unique key are the same.
     C*
     c     filuky        chain     record                             79
     C*
     C*    Code to use when file key and unique key are different.
     C*
     C*R         FILUKY    CHAINRECORDU              79
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     c     zzfgtn        begsr
     c     try1          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R                   READ RECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c     partky        reade     record                                 79
     C*
500d C**   See if we only want received lines.
500d c     noxflg        ifeq      *on
500d c     *in79         andeq     *off
500d c     phstat        cabeq     '0'           try1
500d c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   Get previous record
     C*
     c     zzfgtp        begsr
     c     try2          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R                   READPRECORD                   79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c     partky        readpe    record                                 79
     C*
500d C**   See if we only want received lines.
500d c     noxflg        ifeq      *on
500d c     *in79         andeq     *off
500d c     phstat        cabeq     '0'           try2
500d c                   endif
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
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
650hAc     phstat        wheneq    '4'
650hAc                   movel(p)  sts04         w1stat
650iAc     phstat        wheneq    '5'
650iAc                   movel(p)  sts05         w1stat
     c                   other
     c                   move      *blanks       w1stat
     c                   endsl
416aAc     phdate        ifne      0
416dDC**                   MOVE '*CMDMDY '$CVCMD
416dMc                   move      '*YMDMDY '    $cvcmd
416dDC**                   MOVE PHDATE    $CVD8I
416dMc                   move      phdate        $cvd6i
416aMc                   call      @cvtdt
416aMc                   parm                    $cvtdt
416aMc                   move      $cvd6o        w1date
416aDC**                   MOVE PHDATE    W1DATE
416AAc                   else
416AAc                   move      *blanks       w1date
416AAc                   endif
414 Ac                   move      phtime        w1time
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C                   eval      viewo = 1
     C                   eval      maxvwo = 2
     C*  Define unique file key.
     C*
     c     filuky        klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
     C*
     C*  Define full key for main file.
     C*
     c     fileky        klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
414 AC*
414 AC*  Define full key for PODTL3 file.
414 AC*
414 Ac     detlky        klist
414 Ac                   kfld                    pdwhse
414 Ac                   kfld                    pdpo
414 Ac                   kfld                    pdseq
     C*
     C*  Define partial key for main file (if needed).
     C*
     c     partky        klist
     c                   kfld                    phwhse
414cAC*
414cAC*  Define key for OPTIONS file.
414cAC*
414cAc     keyops        klist
414cAc                   kfld                    opwhse
414cAc                   kfld                    opcode
416 AC*
416 AC*  Define key for POSPO file.
416 AC*
416 Ac     keypu         klist
416 Ac                   kfld                    $pwhse
416 Ac                   kfld                    $ppo
416 AC*
416 AC*  Define key for POSPO1 file.
416 AC*
416 Ac     keypu1        klist
416 Ac                   kfld                    phwhse
416 Ac                   kfld                    phpo
     C*
500aAc     rpkey         klist
500aAc                   kfld                    wkprtf           10
     C*
     C*  Setup option and command display lines.
     C*
     c                   move      optln(1)      optln1
401 Ac                   move      optln(2)      optln2
     c                   move      cmdln(1)      cmdln1
416 Ac                   z-add     1             k                 3 0
416 Ac                   move      *on           forevr            1
416 Ac                   move      '*NO '        sprpo             4
     C*
413 DC*R                   MOVE #PROG     $CVPRG
416dAc                   move      #prog         $cvprg
     c                   move      #prog         $pprg
     c                   move      #prog         $lprg
610dA*
610dA*  Define key for OPTIONS file.
610dA*
610dAC     opkey         klist
610dAC                   kfld                    opwhse
610dAC                   kfld                    opcode
610dA*
610dAC                   eval      opcode = '*SYSTEM '
610dAC                   eval      opwhse = *zeros
610dA*
610dAC     opkey         chain     options
610dAC                   if        not %found(options)
610dAC                   eval      opuci  = 'N'
770aAC                   eval      opdckv = 'N'
610dAC                   else
610dAC                   movel     opdata        opdta2
610dAC                   endif
770aA /free
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
770aA /end-free
610dA*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Get warehouse for user.
     C*
210 DC*R         USKEY     CHAINPIRUSER              79
210 DC*R         *IN79     IFEQ *OFF
210 DC*R                   Z-ADDUSWHSE    PHWHSE
210 DC*R                   ELSE
210 DC*R                   Z-ADD1         PHWHSE
210 DC*R                   ENDIF
210 AC*
210 Ac                   call      'GETWHSE'
210 Ac                   parm                    #user
210 Ac     phwhse        parm      0             #whse             3 0
210 AC*
     C*
     C*   Verify warehouse and get description.
     C*
     c                   z-add     phwhse        whcode
     c                   move      *blanks       whdesc
     c                   move      '*VERIFY '    $lcmd
     c                   z-add     phwhse        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           *in21
414dDC**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   movel     $lerm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in21
414dDC**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   move      $lmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     c                   z-add     phwhse        $kwhse
     c                   z-add     phwhse        whcode
     c                   movel     $lerm         whdesc
     c                   end
     c                   end
     C*
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
416 AC*----------------------------------------------------------------
416 AC*
416 AC*  ZZCKRC   Check P/O to ensure that ALL detail lines have been rcvd
416 AC*
416 Ac     zzckrc        begsr
416 AC*
416 Ac     fileky        setll     podtl
416 Ac     fileky        reade     podtl                                  85
416 Ac   85              movel     *off          $ok
416 Ac     *in85         doweq     *off
416 Ac     detlky        chain     podtl3                             84
416 Ac     *in84         ifeq      *on
416 Ac                   movel     *off          $ok
416 Ac                   endif
416 Ac     fileky        reade     podtl                                  85
416 Ac                   enddo
416 AC*
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*
416 AC*  ZZCKSP   Check for Super P/O or individual P/O on Super P/O.
416 AC*
416 Ac     zzcksp        begsr
416 AC*
416 AC*    Test p/o selected for receiving is a Super P/O. This
416 AC*    will be determined by a two part test. First, if the
416 AC*    first two characters of the P/O begin with "SP" and we
416 AC*    find the P/O in the Super P/O cross ref file.
416 Ac                   movel     $ppo          spo
416 Ac     keypu         setll     pospo                                  79
416 Ac     *in79         ifeq      *on
416 Ac     spo           andeq     'SP'
416 Ac                   move      '*YES'        sprpo
416 Ac                   else
416 Ac                   move      '*NO '        sprpo
416 Ac     keypu1        setll     pospo1                                 79
416 AC*    Individiual p/o found on a Super P/O.
416 AC*    Can't be marked for export.
416 Ac     *in79         ifeq      *on
416 Ac                   move      *on           error
416 Ac                   move      *on           cancel
416 Ac                   endif
416 Ac                   endif
416 AC*
416 Ac                   endsr
510A C*----------------------------------------------------------------
510A C*
510A C*  ZZCDES   Check for Destination storage location. PACKERS.
510A C*
510A c     zzcdes        begsr
510A C*
510A c                   z-add     *zero         w1dest
510A c     fileky        chain     pohdrm                             79
510A c     *in79         ifeq      *off
510A c     phdest        andne     *zeros
510A c                   goto      endcde
510A c                   endif
510A c     *in79         ifeq      *off
510A c     phdest        andeq     *zeros
510A c                   exfmt     window1
510A c     w1dest        ifeq      *zeros
510A c                   move      *on           error
510A c                   move      *on           cancel
510A c                   goto      endcde
510A c                   endif
510A c                   endif
510A c     *in79         ifeq      *on
510A c                   z-add     phwhse        phmwh
510A c                   move      phpo          phmpo
510A c                   move      w1dest        phdest
510A c                   write     phmrec
510A c                   goto      endcde
510A c                   endif
510A c     *in79         ifeq      *off
510A c     w1dest        andne     *zeros
510A c                   move      w1dest        phdest
510A c                   update    phmrec
510A c                   endif
510A C*
510A c     endcde        tag
510A c                   unlock    pohdrm
510A c                   endsr
510A C*
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     c     zzkeyf        begsr
     c                   move      dsfkey        $pofky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     c     zzkeyu        begsr
     c                   move      dsukey        $pouky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOPT    Process non-standard options.
     C*              Note: Error handling is done in routine OPTNS2.
     C*
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
7700A                     posupdts = current_timestamp
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
401 AC*
401 AC*   Mark for export.
401 AC*
401 Ac     wkoopt        ifeq      ' 8'
414cAc                   move      $puky         dsukey
416 Ac                   move      $puky         hldkey
416 AC*
416 AC*    Check if individual P/O on a Super P/O or selected is a Super
416 AC*    P/O.
416 Ac                   exsr      zzcksp
416 AC*    Individual p/o attached to a Super P/O, marking not allowed.
416 Ac     error         ifeq      *on
416 Ac                   exsr      zm3238
416 Ac                   goto      #notok
416 Ac                   endif
510A  *
510A  *    Check if destination storage location has been entered      r
510A  *    for PACKERS.
510A c     client        ifeq      packers
510A c                   exsr      zzcdes
510A C*    Individual p/o PACKERS did not enter destination storage loc
510A c     error         ifeq      *on
510A c                   exsr      zm3249
510A c                   goto      #notok
510A c                   endif
510A c                   endif
PCK A *
PCK A *    Check if uci count is >= items received for PACKERS.        r
PCK A *
PCK Ac*****client        ifeq      packers
610dAC                   if        opuci = 'Y'
PCK Ac                   move      $puky         $luky
PCK Ac                   move      '*UNMARK '    $lcmd
PCK Ac                   move      *blanks       $lrtn
PCK Ac                   call      @ucict
PCK Ac                   parm                    $lparm
PCK AC*    if not do not allow po to be marked for export
PCK Ac     $lrtn         ifeq      '*ERROR'
PCK Ac                   movel(p)  err02         errmsg
PCK Ac                   exsr      zm0105
PCK Ac                   goto      #notok
PCK Ac                   endif
PCK Ac                   endif
510A  *
414cAC*
414cAC*   Get receiving options
414cAC*
414cAc                   z-add     phwhse        opwhse
414cAc                   move      '*RCVLBL '    opcode
414cAc     keyops        chain     oprec                              79
414cAC*
414cAC*   If option not found or force option is not 'Y'
414cAC*     then go ahead and mark it for export.
414cAC*
414cAc     *in79         ifeq      *on
414cAc     opfrcm        orne      'Y'
416bMc                   movel     *on           $ok               1
414 AC*
414 AC*   Otherwise, check to ensure all detail lines have been touched
414 AC*
414cAc                   else
416 AC*
416 DC*R         FILEKY    SETLLPODTL
416 DC*R         FILEKY    READEPODTL                    85
416 DC*R                   MOVEL*ON       $OK     1
416 DC*R 85                MOVEL*OFF      $OK
416 DC*R         *IN85     DOWEQ*OFF
416 DC*R         DETLKY    CHAINPODTL3               84
416 DC*R         *IN84     IFEQ *ON
416 DC*R                   MOVEL*OFF      $OK
416 DC*R                   ENDIF
416 DC*R         FILEKY    READEPODTL                    85
416 DC*R                   ENDDO
416 AC*
416 Ac                   move      *on           $ok
416 Ac                   select
416 AC*
416 AC*    Super P/O selected to be marked for export. Chk ALL are marked.
416 Ac     sprpo         wheneq    '*YES'
416 AC*
416 Ac     keypu         setll     pospo
416 Ac     forevr        doweq     forevr
416 Ac     keypu         reade     pospo                                  79
416 Ac                   select
416 Ac     *in79         wheneq    *on
416 AC*    Restore original key values.
416 Ac                   move      hldkey        dsukey
416 Ac                   leave
416 AC*
416 Ac                   other
416 Ac                   move      pupo          phpo
416 Ac                   exsr      zzckrc
750aAc                   exsr      zzckcw
416 AC*
DRYaAC*    P/O mising weights.  Super P/O can't be marked.
DRYaAc     missingwgt    ifeq      'Y'
DRYaAc     client        andeq     dairyland
DRYaAC*    Restore original key values.
DRYaAc                   move      hldkey        dsukey
DRYaAc                   leave
DRYaAc                   endif
416 AC*    Super P/O not fully received. Super P/O can't be marked.
416 Ac     $ok           ifeq      *off
416 AC*    Restore original key values.
416 Ac                   move      hldkey        dsukey
416 Ac                   leave
416 Ac                   endif
416 Ac                   endsl
416 Ac                   enddo
416 AC*
416 AC*    Check single p/o not attached to a Super P/O.
416 Ac     sprpo         wheneq    '*NO '
416 Ac     error         andeq     *off
416 Ac                   exsr      zzckrc
750aAc                   exsr      zzckcw
416 AC*
416 Ac                   endsl
416 AC*
414cAc                   endif
750aAC*
750aA /free
750aA    if missingwgt = 'Y';
750aA      select;
DRYaA        when client = dairyland;
DRYaA          error = *on;
DRYaA          cancel = *on;
DRYaA          errmsg = 'Missing Weight - Cannot export';
DRYaA          exsr zm0105;
DRYaA          leavesr;
750aA        other;
750aA      endsl;

750aA    endif;
750aA /end-free
414 AC*
414 Ac     $ok           ifeq      *on
401 Ac                   exsr      inzpar
401 Ac                   move      '*DELETE '    $pcmd
401 Ac                   move      wkokyu        $puky
401 Ac                   move      $puky         $luky
401 Ac                   move      '*MARK   '    $lcmd
401 Ac                   move      *blanks       $lrtn
401 Ac                   call      'PO111'
401 Ac                   parm                    $lparm
416 AC*
416 AC*    User selected a Super P/O to mark, mark ALL attached p/o's.
416 Ac     sprpo         ifeq      '*YES'
416 Ac                   exsr      zzspsl
416 Ac                   endif
414 AC*
414 Ac                   else
414cAc                   move      *on           error
414cAc                   move      *on           cancel
414 Ac                   exsr      zm0110
414 Ac                   endif
GFCaAC*
FBYbAc                   select
FBYbAC                   when      client = glazier
GFCaDC**                 if        client = glazier
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
FBYbDc*                  endif
GFCaAC*
FBYbAC                   when      client = farmboy
FBYbAC*   Print Receiving Receipt (copied from OPTNS2)
FBYbAc                   movel     'PO330PR '    wkprtf
FBYbAc     rpkey         chain     reports                            79
FBYbAc     *in79         ifeq      *on
FBYbAc                   movel     '*STD'        $pform           10
FBYbAc                   movel     '*JOB'        $pdev            10
FBYbAc                   else
FBYbAc                   move      rpform        $pform
FBYbAc                   move      rpdev         $pdev
FBYbAc                   endif
FBYbAc                   move      $pwhse        $pwhs             3
FBYbAc                   call      @prtpg
FBYbAc                   parm                    $pwhs
FBYbAc                   parm                    $ppo
FBYbAc                   parm                    $prtn
FBYbAc                   parm                    $pdev
FBYbAc                   parm                    $pform
FBYbA * Now print Haccp log
FBYbA * check for new or old haccp
FBYbA * check to make sure programs exist or don't do call
FBYbAC                   eval      qcmd = 'CHKOBJ '
FBYbAC                                  + 'OBJ(HA301) '
FBYbAC                                  + 'OBJTYPE(*PGM)'
FBYbAC                   call      'QCMDEXC'                            78
FBYbAC                   parm                    qcmd            256
FBYbAC                   parm      80            qlen             15 5
FBYbAc                   if        *in78 = *off
FBYbAc                   movel     $ppo          spo
FBYbA * super
FBYbAc                   if        spo = 'SP'
FBYbAc     keypu         setll     pospo                                  79
FBYbAc                   dow       not %eof(pospo)
FBYbAc     keypu         reade     pospo                                  79
FBYbAc                   if        not %eof(pospo)
FBYbAc                   eval      hapo = pupo
FBYbAc                   exsr      PrtLog
FBYbAc                   endif
FBYbAc                   enddo
FBYbAc                   else
FBYbAc                   eval      hapo = $ppo
FBYbAc                   exsr      PrtLog
FBYbAc                   endif
FBYbAc                   endif

FBYbAc                   endsl
416 Ac     #notok        tag
401 Ac                   endif
650cA*
650cA*   Partial Export    ***********************************
650cA*
ADFaAc                   if        client = 'AANDDFOODS' and
ADFaAc                             wkoopt = ' U'
ADFaAc                   move      *on           error
ADFaAc                   move      *on           cancel
ADFaAc                   movel(p)  err03         errmsg
ADFaAc                   exsr      zm0105
ADFaAc                   goto      #notoku
ADFaAc                   endif
650cAc     wkoopt        ifeq      ' U'
650cAc                   move      $puky         dsukey
650cAc                   move      $puky         hldkey
650cA*
650cA*    Check if individual P/O on a Super P/O or selected is a Super
650cA*    P/O.
650cAc                   exsr      zzcksp
650cA*    Individual p/o attached to a Super P/O, marking not allowed.
650cAc     error         ifeq      *on
650cAc                   exsr      zm3238
650cAc                   goto      #notoku
650cAc                   endif
650cA*
650cA*    Check if destination storage location has been entered
650cA*    for PACKERS.
650cAc     client        ifeq      packers
650cAc                   exsr      zzcdes
650cA*    Individual p/o PACKERS did not enter destination storage loc
650cAc     error         ifeq      *on
650cAc                   exsr      zm3249
650cAc                   goto      #notoku
650cAc                   endif
650cAc                   endif
650cA*
650cA*    Check if uci count is >= items received for PACKERS.
650cA*
650cAC                   if        opuci = 'Y'
650cAc                   move      $puky         $luky
650cAc                   move      '*UNMARK '    $lcmd
650cAc                   move      *blanks       $lrtn
650cAc                   call      @ucict
650cAc                   parm                    $lparm
650cA*    if not do not allow po to be marked for export
650cAc     $lrtn         ifeq      '*ERROR'
650cAc                   movel(p)  err02         errmsg
650cAc                   exsr      zm0105
650cAc                   goto      #notoku
650cAc                   endif
650cAc                   endif
650cA*
650cA*   Get receiving options
650cA*
650cAc                   z-add     phwhse        opwhse
650cAc                   move      '*RCVLBL '    opcode
650cAc     keyops        chain     oprec                              79
650cA*
650cA*   If option not found or force option is not 'Y'
650cA*     then go ahead and mark it for export.
650cA*
650cAc**   *in79         ifeq      *on
650cAc**   opfrcm        orne      'Y'
650cAc                   movel     *on           $ok               1
650cA*
650cA*   Otherwise, check to ensure all detail lines have been touched
650cA*
650cAc**                 else
650cA*
650cAc**                 move      *on           $ok
DRYaAc***  need to check for cw on partial
DRYaAc                   select
DRYaA*
DRYaA*    Super P/O selected to be marked for export. Chk ALL are marked.
DRYaAc     sprpo         wheneq    '*YES'
DRYaA*
DRYaAc     keypu         setll     pospo
DRYaAc     forevr        doweq     forevr
DRYaAc     keypu         reade     pospo                                  79
DRYaAc                   select
DRYaAc     *in79         wheneq    *on
DRYaA*    Restore original key values.
DRYaAc                   move      hldkey        dsukey
DRYaAc                   leave
DRYaA*
DRYaAc                   other
DRYaAc                   move      pupo          phpo
DRYaAc                   exsr      zzckcw
750aA /free
750aA    if missingwgt = 'Y';
750aA      select;
DRYaA        when client = dairyland;
DRYaA          error = *on;
DRYaA          cancel = *on;
DRYaA          errmsg = 'Missing Weight - Cannot export';
DRYaA          exsr zm0105;
DRYaA          leavesr;
750aA        other;
750aA      endsl;

750aA    endif;
750aA /end-free
DRYaA*
DRYaAC*    P/O mising weights.  Super P/O can't be marked.
DRYaAc     missingwgt    ifeq      'Y'
DRYaAc     client        andeq     dairyland
DRYaAC*    Restore original key values.
DRYaAc                   move      hldkey        dsukey
DRYaAc                   leave
DRYaAc                   endif
DRYaA*    Super P/O not fully received. Super P/O can't be marked.
DRYaAc     $ok           ifeq      *off
DRYaA*    Restore original key values.
DRYaAc                   move      hldkey        dsukey
DRYaAc                   leave
DRYaAc                   endif
DRYaAc                   endsl
DRYaAc                   enddo
DRYaA*
DRYaA*    Check single p/o not attached to a Super P/O.
DRYaAc     sprpo         wheneq    '*NO '
DRYaAc     error         andeq     *off
DRYaAc                   exsr      zzckcw
DRYaA*
DRYaAc                   endsl
DRYaA*
650cA*
650cA*    Super P/O selected to be marked for export. Chk ALL are marked.
650cAc**   sprpo         wheneq    '*YES'
650cA*
650cAc**   keypu         setll     pospo
650cAc**   forevr        doweq     forevr
650cAc**   keypu         reade     pospo                                  79
650cAc**                 select
650cAc**   *in79         wheneq    *on
650cA*    Restore original key values.
650cAc**                 move      hldkey        dsukey
650cAc**                 leave
650cA*
650cAc**                 other
650cAc**                 move      pupo          phpo
650cAc**                 exsr      zzckrc
650cA*
650cA*    Super P/O not fully received. Super P/O can't be marked.
650cAc**   $ok           ifeq      *off
650cA*    Restore original key values.
650cAc**                 move      hldkey        dsukey
650cAc**                 leave
650cAc**                 endif
650cAc**                 endsl
650cAc**                 enddo
650cA*
650cA*    Check single p/o not attached to a Super P/O.
650cAc**   sprpo         wheneq    '*NO '
650cAc**   error         andeq     *off
650cAc**                 exsr      zzckrc
650cA*
650cAc**                 endsl
650cA*
650cAc**                 endif
650cA*
750aA /free
750aA    if missingwgt = 'Y';
750aA      select;
DRYaA        when client = dairyland;
DRYaA          error = *on;
DRYaA          cancel = *on;
DRYaA          errmsg = 'Missing Weight - Cannot export';
DRYaA          exsr zm0105;
DRYaA          leavesr;
750aA        other;
750aA      endsl;

750aA    endif;
750aA /end-free
650cAc     $ok           ifeq      *on
650cAc                   exsr      inzpar
650cAc                   move      '*DELETE '    $pcmd
650cAc                   move      wkokyu        $puky
650cAc                   move      $puky         $luky
650cAc                   move      '*MKPART '    $lcmd
650cAc                   move      *blanks       $lrtn
650cAc                   call      'PO111'
650cAc                   parm                    $lparm
650cA*
650cA*    User selected a Super P/O to mark, mark ALL attached p/o's.
650cAc     sprpo         ifeq      '*YES'
650cAc                   exsr      zzspsl
650cAc                   endif
650cA*
650cAc                   else
650cAc                   move      *on           error
650cAc                   move      *on           cancel
650cAc                   exsr      zm0110
650cAc                   endif
650cA*
650cAC                   if        client = glazier
650cAc                   movel     'PO330PR '    wkprtf
650cAc     rpkey         chain     reports                            79
650cAc     *in79         ifeq      *on
650cAC                   movel     '*STD'        $pform           10
650cAc                   movel     '*JOB'        $pdev            10
650cAc                   else
650cAc                   move      rpform        $pform
650cAc                   move      rpdev         $pdev
650cAc                   endif
650cAc                   move      $pwhse        $pwhs             3
650cAc                   call      @prtpg
650cAc                   parm                    $pwhs
650cAc                   parm                    $ppo
650cAc                   parm                    $prtn
650cAc                   parm                    $pdev
650cAc                   parm                    $pform
650cAc                   endif
650cA*
650cAc     #notoku       tag
650cAc                   endif
650cA*
650cA*  ******************************************************
401 AC*
401 AC*   Unmark.
401 AC*
401 Ac     wkoopt        ifeq      ' 9'
401 Ac                   exsr      inzpar
401 Ac                   move      '*DELETE '    $pcmd
401 Ac                   move      wkokyu        $puky
416 AC*
416 AC*    Check if this is a Super P/O or ind. attached to a Super P/O.
416 Ac                   exsr      zzcksp
416 AC*
416 Ac                   select
416 AC*    Super P/O selected for UnMark.
416 Ac     sprpo         wheneq    '*YES'
416 AC*    Individual p/o selected for UnMark.
416 Ac     sprpo         oreq      '*NO '
416 Ac     error         andeq     *off
416 AC*
401 Ac                   move      $puky         $luky
401 Ac                   move      '*UNMARK '    $lcmd
401 Ac                   move      *blanks       $lrtn
401 Ac                   call      'PO111'
401 Ac                   parm                    $lparm
416 AC*
416 AC*    User selected a Super P/O to unmark, Unmark ALL attached p/o's.
416 Ac     sprpo         ifeq      '*YES'
416 Ac                   exsr      zzspsl
416 Ac                   endif
416 AC*
416 AC*    Individual P/O attached to a Super P/O, Unmark not allowed.
416 Ac     error         wheneq    *on
416 AC*
416 AC*    UnMark not allowed for ind.p/o attached to a Super P/O.
416 Ac                   exsr      zm3239
416 AC*
416 Ac                   endsl
401 Ac                   endif
     C*
     C*   Work with detail
     C*
     c     wkoopt        ifeq      '12'
500bAc     wkoopt        oreq      '52'
500bAc                   move      *blanks       $pcmd
CLD AC*
CLD AC*     Check if user is authorized to use this option.
CLD Ac     client        ifeq      cityline
RNZaAc     client        oreq      renzi
SVLaDc***                oreq      saval
CLD Ac     wkoopt        ifeq      '52'
CLD Ac                   call      'CHKLIST'
CLD Ac                   parm      #prog         $cpgm            10
CLD Ac                   parm      wkoopt        $copt            20
CLD Ac                   parm      #user         $cuser           10
CLD Ac                   parm      *blanks       $crtn            10
CLD AC*       User not authorized to use this option.
CLD Ac     $crtn         ifeq      '*NO '
CLD Ac                   move      *on           error
CLD Ac                   move      *on           cancel
CLD Ac                   movel(p)  err01         errmsg
CLD Ac                   exsr      zm0105
CLD Ac                   goto      endopt
CLD Ac                   endif
CLD Ac                   endif
CLD Ac                   endif
416 AC*
416 AC*    Determine if p/o selected is a Super P/O.
416 Ac                   movel     $ppo          spo               2
416 Ac     keypu         setll     pospo                                  79
416 AC*    Super P/O with attached p/o's.
416 Ac     *in79         ifeq      *on
416 Ac     spo           andeq     'SP'
416 AC*    Super P/O without attached p/o's.
416 Ac     *in79         oreq      *off
416 Ac     spo           andeq     'SP'
416 Ac                   move      '*YES'        $pspsw
416 Ac                   move      $ppo          $pspo
416 Ac                   move      *blanks       $ppo
416 Ac                   else
416 Ac                   move      '*NO '        $pspsw
416 Ac                   move      *blanks       $pspo
416 Ac                   endif
416 AC*
500bAc     wkoopt        ifeq      '52'
500bAc                   move      '*SPRECV '    $pcmd
500bAc                   endif
500bAC*
     c                   call      'PO120CL'
500bAc                   parm                    $pcmd
     c                   parm                    $puky
     c                   parm                    $prtn
416 AC*
416 AC*    On return, load Super P/O number into regular p/o
416 AC*    for positioning purposes.
416 Ac     $pspsw        ifeq      '*YES'
416 Ac                   move      $pspo         $ppo
416 Ac                   endif
     c                   endif
218 AC*
218 AC*   UPC Receiving
218 AC*
221 DC*R         WKOOPT    IFEQ '10'
221 DC*R                   MOVE $PUKY     $LUKY
221 DC*R                   CALL 'PO210'
221 DC*R                   PARM           $LPARM
221 DC*R                   ENDIF
413bAC*
413bAC*   Enter HACCP information.
413bAC*
413bAc     wkoopt        ifeq      '11'
500eAC*
500eAc                   move      '*DTLCHK '    $lcmd
500eAc                   movel     $ppo          $lpo
500eAc                   move      *zeros        $lseq
640aDc*                  call      'PO170'
640aA*
640aA*   Do Haccp Header Processing.
640aA*
640aAC*    Determine if p/o selected is a Super P/O.
640aAc                   movel     $ppo          spo               2
640aAc     keypu         setll     pospo                                  79
640aAC*    Super P/O with attached p/o's.
640aAc     *in79         ifeq      *on
640aAc     spo           andeq     'SP'
640aAC*    Super P/O without attached p/o's.
640aAc     *in79         oreq      *off
640aAc     spo           andeq     'SP'
640aAc                   move      '*YES'        $pspsw
640aAc                   move      $ppo          $pspo
640aAc                   move      *blanks       $ppo
640aAc                   else
640aAc                   move      '*NO '        $pspsw
640aAc                   move      *blanks       $pspo
640aAc                   endif
650fAc                   if        $pspsw = '*YES'
650fAc                   dow       *inku = *off and *inkl = *off
650fAc                   exfmt     window2
650fAc                   enddo
650fAc                   endif
650fAc     *inkl         ifeq      *on
650fAc                   else
640aA * Begin HACCP Header
      /free
        $lwhse = $kwhse;
        $lcmd = '*POHDRCH';
        $llevel = 'RCVH';
        $llicense = ' ';
        if $pspsw = '*YES';
          $lhpo = $pspo;
        else;
          $lhpo = $ppo;
        endif;
        $lhseq = 0;
        $ltype = ' ';
        $lhspo = $pspsw;
      /end-free
640aAc                   call      'HA410'
640aAc                   parm                    $lparm
650bAc                   parm                    $lparm1
640aA * End HACCP Header
650fAc                   endif

650fDc*                  parm                    $lparm
500eAc     $lrtn         ifeq      '*PGMQ   '
500eAc                   move      *on           error
500eAc                   move      $lmsg         #msgk
500eAc                   exsr      zmqmsg
500eAc                   endif
416 AC*
416 AC*    Check if this is a Super P/O.
500eAC*
500eAc     $lrtn         ifne      '*PGMQ   '
500eAC*
510cdC*                    MOVEL$PPO      SPO     2
510cdC*          KEYPU     SETLLPOSPO                    79
510cdC*                    SELEC
510cdC*          *IN79     WHEQ *OFF
510cdC*          SPO       ANDNE'SP'
416 AC*
413bAc                   move      $puky         $luky
413bAc                   move      '*PO     '    $lcmd
413bAc                   move      *zeros        $lseq
413bAc                   move      *blanks       $litem
640aDc*                  call      'PO170'
640aDc*                  parm                    $lparm
640aAc                   call      'HA410'
640aAc                   parm                    $lparm
650bAc                   parm                    $lparm1
416 AC*
510cdC*                    OTHER
416 AC*
416 AC*    Enter HACCP info not allowed for Super P/O.
510cdC*                    MOVE *ON       ERROR
510cdC*                    EXSR ZM3240
416 AC*
510cdC*                    ENDSL
413bAc                   endif
500eAc                   endif
416 AC*
416 AC*   Work with Super P/O.
416 AC*
416 Ac     wkoopt        ifeq      '13'
416 AC*
416 AC*    Check if this is a Super P/O.
416 Ac                   movel     $ppo          spo               2
416 Ac     keypu         setll     pospo                                  79
416 Ac                   select
416 AC*    Super P/O with attached p/o's.
416 Ac     *in79         wheneq    *on
416 Ac     spo           andeq     'SP'
416 AC*    Super P/O without attached p/o's.
416 Ac     *in79         oreq      *off
416 Ac     spo           andeq     'SP'
416 AC*
416 Ac                   move      $puky         $luky
416 Ac                   move      $lpo          $lspo
416 Ac                   move      *blanks       $lpo
416 Ac                   move      '*CHANGE '    $lcmd
416 Ac                   call      'PO110C'
416 Ac                   parm                    $lparm
700 Ac                   eval      $lprg = #prog
416 AC*
416 Ac                   other
416 AC*
416 AC*    Work w/ Super P/O not allowed for individual p/o's.
416 Ac                   move      *on           error
416 Ac                   exsr      zm3237
416 AC*
416 Ac                   endsl
416 Ac                   endif
416cAC*
416cAC*   Enter Lumper information.
416cAC*
416cAc     wkoopt        ifeq      '15'
416cAC*
416cAC*    Check if this is a Super P/O.
416cAc                   movel     $ppo          spo               2
416cAc     keypu         setll     pospo                                  79
416cAc                   select
416cAc     *in79         wheneq    *off
416cAc     spo           andne     'SP'
416cAC*
416cAc                   move      $puky         $luky
416cAc                   move      '*PO     '    $lcmd
416cAc                   z-add     0             $lhedt
416aAc                   z-add     0             $lheti
416cAc                   call      'PO180'
416cAc                   parm                    $lparm
416cAC*
416cAc                   other
416cAC*
416cAC*    Enter Lumper info not allowed for Super P/O.
416cAc                   move      *on           error
416cAc                   exsr      zm3240
416cAC*
416cAc                   endsl
416cAc                   endif
416 AC*
500f C*****
     C*   Display pallet estimate
     C*
500f c     wkoopt        ifeq      '16'
500fAc                   move      *blanks       $pcmd
500fAC*
500fAC*    Determine if p/o selected is a Super P/O.
500fAc                   movel     $ppo          spo               2
500fAc     keypu         setll     pospo                                  79
500fAC*    Super P/O with attached p/o's.
500fAc     *in79         ifeq      *on
500fAc     spo           andeq     'SP'
500fAC*    Super P/O without attached p/o's.
500fAc     *in79         oreq      *off
500fAc     spo           andeq     'SP'
500fAc                   move      '*YES'        $pspsw
500fAc                   move      $ppo          $pspo
500fAc                   move      *blanks       $ppo
500fAc                   else
500fAc                   move      '*NO '        $pspsw
500fAc                   move      *blanks       $pspo
500fAc                   endif
500fAC*
500fAC*
500f c                   call      'PO126CL'
500fAc                   parm                    $pcmd
500f c                   parm                    $puky
500f c                   parm                    $prtn
500fAC*
500fAC*    On return, load Super P/O number into regular p/o
500fAC*    for positioning purposes.
500fAc     $pspsw        ifeq      '*YES'
500fAc                   move      $pspo         $ppo
500fAc                   endif
500f c                   endif
      *
510bAc     wkoopt        ifeq      '17'
510bAc                   move      *blanks       $pcmd
      *    Determine if p/o selected is a Super P/O.
510bAc                   movel     $ppo          spo               2
510bAc     keypu         setll     pospo                                  79
      *    Super P/O with attached p/o's.
510bAc     *in79         ifeq      *on
510bAc     spo           andeq     'SP'
      *    Super P/O without attached p/o's.
510bAc     *in79         oreq      *off
510bAc     spo           andeq     'SP'
510bAc                   move      '*YES'        $pspsw
510bAc                   move      $ppo          $pspo
510bAc                   move      *blanks       $ppo
510bAc                   else
510bAc                   move      '*NO '        $pspsw
510bAc                   move      *blanks       $pspo
510bAc                   endif
      *
510bAc                   call      'PO190'
510bAc                   parm                    $pcmd
510bAc                   parm                    $puky
510bAc                   parm                    $prtn
      *
510bAC*    On return, load Super P/O number into regular p/o
510bAC*    for positioning purposes.
510bAc     $pspsw        ifeq      '*YES'
510bAc                   move      $pspo         $ppo
510bAc                   endif
510bAc                   endif
      *
CLD Ac     endopt        tag
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     c     zzpos         begsr
     C*
     C*      Verify warehouse entry.
     C*
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
414dDC**                   MOVE *ON       *IN01
414dMc                   move      '1'           *in03
     c                   movel     $lerm         errmsg
     c                   exsr      zm0105
     c                   goto      endzps
     c                   else
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in21
414dDC**                   MOVE *ON       *IN01
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
     C*
     C*  See if user is trying to position to PO number
     C*
     c     ptinp2        ifne      *blanks
     c                   movel     ptinp2        phpo
     c                   move      *blanks       ptinp2
     c                   move      *on           repos
     c                   end
     c     endzps        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     c     zzpos2        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C*R         $POCMD    IFEQ '*TOP'
     C*R         *LOVAL    SETLLRECORD
     C*R                   ELSE
     C*R         $POCMD    IFEQ '*BOTTOM'
     C*R         *HIVAL    SETLLRECORD
     C*R                   END
     C*R                   END
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     c     $pocmd        ifeq      '*TOP'
     c     partky        setll     record
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     partky        setgt     record
     c                   end
     c                   end
     c                   endsr
416 AC*----------------------------------------------------------------
416 AC*
416 AC*  ZZSPSL   Process Super P/O to Mark/UnMark attached p/o's.
416 AC*
416 Ac     zzspsl        begsr
416 AC*
416 Ac     keypu         setll     pospo
416 Ac     forevr        doweq     forevr
416 Ac     keypu         reade     pospo                                  79
416 Ac                   select
416 Ac     *in79         wheneq    *on
416 Ac                   leave
416 AC*
416 Ac                   other
416 AC*
416 AC*    Call program to mark/unmark individual p/o.
416 Ac                   move      pupo          $lpo
416 Ac                   move      *blanks       $lrtn
416 Ac                   call      'PO111'
416 Ac                   parm                    $lparm
416 AC*
416 Ac                   endsl
416 Ac                   enddo
416 AC*
416 Ac                   endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**  ZOPT - Valid options
 2 4 5 6 8 91112131516521718RC UDV
**  OPTLN - Option display line
 2=Change  4=Delete  5=View  6=Receipt  8=Mark/export  9=Unmark 11=HACCP
12=Work w/dtl 13=Work w/SuperPO 15=Lumper 16=Plt Est 17=Qty Diff U=Mark/update
18=Produce Labels 52=Pickslt RC=Recall Listing DV=Resend PO
**  CMDLN - Command display line
F3=Exit F4=Prompt F5=Refresh F7=Create Super PO   F23=more opts  F24=More keys
F6=Create Regular PO  F9=Date Order  F11=Rcvd PO  F12=Cancel     F24=More keys
F3=Exit F4=Prompt F5=Refresh F7=Create Super PO   F23=more opts  F24=More keys
F6=Create Regular PO  F9=Date Order  F11=All  F12=Cancel         F24=More keys
**  DESC - Error descriptions
Err: Only 52=Pickslt allowed for Vendor 3194
