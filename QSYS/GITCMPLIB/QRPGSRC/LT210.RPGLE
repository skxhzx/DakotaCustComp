      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  For some clients, RSTDSP needs to be set to *YES.
     *  See comment for JDOa below.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LT210     RF License plate tracking
     *  11 December 2003
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    12/11/03  DAS  4.17
     *      - Created
     *
417aA*    04/06/04  DAS  4.17a
     *      - Revised to track non-tracked items.
     *
417bA*    07/23/04  DAS  4.17b
     *      - Revised to call DRILICHIST instead of UPDLLPTRK.
     *
417cA*    08/25/04  DAS  4.17c
     *      - Added *PULL logic.
     *
500 A*    10/17/04  DAS  5.00
     *      - Revised ZZINZ2 to not set NXTSCR to EOJ. Re: Routine
     *        zznottracked is responsible for setting NXTSCR.
     *
500aA*    12/31/04  DAS  5.00a
     *      - Added LOGLT210 file.
     *      - Added command *PUTAREA.
     *      - Added parm $lsplit to GETTRACK program.
     *
500bA*    01/08/05  DAS  5.00b
     *      - Added trackpos check to pltpos checks.
     *
500cA*    01/10/05  DAS  5.00c
     *      - Added *PUTSTUF.
     *      - Added screen 29 (pallet position).
     *      - Added some logic for trackposrtn.
     *      - Revised zzpuldrop to work with trackitem = 'L'
     *
500dA*    01/13/05  DAS  5.00d
     *      - Revised zzpulrtn to do a *RTNALL.
     *      - Added $ltsplit (Tfr/Rpl split option) to GETTRACK.
     *      - Renamed $lsplit to $lpsplit (Putaway split opt) for GETTRACK.
     *      - Added fields to C#LICHIST.
     *
500eA*    01/25/05  DAS  5.00e
     *      - Added calls for *CHK4EXIST and *MERGE.
     *      - Revised *PULDROP logic.
     *
500fA*    02/09/05  DAS  5.00f
     *      - Deleted zzzupdsltpos logic.
     *
500gA*    02/15/05  DAS  5.00g
     *      - Added FLW and BRK types.
     *      - Added SCREEN30 to handle FLW and BRK.
     *
500hA*    03/06/05  DAS  5.00h
     *      - Added command *ADJUST.
     *
500iA*    03/23/05  DAS  5.00i
     *      - Revised %WRONGLOC to send To code and area.
     *
500jA*    03/25/05  DAS  5.00j
     *      - Added F9=Skip to SC1.
     *      - Revised SC1/ZZCMD1 to seton LR for F3, F12 and F9.
     *        Re: Odd situation was happening where an I/O error would
     *        occur for this sequence: LT107.01 to LT210.01. Press F12 or
     *        F9 back to LT107.01. Press Enter back to LT210.01. Press
     *        Enter and get I/O error instead of LT210.02a.
     *        Note: Debug showed that program did not stop for input on
     *        the EXFMT screen2a statement.
     *        This sequence worked: LT107.01 to LT210.01. Press Enter to
     *        LT210.02a. Press F12 back to LT107.01. Press Enter back to
     *        LT210.01. Press Enter to LT210.02a and don't get I/O error.
     *        Go figure.
     *      - Revised SC2A to do zzpulrtn for F3 and F12.
     *
500kA*    03/30/05  DAS  5.00k
     *      - Revised to do a *MERGE after a *PULUNDO.
     *
500lA*    04/04/05  DAS  5.00l
     *      - Added commands *INVCNTB for Inventory Counts.
     *        Note, there is no *INVCNTA because there is nothing to do.
     *        The information from INVCNTB is written to an inventory file
     *        to be used when the iventory is posted.
     *
500mA*    04/12/05  DAS  5.00m
     *      - Revised PULTRAN for FLW to not ask for license, instead it
     *        will defualt to '*RP'.
     *
500oA*    04/13/05  DAS  5.00o
     *      - Revised SC2D (search other pallets for item) to ask a Y/N
     *        question instead of a pallet position.
     *      - Removed F10=Exception from SC2D ('N' will be the exception)
     *      - Revised ZZUPD2D to not mess with pallet positions.
     *      - Revised ZZUPD2D to always create an exception, even if the
     *        user found the item on another pallet. Re: Not finding the
     *        item on the original pallet could indicate that the pallet
     *        position is wrong for the other items on the same pallet, it
     *        could mean that the item was just put on the wrong pallet,
     *        or the item could legitamately be in another pallet position
     *        and could just be missing. Much too difficult to have the
     *        user identify.
     *
500pA*    04/22/05  DAS  5.00p
     *      - Enh: Revised program to add support for Client id
     *
500qA*    04/29/05  DAS  5.00q
     *      - Added command *NQDROP (no questions drop).
     *
500rA*    04/30/05  DAS  5.00r
     *      - Added $pnorm1/2/3 parms for Normal qty.
     *      - Added $lrnorm1/2/3 to C#LICHIST.
     *
500sA*    05/03/05  DAS  5.00s
     *      - Added commands *RMVZERO and *RMVZRTN.
     *
500tA*    05/08/05  DAS  5.00t
     *      - Revised *ADJUST to call zzrmvzero to remove lichist record
     *        if quantity went to zero.
     *
500uA*    05/20/05  MLB  5.00u
     *      - Revised pgm when called with *ADJUST to not Open LT210FM.
     *
500vA*    05/27/05  DAS  5.00v
     *      - Revised *INVCNTB to not ask for any information if all
     *        quantities are zero.
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    07/16/08  DAS  6.00a  P#00045
     *      - Added phrase logging.
     *
600bA*    10/15/08  DAS  6.00b
     *      - Moved scnext logic into individual zzupd routines.
     *      - Deleted scnext routine to clean up program.
     *        Routine can be viewed in LT210.1015
     *      - Created scprevupd routine to update previous screen stack
     *
600cA*    01/21/09  DAS  6.00c
     *      - Revised ZZFIL21 to set w21psplit correctly for putaway.
     *
600dA*    01/24/09  DAS  6.00d
     *      - Revised to work with DRILICENSE instead of DRILICHIST.
     *
600eA*    01/26/09  DAS  6.00e
     *      - Revised to have calling program pass in the license
     *        number through $plic#. Re: Calling program should
     *        either be sending the From or To slot, but in some
     *        cases, the To slot must be sent in before the slot
     *        and license has been update, thus the license wouldn't
     *        be associated with the slot yet, causing an error in
     *        zzinz2 when it retrieved the slot information.
     *
600fA*    02/04/09  DAS  6.00f
     *      - Revised *PULTRAN for a M/H tracked item to not ask the
     *        user for an LP when pulling a partial qty. Re: We
     *        currently only allow the user to assign the new LP to
     *        the qty going to the new slot. Therefore, we are going
     *        to delay asking for the new LP until the qty is put into
     *        the new slot.
     *
600gA*    02/07/09  DAS  6.00g
     *      - Revised zzchk21 to verify new license is not in the
     *        licactive file.
     *
600hA*    02/11/09  DAS  6.00h
     *      - Removed all DRILICHIST code. LICHIST file is no longer
     *        used for license tracking.
     *      - Removed *ADJUST/zzadjust because it is not used anymore.
     *      - Removed *RMVZERO/zzrmvzero because it is not used anymore.
     *      - Removed *RMVZTRN/zzrmvztrn because it is not used anymore.
     *
600iA*    05/19/09  DAS  6.00i
     *      - Revised to initialize some $sl fields before calling
     *        zzexception from zzinz2 routine.
     *
600jA*    05/31/09  DAS  6.00j
     *      - Revised to not allow a blank license on screen 21.
     *
600kA*    06/02/09  DAS  6.00k
     *      - Revised to ask for LP when going to a non-pick slot
     *        and current LP begins with '*'.
     *
610aA*    06/07/09  DAS  6.10a
     *      - Revised zznotracked/PULTRAN to not ask for LP for BRK/FLW.
     *
610bA*    08/27/09  DAS  6.10b
     *      - Revised *PULRTN to not display a screen. Screen was
     *        confusing telling user to put pallets back up for a
     *        single pallet position slot. Can revisit at a later date.
     *      - Revised F9=Skip on screen 1 to return *CANCEL if calling
     *        program is not LT107.
     *      - Added F9=Skip to screen 3 to function like screen 1.
     *
610cA*    09/09/09  DAS  6.10c
     *      - Revised zzchk3 to set on error indicator.
     *      - Changed error message used in zzchk3. Message RC20017
     *        says 'Invalid slot, virtual slot'.
     *
610dA*    09/10/09  DAS  6.10d
     *      - Revised *INVCNTB to behave like *PULDROP, except that
     *        it will not ask the user to verify the license.
     *
610eA*    09/09/09  DAS  6.10e
     *      - Revised *INVCNTB to return if license is *NONE, if
     *        license is not found, slot is a pick slot, or
     *        item is low tracking.
     *
610fA*    09/19/09  DAS  6.10f
     *      - Added *GETNEW command.
     *
610gA*    11/11/09  DAS  6.10g
     *      - Added $ptoslot parameter.
     *      - Revised to display $ptoslot on screens 1/3 if sent.
     *
610hA*    10/19/09  DAS  6.10h
     *      - Revised to not set tracking level to No for *MULTIPLE.
     *        Now, if *MULTIPLE licenses are being transfered into
     *        an Overflow slot for a Medium/High tracked item, the
     *        user will be asked for a license. DRILICENSE has been
     *        revised to combine the *MULTIPLE license into the
     *        new license.
     *
610iA*    12/09/09  DAS  6.10i
     *      - Revised to create an ITMEXCP record when F10 is pressed
     *        on screen 3 then return to calling program instead of
     *        displaying screen 2a.
     *      - Revised to use exception task code LCNS instead of REPL.
     *      - Revised to ensure an exception error id is assigned.
     *      - Revised to set exception corresponding item to license.
     *
610jA*    04/14/10  DAS  6.10j
     *      - Revised to treat RPK slots like Pick slots.
     *
640aA*    04/11/11  DAS  6.40a
     *      - Revised to only open screen when necessary in DSPSCR.
     *
640bA*    06/13/11  DAS  6.40b
     *      - Fix: Revised ZZINZ2 to set NXTSCR to EOF when doing
     *        a partial qty for *PULTRAN. Otherwise, there were times
     *        when NXTSCR would remain blank and go into a loop trying
     *        to display a screen, which would blow up the previous
     *        multiple occurance data structure.
650a *    06/27/13  GJA  6.50a
     *      - Enh: Rename LT210FM format to LT21001
     *
650a *    05/07/14  GJA  6.50b
     *      - Enh: Change invalid license to be wrong license
     *
650c *    06/11/14  KDE  6.50c
     *      - Enh: Setup to handle Production Replenishments
     *
700a *    05/21/15  GJA  7.00a
     *      - Enh: Display the last three digits of license per
     *             system option setting.
     *
700bA*    06/27/16  LMC  7.00b
     *      - Reserved - UCI Tracking
700cA*    09/15/16  TAB  7.00c
     *      - Add new screen for F8 license override
700dA*    12/07/16  LMC  7.00d
     *      - If an error occurred on Sc3 or SC3b the prvcount field
     *        was increasing, causing the user to do multiple F12 to
     *        be returned to the previous screen. User would have to
     *        F12 the number of times an error occurred plus 1 more
     *        time to actually get to the previous screen.
     *        In zzchk3 and zzchk3b if an error occurs, sub 1 from
     *        prvcount.
700eA*    11/04/16  LMC  7.00e
     *      - Enh: UPC file has a database change. Recompile only.
720 A*    02/22/18  KDE  7.20
     *      - Enh: Add support for Virtual RPA
     *      - Force Med. Tacking when Store Stage Repln to force license entry
720aA*    06/27/16  LMC  7.20a  - reserved
     *      - UCI Tracking - New Item tracking level 'U'
     *      - New tracking will require scanning of UCI's on partial
     *      - Rename LT21003 format to LT21004
730aA*    02/15/19  LMC  7.30a
     *      - Fix - conditioin any use of $puci on parm 35 being
     *        sent in.
730bA*    07/10/19  LMC  7.30b
     *      - Enh - don't display apply license screen 21. force f10
     *        to use system license, if called from porgram AUTOTFR.
730cA*    11/08/19  KDE  7.30c
     *      - Enh - Force Low Tracking on Drop Pick slot transactions
750aA*    08/15/21  KDE  7.50a
     *      - Fix - Only do clrsch if a screen was used
750bA*    08/26/21  LMC  7.50b
     *      - Enh - When assigning a new license on sc21, we are only
     *        checking licactive, we also need to check liclog. If
     *        liclog exist, do not allow the license to be used.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * City Line Distributors Custom Mod
     *
CLDaA*    01/10/13  DAS  CLDb
     *      - Revised W3LDSP to only contain last 3 characters of license.
     *        Re: User manually entering license for High tracked items.
     *      - Any comparisons agains W3LSDSP will now be done against
     *        new field w3ldspFull
     *
CLDbA*    01/10/13  DAS  CLDb
     *      - Disallow F10=Excp from screen 3.
     *
CLDcA*    02/18/13  LMC  CLDc
     *      - Display seven dashes in place of the last 3 positions
     *        or th license number.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Coastal Sunbelt Produce Custom Mod
     *
CSPaA*    02/08/13  LMC  CSPa
     *      - Use same client logic as CLDa & CLDb mods.              nse.
CSPbA*    12/09/13  RH   CSPb
     *      - Allow F10 exception.                                    nse.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Jordano's Custom Mods
     *
JDO A*    04/22/05  DAS  JDO
     *      - Revised PULTRAN for BRK to not ask for license, instead it
     *        will defualt to '*RP'.
     *
JDOaA*    11/02/10  DAS  JDOa
     *      - Changed compiled object to set RSTDSP = *YES.
     *        Re: When running program IT252 and IT352 using iSeries
     *        Access, and the program neeads to ask the user for a new
     *        license when putting the item into the slot, LT210 would
     *        blow up with an I/O error.
     *
     *----------------------------------------------------------------
     * Greenleaf Produce Custom Mod
GLPaA*    03/30/15  RH   GLPa
     *      - Don't allow F10 to skip scan, Temp only for move.
     *      - This mod has been commented out for possible future use.

     *----------------------------------------------------------------
     * Springfield Grocer Custom Mod
     *
SGCaA*    02/08/13  LMC  SGCa
     *      - Use same client logic as CLDa & CLDb mods.              nse.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
DRYaA*    06/10/14  RH   DRYa
     *      - Disallow F10 screen 21 to force license to be applied
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * WestSide Custom Mod
     *
WSTa *    05/21/15  GJA  WSTa
     *      - Revised W3LDSP to only contain last 3 characters of license.
     *        Re: User manually entering license for High tracked items.
     *      - Any comparisons agains W3LSDSP will now be done against
     *        new field w3ldspFull
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * FoodPro Custom Mod
     *
FPRaA*    07/10/15  RH   FPRa
     *      - Use same client logic as CLDa disable F10               nse.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBIaA*    07/12/17  LMC  CBIa
     *      - Cheney requires a new license when transferring from    nse.
     *        One department to another, their license plates are     nse.
     *        color coded by department.                              nse.
     *----------------------------------------------------------------
     * Client Custom Revisions: Seashore
SFPaA*    04/28/23  RH   SFPa
     *      - Disallow F10 screen 21 to force license to be applied
     *----------------------------------------------------------------
     * Tracking options
     *
     * Tracking levels for field trackitem:
     *
     *   Low     -  User is not asked for any extra info.
     *              All tracking is done in the background.
     *
     *   Medium  -  User may be asked to apply new license plate to
     *              a split quantity.
     *              Applying new license plate is optional.
     *
     *   High    -  User may be asked to apply new license plate to
     *              a split quantity.
     *              Applying new license plate is manditory.
     *              User may be asked to confirm license plate being
     *              used for task.
     *
     * Values for trackpos fields:
     *
     *    trackpos     Track slot pallet position (Y/N)
     *
     *    trackposmrg  Putaway merge option
     *                 1 = Only ask for pallet position.
     *                 2 = Direct user step by step.
     *
     *    trackposrtn  Return pallet option
     *                 1 = Assume user returns pallets in LOFI order.
     *                 2 = Direct user step by step.
     *
     * Values for field tracksplit
     *
     *   1  =  LP goes with first quantity put into a slot.
     *   2  =  LP goes with last quantity put into a slot.
     *   3  =  Ask user.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650aDF***lt210fm   cf   e             workstn
700cDF***lt21001   cf   e             workstn
720aDF*lt21003   cf   e             workstn
720aMFlt21004   cf   e             workstn
500uAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
500eAFworkrpl3  if   e           k disk
500eAFupc2      if   e           k disk
500aAFloglt210  o    e           k disk
500oAFitmexcp   o    e           k disk
700aAFoptions   if   e           k disk

500pA*----------------------------------------------------------------
500pA*  Customer id
500pA*----------------------------------------------------------------
500pA
500pA /copy qcopysrc,id#jordano
CLDaA /copy qcopysrc,id#citylin
SGCaA /copy qcopysrc,id#sgc
CSPaA /copy qcopysrc,id#coastal
DRYaA /copy qcopysrc,id#dairyla
GLPaA /copy qcopysrc,id#glp
FPR A /copy qcopysrc,id#fpr
CBIaA /copy qcopysrc,id#cheney
SFPaA /copy qcopysrc,id#sfp

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#DEPT
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#SLOTDEF
600hD *COPY *libl/qcopysrc,C#LICHIST
600dA /COPY *libl/qcopysrc,C#LICENSE
720aA /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

720aA /COPY *libl/qcopysrc,C#CVTPARMS
720aA /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar

600dA*----------------------------------------------------------------
600dA*  Tracking variables
600dA*----------------------------------------------------------------
600dA
600dA /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10

     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curdate         s              8  0
600fMD curlic#         s                   like($liToLcns)
     D curpal          s              3  0
     D curpos          s              3  0
     D curposcod       s              1
417bMD curslot         s                   like($sldisp)
     D curtime         s              6  0
730cAD dropPickSlot    s               n
     D enterStat       s              5  0
     D excppos         s              3  0
     D getlic          s               n
417bDD*gettyp          s                   like($rrtn)
     D help            s              5  0
600hMD inlic#          s                   like($liToLcns)
500gAD kynbr           s                   like(wrnbr)
500gAD kytype          s                   like(wrtype)
500gAD kyupc           s                   like(upupc)
     D lastscr         s              3
     D liccnf          s               n
     D licexists       s               n
     D licpos          s              3  0
     D msgk            s              4  0
     D multiflag       s               n
     D numpostfix      s              2
     D nxtscr          s              3
500uAD opn_lt210fm     s              1    inz('0')
750aAD clrscrn         s               n
600hMD outlic          s                   like($liToLcns)
600hMD outlic#         s                   like($liToLcns)
     D outqty          s              4
600hMD outtsp          s                   like($liToPos)
     D ovrrid          s              1
600fAD pickSlot        s               n
     D pltpos          s              3  0
     D pulled          s              3  0
     D redspl          s              1
     D refrsh          s              1
610jAD repackSlot      s               n
650cAD ProdSlot        s               n
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
600dAD slotLcns        s                   like($saToLcns)
600dAD slotLcnsPos     s                   like($saToPos)
600fAD spclLcns        s              3
720 Ad strRepl         s               n
600kAD systemLcns      s               n
720aAD scancount       s              5  0
     D temp1n          s              1  0
     D temp2n          s              2  0
     D temp3a          s              3
600hMD tfrlic          s                   like($liToLcns)
     D trackitem       s              1
     D tracklevel      s              1
     D trackpos        s              1
     D trackposmrg     s              1
     D trackposrtn     s              1
500dMD trackpsplit     s              1
500dAD tracktsplit     s              1
720aAD uciqty          s              5  0
CLDaAD w3ldspFull      s             15
CLDcAD w3ldspFullnone  s             15    inz('-------')
CLDaAD licLen          s              3  0
700cAD Htoitem         s                   like($litoitem)
700cAD Hfirstfifoentd  s                   like($lifirstfifoentd)
700cAD Hfirstfifoexpd  s                   like($lifirstfifoexpd)
700cAD Prv3BScr        s              3
720aAD currtimestamp   s               z

417bDD**---------------------------------------------------------------
417bDD** LICHIST parameters
417bDD**---------------------------------------------------------------
417bDD**
417bDD*$rparm          ds
417bDD**$rwhse                 1      3  0
417bDD**$rltrn                 4      7p 0
417bDD**$racfl                 8      9
417bDD**$rtrn#                10     13p 0
417bDD**$rlbl#                14     17p 0
417bDD**$rlcns                18     32
417bDD**$rfmlc                33     47
417bDD**$rorlc                48     62
417bDD**$rlqy1                63     66p 0
417bDD**$rlqy2                67     70p 0
417bDD**$rlqy3                71     74p 0
417bDD**$raqy1                75     78p 0
417bDD**$raqy2                79     82p 0
417bDD**$raqy3                83     86p 0
417bDD**$rfmcd                87     87
417bDD**$rfara                88    102
417bDD**$rfwhd               103    107
417bDD**$rfasl               108    110
417bDD**$rfloc               111    113  0
417bDD**$rflvl               114    115  0
417bDD**$rfhnd               116    117
417bDD**$rfslp               118    119p 0
417bDD**$rtocd               120    120
417bDD**$rtara               121    135
417bDD**$rtwhd               136    140
417bDD**$rtasl               141    143
417bDD**$rtloc               144    146  0
417bDD**$rtlvl               147    148  0
417bDD**$rthnd               149    150
417bDD**$rtslp               151    152p 0
417bDD**$rtord               153    156p 0
417bDD**$rtseq               157    159p 0
417bDD**$rexcd               160    167
417bDD**$radts               168    193
417bDD**$raemp               194    196p 0
417bDD**$rausr               197    206
417bDD**$rajob               207    216
417bDD**$rajbn               217    222
417bDD**$rcdts               223    248
417bDD**$rcemp               249    251p 0
417bDD**$rcusr               252    261
417bDD**$rcjob               262    271
417bDD**$rcjbn               272    277
417bDD**
417bDD**  Misc. work fields
417bDD**
417bDD*$rdata          ds
417bDD**$rpo                   1      9
417bDD**$rseq                 10     12p 0
417bDD**$ritem                13     27
417bDD**$rlotc                28     57
417bDD**$rcwgt                58     62p 2
417bDD**$rnewp                63     64p 0
417bDD**rdtaln                 1    100

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $laisl                27     29
     D  $lloc                 30     31p 0
     D  $lrlvl                32     33  0
     D  $lhand                34     35
     D  $lpos                 36     37p 0
     D  $lpdsp                38     49
     D  $lvdsp                50     61
     D  $lpllc                62     62
     D  $lmxps                63     64p 0
     *
     D  $lwhse2               19     21  0
     D  $ltrackitem           22     22
     D  $ltrackpos            23     23
     D  $lposmrg              24     24
     D  $lposrtn              25     25
500dMD  $lpsplit              26     26
500dAD  $ltsplit              27     27
     *
     D $ldata          ds
     D  $ldend                 1    100
