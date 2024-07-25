     H option(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU120   Work with Flag Entries - Display
     *  07 May 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *      This program allows the user to select multiple label
     *      numbers that have been flagged for outs or shorts. A
     *      report will be printed listing items to be picked.
     *
     *      This program creates a RUNNER task linking the entries in
     *      the RUNNER file. The RUNNER task is created and then
     *      immediately closed. This is done because the RUNNER task
     *      cannot run concurrently with other direct tasks. This
     *      will allow tracking of the RUNNER task to a specific
     *      user.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    05/07/04  MLB  4.17
     *      - Created.
417aA*    08/12/04  MLB  4.17a
     *      - Enh: Revised program to send message to user when new
     *        RUNNER task has been assigned. Added file OPTIONS to
     *        program.
417bA*    08/12/04  MLB  4.17b
     *      - Enh: Revised program to retrieve printer defaults
     *        when displaying pop-up window.
417cA*    08/19/04  MLB  4.17c
     *      - Enh: Revised program to add support for client custom
     *        modifications.
     *
500 A*    03/18/05  RLP  5.00
     *      - Enh: Revised program to display new status codes
     *        'R'=Replenished or 'U'=Out.
     *      - Enh: Revised program to not allow entries to be selected
     *        for printing if status <> 'R' or 'U'
500aA*    03/29/05  MLB  5.00a
     *      - Enh: Revised program to add new function key: F16=Select all
     *        Added new select field to POSTNREC: FLGTYP. This field will
     *        control values displayed on the screen. *RPL will show all
     *        flag entries at Open, Replenished and Printed status. *OUT
     *        show only entries at Out status.
500bA*    07/10/05  MLB  5.00b
     *      - Enh: Revised program to allow flag entries to be deleted
     *        when label record is closed.
500cA*    07/10/05  MLB  5.00c
     *      - Enh: Revised program to add support for new fields added
     *        to RUNNER file. New field RUTYPE determines statuses avail-
     *        to each flag type. See table below.
     *        Changes made in 5.00, 5.00a revised per these comments:
     *         - One new status added: R=Replenished.
     *         - When Flag Type=*RPL, Flag Report can be printed when
     *           status is R=Replenished.
     *         - When Flag Type=*OUT, *MRG, Flag Report can be printed
     *           only when status is O=Open.
     *         - *OUT,*MRG will show flag entries at Open or Printed
     *           status. When flag is cleared, the entries will be
     *           removed from the list.
500dA*    07/10/05  MLB  5.00d
     *      - Revised program to add support for *MRG flag type.
500eA*    07/27/05  MLB  5.00e
     *      - Enh: Revised program to add support for redefine FLGTYP
     *        field. Removed '*' from valid values for FLGTYP.
500fA*    10/26/05  MLB  5.00f
     *      - Enh: Revised program to add Replenished date/time to
     *        view 3. Removed Closed date/time from view 3.
     *      - Enh: Revised program to position cursor on department
     *        if no errors.
500gA*    12/02/05  MLB  5.00g
     *      - Fix: Populate FRSTKY when F12=Cancel is selected from
     *        Screen 2,3 to prevent data decimal error.
500hA*    12/12/05  JCJ  5.00h
     *      - Enh: Commented zzgetop and replaced it with zzgetruop
500iA*    12/23/05  JCJ/MLB  5.00i
     *      - Enh: add two new *runner options (OPRPCK,OPRLBL)
     *      - Enh: replace file PIRUSER1 with call to GETEMPL
500jA*    12/02/05  MLB  500j
     *      - Revised routine CMD01, ENT02 to add call to RU350CL to print
     *        Runner Flags on Belt Printer labels. Previously CBIa changed.
500k *    01/14/06  MLB  500k
     *      - Fix: Revise ZZWDWCK2 to not lock RUNNER1 on chain.
500mA*    01/25/06  MLB  5.00m
     *      - Enh: Revised program to pass warehouse department to
     *        GETRPT to retrieve printer defaults assigned by
     *        department, not just by report. This change affects
     *        both RU355PR and RU365PR. Section type is defaulted
     *        to F=Fixed for both reports.
500nA*    03/01/06  MLB  5.00n
     *      - Fix: Revised ZZWDWCK2 to loop looking for records
     *        where RUSTAT='P'. If found, allow reprint pick list.
510 A*    08/23/07  MLB  5.10
     *      - Fix: Corrected data decimal error that occured after
     *        user entered invalid warehouse number and then changed
     *        warehouse number back to the correct value. RULBL# was
     *        not being set to zeros.
510aA*    11/07/07  RBD  5.10a
     *      - Omit status 'D' added to RUNNER2. Re-compile only.
520 A*    06/02/08  RBD  5.20   P#00060
     *      - Logic added to identify 'MRG' short and mispick flags
     *        created by loader merged items scanning process,
     *        pgms RF-Loadr9-->Loadr19. (Taken from rev's marked CBI9
     *        in Cheney's version of RU120.)
520aA*    09/12/08  RBD  5.20a
     *      - Fix:  If GETEMPL returns $bpu (belt printer user) as a
     *        a blank, it indicates that the system is not yet using
     *        PIRUSERA, the file which contains the belt printer user
     *        field.  So if $bpu is returned as a blank, bypass the
     *        belt printer user logic.
     *
530 A*    09/10/10  MLB  5.30
     *      - Fix: Revised program to set warehouse department to
     *        *ALL when user is not enrolled in Dakota User file upon
     *        entry into program first time.
     *
530a *    12/01/10  GJA  5.30a
     *      - Fix: If the same employee is assigned the runner it
     *        would close the current selection transaction.
     *
650 A*    02/12/13  MLB  6.50
     *      - Fix: Revised program to select both O=Open and R=Repl'd
     *        status when F16=Select all is selected.
650a *    01/19/15  GJA  6.50a
     *      - Enh: Add fourth screen.   Rename RU120FM to RU12001
     *
710 A*    01/126/17  MLB  7.10
     *      - Enh: Revised routine, ZZWDWCK2 to not lock RUNNER1 file
     *        when looking for runner flags at Printed status.
     *
710aA*    06/05/17  TAB  7.10a
     *      - Enh: Added new runner type for Box Breaker / create
     *        runner record with type 'B' when breakdown qty is being
     *        shorted.
     *
710bA*    07/11/17  TAB  7.10b
     *      - Enh: Added new ALL selection for runner type. This
     *             allows user to view all runner transaction flags.
710cA*    07/20/17  TAB  7.10c
     *      - Fix: Removed code in ZZFGTP after speaking with Max, it
     *             was checking for RUSTAT = 'U', Max was not sure why
     *             that code was there as the RUSTAT field is not set to
     *             'U' in any programs currently in production. On his
     *             advise I remarked the code out. Also I corrected F20
     *             positioning when selection flag type is 'ALL'.
     *             F16 key is not working for select flag 'ALL' to not
     *             allow user to process all screen entries just like
     *             *ALL for department.
     *      -Add:  07/21/17 Added file RUNNER6 for positioning when
     *             user enters a specific label number while under the
     *             ALL selection type. Also corrected post issue, when
     *             user has specified a label number to position to and
     *             then changes the selection type previously it would
     *             not return to the screen correctly. This is now fixed
     *
710dA*    12/22/17  MR   7.10d
     *      - Add email and pics parms to GETEMPL.
     *
720aA*    01/16/18  RBD  7.20a
     *      - Added a prefix to RUNNER6 so I can move its fields into
     *        standard runner fields for rev 710c, then use RUNNER6 to
     *        retrieve the child runner without overlaying the parent
     *        runner fields.
     *      - Added editing when runner flag type is M(merge):
     *          1. If a runner flag exists for the child with a flag type
     *             of blank, N or U and a status of O(open), P(printed) or
     *             R(replenishment) throw an error.
     *          2. If no runner flag exists for the child and the trans
     *             is at Open or Started status throw an error.
     *      - Changed scrn format name to RU12003.
     *      - Color legend when runner flag type is M:
     *          If a runner flag exists for the child:
     *            Green : child status is not O,P or R
     *            Yellow: child status is P
     *            Red   : child status is O or R
     *            Pink  : child runner type is U and its flag trans is gt 0
     *          If no runner flag exists for the child:
     *            Green : trans status is Ended, Closed or Deleted
     *            Yellow: trans status is Open or Started
     *
720bA*    05/02/18  RBD  7.20b
     *      - Do not display runner records with status 'S', this is a
     *        new status code.  When a flag type N or M is cleared with
     *        quantity found the status will be changed to S rather
     *        than C. Status S gets changed to C when either the route is
     *        closed to the Loader Mod or the flag is cleared again
     *        in RU310.
     *
720cA*    07/03/18  RBD  7.20c
     *      - Abbreviate Status to make room for adding Route to first screen.
720dA*    01/04/19  LMC  7.20d
     *      - Reserved - for special call to adjtran2 to start runner  screen.
730aA*    05/07/19  DAS  7.30a
     *      - Changed format to RU12004
     *      - Added 5th view, initially for Greco.
     *
730bA*    09/19/19  MLB  7.30b
     *      - Enh: Revised CBIc mod to remove client mod to log runner
     *        flag deletions for all clients, not just CBI. Also, this
     *        will allow opt# 5 on the Loader Reports menu to display
     *        deleted runner flags.
     *
740aA*    06/05/19  MLB  7.40a
     *      - Enh: Revised pgm to retrieve Runner Flag emp# for dft
     *        user, RUNNER. User entry for user RUNNER will be created in
     *        BFC User table. If not found, set field to zero and prompt
     *        for emp#. Was requested by Leo for Greco.
     *      ** NOTE: this was originally a 730b mod at Greco that was
     *      ** not brought back to dev3 until 12/1/20. The 730b mod mark
     *      ** had already been used for something else, thus I've renamed
     *      ** it to 740a ... RBD.
     *
740bA*    12/01/20  RBD  7.40b
     *      - Fix: Changed #user parm name when getuser called with
     *        user RUNNER.  If RUNNER user is not found in piruser it
     *        was causing the user to have to perform opt 1 twice
     *        because the first time through it wasn't finding a hit
     *        to RUNNER in WORKOPT. If RUNNER is found then move 'RUNNER'
     *        to #user.
     *
750aA*    08/19/21  RBD  7.50a
     *      - Add logic for new runner status 'L'.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BADa *    12/16/16  GJA  BADa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    12/16/16  GJA  ADFA
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
ADW A*    06/26/06  MLB  ADW
     *      - Revised program to display view 2 on initial entry into
     *        program which has customer route number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions for Cheney Brothers.
     *
CBI A*    05/07/04  MLB  CBI
     *      - Revised routine ZZWDWPROMPT, ZZWDWRPRNT to set printer defaults
     *        based on department selected.
     *
CBIaA*    12/02/05  MLB  CBIa
     *        Note: This change was added a custom client change at this time
     *              but will be converted to permanent change at a later date.
     *        Note: Reference mod 500j
     *
CBIbA*    08/18/16  RBD  CBIb
     *      - Per Keith, bypass edit which prevents flag label being
     *        printed if label is already closed.
     *
CBIcA*    08/15/17  JGD  CBIc
     *      - Add logic to verify if user is authorized to dlt flags.
     *      A new file was added, FlgDelF, to hold info pertaining to
     *      the flag deletion process such as why and who deleted the
     *      flag among other type of info.
CBIdA*    09/19/19  MLB  CBId
     *      - Revised CBIc mod to remove CBI-only limitation to write
     *        deleted runner flags into FLGDELF.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
     *
CSPa *    04/15/11  GJA  CSPa
     *      - ENH:  Setup time range to default printer to SHORTS.
     *
CSPbA*    01/25/17  RBD  CSPb
     *      - Revised program to only allow authorized users to delete
     *        runner flag entries.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grocery Supply
     *
GSC A*    01/14/06  MLB  GSC
c    *      - Revised program to add 4th view to dspf. This new view
     *        will be the default view for GSC and include client
     *        specific information.
     *      - Added files ORDH, ORDLBL3 to program.
     *      - Added 2 lines to CMDLN array for 4th view.
     *      - Created new array CMDLNA to hold replacement lines
     *        4th view.
GSC1A*    02/10/05  MLB  GSC1
     *      - Fix: Revised routine SAVOPT to add code to check for View 4
     *        to properly position pointer to array element selected
     *        for further processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    09/10/10  MLB  DRY
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SouthWest Trader
     *
SWTa *    03/28/19  GJA  SWTa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi
     *
ACCa *    04/15/19  GJA  ACCa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vitco Foods
     *
VFIa *    01/28/20  GJA  VFIa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
     *
FSHa *    09/13/16  GJA  FSHa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQSa *    02/13/19  GJA  MQSa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
MQSb *    02/14/19  GJA  MQSa
     *      - ENH:  Setup time range to default printer to SHORTS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPRa *    04/12/16  GJA  FPRa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: GreenLeaf
     *
GLPa *    07/14/16  GJA  GLPa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    10/15/15  GJA  JSLa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program. Add JSLa to DRY mod
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLD A*    06/07/11  MLB  CLD
     *      - Revised program to only allow authorized users to delete
     *        runner flag entries. Per Steve D. conference call.
CLDaA*    08/10/11  MLB  CLDa
     *      - Revised pgm to fully left justify 4 before calling pgm.
     *        change to mod CLD.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/25/07  MLB  VIP
     *      - Enh: Added support for item# 9999999999 to retrieve
     *        item description from order detail misc. file.
     *      - Added ORDDM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: ISupply
     *
ISPa *    06/14/16  GJA  ISPa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    07/16/13  MLB  GFS
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *      - Added GFS to DRY mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SOFO Foods
     *
SOFa *    09/28/16  GJA  SOFa
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco
     *
GRCaA*    05/04/19  DAS  GRCa
     *      - Revised display order to by Route/Transaction.
     *      - Added 5th view, which is their initial view.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFI A*    09/18/18  MLB  CFI
     *      - Revised program to default user to *ALL departments on
     *        first entry into program.
     *      - Added CFI to DRY mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC Foodservice
     *
SGC A*    12/04/20  MLB  SGC
     *      - Revised program to only allow authorized users to delete
     *        runner flag entries.
     *
500cA*----------------------------------------------------------------
500cA*  Notes - The table below will show what statuses are allowed for
500cA*          each Flag Type.
500cA*
500cA*----------------------------------------------------------------
500cA*  Flag Type==> | Normal (N) | Out (U) | Merge (M) |            |
500cA*----------------------------------------------------------------
500cA*  Status Code  |                                               |
500cA*----------------------------------------------------------------
500cA* Open    (O)   |     X      |    X    |     X     |            |
500cA* Replenished(R)|     X      |         |           |            |
500cA* Printed (P)   |     X      |    X    |     X     |            |
500cA* Closed  (C)   |     X      |    X    |     X     |            |
500cA* Deleted (D)   |     X      |    X    |     X     |            |
500cA*----------------------------------------------------------------
500cA*
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *    This program uses a flag WDWINUSE in the ZMxxxxx routines to
     *    determine which message record(s) to write when the prompt
     *    window is displayed. This allows the same message routines
     *    to be used for the window and full screen displays.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This is not a normal 110a type program.  Instead of option
     *    4 we are using option 1 with a command of *PRINT.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
500iA*  40        Protect Input Fields
GSC A*  41        Numeric data in ohdeld
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF**ru120fm   cf   e             workstn
710aDF**ru12001   cf   e             workstn
720aDF**ru12002   cf   e             workstn
730aDF*u12003   cf   e             workstn
730aMFru12004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
GSC AF                                     sfile(vw4sflgs:recno)
650aAF                                     sfile(vw4sfl:recno)
730aAF                                     sfile(vw5sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec1:msgk)
     FLabel     if   e           k disk
520 AFldrpltq3  if   e           k disk
417aAFoptions   if   e           k disk
VIP AForddm     if   e           k disk    usropn
GSC AFordh      if   e           k disk    usropn
GSC AFordlbl3   if   e           k disk    usropn
650aAFpirtran   if   e           k disk
720aAFpirtran9  if   e           k disk    rename(ptrec:ptrec9) prefix(p9)
     Fpiritem   if   e           k disk
500iA**Fpiruser1  if   e           k disk
CBIcAFpiruser   if   e           k disk
CBIcAFrsncode   if   e           k disk
CBIcAFflgdelf   o  a e           k disk
     Frtehed    if   e           k disk
     Frunner    uf   e           k disk
     F                                     rename(rurec:recordu)
     Frunner1   uf   e           k disk
     F                                     rename(rurec:rurec1)
     Frunner2   if   e           k disk
     F                                     rename(rurec:record)
710cAFrunner6   if   e           k disk
720aMF                                     rename(rurec:record6) prefix(r6)
     Fworkopt   uf a e           k disk
GRCaAFrtehed2   if   e           k disk    rename(rhrec:rhrec2) prefix(rh2)
GRCaAFpirtran4  if   e           k disk    rename(ptrec:ptrec4) prefix(pt4)
GRCaAFrunner5   if   e           k disk    rename(rurec:rurec5)
     F
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1)  ctdata perrcd(1)
GSC DD*cmdln           s             79    dim(6)  ctdata perrcd(1)
GRCaDD*cmdln           s             79    dim(8)  ctdata perrcd(1)
GRCaMD cmdln           s             79    dim(10)  ctdata perrcd(1)
GSC AD cmdlna          s             79    dim(2)  ctdata perrcd(1)
GRCaAD cmdln5          s             79    dim(10)  ctdata perrcd(1)
500 DD*desc            s             50    dim(14) ctdata perrcd(1)
500 AD desc            s             50    dim(15) ctdata perrcd(1)
417aAD cmdsndm         s             50    dim(3) ctdata perrcd(1)
417aA*
417cA*----------------------------------------------------------------
417cA*  Customer id
417cA*
ADW A /COPY QCOPYSRC,ID#andrews
417cA /COPY QCOPYSRC,ID#CHENEY
CSPaA /COPY QCOPYSRC,ID#COASTAL
GSC A /COPY QCOPYSRC,ID#GSC
DRY A /COPY QCOPYSRC,ID#DAIRYLA
CLD A /COPY QCOPYSRC,ID#CITYLIN
VIP A /COPY QCOPYSRC,ID#VIP
GFS A /COPY QCOPYSRC,ID#GFS
SOFaA /COPY QCOPYSRC,ID#SOFO
GLPaA /COPY QCOPYSRC,ID#GLP
ISPaA /COPY QCOPYSRC,ID#ISUPPLY
FPRaA /COPY QCOPYSRC,ID#FPR
JSLaA /COPY QCOPYSRC,ID#JSL
ADFaA /COPY QCOPYSRC,ID#ADF
SWTaA /COPY QCOPYSRC,ID#SWT
FSHaA /COPY QCOPYSRC,ID#FISCHER
MQSaA /COPY QCOPYSRC,ID#MQS
ACCaA /COPY QCOPYSRC,ID#ACC
CFI A /COPY QCOPYSRC,ID#CFI
GRCaA /COPY QCOPYSRC,ID#GRC
VFIaA /COPY QCOPYSRC,ID#VFI
BADaA /COPY QCOPYSRC,ID#BAD
SGC A /COPY QCOPYSRC,ID#SGC
417cA*
417aA*----------------------------------------------------------------
417aA*  *GENPICK -  General picking.
417aA*----------------------------------------------------------------
417aA*
417aA* Fields
417aA*
417aA*    OPERPT  -  Print exception (short) error report (Y,N).
417aA*    OPELBL  -  Print exception (short) labels (Y,N).
417aA*    OPRFWC  -  Using RF will call (Y,N).
417aA*    OPNRSC  -  Number of pallet sections (1-9).
417aA*    OPHPWC  -  Host pick Will Call (Y/N).
417aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
417aA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
417aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
417aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
417aA*    OPCLRF  -  Clear runner flags if qty still short/out? (Y/N)
417aA*    OPRNRM  -  Send message to user when new RUNNER task ready?
417aA*               (Y/N)
417aA*
417aA* Data structure
417aA*
417aAD opdta1          DS
417aAD  OPERPT                 1      1
417aAD  OPELBL                 2      2
417aAD  OPRFWC                 3      3
417aAD  OPNRSC                 4      4  0
417aAD  OPHPWC                 5      5
417aAD  OPMRGA                 6      6
417aAD  OPPLSQ                 7      7
417aAD  OPEADJ                 8      8
417aAD  OPNOPK                 9      9
500hD***OPCLRF                10     10
500hMD  OPCLRF2               10     10
500hD***OPRNRM                11     11
500hMD  OPRNRM2               11     11
417aAD  OPTEND               117    117
417aA*
500hA*----------------------------------------------------------------
500hA*  *RUNNER  -  PIR Runner Flag Options
500hA*----------------------------------------------------------------
500hA*
500hA* Fields
500hA*
500hA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
500hA*    OPUPLR  -  Update Label with quantity shorted during manual
500hA*               flag entry (Y/N)
500hA*               NOTE: Any change to this field will cause OPUPLV
500hA*                     in the *VOICE options record to be updated.
500hA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
500hA*               & create Priority Replenishment if necessary.
500hA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
500hA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
500hA*    OPRNRM  -  Send break message to user when new Runner
500hA*               task has been assigned. (Y/N)
500hA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
500hA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500iA*    OPRPCK  -  Print Runner pick list. (Y/N)
500iA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
500iA*               printer, 2=Belt printer
500iA*----------------------------------------------------------------
500hA* Data structure
500hA*
500hAD oprdta          ds
500hAD  opcrtm                 1      1
500hAD  opuplr                 2      2
500hAD  oprplf                 3      3
500hAD  opmrgf                 4      4
500hAD  opclrf                 5      5
500hAD  oprnrm                 6      6
500hAD  opclsf                 7      7
500hAD  opoutf                 8      8
500iAD  oprpck                 9      9
500iAD  oprlbl                10     10
500hAD  optendr              117    117

     *----------------------------------------------------------------
CBIcAD                 ds
CBIcAD  delinfo                1     15
CBIcAD  delwhs                 1      3  0
CBIcAD  deldpt                 4      8
CBIcAD  dellbl                 9     15  0

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0 inz(0)
     D  $kwhdp                 4      8
     D  $klbl#                 9     15  0 inz(0)
     *
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     *
     D  ruwhse                 1      3  0
     D  ruwhdp                 4      8
     D  rulbl#                 9     15  0
500cAD  rutype                16     16
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0
     D  ukwhdp                 4      8
     D  uklbl#                 9     15  0
500cAD  uktype                16     16
GSC A*----------------------------------------------------------------
GSC A*  Re-Defintion data structure - GSC
GSC A*
GSC AD                 ds
GSC AD  ohdeld                 1      6
GSC AD  ohmisc                 1     20
     *
VIP A*----------------------------------------------------------------
VIP A*  Order Detail Misc file - Misc fields 1 - 5.
VIP A*----------------------------------------------------------------
VIP A /copy *libl/qcopysrc,orddm1_vip
VIP A
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('RU122')
     D @delpg          c                   const('RU124')
500jAD @prtpg2         c                   const('RU350CL')
     D @prtpg          c                   const('RU360CL')
     D @adjtr2         c                   const('ADJTRAN2 ')
     *
     *----------------------------------------------------------------
     * Status message(s)
CLD AD err01           c                   const('Not authorized t-
CLD AD                                     o use 4=Delete')
     D sts01           c                   const('Open')
720cDD*sts02           c                   const('Printed')
720cMD sts02           c                   const('Prt''d')
GSC AD sts02g          c                   const('Print')
720cDD*sts03           c                   const('Closed')
720cMD sts03           c                   const('Cls''d')
417aAD sts04           c                   const('Flag task ready for pickup.')
720cDD*sts05           c                   const('Replenished')
720cMD sts05           c                   const('Rpl''d')
750aAD sts06           c                   const('NotLod''d')
500jAD noprinter       c                   const('No belt printer assigned to F-
500jAD                                     lag Runner.')
     *
     *----------------------------------------------------------------
     * Window Titles
     D Title01         c                   const('Assign Employee to Task')
     D Title02         c                   const('Reprint Runner Pick List')
     D Title03         c                   const('*ALL Warehouse Departments')
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
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
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
     D  $lwhsea               19     21
     D  $lwhdp                22     26
     *
     D  $ltrn#                22     28  0
     D  $ltrn#a               22     28
     D  $ldev                 29     38
     D  $lform                39     48
     *
     *----------------------------------------------------------------
     *  Date conversion work fields
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
     *
     D dftstamp        s               z
     D currstamp       s               z
     D datestamp       s               d
     D timestamp       s               t
     *
     *----------------------------------------------------------------
     *  Other working variables.
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
500jAD bothrpt         s              4    inz('*YES')
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
CSPaAD csptime         s              6  0
740aAD dftrunner       s              4    inz('*NO ')
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D error1          s              1
720aAD flgtypDesc      s              3
     D forceb          s              1
     D forever         s              1    inz('1')
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
720aAD holdlab         s                   like(lblbl#)
500aAD holdflgtyp      s                   like(flgtyp)
     D kytrn#          s                   like(lbtrn#)
     D kywhse          s                   like(lbwhse)
500hAD svwhse          s                   like(lbwhse)
     D kywhdp          s                   like(lbwhdp)
     D kylbl#          s                   like(lblbl#)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svtrn#          s                   like(lbtrn#)
     D t               s              2  0
     D tlpcs           s              7  0
     D tlswgt          s             11  2
     D tlcube          s             11  3
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D wdwinuse        s              4    inz('*NO ')
730aAD i               s              3  0
     D x               s              3  0
     D y               s              3  0
500iAD svdev           s             10
500iAD svdev2          s             10
500iAD svform          s             10
500iAD svform2         s             10
GRCaAD byRoute         s               n
GRCaAD fileToRead      s             10
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
     *  Parameters
     *
     *    Input Parameters
     *
500iA*     $EMP#    -  Employee number
     *
     *    Returned Parameters
     *
500iA*     $WHSE    -  Default warehouse
500iA*     $CODE    -  User code
500iA*     $FNAM    -  Employee first name
500iA*     $INIT    -  Employee middle initial
500iA*     $LNAM    -  Employee last name
500iA*     $WHDP    -  Default department
500iA*     $STYP    -  Default section
500iA*     $SHFT    -  Default shift
500iA*     $CREW    -  Default crew
500iA*     $NHRS    -  Default hours per shift
500iA*     $RTN     -  Status code
500iA*                 *OK    - Valid userid
500iA*                 *ERROR - Invalid userid
500iA*     $BPU     -  Belt printer user (Y,N).
500iA*                 Note, this has to come at the end of the parm list
500iA*                 so that we can determine if it was sent or not.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
500iAC     getemplp      plist
500iAC                   parm                    $emp#             5 0
500iAC                   parm                    $whse             3 0
500iAC                   parm                    $code            10
500iAC                   parm                    $fnam            15
500iAC                   parm                    $init             1
500iAC                   parm                    $lnam            20
500iAC                   parm                    $whdp             5
500iAC                   parm                    $styp             1
500iAC                   parm                    $shft             6
500iAC                   parm                    $crew             6
500iAC                   parm                    $nhrs             3 1
500iAC                   parm                    $rtn              8
500iAC                   parm                    $bpu              1
710dAC                   parm                    $email            1
710dAC                   parm                    $pics             1
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     *
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   seton                                        lr
     *
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
500fA*
500fA*   Set ON *in02 to force 'Change to Department' field
500fA*   initial cursor default location.
500fA*
500fAC                   if        error <> *on
500fAC                   eval      *in02 = *on
500fAC                   endif
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     *
     C                   when      nxtscr = '02 '
     C                   exsr      deldsp
     *
     C                   when      nxtscr = '03 '
     C                   exsr      deldsp
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn   = *off
     C                   eval      error  = *off
     C                   eval      cancel = *off
     C                   eval      e      = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     C                   when      view = 1
     C                   read      dspsfc                                 50
     C                   when      view = 2
     C                   read      vw2sfc                                 50
     C                   when      view = 3
     C                   read      vw3sfc                                 50
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   read      vw4sfcgs                               50
650aAC                   when      view = 4
650aAC                   read      vw4sfc                                 50
730aAC                   when      view = 5
730aAC                   read      vw5sfc                                 50
     C                   endsl
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
417aA****500hA           exsr      zzgetop
500hAC                   if        kywhse <> svwhse
500hAC                   exsr      zzgetruop
500hAC                   eval      svwhse = kywhse
500hAC                   endif
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
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     *
     C                   eval      nxtscr = '03 '
     C                   eval      *in90  = *on
     *
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     *
     C                   write     clr0306
     C                   write     delrec3
     *
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag03
     *
     C                   write     cmddel
     *
     C                   endsr
     *
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
     C*                  eval      $pouky = $puky
     C                   eval      $pouky = frstky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 wrap-up
     *
     C     scr03e        begsr
     *
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
     *
     C                   else
     *
     C                   eval      $pocmd = '*POSTN2U'
     C*                  eval      $pouky = $puky
     C                   eval      $pouky = frstky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     *
     C                   endsr
     *
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
     *
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     C     status        caseq     rollup        roll03
     C     status        caseq     rolldn        roll03
     C     status        caseq     comand        cmd03
     C                   cas                     ent03
     C                   endcs
     *
     C     endsc3        endsr
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
417cA*
417cA* Get client id.
417cA*
417cAC                   call      'GETCLIENT'
417cAC                   parm                    client           10
GSC A*
GSC A*  Open files unique to Grocery Supply
GSC AC                   if        client = gsc
GSC AC                   open      ordh
GSC AC                   open      ordlbl3
GSC AC                   endif
VIP A*
VIP AC                   if        client = VIP
VIP A*
VIP AC                   if        not %open(orddm)
VIP AC                   open      orddm
VIP AC                   endif
VIP A*
VIP AC                   endif
VIP A*
     *
     *  Define keys
     *
     *  Define key for LDRPLTQ3 file.
520 A*
520 AC     plkey         klist
520 AC                   kfld                    ruwhse
520 AC                   kfld                    rulbl#
417aA*
417aA*  Define key for OPTIONS file.
417aA*
417aAC     opkey         klist
417aAC                   kfld                    kywhse
417aAC                   kfld                    opcode
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
CBIcA*
CBIcA*  Define key for RSNCODE file.
CBIcA*
CBIcAC     rsnkey        klist
CBIcAC                   kfld                    kywhse
CBIcAC                   kfld                    wkocde            1
CBIcA*
CBIcA*  Define key for RUNNER1 file.
CBIcA*
CBIcAC     itmkey        klist
CBIcAC                   kfld                    delwhs
CBIcAC                   kfld                    lbitem
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     C                   write     vw2sfl                               79
     C                   write     vw3sfl                               79
650aAC                   write     vw4sfl                               79
GSC AC                   if        client = gsc
GSC AC                   write     vw4sflgs                             79
GSC AC                   endif
730aAC                   write     vw5sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     *
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  Test for Cmd3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Execute command keys that don't need the options verified
     *
     *     Test for Cmd5 - Refresh
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        dsplyd        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    dspsfl
     C                   endif
     C     x             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    vw2sfl
     C                   endif
     C     x             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    vw3sfl
     C                   endif
650aAC     x             chain     vw4sfl                             79
650aAC                   if        not *in79
650aAC                   eval      option = '  '
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
650aAC                   update    vw4sfl
650aAC                   endif
GSC AC                   if        client = gsc
GSC AC     x             chain     vw4sflgs                           79
GSC AC                   if        not *in79
GSC AC                   eval      option = '  '
GSC AC                   update    vw4sflgs
GSC AC                   endif
GSC AC                   endif
730aAC     x             chain     vw5sfl                             79
730aAC                   if        not *in79
730aAC                   eval      option = '  '
730aA*    Restore color indicators.
730aAC                   eval      *in32 = hldi32
730aAC                   eval      *in33 = hldi33
730aAC                   eval      *in34 = hldi34
     C                   update    vw5sfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Verify and save any options that were entered.
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  Execute command keys that did need the options verified
     *
     *  Test for Cmd6 - Reprint Runner Pick List
     *
     C                   if        *inkf
     C
     C                   eval      $puky  = fkey(1)
500iAC                   select
500iA* Pick list or label
500iAC                   when      oprpck = 'Y' and oprlbl  = '0' or
500iAC                             oprpck = 'N' and oprlbl >= '1'
500jAC                   eval      bothrpt = '*NO '
     C                   exsr      zzwdwreprnt
500iA* Pick list and label
500iAC                   when      oprpck = 'Y' and oprlbl >= '1'
500jAC                   eval      bothrpt = '*YES'
500iAC                   exsr      zzwdwreprnt2
500iAC                   endsl
     C                   If        cancel  = *off
     C
     C                   eval      $lwhsea = %editc(kywhse:'X')
     C                   eval      $ltrn#a = %editc(wwtrn#:'X')
500dA*
500dA*    Tell Runner pick program which type we're printing.
500dAC                   Select
500eMC                   When      flgtyp = 'OUT'
500dAC                   eval      $lcmd = '*RPNTOUT'
500dA*
500eMC                   When      flgtyp = 'MRG'
500dAC                   eval      $lcmd = '*RPNTMRG'
500dA*
500dAC                   Other
500dAC                   eval      $lcmd = '*REPRINT'
500dAC                   endsl
500jA*
500jDC*                  if        client = cheney
500jA*    Print Runner Flags on Belt Printer.
500iAC                   if        oprlbl >= '1'

500iAC                   select
500iAC                   when      oprlbl = '2'
500iAC                   eval      $lcmd = '*RPRTBLT'
500iAC                   other
500iAC                   eval      $lcmd = '*REPRINT'
500iAC                   endsl

500jAC                   select
500jAC                   when      bothrpt = '*YES'
500jAC                   eval      $ldev   = wwdev2
500jAC                   eval      $lform  = wwform2
500jAC                   other
500jAC                   eval      $ldev   = wwdev
500jAC                   eval      $lform  = wwform
500jAC                   endsl

500jAC                   call      @prtpg2
500jAC                   Parm                    $lcmd
500jAC                   Parm                    $lwhsea
500jAC                   Parm                    $ltrn#a
500jAC                   Parm                    $ldev
500jAC                   Parm                    $lform
500jAC                   Parm      *blanks       $lrtn
500jDC*                  endif
500jA*
500jAC                   If        $lrtn =  '*NOBELT '
500jAC                   eval      error  = *on
500jAC                   eval      errmsg = noprinter
500jAC                   exsr      zm0105
500jAC                   Endif
500jA*
500jAC                   endif
500jA*
500dA*
500jAC                   If        error =  *off
500iAC                   if        oprpck = 'Y'
     C                   call      @prtpg
500dDC*                  Parm      '*REPRINT'    $lcmd
500dMC                   Parm                    $lcmd
     C                   Parm                    $lwhsea
     C                   Parm                    $ltrn#a
     C                   Parm      wwdev         $ldev
     C                   Parm      wwform        $lform
     C                   Parm      *blanks       $lrtn
500iAC                   endif
500jAC                   endif
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   Else
     C                   If        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   Else
     C                   If        $lrtn <> '*CANCEL '  and
     C                             $lrtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   Endif
     C                   Endif
     C                   Endif
     C                   Endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   Endif
     *
     *  Test for Cmd20 - Move record that cursor is on to top
     *
     C                   if        *inku
     C**                 z-add     0             row#
     C**                 eval      row = rowin
     C**                 z-add     0             col#
     C**                 eval      col = colin
     *
     *     Make sure cursor is on one of the displayed records
     *
     C**                 sub       10            row#
     C**                 if        row# < 1  or
     C                   if        SFLRRN = 0
     C*                            row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     Reposition record that cursor is on to the top
     *
     C                   eval      $pocmd = '*POSTN2U'
     C*                  eval      $pouky = ukey(row#)
     C                   eval      $pouky = ukey(SFLRRN)
710cAC                   Eval      kytype = %subst($pouky:16:1)
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd10 - Previous view
     *
     C                   if        *inkj
     C                   if        view = 1
     C                   eval      view = maxvw
     C                   else
     C                   eval      view = view - 1
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd11 - Next view
     *
     C                   if        *inkk
     C                   if        view = maxvw
     C                   eval      view = 1
     C                   else
     C                   add       1             view
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd17 - Reposition to top of display
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd18 - Reposition to bottom of display.
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
     *
     C     cmd01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  Test for Cmd12 - Previous
     *
     C                   if        *inkl
     C                   exsr      clrsch
     *
     C                   eval      cancel = *on
500gAC                   select
500gAC                   when      fkey(1) > *blanks
500gAC                   eval      frstky = fkey(1)
500gAC                   when      $puky > *blanks
500gAC                   eval      frstky = $puky
500gAC                   other
500gAC                   eval      frstky = dsfkey
500gAC                   endsl
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     *
     C     cmd02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  CMD03    Screen 3 command key routine
     *
     C     cmd03         begsr
     *
     *  Test for Cmd12 - Previous
     *
     C                   if        *inkl
     C                   exsr      clrsch
     *
     C                   eval      cancel = *on
500gAC                   eval      frstky = $puky
     C                   exsr      scr03e
     C                   goto      cmd03e
     C                   endif
     *
     C     cmd03e        endsr
     *
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 10
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  Get record info
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *
     *  Save key to record of first screen line
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  Write display line to subfile
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
     C                   write     vw2sfl
     C                   write     vw3sfl
650aAC                   write     vw4sfl
GSC AC                   if        client = gsc
GSC AC                   write     vw4sflgs
GSC AC                   endif
730aAC                   write     vw5sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  Write 'Bottom/More...' field to display
     *
     C                   write     morrec
     *
     *  Write subfile to display
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   write     vw4sfcgs
650aAC                   when      view = 4
650aAC                   write     vw4sfc
730aAC                   when      view = 5
730aAC                   write     vw5sfc
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  Verify and save options
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  See if user is trying to position to a certain spot
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
GRCaAC                   if        byRoute and rulbl# = 0
GRCaAC                   eval      $pocmd = '*TOP'
GRCaAC                   exsr      fgtway
GRCaAC                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
GRCaAC                   endif
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  If not positioning then execute the entered options
     *
     C                   exsr      optns
     *
     C     ent01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first Select key.
     *
     C                   eval      frstky = $puky
     C                   eval      Tlpcs  = 0
     C                   eval      Tlswgt = 0
     C                   eval      Tlcube = 0
500iA****                eval      uscode = ' '
500iAC                   eval      $code  = ' '
     *
     *  Prompt user for Runner employee number and printer.
     *
500iAC                   select
500iA* Pick list or label
500iAC                   when      oprpck = 'Y' and oprlbl  = '0' or
500iAC                             oprpck = 'N' and oprlbl >= '1'
500jAC                   eval      bothrpt  = '*NO '
     C                   Exsr      zzwdwprompt
500iA* Pick list and label
500iAC                   when      oprpck = 'Y' and oprlbl >= '1'
500jAC                   eval      bothrpt  = '*YES'
500iAC                   Exsr      zzwdwprompt2
500iAC                   endsl

     C                   If        cancel = *on
     C                   goto      endent02
     C                   Endif
     *
     *  Process the Labels that have been selected.
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   select
     C                   when      *in79
     C                   eval      stop = *on
     *
     C                   other
     *
     C                   if        wkoopt = ' 1'
     C                   exsr      inzpar
500bAC                   eval      $pcmd  = '*CHANGE '
     C                   eval      $puky  = wkokyu
     C                   eval      dsukey = $puky
500 AC                   eval      dsfkey = $puky
     *
     *  Check status of Label entry.
     *
     C                   exsr      zzckstat
     *
     *     Error occured - Error message sent back
     *
     C                   If        cancel = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   Else
     C                   eval      TLpcs  = Tlpcs  + ruqyso
     C                   eval      TLswgt = Tlswgt + (ruqyso * lbuwgt)
     C                   eval      TLcube = Tlcube + (ruqyso * lbucub)
     C                   Endif
     *
     C                   Endif
     *
     C                   endsl
     C                   enddo
     *
     *  Process the Labels that have been selected.
     *
     C                   if        cancel = *off
     *
     *         Create Runner Transaction number.
     C                   Call      @adjtr2
530aDC*****              Parm      '*CRTSTRT  '  $Pcmd2           10
530aMC                   Parm      '*CREATE   '  $Pcmd2           10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      0             $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      kywhse        $Pwhse            3 0
     C                   Parm      ' '           $pwhdp            5
     C                   Parm      ' '           $pstyp            1
     C                   Parm      tlcube        $pcube            9 3
     C                   Parm      tlswgt        $pswgt            9 2
     C                   Parm      tlpcs         $ppcs             5 0
     C                   Parm      1             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      ' '           $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
500iA****                Parm      uscode        $puser           10
500iAC                   Parm      $code         $puser           10
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   If        $Prtn = '*ERROR  '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      Svtrn# = $ptrn#
417aA*
417aA*         Send break message to Flag Runner if Yes.
417aAC                   if        oprnrm = 'Y'
417aAC                   exsr      zzsndmsg
417aAC                   endif
417aA*
     C                   endif
     C                   endif
     *
     *         Close Runner Transaction.
     C                   if        error  = *off
     C                   Call      @adjtr2
     C                   Parm      '*CLOSE    '  $Pcmd2           10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      svtrn#        $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      kywhse        $Pwhse            3 0
     C                   Parm      ' '           $pwhdp            5
     C                   Parm      ' '           $pstyp            1
     C                   Parm      tlcube        $pcube            9 3
     C                   Parm      tlswgt        $pswgt            9 2
     C                   Parm      tlpcs         $ppcs             5 0
     C                   Parm      1             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      ' '           $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
500iA****                Parm      uscode        $puser           10
500iAC                   Parm      $code         $puser
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   If        $Prtn = '*ERROR  '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     C                   If        Error  = *off
     C                   eval      Svtrn# = $ptrn#
     C                   time                    currstamp
     C                   Endif
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C                             and error = *off
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 1'
     C                   eval      dsukey = wkokyu
     *
     *  Update Label entry status to Picked.
     *
     C                   eval      $puky = wkokyu
     C                   exsr      zzupdstat
     *
     *     Error occured - Error message sent back
     *
     C                   If        cancel = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   Else
     C                   delete    wkorec
     C                   Endif
     *
     C                   endif
     *
     C                   endif
     C                   enddo
     *
     *    Remove transaction if any errors.
     C                   If        cancel = *on
     C                   exsr      zzabort
     *
     C                   Else
     *
     *    Print Runner Pick List report.
     C                   eval      $lwhsea = %editc(kywhse:'X')
     C                   eval      $ltrn#a = %editc(svtrn#:'X')
500dA*
500dA*    Tell Runner pick program which type we're printing.
500dAC                   Select
500eMC                   When      flgtyp = 'OUT'
500dAC                   eval      $lcmd = '*PRTOUT '
500dA*
500eMC                   When      flgtyp = 'MRG'
500dAC                   eval      $lcmd = '*PRTMRG '
500dA*
500dAC                   Other
500dAC                   eval      $lcmd = '*PRINT  '
500dAC                   endsl
500jA*
500jA*    Print Runner Flags on Belt Printer.
500iAC                   if        oprlbl >= '1'

500iAC                   select
500iAC                   when      oprlbl = '2'
500iAC                   eval      $lcmd = '*PRTBELT'
500iAC                   other
500iAC                   eval      $lcmd = '*PRINT  '
500iAC                   endsl

500jAC                   select
500jAC                   when      bothrpt = '*YES'
500jAC                   eval      $ldev   = wwdev2
500jAC                   eval      $lform  = wwform2
500jAC                   other
500jAC                   eval      $ldev   = wwdev
500jAC                   eval      $lform  = wwform
500jAC                   endsl

500jAC                   call      @prtpg2
500jAC                   Parm                    $lcmd
500jAC                   Parm                    $lwhsea
500jAC                   Parm                    $ltrn#a
500jAC                   Parm                    $ldev
500jAC                   Parm                    $lform
500jAC                   Parm      *blanks       $lrtn
500iAC                   endif
500jA*
500jAC                   If        $lrtn =  '*NOBELT '
500jAC                   eval      error  = *on
500jAC                   eval      errmsg = noprinter
500jAC                   exsr      zm0105
500jAC                   goto      Endent02
500jAC                   Endif
500jA*
500dA*
500iAC                   if        oprpck = 'Y'
     C                   Call      @prtpg
500aDC*                  Parm      '*PRINT  '    $lcmd
500aMC                   Parm                    $lcmd
     C                   Parm                    $lwhsea
     C                   Parm                    $ltrn#a
     C                   Parm      wwdev         $ldev
     C                   Parm      wwform        $lform
     C                   Parm      *blanks       $lrtn
500iAC                   endif
     C                   Endif
     *
     C                   endif
     *
     C     Endent02      tag
     *
     C                   exsr      scr02e
     *
     C     ent02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ENT03    Screen 3 enter key routine
     *
     CSR   ENT03         BEGSR
     *
     *  Save first delete key.
     *
     CSR   *LIKE         DEFINE    $PUKY         FRSTKY
     CSR                 MOVE      $puky         FRSTKY
     *
     *  Delete the records that have been selected
     *
     CSR   WKOPRT        SETLL     WORKOPT
     CSR                 eval      stop = *off
     CSR   STOP          DOUEQ     '1'
     CSR   WKOPRT        READE     WORKOPT                                79
     CSR                 MOVE      *OFF          *IN21
     CSR                 IF        *in79 = *on
     CSR                 eval      stop  = *on
     CSR                 ELSE
     *
     CSR                 if        wkoopt = ' 4'
CLD A*
CLD A*     Check if user is authorized to use this option.
CLD AC     client        ifeq      cityline
CSPbAC     client        oreq      CoastalSunbelt
CBIcAC     client        oreq      cheney
SGC AC     client        oreq      SGC
CLD A*
CLD AC     wkoopt        ifeq      ' 4'
CLDaAc                   eval      $copt = %trim(wkoopt)
CLD AC                   call      'CHKLIST'
CLD AC                   parm      #prog         $cpgm            10
CLDaMc                   parm                    $copt            20
CLD AC                   parm      #user         $cuser           10
CLD AC                   parm      *blanks       $crtn            10
CLD A*
CLD A*       User not authorized to use this option.
CLD AC     $crtn         ifeq      '*NO '
CLD AC                   move      *on           error
CLD AC                   move      *on           cancel
CLD AC                   movel(p)  err01         errmsg
CLD AC                   exsr      zm0105
CLD AC                   iter
CLD AC                   endif
CLD A*
CLD AC                   endif
CLD A*
CLD AC                   endif
     *
     *  Call delete program
     *
     CSR                 EXSR      INZPAR
     CSR                 MOVE      '*DELETE '    $PCMD
     CSR                 MOVE      WKOKYU        $PUKY
CBIcACSR                 MOVEL     WKOKYU        DELINFO
     *
     *    Verify that flag entry is still at "Open" status.
     *
     CSR                 MOVE      $PUKY         DSUKEY
500 ACSR                 MOVE      $PUKY         DSFKEY
     CSR                 EXSR      zzckstat
     CSR                 if        cancel = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   iter
     CSR                 ENDIF
     *
     CSR                 CALL      @DELPG
     CSR                 PARM                    $PARMS
     *
     *     Error occured - Error message sent back
     *
     CSR   $PRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVEL     $PERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     *
     *     Error occured - Error message sent to program msgq
     *
     CSR   $PRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      '1'           ERROR
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ELSE
     *
     *     Delete canceled
     *
     CSR   $PRTN         IFEQ      '*CANCEL '
     CSR                 MOVE      '1'           CANCEL
     CSR                 MOVE      '1'           STOP
     CSR                 ELSE
     *
     *     Delete was successful.
     *
     CSR   $PRTN         IFEQ      '*OK     '
CBIcAC*----------------------------------------------------------------
CBIcA*     Create a delete history record
CBIcA*
730bDC*                  if        client = cheney
CBIcAC                   clear                   flgdrec
CBIcAC     dellbl        chain     label                              79
CBIcAC     *in79         ifeq      *off
CBIcAC                   eval      flgitm = lbitem
CBIcAC                   eval      flglbl = lblbl#
CBIcAC                   eval      flgtrn = lbtrn#
CBIcAC                   endif
CBIcAC     #user         chain     piruser                            79
CBIcAC     *in79         ifeq      *off
CBIcDC*>                 eval      flgfna = usfnam
CBIcDC*>                 eval      flgini = usinit
CBIcDC*>                 eval      flglna = uslnam
CBIcAC                   eval      flgemp = usemp#
CBIcAC                   eval      flgshf = usshft
CBIcAC                   eval      flgcrw = uscrew
CBIcAC                   endif
CBIcAC*
CBIcAC     itmkey        chain     piritem                            79
CBIcAC     *in79         ifeq      *off
CBIcAC                   eval      flgidc = itdesc
CBIcAC                   endif
CBIcAC*
CBIcAC                   eval      flgwhs = delwhs
CBIcAC                   eval      flgwhd = deldpt
CBIcAC                   eval      flgcde = wkocde
CBIcAC                   eval      flgusr = #user
CBIcAC*>                 move      wkocde        indx              1 0
CBIcDC*>                 move      rcdesc(indx)  flgrdc
CBIcAC*
CBIcAC*    Find reason code description
CBIcAC     rsnkey        chain     rsncode                            74
CBIcAC     *in74         ifeq      *off
CBIcAC                   eval      flgrdc = rsndsc
CBIcAC                   else
CBIcAC                   eval      flgrdc = ' '
CBIcAC                   endif
CBIcAC*
CBIcAC                   move      '*MDYCMD '    $cvcmd
CBIcAC                   move      #jobdt        $cvd6i
CBIcAC                   call      @cvtdt
CBIcAC                   parm                    $cvtdt
CBIcAC                   z-add     $cvd8o        flgdte
CBIcAC                   time                    flgtim
CBIcAC                   write     flgdrec
730bDC*                  endif
CBIcAC*----------------------------------------------------------------
     CSR                 MOVE      $PMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 END
     CSR                 END
     CSR                 END
     CSR                 END
     *
     CSR                 IF        cancel = *off
     CSR                 DELETE    WKOREC
     CSR                 ELSE
     CSR                 MOVE      '1'           WKOERR
     CSR                 UPDATE    WKOREC
     CSR                 END
     CSR                 END
     *
     CSR                 END
     CSR                 END
     *
     *
     CSR                 EXSR      SCR03E
     CSR                 eval      $pcmd  = ' '
     *
     CSR   ENT03E        ENDSR
     *
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
     C                   exsr      zzkeyi
     C                   else
     *
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
     C                   exsr      zzkeyi
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
     C                   exsr      zzkeyi
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
GRCaAC                   if        not byRoute
     C     fileky        setll     record
GRCaAC                   else
GRCaA /free
GRCaA    fileToRead = 'RUNNER';
GRCaA    chain (ruwhse: rutype: ruwhdp: rulbl#) runner2;
GRCaA    if %eof(runner2);
GRCaA      leavesr;
GRCaA    endif;
GRCaA    setll (ruwhse: rutype: ruwhdp: rulbl#) runner2;
GRCaA
GRCaA    setll (kywhse: ruotrn) runner5;
GRCaA
GRCaA    chain (ruotrn) pirtran;
GRCaA    if %eof(pirtran);
GRCaA      leavesr;
GRCaA    endif;
GRCaA    setll (kywhse: ' ': ptrtpo: pttrn#: ptgrp1) pirtran4;
GRCaA    reade (kywhse: ' ': ptrtpo: pttrn#: ptgrp1) pirtran4;
GRCaA    if %eof(pirtran4);
GRCaA      leavesr;
GRCaA    endif;
GRCaA
GRCaA    chain (kywhse: ptrtpo) rtehed;
GRCaA    if %eof(rtehed);
GRCaA      leavesr;
GRCaA    endif;
GRCaA    setll (kywhse: '4': ' ': rhrte: rhrtid) rtehed2;
GRCaA    reade (kywhse: '4': ' ': rhrte: rhrtid) rtehed2;
GRCaA    if %eof(rtehed2);
GRCaA      leavesr;
GRCaA    endif;
GRCaA /end-free
GRCaAC                   endif
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
     C                   eval      $ptype = '*INTER  '
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *  Do all 1=Select's first (option 1)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 1'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 1'
     C                   eval      dsukey = wkokyu
     C                   if        error = *on
     C                   goto      optnse
     C                   endif
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  Do all 4=Delete's next. (Option 4)
     *
     C     WKOPRT        SETLL     WORKOPT
     C                   eval      stop = *off
     C     WKOPRT        READE     WORKOPT                                79
     C     *IN79         DOWEQ     '0'
     C     WKOOPT        ANDNE     ' 4'
     C     WKOPRT        READE     WORKOPT                                79
     C                   END
     C     *IN79         IFEQ      '0'
     C     WKOOPT        ANDEQ     ' 4'
     C                   eval      otaken = *on
     C                   MOVE      WKOKYU        $PUKY
     C                   EXSR      SCR03I
     C                   GOTO      OPTNSE
     C                   END
     *
     *  Then do the other options in the order they were entered -
     *     Stop when no more options or user enters Cmd12.
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
     C                   if        error  = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop   = *on
     C                   if        error  = *on
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
     C                   if        refrsh = *on
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     *
     C                   endif
     *
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
     C                   exsr      zzopt
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     *
     C                   else
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
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
     *
     C                   eval      pagcmd = *blanks
     *
     C     pag02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG03    Screen 3 page routines
     *
     C     pag03         begsr
     *
     *  Next Page
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag3fw
     C                   else
     *
     *  Previous Page
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag3bk
     C                   else
     *
     *  Refresh Screen
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag3fw
     C                   endif
     C                   endif
     C                   endif
     *
     C                   eval      pagcmd = *blanks
     *
     C     pag03e        endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  Get 09 records to display
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  Out of Records - Inform user and set flag
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  Record read - Stop after 09 good records
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 09
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
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   eval      goback = dsplyd + 09
     C                   if        bot = '1'
     C                   if        goback = 09
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  Hit Top of File
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  Record read - Stop after reading 'GOBACK' number of good recs
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * If the top was reached then position pointer to top of file
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     *
     C                   exsr      pag1fw
     *
     C     endb          endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf2
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  Get 09 Records to display
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  Record read - Stop after 09 good records
     *
     C                   if        wkoopt = ' 1'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 09
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
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of Select records
     *
     C     pag2bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   eval      goback = dsplyd + 09
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  Hit top of file
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  Record read - Stop after reading 'GOBACK' number of good recs
     *
     C                   if        wkoopt = ' 1'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * If we hit the top, Reposition pointer to top of file.
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     *
     C                   exsr      pag2fw
     *
     C     endb2         endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG3FW   Let's see that next page of delete records
     *
     C     pag3fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf3
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot  = *off
     C                   eval      top  = *off
     C                   eval      stop = *off
     C                   eval      p    = 0
     *
     *  Get 09 Records to display
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw3
     C                   endif
     *
     *  Record read - Stop after 09 good records
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 09
     C                   eval      stop   = *on
     C                   if        forceb = '1'
     C                   eval      bot    = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw3        tag
     C                   enddo
     *
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     *
     C     endf3         endsr
     *
     *----------------------------------------------------------------
     *
     *  PAG3BK   Let's see the previous page of delete records
     *
     C     pag3bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     '1'           endb3
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   eval      goback = dsplyd + 09
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top  = *off
     C                   eval      bot  = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  Hit top of file
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk3
     C                   endif
     *
     *  Record read - Stop after reading 'GOBACK' number of good recs
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk3        tag
     C                   enddo
     *
     * If we hit the top, Reposition pointer to top of file
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     *
     C                   exsr      pag3fw
     *
     C     endb3         endsr
     *
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  Test for Rollup
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  Test for Rolldown
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     C     rol01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  Test for Rollup
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  Test for Rolldown
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *
     *----------------------------------------------------------------
     *
     *  ROLL03   Screen 3 roll up/down routine
     *
     C     roll03        begsr
     *
     *  Test for Rollup
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag03
     C                   goto      rol03e
     C                   endif
     *
     *  Test for Rolldown
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag03
     C                   goto      rol03e
     C                   endif
     *
     C     rol03e        endsr
     *
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the changed options
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   when      view = 3
     C                   readc     vw3sfl                                 79
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   readc     vw4sflgs                               79
650aAC                   when      view = 4
650aAC                   readc     vw4sfl                                 79
730aAC                   when      view = 5
730aAC                   readc     vw5sfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *  Look up option in profile - Error if not found
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  Save option
     *
     C                   select
     C                   when      view = 1
     C                   eval      y = recno
     C                   when      view = 2
     C                   eval      y = recno
     C                   when      view = 3
     C                   eval      y = recno
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   eval      y = recno
650aAC                   when      view = 4
650aAC                   eval      y = recno
730aAC                   when      view = 5
730aAC                   eval      y = recno
     C                   endsl
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
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 10
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   eval      y = reccnt
     *
     *  Save file and unique keys
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  Write display line to subfile
     *
     C                   exsr      zzfill
     *
     C                   write     dspsfl
     C                   write     vw2sfl
     C                   write     vw3sfl
650aAC                   write     vw4sfl
GSC AC                   if        client = gsc
GSC AC                   write     vw4sflgs
GSC AC                   endif
730aAC                   write     vw5sfl
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  Clear display subfile
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
     C                   write     vw2sfc
     C                   write     vw3sfc
654aAC                   write     vw4sfc
GSC AC                   if        client = gsc
GSC AC                   write     vw4sfcgs
GSC AC                   endif
730aAC                   write     vw5sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno  = 0
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  Write option and command lines to display
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  Write 'Bottom/More...' Field to display
     *
     C                   write     morrec
     *
     *  Write position to field to display
     *
     C                   write     postnrec
     *
     *  Get any existing values for the options
     *
     C                   exsr      sflopt
     *
     *  Position cursor to first option when no errors exist
     *
     C                   if        error <> '1'
     C                   select
     C                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    dspsfl
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    vw2sfl
     C                   endif
     C                   when      view = 3
     C     1             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   update    vw3sfl
     C                   endif
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC     1             chain     vw4sflgs                           79
GSC AC                   if        not *in79
GSC AC                   eval      *in20 = *on
GSC AC                   update    vw4sflgs
GSC AC                   endif
650aAC                   when      view = 4
650aAC     1             chain     vw4sfl                             79
650aAC                   if        not *in79
650aAC                   eval      *in20 = *on
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
650aAC                   update    vw4sfl
650aAC                   endif
730aAC                   when      view = 5
730aAC     1             chain     vw5sfl                             79
730aAC                   if        not *in79
730aAC                   eval      *in20 = *on
730aA*    Restore color indicators.
730aAC                   eval      *in32 = hldi32
730aAC                   eval      *in33 = hldi33
730aAC                   eval      *in34 = hldi34
     C                   update    vw5sfl
     C                   endif
     C                   endsl
     C                   endif
     *
     *  Write subfile to display
     *
     C                   eval      *in81 = *on
     C                   eval      recno = posrec
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
650aAC                   when      view = 4
650aAC                   write     vw4sfc
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   write     vw4sfcgs
730aAC                   when      view = 5
730aAC                   write     vw5sfc
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x
     C                   select
     C                   when      view = 1
     C     x             chain     dspsfl                             79
     C                   when      view = 2
     C     x             chain     vw2sfl                             79
     C                   when      view = 3
     C     x             chain     vw3sfl                             79
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC     x             chain     vw4sflgs                           79
650aAC                   when      view = 4
650aAC     x             chain     vw4sfl                             79
730aAC                   when      view = 5
730aAC     x             chain     vw5sfl                             79
     C                   endsl
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
720aA*    Restore color indicators.
720aAC                   eval      *in32 = hldi32
720aAC                   eval      *in33 = hldi33
720aAC                   eval      *in34 = hldi34
     C                   select
     C                   when      view = 1
     C                   update    dspsfl
     C                   when      view = 2
     C                   update    vw2sfl
     C                   when      view = 3
     C                   update    vw3sfl
GSC AC                   when          client = gsc
GSC AC                             and view = 4
GSC AC                   update    vw4sflgs
640aAC                   when      view = 4
650aAC                   update    vw4sfl
730aAC                   when      view = 5
730aAC                   update    vw5sfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   If        wdwinuse = '*YES'
     C                   write     msgctl1
     C                   Else
     C                   write     msgctl
     C                   Endif
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   If        wdwinuse = '*YES'
     C                   write     msgclr1
     C                   Else
     C                   write     msgclr
     C                   Endif
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   If        wdwinuse = '*YES'
     C                   write     msgctl1
     C                   Else
     C                   write     msgctl
     C                   Endif
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
     C                   If        wdwinuse = '*YES'
     C                   write     msgrec1
     C                   Else
     C                   write     msgrec
     C                   Endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   If        wdwinuse = '*YES'
     C                   write     msgrec1
     C                   Else
     C                   write     msgrec
     C                   Endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
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
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        Begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   Endsr
     *----------------------------------------------------------------
     *    PIR7872  Record not updated in file.
     *
     C     zm7872        begsr
     C                   move      'PIR7872'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
500aA*  Test for F16 - Select all flag entries.
500aA*
500eM*    Note: When FLGTYP = RPL only flags at Replenished
500aA*          status will be selected for printing.
500aA*
500eM*    Note: When FLGTYP = OUT only flags at Out
500aA*          status will be selected for printing.
500aA*
710bDC**                 if        *inkq and wowhdp <> '*ALL '
710bMC                   if        *inkq and
710bMC                             wowhdp <> '*ALL ' and
710bMC                             flgtyp <> 'ALL'
500aA*
500aAC     partky        setll     record
500aAC                   dou       forever <> forever
500aAC     partky        reade(n)  record                                 77
500aAC                   select
500aAC                   when      *in77
500aAC                   leave
500aA*
500aAC                   when      rustat = 'C'
500aAC                             or rustat = 'D'
750aAC                             or rustat = 'L'
500dA*
500dA*    When Flag Type is *OUT, load only flags at Open status.
500eMC                             or flgtyp = 'OUT'
500dAC                             and rustat = 'P'
500dA*
500dA*    When Flag Type is *MRG, load only flags at Open status.
500eMC                             or flgtyp = 'MRG'
500dAC                             and rustat = 'P'
500aA*
710aAC*    When Flag Type is *BXB, load only flags at Open status.
710aAC                             or flgtyp = 'BXB'
710aAC                             and rustat = 'P'
710aAC
720bA*    Don't load flags at S status.
720bAC                             or rustat = 'S'
720bAC
500aA*    When Flag Type is *RPL, load only flags at Replenished status.
500eMC                             or flgtyp = 'RPL'
500aAC                             and rustat <> 'R'
500hAC                             and oprplf  = 'Y'
500aAC                   iter
500aA*
500eMC                   when      flgtyp = 'RPL' and rustat = 'R'
500hAC                                            and oprplf = 'Y'
500eMC                             or flgtyp = 'OUT' and rustat = 'O'
500eMC                             or flgtyp = 'MRG' and rustat = 'O'
710aAC                             or flgtyp = 'BXB' and rustat = 'O'
650 DC*                            or flgtyp = 'RPL' and rustat = 'O'
650 MC                             or flgtyp = 'RPL' and (rustat = 'O'
650 AC                                                 or rustat = 'R')
500hAC                                               and oprplf = 'N'
500aA*
500aAC                   eval      ukwhse = ruwhse
500aAC                   eval      ukwhdp = ruwhdp
500aAC                   eval      uklbl# = rulbl#
710bAC                   eval      uktype = rutype
500aA*
500aAC                   eval      $puky  = dsukey
500aA*
500aAC                   eval      wkokyf = dsfkey
500aAC                   eval      wkokyu = dsukey
500aAC     wkounq        chain     workopt                            76
500aA*
500aA*      Update record in work option file.
500aAC                   if        not *in76
500aAC                   eval      wkoopt = ' 1'
500aAC                   eval      wkoerr = *off
500aAC                   update    wkorec
500aA*
500aAC                   else
500aA*
500aA*      Add record to work option file.
500aAC                   eval      wkousr = #user
500aAC                   eval      wkopgm = #prog
500aAC                   eval      wkokyf = dsfkey
500aAC                   eval      wkokyu = dsukey
500aAC                   eval      wkoopt = ' 1'
500aAC                   eval      wkoerr = *off
500aAC                   write     wkorec
500aAC                   endif
500aAC                   endsl
500aAC                   enddo
500aA*
500aAC                   if        cancel = *on
500aAC                   exsr      scr02e
500aAC                   else
500aA*
500aAC                   exsr      scr02i
500aAC                   endif
500aA*
500aAC                   endif
500aA*
500aA*
500aA*  Test for F16 - NOT allowed when department = *ALL.
710bA*                 or selection type = ALL.
710cDC***                if        *inkq and wowhdp = '*ALL '
710cMC                   if        *inkq and
710cMC                             (wowhdp = '*ALL ' or flgtyp = 'ALL')
500aA*
500aAC                   eval      error = *on
710cAC                   If        wowhdp = '*ALL'
500aAC                   eval      errmsg    = 'F16=Select all not allowe'
500aAC                                       + 'd when department = *ALL'
710cAC                   Else
710cAC                   eval      errmsg    = 'F16=Select all not allowe'
710cMC                                       + 'd when select flag = ALL'
710cAC                   EndIf
500aAC                   exsr      zm0105
500aA*
500aAC                   endif
     *
     C     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *          FILEKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain (n) recordu                            79
     *
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
     *                    READ RECORD                   79
GRCaA*
GRCaAC                   if        byRoute
GRCaA /free
GRCaA    dow forever = forever;
GRCaA
GRCaA      if fileToRead = 'RTEHED';
GRCaA        reade (kywhse: '4': ' ') rtehed2;
GRCaA        if %eof(rtehed2);
GRCaA          *in79 = *on;
GRCaA          leavesr;
GRCaA        endif;
GRCaA        fileToRead = 'PIRTRAN';
GRCaA        setll (kywhse: ' ': rh2rhrtid) pirtran4;
GRCaA      endif;
GRCaA
GRCaA      if fileToRead = 'PIRTRAN';
GRCaA        reade (kywhse: ' ': rh2rhrtid) pirtran4;
GRCaA        if %eof(pirtran4);
GRCaA          fileToRead = 'RTEHED';
GRCaA          iter;
GRCaA        endif;
GRCaA        if pt4ptgrp1 <> 'S';
GRCaA          iter;
GRCaA        endif;
GRCaA        fileToRead = 'RUNNER';
GRCaA        setll (kywhse: pt4pttrn#) runner5;
GRCaA      endif;
GRCaA
GRCaA      if fileToRead = 'RUNNER';
GRCaA        reade (kywhse: pt4pttrn#) runner5;
GRCaA        if %eof(runner5);
GRCaA          fileToRead = 'PIRTRAN';
GRCaA          iter;
GRCaA        endif;
GRCaA        if rustat = 'C' or rustat = 'D' or rustat = 'S'
750aA           or rustat = 'L';
GRCaA          iter;
GRCaA        endif;
GRCaA        if wowhdp <> '*ALL' and ruwhdp <> wowhdp;
GRCaA          iter;
GRCaA        endif;
GRCaA        if flgtyp <> 'ALL' and rutype <> kytype;
GRCaA          iter;
GRCaA        endif;
GRCaA      endif;
GRCaA     *in79 = *off;
GRCaA      leave;
GRCaA
GRCaA    enddo;
GRCaA /end-free
GRCaAC                   else
     *
     *    Code to use when we do have a partial key to use.
     *
710bAC                   If        flgtyp <> 'ALL'
     C                   If        wowhdp = '*ALL '
     C     partky2       reade(n)  record                                 79
     C                   Else
     C     partky        reade(n)  record                                 79
     C                   Endif
710bAC                   EndIf

710bAC                   If        flgtyp = 'ALL'
710bAC     partky3       reade(n)  record                                 79
710bAC                   EndIf

GRCaAC                   endif

     C                   if        not *in79
     C                   if        rustat = 'C'
     C                             or rustat = 'D'
720bAC                             or rustat = 'S'
750aAC                             or rustat = 'L'
     C                   goto      try1
     C                   endif
     *
710bAC                   If        flgtyp = 'ALL'
710bAC                   If        wowhdp <> '*ALL' and
710bAC                             wowhdp <> ruwhdp
710bAC                   goto      try1
710bAC                   EndIf
710bAC                   EndIf
     C                   endif
     *
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
GRCaA*
GRCaAC                   if        byRoute
GRCaA /free
GRCaA    dow forever = forever;
GRCaA
GRCaA      if fileToRead = 'RTEHED';
GRCaA        readpe (kywhse: '4': ' ') rtehed2;
GRCaA        if %eof(rtehed2);
GRCaA          *in79 = *on;
GRCaA          leavesr;
GRCaA        endif;
GRCaA        fileToRead = 'PIRTRAN';
GRCaA        setgt (kywhse: ' ': rh2rhrtid) pirtran4;
GRCaA      endif;
GRCaA
GRCaA      if fileToRead = 'PIRTRAN';
GRCaA        readpe (kywhse: ' ': rh2rhrtid) pirtran4;
GRCaA        if %eof(pirtran4);
GRCaA          fileToRead = 'RTEHED';
GRCaA          iter;
GRCaA        endif;
GRCaA        if pt4ptgrp1 <> 'S';
GRCaA          iter;
GRCaA        endif;
GRCaA        fileToRead = 'RUNNER';
GRCaA        setgt (kywhse: pt4pttrn#) runner5;
GRCaA      endif;
GRCaA
GRCaA      if fileToRead = 'RUNNER';
GRCaA        readpe (kywhse: pt4pttrn#) runner5;
GRCaA        if %eof(runner5);
GRCaA          fileToRead = 'PIRTRAN';
GRCaA          iter;
GRCaA        endif;
GRCaA        if rustat = 'C' or rustat = 'D' or rustat = 'S'
750aA          or rustat = 'L';
GRCaA          iter;
GRCaA        endif;
GRCaA        if wowhdp <> '*ALL' and ruwhdp <> wowhdp;
GRCaA          iter;
GRCaA        endif;
GRCaA        if flgtyp <> 'ALL' and rutype <> kytype;
GRCaA          iter;
GRCaA        endif;
GRCaA      endif;
GRCaA     *in79 = *off;
GRCaA      leave;
GRCaA
GRCaA    enddo;
GRCaA /end-free
GRCaAC                   else
     *
     *    Code to use when we do have a partial key to use.
     *
710bAC                   If        flgtyp <> 'ALL'
     C                   If        wowhdp = '*ALL '
     C     partky2       readpe(n) record                                 79
     C                   Else
     C     partky        readpe(n) record                                 79
     C                   Endif
710bAC                   EndIf
     *
710bAC                   If        flgtyp = 'ALL'
710bAC     partky3       readpe(n) record                                 79
710bAC                   EndIf

GRCaAC                   endif

     C                   if        *in79 <> *on
     C                   if        rustat = 'C'
     C                             or rustat = 'D'
720bAC                             or rustat = 'S'
750aAC                             or rustat = 'L'
710cD*
710cD*    When Flag Type is *OUT, load only flags at Out status.
710cDC*                            or flgtyp = 'OUT'
710cDC*                            and rustat <> 'U'
710cD*
710cD*    When Flag Type is *RPL, omit flags at Out status.
710cDC*                            or flgtyp = 'RPL'
710cDC*                            and rustat = 'U'
710cD*
710cD*    When Flag Type is *BXB, load only flags at Out status.
710cDC*                            or flgtyp = 'BXB'
710cDC*                            and rustat <> 'U'
     C                   goto      try2
     C                   endif
     *
710bAC                   If        flgtyp = 'ALL'
710bAC                   If        wowhdp <> '*ALL' and
710bAC                             wowhdp <> ruwhdp
710bAC                   goto      try2
710bAC                   EndIf
710bAC                   EndIf
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C     rulbl#        chain     label
     C                   if        not %found
     C                   eval      lbitem = ' '
     C                   eval      lblbl# = 0
     C                   eval      lbrte  = ' '
     C                   eval      lbucod = ' '
     C                   endif
     *
     C     keyit         chain     piritem
     C                   if        not %found
     C                   eval      itdesc = ' '
     C                   eval      itpdsc = ' '
     C                   endif
VIP A*
VIP AC                   if        client = VIP
VIP A*      Retrieve item description for special order item#.
VIP AC                   if        lbitem = '9999999999'
VIP AC                   exsr      zzgetom
VIP AC                   endif
VIP A*
VIP AC                   endif
     *
     C     keyrh         chain     rtehed
     C                   if        not %found
     C                   eval      rhrte = ' '
     C                   endif
     *
     *         Load View 1 fields.
     C                   eval      w1whdp = ruwhdp
     C                   eval      w1item = lbitem
VIP A*
VIP AC                   select
VIP AC                   when      client = VIP
VIP A*
VIP AC                   if        lbitem = '9999999999'
VIP AC                   eval      w1desc = omodsc
VIP AC                   else
VIP AC                   eval      w1desc = itdesc
VIP AC                   endif
VIP A*
VIP AC                   other
VIP A*
     C                   eval      w1desc = itdesc
VIP AC                   endsl
VIP A*
730aAC                   eval      w5desc = itdesc
     C                   eval      w1qyso = ruqyso
     C                   eval      w1ucod = lbucod
720cAC                   eval      w1rte  = rhrte

      *----------------------------------------------------------------
520 A*  Check Loader merged items exception file to see if flag
520 A*  to be displayed was created by the merged items pallet
520 A*  process. If true, get exception code found in record and
520 A*  display it on screen for the flag runner to be able to
520 A*  identify this type of flag as high priority.
520 AC                   eval      w1sm = ' '
520 AC     plkey         setll     ldrpltq3
520 AC     plkey         reade     ldrpltq3                               75
520 AC                   dow       *in75 = *off
520 AC*
520 AC     lpscnq        ifeq      *zeros
520 AC     lpstat        ifne      'F'
520 AC     lpstat        andne     ' '
520 A*  Lpstat='F' means flag was created by a selector, do not
520 A*  display blinking status, display it only on loader flags.
520 AC                   eval      w1sm = lpstat
520 AC                   seton                                        31
520 AC                   leave
520 AC                   endif
520 AC                   endif
520 AC*
520 AC     plkey         reade     ldrpltq3                               75
520 AC                   enddo
      *----------------------------------------------------------------
     C                   select
     C                   when      rustat = 'O'
     C                   eval      w1stat = sts01
     *
     C                   when      rustat = 'P'
     C                   eval      w1stat = sts02
     *
     C                   when      rustat = 'C'
     C                   eval      w1stat = sts03
     *
500 AC                   when      rustat = 'R'
500 AC                   eval      w1stat = sts05
     *
750aAC                   when      rustat = 'L'
750aAC                   eval      w1stat = sts06
     *
     C                   other
     C                   eval      w1stat = *blanks
     *
     C                   endsl
     *
     *         Load View 2 fields.
     C                   eval      w2item = lbitem
     C                   eval      w2disp = lbdisp
     C                   eval      w2lbl# = rulbl#
     C                   eval      w2otrn = ruotrn
     C                   eval      w2trn# = rutrn#
     C                   eval      w2rte  = rhrte
     C                   eval      w2rtid = lbrte
710bA /Free
710bA         Eval W2TYPE = *blanks;
710bA       Select;
710bA         When rutype = 'R' or
710bA              rutype = 'N';
710bA           Eval W2TYPE = 'RPL';
710bA         When rutype = 'U';
710bA           Eval W2TYPE = 'OUT';
710bA         When rutype = 'M';
710bA           Eval W2TYPE = 'MRG';
710bA         When rutype = 'B';
710bA           Eval W2TYPE = 'BXB';
710bA         Other;
710bA       EndSL;
710bA /End-Free
     *
     *         Load View 3 fields.
     C                   eval      w3item = lbitem
650aA*
650aA*         Load View 4 fields.
650aAC     ruotrn        chain     pirtran
650aAC                   if        %found(pirtran)
650aAC                   if        ptemp# > 0
650aAC                   eval      $emp# = ptemp#
650aAC                   call      'GETEMPL'     getemplp
     C                   eval      w4empnam = %trim(%editc(ptemp#:'4')) +
     C                             ' ' + %trim($lnam) +
     C                             ', ' + %trim($fnam)
650aAC                   endif
730aAC                   select
730aAC                   when      ptstat = '1'
730aAC                   eval      w5otrns = 'OPN'
730aAC                   when      ptstat = '2'
730aAC                   eval      w5otrns = 'STR'
730aAC                   when      ptstat = '3'
730aAC                   eval      w5otrns = 'END'
730aAC                   when      ptstat = '4'
730aAC                   eval      w5otrns = 'CLS'
730aAC                   when      ptstat = '8'
730aAC                   eval      w5otrns = 'INT'
730aAC                   other
730aAC                   eval      w5otrns = ptstat
730aAC                   endsl
650aAC                   else
650aAC                   eval      w4empnam = *blanks
730aAC                   eval      w5otrns = ' '
650aAC                   endif
     C                   eval      w4lbl# = rulbl#
     C                   eval      w4item = lbitem
     C                   eval      w4rte  = rhrte
     C                   eval      w4rtid = lbrte
GSC A*
GSC A*         Load View 4 fields.
GSC AC                   select
GSC AC                   when      client = gsc
GSC A*
GSC AC     keyal3        chain     ordlbl3
GSC AC                   if        not %found(ordlbl3)
GSC AC                   eval      w4htr# = 0
GSC AC                   else
GSC AC                   eval      w4htr# = alhtr#
GSC AC                   endif
GSC A*
GSC AC     keyoh         chain     ordh
GSC AC                   if        not %found(ordh)
GSC AC                   eval      w4cord = 0
GSC AC                   eval      w4cust = 0
GSC AC                   eval      w4cnam = ' '
GSC AC                   eval      w4deld = 0
GSC AC                   else
GSC AC                   eval      w4cord = ohcord
GSC AC                   eval      w4cust = ohcust
GSC AC                   eval      w4cnam = ohcnam
GSC AC                   testn                   ohdeld               4141
GSC AC                   if        *in41 = *on
GSC AC                   move      ohdeld        w4deld
GSC AC                   else
GSC AC                   eval      w4deld = 0
GSC AC                   endif
GSC AC                   eval      w4stat = w1stat
GSC AC                   endif
GSC A*
GSC AC                   endsl

     *  Convert datestamp to date/time output fields.

     C                   If        ruodts <> dftstamp
     C                   move      ruodts        datestamp
     C                   move      ruodts        timestamp

     *  Load Open Status date/time fields.

     C     *mdy          move      datestamp     w3opnd
     C                   eval      w3opnt = timestamp
     C                   Else
     C                   eval      w3opnd = 0
     C                   eval      w3opnt = *loval
     C                   Endif

500fA*  Convert datestamp to date/time output fields.
500fA
500fAC                   If        rurdts <> dftstamp
500fAC                   move      rurdts        datestamp
500fAC                   move      rurdts        timestamp
500fA
500fA*  Load Replenished date/time fields.
500fA
500fAC     *mdy          move      datestamp     w3rpld
500fAC                   eval      w3rplt = timestamp
500fA
500fAC                   Else
500fAC                   eval      w3rpld = 0
500fAC                   eval      w3rplt = *loval
500fAC                   Endif

     *  Convert datestamp to date/time output fields.

     C                   If        rupdts <> dftstamp
     C                   move      rupdts        datestamp
     C                   move      rupdts        timestamp

     *  Load Printed Status date/time fields.

     C     *mdy          move      datestamp     w3prtd
     C                   eval      w3prtt = timestamp
     C                   Else
     C                   eval      w3prtd = 0
     C                   eval      w3prtt = *loval
     C                   Endif

500fD*  Convert datestamp to date/time output fields.

500fDC*                  If        rucdts <> dftstamp
500fDC*                  move      rucdts        datestamp
500fDC*                  move      rucdts        timestamp

500fD*  Load Close Status date/time fields.

500fDC*    *mdy          move      datestamp     w3clsd
500fDC*                  eval      w3clst = timestamp
500fDC*                  Else
500fDC*                  eval      w3clsd = 0
500fDC*                  eval      w3clst = *loval
500fDC*                  Endif
     *
720aA* If this is a Merge runner set color indicator if applicable

720aA /free
720aA
720aA    *in32 = *off;
720aA   hldi32 = *off;
720aA    *in33 = *off;
720aA   hldi33 = *off;
720aA    *in34 = *off;
720aA   hldi34 = *off;

720aA   if rutype = 'M';
720aA     chain (lbwhse: lbctr#) runner6;

720aA  // If Merge runner and a runner exists for its child:
720aA  //   If the child status is P: yellow
720aA  //   If the child status is O or R: red
720aA  //   If the child status is C and runner type is U: pink

720aA     if %found;
720aA       if r6Rustat = 'P';
720aA          *in32 = *on;
720aA         hldi32 = *on;
720aA       endif;
720aA       if r6Rustat = 'O' or r6Rustat = 'R';
720aA          *in33 = *on;
720aA         hldi33 = *on;
720aA       endif;
720aA       if r6Rustat = 'C' and r6Rutype = 'U';
720aA          *in34 = *on;
720aA         hldi34 = *on;
720aA       endif;

720aA  // If Merge runner and no runner exists for its child:
720aA  //   If the trans status is Open or Started for the child
720aA  //   (lbtype O rec) make the line yellow

720aA     else;
720aA
720aA  // Gotta get label rec for the child so hold onto the
720aA  // label# of the parent so you can reposition back to it
720aA       holdlab = lblbl#;
720aA       lbtrn# = 0;
720aA       chain (lbctr#) label;
720aA       chain (lbtrn#) pirtran;
720aA       if %found(pirtran) and ptstat <= '2';
720aA         *in32 = *on;
720aA         hldi32 = *on;
720aA       endif;
720aA  // Reposition back to the parent label rec
720aA       chain (holdlab) label;

720aA     endif;

720aA   endif;

720aA /end-free

     C                   endsr
VIP A*
VIP A*----------------------------------------------------------------
VIP A*
VIP A*  ZZGETOM  Get Order Detail Misc. record.
VIP A*
VIP AC     zzgetom       begsr
VIP A*
VIP AC     omkey         chain     orddm
VIP AC                   if        not %found(orddm)
VIP AC                   eval      omodsc = ' '
VIP AC                   eval      omcbox = 'N'
VIP AC                   eval      omcexp = 'N'
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base   = ' '
VIP AC                   eval      vipdm1_ompckm = 0
VIP AC                   eval      vipdm1_omwtiw = 0
VIP AC                   eval      vipdm1_omcbec = 0
VIP AC                   endsl
VIP A*
VIP AC                   else
VIP A*
VIP AC                   select
VIP AC                   when      client = VIP
VIP AC                   eval      vipdm1_base = ommsc1
VIP AC                   endsl
VIP AC                   endif
VIP A*
VIP AC                   endsr
740aA*
740aA*----------------------------------------------------------------
740aA*
740aA*  ZZGETDFTRUNNER  Get Default Runner Employee Number.
740aA*
740aAC     zzgetdftrunnerbegsr
740aA*
740aAC                   call      'GETUSER'
740aAC**740bD            parm      'RUNNER'      #user
740bMC                   parm      'RUNNER'      #user_r          10
740aAC                   parm      0             #whse             3 0
740aAC                   parm      0             #emp#             5 0
740aAC                   parm                    #fnam            15
740aAC                   parm                    #init             1
740aAC                   parm                    #lnam            20
740aAC                   parm                    #whdp             5
740aAC                   parm                    #styp             1
740aAC                   parm                    #shft             6
740aAC                   parm                    #crew             6
740aAC                   parm      0             #nhrs             3 1
740aAC                   parm                    #rtn              8
740aA*
740aAC                   endsr
417aA*
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZGETOP  Get General Picking Options record.
417aA*
417aAC     zzgetop       begsr
417aA*
417aAC                   MOVE      '*GENPICK'    opcode
417aA*
417aAC     opkey         chain     options
417aAC                   if        not %found(options)
417aAC                   eval      opclrf = 'Y'
417aAC                   eval      oprnrm = 'N'
417aAC                   else
417aAC                   movel     opdata        opdta1
417aAC                   endif
417aA*
417aAC                   endsr
500iA*
500iA*----------------------------------------------------------------
500iA*
500iA*  ZZGETRPT  Get Report/Label device defaults.
500iA*
500iAC     zzgetrpt      begsr
500iA*
500iAC                   call      'GETRPT'
500iAC                   parm      '*DEVFORM'    $CMD
500iAC                   parm                    $lprt
500iAC                   parm      kywhse        $whse
500mDC*                  parm      ' '           $styp
500mMC                   parm                    $styp
500mDC*                  parm      ' '           $whdp
500mMC                   parm                    $whdp
500iAC                   parm      ' '           $desc
500iAC                   parm      ' '           $dev
500iAC                   parm      ' '           $form
500iA*
500iAC                   if        $dev = ' '
500iAC                   eval      $dev  = '*JOB      '
500iAC                   eval      $form = '*STD      '
500iAC                   endif
500iA*
500iAC                   endsr
500hA*
500hA*----------------------------------------------------------------
500hA*
500hA*  ZZGETRUOP  Get Runner Options record.
500hA*
500hAC     zzgetruop     begsr
500hA*
500hAC                   eval      opcode = '*RUNNER '
500hA*
500hAC     opkey         chain     options
500hAC                   if        not %found(options)
500hAC                   eval      opclrf = 'Y'
500hAC                   else
500hAC                   movel     opdata        oprdta
500hAC                   endif
500hA*
500hAC                   endsr
417aA*
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for main file.
     *
     C     fileky2       klist
     C                   kfld                    ruwhse
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    ruwhse
500cAC                   kfld                    kytype
     C                   kfld                    ruwhdp
     C                   kfld                    rulbl#
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
500cAC                   kfld                    ukwhse
710bDC**                 kfld                    kytype
710bMC                   kfld                    uktype
     C                   kfld                    uklbl#
     *
     *  Define partial key for main file (if needed).
     *
500cAC     *like         define    rutype        kytype
     C     partky        klist
     C                   kfld                    kywhse
500cAC                   kfld                    kytype
     C                   kfld                    kywhdp
     C     partky2       klist
     C                   kfld                    kywhse
500cAC                   kfld                    kytype
710bAC     partky3       klist
710bAC                   kfld                    kywhse
VIP A*
VIP A*   Full ORDDM key
VIP AC     omkey         klist
VIP AC                   kfld                    kywhse
VIP AC                   kfld                    lbord
VIP AC                   kfld                    lbseq
VIP AC                   kfld                    lbitem
GSC A*
GSC A*  Define FULL key for ORDH file.
GSC A*
GSC AC     keyoh         klist
GSC AC                   kfld                    kywhse
GSC AC                   kfld                    lbord
GSC A*
GSC A*  Define Partial key for ORDLBL3 file.
GSC A*
GSC AC     keyal3        klist
GSC AC                   kfld                    kywhse
GSC AC                   kfld                    ruotrn
     *
     *  Define FULL key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    lbitem
     *
     *  Define FULL key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    kywhse
     C                   kfld                    lbrte
500cA*
500cA*  Define key for RUNNER file.
500cA*
500cAC     keyru         klist
500cAC                   kfld                    kywhse
500cAC                   kfld                    kytype
500cAC                   kfld                    rulbl#
500cA*
500cAC     keyruA        klist
500cAC                   kfld                    kywhse
710bDC**                 kfld                    kytype
710bMC                   kfld                    uktype
500cAC                   kfld                    uklbl#
     *
     *  Define key for RUNNER1 file.
     *
     C     rukey         klist
     C                   kfld                    kywhse
500cAC                   kfld                    kytype
     C                   kfld                    svtrn#
     *
     *  Define key for RUNNER1 file.
     *
     C     rukey1        klist
     C                   kfld                    kywhse
500cAC                   kfld                    kytype
     C                   kfld                    wwtrn#
     *
720aA*  Define key for RUNNER6 file.
720aA*
720aAC     childKey      klist
720aAC                   kfld                    lbwhse
720aAC                   kfld                    lbctr#
     *
     *  Setup option and command display lines.
     *
GSC AC                   select
GSC AC                   when      client = gsc
GSC AC                   eval      view = 4
GSC AC                   eval      maxvw = 4
GSC AC                   eval      optln1 = optln(1)
GSC A*     Load replacement lines for 4th view.
GSC AC                   eval      cmdln(2) = cmdlna(1)
GSC AC                   eval      cmdln(6) = cmdlna(2)
GSC A*     Load replacement lines for 4th view.
GSC AC                   eval      cmdln1 = cmdln(7)
GSC AC                   eval      cmdln2 = cmdln(8)
ADW A*
ADW A*     Set initial view to 2nd view.
ADW AC                   when      client = andrews
ADW AC                   eval      view = 2
ADW AC                   eval      maxvw = 3
ADW AC                   eval      optln1 = optln(1)
ADW AC                   eval      cmdln1 = cmdln(3)
ADW AC                   eval      cmdln2 = cmdln(4)
GSC AC                   other
     C                   eval      view = 1
650aDC***                eval      maxvw = 3
730aDC**                 eval      maxvw = 4
730aMC                   eval      maxvw = 5
     C                   eval      optln1 = optln(1)
730aA*     Populate cmdln() with versions for 5 views
730aAC                   for       i = 1 to 10
730aAC                   eval      cmdln(i) = cmdln5(i)
GRCaAC                   endfor
730aA*     Start with view 1
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
GSC AC                   endsl
cRCaA*
GaCaA*     Start Greco at view 5
     *
GRCaAC                   if        client = greco
GRCaAC                   eval      view = 5
GRCaAC                   eval      cmdln1 = cmdln(9)
GRCaAC                   eval      cmdln2 = cmdln(10)
GRCaAC                   endif
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     *   Verify warehouse and get description.
     *
     C                   eval      wowhse = *blanks
     C                   eval      $lcmd  = '*VERIFY '
     C                   eval      ruwhse = #whse
     C                   eval      kywhse = #whse
     C                   eval      $lwhse = #whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn  = '*PGMQ   '
     C                   eval      wowhse = *blanks
     C                   eval      error  = *on
     C                   eval      *in21  = *on
     C                   eval      *in01  = *on
     C                   eval      #msgk  = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $fwhse = kywhse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
     C                   endif
     *
     *         Get department description.
     *
     C                   eval      $lwhse = kywhse
530 A*
530 A*      Default to *ALL for department when user not enrolled.
530 AC                   if        #whdp = ' '
DRY AC                             or client = Dairyland
GFS AC                             or client = Getfresh
SOFaAC                             or client = Sofo
GLPaAC                             or client = GreenLeaf
ISPaAC                             or client = Isupply
FPRaAC                             or client = FoodPro
JSLaAC                             or client = JSilvert
ADFaAC                             or client = AandDFoods
BADaAC                             or client = BigApple
FSHaAC                             or client = Fischr
MQSaAC                             or client = Marques
ACCaAC                             or client = ACC
VFIaAC                             or client = Vitco
SWTaAC                             or client = SWT
CFI AC                             or client = Colony
530 AC                   eval      wowhds = ' '
530 AC                   eval      wowhds = title03
530 AC                   eval      wowhdp = '*ALL '
530 AC                   eval      ruwhdp = '*ALL '
530 AC                   eval      kywhdp = '*ALL '
530 AC                   eval      rulbl# = 0
530 A*
530 AC                   else
     C                   eval      $lwhdp = #whdp
     C                   eval      kywhdp = #whdp
     C                   eval      wowhdp = #whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     *
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   movel     $lerm         wowhds
     C                   endif
     C                   endif
530 A*
530 AC                   endif
GRCaA*
GRCaA*    For Greco, turn on flag to display by Route
GRCaA*
GRCaA /free
GRCaA      if client = greco;
GRCaA        byRoute = *on;
GRCaA        fileToRead = 'RTEHED';
GRCaA        setll (kywhse: '4': ' ') rtehed2;
GRCaA      else;
GRCaA        byRoute = *off;
GRCaA      endif;
GRCaA /end-free
530 A*
     *
     C                   eval      dftstamp = *loval
500eMC                   eval      flgtyp     = 'RPL'
500cAC                   eval      kytype     = 'N'
500eMC                   eval      holdflgtyp = 'RPL'
     C                   exsr      clrsch
     C                   exsr      scr01i
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZABORT  Abort runner pick list transaction created.
     *
     C     zzabort       begsr
     *
     C                   move      *off          error
     *
     C     rukey         setll     Runner1
     C                   Dow       Forever = Forever
     C     rukey         reade     Runner1
     C                   Select
     C                   When      %eof(runner1)
     C                   Leave
     *
     C                   Other
     *         Set item back to Open status.
     C                   eval      Rustat = 'O'
     C                   eval      Rupdts = *loval
     C                   Update    Rurec1
     C                   If        %Error
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      errmsg = DESC(8) + ' ' +
     C                               %trim(%editc(rulbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
     C                   Endsl
     C                   Enddo
     *
     *         Close Runner Transaction.
     *
     C                   If        error = *off
     *
     C                   Call      @adjtr2
     C                   Parm      '*CLOSE    '  $Pcmd2           10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      svtrn#        $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      kywhse        $Pwhse            3 0
     C                   Parm      ' '           $pwhdp            5
     C                   Parm      ' '           $pstyp            1
     C                   Parm      0             $pcube            9 3
     C                   Parm      0             $pswgt            9 2
     C                   Parm      0             $ppcs             5 0
     C                   Parm      0             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      ' '           $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
500iA****                Parm      uscode        $puser           10
500iAC                   Parm      $code         $puser
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   if        $Prtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKSTAT   Check status of Runner Flag Entry.
     *
     C     zzckstat      begsr
     *
     C     uklbl#        chain     Label
     C                   Select
     C                   When      not %found(Label)
500bAC                             and $pcmd  <> '*DELETE'
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Label)
     *
     *    Label not flagged yet.
     C                   Select
     C                   When      Lbvrfy <> 'F'
     C                             and Lbvrfy <> 'I'
500bAC                             and $pcmd  <> '*DELETE'
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0105
     *
     *    Label already closed.
     C                   When      Lbstat = 'C'
500bAC                             and $pcmd <> '*DELETE'
CBIbAC                             and client <> cheney
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     desc(5)       errmsg
     C                   exsr      zm0105
     *
     C                   Endsl
     *
     *    Retrieve Flag file record.
500bAC                   if        $pcmd <> '*DELETE '
500cDC*    rulbl#        chain (n) Runner
500cMC     keyru         chain (n) Runner
     C                   Select
     C                   When      not %found(Runner)
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     desc(4)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Runner)
     *
     *    Flag record has been picked.
     C                   Select
     C                   When      Rustat = 'P'
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   if        $pcmd = '*DELETE '
     C                   movel     desc(14)      errmsg
     C                   else
     C                   movel     desc(7)       errmsg
     C                   endif
     C                   exsr      zm0105
     *
     *    Flag record already closed.
     C                   When      Rustat = 'C'
750aAC                             or Rustat = 'L'
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   if        $pcmd = '*DELETE '
     C                   movel     desc(13)      errmsg
     C                   else
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   exsr      zm0105
500 A*
500 A*    Flag record at open status.
500 AC                   When      Rustat = 'O' and
500 AC                             $pcmd <> '*DELETE '
500eMC                             and flgtyp = 'RPL'
500hAC                             and oprplf = 'Y'
500 AC                   eval      error  = *on
500 AC                   eval      cancel = *on
500 AC                   movel     desc(15)      errmsg
500 AC                   exsr      zm0105
     *
720aA*    Editing for flag type M(merge)
720aAC                   When      Rutype = 'M'
720aAC     childKey      chain     runner6
720aA*      Gotta get label rec for the child so hold onto the
720aA*      label# of the parent so you can reposition back to it
720aAC                   eval      holdlab = lblbl#
720aAC     lbctr#        chain     label
720aAC                   if        %found(runner6)
720aA*      A runner flag exists for the child record with a flag
720aA*      type of blank, N or U and a status of O-Open, P-Printed
720aA*      or R-replenishment. The child flag must be closed before
720aA*      proceeding.
720aAC                   if            (r6rutype = ' '
720aAC                              or  r6rutype = 'N'
720aAC                              or  r6rutype = 'U')
720aAC                             and (r6rustat = 'O'
720aAC                              or  r6rustat = 'P'
720aAC                              or  r6rustat = 'R')
720aAC                   eval      error  = *on
720aAC                   eval      cancel = *on
720aAC                   select
720aAC                   when      r6rutype = ' ' or r6rutype = 'U'
720aAC                   eval      flgtypDesc = 'OUT'
720aAC                   when      r6rutype = 'N'
720aAC                   eval      flgtypDesc = 'RPL'
720aAC                   endsl
720aAC                   eval      errmsg = %trimr(flgtypDesc)
720aAC                                    + ' for '
720aAC                                    + %trimr(lbitem)
720aAC                                    + ' in '
720aAC                                    + %trimr(lbdisp)
720aAC                                    + ' not closed'
720aAC                   exsr      zm0105
720aAC                   endif
720aAC                   else
720aA*      PIR pick not ended for child transaction. No runner
720aA*      flag exists for the child record and the trans is at
720aA*      Open or Started status. It must be ended or closed
720aA*      before proceeding.
720aAC     lbtrn#        chain     pirtran
720aAC                   if        %found(pirtran) and ptstat <= '2'
720aAC                   eval      error  = *on
720aAC                   eval      cancel = *on
720aAC                   eval      errmsg = 'PIR pick not ended for trans '
720aAC                                    + %Trim(%editc(pttrn#:'Z'))
720aAC                   exsr      zm0105
720aAC                   endif

720aAC                   endif
720aA*      Reposition back to the parent label rec
720aAC     holdlab       chain     label
     *
500 D*    Flag record at open status.
500cM*    Flag record at 'R'eplenished for *RPL and 'O'pen
500cA*    for *OUT, *MRG.
     C                   Other
     *
     C                   Endsl
     *
     C                   Endsl
     *
500bAC                   Endif
500bA*
     C                   Endsl
     *
     C                   Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C**                 clear                   ruwhse
     C**                 clear                   ruwhdp
     C**                 clear                   rulbl#
     *
     *   Initialize unique key (DSUKEY)
     *
     C**                 clear                   ukwhse
     C**                 clear                   ukwhdp
     C**                 clear                   uklbl#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     *
     C                   eval      ukwhse = ruwhse
     C                   eval      ukwhdp = ruwhdp
     C                   eval      uklbl# = rulbl#
500cAC                   eval      uktype = rutype
     *
     C                   eval      $pouky = dsukey
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     C                   if        ptinp1 <> 0
     C                   eval      wowhse = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      ruwhse = ptinp1
     C                   eval      kywhse = ruwhse
     C                   eval      ruwhdp = *blanks
510 AC                   eval      rulbl# = *zeros
     C                   eval      wowhse = %editc(ptinp1:'X') + ' - '
     C                             + %trim($lerm)
     C                   eval      ptinp1 = *zeros
417aA*
417aA*  Get picking options for warehouse.
417aA****500hA           exsr      zzgetop
500hAC                   exsr      zzgetruop
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *      Verify department entry.
     *
     C                   if        ptinp2 <> '  '
     C                   eval      wowhdp = ptinp2
     C                   eval      wowhds = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = kywhse
     C                   eval      $lwhdp = ptinp2
     *
     C                   if        ptinp2 <> '*ALL '
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   endif
     *
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      wowhdp = ptinp2
     *
     *    If all departments selected, then clear input field so that
     *    we will be positioned to top of the list.
     *
     C                   if        ptinp2 = '*ALL'
     C                   eval      ptinp2 = ' '
     C                   eval      wowhds = ' '
     C                   eval      wowhds = title03
     C                   else
     C                   movel     $lerm         wowhds
     C                   endif
     C                   eval      ruwhdp = ptinp2
     C                   eval      kywhdp = ptinp2
     C                   eval      rulbl# = 0
     C                   eval      ptinp2 = *blanks
710cAC                   eval      holdflgtyp = *blanks
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to label number.
     *
     C                   if        ptinp3 <> 0
     C                   eval      rulbl# = ptinp3
     C                   eval      kylbl# = ptinp3
     C                   eval      ptinp3 = 0
     C                   eval      repos = *on
710cA /Free
710cA           If flgtyp = 'ALL';
710cA              SetLL (ruwhse:kylbl#) Runner6;
710cA              Read Record6;
710cA              If Not %Eof(Runner6);
720aD    //         Eval kytype = rutype;
720aM               kytype = r6Rutype;
720aA               ruwhse = r6Ruwhse;
720aA               rutype = r6Rutype;
720aA               ruwhdp = r6Ruwhdp;
720aA               rulbl# = r6Rulbl#;
720aA               ruotrn = r6Ruotrn;
720aA               rutrn# = r6Rutrn#;
720aA               rudisp = r6Rudisp;
720aA               ruoqys = r6Ruoqys;
720aA               ruqyso = r6Ruqyso;
720aA               ruqyfd = r6Ruqyfd;
720aA               rustat = r6Rustat;
720aA               rurdts = r6Rurdts;
720aA               ruodts = r6Ruodts;
720aA               rupdts = r6Rupdts;
720aA               rucdts = r6Rucdts;
710cA              EndIf;
710cA           EndIf;
710cA /End-Free
     C                   endif
500aA*
500aA*  See if user changed Flag Type selection.
500aA*
500aAC                   if        flgtyp <> holdflgtyp
500aAC                   eval      holdflgtyp = flgtyp
710cAC                   eval      rulbl# = 0
710cAC                   eval      rutype = ' '
500cA*
500cA*    Set Flag Type code based on user entry.
500cAC                   select
500CA*      Flag Type is Normal.
500eMC                   when      flgtyp = 'RPL'
500cAC                   eval      kytype = 'N'
500cA*      Flag Type is Out.
500eMC                   when      flgtyp = 'OUT'
500cAC                   eval      kytype = 'U'
500cA*      Flag Type is Merge.
500eMC                   when      flgtyp = 'MRG'
500cAC                   eval      kytype = 'M'
710aA*      Flag Type is Box Breaker
710aaC                   when      flgtyp = 'BXB'
710aAC                   eval      kytype = 'B'
710bA*      Flag Type is ALL flags
710baC                   when      flgtyp = 'ALL'
710bAC                   eval      kytype = ' '
500cAC                   endsl
500cA*
500aAC                   eval      ruwhdp = wowhdp
500aAC                   eval      kywhdp = wowhdp
500aAC                   if        kylbl# = 0
500aAC                   eval      rulbl# = 0
500aAC                   endif
500aAC                   eval      repos = *on
500aAC                   endif
     *
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
GRCaA*
GRCaA*    For byRoute, only honoring *TOP. Not honoring *BOTTOM because
GRCaA*    of the logic that would be needed.
GRCaA*
GRCaA /free
GRCaA      if byRoute;
GRCaA        if $pocmd = '*TOP';
GRCaA          fileToRead = 'RTEHED';
GRCaA          setll (kywhse: '4': ' ') rtehed2;
GRCaA        endif;
GRCaA        leavesr;
GRCaA      endif;
GRCaA /end-free
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
     *
     C                   if        wowhdp = '*ALL '
     C     partky2       setll     record
     C                   else
     C     partky        setll     record
     C                   endif

710bAC                   If        Flgtyp = 'ALL'
710bAC     partky3       SetLL     record
710bAC                   EndIf
     *
     C                   else
     *
     C                   if        $pocmd = '*BOTTOM'
     *
     C                   if        wowhdp = '*ALL '
     C     partky2       setgt     record
     C                   else
     C     partky        setgt     record
     C                   endif

710bAC                   If        Flgtyp = 'ALL'
710bAC     partky3       SetGT     record
710bAC                   EndIf
     *
     C                   endif
     C                   endif
     *
     C                   endsr
417aA*
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZSNDMSG Position to record
417aA*
417aAC     zzsndmsg      begsr
417aA*
417aA*    SNDBRKMSGU MSGTXT(msg text) USRPRF(user id) msgtyp(*info)
417aA*
417aAC                   eval      qcmd = %trim(cmdsndm(1)) + %trim(sts04) +
500iAC                             %trim(cmdsndm(2)) + %trim($code) +
417aAC                             cmdsndm(3)
417aA*
417aAC                   call (e)  'QCMDEXC'
417aAC                   parm                    qcmd            200
417aAC                   parm      200           qlen             15 5
417aA*
417aAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPDSTAT   Update Flag Entry Status.
     *
     C     zzupdstat     begsr
     *
     C                   move      *off          error
     *
500cDC*    uklbl#        chain     Runner
500cMC     keyruA        chain     Runner
     C                   If        Not %found(Runner)
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     *
     C                   else
     *
     *         Set item to Picked status.
     C                   eval      Rustat = 'P'
     C                   eval      Rutrn# = Svtrn#
     C                   eval      Rupdts = Currstamp
     *
     C                   Update    Recordu
     C                   If        %Error
     C                   eval      error  = *on
     C                   eval      cancel = *on
     C                   eval      errmsg = desc(8) + ' ' +
     C                               %trim(%editc(rulbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
     C                   Endif
     *
     C     endupdsts     endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDWCK1   Window 1 edit check
     *
     C     zzwdwck1      Begsr
     C                   move      *off          error1
     *
     *  Verify employee number entered.
     *
     C                   If        wwemp# <= 0
     C                   move      *on           error1
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     DESC(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     C                   If        wwemp# >  0
500iA **   wwemp#        chain     Piruser1
500iA **                 Select
500iA **                 When      not %found(Piruser1)
500iAC                   eval      $emp# = wwemp#
500iAC                   call      'GETEMPL'     getemplp
500iAC                   select
500iAC                   when      $rtn = '*ERROR  '
     C                   eval      error1 = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm0105
500iA*
500iA*  if belt printer selected verify if employee is a belt
500iA*  printer user.
500iA*
500iAC                   when      oprlbl = '2' and $bpu <> 'Y'
520aAC                             and $bpu <> ' '
500iAC                   eval      error1 = *on
500iAC                   eval      *in25  = *on
500iAC                   eval      *in05  = *on
500iAC                   eval      errmsg = *blanks
500iAC                   eval      errmsg = desc(9)
500iAC                   exsr      zm0105
500iAC                   endsl
500iAC                   endif
     *
     *  Verify default device
     *
     C                   If        %subst(wwdev:1:1) = '*'
     C                             and wwdev <> '*SYSVAL'
     C                             and wwdev <> '*JOB'
     C                             or  wwdev = *blanks
     C                   eval      error1 = *on
     C                   eval      *in25  = *on
     C                   eval      *in05  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(9)
     C                   exsr      zm1001
     C                   Endif
     *
     *  Verify default form type
     *
     C                   If        %subst(wwform:1:1) = '*'
     C                             and wwform <> '*STD'
     C                             or  wwform = *blanks
     C                   eval      error1 = *on
     C                   eval      *in26  = *on
     C                   eval      *in06  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(10)
     C                   exsr      zm1001
     C                   Endif
     *
     C                   Endsr
500iA*
500iA*----------------------------------------------------------------
500iA*
500iA*  ZZWDWCK1A   Window 1 Edit check - Labels
500iA*
500iAC     zzwdwck1a     Begsr
500iA*
500iA*  Verify default label device
500iA*
500iAC                   If        %subst(wwdev2:1:1) = '*'
500iAC                             and wwdev2 <> '*SYSVAL'
500iAC                             and wwdev2 <> '*JOB'
500iAC                             or  wwdev2 = *blanks
500iAC                   eval      error1 = *on
500iAC                   eval      *in27  = *on
500iAC                   eval      *in07  = *on
500iAC                   eval      errmsg = *blanks
500iAC                   eval      errmsg = desc(9)
500iAC                   exsr      zm1001
500iAC                   Endif
500iA*
500iA*  Verify label default form type
500iA*
500iAC                   If        %subst(wwform2:1:1) = '*'
500iAC                             and wwform2 <> '*STD'
500iAC                             or  wwform2 = *blanks
500iAC                   eval      error1 = *on
500iAC                   eval      *in28  = *on
500iAC                   eval      *in08  = *on
500iAC                   eval      errmsg = *blanks
500iAC                   eval      errmsg = desc(10)
500iAC                   exsr      zm1001
500iAC                   Endif
500iA*
500iAC                   Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDWCK2   Window 2 edit check
     *
     C     zzwdwck2      Begsr
     C                   move      *off          error1
     *
     *  Verify transaction number entered.
     *
     C                   If        wwtrn# <= 0
     C                   move      *on           error1
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     DESC(11)      errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     C                   If        wwtrn# >  0
500kDC*    Rukey1        chain     runner1
500kMC     Rukey1        chain (n) runner1
500nA*
500nA*  Loop, looking for Runner Flags still at Printed status.
500nAC                   dow       rustat <> 'P' and not %eof(Runner1)
710 DC*    Rukey1        reade     runner1
710 MC     Rukey1        reade (n) runner1
500nAC                   enddo
500nA*
     C                   Select
     C                   When      not %found(Runner1) or
     C                             %found(Runner1) and rustat <> 'P'
     C                   eval      error1 = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(12)
     C                   exsr      zm0105
     *
     C                   endsl
     C                   endif
     *
     *  Verify default device
     *
     C                   If        %subst(wwdev:1:1) = '*'
     C                             and wwdev <> '*SYSVAL'
     C                             and wwdev <> '*JOB'
     C                             or  wwdev = *blanks
     C                   eval      error1 = *on
     C                   eval      *in25  = *on
     C                   eval      *in05  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(9)
     C                   exsr      zm1001
     C                   Endif
     *
     *  Verify default form type
     *
     C                   If        %subst(wwform:1:1) = '*'
     C                             and wwform <> '*STD'
     C                             or  wwform = *blanks
     C                   eval      error1 = *on
     C                   eval      *in26  = *on
     C                   eval      *in06  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(10)
     C                   exsr      zm1001
     C                   Endif
     *
     C                   Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDWPROMPT   Window Prompt for Employee number and Printer.
     *
     C     zzwdwprompt   begsr
     *
     C                   eval      error1   = *off
     C                   eval      cancel   = *off
     C                   eval      wdwinuse = '*YES'
     C                   eval      wdwtitle = title01
740aA*
740aAC                   exsr      zzgetdftrunner
740aA*      Default Runner Employee found. Load nbr.
740aAC                   if        #rtn = '*OK'
740aAC                   eval      wwemp#    = #emp#
740aAC                   eval      dftrunner = '*YES'
740bAC                   eval      #user = 'RUNNER    '
740aAC                   else
740aAC                   eval      dftrunner = '*NO '
740aAC                   endif
     *
500jAC                   select
500iAC                   when      client = cheney and oprpck = 'Y'
CBI A*
CBI A*    Set printer defaults.
CBI AC                   select
CBI AC                   when      wowhdp = 'DRY  '
CBI AC                   eval      wwdev = 'LP08     '
CBI A*
CBI AC                   when      wowhdp = 'FRZ  '
CBI AC                             or wowhdp = 'CLR  '
CBI AC                   eval      wwdev = 'LP26       '
CBI A*
CBI AC                   Endsl
CBI AC                   eval      wwform = '*STD      '
     *
500iDC*                  other
500iA*       Print Runner pick list
500iMC                   When         oprpck = 'Y'
500iA*       Print Runner pick labels
500iMC                             or oprlbl = '1'
500iA*
500iAC                   eval         *in40  = *off
     *
417bA*       Retrieve default printer device.
500iA*
500iAC                   select
500iAC                   when      oprpck = 'Y'
500iAC                   eval      $lprt  = 'RU365PR'
500iAC                   when      oprlbl = '1'
500iAC                   eval      $lprt  = 'RU355PR'
500iAC                   endsl
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iA*
417bAC                   call      'GETRPT'
417bAC                   parm      '*DEVFORM'    $CMD              8
500iDC*                  parm      'RU365PR'     $lprt            10
500iMC                   parm                    $lprt            10
417bAC                   parm      kywhse        $whse             3 0
500mDC*                  parm      ' '           $styp             1
500mMC                   parm                    $styp             1
500mDC*                  parm      ' '           $whdp             5
500mMC                   parm                    $whdp             5
417bAC                   parm      ' '           $desc            50
417bAC                   parm      ' '           $dev             10
417baC                   parm      ' '           $form            10
500iA*
417bAC                   if        $dev > ' '
417bAC                   eval      wwdev  = $dev
417bAC                   eval      wwform = $form
417bAC                   else
     C                   eval      wwdev  = '*JOB      '
     C                   eval      wwform = '*STD      '
417bAC                   endif
MQSbAC                   if        client = Marques
MQSbAC                   eval      wwdev = 'MQSRCV1   '
MQSbAC                   endif
CSPaAC                   if        client = coastl
CSPaAC                   time                    csptime
CSPaAC                   if        csptime > 220000 or
CSPaAC                             csptime < 070000
CSPaAC                   eval      wwdev = 'SHORTS    '
CSPaAC                   endif
CSPaAC                   endif
500iA*
500iA*       Runner label on belt printer selected
500iAC                   when      oprlbl  = '2'
500iAC                   eval      *in40   = *on
500iAC                   eval      wwdev   = 'BELTPRINT '
500iAC                   eval      wwform  = '*STD      '
     *
CBI AC                   endsl

500iAC                   eval      svdev  = wwdev
500iAC                   eval      svform = wwform
     *
     *    Write window definition record
     C                   write     window1
     *
     C                   Dow       Forever = Forever
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     C                   exfmt     wdwfmt1
     *
     C                   setoff                                       040506
     C                   setoff                                       242526
500iAC                   setoff                                       2728
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     *   F3 or F12 selected by user.
     C                   when      *inkc = *on
     C                             or *inkl = *on
     C                   eval      cancel = *on
     C                   leave
     *
     *   F5 Refresh selected by user.
     C                   when      *inke = *on
740aAC                   if        dftrunner = '*YES'
740aAC                   eval      wwemp# = #emp#
740aAC                   else
     C                   eval      wwemp# = 0
740aAC                   endif
     *
500iAC                   eval      wwdev   = svdev
500iAC                   eval      wwform  = svform
     *
     *   Enter key pressed. Validate entries.
     C                   Other
     *
     C                   exsr      zzwdwck1
     *
     *   If no errors, proceed with report generation.
     C                   If        Error1 = *off
     C                   leave
     C                   Endif
     *
     C                   Endsl
     C                   Enddo
     *
     C                   eval      wdwinuse = '*NO '
     *
     C     endwdwpmt     endsr
     *
500iA*----------------------------------------------------------------
500iA*  ZZWDWPROMPT2  Window Prompt for Employee number and Printer.
500iA*
500iAC     zzwdwprompt2  begsr
500iA*
500iAC                   eval      error1   = *off
500iAC                   eval      cancel   = *off
500iAC                   eval      wdwinuse = '*YES'
500iAC                   eval      wdwtitle = title01
740aA*
740aAC                   exsr      zzgetdftrunner
740aA*      Default Runner Employee found. Load nbr.
740aAC                   if        #rtn = '*OK'
740aAC                   eval      wwemp#    = #emp#
740aAC                   eval      dftrunner = '*YES'
740bAC                   eval      #user = 'RUNNER    '
740aAC                   else
740aAC                   eval      dftrunner = '*NO '
740aAC                   endif
500iA*
500iAC                   select
500iAC                   when      client = cheney and oprpck = 'Y'
500iA*
500iA*    Set printer defaults.
500iAC                   select
500iAC                   when      wowhdp = 'DRY  '
500iAC                   eval      wwdev = 'LP08     '
500iA*
500iAC                   when      wowhdp = 'FRZ  '
500iAC                             or wowhdp = 'CLR  '
500iAC                   eval      wwdev = 'LP26       '
500iA*
500iAC                   Endsl
500iAC                   eval      wwform = '*STD      '
500iA*
500iA*       Print Runner pick list
500iMC                   Other
500iA*         Allow Label device to be changed.
500iAC                   eval         *in40  = *off
500iA*
500iA*       Retrieve Runner pick list default printer device.
500iAC                   eval      $lprt  = 'RU365PR'
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iAC                   exsr      zzgetrpt
500iAC                   eval      wwdev  = $dev
500iAC                   eval      wwform = $form
500iAC                   endsl
500iA*
500iAC                   select
500iA*       Retrieve Runner pick label default printer device.
500iAC                   when      oprlbl = '1'
500iA*         Allow Label device to be changed.
500iAC                   eval         *in40  = *off
500iAC                   eval      $lprt  = 'RU355PR'
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iAC                   exsr      zzgetrpt
500iAC                   eval      wwdev2  = $dev
500iAC                   eval      wwform2 = $form
500iA*
500iA*       Set Runner Belt default printer device.
500iAC                   when      oprlbl = '2'
500iA*         Protect Label device so that it can't be changed.
500iAC                   eval      *in40 = *on
500iAC                   eval      wwdev2  = 'BELTPRINT '
500iAC                   eval      wwform2 = '*STD      '
500iAC                   endsl

500iAC                   eval      svdev  = wwdev
500iAC                   eval      svform = wwform
500iAC                   eval      svdev2  = wwdev2
500iAC                   eval      svform2 = wwform2
500iA*
500iA*    Write window definition record
500iAC                   write     window1
500iA*
500iAC                   Dow       Forever = Forever
500iA*
500iA*   Overlay screen with error messages
500iA*
500iAC                   exsr      zmdmsg
500iA*
500iAC                   exfmt     wdwfmt3
500iA*
500iAC                   setoff                                       040506
500iAC                   setoff                                       242526
500iAC                   setoff                                       2728
500iA*
500iA*   Initialize error subfile
500iA*
500iAC                   exsr      zmcmsg
500iA*
500iAC                   select
500iA*   F3 or F12 selected by user.
500iAC                   when      *inkc = *on
500iAC                             or *inkl = *on
500iAC                   eval      cancel = *on
500iAC                   leave
500iA*
500iA*   F5 Refresh selected by user.
500iAC                   when      *inke = *on
740aAC                   if        dftrunner = '*YES'
740aAC                   eval      wwemp# = #emp#
740aAC                   else
500iAC                   eval      wwemp# = 0
740aAC                   endif
500iA*
500iAC                   eval      wwdev   = svdev
500iAC                   eval      wwform  = svform
500iAC                   eval      wwdev2  = svdev2
500iAC                   eval      wwform2 = svform2
500iA*
500iA*   Enter key pressed. Validate entries.
500iAC                   Other
500iA*
500iAC                   exsr      zzwdwck1
500iAC                   exsr      zzwdwck1a
500iA*
500iA*   If no errors, proceed with report generation.
500iAC                   If        Error1 = *off
500iAC                   leave
500iAC                   Endif
500iA*
500iAC                   Endsl
500iAC                   Enddo
500iA*
500iAC                   eval      wdwinuse = '*NO '
500iA*
500iAC     endwdwpmt2    endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWDWREPRNT   Window Prompt for Transaction number for Reprint
     *
     C     zzwdwreprnt   begsr
     *
     C                   eval      error1   = *off
     C                   eval      cancel   = *off
     C                   eval      wdwinuse = '*YES'
     C                   eval      wdwtitle = title02
     *
500jAC                   select
500iAC                   when      client = cheney and oprpck = 'Y'
CBI A*
CBI A*    Set printer defaults.
CBI AC                   select
CBI AC                   when      wowhdp = 'DRY  '
CBI AC                   eval      wwdev = 'LP08     '
CBI A*
CBI AC                   when      wowhdp = 'FRZ  '
CBI AC                             or wowhdp = 'CLR  '
CBI AC                   eval      wwdev = 'LP26       '
CBI A*
CBI AC                   Endsl
CBI AC                   eval      wwform = '*STD      '
CBI A*
500iDC*                  Other
500iA*       Print Runner pick list
500iMC                   When         oprpck = 'Y'
500iA*       Print Runner pick labels
500iMC                             or oprlbl = '1'
500iA*
500iAC                   eval         *in40  = *off
     *
417bA*       Retrieve default printer device.
500iA*
500iAC                   select
500iAC                   when      oprpck = 'Y'
500iAC                   eval      $lprt  = 'RU365PR'
500iAC                   when      oprlbl = '1'
500iAC                   eval      $lprt  = 'RU355PR'
500iAC                   endsl
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iA*
417bAC                   call      'GETRPT'
417bAC                   parm      '*DEVFORM'    $CMD
500iDC*                  parm      'RU365PR'     $lprt
500iMC                   parm                    $lprt
417bAC                   parm      kywhse        $whse
500mDC*                  parm      ' '           $styp
500mMC                   parm                    $styp
500mDC*                  parm      ' '           $whdp
500mMC                   parm                    $whdp
417bAC                   parm      ' '           $desc
417bAC                   parm      ' '           $dev
417baC                   parm      ' '           $form
417bAC                   if        $dev > ' '
417bAC                   eval      wwdev  = $dev
417bAC                   eval      wwform = $form
417bAC                   else
     C                   eval      wwdev  = '*JOB       '
     C                   eval      wwform = '*STD       '
417bAC                   endif
500iA*
500iA*       Runner label on belt printer selected
500iAC                   when      oprlbl  = '2'
500iAC                   eval      *in40   = *on
500iAC                   eval      wwdev   = 'BELTPRINT '
500iAC                   eval      wwform  = '*STD      '
CBI A*
CBI AC                   Endsl
500iA
500iAC                   eval      svdev  = wwdev
500iAC                   eval      svform = wwform
     *
     *   Write window definition record
     C                   write     window1
     *
     C                   Dow       Forever = Forever
     *
     *   Overlay screen with error messages
     C                   exsr      zmdmsg
     *
     C                   exfmt     wdwfmt2
     *
     C                   setoff                                       040506
     C                   setoff                                       242526
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     *   F3 or F12 selected by user.
     C                   when      *inkc = *on
     C                             or *inkl = *on
     C                   eval      cancel = *on
     C                   leave
     *
     *   F5 Refresh selected by user.
     C                   when      *inke = *on
     C                   eval      wwtrn# = 0
     *
500iAC                   eval      wwdev   = svdev
500iAC                   eval      wwform  = svform
     *
     *   Enter key pressed. Validate entries.
     C                   Other
     *
     C                   exsr      zzwdwck2
     *
     *   If no errors, proceed with report generation.
     C                   If        Error1 = *off
     C                   leave
     C                   Endif
     *
     C                   Endsl
     C                   Enddo
     *
     C                   eval      wdwinuse = '*NO '
     *
     C     endwdwrpt     endsr
500iA*----------------------------------------------------------------
500iA*  ZZWDWREPRNT2  Window Prompt for Transaction number for Reprint
500iA*
500iAC     zzwdwreprnt2  begsr
500iA*
500iAC                   eval      error1   = *off
500iAC                   eval      cancel   = *off
500iAC                   eval      wdwinuse = '*YES'
500iAC                   eval      wdwtitle = title02
500iA*
500iAC                   select
500iAC                   when      client = cheney and oprpck = 'Y'
500iA*
500iA*    Set printer defaults.
500iAC                   select
500iAC                   when      wowhdp = 'DRY  '
500iAC                   eval      wwdev = 'LP08     '
500iA*
500iAC                   when      wowhdp = 'FRZ  '
500iAC                             or wowhdp = 'CLR  '
500iAC                   eval      wwdev = 'LP26       '
500iA*
500iAC                   Endsl
500iAC                   eval      wwform = '*STD      '
500iA*
500iAC                   Other
500iA*         Allow Label device to be changed.
500iAC                   eval         *in40  = *off
500iA*
500iA*       Retrieve Runner pick list default printer device.
500iAC                   eval      $lprt  = 'RU365PR'
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iAC                   exsr      zzgetrpt
500iAC                   eval      wwdev  = $dev
500iAC                   eval      wwform = $form
500iA*
500iAC                   Endsl
500iA*
500iAC                   select
500iA*       Retrieve Runner pick label default printer device.
500iAC                   when      oprlbl = '1'
500iAC                   eval      $lprt  = 'RU355PR'
500mAC                   eval      $whdp  = kywhdp
500mAC                   eval      $styp  = 'F'
500iAC                   exsr      zzgetrpt
500iAC                   eval      wwdev2  = $dev
500iAC                   eval      wwform2 = $form
500iA*
500iA*       Set Runner Belt default printer device.
500iAC                   when      oprlbl = '2'
500iA*         Protect Label device so that it can't be changed.
500iAC                   eval      *in40 = *on
500iAC                   eval      wwdev2  = 'BELTPRINT '
500iAC                   eval      wwform2 = '*STD      '
500iAC                   endsl

500iAC                   eval      svdev   = wwdev
500iAC                   eval      svform  = wwform
500iAC                   eval      svdev2  = wwdev2
500iAC                   eval      svform2 = wwform2

500iA*
500iA*   Write window definition record
500iAC                   write     window1
500iA*
500iAC                   Dow       Forever = Forever
500iA*
500iA*   Overlay screen with error messages
500iAC                   exsr      zmdmsg
500iA*
500iAC                   exfmt     wdwfmt4
500iA*
500iAC                   setoff                                       040506
500iAC                   setoff                                       242526
500iAC                   setoff                                       2728
500iA*
500iA*   Initialize error subfile
500iA*
500iAC                   exsr      zmcmsg
500iA*
500iAC                   select
500iA*   F3 or F12 selected by user.
500iAC                   when      *inkc = *on
500iAC                             or *inkl = *on
500iAC                   eval      cancel = *on
500iAC                   leave
500iA*
500iA*   F5 Refresh selected by user.
500iAC                   when      *inke = *on
500iAC                   eval      wwtrn# = 0
500iA*
500iAC                   eval      wwdev   = svdev
500iAC                   eval      wwform  = svform
500iAC                   eval      wwdev2  = svdev2
500iAC                   eval      wwform2 = svform2
500iA*
500iA*   Enter key pressed. Validate entries.
500iAC                   Other
500iA*
500iAC                   exsr      zzwdwck2
500iAC                   exsr      zzwdwck1a
500iA*
500iA*   If no errors, proceed with report generation.
500iAC                   If        Error1 = *off
500iAC                   leave
500iAC                   Endif
500iA*
500iAC                   Endsl
500iAC                   Enddo
500iA*
500iAC                   eval      wdwinuse = '*NO '
500iA*
500iAC     endwdwrpt2    endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 2 4 5
**  OPTLN - Option display line
  1=Select flags  2=Change  4=Delete  5=View
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 3  F11=View 2  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 1  F11=View 3  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 2  F11=View 1  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 3  F11=View 1  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
replaced with CMDLN5(9)
replaced with CMDLN5(10)
**  CMDLNA - Command display line - Replacement lines for 4th view.
F10=View 4  F11=View 2  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F10=View 2  F11=View 4  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
**  CMDLN5  Command display line
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 5  F11=View 2  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 1  F11=View 3  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 2  F11=View 4  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 3  F11=View 5  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F5=Refresh  F6=Reprint  F12=Cancel
F10=View 4  F11=View 1  F16=Select all  F17=Top  F18=Bottom  F20=Move to top
** Descriptions / Messages
Employee number
Invalid employee number
Invalid label number
Label not flagged.
Label already closed.
Flag record closed.
Flag being picked.
Label number
Printer device
Form type
Transaction number
Invalid transaction number
Flag record closed. Delete canceled.
Flag being picked. Delete canceled.
Option not allowed.
** Send break message to user
sndbrkmsgu msgtxt('
') usrprf(
) msgtyp(*info)