500oA
500oA*----------------------------------------------------------------
500oA* CVTDTE parameters
500oA*----------------------------------------------------------------
500oA
500oAD $cvtdt          ds
500oAD  $cvcmd                 1      8
500oAD  $cvprg                 9     18
500oAD  $cvd6i                19     24
500oAD  $cvd8i                25     32
500oAD  $cvd6o                33     38  0
500oAD  $cvd8o                39     46  0
500oAD  $cvsto                47     64
500oAD  $cvrtn                65     72
500oAD  $cverm                73    132
500oAD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Data structure for error message
     *----------------------------------------------------------------

     D msgscr          ds
     D  msg0                         20
     D  msg1                         20
     D  msg2                         20
     D  msg3                         20
     D  msg4                         20
     D  msg5                         20
     D  msg6                         20

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erlcns                 1     15
     D  erdsp                 16     27
     D  erpos                 28     29p 0
     *
     D  erfld                  1     30
     D  erfromrng             31     40
     D  ertorng               41     50
     *
500gAD  erpnbr                 1     15
500gAD  erpusr                16     25

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Previous screen multiple occurance data structure
     *----------------------------------------------------------------

     D prvscr          s             10
     D prvcount        s              3  0
600bAD savscr          s             10

     D maxscr          c                   100
     D dsprvscr        ds                  occurs(maxscr)
     D   dsscr                       10

     *----------------------------------------------------------------
     * Program information data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

600aA*----------------------------------------------------------------
600aA*  Phrase Variables
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,c#phrasvar
600aAD  currFile       s             10
600aAD  currRoutine    s             20
600aAD  lastnxtscr     s              3
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)
600aA
600aA*----------------------------------------------------------------
600aA*  Phrases
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D  $pcmd          s              8
     D  $pprogram      s             10
     D  $ptype         s              3
     D  $phead         s             20
     D  $pwhse         s              3  0
     D  $pitem         s             15
     D  $pitemdsc      s             65
     D  $pwhdp         s              5
     D  $pslot         s             12
     D  $pslotpos      s              3  0
     D  $pempl#        s              5  0
     D  $ptran#        s              7  0
     D  $plic#         s             15
     D  $pnewlic#      s             15
     D  $pqty1         s              5  0
     D  $pqty2         s              3  0
     D  $pqty3         s              3  0
500rAD  $pnorm1        s              5  0
500rAD  $pnorm2        s              3  0
500rAD  $pnorm3        s              3  0
     D  $ppartial      s               n
     D  $ppulled       s              3  0
     D  $pinslot       s              1
     D  $psamepos      s              1
     D  $pdiffpos      s              1
     D  $ppsplit       s              1
     D  $pinlic#       s             15
     D  $poutlic#      s             15
     D  $pnexttask     s             10
     D  $preturn       s              8
     D  $perrmsg       s             60
     D  $pmsgid        s              4
610gAD  $ptoslot       s             12
720aAD  $ppartime      s               Z
720aAD  $puci          s            100

700aA*----------------------------------------------------------------
700aA*  *SYSTEM  -  System options.
700aA*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPDSPL  -  Diplay last three of license plate.
     *
     * Data structure
     *
     D opdata          ds
     D  opdspl                44     44
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
500 M*      $pcmd        *PUTAWYA - Putaway - Put into slot (*PUTAWY2)
500 M*                                        After slot has been updated.
500 M*                   *PUTAWYB - Putaway - Put into slot (*PUTAWY2)
500 M*                                        Before slot has been updated.
500aA*                   *PUTAREA - Putaway - Put into area (non-slot)
500cA*                   *PUTSTFA - Putaway - Stuff into slot
500 M*                                        After slot has been updated.
500cA*                   *PUTSTFB - Putaway - Stuff into slot
500 M*                                        Before slot has been updated.
500 M*  ??????????????   *PUTTRAN - Putaway - In transit (*PUTAWY1)
500 M*  ??????????????   *PUTUNDO - Putaway - Undo (*PUTAWY0)
500 A*                   *PULDROP - Pull - Drop pallet to floor.
500 A*                   *PULRTN  - Pull - Return dropped plts to slot
500 A*                   *PULTRAN - Pull - In transit
500 A*                   *PULUNDO - Pull - Undo
500hA*                   *ADJUST  - Adjust slot/license quantity.
500uA*                              LT210FM not opened.
500lA*                   *INVCNTB - Inventory Count.
500lA*                                Before inventory count file updated.
500qA*                   *NQDROP  - Drop pallet to floor w/o questions
610xA*                   *GETNEW  - Get new license
     *      $pprogram  - Calling program name
     *      $ptype     - PUT - Putaway
     *                   TFR - Transfer
     *                   RPL - Replenishment
     *                   LET - Letdown
     *                   PRP - Priority Replenishment
     *                   SSR - Single Slot Replenishment
500gA*                   BRK - Breakdown replenishment.
500gA*                   FLW - Flowrack replenishment.
610jA*                   RPK - Repack replenishment.
     *      $phead     - Main heading
     *      $pwhse     - Warehouse
     *      $pitem     - Item number
     *      $pitemdsc  - Item description heading
     *      $pwhdp     - Department
     *      $pslot     - Slot number
     *      $pslotpos  - Slot pallet positions
     *      $pempl#    - Employee number
     *      $ptran#    - Transaction number
     *      $plic#     - License number
     *      $pnewlic#  - New licence number (partial replenishment).
     *      $pqty1     - Quantity 1
     *      $pqty2     - Quantity 2
     *      $pqty3     - Quantity 3
500rA*      $pnorm1    - Normal quantity 1
500rA*      $pnorm2    - Normal quantity 2
500rA*      $pnorm3    - Normal quantity 3
     *      $ppartial  - Partial quantity flag (1=Yes, 2=No)
     *      $ppulled   - Pallets pulled in *PULL1. Needed for *PULL2.
     *      $ppsplit   - trackpsplit (used for *PUTAWYA)
     *      $pinlic#   - inlic# (used for *PUTAWYA)
     *      $poutlic#  - outlic# (used for *PUTAWYA)
     *      $pnexttask - Task to be performed for *PUTAWYA.
610gA*      $ptoslot   - 'To' slot for Replenishments.
720aA*      $ppartime - TimeStamp for UCI tracking on partials
720aA*      $puci     - UCI if initiated from an it253
     *
     *    Returned Parameters
     *      $ppulled   - Pallets pulled in *PULL1.
     *      $pinslot   - Item already exists in slot (Y,N)
     *      $psamepos  - Item already exists in same slot position (Y,N)
     *      $pdiffpos  - Item already exists in different slot pos (Y,N)
     *      $ppsplit   - Set to trackpsplit before returning.
     *      $pinlic#   - Set to inlic# before returning.
     *      $poutlic#  - Set to outlic# before returning.
     *      $pnexttask - Task to be performed for *PUTAWYA.
     *      $preturn   - *OK
     *                   *CANCEL - F12 was taken.
     *                   *NOTFND - Item not found for replenishment.
     *      $perrmsg
     *      $pmsgid
720aA*      $ppartime - TimeStamp for UCI tracking on partials
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $pprogram
     C                   parm                    $ptype
     C                   parm                    $phead
     C                   parm                    $pwhse
     C                   parm                    $pitem
     C                   parm                    $pitemdsc
     C                   parm                    $pwhdp
     C                   parm                    $pslot
     C                   parm                    $pslotpos
     C                   parm                    $pempl#
     C                   parm                    $ptran#
     C                   parm                    $plic#
     C                   parm                    $pnewlic#
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
500rAC                   parm                    $pnorm1
500rAC                   parm                    $pnorm2
500rAC                   parm                    $pnorm3
     C                   parm                    $ppartial
     C                   parm                    $ppulled
     C                   parm                    $pinslot
     C                   parm                    $psamepos
     C                   parm                    $pdiffpos
     C                   parm                    $ppsplit
     C                   parm                    $pinlic#
     C                   parm                    $poutlic#
     C                   parm                    $pnexttask
     C                   parm                    $preturn
     C                   parm                    $perrmsg
     C                   parm                    $pmsgid
610gAC                   parm                    $ptoslot
720aAC                   parm                    $ppartime
720aAC                   parm                    $puci

720 Ac                   if        $pcmd = '*PUTAWY9'
720 Ac                   eval      $pcmd = '*PUTAWYB'
720 Ac                   eval      strRepl = *on
720 Ac                   else
720 Ac                   eval      strRepl = *off
720 Ac                   endif

600aAC                   eval      stackCount = 0
600aAC                   eval      currRoutine = 'main'
600aAC                   exsr      phpgmV1V2V3s

500aAC                   eval      lg210io = 'I'
500aAC                   exsr      writelogrec

     C                   eval      $preturn = '*OK'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
750aAc                   eval      clrscrn = *off
720aAC                   if        %parms >= 34
720aAC                   eval      $ppartime = *loval
720aAc                   endif
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
750aAc                   eval      clrscrn = *on
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02a'         sc2a
     C     nxtscr        caseq     '02b'         sc2b
     C     nxtscr        caseq     '02c'         sc2c
     C     nxtscr        caseq     '02d'         sc2d
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '03a'         sc3a
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
     C     nxtscr        caseq     '09 '         sc9
     C     nxtscr        caseq     '21 '         sc21
     C     nxtscr        caseq     '22 '         sc22
     C     nxtscr        caseq     '23 '         sc23
     C     nxtscr        caseq     '24 '         sc24
     C     nxtscr        caseq     '25 '         sc25
     C     nxtscr        caseq     '26 '         sc26
     C     nxtscr        caseq     '27 '         sc27
     C     nxtscr        caseq     '28 '         sc28
500cAC     nxtscr        caseq     '29 '         sc29
500gAC     nxtscr        caseq     '30 '         sc30
700cAC     nxtscr        caseq     '03b'         sc3b
720aAC     nxtscr        caseq     '31 '         sc31
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
640aDC**                 if        $pcmd <> '*ADJUST'
640aAC                   if        opn_lt210fm = *on
750aAc                   if        clrscrn
     C                   exsr      zsclr
750aAc                   endif
500uAC                   endif

720aAC* for transfer we need to grab the qty and hold it
720aAc                   if        trackitem = 'U' and $ppartial
720aAc                   eval      uciqty = ($pqty1 + $pqty2 +
720aAc                                       $pqty3)
720aAc                   endif
500aAC                   eval      $ppsplit = trackpsplit
500aAC                   eval      $pinlic# = inlic#
500aAC                   eval      $poutlic# = outlic#
500aAC                   eval      lg210io = 'O'
500aAC                   exsr      writelogrec
600aAC                   exsr      phpgmV1V2V3e
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
640aA
640aA*  Do not open screen for *ADJUST or low tracked items
640aA
640aAC                   if        opn_lt210fm <> *on
650aDC***                open      LT210FM
700cDC***                open      LT21001
720aDC**                 open      LT21003
720aMC                   open      LT21004
640aAC                   exsr      zmimsg
640aAC                   eval      opn_lt210fm = *on
640aAC                   endif
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
600aA*
600aA*   Write tracking phrase.
600aA*
600aAC                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
600bAC                   eval      savscr = nxtscr
600bA
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen01                             50
     C                   when      nxtscr = '02a'
     C                   exfmt     screen02a                            50
     C                   when      nxtscr = '02b'
     C                   exfmt     screen02b                            50
     C                   when      nxtscr = '02c'
     C                   exfmt     screen02c                            50
     C                   when      nxtscr = '02d'
     C                   exfmt     screen02d                            50
     C                   when      nxtscr = '03 '
700cAC                   If        $ptype = 'RPL'
700cAC                   Eval      *In60 = *On
700cAC                   EndIf
     C                   exfmt     screen03                             50
     C                   when      nxtscr = '03a'
     C                   exfmt     screen03a                            50
700cAC                   when      nxtscr = '03b'
700cAC                   exfmt     screen03b                            50
     C                   when      nxtscr = '04 '
     C                   exfmt     screen04                             50
     C                   when      nxtscr = '05 '
     C                   exfmt     screen05                             50
     C                   when      nxtscr = '06 '
     C                   exfmt     screen06                             50
     C                   when      nxtscr = '07 '
     C                   exfmt     screen07                             50
     C                   when      nxtscr = '08 '
     C                   exfmt     screen08                             50
     C                   when      nxtscr = '09 '
     C                   exfmt     screen09                             50
     C                   when      nxtscr = '21 '
720aAC                   if        w31uci <> ' '
730bAc                             or $pprogram = 'AUTOTFR'
720aAc***for f10 so we just use system license
720aAc                   eval      *inkj = *on
720aAc                   else
     C                   exfmt     screen21                             50
720aAc                   endif
     C                   when      nxtscr = '22 '
     C                   exfmt     screen22                             50
     C                   when      nxtscr = '23 '
     C                   exfmt     screen23                             50
     C                   when      nxtscr = '24 '
     C                   exfmt     screen24                             50
     C                   when      nxtscr = '25 '
     C                   exfmt     screen25                             50
     C                   when      nxtscr = '26 '
     C                   exfmt     screen26                             50
     C                   when      nxtscr = '27 '
     C                   exfmt     screen27                             50
     C                   when      nxtscr = '28 '
     C                   exfmt     screen28                             50
500cAC                   when      nxtscr = '29 '
500cAC                   exfmt     screen29                             50
500gAC                   when      nxtscr = '30 '
500gAC                   exfmt     screen30                             50
720aAC                   when      nxtscr = '31 '
720aAc* if uci is sent in from it222, don't display the screen
730aAC                   if        %parms >= 35
720aAC                   if        $puci  <> ' '
720aAc                   else
720aAC                   exfmt     screen31                             50
720aAc                   endif
730aAc                   else
730aAC                   exfmt     screen31                             50
730aAc                   endif
     C                   endsl
600bA*
600bA*   Update previous screen stack.
600bA*
600bAC                   if        status = enterStat
600bAC                   eval      prvscr = savscr
600bAC                   exsr      scPrevUpd
600bAC                   endif
600aA*
600aA*   Write tracking phrase of what was pressed.
600aA*
600aAC                   exsr      phV2onV1
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
700cAC                   setoff                                       60
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C********           eval      e = 0
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
     C                   move      '01 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02a initialization
     *
     C     scr02ai       begsr
     C                   move      '02a'         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil2a
     C                   endif
     C                   eval      refrsh = *off
     C     end02ai       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02b initialization
     *
     C     scr02bi       begsr
     C                   move      '02b'         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil2b
     C                   endif
     C                   eval      refrsh = *off
     C     end02bi       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02c initialization
     *
     C     scr02ci       begsr
     C                   move      '02c'         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil2c
     C                   endif
     C                   eval      refrsh = *off
     C     end02ci       endsr
     *----------------------------------------------------------------
     *
     *  Screen 02d initialization
     *
     C     scr02di       begsr
     C                   move      '02d'         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil2d
     C                   endif
     C                   eval      refrsh = *off
     C     end02di       endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03a initialization
     *
     C     scr03ai       begsr
     C                   move      '03a'         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil3a
     C                   endif
     C                   eval      refrsh = *off
     C     end03ai       endsr
700cA*----------------------------------------------------------------
700cA*
700cA*  Screen 03b initialization
700cA*
700cAC     scr03bi       begsr
700cAC                   Move      nxtscr        Prv3BScr
700cAC                   move      '03b'         nxtscr
700cAC                   if        refrsh = *on
700cAC                   exsr      zzfil3b
700cAC                   endif
700cAC                   eval      refrsh = *off
700cAC     end03bi       endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil4
     C                   endif
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   move      '05 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil5
     C                   endif
     C                   move      *off          refrsh
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   move      '06 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil6
     C                   endif
     C                   move      *off          refrsh
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   move      '07 '         nxtscr
     C                   if        refrsh = *on
     C                   endif
     C                   exsr      zzfil7
     C                   move      *off          refrsh
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   move      '08 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil8
     C                   endif
     C                   move      *off          refrsh
     C     end08i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   move      '09 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil9
     C                   endif
     C                   move      *off          refrsh
     C     end09i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 21 initialization
     *
     C     scr21i        begsr
     C                   move      '21 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil21
     C                   endif
     C                   move      *off          refrsh
     C     end21i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 22 initialization
     *
     C     scr22i        begsr
     C                   move      '22 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil22
     C                   endif
     C                   move      *off          refrsh
     C     end22i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 23 initialization
     *
     C     scr23i        begsr
     C                   move      '23 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil23
     C                   endif
     C                   move      *off          refrsh
     C     end23i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 24 initialization
     *
     C     scr24i        begsr
     C                   move      '24 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil24
     C                   endif
     C                   move      *off          refrsh
     C     end24i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 25 initialization
     *
     C     scr25i        begsr
     C                   move      '25 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil25
     C                   endif
     C                   move      *off          refrsh
     C     end25i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 26 initialization
     *
     C     scr26i        begsr
     C                   move      '26 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil26
     C                   endif
     C                   move      *off          refrsh
     C     end26i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 27 initialization
     *
     C     scr27i        begsr
     C                   move      '27 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil27
     C                   endif
     C                   eval      refrsh = *off
     C     end27i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 28 initialization
     *
     C     scr28i        begsr
     C                   move      '28 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil28
     C                   endif
     C                   eval      refrsh = *off
     C     end28i        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  Screen 29 initialization
500cA*
500cAC     scr29i        begsr
     C                   move      '29 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil29
     C                   endif
     C                   move      *off          refrsh
     C     end29i        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  Screen 30 initialization
500cA*
500cAC     scr30i        begsr
     C                   move      '30 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil30
     C                   endif
     C                   move      *off          refrsh
     C     end30i        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  Screen 31 initialization
720aA*
720aAC     scr31i        begsr
720aAC                   move      '31 '         nxtscr
720aAC                   if        %parms >= 34
720aAC                   time                    $ppartime
720aAc                   endif
720aAC                   if        refrsh = *on
720aAC                   exsr      zzfil31
720aAC                   endif
720aAC                   move      *off          refrsh
720aAC     end31i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
600bA*----------------------------------------------------------------
600bA*
600bA*  SCPREVUPD  -  Update previous screen stack
600bA*
600bAC     scPrevUpd     begsr

     C                   select

     *   Screen 1 is the 'launch' screen.
     *     Therefore, clear the previous screen list.

     C                   when      nxtscr = '02 '
     C                             or nxtscr = '02a'
     C                   exsr      zzclrdsprvscr
     C                   goto      endprevupd

     *   We do not want to return to the following screens.
     *      - Screen 21 (Assign new license)
     *      - Screen 24 (Pull n Pallet)
     *      - Screen 28 (No more pallets)
500gA*      - Screen 30 (Assign Flw/Brk Rpl license)
720aA*      - Screen 31 UCI Tracking - Scanning

     C                   when      prvscr = '21 '
     C                             or prvscr = '24 '
     C                             or prvscr = '28 '
500gAC                             or prvscr = '30 '
720aAC                             or prvscr = '31 '
     C                   goto      endprevupd

     *   Otherwise, we want to return to the screen we just came from.

     C                   other
     C                   eval      prvcount = prvcount + 1
     C                   endsl

     C     prvcount      occur     dsprvscr
     C                   eval      dsscr = prvscr

     C     endPrevUpd    endsr
     *----------------------------------------------------------------
     *
     *  SCPREV  -  Previous screen
     *
     C     scprev        begsr
     C                   eval      refrsh = *off

     * First, get last screen from list of previous screens.

     C                   if        prvcount = 0
     C                   eval      lastscr = 'EOJ'
     C                   eval      $preturn = '*CANCEL'
     C                   else
     C     prvcount      occur     dsprvscr
     C                   eval      lastscr = dsscr
     C                   eval      prvcount = prvcount - 1
     C                   endif

     * First, add current screen to list of previous screens.

     C                   select
     C                   when      lastscr = 'EOJ'
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $preturn = '*CANCEL'
     C                   when      lastscr = '01 '
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   when      lastscr = '02a'
     C                   exsr      scr02ai
     C                   when      lastscr = '02b'
     C                   exsr      scr02bi
     C                   when      lastscr = '02c'
     C                   exsr      scr02ci
     C                   when      lastscr = '02d'
     C                   exsr      scr02di
     C                   when      lastscr = '03 '
     C                   exsr      scr03i
     C                   when      lastscr = '03a'
     C                   exsr      scr03ai
700cAC                   when      lastscr = '03b'
700cAC                   exsr      scr03bi
     C                   when      lastscr = '04 '
     C                   exsr      scr04i
     C                   when      lastscr = '05 '
     C                   exsr      scr05i
     C                   when      lastscr = '06 '
     C                   exsr      scr06i
     C                   when      lastscr = '07 '
     C                   exsr      scr07i
     C                   when      lastscr = '08 '
     C                   exsr      scr08i
     C                   when      lastscr = '09 '
     C                   exsr      scr09i
     C                   when      lastscr = '21 '
     C                   exsr      scr21i
     C                   when      lastscr = '22 '
     C                   exsr      scr22i
     C                   when      lastscr = '23 '
     C                   exsr      scr23i
     C                   when      lastscr = '24 '
     C                   eval      refrsh = *on
     C                   exsr      scr24i
     C                   when      lastscr = '25 '
     C                   eval      refrsh = *on
     C                   eval      curpal = curpal - 1
     C                   if        curpal = 0 and $ppulled > 0
     C                   exsr      scr27i
     C                   else
     C                   exsr      scr25i
     C                   endif
     C                   when      lastscr = '26 '
     C                   exsr      scr26i
     C                   when      lastscr = '27 '
     C                   exsr      scr27i
     C                   when      lastscr = '28 '
     C                   exsr      scr28i
500cAC                   when      lastscr = '29 '
500cAC                   exsr      scr29i
500gAC                   when      lastscr = '30 '
500gAC                   exsr      scr30i
720aAC                   when      lastscr = '31 '
720aAC                   exsr      scr31i
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   move      'EOJ'         nxtscr
     C                   eval      $preturn = '*CANCEL'
500jAC                   eval      *inlr = *on
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr01i
     Csr                 goto      endsc1
     C                   endif
700cA*
700cA*  Test for F8 - Chg Lcns
700cA*
700cAC                   if        *inkh
700cAC                   move      *on           refrsh
700cAC                   eval      prvscr = savscr
700cAC                   exsr      scPrevUpd
700cAC                   exsr      scr03bi
700cACsr                 goto      endsc1
700cAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $preturn = '*CANCEL'
500jAC                   eval      *inlr = *on
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
600bDC**                 exsr      scnext
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2a -  Screen 2a
     *
     C     sc2a          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
500jAC                   exsr      zzpulrtn
     C                   exsr      scprev
     C                   goto      endsc2a
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02ai
     C                   goto      endsc2a
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
500jAC                   exsr      zzpulrtn
     C                   exsr      scprev
     C                   goto      endsc2a
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2a
     C     cmdtkn        cabeq     *on           endsc2a
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2a
     C     error         cabeq     *on           endsc2a
     C                   exsr      zzupd2a
     C     error         cabeq     *on           endsc2a
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2a
     C     cmdtkn        cabeq     *on           endsc2a
     *
600bDC**                 exsr      scnext
     C     endsc2a       endsr
     *----------------------------------------------------------------
     *
     *  SC2b -  Screen 2b
     *
     C     sc2b          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc2b
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02bi
     C                   goto      endsc2b
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc2b
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2b
     C     cmdtkn        cabeq     *on           endsc2b
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2b
     C     error         cabeq     *on           endsc2b
     C                   exsr      zzupd2b
     C     error         cabeq     *on           endsc2b
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2b
     C     cmdtkn        cabeq     *on           endsc2b
     *
600bDC**                 exsr      scnext
     C     endsc2b       endsr
     *----------------------------------------------------------------
     *
     *  SC2c -  Screen 2c
     *
     C     sc2c          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc2c
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02ci
     C                   goto      endsc2c
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc2c
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2c
     C     cmdtkn        cabeq     *on           endsc2c
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2c
     C     error         cabeq     *on           endsc2c
     C                   exsr      zzupd2c
     C     error         cabeq     *on           endsc2c
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2c
     C     cmdtkn        cabeq     *on           endsc2c
     *
600bDC**                 exsr      scnext
     C     endsc2c       endsr
     *----------------------------------------------------------------
     *
     *  SC2d -  Screen 2d
     *
     C     sc2d          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc2d
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02di
     C                   goto      endsc2d
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc2d
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2d
     C     cmdtkn        cabeq     *on           endsc2d
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2d
     C     error         cabeq     *on           endsc2d
     C                   exsr      zzupd2d
     C     error         cabeq     *on           endsc2d
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2d
     C     cmdtkn        cabeq     *on           endsc2d
     *
600bDC**                 exsr      scnext
     C     endsc2d       endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr03i
     Csr                 goto      endsc3
     C                   endif
700cA*
700cA*  Test for F8 - Chg Lcns
700cA*
700cAC                   if        *inkh
700cAC                   move      *on           refrsh
700cAC                   eval      prvscr = savscr
700cAC                   exsr      scPrevUpd
700cAC                   exsr      scr03bi
700cACsr                 goto      endsc3
700cAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
600bDC**                 exsr      scnext
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC3a -  Screen 3a
     *
     C     sc3a          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc3a
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr03ai
     C                   goto      endsc3a
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc3a
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3a
     C     cmdtkn        cabeq     *on           endsc3a
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3a
     C     error         cabeq     *on           endsc3a
     C                   exsr      zzupd3a
     C     error         cabeq     *on           endsc3a
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3a
     C     cmdtkn        cabeq     *on           endsc3a
     *
600bDC**                 exsr      scnext
     C     endsc3a       endsr
     *----------------------------------------------------------------
700cA*
700cA*  SC3b -  Screen 3b
700cA*
700cAC     sc3b          begsr
700cA*
700cA*  Test for F12 - Previous
700cA*
700cAC                   if        *inkl
700cAC                   exsr      scprev
700cAC                   Clear                   w3lic
700cAC                   goto      endsc3b
700cAC                   endif
700cA*
700cA*  Test for other command keys BEFORE verification and update.
700cA*
700cAC                   move      '*BEFORE '    cmdchk
700cAC                   exsr      zzcmd3b
700cAC     cmdtkn        cabeq     *on           endsc3b
700cA*
700cA*  Some other key pressed.
700cA*
700cA*     Check input and write/update record.
700cA*
700cAC                   exsr      zzchk3b
700cAC     error         cabeq     *on           endsc3b
700cAC                   exsr      zzupd3b
700cAC     error         cabeq     *on           endsc3b
700cA*
700cA*  Test for other command keys AFTER verification and update.
700cA*
700cAC                   move      '*AFTER  '    cmdchk
700cAC                   exsr      zzcmd3b
700cAC     cmdtkn        cabeq     *on           endsc3b
700cA*
700cAC     endsc3b       endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr04i
     Csr                 goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
600bDC**                 exsr      scnext
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
600bDC**                 exsr      scnext
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr06i
     Csr                 goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc6
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
600bDC**                 exsr      scnext
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr07i
     Csr                 goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
600bDC**                 exsr      scnext
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     C                   goto      endsc8
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
600bDC**                 exsr      scnext
     C     endsc8        endsr
     *----------------------------------------------------------------
     *
     *  SC9  -  Screen 9
     *
     C     sc9           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr09i
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
600bDC**                 exsr      scnext
     C     endsc9        endsr
     *----------------------------------------------------------------
     *
     *  SC21 -  Screen 21
     *
     C     sc21          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc21
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr21i
     Csr                 goto      endsc21
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc21
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd21
     C     cmdtkn        cabeq     *on           endsc21
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk21
     C     error         cabeq     *on           endsc21
     C                   exsr      zzupd21
     C     error         cabeq     *on           endsc21
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd21
     C     cmdtkn        cabeq     *on           endsc21
     *
600bDC**                 exsr      scnext
     C     endsc21       endsr
     *----------------------------------------------------------------
     *
     *  SC22 -  Screen 22
     *
     C     sc22          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc22
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr22i
     Csr                 goto      endsc22
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc22
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd22
     C     cmdtkn        cabeq     *on           endsc22
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk22
     C     error         cabeq     *on           endsc22
     C                   exsr      zzupd22
     C     error         cabeq     *on           endsc22
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd22
     C     cmdtkn        cabeq     *on           endsc22
     *
600bDC**                 exsr      scnext
     C     endsc22       endsr
     *----------------------------------------------------------------
     *
     *  SC23 -  Screen 23
     *
     C     sc23          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc23
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr23i
     Csr                 goto      endsc23
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc23
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd23
     C     cmdtkn        cabeq     *on           endsc23
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk23
     C     error         cabeq     *on           endsc23
     C                   exsr      zzupd23
     C     error         cabeq     *on           endsc23
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd23
     C     cmdtkn        cabeq     *on           endsc23
     *
600bDC**                 exsr      scnext
     C     endsc23       endsr
     *----------------------------------------------------------------
     *
     *  SC24 -  Screen 24
     *
     C     sc24          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc24
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr24i
     Csr                 goto      endsc24
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc24
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd24
     C     cmdtkn        cabeq     *on           endsc24
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk24
     C     error         cabeq     *on           endsc24
     C                   exsr      zzupd24
     C     error         cabeq     *on           endsc24
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd24
     C     cmdtkn        cabeq     *on           endsc24
     *
600bDC**                 exsr      scnext
     C     endsc24       endsr
     *----------------------------------------------------------------
     *
     *  SC25 -  Screen 25
     *
     C     sc25          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc25
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr25i
     Csr                 goto      endsc25
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc25
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd25
     C     cmdtkn        cabeq     *on           endsc25
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk25
     C     error         cabeq     *on           endsc25
     C                   exsr      zzupd25
     C     error         cabeq     *on           endsc25
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd25
     C     cmdtkn        cabeq     *on           endsc25
     *
600bDC**                 exsr      scnext
     C     endsc25       endsr
     *----------------------------------------------------------------
     *
     *  SC26 -  Screen 26
     *
     C     sc26          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc26
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr26i
     Csr                 goto      endsc26
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc26
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd26
     C     cmdtkn        cabeq     *on           endsc26
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk26
     C     error         cabeq     *on           endsc26
     C                   exsr      zzupd26
     C     error         cabeq     *on           endsc26
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd26
     C     cmdtkn        cabeq     *on           endsc26
     *
600bDC**                 exsr      scnext
     C     endsc26       endsr
     *----------------------------------------------------------------
     *
     *  SC27 -  Screen 27
     *
     C     sc27          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc27
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr27i
     Csr                 goto      endsc27
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc27
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd27
     C     cmdtkn        cabeq     *on           endsc27
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk27
     C     error         cabeq     *on           endsc27
     C                   exsr      zzupd27
     C     error         cabeq     *on           endsc27
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd27
     C     cmdtkn        cabeq     *on           endsc27
     *
600bDC**                 exsr      scnext
     C     endsc27       endsr
     *----------------------------------------------------------------
     *
     *  SC28 -  Screen 28
     *
     C     sc28          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     C                   goto      endsc28
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr28i
     Csr                 goto      endsc28
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc28
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd28
     C     cmdtkn        cabeq     *on           endsc28
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk28
     C     error         cabeq     *on           endsc28
     C                   exsr      zzupd28
     C     error         cabeq     *on           endsc28
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd28
     C     cmdtkn        cabeq     *on           endsc28
     *
600bDC**                 exsr      scnext
     C     endsc28       endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  SC29 -  Screen 29
500cA*
500cAC     sc29          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc29
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr29i
     Csr                 goto      endsc29
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc29
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd29
     C     cmdtkn        cabeq     *on           endsc29
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk29
     C     error         cabeq     *on           endsc29
     C                   exsr      zzupd29
     C     error         cabeq     *on           endsc29
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd29
     C     cmdtkn        cabeq     *on           endsc29
     *
600bDC**                 exsr      scnext
     C     endsc29       endsr
500gA*----------------------------------------------------------------
500gA*
500gA*  SC30 -  Screen 30
500gA*
500gAC     sc30          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      *on           refrsh
     C                   exsr      scprev
     Csr                 goto      endsc30
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr30i
     Csr                 goto      endsc30
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scprev
     Csr                 goto      endsc30
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd30
     C     cmdtkn        cabeq     *on           endsc30
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk30
     C     error         cabeq     *on           endsc30
     C                   exsr      zzupd30
     C     error         cabeq     *on           endsc30
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd30
     C     cmdtkn        cabeq     *on           endsc30
     *
600bDC**                 exsr      scnext
     C     endsc30       endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  SC31 -  Screen 31
720aA*
720aAC     sc31          begsr
720aA*
720aA*  Test for F3 - Exit
720aA*
720aAC                   if        *inkc
720aAC                   move      *on           refrsh
720aAC                   exsr      scprev
720aAC                   goto      endsc31
720aAC                   endif
720aA*
720aA*  Test for F5 - Refresh
720aA*
720aAC                   if        *inke
720aAC                   move      *on           refrsh
720aAC                   exsr      scr31i
720aAC                   goto      endsc31
720aAC                   endif
720aA*
720aA*  Test for F12 - Previous
720aA*
720aAC                   if        *inkl
720aAC                   exsr      scprev
720aAC                   goto      endsc31
720aAC                   endif
720aA*
720aA*  Test for other command keys BEFORE verification and update.
720aA*
720aAC                   move      '*BEFORE '    cmdchk
720aAC                   exsr      zzcmd31
720aAC     cmdtkn        cabeq     *on           endsc31
720aA*
720aA*  Some other key pressed.
720aA*
720aA*     Check input and write/update record.
720aA*
720aAC                   exsr      zzchk31
720aAC     error         cabeq     *on           endsc31
720aAC                   exsr      zzupd31
720aAC     error         cabeq     *on           endsc31
720aA*
720aA*  Test for other command keys AFTER verification and update.
720aA*
720aAC                   move      '*AFTER  '    cmdchk
720aAC                   exsr      zzcmd31
720aAC     cmdtkn        cabeq     *on           endsc31
720aA*
720aAC     endsc31       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
640aD **
640aD ** Program may be called from batch when called with *ADJUST.
640aD ** Open display file for all other commands.
640aDC**                 if        opn_lt210fm <> *on
640aDC**                           and $pcmd <> '*ADJUST'
640aDC**                 open      LT210FM
640aDC**                 eval      opn_lt210fm = *on
640aDC**                 endif
640aDC**
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      'CVTDTE'
720aAC                   parm                    $cvtdt
720aAC                   eval      curdate = $cvd8o
     *
     *  Initialize special keys
     *
     C                   eval      enterStat = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
640aD **
640aD ** Initialize message handling
640aD **
640aDC**                 if        $pcmd <> '*ADJUST'
640aDC**                 exsr      zmimsg
640aDC**                 endif
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   eval      #pgmq = #pgm
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
     C                   move      *on           sclear
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

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   move      'PIR1005'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
700cA*----------------------------------------------------------------
700cA*   PIR2007  Invalid slot, slot inactive.
700cA*
700cAC     zm2007        begsr
700cAC                   eval      #msgid = 'PIR2007'
700cAC                   eval      #msgtp = '*DIAG  '
700cAC                   eval      $md = *blanks
700cAC                   exsr      zmpmsg
700cAC                   endsr
700cA*----------------------------------------------------------------
700cA*   PIR2104  Item does not match required item to pull
700cA*
700cAC     zm2104        begsr
700cAC                   move      'PIR2104'     #msgid
700cAC                   move      '*DIAG  '     #msgtp
700cAC                   exsr      zmpmsg
700cAC                   endsr
700cA*----------------------------------------------------------------
700cA*   PIR2105  FIFO information differs
700cA*
700cAC     zm2105        begsr
700cAC                   move      'PIR2105'     #msgid
700cAC                   move      '*DIAG  '     #msgtp
700cAC                   exsr      zmpmsg
700cAC                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be greater than zero.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Value is not within range
     *
     C     zm0112        begsr
     C                   move      'PIR0112'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
500gA*----------------------------------------------------------------
500gA*   RC20008 License/Label already scanned in.
500gA*
500gAC     zm2019        begsr
     C                   eval      #msgid = 'RC20019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20012 License not found in tracking files.
     *
     C     zm2012        begsr
     C                   move      'RC20012'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20013 License not found in scanned slot.
     *
     C     zm2013        begsr
     C                   move      'RC20013'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20016 Scan pallet on floor.
     *
     C     zm2016        begsr
     C                   move      'RC20016'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
610cDC**---------------------------------------------------------------
610cDC**  RC20017 Wrong license plate scanned
610cDC**
610cDC**   zm2017        begsr
610cDC**                 move      'RC20017'     #msgid
610cDC**                 move      '*DIAG  '     #msgtp
610cDC**                 exsr      zmpmsg
610cDC**                 endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off
     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2a  Screen 2a error checking.
     *----------------------------------------------------------------

     C     zzchk2a       begsr
     C                   eval      error = *off

     *  Something must be entered.

     C                   if        w2opt = ' ' and w2upc = ' '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Option or UPC must be entered'
     C                   exsr      zm0105
     C                   goto      endck2a
     C                   endif

     *  Verify option.

     C                   if        w2opt <> ' '
     C                             and w2opt <> 'Y'
     C                             and w2opt <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Y/N option'
     C                   exsr      zm1005
     C                   goto      endck2a
     C                   endif

     *  If option entered, then skip UPC check.

     C     w2opt         cabne     ' '           endck2a

     *  Check UPC code.

415cAC                   call      'CVTBAR'
415cAC                   parm      '*UPC'        $cbcmd            8
415cAC                   parm      w2upc         $cbbar          100
415cAC                   parm                    $cbcod            3 0
415cAC                   parm                    $cbdec            1 0
415cAC                   parm                    $cbdsc           30
415cAC                   parm                    $cbpos            3 0
415cAC                   parm                    $cbtyp            1 0
415cAC                   parm                    $cbv1            11 3
415cAC                   parm                    $cbv2            50
415cAC                   parm                    $cbrtn            8
415cAC                   parm                    $cberm           60
417lA*
415cAC                   if        $cbrtn <> '*OK'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = $cberm
     C                   exsr      zm0105
     C                   goto      endck2a
415cAC                   endif

     *    Get item associated with UPC code.
417lA
417lAC                   movel     $cbv2         $cstr
417lAC                   call      'ADJUST'
417lAC                   parm      '*RIGHT  '    $ccmd             8
417lAC                   parm                    $cstr            30
417lAC                   eval      w2upc = *blanks
417lAC                   move      $cstr         kyupc

417jAC     keyup2        chain     upc2
417jAC                   if        not %found
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'UPC does not match item'
     C                   exsr      zm0105
     C                   goto      endck2a
415cAC                   endif

     C     endck2a       endsr

     *----------------------------------------------------------------
     *  ZZCHK2b  Screen 2b error checking.
     *----------------------------------------------------------------

     C     zzchk2b       begsr
     C                   eval      error = *off
     C     endck2b       endsr

     *----------------------------------------------------------------
     *  ZZCHK2c  Screen 2c error checking.
     *----------------------------------------------------------------

     C     zzchk2c       begsr
     C                   eval      error = *off
     C     endck2c       endsr

     *----------------------------------------------------------------
     *  ZZCHK2d  Screen 2d error checking.
     *----------------------------------------------------------------

     C     zzchk2d       begsr
     C                   eval      error = *off
500oA
500oA*  Verify option.
500oA
500oAC                   if        w2dopt <> 'Y'
500oAC                             and w2dopt <> 'N'
500oAC                   eval      error = *on
500oAC                   eval      *in21 = *on
500oAC                   eval      *in01 = *on
500oAC                   eval      errmsg = *blanks
500oAC                   eval      errmsg = 'Y/N option'
500oAC                   exsr      zm1005
500oAC                   goto      endck2d
500oAC                   endif
500oDC**
500oDC**Verify pallet position is greater than zero.
500oDC**
500oDC**                 if        w2dpos <= 0
500oDC**                 move      *on           error
500oDC**                 eval      *in21 = *on
500oDC**                 eval      *in01 = *on
500oDC**                 eval      erfld = 'Position'
500oDC**                 eval      erfromrng = '1'
500oDC**                 eval      ertorng = %editc(pltpos : 'P')
500oDC**                 exsr      zm0112
500oDC**                 endif
     C     endck2d       endsr

     *----------------------------------------------------------------
     *  ZZCHK3   Screen 3 error checking.
     *----------------------------------------------------------------

     C     zzchk3        begsr
     C                   eval      error = *off

     *  Scanned LP must be same as LP retrieved earlier.

CLDaDC**                 if        w3lic <> W3ldsp
CLDaMC                   if        w3lic <> w3ldspFull
610cAC                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
610cDC**                 eval      errmsg = *blanks
610cDC**                 eval      erlcns = w3ldsp
610cDC**                 eval      erdsp = *blanks
610cDC**                 exsr      zm2017
650bDC***610c            eval      errmsg = 'License'
650bDC***610c            exsr      zm1001
650bMC                   eval      errmsg = 'Wrong License'
600gAC                   exsr      zm0105
700dAC                   eval      prvcount = prvcount -1
     C                   goto      endck3
     C                   endif

     C     endck3        endsr

     *----------------------------------------------------------------
     *  ZZCHK3a  Screen 3a error checking.
     *----------------------------------------------------------------

     C     zzchk3a       begsr
     C                   eval      error = *off

     *  Verify option.

     C                   if        w3opt <> 'Y'  and w3opt <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Y/N option'
     C                   exsr      zm1005
     C                   endif
     C     endck3a       endsr

700cA*----------------------------------------------------------------
700cA*  ZZCHK3b  Screen 3b error checking.
700cA*----------------------------------------------------------------

700cA* Check to see if changed license is valid                    ---
700cAC     zzchk3b       begsr
700cAC                   eval      error = *off
700cAC                   exsr      clr$license
700cAC                   eval      $liToWhseU = *On
700cAC                   eval      $liToWhse = $pWhse
700cAC                   eval      $liToLcnsU = *On
700cAC                   eval      $liToLcns = w3blic
700cA
700cAC                   eval      $dricommand = '*LICENSE'
700cAC                   eval      $drisubcmd  = '%GETLCNS'
700cAC                   eval      $drisys2upd = 'D'
700cAC                   exsr      zzzdricop
700cAC                   if        error
700cAC                   eval      *in21 = *on
700cAC                   eval      *in01 = *on
700cAC                   eval      errmsg = *blanks
700cAC                   eval      erlcns = w3blic
700cAC                   eval      erdsp = *blanks
700cAC                   exsr      zm2012
700dAC                   eval      prvcount = prvcount -1
700cAC                   goto      endchk3b
700cAC                   endif

700cA* If changed license valid check for item information         ---
700cAC                   If        $litoitem <> Htoitem
700cAC                   Eval      Error = *On
700cAC                   eval      *in21 = *on
700cAC                   eval      *in01 = *on
700cAC                   eval      errmsg = *blanks
700cAC                   eval      erdsp = *blanks
700cAC                   exsr      zm2104
700dAC                   eval      prvcount = prvcount -1
700cAC                   goto      endchk3b
700cAC                   EndIf
700cA* If changed license valid check Expiration date information        ---
     C                   If        Hfirstfifoexpd <> 0
700cAC                   If        $LIFIRSTFIFOEXPD <> Hfirstfifoexpd
700cAC                   Eval      Error = *On
700cAC                   eval      *in21 = *on
700cAC                   eval      *in01 = *on
700cAC                   eval      errmsg = *blanks
700cAC                   eval      erdsp = *blanks
700cAC                   exsr      zm2105
700dAC                   eval      prvcount = prvcount -1
700cAC                   goto      endchk3b
700cAC                   EndIf
700cAC                   EndIf
700cA* If changed license valid check Entered date information        ---
     C                   If        Hfirstfifoexpd = 0
700cAC                   If        $LIFIRSTFIFOENTD <> Hfirstfifoentd
700cAC                   Eval      Error = *On
700cAC                   eval      *in21 = *on
700cAC                   eval      *in01 = *on
700cAC                   eval      errmsg = *blanks
700cAC                   eval      erdsp = *blanks
700cAC                   exsr      zm2105
700dAC                   eval      prvcount = prvcount -1
700cAC                   goto      endchk3b
700cAC                   EndIf
700cAC                   EndIf

700cA* Check for valid pulling slot                                ---
700cAC                   exsr      clr$slot
700cAC                   eval      $slwhseu = *on
700cAC                   eval      $slwhse  = $pwhse
700cAC                   eval      $slwhdpu = *on
700cAC                   eval      $slwhdp  = $pwhdp
700cAC                   eval      $sldispu = *on
700cAC                   eval      $sldisp  = $litodisp

700cAC                   eval      $dricommand = '*SLOT'
700cAC                   eval      $drisubcmd  = '%GET'
700cAC                   eval      $drisys2upd = 'D'
700cAC                   exsr      zzzdricop

700cAC                   If        $slstat <> 'A ' or
700cAC                             %subst($sldisp:1:3) = 'RCV' or
720 AC                             %subst($sldisp:1:3) = 'RPA' or
700cAC                             %subst($sldisp:1:3) = 'STG' or
700cAC                             %subst($sldisp:1:3) = 'OSS' or
700cAC                             %subst($sldisp:1:3) = 'USR'
700cAC                   Eval      Error = *On
700cAC                   eval      *in21 = *on
700cAC                   eval      *in01 = *on
700cAC                   eval      errmsg = *blanks
700cAC                   eval      erdsp = *blanks
700cAC                   exsr      zm2007
700dAC                   eval      prvcount = prvcount -1
700cAC                   goto      endchk3b
700cAC                   Else
700cAC                   Eval      $pqty1 = $slstk1
700cAC                   EndIf

700cAC     endchk3b      endsr

     *----------------------------------------------------------------
     *  ZZCHK4   Screen 4 error checking.
     *----------------------------------------------------------------

     C     zzchk4        begsr
     C                   eval      error = *off
     C     endck4        endsr

     *----------------------------------------------------------------
     *  ZZCHK5   Screen 5 error checking.
     *----------------------------------------------------------------

     C     zzchk5        begsr
     C                   eval      error = *off
     C     endck5        endsr

     *----------------------------------------------------------------
     *  ZZCHK6   Screen 6 error checking.
     *----------------------------------------------------------------

     C     zzchk6        begsr
     C                   eval      error = *off
     C     endck6        endsr

     *----------------------------------------------------------------
     *  ZZCHK7   Screen 7 error checking.
     *----------------------------------------------------------------

     C     zzchk7        begsr
     C                   eval      error = *off
     C     endck7        endsr

     *----------------------------------------------------------------
     *  ZZCHK8   Screen 8 error checking.
     *----------------------------------------------------------------

     C     zzchk8        begsr
     C                   eval      error = *off
     C     endck8        endsr

     *----------------------------------------------------------------
     *  ZZCHK9   Screen 9 error checking.
     *----------------------------------------------------------------

     C     zzchk9        begsr
     C                   eval      error = *off
     C     endck9        endsr

     *----------------------------------------------------------------
     *  ZZCHK21  Screen 21 error checking.
     *----------------------------------------------------------------

     C     zzchk21       begsr
     C                   eval      error = *off
600jA
600jA*  Verify license was entered.
600jA
600jAC                   if        w21lic = ' '
600gAC                   eval      error = *on
600gAC                   eval      *in21 = *on
600gAC                   eval      *in01 = *on
600gAC                   eval      errmsg = 'License must be entered'
600gAC                   exsr      zm0105
600gAC                   leavesr
600jAC                   endif
600gA
600gA*  Verify license is not active.
600gA
600gAC                   exsr      clr$license
600gAC                   eval      $liToWhseU = *On
600gAC                   eval      $liToWhse = $pWhse
600gAC                   eval      $liToLcnsU = *On
600gAC                   eval      $liToLcns = w21lic
600gA
600gAC                   eval      $dricommand = '*LICENSE'
600gAC                   eval      $drisubcmd  = '%GETLCNS'
600gAC                   eval      $drisys2upd = 'D'
600gAC                   exsr      zzzdricop
600gAC                   select
600gAC                   when      error
600gAC                   eval      error = *off
600gAC                   when      $drireturn = '*OK'
600gAC                   eval      error = *on
600gAC                   eval      *in21 = *on
600gAC                   eval      *in01 = *on
600gAC                   eval      errmsg = 'License already used'
600gAC                   exsr      zm0105
600gAC                   endsl
750bA*
750bA*  Check LICLOG before accepting this license
750bA*
750bAc                   if        error = *off
750bAC                   eval      $dricommand = '*LICENSE'
750bAC                   eval      $drisubcmd  = '%GETINFO'
750bAC                   eval      $drisys2upd = 'D'
750bAC                   exsr      zzzdricop
750bAc* if we get an ok on the return this means it exist - don't use
750bAC                   if        $drireturn = '*OK'
750bAC                   eval      error = *on
750bAC                   eval      *in21 = *on
750bAC                   eval      *in01 = *on
750bAC                   eval      errmsg = 'License already used'
750bAC                   exsr      zm0105
750bAc                   else
750bAc                   eval      error = *off
750bAC                   endif
750bAC                   endif

     *  Verify For option.

     C                   if        w21psplit <> '1'
     C                             and w21psplit <> '2'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = '"For" option'
     C                   exsr      zm1001
     C                   endif

     C     endck21       endsr

     *----------------------------------------------------------------
     *  ZZCHK22  Screen 22 error checking.
     *----------------------------------------------------------------

     C     zzchk22       begsr
     C                   eval      error = *off

     *  Verify merge option.

     C                   if        w22opt <> 'Y'  and w22opt <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Merge option'
     C                   exsr      zm1005
     C                   endif

     C     endck22       endsr

     *----------------------------------------------------------------
     *  ZZCHK23  Screen 23 error checking.
     *----------------------------------------------------------------

     C     zzchk23       begsr
     C                   eval      error = *off
     C     endck23       endsr

     *----------------------------------------------------------------
     *  ZZCHK24  Screen 24 error checking.
     *----------------------------------------------------------------

     C     zzchk24       begsr
     C                   eval      error = *off
     C     endck24       endsr

     *----------------------------------------------------------------
     *  ZZCHK25  Screen 25 error checking.
     *----------------------------------------------------------------

     C     zzchk25       begsr
     C                   eval      error = *off

     *  Verify merge option.

     C                   if        w25opt <> 'Y'  and w25opt <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Merge option'
     C                   exsr      zm1005
     C                   endif

     C     endck25       endsr

     *----------------------------------------------------------------
     *  ZZCHK26  Screen 26 error checking.
     *----------------------------------------------------------------

     C     zzchk26       begsr
     C                   eval      error = *off
     C     endck26       endsr

     *----------------------------------------------------------------
     *  ZZCHK27  Screen 27 error checking.
     *----------------------------------------------------------------

     C     zzchk27       begsr
     C                   eval      error = *off

     *  Verify license number by getting

600hMC                   exsr      clr$license
600hMC                   eval      $liToWhseU = *On
600hMC                   eval      $liToWhse = $pWhse
600hMC                   eval      $liToLcnsU = *On
600hMC                   eval      $liToLcns = w27lic
600hM
600hMC                   eval      $dricommand = '*LICENSE'
600hMC                   eval      $drisubcmd  = '%GETLCNS'
417bAC                   eval      $drisys2upd = 'D'
417bAC                   exsr      zzzdricop
417bAC                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w27lic
     C                   eval      erdsp = *blanks
     C                   exsr      zm2012
     C                   goto      endchk27
     C                   endif

     *  License must be associated with slot we are working with.

600hMC                   if        $liToWhdp <> $slwhdp  or
600hMC                             $liToAisl <> $slaisl  or
600hMC                             $liToLoc <> $slloc  or
600hMC                             $liToRLvl <> $slrlvl
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w27lic
     C                   eval      erdsp = *blanks
     C                   exsr      zm2013
     C                   goto      endchk27
     C                   endif

     *  Pallet must be on floor.

600hMC                   if        $liToCode <> 'F'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      erlcns = w27lic
     C                   eval      erdsp = *blanks
     C                   eval      erpos = 0
     C                   exsr      zm2016
     C                   goto      endchk27
     C                   endif

     *  Save license pallet position.

600hMC                   eval      licpos = $liToPos

     C     endchk27      endsr

     *----------------------------------------------------------------
     *  ZZCHK28  Screen 28 error checking.
     *----------------------------------------------------------------

     C     zzchk28       begsr
     C                   eval      error = *off
     C     endck28       endsr

500cA*----------------------------------------------------------------
500cA*  ZZCHK29  Screen 29 error checking.
500cA*----------------------------------------------------------------
500cA
500cAC     zzchk29       begsr
     C                   eval      error = *off

     *  Verify pallet position is greater than zero.
     *    and less than slot positions.

     C                   if        w29pos <= 0
     C                             or w29pos > pltpos
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      erfld = 'Position'
     C                   eval      erfromrng = '1'
     C                   eval      ertorng = %editc(pltpos : 'P')
     C                   exsr      zm0112
     C                   endif

     C     endck29       endsr

500gA*----------------------------------------------------------------
500gA*  ZZCHK30  Screen 30 error checking.
500gA*----------------------------------------------------------------
500gA
500gAC     zzchk30       begsr
     C                   eval      error = *off

     *  If license not scanned in, create one.

     C                   if        w30lic = ' '
     C                   eval      w30lic = '*RP'
     C                   goto      endck30
     C                   endif

     *  See if license already scanned.

     C                   eval      kynbr  = w30lic
     C                   eval      kytype = 'P'

     C     wrkey3        setll     workrpl3
     C     wrkey3        reade     workrpl3
     C                   if        not %eof
     C                   eval      error = *on
     C                   eval      erpnbr = w30lic
     C                   eval      erpusr = wruser
     C                   exsr      zm2019
     C                   goto      endck30
     C                   endif

     C     endck30       endsr
720aA*----------------------------------------------------------------
720aA*  ZZCHK31  Screen 31 error checking.
720aA*----------------------------------------------------------------
720aA
720aAC     zzchk31       begsr
720aAC                   eval      error = *off
720aA
720aA*  Verify UCI was scanned.
720aA
720aAC                   if        w31UCI = ' '
720aAC                   eval      error = *on
720aAC                   eval      *in21 = *on
720aAC                   eval      *in01 = *on
720aAC                   eval      errmsg = 'UCI must be scanned'
720aAC                   exsr      zm0105
720aAC                   leavesr
720aAC                   endif
720aA*  Verify UCI has not already been scanned for movement.
720aA*  if the UCI is already assigned to the temp license that is
720aA*  created when the product is put in the USR slot.
720aA*  it has already been scanned, and can not be scanned again.
720aA /free
720aA   w31UCI = %TrimL(w31uci);
720aA   exsr clr$uciinfo;

720aA   $uiWhse = $pwhse;
720aA   $uiuci  = w31uci;
720aA   $uilcns = $plic#;
720aA   $uiApartlts = $ppartime;

720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%VFYCURMV';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA   // if return is *OK we are ready to update the uci
720aA   if $drireturn <> '*OK';
720aA     error = *on;
720aA     *in21 = *on;
720aA     *in01 = *on;
720aA     errmsg = $drimessage;
720aA     exsr zm0105;
720aA     leavesr;
720aA   endif;
720aA /end-free
417lA*
720aA*  Verify UCI is for the correct Item
720aA*  take into account - chgitem
720aA*  will check active confirm item is a match?
720aA /free
720aA   w31UCI = %TrimL(w31uci);
720aA   exsr clr$uciinfo;

720aA   $uiWhse = $pwhse;
720aA   $uiuci  = w31uci;
720aA   $uiitem = $pitem;

720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%CHK4MOVE';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA   // if return is *OK we are ready to update the uci
720aA   if $drireturn <> '*OK';
720aA     error = *on;
720aA     *in21 = *on;
720aA     *in01 = *on;
720aA     errmsg = $drimessage;
720aA     exsr zm0105;
720aA     leavesr;
720aA   endif;
720aA   if $drireturn = '*OK';
          error = *off;
720aA   endif;
720aA   if error;
720aA   endif;
720aA /end-free

720aA
720aA*  Verify UCI scanned is a valid gs1 barcode GTIN Found
720aA
720aAc                   clear                   $barcode
720aAc                   clear                   $barcode2
720aAC                   call      'CVTBAR'
720aAC                   parm      '*ALL'        $cbcmd            8
720aAC                   parm      w31UCI        $cbbar          100
720aAC                   parm                    $cbcod            3 0
720aAC                   parm                    $cbdec            1 0
720aAC                   parm                    $cbdsc           30
720aAC                   parm                    $cbpos            3 0
720aAC                   parm                    $cbtyp            1 0
720aAC                   parm                    $cbv1            11 3
720aAC                   parm                    $cbv2            50
720aAC                   parm                    $cbrtn            8
720aAC                   parm                    $cberm           60
720aAC                   parm      0             $cbven           10 0
720aAC                   parm                    $cvtdata
720aaC                   parm                    $cvtdata2
720aAc                   eval      $barcode = $cvtdata
720aac                   eval      $barcode2 = $cvtdata2
720aAc                   if        not $bcGtinSent
720aAC                   eval      error = *on
720aAC                   eval      *in21 = *on
720aAC                   eval      *in01 = *on
720aAC                   eval      errmsg = 'Invalid UCI Scanned'
720aAC                   exsr      zm0105
720aAC                   leavesr
720aAc                   endif
720aA*  if uci doesn't exist - can only verify that gtin matches item
720aA
720aAC     endck31       endsr


500gA*----------------------------------------------------------------
500gA*  ZZCHKEXIST  See if item exists in base slot.
500gA*----------------------------------------------------------------
500gA
     C     zzchkexist    begsr
600dA
600dAC                   exsr      clr$license
600dAC                   eval      $liToWhseU = *on
600dAC                   eval      $liToWhse = $pWhse
600dAC                   eval      $liToWhdpU = *on
600dAC                   eval      $liToWhdp = $slwhdp
600dAC                   eval      $liToDispU = *on
600dAC                   eval      $liToDisp = $sacdsp
600dAC                   eval      $liToSItemU = *on
600dAC                   eval      $liToSItem = $slitem
600dA
600dAC                   eval      $dricommand = '*LICENSE'
600dAC                   eval      $drisubcmd  = '%CHK4EXIST'
600dAC                   eval      $drisys2upd = 'D'
600daC                   exsr      zzzdricop
     C                   eval      error = *off

     C                   select
     C                   when      $drireturn = '*FOUNDSAME'
     C                   eval      $pinslot = 'Y'
     C                   eval      $psamepos = 'Y'
     C                   eval      $pdiffpos = 'N'
     C                   when      $drireturn = '*FOUNDDIFF'
     C                   eval      $pinslot = 'Y'
     C                   eval      $psamepos = 'N'
     C                   eval      $pdiffpos = 'Y'
600dAC                   when      $drireturn = '*FOUNDBOTH'
600dAC                   eval      $pinslot = 'Y'
600dAC                   eval      $psamepos = 'Y'
600dAC                   eval      $pdiffpos = 'Y'
     C                   other
     C                   eval      $pinslot = 'N'
     C                   eval      $psamepos = 'N'
     C                   eval      $pdiffpos = 'N'
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  ZZCLRDSPRVSCR  Clear multi-occurance DS for previous screens
     *----------------------------------------------------------------

     C     zzclrdsprvscr begsr
     C     1             do        prvcount      i
     C     i             occur     dsprvscr
     C                   eval      dsscr = ' '
     C                   enddo
     C                   eval      prvcount = 0
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
500jA
500jA*    Test for F9 - Skip
500jA
500jAC                   if        *inki
500jAC                   eval      cmdtkn = *on
610bAC                   if        $pprogram = 'LT105'
610bAC                             or $pprogram = 'LT107'
500jAC                   eval      $preturn = '*SKIP'
610bAC                   else
610bAC                   eval      $preturn = '*CANCEL'
610bAC                   endif
500jAC                   eval      nxtscr = 'EOJ'
500jAC                   eval      *inlr = *on
500jAC                   goto      endcm1
500jAC                   endif

     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2a  User defined command keys for screen 2a.
     *----------------------------------------------------------------

     C     zzcmd2a       begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2a       endsr

     *----------------------------------------------------------------
     *  ZZCMD2b  User defined command keys for screen 2b.
     *----------------------------------------------------------------

     C     zzcmd2b       begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2b       endsr

     *----------------------------------------------------------------
     *  ZZCMD2c  User defined command keys for screen 2c.
     *----------------------------------------------------------------

     C     zzcmd2c       begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2c       endsr

     *----------------------------------------------------------------
     *  ZZCMD2d  User defined command keys for screen 2d.
     *----------------------------------------------------------------

     C     zzcmd2d       begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
500oDC**
500oDC**  F10 - Exception
500oDC**
500oDC**                 if        *inkj
500oDC**                 eval      cmdtkn = *on
500oDC**                 eval      inlic# = '*ML'
500oDC**                 exsr      zzexception
500oDC**                 eval      $preturn = '*NOTFND'
500oDC**                 eval      nxtscr = 'EOJ'
500oDC**                 endif
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2d       endsr

     *----------------------------------------------------------------
     *  ZZCMD3   User defined command keys for screen 3.
     *----------------------------------------------------------------

     C     zzcmd3        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
610bA
610bA*    Test for F9 - Skip
610bA
610bAC                   if        *inki
610bAC                   eval      cmdtkn = *on
610bAC                   if        $pprogram = 'LT105'
610bAC                             or $pprogram = 'LT107'
610bAC                   eval      $preturn = '*SKIP'
610bAC                   else
610bAC                   eval      $preturn = '*CANCEL'
610bAC                   endif
610bAC                   eval      nxtscr = 'EOJ'
610bAC                   eval      *inlr = *on
610bAC                   goto      endcm3
610bAC                   endif

700cA*    Test for F8 - Chg Lcns
700cA
700cAC                   if        *inkh
700cAC                   eval      nxtscr = '3b'
700cAC                   endif
     *    F10 - Exception

     C                   if        *inkj
CLDbAC                             and client <> cityline
SGCaAC                             and client <> sgc
CSPbDC**                           and client <> CoastalSunbelt
DRYaAC                             and client <> dairyland
GLPaA *                            and client <> greenleaf
FPRaAC                             and client <> FoodPro
     C                   eval      cmdtkn = *on
610iDC**                 eval      inlic# = '*ML'
610iDC**                 exsr      scr02ai
610iAC                   eval      exerid = 'NOSCAN'
CLDaDC**                 eval      excitm = W3ldsp
CLDaMC                   eval      excitm = w3ldspFull
610iAC                   exsr      zzexception
610iAC                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr

     *----------------------------------------------------------------
     *  ZZCMD3a  User defined command keys for screen 3a.
     *----------------------------------------------------------------

     C     zzcmd3a       begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3a       endsr

700cA*----------------------------------------------------------------
700cA*  ZZCMD3b  User defined command keys for screen 3b.
700cA*----------------------------------------------------------------

700cAC     zzcmd3b       begsr

700cA*  Command keys to check BEFORE verification and update.

700cAC                   if        cmdchk = '*BEFORE '
700cAC                   endif

700cA*  Command keys to check AFTER verification and update.

700cAC                   if        cmdchk = '*AFTER  '
700cAC                   endif
700cAC     endcm3b       endsr

     *----------------------------------------------------------------
     *  ZZCMD4   User defined command keys for screen 4.
     *----------------------------------------------------------------

     C     zzcmd4        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr

     *----------------------------------------------------------------
     *  ZZCMD5   User defined command keys for screen 5.
     *----------------------------------------------------------------

     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr

     *----------------------------------------------------------------
     *  ZZCMD6   User defined command keys for screen 6.
     *----------------------------------------------------------------

     C     zzcmd6        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr

     *----------------------------------------------------------------
     *  ZZCMD7   User defined command keys for screen 7.
     *----------------------------------------------------------------

     C     zzcmd7        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm7        endsr

     *----------------------------------------------------------------
     *  ZZCMD8   User defined command keys for screen 8.
     *----------------------------------------------------------------

     C     zzcmd8        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr

     *----------------------------------------------------------------
     *  ZZCMD9   User defined command keys for screen 9.
     *----------------------------------------------------------------

     C     zzcmd9        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm9        endsr

     *----------------------------------------------------------------
     *  ZZCMD21  User defined command keys for screen 21.
     *----------------------------------------------------------------

     C     zzcmd21       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '

     *    F10 - Exception

     C                   if        *inkj
FPRaAC                             and client <> FoodPro
SFPaAC                             and client <> seashore
     C                   eval      cmdtkn = *on
     C                   eval      inlic# = '*NA'
600bDC**                 exsr      scnext
600bAC                   eval      refrsh = *on
600bAC                   if        $pcmd = '*PULTRAN'
600bAC                   exsr      zzpultran
600bAC                   endif
600bAC                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm21       endsr

     *----------------------------------------------------------------
     *  ZZCMD22  User defined command keys for screen 22.
     *----------------------------------------------------------------

     C     zzcmd22       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm22       endsr

     *----------------------------------------------------------------
     *  ZZCMD23  User defined command keys for screen 23.
     *----------------------------------------------------------------

     C     zzcmd23       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm23       endsr

     *----------------------------------------------------------------
     *  ZZCMD24  User defined command keys for screen 24.
     *----------------------------------------------------------------

     C     zzcmd24       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm24       endsr

     *----------------------------------------------------------------
     *  ZZCMD25  User defined command keys for screen 25.
     *----------------------------------------------------------------

     C     zzcmd25       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm25       endsr

     *----------------------------------------------------------------
     *  ZZCMD26  User defined command keys for screen 26.
     *----------------------------------------------------------------

     C     zzcmd26       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm26       endsr

     *----------------------------------------------------------------
     *  ZZCMD27  User defined command keys for screen 27.
     *----------------------------------------------------------------

     C     zzcmd27       begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '

     *    F10 - Exception

     C                   if        *inkj
     C                   eval      cmdtkn = *on
600bDC**                 exsr      scnext
600bAC                   eval      $ppulled = $ppulled - 1
600bAC                   if        $ppulled = 0
600bAC                   exsr      zzupd27
600bAC                   else
600bAC                   exsr      scr27i
600bAC                   endif
     C                   endif

     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm27       endsr

     *----------------------------------------------------------------
     *  ZZCMD28  User defined command keys for screen 28.
     *----------------------------------------------------------------

     C     zzcmd28       begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm28       endsr

500cA*----------------------------------------------------------------
500cA*  ZZCMD29  User defined command keys for screen 29.
500cA*----------------------------------------------------------------
500cA
500cAC     zzcmd29       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm29       endsr

500gA*----------------------------------------------------------------
500gA*  ZZCMD30  User defined command keys for screen 30.
500gA*----------------------------------------------------------------
500gA
500gAC     zzcmd30       begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm30       endsr

720aA*----------------------------------------------------------------
720aA*  ZZCMD31  User defined command keys for screen 31.
720aA*----------------------------------------------------------------
720aA
720aAC     zzcmd31       begsr
720aAC                   eval      cmdtkn = *off
720aA
720aA*  Command keys to check BEFORE verification and update.
720aA
720aAC                   if        cmdchk = '*BEFORE '
720aA
720aA
720aAC                   endif
720aA
720aA*  Command keys to check AFTER verification and update.
720aA
720aAC                   if        cmdchk = '*AFTER  '
720aAC                   endif
720aAC     endcm31       endsr
720aA
     *----------------------------------------------------------------
     *  zzexception  Write exception to file.
     *----------------------------------------------------------------

     C     zzexception   begsr
600aAC                   eval      currRoutine = 'zzexception'
600aAC                   exsr      phpgmV1V2V3s
500oA
500oA*    Write an item exception record.
500oA
500oAC                   eval      exwhse = $slwhse
500oAC                   eval      exwhdp = $slwhdp
500oAC                   eval      exstyp = $slstyp
500oAC                   eval      exitem = $slitem
500oAC                   eval      exfdis = $sldisp
610iDC**                 eval      extdis = *blanks
610iMC                   eval      extdis = $pprogram
610iDC**                 eval      extask = 'REPL'
610iMC                   eval      extask = 'LCNS'
500oAC                   eval      $cvcmd = '*CURCMD '
500oAC                   call      'CVTDTE'
500oAC                   parm                    $cvtdt
500oAC                   eval      exgdte = $cvd8o
500oAC                   time                    exgtim
500oAC                   eval      exgby = #user
500oAC                   eval      exesta = '1 '
500oAC                   write     exrec
500oA
610iAC                   eval      excitm = ' '
600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
417cA
     C                   eval      w1slot = curslot
417cAC                   if        curposcod = 'F'
417cAC                   eval      w1ploc = ' Floor pos'
417cAC                   else
417cAC                   eval      w1ploc = '  Slot pos'
417cAC                   endif
     C                   z-add     curpos        w1ppos
417cA
     C                   if        licexists and tracklevel <> tLow
     C                   eval      w1pull = 'LP ' + curlic#
     C                   else
500eDC**                 eval      w1pull = 'pallet w/o LP'
500eMC                   eval      w1pull = 'pallet'
     C                   endif
417cA
417cA*  Warn user if multiple LP's exist for item in the slot
417cA*    (Future enhancement)
417cAC                   eval      multiflag = *off
610gAC                   eval      *in91 = *on
417cA
417cAC                   if        multiflag
417cAC                   eval      wrntxt = 'Multiple LPs exist for item'
417cAC                   else
417cAC                   eval      wrntxt = ' '
417cAC                   endif
610gA
610gA* Commandeering wrntxt to display 'To' slot.
610gA
610gAC                   if        %parms >= 33
610gAC                   eval      wrntxt = '  To: ' + %trim($ptoslot)
610gAC                   eval      *in91 = *off
610gAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2a  Fill screen 2a fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2a       begsr
     C                   eval      w2opt = ' '
     C                   eval      w2upc = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2b  Fill screen 2b fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2b       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2c  Fill screen 2c fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2c       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2d  Fill screen 2d fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2d       begsr
500oAC                   eval      w2dopt = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3        begsr
417cA
     C                   eval      w3slot = curslot
417cAC                   if        curposcod = 'F'
417cAC                   eval      w3ploc = ' Floor pos'
417cAC                   else
417cAC                   eval      w3ploc = '  Slot pos'
417cAC                   endif
     C                   z-add     curpos        w3ppos
CLDaDC**                 eval      w3ldsp = curlic#
CLDaAC                   eval      w3ldspFull = curlic#
700aAC
700aAC                   exsr      zzgetsyop
CLDaAC
CLDaA /free
CLDaA     licLen = %len(%trimr(curlic#));
CLDcA     Select;
CLDcA       when client = cityline;
CLDcA         w3ldsp = w3ldspFullnone;
CLDcA       other;
CLDaA         if licLen > 3 and client = cityline or
SGCaA           licLen > 3 and client = sgc      or
CSPaA           licLen > 3 and client = CoastalSunbelt or
700aA           opdspl = 'Y';
CLDaA           w3ldsp = %subst(curlic#: licLen-2 : 3);
CLDaA         else;
CLDaA           w3ldsp = curlic#;
CLDaA         endif;
CLDcA     endsl;
CLDaA /end-free
CLDaAC
     C                   eval      w3lic  = ' '
417cA
417cA*  Warn user if multiple LP's exist for item in the slot
417cA*    (Future enhancement)
417cAC                   eval      multiflag = *off
610gAC                   eval      *in91 = *on
417cA
417cAC                   if        multiflag
417cAC                   eval      wrntxt = 'Multiple LPs exist for item'
417cAC                   else
417cAC                   eval      wrntxt = ' '
417cAC                   endif
610gA
610gA* Commandeering wrntxt to display 'To' slot.
610gA
610gAC                   if        %parms >= 33
610gAC                   eval      wrntxt = '  To: ' + %trim($ptoslot)
610gAC                   eval      *in91 = *off
610gAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3a  Fill screen 3a fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3a       begsr
     C                   eval      w3opt = 'N'
     C                   endsr

700cA*----------------------------------------------------------------
700cA*  ZZFIL3b  Fill screen 3a fields with info from file.
700cA*----------------------------------------------------------------

700cAC     zzfil3b       begsr
700cAC                   Clear                   w3blic

700cA* Get information from license system said to pull and        ---
700cA* hold the item, and FIFO date for edit checking              ---

700cAC                   eval      error = *off
700cAC                   exsr      clr$license
700cAC                   eval      $liToWhseU = *On
700cAC                   eval      $liToWhse = $pWhse
700cAC                   eval      $liToLcnsU = *On
700cAC                   eval      $liToLcns = curlic#
700cA
700cAC                   eval      $dricommand = '*LICENSE'
700cAC                   eval      $drisubcmd  = '%GETLCNS'
700cAC                   eval      $drisys2upd = 'D'
700cAC                   exsr      zzzdricop

700cAC                   Eval      Htoitem      = $litoitem
700cAC                   Eval      Hfirstfifoexpd = $LIFIRSTFIFOEXPD
700cAC                   Eval      Hfirstfifoentd = $LIFIRSTFIFOENTD

700cAC                   endsr

     *----------------------------------------------------------------
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil4        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil5        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil6        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil7        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil8        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL9   Fill screen 9 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil9        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL21  Fill screen 21 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil21       begsr

     *  Field W21DESC should be inizialized before calling this routine
     *  The field identifies why a license needs to be assigned.

     C                   eval      w21lic = ' '

     *  Set the 'For' field.

     *    When we are pulling a partial quantity.

     C                   select
     C                   when      $pcmd = '*PULTRAN'

     C                   select

600cA*      When tracktsplit is 1 (orig LP stays with leftover qty in From slot
600cA*      set w21psplit to 1 (new LP goes with qty going into slot)

     C                   when      tracktsplit = '1'
     C                   eval      w21psplit = '1'
     C                   eval      *in92 = *on

600cA*      when tracktsplit is 2 (orig LP goes with qty being tfr/rpl)
600cA*      set w21psplit to 2 (new LP goes with leftover qty)

     C                   when      tracktsplit = '2'
     C                   eval      w21psplit = '2'
     C                   eval      *in92 = *on

     C                   other
     C                   eval      w21psplit = ' '
     C                   eval      *in92 = *off

     C                   endsl

     *    When we are putting away a partial quantity.

     C                   other

     C                   select

600cA*      When trackpsplit is 1 (orig LP goes with qty going into slot)
600cA*      set w21psplit to 2 (new LP goes with leftover qty)

     C                   when      trackpsplit = '1'
600cDC**                 eval      w21psplit = '1'
600cMC                   eval      w21psplit = '2'
     C                   eval      *in92 = *on

600cA*      when trackpsplit is 2 (orig LP goes with last qty put into slot - l
600cA*      set w21psplit to 1 (new LP goes with qty going into slot)

     C                   when      trackpsplit = '2'
600cDC**                 eval      w21psplit = '2'
600cMC                   eval      w21psplit = '1'
     C                   eval      *in92 = *on

     C                   other
     C                   eval      w21psplit = ' '
     C                   eval      *in92 = *off

     C                   endsl

     C                   endsl

     C     endfil21      endsr

     *----------------------------------------------------------------
     *  ZZFIL22  Fill screen 22 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil22       begsr
     C                   eval      w22opt = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL23  Fill screen 23 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil23       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL24  Fill screen 24 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil24       begsr
     C                   exsr      zznumpostfix
     C                   eval      w24pull = %trim(%editc(curpal:'P'))
     C                                     + numpostfix
     C                                     + ' pallet'
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL25  Fill screen 25 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil25       begsr
     C                   exsr      zznumpostfix
     C                   eval      w25pos = %trim(%editc(curpal:'P'))
     C                                     + numpostfix
     C                                     + ' pallet'
     C                   eval      w25opt = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL26  Fill screen 26 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil26       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL27  Fill screen 27 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil27       begsr
     C                   eval      w27lic = ' '
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL28  Fill screen 28 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil28       begsr
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZFIL29  Fill screen 29 fields with info from file.
500cA*----------------------------------------------------------------
500cA
500cAC     zzfil29       begsr
     C                   eval      w29pos = 0
     C                   endsr

500gA*----------------------------------------------------------------
500gA*  ZZFIL30  Fill screen 30 fields with info from file.
500gA*----------------------------------------------------------------
500gA
500gAC     zzfil30       begsr

     C                   eval      w30lic = ' '

     C     endfil30      endsr

720aA*----------------------------------------------------------------
720aA*  ZZFIL31  Fill screen 31 fields with info from file.
720aA*----------------------------------------------------------------
720aA
720aAC     zzfil31       begsr
720aA
720aA*  Field W21DESC should be inizialized before calling this routine
720aA*  The field identifies why UCI needs to be scanned.
720aA
720aAC                   eval      w31UCI = ' '

720aAC* if uci sent in from IT253 load so user doesn't have to scan again
720aAC                   if        %parms >= 35
720aAC                   eval      w31uci = $puci
720aAc                   endif
720aA
720aAC     endfil31      endsr

     *----------------------------------------------------------------
     *  ZZGETITEM   Get item information.
     *----------------------------------------------------------------

     C     zzgetitem     begsr

     *  Get item information

     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

600eA*----------------------------------------------------------------
600eA*  ZZGETLCNS   Get license information.
600eA*----------------------------------------------------------------
600eA
600eAC     zzgetlcns     begsr

     C                   if        $plic# = '*MULTIPLE'
     C                             or $plic# = '*SI'
     C                   eval      $liToPos = 1
     C                   leavesr
     C                   endif

     C                   exsr      clr$license
     C                   eval      $liToWhseU = *On
     C                   eval      $liToWhse = $pWhse
     C                   eval      $liToLcnsU = *On
     C                   eval      $liToLcns = $plic#

     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETSLOT   Get slot information.
     *----------------------------------------------------------------

     C     zzgetslot     begsr

     * Get info for slot and check for associated virtual slots.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pslot

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Get slot definition for slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $pwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
600eAC                   eval      error = *off
600eAC                   eval      $sdpos = 1
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETTRACK  Get tracking options.
     *----------------------------------------------------------------

     C     zzgettrack    begsr

     C                   eval      $lcmd = *blanks
     C                   eval      $lprg = #pgm
     C                   eval      $lwhse2 = $pwhse
     C                   eval      $ltrackitem = $imltrk
500aDC**                 eval      $ltrackpos  = 'N'

     C                   call      'GETTRACK'
     C                   parm                    $lparm

     C                   eval      tracklevel  = $ltrackitem
     C                   eval      trackitem   = $ltrackitem
     C                   eval      trackpos    = $ltrackpos
     C                   eval      trackposmrg = $lposmrg
     C                   eval      trackposrtn = $lposrtn
500dMC                   eval      trackpsplit  = $lpsplit
500dAC                   eval      tracktsplit  = $ltsplit

     C                   endsr

610dDC**---------------------------------------------------------------
610dDC** ZZINVCNTB   Inventory count Before Inv count file updated.
610dDC**---------------------------------------------------------------
610dDC**
610dDC**   zzinvcntb     begsr
610dDC**                 eval      currRoutine = 'zzinvcntb'
610dDC**                 exsr      phpgmV1V2V3s
610dDC**
610dDC** First see if license exists for slot.
610dDC**
610dDC**                 exsr      clr$license
610dDC**                 eval      $liToWhseU = *on
610dDC**                 eval      $liToWhse = $pWhse
610dDC**                 eval      $liToWhdpU = *on
610dDC**                 eval      $liToWhdp = $slwhdp
610dDC**                 eval      $liToDispU = *on
610dDC**                 eval      $liToDisp = $sldisp
610dDC**
610dDC**                 eval      $dricommand = '*LICENSE'
610dDC**                 eval      $drisubcmd  = '%GETSLTLIC'
610dDC**                 eval      $drisys2upd = 'D'
610dDC**                 exsr      zzzdricop
610dDC**
610dDC**                 if        error
610dDC**                           or $drireturn <> '*OK'
610dDC**                           or $liToLcns = '*NONE'
610dDC**                 exsr      licnf
610dDC**                 endif
610dDC**                 eval      error = *off
610dDC**
610dDC**                 eval      curlic#   = $liToLcns
610dDC**                 eval      $plic#    = $liToLcns
610dDC**                 eval      curpos    = $liToPos
610dDC**                 eval      $pslotpos = $liToPos
610dDC**                 eval      curposcod = $liToCode
610dDC**
610dDC**                 exsr      phpgmV1V2V3e
610dDC**                 endsr

500lA*----------------------------------------------------------------
500lA*  ZZINVCOUNT   Inventory Count - Just send back info.
500lA*----------------------------------------------------------------
500lA
500lAC     zzinvcount    begsr

     *  Send back current lic# and entered slot position.

     C                   eval      $plic#    = curlic#
     C                   eval      $pslotpos = w29pos
     C                   eval      $pnexttask = 'INVCNT'

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
500gA
500gA*  Define key for WORKRPL3 file.
500gA
500gAC     wrkey3        klist
500gAC                   kfld                    $pwhse
500gAC                   kfld                    kynbr
500gAC                   kfld                    kytype
500gA
500gA*  Define key for UPC2 file.
500gA
417bAC     keyup2        klist
417bAC                   kfld                    $pwhse
417bAC                   kfld                    $pitem
417bAC                   kfld                    kyupc
700aA*
700aAC     opkey         klist
700aAC                   kfld                    opwhse
700aAC                   kfld                    opcode
500gA
     C                   eval      #pgmq = #pgm
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
600aAC                   eval      currRoutine = 'zzinz2'
600aAC                   exsr      phpgmV1V2V3s
     C                   setoff                                       kckl
     C                   move      *on           refrsh
640aD **
640aD ** Program may be called from batch when called with *ADJUST.
640aD ** Open display file for all other commands.
640aDC**                 if        opn_lt210fm <> *on
640aDC**                           and $pcmd <> '*ADJUST'
640aDC**                 open      LT210FM
640aDC**                 eval      opn_lt210fm = *on
640aDC**                 endif

     * See if we are just closing down.

     C                   if        $pcmd = '*CLOSE'
     C                   exsr      zzzdriclose
     C                   eval      nxtscr = 'EOJ'
     C                   eval      *inlr = *on
     C                   goto      endinz2
     C                   endif
600eA
600eA*  If no license sent,
600eA*    Then return error.
600eA
600eAC                   if        $plic# = ' '
610fAC                             and $pcmd <> '*GETNEW'
600eAC                   eval      error = *on
600eAC                   eval      $preturn = '*LNOTSNT'
600eAC                   eval      $pErrMsg = '$plic# not sent'
600iAC                   eval      $slwhse = $pwhse
600iAC                   eval      $slwhdp = $pwhdp
600iAC                   eval      $slitem = $pitem
600iAC                   eval      $sldisp = ' '
610iAC                   eval      exerid = 'LT210'
600eAC                   exsr      zzexception
600eAC                   leavesr
600eAC                   endif
600eA
600eAC                   eval      curlic# = $plic#
600eAC                   eval      inlic# = $plic#
600eAC                   eval      outlic# = $plic#
600eA
600eA*  Get license information.
600eA
610fAC                   if        $pcmd <> '*GETNEW'
610fA
600eAC                   exsr      zzgetlcns
600eAC                   if        error
600eAC                   eval      $preturn = '*LICERR'
600eAC                   eval      $pErrMsg = $drimessage
600eAC                   leavesr
600eAC                   endif
600eA
600eAC                   eval      curpos  = $liToPos
610fA
610fAC                   endif
500pA
500pA* Get client id.
500pA
500pAC                   call      'GETCLIENT'
500pAC                   parm                    client           10

     *  Get item information

     C                   exsr      zzgetitem

     *  Get slot information if slot was sent in.

600fAC                   eval      pickSlot = *off
610jAC                   eval      repackSlot = *off
650cAC                   eval      ProdSlot = *off
730cAC                   eval      dropPickSlot = *off
     C                   eval      curslot = ' '
     C                   eval      pltpos = $pslotpos
     C                   if        $pslot <> ' '
     C                   exsr      zzgetslot
     C                   eval      curslot = $sldisp
600fAC                   if        $slpick = 'Y'
600fAC                   eval      pickSlot = *on
600fAC                   endif
610jAC                   if        $slaisl = 'RPK'
610jAC                   eval      repackSlot = *on
610jAC                   endif
650cAC                   if        $slstat = 'PR'
650cAC                   eval      ProdSlot = *on
650cAC                   endif
730cAC                   if        $sldesg = '*DROP'
730cAC                   eval      dropPickSlot = *on
730cAC                   endif
600eDC**                 eval      pltpos = $sdpos
     C                   endif

     * Initialize headings.

     C                   eval      head1 = $phead
     C                   eval      head2 = $pitemdsc
     C                   eval      w1slot = %trim($pslot)
     C                                    + '/'
     C                                    + %trim(%editc(pltpos:'P'))

     *  Get tracking information

     C                   exsr      zzgettrack
600kA
600kA*  See if license starts with '*'
600kA
600kAC                   if        %subst(curlic#:1:1) = '*'
600kAC                   eval      systemLcns = *on
600kAC                   else
600kAC                   eval      systemLcns = *off
600kAC                   endif
600dA
600dA*  If multiple licenses found for slot,
600dA*    or dealing with a Pick slot,
610jA*    or dealing with an Repack slot,
600dA*    Then set tracking to Low.
600dA
610hDC**                 if        curlic# = '*MULTIPLE'
610hDC**                           or pickSlot
610hMC                   if        pickSlot
610jAC                             or repackSlot
650cAC                             or ProdSlot
730cAC                             or dropPickSlot
600dAC                   eval      tracklevel = tLow
600dAC                   endif
600dA
600dA*  If High tracking,
600dA*    and license starts with '*',
600dA*    Then reduce tracking to Medium.
600dA
600dAC                   if        tracklevel = tHigh
600kMC                             and systemLcns
720aAC                             or tracklevel = tUCI
720aMC                             and systemLcns
600dAC                   eval      tracklevel = tMedium
600dAC                   endif
720 A
720 A*  If Low tracking,
720 A*    and Store Replenishment for Staging force Med
720 A*    to enforce License entry for replenishments
600dAC                   if        tracklevel = tLow and strRepl
600dAC                   eval      tracklevel = tMedium
600dAC                   endif

     * Initialize previous screen data structure.

     C                   exsr      zzclrdsprvscr

     * Determine which screen to display, if any.

     C                   select

     *   When NOT TRACKING license plates,
     *     Track without user knowing.

500aMC                   when      tracklevel = tLow
417aAC                   exsr      zznottracked
500 AC**                 eval      nxtscr = 'EOJ'
500lA
610dDC**  For *INVCNTB - Inventory count Before Inv Count file updated.
610dDC**
610dDC**                 when      $pcmd = '*INVCNTB'
610dDC**                 eval      $ppulled = 0
610dDC**                 exsr      zzinvcntb
610fA
610fA*   For *GETNEW - Get new license
610fA
610fAC                   when      $pcmd = '*GETNEW'
610fAC                   eval      w21desc = ' '
610fAC                   eval      $pnexttask = 'PUTAWAY'
610fAC                   exsr      scr21i
417cA
417cA*   For *PULDROP - Drop pallet to floor.
417cA
417cAC                   when      $pcmd = '*PULDROP'
500qAC                             or $pcmd = '*NQDROP'
610dAC                             or $pcmd = '*INVCNTB'
417cAC                   exsr      zzpuldrop
417cA
417cA*   For *PULTRAN - In transit.
600fA*     Currently for a partial we only allow the new LP to be applied
600fA*     to the portion going to the new slot. Therefore, we will delay
600fA*     asking for the LP until the split qty is put into a slot and
600fA*     we will send *SP for the "In" LP.
417cA
417cAC                   when      $pcmd = '*PULTRAN'

500aMC                   select
500aMC                   when      $ppartial
600fDC**                 eval      w21desc = 'Partial quantity being transfered'
600fDC**                 exsr      scr21i
600fAC                   eval      inlic# = '*SP'
600fAC                   eval      outlic# = $plic#
640bAC                   eval      nxtscr = 'EOJ'
     C                   other
417cAC                   eval      inlic# = $plic#
417cAC                   eval      outlic# = $plic#
417cAC                   exsr      zzpultran
417cAC                   eval      nxtscr = 'EOJ'
417cAC                   endsl

     *   For *PULRTN - Return dropped pallets to slot.

     C                   when      $pcmd = '*PULRTN'
610bDC**                 exsr      scr07i
610bMC                   exsr      zzupd7

417cA*   For *PULLUNDO - Undo pull.
417cA*     Just update history file and return.
417cA
417cAC                   when      $pcmd = '*PULUNDO'
417cAC                   exsr      zzpulundo
417cAC                   eval      nxtscr = 'EOJ'

     *   For *PUTAWYA - Putaway After slot is update.

     C                   when      $pcmd = '*PUTAWYA'
     C                   eval      $ppulled = 0
     C                   exsr      zzputawya

     *   For *PUTAWYB - Putaway Before slot is update.

     C                   when      $pcmd = '*PUTAWYB'
     C                   eval      $ppulled = 0
     C                   exsr      zzputawyb
500aA
500aA*   For *PUTAREA - Put product into a non-slot area.
500aA
500aAC                   when      $pcmd = '*PUTAREA'
500aAC                   eval      inlic# = $plic#
500aAC                   eval      $ppulled = 0
500aA
500aA*     If partial qty being putaway,
500aA*       Then ask for new license plate (SC21)
500aA
500aAC                   if        $ppartial
500aAC                   eval      w21desc = 'Partial quantity being putaway'
720aAc                   if        trackitem = 'U'
720aAc                   exsr      scr31i
720aAc                   else
500aAC                   exsr      scr21i
720aAc                   endif
500aA
500aA*     Otherwise, update history and return
500aA
500aAC                   else
500aAC                   exsr      zzputarea
500aAC                   eval      nxtscr = 'EOJ'
500aAC                   endif

     *   For *PUTSTFA - StuffIt After slot is update.

     C                   when      $pcmd = '*PUTSTFA'
     C                   eval      $ppulled = 0
     C                   exsr      zzputstfa

     *   For *PUTSTFB - StuffIt Before slot is update.

     C                   when      $pcmd = '*PUTSTFB'
     C                   eval      $ppulled = 0
     C                   exsr      zzputstfb
600hA
600hA*    If license not sent in, create new license plate.
600hA
600hAC                   if        $plic# = ' '
600hAC                   eval      inlic# = '*SI'
600hAC                   eval      $pslotpos = 1
600hAC                   else
600hAC                   eval      inlic# = $plic#
600hAC                   endif
     C                   eval      nxtscr = 'EOJ'

     *   For *PUTTRAN - In transit.
     *     Just update history file and return.

     C                   when      $pcmd = '*PUTTRAN'
     C                             or $pcmd = '*PUTAWY1'
     C                   exsr      zzputtran
     C                   eval      nxtscr = 'EOJ'

     *   For *PUTUNDO - Undo putaway.
     *     Just update history file and return.

     C                   when      $pcmd = '*PUTUNDO'
     C                             or $pcmd = '*PUTAWY0'
     C                   exsr      zzputundo
     C                   eval      nxtscr = 'EOJ'

     C                   endsl

600aAC     endinz2       tag
600aAC                   exsr      phpgmV1V2V3e
600aMC                   endsr

500gA*----------------------------------------------------------------
500gA*  ZZMERGE  Merge same slot/item/pos records together.
500gA*----------------------------------------------------------------
500gA
     C     zzmerge       begsr
600eDC**                 eval      currRoutine = 'zzmerge'
600eDC**                 exsr      phpgmV1V2V3s
600eD **
600eD ** Using information from last call to DRILICHIST.
600eD **
600eDC**                 eval      $dricommand = '*LICHIST'
600eDC**                 eval      $drisubcmd  = '%MERGE'
600eDC**                 eval      $drisys2upd = 'D'
600eDC**                 exsr      zzzdricop
600eDC**                 eval      error = *off
600eD **
600eDC**                 exsr      phpgmV1V2V3e
     C                   endsr

417aA*----------------------------------------------------------------
417aA*  ZZNOTTRACKED  Handling Non-Tracked Items.
417aA*----------------------------------------------------------------
417aA
     C     zznottracked  begsr
600aAC                   eval      currRoutine = 'zznottracked'
600aAC                   exsr      phpgmV1V2V3s

     C                   select
500lA
610dDC**  For *INVCNTB - Inventory count Before Inv Count file updated.
610dDC**
610dDC**                 when      $pcmd = '*INVCNTB'
610dDC**                 eval      $ppulled = 0
610dDC**                 exsr      zzinvcntb
610dDC**
610dDC**   If single pallet position update history and return
610dDC**   or if all qtys are zero update history and return
610dDC**   Otherwise, ask if user for pallet position.
610dDC**
610dDC**                 if        pltpos < 2
610dDC**                           or trackpos = 'N'
610dDC**                           or $pqty1 = 0
610dDC**                              and $pqty2 = 0
610dDC**                              and $pqty3 = 0
610dDC**                 eval      w29pos = 1
610dDC**                 exsr      zzinvcount
610dDC**                 eval      nxtscr = 'EOJ'
610dDC**                 else
610dDC**                 exsr      scr29i
610dDC**                 endif
610fA
610fA*   For *GETNEW - Get new license
610fA
610fAC                   when      $pcmd = '*GETNEW'
610fAC                   eval      nxtscr = 'EOJ'

     *  For *PULRTN - Return dropped pallets to slot.

     C                   when      $pcmd = '*PULRTN'
     C                   exsr      zzpulrtn
     C                   eval      nxtscr = 'EOJ'

     *  For *PULDROP - Drop pallet to floor

     C                   when      $pcmd = '*PULDROP'
500qAC                             or $pcmd = '*NQDROP'
610dAC                             or $pcmd = '*INVCNTB'
     C                   exsr      zzpuldrop
500eDC**                 eval      nxtscr = 'EOJ'

     *  For *PULTRAN - In transit.
     *    Just update history file and return.

     C                   when      $pcmd = '*PULTRAN'

610aDC**                 select
610aDC**                 when      $ptype = 'BRK'
610aDC**                           and client <> jordanos
500mAC**                           or $ptype = 'FLW'
610aDC**                 exsr      scr30i
610aDC**                 when      $ptype = 'FLW'
610aDC**                           or client = jordanos
610aDC**                 eval      inlic# = '*RP'
610aDC**                 eval      outlic# = $plic#
610aDC**                 exsr      zzpultran
610aDC**                 eval      nxtscr = 'EOJ'
610aDC**                 other
500dAC                   if        $ppartial
500dAC                   eval      inlic# = '*NT'
     C                   eval      outlic# = $plic#
500dAC                   else
500dAC                   eval      inlic# = $plic#
500dAC                   eval      outlic# = $plic#
500dAC                   endif
     C                   exsr      zzpultran
     C                   eval      nxtscr = 'EOJ'
610aDC**                 endsl

     *  For *PULUNDO - Undo pull.
     *    Just update history file and return.

     C                   when      $pcmd = '*PULUNDO'
     C                   exsr      zzpulundo
     C                   eval      nxtscr = 'EOJ'

     *  For *PUTAWYA - Putaway After slot is updated.

     C                   when      $pcmd = '*PUTAWYA'
     C                   eval      $ppulled = 0
     C                   exsr      zzputawya

     *  For *PUTAWYB - Putaway Before slot is updated.

     C                   when      $pcmd = '*PUTAWYB'
     C                   eval      $ppulled = 0

     *    If partial qty being putaway, create new license plate.

     C                   if        $ppartial
610jAC                   select
610jMC                   when      trackitem <> tLow
600fAC                             and pickSlot
600fAC                   eval      spclLcns = '*PS'
610jAC                   when      trackitem <> tLow
610jAC                             and repackSlot
610jAC                   eval      spclLcns = '*RP'
650cAC                   when      ProdSlot
650cAC                   eval      spclLcns = '*PR'
730cAC                   when      dropPickSlot
730cAC                   eval      spclLcns = '*DP'
610jMC                   other
600fAC                   eval      spclLcns = '*NT'
610jMC                   endsl
     C                   if        trackpsplit = '1'
     C                   eval      inlic# = $plic#
     C                   eval      outlic# = spclLcns
     C                   else
     C                   eval      inlic# = spclLcns
     C                   eval      outlic# = $plic#
     C                   endif
     C                   else
     C                   eval      inlic# = $plic#
     C                   eval      outlic# = $plic#
     C                   endif

     *    If single pallet position update history and return
     *    Otherwise, ask if user is merging onto existing pallet.

     C                   if        pltpos < 2
500bAC                             or trackpos = 'N'
     C                   exsr      zzputaway
720aAc                   if        trackitem = 'U' and $ppartial
720aAc                   eval      uciqty = ($pqty1 + $pqty2 +
720aAc                                       $pqty3)
720aAc                   exsr      scr31i
720aAc                   else
     C                   eval      nxtscr = 'EOJ'
720aAc                   endif
     C                   else
     C                   exsr      scr22i
     C                   endif
500aA
500aA*  For *PUTAREA - Put product into a non-slot area.
500aA
500aAC                   when      $pcmd = '*PUTAREA'
500aAC                   eval      $ppulled = 0
500aA
500aA*    If partial qty being putaway, create new license plate.
500aA
500aAC                   if        $ppartial
500aAC                   eval      inlic# = '*NT'
500aAC                   else
500aAC                   eval      inlic# = $plic#
500aAC                   endif
500aA
500aA*    Update history and return
500aA
500aAC                   exsr      zzputarea
500aAC                   eval      nxtscr = 'EOJ'

     *  For *PUTSTFA - Stuff product After slot is updated.

     C                   when      $pcmd = '*PUTSTFA'
     C                   eval      $ppulled = 0
     C                   exsr      zzputstfa
500cA
500cA*  For *PUTSTFB - Stuff product Before slot is update.
500cA
500cAC                   when      $pcmd = '*PUTSTFB'
500cAC                   eval      $ppulled = 0
500cA
500cA*    If license not sent in, create new license plate.
500cA
500cAC                   if        $plic# = ' '
500cAC                   eval      inlic# = '*SI'
500cAC                   else
500cAC                   eval      inlic# = $plic#
500cAC                   endif
500cA
500cA*    If single pallet position update history and return
500cA*    Otherwise, ask if user for pallet position.

500cAC                   if        pltpos < 2
500cAC                             or trackpos = 'N'
500cAC                   eval      w29pos = 1
500cAC                   exsr      zzputstuf
500cAC                   eval      nxtscr = 'EOJ'
500cAC                   else
500cAC                   exsr      scr29i
500cAC                   endif

     *  For *PUTTRAN - In transit.
     *    Just update history file and return.

     C                   when      $pcmd = '*PUTTRAN'
     C                             or $pcmd = '*PUTAWY1'
     C                   exsr      zzputtran
     C                   eval      nxtscr = 'EOJ'

     *  For *PUTUNDO - Undo putaway.
     *    Just update history file and return.

     C                   when      $pcmd = '*PUTUNDO'
     C                             or $pcmd = '*PUTAWY0'
     C                   exsr      zzputundo
     C                   eval      nxtscr = 'EOJ'

     C                   endsl

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZNUMPOSTFIX  Determine proper number postfix.
     *----------------------------------------------------------------

     C     zznumpostfix  begsr

     C                   move      curpal        temp1n
     C                   move      curpal        temp2n

     C                   select

     C                   when      temp1n = 1 and temp2n <> 11
     C                   eval      numpostfix = 'st'

     C                   when      temp1n = 2 and temp2n <> 12
     C                   eval      numpostfix = 'nd'

     C                   when      temp1n = 3 and temp2n <> 13
     C                   eval      numpostfix = 'rd'

     C                   other
     C                   eval      numpostfix = 'th'

     C                   endsl

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZPULDROP   Drop pallet to floor.
500 A*----------------------------------------------------------------
500 A
500 AC     zzpuldrop     begsr
600aAC                   eval      currRoutine = 'zzpuldrop'
600aAC                   exsr      phpgmV1V2V3s

600eDC**                 eval      curlic#   = slotLcns
600eDC**                 eval      $plic#    = slotLcns
600eDC**                 eval      curpos    = slotLcnsPos
600eDC**                 eval      $pslotpos = slotLcnsPos
600dDC******             eval      curposcod = $lrtcod

     *  Set license exist flag.

     C                   if        curlic# = ' '
600dMC                             or curlic# = '*MULTIPLE'
600dDC**                           or %subst(curlic#:1:1) = '*'
     C                   eval      licexists = *off
     C                   else
     C                   eval      licexists = *on
     C                   endif
417cA
417cA*  Initialize some fields
417cA
417cAC                   eval      inlic# = curlic#
417cAC                   eval      $ppulled = 0

500cAC                   select
500qA
500qA*  If doing a no-queston drop,
500qA*    Then just pull pallet.
500qA
500qAC                   when      $pcmd = '*NQDROP'
500qAC                   exsr      zzupd1
500qAC                   eval      nxtscr = 'EOJ'
417cA
610eA*  If license tracking is Low for item,
610eA*    and doing *INVCNTB,
610eA*    Then just pull pallet
610eA
610eAC                   when      tracklevel = tLow
610eAC                             and $pcmd = '*INVCNTB'
610eAC                   exsr      zzupd1
610eAC                   eval      nxtscr = 'EOJ'
417cA
417cA*  If license tracking is High for item,
417cA*    Then tell user to pull LP and scan it for verification (SC3)
417cA
500cMC                   when      tracklevel = tHigh
610dAC                             and $pcmd <> '*INVCNTB'
720aAC                             or tracklevel = tUCI
720aAC                             and $pcmd <> '*INVCNTB'
417cAC                   exsr      scr03i
417cAC                   goto      endpuldrop
417cA
417cA*  If license tracking is Medium for item,
417cA*    Then just tell user to pull LP (SC1)
417cA
500cMC                   when      tracklevel = tMedium
610dAC                             or $pcmd = '*INVCNTB'
417cAC                   exsr      scr01i
417cA
500eA*  If tracking pallet positions and multiple position slot,
417cA*    Then just tell user to pull LP (SC1)
417cA
500eMC                   when      trackpos = 'Y' and pltpos > 1
417cAC                   exsr      scr01i
500cA
500cA*  Otherwise, just pull pallet.
500cA
500cMC                   other
500cAC                   exsr      zzupd1
500eAC                   eval      nxtscr = 'EOJ'

500cAC                   endsl
417cA
600aAC     endpuldrop    tag
600aAC                   exsr      phpgmV1V2V3e
600aMC                   endsr

417cA*----------------------------------------------------------------
417cA*  ZZPULRTN   Return pulled pallets into slot.
417cA*----------------------------------------------------------------
417cA
417cAC     zzpulrtn      begsr
600aAC                   eval      currRoutine = 'zzpulrtn'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrtwhdu = *on
600dDC**                 eval      $lrtwhd  = $slwhdp
600dDC**                 eval      $lrtaslu = *on
600dDC**                 eval      $lrtasl  = $slaisl
600dDC**                 eval      $lrtlocu = *on
600dDC**                 eval      $lrtloc  = $slloc
600dDC**                 eval      $lrtlvlu = *on
600dDC**                 eval      $lrtlvl  = $slrlvl
600dDC**                 eval      $lrthndu = *on
600dDC**                 eval      $lrthnd  = $slhand
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%RTNALL'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

417cA*----------------------------------------------------------------
417cA*  ZZPULTRAN   Pull product in transit.
417cA*----------------------------------------------------------------
417cA
417cAC     zzpultran     begsr
600aAC                   eval      currRoutine = 'zzpultran'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
500dDC**                 eval      $lrlcns  = $pnewlic#
600dDC**                 eval      $lrlcns  = inlic#
600dDC**                 eval      $lrflicu = *on
600dDC**                 eval      $lrflic  = outlic#
600dDC**                 eval      $lrtcodu = *on
600dDC**                 eval      $lrtcod  = '?'
600dDC**                 eval      $lrtarau = *on
600dDC**                 eval      $lrtara  = 'Unknown'
600dDC**                 eval      $lrlqy1u = *on
600dDC**                 eval      $lrlqy1  = $pqty1
600dDC**                 eval      $lrlqy2u = *on
600dDC**                 eval      $lrlqy2  = $pqty2
600dDC**                 eval      $lrlqy3u = *on
600dDC**                 eval      $lrlqy3  = $pqty3
600dDC**                 eval      $lrnorm1u = *on
600dDC**                 eval      $lrnorm1  = $pnorm1
600dDC**                 eval      $lrnorm2u = *on
600dDC**                 eval      $lrnorm2  = $pnorm2
600dDC**                 eval      $lrnorm3u = *on
600dDC**                 eval      $lrnorm3  = $pnorm3
600dD **
600dDC**                 eval      $lrtsplu = *on
600dDC**                 eval      $lrtspl  = tracktsplit
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dD **
600dDC**                 select
600dDC**                 when      $ptype = 'BRK'
600dDC**                 eval      $drisubcmd  = '%UPDRPL'
600dDC**                 when      $ptype = 'FLW'
600dDC**                 eval      $drisubcmd  = '%UPDRPL'
600dDC**                 when      $ptype = 'RPL'
600dDC**                 eval      $drisubcmd  = '%UPDRPL'
600dDC**                 when      $ptype = 'TFR'
600dDC**                 eval      $drisubcmd  = '%UPDTFR'
600dDC**                 endsl
600dD **
600dDC**                 if        $ppartial
600dDC**                 eval      $drisubcmd = %trim($drisubcmd) + 'P'
600dDC**                 else
600dDC**                 eval      $drisubcmd = %trim($drisubcmd) + 'T'
600dDC**                 endif
600dD **
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif
600dD **
600dD ** Send back license plate that is in transit.
600dD **
600dDC**                 eval      $plic#    = $lrlcns

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

417cA*----------------------------------------------------------------
417cA*  ZZPULUNDO  Undo pull
417cA*----------------------------------------------------------------
417cA
417cAC     zzpulundo     begsr
600aAC                   eval      currRoutine = 'zzpulundo'
600aAC                   exsr      phpgmV1V2V3s

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = $plic#
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**
600hDC**                 select
600hDC**                 when      $ptype = 'BRK'
600hDC**                 eval      $drisubcmd  = '%UNDORPL'
600hDC**                 when      $ptype = 'FLW'
600hDC**                 eval      $drisubcmd  = '%UNDORPL'
600hDC**                 when      $ptype = 'RPL'
600hDC**                 eval      $drisubcmd  = '%UNDORPL'
600hDC**                 when      $ptype = 'TFR'
600hDC**                 eval      $drisubcmd  = '%UNDOTFR'
600hDC**                 endsl
600hDC**
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600hDC**
600hDC**  Merge item back into slot if necessary.
600hDC**    Note, To info is passed back from above command.
600hDC**
600hDC**                 eval      $lrwhseu = *on
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtslpu = *on
600hDC**
600hDC**                 exsr      zzmerge

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTAWAY  Product put into slot.
     *----------------------------------------------------------------

     C     zzputaway     begsr
600aAC                   eval      currRoutine = 'zzputaway'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
600dDC**                 eval      $lrlcns  = inlic#
600dDC**                 eval      $lrflicu = *on
600dDC**                 eval      $lrflic  = outlic#
600dDC**                 eval      $lrtwhdu = *on
600dDC**                 eval      $lrtwhd  = $slwhdp
600dDC**                 eval      $lrtdspu = *on
600dDC**                 eval      $lrtdsp  = $sldisp
600dDC**                 eval      $lrtbaseu = *on
600dDC**                 eval      $lrtbase = $sacdsp
600dDC**                 eval      $lrtaslu = *on
600dDC**                 eval      $lrtasl  = $slaisl
600dDC**                 eval      $lrtlocu = *on
600dDC**                 eval      $lrtloc  = $slloc
600dDC**                 eval      $lrtlvlu = *on
600dDC**                 eval      $lrtlvl  = $slrlvl
600dDC**                 eval      $lrthndu = *on
600dDC**                 eval      $lrthnd  = $slhand
600dDC**                 eval      $lrtitmu = *on
600dDC**                 eval      $lrtitm  = $slitem
600dDC**                 eval      $lrlqy1u = *on
600dDC**                 eval      $lrlqy1  = $pqty1
600dDC**                 eval      $lrlqy2u = *on
600dDC**                 eval      $lrlqy2  = $pqty2
600dDC**                 eval      $lrlqy3u = *on
600dDC**                 eval      $lrlqy3  = $pqty3
600dDC**                 eval      $lrnorm1u = *on
600dDC**                 eval      $lrnorm1  = $pnorm1
600dDC**                 eval      $lrnorm2u = *on
600dDC**                 eval      $lrnorm2  = $pnorm2
600dDC**                 eval      $lrnorm3u = *on
600dDC**                 eval      $lrnorm3  = $pnorm3
600dDC**                 eval      $lrtcodu = *on
600dDC**                 eval      $lrtcod  = 'S'
600dDC**                 eval      $lrtarau = *on
600dDC**                 eval      $lrtara  = 'Slot'
600dDC**                 eval      $lrtslpu = *on
600dDC**                 eval      $lrtslp  = 1
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 if        $ppartial
600dDC**                 eval      $drisubcmd  = '%CLSPUTP'
600dDC**                 else
600dDC**                 eval      $drisubcmd  = '%CLSPUTT'
600dDC**                 endif
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 if        $pcmd = '*PUTAWYA'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif
600dDC**                 endif
500gA
500gA*  Check if item already exists in slot (Before only)
500gA
500gAC                   if        $pcmd = '*PUTAWYB'
500gAC                   exsr      zzchkexist
500gAC                   endif
500gA
500gA*  Try to merge records (After only)
500gA
500gAC                   if        $pcmd = '*PUTAWYA'
500gAC                   exsr      zzmerge
500gAC                   endif

     *  Send back slot position.

     C                   eval      $pslotpos = 1
     C                   eval      $pnexttask = 'PUTAWAY'
417bA
600aAC     endputaway    tag
600aAC                   exsr      phpgmV1V2V3e
600aMC                   endsr

     *----------------------------------------------------------------
     *  ZZPUTAWYA  Putaway After slot update.
     *----------------------------------------------------------------

     C     zzputawya     begsr
600aAC                   eval      currRoutine = 'zzputawya'
600aAC                   exsr      phpgmV1V2V3s

     C                   eval      trackpsplit = $ppsplit
     C                   eval      inlic# = $pinlic#
     C                   eval      outlic# = $poutlic#

500aMC                   select

     C                   when      $pnexttask = 'PUTAWAY'
     C                   exsr      zzputaway
     C                   eval      nxtscr = 'EOJ'

     C                   when      $pnexttask = 'SCR23'
     C                   exsr      scr23i

     C                   when      $pnexttask = 'SCR26'
     C                   exsr      scr26i

     C                   when      $pnexttask = 'UPD29'
     C                   eval      w29pos = $pslotpos
     C                   exsr      zzupd29
     C                   eval      nxtscr = 'EOJ'

     C                   endsl

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTAWYB  Putaway Before slot update.
     *----------------------------------------------------------------

     C     zzputawyb     begsr
600aAC                   eval      currRoutine = 'zzputawyb'
600aAC                   exsr      phpgmV1V2V3s

500aMC                   select

500aM*     If partial qty being putaway ...

500aMC                   when      $ppartial
     C                   eval      w21desc = 'Partial quantity being putaway'
720 Ac*  If Store Staging Replen then prompt differently
720 Ac                   if        strRepl
720 Ac                   eval      w21desc = 'Partial quantity being staged'
720 Ac                   endif

     *       If single pallet position, ask for new license plate (SC21)
     *       Otherwise, ask if user is merging onto existing pallet (SC22).

     C                   if        pltpos < 2
500bAC                             or trackpos = 'N'
     C                   eval      $pnexttask = 'PUTAWAY'
720aAc                   if        trackitem = 'U'
720aAc                   exsr      scr31i
720aAc                   else
     C                   exsr      scr21i
720aAc                   endif
     C                   else
     C                   exsr      scr22i
     C                   endif
600kA
600kA*     If entire qty being putaway and LP starts with '*' ...
600kA
600kAC                   when      systemLcns
600kAC                   eval      w21desc = 'Full qty - Missing License'
600kA
600kA*       If single pallet position, ask for new license plate (SC21)
600kA*       Otherwise, ask if user is merging onto existing pallet (SC22).
600kA
600kAC                   if        pltpos < 2
600kAC                             or trackpos = 'N'
600kAC                   eval      $pnexttask = 'PUTAWAY'
600kAC                   exsr      scr21i
600kAC                   else
600kAC                   exsr      scr22i
600kAC                   endif

CBIaAC                   when      client = cheney and
CBIaAC                             $litowhdp <> $itwhdp
CBIaAC                   eval      w21desc = 'Cheney Require New License'
CBIaA
CBIaA*       If single pallet position, ask for new license plate (SC21)
CBIaA*       Otherwise, ask if user is merging onto existing pallet (SC22).
CBIaA
CBIaAC                   if        pltpos < 2
CBIaAC                             or trackpos = 'N'
CBIaAC                   eval      $pnexttask = 'PUTAWAY'
CBIaAC                   exsr      scr21i
CBIaAC                   else
CBIaAC                   exsr      scr22i
CBIaAC                   endif

     *     Otherwise, if entire qty being putaway ...
600kA*      with a normal LP.

     C                   other
500aAC                   eval      inlic# = $plic#
500aAC                   eval      outlic# = $plic#

     *       If single pallet position, update history and return
     *       Otherwise, ask if user is merging onto existing pallet (SC22).

     C                   if        pltpos < 2
500bAC                             or trackpos = 'N'
     C                   exsr      zzputaway
     C                   eval      nxtscr = 'EOJ'
     C                   else
     C                   exsr      scr22i
     C                   endif

     C                   endsl
600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

500aA*----------------------------------------------------------------
500aA*  ZZPUTAREA  Product put into a non-slot area.
500aA*----------------------------------------------------------------
500aA
500aAC     zzputarea     begsr
600aAC                   eval      currRoutine = 'zzputarea'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
600dDC**                 eval      $lrlcns  = inlic#
600dDC**                 eval      $lrflicu = *on
600dDC**                 eval      $lrflic  = $plic#
600dDC**                 eval      $lrtitmu = *on
500aDC**                 eval      $lrtitm  = $slitem
600dDC**                 eval      $lrtitm  = $pitem
600dDC**                 eval      $lrlqy1u = *on
600dDC**                 eval      $lrlqy1  = $pqty1
600dDC**                 eval      $lrlqy2u = *on
600dDC**                 eval      $lrlqy2  = $pqty2
600dDC**                 eval      $lrlqy3u = *on
600dDC**                 eval      $lrlqy3  = $pqty3
600dDC**                 eval      $lrnorm1u = *on
600dDC**                 eval      $lrnorm1  = $pnorm1
600dDC**                 eval      $lrnorm2u = *on
600dDC**                 eval      $lrnorm2  = $pnorm2
600dDC**                 eval      $lrnorm3u = *on
600dDC**                 eval      $lrnorm3  = $pnorm3
600dDC**                 eval      $lrtcodu = *on
600dDC**                 eval      $lrtcod  = 'A'
600dDC**                 eval      $lrtarau = *on
600dDC**                 eval      $lrtara  = $pslot
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 if        $ppartial
600dDC**                 eval      $drisubcmd  = '%CLSPUTP'
600dDC**                 else
600dDC**                 eval      $drisubcmd  = '%CLSPUTT'
600dDC**                 endif
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif

     *  Send back new license plate.

     C                   eval      $pnewlic# = inlic#

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTSTFA  Stuff product After slot update.
     *----------------------------------------------------------------

     C     zzputstfa     begsr
600aAC                   eval      currRoutine = 'zzputstfa'
600aAC                   exsr      phpgmV1V2V3s

     C                   eval      trackpsplit = $ppsplit
     C                   eval      inlic# = $pinlic#
     C                   eval      outlic# = $poutlic#

500aMC                   select

     C                   when      $pnexttask = 'PUTSTUF'
     C                   eval      w29pos = $pslotpos
     C                   exsr      zzputstuf
     C                   eval      nxtscr = 'EOJ'

     C                   endsl

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTSTFB  Stuff product Before slot update.
     *----------------------------------------------------------------

     C     zzputstfb     begsr
600aAC                   eval      currRoutine = 'zzputstfb'
600aAC                   exsr      phpgmV1V2V3s

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZPUTSTUF  Product stuffed into a slot.
500cA*----------------------------------------------------------------
500cA
500cAC     zzputstuf     begsr
600aAC                   eval      currRoutine = 'zzputstuf'
600aAC                   exsr      phpgmV1V2V3s

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = inlic#
600hDC**                 eval      $lrfcodu = *on
600hDC**                 eval      $lrfcod  = 'X'
600hDC**                 eval      $lrfarau = *on
600hDC**                 eval      $lrfara  = 'StuffIt'
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtitm  = $pitem
600hDC**                 eval      $lrlqy1u = *on
600hDC**                 eval      $lrlqy1  = $pqty1
600hDC**                 eval      $lrlqy2u = *on
600hDC**                 eval      $lrlqy2  = $pqty2
600hDC**                 eval      $lrlqy3u = *on
600hDC**                 eval      $lrlqy3  = $pqty3
600hDC**                 eval      $lrnorm1u = *on
600hDC**                 eval      $lrnorm1  = $pnorm1
600hDC**                 eval      $lrnorm2u = *on
600hDC**                 eval      $lrnorm2  = $pnorm2
600hDC**                 eval      $lrnorm3u = *on
600hDC**                 eval      $lrnorm3  = $pnorm3
600hDC**                 eval      $lrtcodu = *on
600hDC**                 eval      $lrtcod  = 'S'
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtarau = *on
600hDC**                 eval      $lrtara  = 'Slot'
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = w29pos
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtdspu = *on
600hDC**                 eval      $lrtdsp  = $sldisp
600hDC**                 eval      $lrtbaseu = *on
600hDC**                 eval      $lrtbase = $sacdsp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%ADDLIC'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 if        $pcmd <> '*PUTSTFB'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600hDC**                 endif
500gA
500gA*  Check if item already exists in slot (Before only)
500gA
500gAC                   if        $pcmd = '*PUTSTFB'
500gAC                   exsr      zzchkexist
500gAC                   endif
500gA
500gA*  Try to merge records (After only)
500gA
500gAC                   if        $pcmd = '*PUTSTFA'
500gAC                   exsr      zzmerge
500gAC                   endif

     *  Send back slot position.

     C                   eval      $pslotpos = w29pos
     C                   eval      $pnexttask = 'PUTSTUF'

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTTRAN  Putaway product in transit.
     *----------------------------------------------------------------

     C     zzputtran     begsr
600aAC                   eval      currRoutine = 'zzputtran'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
600dDC**                 eval      $lrlcns  = $plic#
600dDC**                 eval      $lrtcodu = *on
600dDC**                 eval      $lrtcod  = '?'
600dDC**                 eval      $lrtarau = *on
600dDC**                 eval      $lrtara  = 'Unknown'
600dDC**                 eval      $lrfcodu = *on
600dDC**                 eval      $lrfcod  = 'D'
600dDC**                 eval      $lrfarau = *on
600dDC**                 eval      $lrfara  = 'Dock'
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%UPDPUT'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif
417bA
600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPUTUNDO  Undo putaway
     *----------------------------------------------------------------

     C     zzputundo     begsr
600aAC                   eval      currRoutine = 'zzputundo'
600aAC                   exsr      phpgmV1V2V3s

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
600dDC**                 eval      $lrlcns  = $plic#
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%UNDOPUT'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif

600aAC                   exsr      phpgmV1V2V3e
     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  If pallet on floor, there's nothing to pull so skip to bottom

     C     curposcod     cabeq     'F'           endup1

     *  Pull pallets one at a time.

     C     1             do        curpos        curpal

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrtslpu = *on
600dDC**                 eval      $lrtslp  = curpal
600dDC**                 eval      $lrtwhdu = *on
600dDC**                 eval      $lrtwhd  = $slwhdp
600dDC**                 eval      $lrtaslu = *on
600dDC**                 eval      $lrtasl  = $slaisl
600dDC**                 eval      $lrtlocu = *on
600dDC**                 eval      $lrtloc  = $slloc
600dDC**                 eval      $lrtlvlu = *on
600dDC**                 eval      $lrtlvl  = $slrlvl
600dDC**                 eval      $lrthndu = *on
600dDC**                 eval      $lrthnd  = $slhand
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%PULL'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif

     C                   eval      $ppulled = $ppulled + 1
417bAC                   enddo

417bAC                   eval      curpos = 1
417bAC                   eval      curposcod = 'F'

600bAC     endup1        tag

600bA*   Where do we go next?
600bA
600bAC                   eval      refrsh = *on
600bA
600bA*     For multi postion slot,
600bA*       Goto screen 2a (Is item on pallet),
600bA*     Otherwise, return to calling program.
600ba
600bAC                   if        pltpos > 1
600bAC                             and trackpos = 'Y'
600bAC                   exsr      scr02ai
600bAC                   else
600bAC                   eval      nxtscr = 'EOJ'
600bAC                   endif

600bMC                   endsr

     *----------------------------------------------------------------
     *  ZZUPD2a  Update for screen 2a.
     *----------------------------------------------------------------

     C     zzupd2a       begsr
     C                   eval      error = *off

     *  If item not on pallet and slot only has one pallet position,
     *    then create exception.

     C                   if        w2opt = 'N' and pltpos <= 1
500bAC                             or w2opt = 'N' and trackpos = 'N'
     C                   eval      $preturn = '*NOTFND'
610iAC                   eval      exerid = 'LT210a'
     C                   exsr      zzexception
     C                   endif

600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bAC                   select
600bA
600bA*     If item was found on pallet, return to calling pgm.
600bA
600bAC                   when      w2opt = 'Y'
600bAC                   eval      nxtscr = 'EOJ'
600bA
600bA*     If 1 position slot or not tracking position,
600bA*       return to calling pgm.
600bA
600bAC                   when      pltpos <= 1
600bAC                             or trackpos = 'N'
600bAC                   eval      nxtscr = 'EOJ'
600bA
600bA*     Otherwise, goto screen 2d (enter position of item).
600bA
600bAC                   other
600baC                   exsr      scr02di
600bA
600bAC                   endsl

     C     endup2a       endsr

     *----------------------------------------------------------------
     *  ZZUPD2b  Update for screen 2b.
     *----------------------------------------------------------------

     C     zzupd2b       begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 2c (Is item on previous pallet)
600bA
600bAC                   exsr      scr02ci

     C     endup2b       endsr

     *----------------------------------------------------------------
     *  ZZUPD2c  Update for screen 2c.
     *----------------------------------------------------------------

     C     zzupd2c       begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 3 (Pull and confirm license)
600bA
600bAC                   exsr      scr03i

     C     endup2c       endsr

     *----------------------------------------------------------------
     *  ZZUPD2d  Update for screen 2d.
     *----------------------------------------------------------------

     C     zzupd2d       begsr
     C                   eval      error = *off
500oDC**
500oDC**If item found on floor, skip pulling pallets.
500oDC**
500oDC**                 if        w2dpos <= curpos
500oDC**                 goto      skippull
500oDC**                 endif
500oDC**
500oDC**If item wasn't found on floor, pull the necessary pallet(s).
500oDC**
500oDC**                 eval      excppos = w2dpos - curpos
500oDC**
500oDC**   1             do        excppos       curpal
500oDC**
500oDC**                 exsr      clr$lichist
500oDC**                 eval      $lrtslpu = *on
500oDC**                 eval      $lrtslp  = curpal
500oDC**                 eval      $lrtwhdu = *on
500oDC**                 eval      $lrtwhd  = $slwhdp
500oDC**                 eval      $lrtaslu = *on
500oDC**                 eval      $lrtasl  = $slaisl
500oDC**                 eval      $lrtlocu = *on
500oDC**                 eval      $lrtloc  = $slloc
500oDC**                 eval      $lrtlvlu = *on
500oDC**                 eval      $lrtlvl  = $slrlvl
500oDC**                 eval      $lrthndu = *on
500oDC**                 eval      $lrthnd  = $slhand
500oDC**
500oDC**                 eval      $dricommand = '*LICHIST'
500oDC**                 eval      $drisubcmd  = '%PULL'
500oDC**                 eval      $drisys2upd = 'D'
500oDC**                 exsr      zzzdricop
500oDC**                 if        error
500oDC**                 endif
500oDC**
500oDC**                 eval      $ppulled = $ppulled + 1
500oDC**                 enddo
500oDC**
500oDC**   skippull      tag
500oDC**
500oDC**Update license with new pallet position.
500oDC**
500oDC**                 eval      excppos = $ppulled - w2dpos + 1
500oDC**
500oDC**                 exsr      clr$lichist
500oDC**                 eval      $lrlcnsu = *on
500oDC**                 eval      $lrlcns  = curlic#
500oDC**                 eval      $lrtcodu = *on
500oDC**                 eval      $lrtcod  = 'S'
500oDC**                 eval      $lrtarau = *on
500oDC**                 eval      $lrtara  = 'Slot'
500oDC**                 eval      $lrtslpu = *on
500oDC**                 eval      $lrtslp  = excppos
500oDC**                 eval      $lrtwhdu = *on
500oDC**                 eval      $lrtwhd  = $slwhdp
500oDC**                 eval      $lrtaslu = *on
500oDC**                 eval      $lrtasl  = $slaisl
500oDC**                 eval      $lrtlocu = *on
500oDC**                 eval      $lrtloc  = $slloc
500oDC**                 eval      $lrtlvlu = *on
500oDC**                 eval      $lrtlvl  = $slrlvl
500oDC**                 eval      $lrthndu = *on
500oDC**                 eval      $lrthnd  = $slhand
500oDC**                 eval      $dricommand = '*LICHIST'
500oDC**                 eval      $drisubcmd  = '%WRONGLOC'
500oDC**                 eval      $drisys2upd = 'D'
500oDC**                 exsr      zzzdricop
500oDC**                 if        error
500oDC**                 endif
500oDC**
500oDC**Set position for item's pallet.
500oDC**
500oDC**                 eval      curpos = excppos

     *  Create exception.

500oAC                   if        w2dopt = 'Y'
500oAC                   eval      exerid = 'WRGPOS'
500oAC                   else
500oAC                   eval      exerid = 'NOTFND'
500oAC                   endif
500oA
     C                   exsr      zzexception
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on

500oA*     If user didn't find item, send back error code.
500oA
600bAC                   select
600bA
600bDC**                 if        w2dopt <> 'Y'
600bMC                   when      w2dopt <> 'Y'
500oAC                   eval      $preturn = '*NOTFND'
500oAC                   eval      nxtscr = 'EOJ'
600bDC**                 endif
500oA
600bA*     If High tracking, Goto screen 3 (pull and confirm license)
600bA
600bAC                   when      tracklevel = tHigh
720aAc                             or tracklevel = tUCI
600bAC                   exsr      scr03i
600bA
600bA*     Otherwise, return to calling program.
600bA
600bAC                   other
600bAC                   eval      nxtscr = 'EOJ'
600bA
600bAC                   endsl

     C     endup2d       endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   eval      error = *off

     *  If pallet on floor, there's nothing to pull so skip to bottom

     C     curposcod     cabeq     'F'           endup3

     *  Pull pallets one at a time.

     C     1             do        curpos        curpal

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = curpal
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%PULL'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif

417bAC                   enddo
600bA
600bAC     endup3        tag
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return to calling program.
600bA
600bAC                   eval      nxtscr = 'EOJ'

600bMC                   endsr

     *----------------------------------------------------------------
     *  ZZUPD3a  Update for screen 3a.
     *----------------------------------------------------------------

     C     zzupd3a       begsr
     C                   eval      error = *off

     *  If item is on the pallet but license could not be verified,
     *    Then create a *ML license for it and move on.

     C                   if        w2opt = 'Y' and prvscr = '03 '
600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = curlic#
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%MISSINGLP'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
     C                   endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     If item was found on pallet, return to calling pgm.
600bA*     Otherwise, goto screen 2d (enter position of item).
600bA
600bAC                   if        w3opt = 'Y'
600bAC                   eval      nxtscr = 'EOJ'
600bAC                   else
600bAC                   exsr      scr02di
600bAC                   endif

     C     endup3a       endsr

700cA*----------------------------------------------------------------
700cA*  ZZUPD3b  Update for screen 3b.
700cA*----------------------------------------------------------------

700cAC     zzupd3b       begsr
700cAC                   eval      error = *off

     *  If pallet on floor, there's nothing to pull so skip to bottom

700cAC     curposcod     cabeq     'F'           endup3b

     *  Move information to be sent back to LT105
700cAC                   Eval      $pslot = $litodisp
700cAC                   Eval      inlic#  = w3blic
700cAC                   Eval      outlic# = w3blic
700cAC                   Eval      $plic#  = w3blic
700cA
700cA*   Where do we go next?
700cA
700cAC                   eval      refrsh = *on
700cA
700cA*     If item was found on pallet, return to calling pgm.
700cA*     Otherwise, goto screen 2d (enter position of item).
700cA
700cAC                   eval      nxtscr = 'EOJ'

     C     endup3b       endsr

     *----------------------------------------------------------------
     *  ZZUPD4   Update for screen 4.
     *----------------------------------------------------------------

     C     zzupd4        begsr
     C                   eval      error = *off

     *  Move pallet to the floor.

600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 5 (Any pallets to put back)
600bA
600bAC                   exsr      scr05i

     C     endup4        endsr

     *----------------------------------------------------------------
     *  ZZUPD5   Update for screen 5.
     *----------------------------------------------------------------

     C     zzupd5        begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 6 (Is slot empty)
600bA
600bAC                   exsr      scr06i

     C     endup5        endsr

     *----------------------------------------------------------------
     *  ZZUPD6   Update for screen 6.
     *----------------------------------------------------------------

     C     zzupd6        begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 7 (Put pallets back into slot)
600bA
600bAC                   exsr      scr07i

     C     endup6        endsr

     *----------------------------------------------------------------
     *  ZZUPD7   Update for screen 7.
     *----------------------------------------------------------------

     C     zzupd7        begsr
     C                   eval      error = *off

     *  Put all pallets back up.

600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrtwhdu = *on
600dDC**                 eval      $lrtwhd  = $slwhdp
600dDC**                 eval      $lrtaslu = *on
600dDC**                 eval      $lrtasl  = $slaisl
600dDC**                 eval      $lrtlocu = *on
600dDC**                 eval      $lrtloc  = $slloc
600dDC**                 eval      $lrtlvlu = *on
600dDC**                 eval      $lrtlvl  = $slrlvl
600dDC**                 eval      $lrthndu = *on
600dDC**                 eval      $lrthnd  = $slhand
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%RTNALL'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return to calling program.
600bA
600bAC                   eval      nxtscr = 'EOJ'

     C     endup7        endsr

     *----------------------------------------------------------------
     *  ZZUPD8   Update for screen 8.
     *----------------------------------------------------------------

     C     zzupd8        begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 9 (Confirm item not found)
600bA
600bAC                   exsr      scr09i

     C     endup8        endsr

     *----------------------------------------------------------------
     *  ZZUPD9   Update for screen 9.
     *----------------------------------------------------------------

     C     zzupd9        begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 21 (Assign new license)
600bA
600bAC                   exsr      scr21i

     C     endup9        endsr

     *----------------------------------------------------------------
     *  ZZUPD21  Update for screen 21.
     *----------------------------------------------------------------

     C     zzupd21       begsr
     C                   eval      error = *off

     C                   if        $pcmd = '*PULTRAN'
     C                   eval      tracktsplit = w21psplit
     C                   else
     C                   eval      trackpsplit = w21psplit
     C                   endif

     *  Set In/Out license numbers.

     C                   select

     *    For *PULTRAN, LICHIST will deal with split option.

     C                   when      $pcmd = '*PULTRAN'
     C                   eval      inlic# = w21lic
     C                   eval      outlic# = $plic#

     *    When new license goes into slot and old stays with leftover.

     C                   when      w21psplit = '1'
     C                   eval      inlic# = w21lic
     C                   eval      outlic# = $plic#

     *    When new license stays with leftover and old goes into slot.

     C                   other
     C                   eval      outlic# = w21lic
     C                   eval      inlic#  = $plic#
     C                   endsl
600bA
600bAC     endup21       tag
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     For *PULTRAN, do update and then return.
600bA*     For everything else assume that we just want to get a new
600bA*     license and return. Therefore, just return.
600bA
600bAC                   if        $pcmd = '*PULTRAN'
600bAC                   exsr      zzpultran
600bAC                   endif
600bAC                   eval      nxtscr = 'EOJ'

600bMC                   endsr

     *----------------------------------------------------------------
     *  ZZUPD22  Update for screen 22.
     *----------------------------------------------------------------

     C     zzupd22       begsr
     C                   eval      error = *off

     *  Send back slot position.

     *    Set to -1 because were pushing pallet into slot.

     C                   eval      $pslotpos = -1
500gA
500gA*  Check if item already exists in slot (Before only)
500gA
500gAC                   if        w22opt = 'N'
600hDC**                 eval      $lrtslp = -1
500gAC                   exsr      zzchkexist
500gAC                   endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bAC                   select
600bA
600bA*     If merge='N' and Low tracking, return to calling program.
600bA
600bAC                   when      w22opt = 'N' and tracklevel = tLow
600bAC                   eval      $pnexttask = 'SCR23'
600bAC                   eval      nxtscr = 'EOJ'
600bA
600bA*     If merge='N' and partial, goto screen 21 (Assign new license)
600bA
600bAC                   when      w22opt = 'N' and $ppartial
600bAC                   eval      $pnexttask = 'SCR23'
600bAC                   exsr      scr21i
600bA
600bA*     If merge='N' and not partial, return to calling program.
600bA
600bAC                   when      w22opt = 'N' and not $ppartial
600bAC                   eval      $pnexttask = 'SCR23'
600bAC                   eval      nxtscr = 'EOJ'
600bA
600bA*     Otherwise,
600bA*       Goto screen 24 (Pull n pallet) (trackposmrg=2 step by step)
600bA*       or Goto screen 29 (Pallet Position) (trackposmrg=1)
600bA
600bAC                   other
600bAC                   if        trackposmrg = '2'
600bAC                   eval      curpal = 1
600bAC                   eval      $ppulled = curpal
600bAC                   exsr      scr24i
600bAC                   else
600bAC                   exsr      scr29i
600bAC                   endif
600bA
600bAC                   endsl

     C     endup22       endsr

     *----------------------------------------------------------------
     *  ZZUPD23  Update for screen 23.
     *----------------------------------------------------------------

     C     zzupd23       begsr
     C                   eval      error = *off

     *   Push pallet into the slot.

417bDC**                 exsr      clr$rparm
417bDC**                 if        $ppartial
417bDC**                 eval      $rcmd = '*PUSHPAP'
417bDC**                 else
417bDC**                 eval      $rcmd = '*PUSHPAT'
417bDC**                 endif
417bDC**                 eval      $rwhse = $pwhse
417bDC**                 eval      $rlcns = inlic#
417bDC**                 eval      $rfmlc = $plic#
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rlqy1 = $pqty1
417bDC**                 eval      $rlqy2 = $pqty2
417bDC**                 eval      $rlqy3 = $pqty3
417bDC**                 eval      $rcemp = $pempl#
417bDC**                 exsr      zzzupdllptrk

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = inlic#
600hDC**                 eval      $lrflicu = *on
600hDC**                 eval      $lrflic  = outlic#
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtdspu = *on
600hDC**                 eval      $lrtdsp  = $sldisp
600hDC**                 eval      $lrtbaseu = *on
600hDC**                 eval      $lrtbase = $sacdsp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtitm  = $slitem
600hDC**                 eval      $lrlqy1u = *on
600hDC**                 eval      $lrlqy1  = $pqty1
600hDC**                 eval      $lrlqy2u = *on
600hDC**                 eval      $lrlqy2  = $pqty2
600hDC**                 eval      $lrlqy3u = *on
600hDC**                 eval      $lrlqy3  = $pqty3
600hDC**                 eval      $lrnorm1u = *on
600hDC**                 eval      $lrnorm1  = $pnorm1
600hDC**                 eval      $lrnorm2u = *on
600hDC**                 eval      $lrnorm2  = $pnorm2
600hDC**                 eval      $lrnorm3u = *on
600hDC**                 eval      $lrnorm3  = $pnorm3
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 if        $ppartial
600hDC**                 eval      $drisubcmd  = '%PUSHPAP'
600hDC**                 else
600hDC**                 eval      $drisubcmd  = '%PUSHPAT'
600hDC**                 endif
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 if        $pcmd <> '*PUTAWYB'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600hDC**                 endif
600hDC**
600hDC** Try to merge records (After only)
600hDC**
600hDC**                 if        $pcmd = '*PUTAWYA'
600hDC**                 exsr      zzmerge
600hDC**                 endif

     *  Send back slot position.

     *    If update wasn't done yet, set to -1.

417bAC                   if        $pcmd = '*PUTAWYB'
     C                   eval      $pslotpos = -1
     C                   else
600hDC**                 eval      $pslotpos = $lrtslp
     C                   endif
     C                   eval      $pnexttask = 'UPD23'
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return to calling program
600bA
600bAC                   eval      nxtscr = 'EOJ'

     C     endup23       endsr

     *----------------------------------------------------------------
     *  ZZUPD24  Update for screen 24.
     *----------------------------------------------------------------

     C     zzupd24       begsr
     C                   eval      error = *off

     *  Pull pallet from slot.

417bDC**                 exsr      clr$rparm
417bDC**                 eval      $rcmd = '*PULL'
417bDC**                 eval      $rnewp = curpal
417bDC**                 eval      $rwhse = $slwhse
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rcemp = $pempl#
417bDC**                 exsr      zzzupdllptrk

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = curpal
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%PULL'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Goto screen 25 (Merging item onto n pallet)
600bA
600bAC                   exsr      scr25i

     C     endup24       endsr

     *----------------------------------------------------------------
     *  ZZUPD25  Update for screen 25.
     *----------------------------------------------------------------

     C     zzupd25       begsr
     C                   eval      error = *off

     C                   if        w25opt = 'N'
     C                   goto      endupd25
     C                   endif

417bDC**                 exsr      clr$rparm
417bDC**                 if        $ppartial
417bDC**                 eval      $rcmd = '*CLSPUTP'
417bDC**                 else
417bDC**                 eval      $rcmd = '*CLSPUTT'
417bDC**                 endif
417bDC**                 eval      $rwhse = $pwhse
417bDC**                 eval      $rlcns = inlic#
417bDC**                 eval      $rfmlc = $plic#
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rlqy1 = $pqty1
417bDC**                 eval      $rlqy2 = $pqty2
417bDC**                 eval      $rlqy3 = $pqty3
417bDC**                 eval      $rcemp = $pempl#
417bDC**                 eval      $rtocd = 'F'
417bDC**                 eval      $rtara = 'Floor'
417bDC**                 eval      $rnewp = curpal
417bDC**                 exsr      zzzupdllptrk

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = inlic#
600hDC**                 eval      $lrflicu = *on
600hDC**                 eval      $lrflic  = $plic#
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtdspu = *on
600hDC**                 eval      $lrtdsp  = $sldisp
600hDC**                 eval      $lrtbaseu = *on
600hDC**                 eval      $lrtbase = $sacdsp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtitm  = $slitem
600hDC**                 eval      $lrlqy1u = *on
600hDC**                 eval      $lrlqy1  = $pqty1
600hDC**                 eval      $lrlqy2u = *on
600hDC**                 eval      $lrlqy2  = $pqty2
600hDC**                 eval      $lrlqy3u = *on
600hDC**                 eval      $lrlqy3  = $pqty3
600hDC**                 eval      $lrnorm1u = *on
600hDC**                 eval      $lrnorm1  = $pnorm1
600hDC**                 eval      $lrnorm2u = *on
600hDC**                 eval      $lrnorm2  = $pnorm2
600hDC**                 eval      $lrnorm3u = *on
600hDC**                 eval      $lrnorm3  = $pnorm3
600hDC**                 eval      $lrtcodu = *on
600hDC**                 eval      $lrtcod  = 'F'
600hDC**                 eval      $lrtarau = *on
600hDC**                 eval      $lrtara  = 'Floor'
600hDC**                 eval      $lrtslpu = *on
500cDC**                 eval      $lrtslp  = curpal
600hDC**                 eval      $lrtslp  = 1
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 if        $ppartial
600hDC**                 eval      $drisubcmd  = '%CLSPUTP'
600hDC**                 else
600hDC**                 eval      $drisubcmd  = '%CLSPUTT'
600hDC**                 endif
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif

     C                   eval      $preturn = '*MERGED'
600bA
600bAC     endupd25      tag
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA
600bA*     If merging item onto the pallet ...
600bA
600bAC                   if        w25opt = 'Y'
600bA
600bA*        When trackposmrg=2 (step by step),
600bA*          Goto screen 27 (Scan put back license)
600bA*        Otherwise, goto screen 26 (Put Pallets Back)
600bA
600bAC                   if        trackposrtn = '2'
600bAC                   exsr      scr27i
600bAC                   else
600bAC                   exsr      scr26i
600bAC                   endif
600bA
600bA*     If not merging item onto the pallet ...
600bA
600bAC                   else
600bA
600bA*        If out of pallets, display screen 28 (No more pallets)
600bA*        otherwise, goto screen 24 (Pull n pallet)
600bA
600bAC                   if        curpal = pltpos
600bAC                   eval      curpal = curpal+1
600bAC                   exsr      scr28i
600bAC                   else
600bAC                   eval      curpal = curpal+1
600bAC                   eval      $ppulled = curpal
600bAC                   exsr      scr24i
600bAC                   endif
600bA
600bAC                   endif
     C
600bMC                   endsr

     *----------------------------------------------------------------
     *  ZZUPD26  Update for screen 26.
     *----------------------------------------------------------------

     C     zzupd26       begsr
     C                   eval      error = *off
500cA
500cA*  Put all pallets back up.

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%RTNALL'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return to calling program
600bA
600bAC                   eval      nxtscr = 'EOJ'
500cA
     C     endup26       endsr

     *----------------------------------------------------------------
     *  ZZUPD27  Update for screen 27
     *----------------------------------------------------------------

     C     zzupd27       begsr
     C                   eval      error = *off
     C                   do

     *  Put pallet back into slot (Position was determined in ZZCHK27).

     C                   if        $ppulled >= 1

417bDC**                 exsr      clr$rparm
417bDC**                 eval      $rcmd = '*PUSH'
417bDC**                 eval      $rtslp = licpos
417bDC**                 eval      $rwhse = $slwhse
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rcemp = $pempl#
417bDC**                 exsr      zzzupdllptrk

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = licpos
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%PUSH'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif

     C                   endif

     *  If Pulled is 1 (last pallet to put back up) ...
     *    Then change position of all remaining floor pallets to zero.


     C                   if        $ppulled <= 1

417bDC**                 exsr      clr$rparm
417bDC**                 eval      $rcmd = '*UPDLOC0'
417bDC**                 eval      $rwhse = $slwhse
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rcemp = $pempl#
417bDC**                 eval      $rtocd = 'S'
417bDC**                 eval      $rtara = 'Slot'
417bDC**                 exsr      zzzupdllptrk

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**                 eval      $lrtcodu = *on
600hDC**                 eval      $lrtcod  = 'S'
600hDC**                 eval      $lrtarau = *on
600hDC**                 eval      $lrtara  = 'Slot'
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 eval      $drisubcmd  = '%UPDLOC0'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif

     C                   endif
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return if no more pallets to put back.
600bA*     Otherwise, redisplay for next pallet to be put back.
600bA
600bAC                   eval      $ppulled = $ppulled - 1
600bAC                   select
600bAC                   when      $ppulled < 0
600bAC                   eval      nxtscr = 'EOJ'
600bAC                   when      $ppulled = 0
600bAC                   iter
600bAC                   other
600bAC                   exsr      scr27i
600bAC                   endsl

600bAC                   enddo
     C     endup27       endsr

     *----------------------------------------------------------------
     *  ZZUPD28  Update for screen 28
     *----------------------------------------------------------------

     C     zzupd28       begsr
     C                   eval      error = *off
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Stay put.

     C     endup28       endsr

500cA*----------------------------------------------------------------
500cA*  ZZUPD29  Update for screen 29.
500cA*----------------------------------------------------------------
500cA
500cAC     zzupd29       begsr
     C                   eval      error = *off

     *   See if we are just stuffing item into slot.

     C                   if        $pcmd = '*PUTSTFA'
     C                             or $pcmd = '*PUTSTFB'
     C                   exsr      zzputstuf
     C                   goto      endup29
     C                   endif
500lA
500lA*   See if we are just doing an inventory count.
500lA
610dDC**                 if        $pcmd = '*INVCNTB'
610dDC**                 exsr      zzinvcount
610dDC**                 goto      endup29
610dDC**                 endif

     *   Push pallet into the slot.

600hDC**                 exsr      clr$lichist
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = inlic#
600hDC**                 eval      $lrflicu = *on
600hDC**                 eval      $lrflic  = outlic#
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtdspu = *on
600hDC**                 eval      $lrtdsp  = $sldisp
600hDC**                 eval      $lrtbaseu = *on
600hDC**                 eval      $lrtbase = $sacdsp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtitm  = $slitem
600hDC**                 eval      $lrlqy1u = *on
600hDC**                 eval      $lrlqy1  = $pqty1
600hDC**                 eval      $lrlqy2u = *on
600hDC**                 eval      $lrlqy2  = $pqty2
600hDC**                 eval      $lrlqy3u = *on
600hDC**                 eval      $lrlqy3  = $pqty3
600hDC**                 eval      $lrnorm1u = *on
600hDC**                 eval      $lrnorm1  = $pnorm1
600hDC**                 eval      $lrnorm2u = *on
600hDC**                 eval      $lrnorm2  = $pnorm2
600hDC**                 eval      $lrnorm3u = *on
600hDC**                 eval      $lrnorm3  = $pnorm3
600hDC**                 eval      $lrtcodu = *on
600hDC**                 eval      $lrtcod  = 'S'
600hDC**                 eval      $lrtarau = *on
600hDC**                 eval      $lrtara  = 'Slot'
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = w29pos
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
600hDC**                 if        $ppartial
600hDC**                 eval      $drisubcmd  = '%CLSPUTP'
600hDC**                 else
600hDC**                 eval      $drisubcmd  = '%CLSPUTT'
600hDC**                 endif
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 if        $pcmd <> '*PUTAWYB'
600hDC**                 exsr      zzzdricop
600hDC**                 if        error
600hDC**                 endif
600hDC**                 endif
500gA
500gA*  Check if item already exists in slot (Before only)
500gA
500gAC                   if        $pcmd = '*PUTAWYB'
500gAC                   exsr      zzchkexist
500gAC                   endif
600hDC**
600hDC** Try to merge records (After only)
600hDC**
600hDC**                 if        $pcmd = '*PUTAWYA'
600hDC**                 exsr      zzmerge
600hDC**                 endif

     *  Send back slot position.

600hDC**                 eval      $pslotpos = $lrtslp
     C                   eval      $pnexttask = 'UPD29'
600bA
600bAC     endup29       tag
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Return to calling program
600bA
600bAC                   eval      nxtscr = 'EOJ'

600bMC                   endsr

500gA*----------------------------------------------------------------
500gA*  ZZUPD30  Update for screen 30.
500gA*----------------------------------------------------------------
500gA
500gAC     zzupd30       begsr
     C                   eval      error = *off

     *  Set In/Out license numbers.

     C                   eval      inlic# = w30lic
     C                   eval      outlic# = $plic#
600bA
600bA*   Where do we go next?
600ba
600bAC                   eval      refrsh = *on
600bA
600bA*     Do update and then return.
600bA
600bAC                   exsr      zzpultran
600bAC                   eval      nxtscr = 'EOJ'

     C     endup30       endsr

720aA*----------------------------------------------------------------
720aA*  ZZUPD31  Update for screen 31.
720aA*----------------------------------------------------------------
720aA
720aAC     zzupd31       begsr
720aAC                   eval      error = *off
720aA
720aA
720aA*   Where do we go next?
720aA
720aAC                   eval      refrsh = *on
720aA
720aAc
720aA*     Accumlate gs1's scanned.
720aAc                   eval      scancount = scancount + 1
720aA*     IN51 - protects the f12 key, once scanning is in process
720aA*     the user must complete the scanning process.
720aAc                   eval      *in51 = '1'
720aA*  Update UCIINFO file with temporary *PS plate in USR slot
720aA /free
720aA   w31UCI = %TrimL(w31uci);

720aA   $uiWhse = $pwhse;
720aA   $uiuci  = w31uci;
720aA   $uitolcns = $plic#;
720aA   $uiApartlts = $ppartime;

720aA   // Lets add some more stuff for tracking
        //$uiaction = %trimr($ptype) + 'SPLIT';
720aA   $uiaction = %trimr($ptype) + 'SPLBEG';
720aA   //$uiaction = 'PUTSPLIT';
720aA   $uiAolcns = $plic#;
720aA   $uiAoseq = $uiseq;
720aA   $uiscan = 'Y';
720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%UPDPARTL';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA   // if return is *OK we updated the uci record
720aA   if $drireturn <> '*OK';
720aA     error = *on;
720aA     *in21 = *on;
720aA     *in01 = *on;
720aA     errmsg = 'problem updating uci';
720aA     exsr zm0105;
720aA     leavesr;
720aA   endif;
720aA /end-free
     c
720aA*     Must scan same amount of UCI's as the qty being split
720aA*     once we have all scans then we proceed to the assign
720aA*     the new license.
720aAc                   Select
720aAc                   when      scancount <> uciqty
720aAc                   eval      w31uci = ' '
720aA*     Need to scan more
720aAc                   other
720aA*     Scans match qty being split.
720aAc                   eval      *in51 = '0'
720aAc                   eval      scancount = 0
720aAc                   Select
720aAc                   when      tracklevel = tLow
720aAC                   eval      nxtscr = 'EOJ'
720aAc                   other
720aAC                   exsr      scr21i
720aAc                   endsl
720aAc                   endsl
720aA
720aAC                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  License Plate Tracking Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LICNF    Create *NF (Not Found) license tracking record.
     *
     C     licnf         begsr
     *
417bDC**                 clear                   $rparm
417bDC**                 eval      $rwhse = $slwhse
417bDC**                 eval      $rtwhd = $slwhdp
417bDC**                 eval      $rtasl = $slaisl
417bDC**                 eval      $rtloc = $slloc
417bDC**                 eval      $rtlvl = $slrlvl
417bDC**                 eval      $rthnd = $slhand
417bDC**                 eval      $rtocd = 'S'
417bDC**                 eval      $rfmcd = '?'
417bDC**
417bDC**                 eval      $rcmd = '*CRTNF  '
417bDC**                 call      'UPDLLPTRK'
417bDC**                 parm                    $rcmd
417bDC**                 parm                    $rprg
417bDC**                 parm                    $rparm
417bDC**                 parm                    $rdata
417bDC**                 parm                    $rrtn
417bDC**                 parm                    $rmsg
417bDC**
417bDC**                 if        $rrtn = '*OK'

600hDC**                 exsr      clr$lichist
600hDC**
600hDC**                 eval      $lrlcnsu = *on
600hDC**                 eval      $lrlcns  = '*NF'
600hDC**                 eval      $lrfcodu = *on
600hDC**                 eval      $lrfcod  = '?'
600hDC**                 eval      $lrfarau = *on
600hDC**                 eval      $lrfara  = 'Unknown'
600hDC**                 eval      $lrfitmu = *on
600hDC**                 eval      $lrfitm  = $ititem
600hDC**                 eval      $lrfitypu = *on
600hDC**                 eval      $lrfityp = $ittype
600hDC**
600hDC**                 eval      $lrtcodu = *on
600hDC**                 eval      $lrtcod  = 'S'
600hDC**                 eval      $lrtarau = *on
600hDC**                 eval      $lrtara  = 'Slot'
600hDC**                 eval      $lrtwhdu = *on
600hDC**                 eval      $lrtwhd  = $slwhdp
600hDC**                 eval      $lrtaslu = *on
600hDC**                 eval      $lrtasl  = $slaisl
600hDC**                 eval      $lrtlocu = *on
600hDC**                 eval      $lrtloc  = $slloc
600hDC**                 eval      $lrtlvlu = *on
600hDC**                 eval      $lrtlvl  = $slrlvl
600hDC**                 eval      $lrthndu = *on
600hDC**                 eval      $lrthnd  = $slhand
600hDC**                 eval      $lrtdspu = *on
600hDC**                 eval      $lrtdsp  = $sldisp
600hDC**                 eval      $lrtbaseu = *on
600hDC**                 eval      $lrtbase = $sacdsp
600hDC**                 eval      $lrlqy1u = *on
600hDC**                 eval      $lrlqy1  = $slavl1
600hDC**                 eval      $lrlqy2u = *on
600hDC**                 eval      $lrlqy2  = $slavl2
600hDC**                 eval      $lrlqy3u = *on
600hDC**                 eval      $lrlqy3  = $slavl3
600hDC**                 eval      $lrtslpu = *on
600hDC**                 eval      $lrtslp  = 1
600hDC**                 eval      $lrtitmu = *on
600hDC**                 eval      $lrtitm  = $ititem
600hDC**                 eval      $lrtitypu = *on
600hDC**                 eval      $lrtityp = $ittype
600hDC**
600hDC**                 eval      $dricommand = '*LICHIST'
500dDC**                 eval      $drisubcmd  = '%UPDLOC0'
600hDC**                 eval      $drisubcmd  = '%ADDLIC'
600hDC**                 eval      $drisys2upd = 'D'
600hDC**                 exsr      zzzdricop
500dDC**                 if        not error
500dDC**                 move      $lrlcns       outlic
500dDC**                 eval      outtsp = $lrtslp
500dDC**                 else
500dDC**                 eval      outlic = *blanks
500dDC**                 eval      outtsp = 0
500dDC**                 endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$dept  Clear $dept data structure fields
     *----------------------------------------------------------------

     C     clr$dept      begsr
     C                   eval      savever# = $wdver#
     C                   clear                   $dept
     C                   eval      $wdver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600dAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600dA*----------------------------------------------------------------
600dA*  clr$license  Clear $license data structure fields
600dA*----------------------------------------------------------------
600dA
600dAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   clear                   $license2
     C                   eval      $liver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600dAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slotdef  Clear $slotdef data structure fields
     *----------------------------------------------------------------

     C     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr

720aA*----------------------------------------------------------------
720aA*  clr$uciinfo  Clear $uciinfo data structure fields
720aA*----------------------------------------------------------------
720aA
720aAC     clr$uciinfo   begsr
720aAC                   eval      savever# = $uiver#
720aAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
720aAC                   eval      $uiver# = savever#
720aAC                   eval      $uiaddemp = $pempl#
720aAC                   eval      $uiaddusr = #curruser
720aAC                   eval      $uiaddpgm  = #pgm
720aAC                   eval      $uiaddjob  = #job
720aAC                   eval      $uiaddnbr = #jobnbr
720aAC                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*DEPT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

720aAC                   eval      $dricommand = '*UCIINFO'
720aAC                   eval      $drisubcmd  = '%CLOSE'
720aAC                   eval      $drisys2upd = 'D'
720aAC                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600dAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
500 AC                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*DEPT'
     C                   eval      $dridata = $dept
600dAC                   when      $dricommand = '*LICENSE'
600dAC                   eval      $dridata = $license
600dAC                   eval      $dridata2 = $license2
720aAC                   when      $dricommand = '*UCIINFO'
720aAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
600dAC                   endsl

500 AC                   if        $dricommand = '*ITEM'
600dAC                             or $dricommand = '*SLOT'
600dAC                             or $dricommand = '*LICENSE'
720aAC                             or $dricommand = '*UCIINFO'
500 AC                   call(e)   'DRICOP'
500 AC                   parm                    $dricommand
500 AC                   parm                    $drisubcmd
500 AC                   parm                    $drisys2upd
500 AC                   parm      #pgm          $driprogram
500 AC                   parm      ' '           $drireturn
500 AC                   parm      ' '           $drimessage
500 AC                   parm                    $dridata
500 AC                   parm                    $dridata2
500 AC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
500 AC                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #pgm
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600dAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*DEPT'
     C                   eval      $dept = $dridata
600dAC                   when      $dricommand = '*LICENSE'
600dAC                   eval      $license = $dridata
600dAC                   eval      $license2 = $dridata2
720aAC                   when      $dricommand = '*UCIINFO'
720aAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C     enddricop     endsr

700aA*----------------------------------------------------------------
700aA*
700aA*  ZZGETSYOP  Get System Options record.
700aA*
     C     zzgetsyop     begsr
     *
     C                   eval      opcode = '*SYSTEM '
     *
     C                   eval      opwhse = *zeros
     *
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      opdspl = 'N'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                  LICENSE SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

417bD**---------------------------------------------------------------
417bD** clr$dept  Clear $dept data structure fields
417bD**---------------------------------------------------------------
417bDC**
417bDC**   clr$rparm     begsr
417bDC**                 clear                   $rparm
417bDC**                 clear                   $rdata
417bDC**                 endsr
417bDC**
417bD**---------------------------------------------------------------
417bD** zzzupdllptrk   Call UPDLLPTRK
417bD**---------------------------------------------------------------
417bDC**
417bDC**   zzzupdllptrk  begsr
417bDC**                 eval      error = *off
417bDC**
417bDC**                 call      'UPDLLPTRK'
417bDC**                 parm                    $rcmd             8
417bDC**                 parm                    $rprg            10
417bDC**                 parm                    $rparm
417bDC**                 parm                    $rdata
417bDC**                 parm                    $rrtn             8
417bDC**                 parm                    $rmsg             4
417bDC**
417bDC**   endupdllptrk  endsr

500aA*----------------------------------------------------------------
500aA*  writelogrec    Write LOGLT210 record.
500aA*----------------------------------------------------------------
500aA
500aAC     writelogrec   begsr

     C                   eval      lg210cmd   = $pcmd
     C                   eval      lg210pgm   = $pprogram
     C                   eval      lg210type  = $ptype
     C                   eval      lg210head  = $phead
     C                   eval      lg210whse  = $pwhse
     C                   eval      lg210item  = $pitem
     C                   eval      lg210idsc  = $pitemdsc
     C                   eval      lg210whdp  = $pwhdp
     C                   eval      lg210slot  = $pslot
     C                   eval      lg210spos  = $pslotpos
     C                   eval      lg210emp#  = $pempl#
     C                   eval      lg210trn#  = $ptran#
     C                   eval      lg210lic#  = $plic#
     C                   eval      lg210newl# = $pnewlic#
     C                   eval      lg210qty1  = $pqty1
     C                   eval      lg210qty2  = $pqty2
     C                   eval      lg210qty3  = $pqty3
     C                   eval      lg210part  = $ppartial
     C                   eval      lg210pull  = $ppulled
     C                   eval      lg210psplt = $ppsplit
     C                   eval      lg210inlic = $pinlic#
     C                   eval      lg210outli = $poutlic#
     C                   eval      lg210nxttk = $pnexttask
     C                   eval      lg210rtn   = $preturn
     C                   eval      lg210msg   = $perrmsg
     C                   eval      lg210msgid = $pmsgid

     C                   time                    lg210stamp
     C                   write     lg210rec

     C                   endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*  Phrase Routines
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  pushRoutine  -  Add routine to stack
600aA*----------------------------------------------------------------
600aA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  popRoutine  -  Remove routine from stack
600aA*----------------------------------------------------------------
600aA
      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phClearVars  - Clear phrase variables
600aA*----------------------------------------------------------------
600aA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phWrtPhrase  - Write logging phrase
600aA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = $pWhse;
         pEmp# = $pEmpl#;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = $pItem;
         pWhdp = $pWhdp;
         pLocation = $pSlot;
         pTrn# = $ptran#;
         pLcns = $pLic#;
         pLtrn = 0;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free

         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phV2onV1
600aA*----------------------------------------------------------------
600aA
      /free
       begsr phV2onV1;

         pPhraseId = V2onV1;

         exsr phClearVars;

         exsr phWrtPhrase;
         v1 = nxtscr;

         select;
           when status = rollup;
             v2 = 'PageDn';
           when status = rolldn;
             v2 = 'PageUp';
           when status = comand;
             select;
               when *inka;
                 v2 = 'F1';
               when *inkb;
                 v2 = 'F2';
               when *inkc;
                 v2 = 'F3';
               when *inkd;
                 v2 = 'F4';
               when *inke;
                 v2 = 'F5';
               when *inkf;
                 v2 = 'F6';
               when *inkg;
                 v2 = 'F7';
               when *inkh;
                 v2 = 'F8';
               when *inki;
                 v2 = 'F9';
               when *inkj;
                 v2 = 'F10';
               when *inkk;
                 v2 = 'F11';
               when *inkl;
                 v2 = 'F12';
               when *inkm;
                 v2 = 'F13';
               when *inkn;
                 v2 = 'F14';
               when *inkp;
                 v2 = 'F15';
               when *inkq;
                 v2 = 'F16';
               when *inkr;
                 v2 = 'F17';
               when *inks;
                 v2 = 'F18';
               when *inkt;
                 v2 = 'F19';
               when *inku;
                 v2 = 'F20';
               when *inkv;
                 v2 = 'F21';
               when *inkw;
                 v2 = 'F22';
               when *inkx;
                 v2 = 'F23';
               when *inky;
                 v2 = 'F24';
               other;
                 v2 = 'Unknown Command Key';
             endsl;
           other;
             v2 = 'ENTER';
         endsl;

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phScrV1pgmV2
600aA*----------------------------------------------------------------
600aA
      /free
       begsr phScrV1pgmV2;

         pPhraseId = scrV1pgmV2;

         exsr phClearVars;

         v1 = nxtscr;
         select;
600bA      when nxtscr <> lastnxtscr;
600bA        v2 = 'displayed';
600bA      when error = *on;
600bA        v2 = 'redisplayed with error';
600bA      when warn = *on;
600bA        v2 = 'redisplayed with warning';
600bA      other;
600bA        v2 = 'redisplayed';
600bA    endsl;
600bA    lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phPgmV1V2V3e
600aA*----------------------------------------------------------------
600aA
      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*  phPgmV1V2V3s
600aA*----------------------------------------------------------------
600aA
      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free
