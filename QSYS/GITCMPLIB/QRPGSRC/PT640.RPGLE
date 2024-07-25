640bA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT640   Route transaction - Display
     *  26 June 1997
     *  Dave Sommerville
     *
     *  NOTE:
     *      If you change this program, check PT645 for same changes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
404 A*    08/11/97  HNK  4.04
     *      - Add STATUS
     *
406 A*    09/22/97  DAS  4.06
     *      - Revised to not display letdowns.
408 A*    01/26/98  RH   4.08
     *      - Revised to skip Letdowns when updating RTEHED file.
     *      - NOTE: Will use PT170A to close letdowns.
410 A*    08/19/98  RH   4.10
     *      - Do not allow option 2 or 9 to change and close or close
     *        a transaction already closed.
412 A*    07/22/99  RH   4.12
     *      - Add option 3 to enter catch weights.
412 A*    08/23/99  HNK  4.12
     *      - Disable option 9 = Quick close.
412aA*    09/21/98  DAS  4.12
     *      - Revised to not change RteHed stat to '5' when it is
     *        already greater than '5'.
     *
413 A*    10/19/99  DAS  4.13
     *      - Reinstated option 9 = Quick close.
     *
413bA*    02/28/00  MLB  4.13b
     *      - Revised ZZCMD to only include selection transactions when
     *        F16=Close all is selected.
413cA*    02/28/00  MLB  4.13c
     *      - Revised ZZCMD to set on switch when F16=Close all is
     *        selected.
     *      - Revised CMD02 to run routine CLRSCH to remove all
     *        entries from file WORKOPT when user chooses to exit
     *        with F12=Cancel.
     *
414 A*    06/30/00  DAS  4.14
     *      - Revised display file to use ind 21 with SFLNXTCHG
     *        instead of ind 85 as stated in this program. The
     *        actual indicator used in the program was never changed
     *        from 21 to 85.
     *      - Only had to recompile the program.
     *
414aA*    08/18/00  DAS  4.14a
     *      - Added F7=Verify Cwgt.
     *
415aA*    05/23/01  MLB  4.15a
     *      - Added file LABEL8.
     *      - Changed file PIRTRAN4 to be update capable file.
     *      - Revised routine ZZSTAT to check for label records not at closed
     *        status.
     *
416aA*    08/17/01  MLB  4.16a
     *      - Revised 415a modification to do a READ of LABEL8
     *        looking for label records not at closed status
     *        since field LBPO may not be blank when interfacing
     *        with certain host software packages.
     *
416bA*    10/29/01  HNK  4.16b
     *      - Add call to CALPCKRTE prog to update picked qty, wt and
     *        cube in RTESUM file.
     *
417 A*    09/23/03  HNK  4.17
     *      - Add zone description for each transaction.
417bA*    12/04/03  RH   4.17b
     *      - ENH:Can't close if transaction is a multiple scan trans
417cA*    12/17/03  RH   4.17c
     *      - Fix: Allow change for trans that is a multiple scan tran
     *             Reverse some of 417b changes.
417dA*    01/15/04  HNK  4.17d
     *      - Can not close if transaction has label recs marked with
     *        'F' (Flags) in LBVRFY.
     *      - Display 'F' if there are any flags (shorts) for trans
417eA*    02/04/04  DAS  4.17e
     *      - Revised loop in ZZFLAG to leave at eof.
417fA*    05/25/04  MLB  4.17f
     *      - ENH: Revised 4.17d mod to not allow pick trans to close
     *        if LBVRFY = 'F' or 'I'. If LBVRFY is 'I', this means
     *        inventory control has to try and find item. This gives
     *        3 chances to try and find missing product before outing
     *        or shorting item.
     *
500 A*    12/01/04  MLB  5.00
     *      - Fix: Revised ZZFILL to movel the transaction type into
     *        the type field. Text was being truncated.
500bA*    12/29/04  RH   5.00b
     *      - Fix: Can not close trans with status 2(started)
500cA*    11/30/05  MLB  5.00c
     *      - Enh: Revised program to load transaction, employee
     *        number onto View 2.
500dA*    12/19/05  RH   5.00d
     *      - Can not close if transaction has WORKSOS records (qty
     *        not moved to holding slot yet)
     *
510 A*    06/21/06  MLB  5.10
     *      - Fix: Revised program to not allow Close processing
     *        to proceed if PTSTAT is greater than '4'.
     *      - Fix: Revised routine ZZCHKT to not allow proessing
     *        to proceed if PTSTAT is greater than '4'.
     *
510aA*    07/20/06  JCJ  5.10a
     *      - Enh: Add Verify Cwgt. to F16 processing.
510bA*    07/26/06  MLB  5.10b
     *      - Enh: Add client custom code support.
510cA*    07/28/06  MLB  5.10c
     *      - Fix: Changed ZZPOS to populate fields for correct positioning.
     *
530 A*    11/30/09  JCJ  5.30
     *      - Moved POSTNREC/OPTREC into DSPSFC.
     *      - Removed READ/WRITE for POSTNREC/OPTREC.
     *      - Re: Webfacing could not handle double read.
     *
530 A*    11/30/09  JCJ  5.30
     *      - Enh: Add file Truckh to retrieve Truck Template
     *
530bA*    05/19/10  JCJ  5.30b
     *      - Enh: F16 - restore logic that calls @DELPG with *VRFYCW
     *             by removing client custom code that skips @DELPG.
530cA*    06/15/10  MLB  5.30c
     *      - Fix: Revised 5.30 mod above to omit Merge label records
     *             from the catchwgt checks.
     *
610a *    04/27/10  GJA  6.10a     P#00243
     *      - Enh: Changed UCI to be option driven.  OPUCI
     *
610b *    05/11/10  GJA  6.10b     P#00243
     *      - Fix: Changed UCI option position.
     *
610cA*    06/21/10  JCJ  6.10c
     *      - Fix: In ZZCW skip any ORDC record with a weight of 0.
     *
610dA*    06/30/10  JCJ  6.10d
     *      - Fix: Revised 5.30 mod above to omit label records with
     *             LBQPCK = 0 from the catchwgt checks.
     *
620aA*    11/30/10  RBD  6.20a
     *      - Stop user from touching Normal transaction if the
     *        corresponding Pre-Pick transactions aren't closed.
     *
620bA*    12/01/10  DAS  6.20b
     *      - Revised 620a to use prexref1 instead of prexref3.
     *
620cA*    12/01/10  DAS  6.20c
     *      - Revised to pull PRE info into normal transaction.
     *
620dA*    02/16/11  JCJ  6.20d
     *      - Fix: ensure that the normal routeid matches routeid
     *        passed in.
     *
640AA*    03/02/11  DAS  6.40A
     *      - Add option ET to export transaction to staging files.
     *
640bA*    04/25/11  RBD  6.40b
     *      - Prevent user from touching a transaction if any labels
     *        associated with the transaction has a USR slot.
     *
640cA*    05/14/12  JCJ  6.40c
     *      - added catch weight processing from F16 to option 9.
     *
640dA*    06/06/12  LMC  6.40d
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
640eA*    08/14/12  LMC  6.40e
     *      - Enh: Don't call WRTTRAN1 multiple times for same tran#
     *
640fA*    12/26/12  JCJ  6.40f
     *      - Fixed DDE caused by F16 trashing transaction number.
     *
650aA*    03/20/13  JCJ  6.50a
     *      - Fix: Revised 5.30 mod above to omit Adjustment label
     *             records from the catchwgt checks.
     *
650bA*    03/19/13  LMC  6.50b
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
     *
650cA*    07/08/13  LMC  6.50c
     *      - Fix: Change definition on field wrttran#
650dA*    12/10/13  LMC  6.50d
     *      - Enh: Show loader merge in the w1flag field if no other
     *        flags exist. Display Z for loader merger transaction.
650eA*    12/26/13  RBD  6.50e
     *      - Recompiled, LABEL76 changed.
     *
700aA*    11/19/15  NLK  7.00a
     *      - AMP change
700bA*    06/16/16  NLK  7.00b
     *      - DelvRt of an AMP when having catchwgt items in the box
     *        can omit the check if cw exists on the tran# not being
     *        picked and is the discription of the boxed items.
710aA*    03/17/17  DAS  7.10a
     *      - Enh: Added call to PT640AC to check if any transactions
     *        should be auto closed. Originally created for Cheney.
720aA*    06/11/18  DAS  7.20a
     *      - Removed call to PT640AC for furthre investigation.
     *        Neither Ocala or Riviera call this. Looks like this is
     *        causing unclosed records to be written to EXPSORDL/T.
720bA*    08/24/18  DAS  7.20b
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
730aA*    11/24/18  DAS  7.30a
     *      - Revised to prevent closing transaction if open order
     *        audit exists.
730b *    01/24/19  DAS  7.30b
     *      - Added pltid parm to chkordaud.
760 A*    03/07/22  KDE  7.60
     *      - Enh: Add ELS Goal data once all transactions completed
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
     *
CBIaA*    10/29/03  RH   CBIa
     *      - Call OR663CL to print Drivers pallet detail report.
     *
CBIBA*    10/31/03  HNK  CBIB - TEMPORARY
     *      - HARD CODE PRINTER DEV TO LP10
CBIcA*    11/04/03  RH   CBIc
     *      - Get printer DEV from REPORTS file. Replace CBIB
CBIdA*    10/08/04  RH   CBId
     *      - Set FLAGNC to not do catch wt check in PT132 if F7
     *        Vfy Cathc wt is pressed before F16 Close all.
CBIe *    11/19/04  HNK  CBIe
     *      - Call OR670CL to print Route summary report.
CBIg *    09/22/06  HNK  CBIg
     *      - Reverse CBIe.  Report not reqd. Mark email 9.22.06
CBIhA*    11/28/16  DAS/JCJ  CBIh
     *      - Added skip for gen2 pallets because the catch weights
     *        are on the gen1 pallets for Cheney.  We did this because
     *        the gen 2 pallets were getting flagged for catch
     *        weights in error.
CBIiA*    12/20/16  MLB  CBIi
     *      - Revised routine ZZCW to bypass check for missing c/wgts
     *        for export orders. This mod is needed because Cheney's
     *        previous version did not check for missing wgts when opt
     *        9=Quick close or F16=Close all was selected.
     *
CBI1A*    04/21/05  CBI1-JGD
     *      - Added logic to process new option
     *        (opt# 10 - View Tran Info)
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Eastland Food Corp.
EFCaA*    05/31/11  RH   EFCa
     *      - Enh: Removed "9=Quick Close" from EFC options.
EFCbA*    06/06/11  RH   EFCb
     *      - Enh: Removed "F16=Close All"
     *      - Add call to OR320CL, Print SOS slot transfer quantity.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Grocery Supply Co.
     *
GSC A*    01/27/06  JCJ  GSC
     *      - Fix: In ZZCW skip any ORDC record with a weight of 0.
     *      - Removed "2=Change and Close" from GSC options.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
     *
HAR A*    07/26/06  MLB  HAR
     *      - Revised program to seton ind 35 to position cursor on
     *        transaction number.
     *
HARaA*    08/16/06  MLB  JCJ
     *      - Revised program to save position to field for use with
     *        cursor position logic.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
     *
PAKaA*    11/03/06  PAK  RAH
     *      - Packers - added call to CE190 on option '6' to view
     *        UCI's entered for a particular transaction.
PAKbA*    07/23/07  PAKb RH
     *      - Enh: Add option 65 to call CK365PCL for one transaction
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    03/25/09  SVL  DAS
     *      - Revised to not verify Cwgt in F16 before calling PT132.
     *        PT132 will verify the weights.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    03/31/10  DRY  MLB
     *      - Revised to not verify Cwgt in F16 before calling PT132.
     *        PT132 will verify the weights.
     *      - Added DRY to SVL mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods Company
     *
FFCaA*    05/10/10  MLB  FFCa
     *      - Revised to not verify Cwgt in F16 before calling PT132.
     *        PT132 will verify the weights.
     *      - Added FFCa to SVL mod.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Avalon Foodservice
     *
AVL A*    11/15/11  MLB  AVL
     *      - Revised pgm to add support for DSPSFLAV and DSPCTLAV
     *        so that Retalix Unit of Work value can be displayed
     *        in place of Dakota transaction number.
     *      - Incremented PT64001 to PT64002 to add new screen fmts.
AVLaA*    12/05/11  MLB  AVLa
     *      - Revised pgm to pass Retalix Unit of Work# to PT132
     *        so that it can be displayed on the screen to the user.
     *
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
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This is not a normall 110a type program.  Instead of option
     *    4 we are using option 9 with a command of *CLOSE. Also
     *    field $PTYPE was added to $PARMS.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
HAR A*  35        Position cursor to transaction#
GSC A*  74        Chain Indicator
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
414 D** 85        Manually set subfile change flag (SFLNXTCHG)
414 M*  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 AF**pt640fm   cf   e             workstn
AVL DF*pt64001   cf   e             workstn
AVL MFpt64002   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(dspsflgs:recno)
AVL AF                                     sfile(dspsflav:recno)
     Fworkopt   uf a e           k disk
415aD*PIRTRAN4IF  E           K        DISK
415aMFpirtran4  uf   e           k disk
     F                                     rename(ptrec:record)
     Fpirtran   if   e           k disk
     F                                     rename(ptrec:recordu)
415aAFLabel8    if   e           k disk
417 AFpltsum4   if   e           k disk
417 AFzoneh     if   e           k disk
417bAFmultran1  if   e           k disk
CBIc Freports   if   e           k disk
     Frtehed    uf   e           k disk
620cDF*abel90   if   e           k disk
620cMFLabel90   uf   e           k disk
500dAFworksos2  if   e           k disk
GSC AFordlbl3   if   e           k disk
610aAFoptions   if   e           k disk
530 AFtruckh    if   e           k disk
530bAFlabel7    if   e           k disk
620cDF*rdc1     if   e           k disk
620cMFordc1     uf a e           k disk
620aAFlabel76   if   e           k disk    prefix(L76_)
620bMFprexref1  if   e           k disk
620aAFprexref2  if   e           k disk    rename(pxrec:pxrec2)
620aAFprexref4  uf a e           k disk    rename(pxrec:pxrec4)
700aAFampxref2  if   e           k disk    rename(axrec:axrec2)
700aAFampxref4  uf a e           k disk    rename(axrec:axrec4)
620cAFlabel     if   e           k disk    rename(lbrec:lbrec0)
620cAF                                     prefix(L_)
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
     D zopt            s              2    dim(20) ctdata perrcd(20)
PAK d*                   OPTLN   1   1 75
EFC MD optln           s             75    dim(3) ctdata perrcd(1)
EFC DD*optln           s             75    dim(2) ctdata perrcd(1)
     D cmdln           s             79    dim(6) ctdata perrcd(1)
     D tcod            s              6    dim(10) ctdata perrcd(1)
     D tdsc            s             30    dim(10) alt(tcod)
530bD***                 EMSG    1   1 79
610cD *emsg            s             79    dim(2) ctdata perrcd(1)
620aD *emsg            s             79    dim(3) ctdata perrcd(1)
640bDD*emsg            s             79    dim(4) ctdata perrcd(1)
EFCbDD*emsg            s             79    dim(5) ctdata perrcd(1)
EFCbMD emsg            s             79    dim(6) ctdata perrcd(1)
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
     D @getcl          c                   const('GETCLIENT')
510bA*
GSC AD/copy qcopysrc,id#gsc
HAR A /copy qcopysrc,id#harbor
PAK a /copy qcopysrc,id#packers
SVLAa /copy QCOPYSRC,id#saval
DRY a /COPY QCOPYSRC,ID#DAIRYLA
FFCaa /COPY QCOPYSRC,ID#FISCHER
EFCaAD/copy qcopysrc,id#eastlan
AVL AD/copy qcopysrc,id#avalon
CBIhA /copy qcopysrc,id#cheney
650bA*----------------------------------------------------------------
650bA*  Data Formats
650bA*----------------------------------------------------------------
650bA /COPY *libl/qcopysrc,C#CWLOG
650bAD savever#        s                   like($cwver#)
     *----------------------------------------------------------------
     D                 ds
     D  $ord                   1      7p 0
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     D  $ktruk                14     23
     D  $kstat                24     24
     D  $ktype                25     25
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     *                                       1  50 DSUKEY
     D  ptwhse                 1      3  0 inz(0)
     D  ptgrp1                 4      4
     D  ptgrp2                 5      5
     D  ptrtpo                 6     14
     D  pttrn#                15     21  0 inz(0)
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukrte                  4      8
     D  ukpo                   9     17
     D  uktrn#                18     24  0 inz(0)
AVLaAD  avuow#                41     50    inz(' ')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('PT132')
     D @delpg          c                   const('PT132')
     D @prtpg          c                   const('NONE')
     D @pckrt          c                   const('CALPCKRTE')
404 A*----------------------------------------------------------------
404 A* Status message(s)
     D sts01           c                   const('Open')
     D sts02           c                   const('Started(Active)')
     D sts03           c                   const('Ended')
     D sts04           c                   const('Closed')
     D sts08           c                   const('Interrupted')
     D sts09           c                   const('Cancelled')
     *----------------------------------------------------------------
CBIe * Constants
     D @meat           c                   const('MEAT-INSP ')
     D @ppick          c                   const('PRE-PICK  ')
     D @cntnr          c                   const('CONTAINER ')
     D @wlcll          c                   const('WILL-CALL')
     D @sdsvc          c                   const('SUD-SVC')
     D @dmges          c                   const('DAMAGES')
     D @addon          c                   const('ADD-ONS')
     D @brekr          c                   const('BREAKERS')
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
     D  $ptype                81     88
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
CBIiAD ohmisc          ds
CBIiAD  dssdte                 1      8
CBIiAD  dsspcl                 9     11
CBIiAD  dsrpck                12     12
CBIiAD  dxdoor                13     14
CBIiAD  dsmeat                15     15
CBIiAD  dscode                16     16
CBIiAD  dsppck                17     17
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
610cAD                 ds
610cAD  wrkmsg                 1     21
610cAD  ertrn#                 1      7
610cAD  slash                  8      8
610cAD  eritem                 9     23
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
640dA*----------------------------------------------------------------
640dA*  Prototypes
640dA*----------------------------------------------------------------
650bA /copy qcopysrc,p.cw800
730aA /copy qcopysrc,p.chkordau
640dA
640dAD wrttran1        pr                  extpgm('WRTTRAN1')
640dA * Input
640dAD   ppcmd                        8
640dAD   ppwait                       2  0
640dAD   ppwhse                       3  0
650cDD*  pptran#                           like(pttrn#)
650cMD   pptran#                      7  0
640dAD   ppfromdate                   8  0
640dAD   pptodate                     8  0
640dAD   ppemp#                       5  0
610aA*----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPISHS  -  Extended history weeks.
     *    OPUCI   -  Use UCI processing (Y,N)
     *
     * Data structure
     *
     D opdata          ds
610bD*****                                  33  33 OPUCI
610bMD  opuci                 36     36
     D  optend               117    117
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
CBIaAD $whsea          s              3
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D close           s              1
     D clsall          s              1
     D comand          s              5  0
     D dsplyd          s              2  0
EFCbAD dev             s             10
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
CBIdAD flagnc          s              1
     D forceb          s              1
     D forevr          s              1
620cAD forever         s               n
EFCbAD form            s             10
     D frstky          s                   like($puky)
720bAD gGen            s              1  0
720bAD gGenTruck       s               n
720bAD gGenMerge       s               n
720bAD gGenOverflow    s               n
720bAD gGenTruckExt    s               n
720bAD gPltId          s                   like(lbpal#)
     D goback          s              2  0
     D help            s              5  0
     D kygrp1          s                   like(ptgrp1)
     D kygrp2          s                   like(ptgrp2)
     D kypo            s                   like(l8po)
     D kyrtpo          s                   like(ptrtpo)
     D kytrn#          s                   like(pttrn#)
     D kywhse          s                   like(ptwhse)
     D lsttrn          s              7  0
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
620aAD hasPrepick      s               n   inz('0')
700aAD hasAMPpick      s               n   inz('0')
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
     D svinp1          s              7  0
     D t               s              2  0
     D tmpflg          s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
CBIcAD wkprtf          s             10
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
640dAD wrtpcmd         s             10
640dAD wrtpwait        s              2  0
640dAD wrtpwhse        s              3  0
650cDD*wrtptran#       s                   like(pttrn#)
650cMD wrtptran#       s              7  0
640dAD wrtpfrmdate     s              8  0
640dAD wrtptodate      s              8  0
640dAd wrtpemp#        s                   like(ptemp#)
640eAD wrtsaveptran#   s                   like(pttrn#)
640eAD wrtsaveptstat   s                   like(ptstat)
     D w1zdsc          s             15
     D x               s              3  0
     D y               s              3  0
530 AD $ktmpl          s             10
530bAD cwflg           s              1
530bAD cwitm           s              1
650bAD CWcmd           s             10
650bAD CWpgm           s             10
650bAD CWrtn           s             10
650bAD CWmsg           s             60
650bAD CWdata          s            512
650bAD processstatus   s             10
730aAD coaWhse         s              3  0
730aAD coaRtid         s              5
730aAD coaTran         s              7  0
730aAD coaOrdId        s              7  0
730bAD coaPltId        s              7  0
730aAD coaRtn          s             10
730aAD coaMsg          s            100
760 Ad stdWhse         s              3p 0
760 Ad stdTrn#         s              7p 0
760 Ad stdGoal         s             13p 2
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
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
CBIc C     rpkey         klist
CBIc C                   kfld                    wkprtf
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
400 AC                   exsr      zzstat
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
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
     C                   exsr      sfldsp
530 D ***                read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
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
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   read      dspsfcgs                               50
AVL AC                   when      client = avalon
AVL AC                   read      dspsfcav                               50
AVL MC                   other
     C                   read      dspsfc                                 50
AVL MC                   endsl
     C                   when      view = 2
     C                   read      vw2sfc                                 50
     C                   when      view = 3
     C                   read      vw3sfc                                 50
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
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bAC                   parm                    cliloc           10
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
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsflgs                             79
AVL AC                   when      client = avalon
AVL AC                   write     dspsflav                             79
AVL MC                   other
     C                   write     dspsfl                               79
AVL MC                   endsl
     C                   write     vw2sfl                               79
     C                   write     vw3sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
610aAC                   eval      wkcode = '*SYSTEM '
610aAC                   eval      wkwhse = 0
610aAC     opkey         chain     options                            79
610aAC                   if        *in79
610aAC                   eval      opuci = 'N'
610aAC                   endif
     C                   endsr
650bA*----------------------------------------------------------------
650bA*  clrCWLog     Clear $cwlog   data structure fields
650bA*----------------------------------------------------------------

650bA /free
650bA   begsr ClrCWLog;

650bA     savever# = $cwver#;
650bA     clear $cwlog;
650bA     $cwver# = savever#;
650bA     $cwaddemp = ptemp#;
650bA     $cwaddusr = #user;
650bA     $cwaddpgm  = #prog;
650bA     $cwaddjob  = #job;
650bA     $cwaddnbr = #jobn;

650bA   endsr;
650bA /end-free

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
CBIdAC                   eval      flagnc = *off
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
CBIdAC                   eval      flagnc = *off
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
CBIdAC                   eval      flagnc = *off
     C                   exsr      clrsch
     C     1             do        10            x
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC     x             chain     dspsflgs                           79
AVL AC                   when      client = avalon
AVL AC     x             chain     dspsflav                           79
AVL MC                   other
     C     x             chain     dspsfl                             79
AVL MC                   endsl
     C                   if        not *in79
     C                   eval      option = '  '
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   update    dspsflgs
AVL AC                   when      client = avalon
AVL AC                   update    dspsflav
AVL MC                   other
     C                   update    dspsfl
AVL MC                   endsl
     C                   endif
     C     x             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw2sfl
     C                   endif
     C     x             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw3sfl
     C                   endif
     C                   enddo
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
CBIdAC                   eval      flagnc = *off
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
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
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inku
CBIdAC                   eval      flagnc = *off
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD10 - Previous view
     *
     C                   if        *inkj
CBIdAC                   eval      flagnc = *off
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
     *  TEST FOR CMD11 - Next view
     *
     C                   if        *inkk
CBIdAC                   eval      flagnc = *off
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
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
CBIdAC                   eval      flagnc = *off
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
CBIdAC                   eval      flagnc = *off
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
CBIdAC                   eval      flagnc = *off
413cA*
413cA*    Clear workfile of all entries added when F16=Close all
413cA*    is selected and then canceled using F12.
413cA*
413cAC                   if        clsall = *on
413cAC                   exsr      clrsch
413cAC                   eval      clsall = *off
413cAC                   endif
413cA*
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
     C                   if        recno < 11
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
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsflgs
AVL AC                   when      client = avalon
AVL AC                   write     dspsflav
AVL MC                   other
     C                   write     dspsfl
AVL MC                   endsl
     C                   write     vw2sfl
     C                   write     vw3sfl
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
     C                   eval      *in81 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsfcgs
AVL AC                   when      client = avalon
AVL AC                   write     dspsfcav
AVL MC                   other
     C                   write     dspsfc
AVL MC                   endsl
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
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
     C                   if        wkoopt = ' 9'
640cA*
640cA* Check to see if all catch weights records have been entered.
640cA*
640cAC                   eval      dsukey = wkokyu
640cAC                   exsr      zzchkCW
640cAC                   if        error = '1'
640cAC                   leave
640cAC                   endif
730aA*  Prevent user from closing a transaction if it
730aA*  contains an open order audit.
730aAC                   eval      dsukey = wkokyu
730aAC                   exsr      zzchkordaud
730aAC                   if        error = '1'
730aAC                   goto      end02
730aAC                   endif
640bA*  Prevent user from touching a transaction if any labels
640bA*  associated with the transaction has a USR slot.
640bAC                   eval      dsukey = wkokyu
640bAC                   exsr      zzchkUSR
640bAC                   if        error = '1'
640bAC                   goto      end02
640bAC                   endif
620aA*  Stop user from touching the Normal transaction if the
620aA*  corresponding Pre-Pick transactions aren't closed.
620aAC                   eval      dsukey = wkokyu
620aAC                   exsr      zzchkPrepick
620aAC                   if        error = '1'
620aAC                   goto      end02
620aAC                   endif
620cA*  Update normal transaction with pre-pick information.
620cAC                   eval      dsukey = wkokyu
620cAC                   exsr      updNrmTran
620cAC                   if        error = '1'
620cAC                   goto      end02
620cAC                   endif
700aA*  Update DelvRt transaction with AMP-pick information.
700aAC                   eval      dsukey = wkokyu
700aAC                   exsr      updDelvTran
700aAC                   if        error = '1'
700aAC                   goto      end02
700aAC                   endif
500b *  Check for transaction status 2=started
510 A*     -or- Transaction suspended, interupted.
500b C                   eval      dsukey = wkokyu
500b C                   exsr      zzchkt
500b C                   if        error = '1'
500b C                   exsr      zm6405
500b C                   goto      end02
500b C                   endif
     *  Check for Multi Trans
417b C                   eval      dsukey = wkokyu
417b C                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6401
417b C                   goto      end02
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      dsukey = wkokyu
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d C                   goto      end02
417d C                   endif
500d *  Check for WORKSOS Single Order Selection in use
500d C                   eval      dsukey = wkokyu
500d C                   exsr      zzwsos
500d C                   if        error = '1'
500d C                   exsr      zm6406
500d C                   goto      end02
500d C                   endif
     *
     *  Call delete program
     *
     C                   exsr      inzpar
CBIdAC                   if        flagnc = *on
CBIdAC                   eval      $pcmd = '*CLOSENC'
CBIdAC                   else
     C                   eval      $pcmd = '*CLOSE  '
CBIdAC                   endif
     C                   eval      $puky = wkokyu
413 MC                   call      @delpg
413 MC                   parm                    $parms
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
417b C     end02         tag
CBIdAC                   eval      flagnc = *off
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
640fAC                   select
640fAC                   when      *inkq
640fAC                             and (lbvrfy = 'I'
640fAC                             or  lbvrfy = 'F')
640fAC                   other
     C                   eval      dsukey = $pouky
640fAC                   endsl
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
     C     fileky        setll     record
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
     *     Do all quick closes first (option 9)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 9'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 9'
640cA*
640cA* Check to see if all catch weights records have been entered.
640cA*
640cAC                   eval      dsukey = wkokyu
640cAC                   exsr      zzchkCW
640cAC                   if        error = '1'
640cAC                   goto      optnse
640cAC                   endif
640bA*  Prevent user from touching a transaction if any labels
640bA*  associated with the transaction has a USR slot.
640bAC                   eval      dsukey = wkokyu
640bAC                   exsr      zzchkUSR
640bAC                   if        error = '1'
640bAC                   goto      optnse
640bAC                   endif
620aA*  Stop user from touching the Normal transaction if the
620aA*  corresponding Pre-Pick transactions aren't closed.
620aAC                   eval      dsukey = wkokyu
620aAC                   exsr      zzchkPrepick
620aAC                   if        error = '1'
620aAC                   goto      optnse
620aAC                   endif
620cA*  Update normal transaction with pre-pick information.
620cAC                   eval      dsukey = wkokyu
620cAC                   exsr      updNrmTran
620cAC                   if        error = '1'
620cAC                   goto      optnse
620cAC                   endif
620cA
700aA*  Update DelvRt transaction with AMP-pick information.
700aAC                   eval      dsukey = wkokyu
700aAC                   exsr      updDelvTran
700aAC                   if        error = '1'
700aAC                   goto      optnse
700aAC                   endif
700aA
530bMC                   eval      dsukey = wkokyu
530bAC                   eval      ptwhse = ukwhse
530bAC                   eval      pttrn# = uktrn#
530bMC                   exsr      zzcw
530bMC                   if        cwflg = *off  and
530bMC                             cwitm = *on
530bAC                   movel     emsg(2)       errmsg
610cMC                   move      eritem        errmsg
530bAC                   eval      error = *on
530bAC                   exsr      zm0105
530bMC                   goto      optnse
530bMC                   endif
500b *  Check for transaction status 2=started
510 A*     -or- Transaction suspended, interupted.
530bD***                  MOVE WKOKYU    DSUKEY
500b C                   exsr      zzchkt
500b C                   if        error = '1'
500b C                   exsr      zm6405
500b C                   goto      optnse
500b C                   endif
417b C                   eval      dsukey = wkokyu
417b C                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6401
417b C                   goto      optnse
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      dsukey = wkokyu
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d C                   goto      optnse
417d C                   endif
500d *  Check for WORKSOS Single Order Selection in use
500d C                   eval      dsukey = wkokyu
500d C                   exsr      zzwsos
500d C                   if        error = '1'
500d C                   exsr      zm6406
500d C                   goto      optnse
500d C                   endif
     *
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
413 MC                   exsr      scr02i
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
     *   Change
     *
     C                   if        wkoopt = ' 2'
417cD*R                   MOVE WKOKYU    DSUKEY
417cD*R                   EXSR ZZMULT
417cD*R         ERROR     IFEQ '1'
417cD*R                   EXSR ZM6401
417cD*R                   GOTO ENDOP2
417cD*R                   ENDIF
640bA*  Prevent user from touching a transaction if any labels
640bA*  associated with the transaction has a USR slot.
640bAC                   eval      dsukey = wkokyu
640bAC                   exsr      zzchkUSR
640bAC                   if        error = '1'
640bAC                   goto      endop2
640bAC                   endif
620aA*  Stop user from touching the Normal transaction if the
620aA*  corresponding Pre-Pick transactions aren't closed.
620aAC                   eval      dsukey = wkokyu
620aAC                   exsr      zzchkPrepick
620aAC                   if        error = '1'
620aAC                   goto      endop2
620aAC                   endif
620cA*  Update normal transaction with pre-pick information.
620cAC                   eval      dsukey = wkokyu
620cAC                   exsr      updNrmTran
620cAC                   if        error = '1'
620cAC                   goto      endop2
620cAC                   endif
700aA*  Update DelvRt transaction with AMP-pick information.
700aAC                   eval      dsukey = wkokyu
700aAC                   exsr      updDelvTran
700aAC                   if        error = '1'
700aAC                   goto      endop2
700aAC                   endif
500b *  Check for transaction status 2=started
510 A*     -or- Transaction suspended, interupted.
500b C                   eval      dsukey = wkokyu
500b C                   exsr      zzchkt
500b C                   if        error = '1'
500b C                   exsr      zm6405
500b C                   goto      endop2
500b C                   endif
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
412 A*
412 A*   Catch Weight entry
412 A*
412 AC                   if        wkoopt = ' 3'
640bA*  Prevent user from touching a transaction if any labels
640bA*  associated with the transaction has a USR slot.
640bAC                   eval      dsukey = wkokyu
640bAC                   exsr      zzchkUSR
640bAC                   if        error = '1'
640bAC                   goto      endop2
640bAC                   endif
620aA*  Stop user from touching the Normal transaction if the
620aA*  corresponding Pre-Pick transactions aren't closed.
620aAC                   eval      dsukey = wkokyu
620aAC                   exsr      zzchkPrepick
620aAC                   if        error = '1'
620aAC                   goto      endop2
620aAC                   endif
620cA*  Update normal transaction with pre-pick information.
620cAC                   eval      dsukey = wkokyu
620cAC                   exsr      updNrmTran
620cAC                   if        error = '1'
620cAC                   goto      endop2
620cAC                   endif
620cA
700aA*  Update DelvRt transaction with AMP-pick information.
700aAC                   eval      dsukey = wkokyu
700aAC                   exsr      updDelvTran
700aAC                   if        error = '1'
700aAC                   goto      endop2
700aAC                   endif
700aA
412 AC                   eval      $pcmd = '*CHANGE '
412 AC                   call      'CW110A'
412 AC                   parm                    $puky
412 AC                   parm                    $prtn
412 AC                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
AVLaAC                   eval      dsukey = wkokyu
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
     *
PAK aC                   if        wkoopt = '16'  and
PAK a*****      CLIENT    ANDEQPACKER
610aAC                             opuci = 'Y'
PAK AC                   eval      $ord = hord
PAK aC                   call      'CE190'
PAK aC                   parm                    lbord
PAK aC                   parm      *zeros        hseq              5 0
PAK aC                   parm                    hitem
PAK aC                   parm                    htrn#
PAK aC                   parm                    portn             8
PAK aC                   if        portn = '*NOGOOD '
PAK aC                   eval      cancel = *on
PAK aC                   eval      error = *on
PAK aC                   movel     emsg(1)       errmsg
PAK aC                   exsr      zm0105
PAK aC                   endif
     C                   else
PAKb *   CK365P Report
     *
PAKb C                   if        wkoopt = '65'  and
PAKb C                             client = packer
PAKb C                   move      pttrn#        $ptrn#
PAKb C                   eval      $prtid = $krtid
PAKb C                   move      $kwhse        $pwhse
PAKb C                   call      'CK365PCL'
PAKb C                   parm                    $pwhse            3
PAKb C                   parm                    $prtid            5
PAKb ***                  PARM 'HP8100'  $PDEV  10
PAKb C                   parm      '*JOB'        $pdev            10
PAKb C                   parm      '*STD    '    $pform           10
PAKb C                   parm                    $ptrn#            7
CBI1ACSR                 else
CBI1A *
CBI1A *   View Transaction Info.
CBI1A *
CBI1AC     wkoopt        ifeq      '10'
CBI1AC                   move      '*NOOPT  '    $pcmd
CBI1AC                   z-add     pttrn#        $trn#             7 0
CBI1AC                   call      'LP130B'
CBI1AC                   parm                    $pcmd
CBI1AC                   parm                    $trn#
CBI1A *
PAKb C                   else
     *
     C                   exsr      zzopt
PAKb C                   endif
PAK aC                   endif
     C                   endif
     C                   endif
     C                   endif
CBI1AC                   endif
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
412 AC                   endif
     C                   endif
     C                   endif
417b C     endop2        tag
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
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
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
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
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
     *
     C                   if        wkoopt = ' 9'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
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
     C     dsplyd        add       10            goback
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
     *  READ SPECIFIED FLITCHES FILE
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
     C                   if        wkoopt = ' 9'
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
650bA*----------------------------------------------------------------
650bA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650bA*----------------------------------------------------------------

650bA /free
650bA   begsr processCWlog;
650bA     exsr clrCWLog;
650bA     $cwwhse = ocwhse;
650bA     $cwitem = ocitem;
650bA     $cwseltrn# = octran;
650bA     $cwsellbl# = oclbl#;
650bA     $cwselord  = ocord;
650bA     $cwselseq  = ocseq#;
650bA     $cwselcseq = ocseq;
650bA     $cwwgtlbs = occwgt;
650bA     $cwentflg = 3;

650bA     cwdata = $cwlog;
650bA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650bA     $cwlog = cwdata;

650bA   endsr;
650bA /end-free
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
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   readc     dspsflgs                               79
AVL AC                   when      client = avalon
AVL AC                   readc     dspsflav                               79
AVL MC                   other
     C                   readc     dspsfl                                 79
AVL AC                   endsl
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   when      view = 3
     C                   readc     vw3sfl                                 79
     C                   endsl
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
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
EFCaAC                   select
EFCaAC                   when      client = eastland
EFCaAC                   if        option = ' 9' and
EFCaAC                             $ktype = 'S'
EFCaAC                   eval      error = *on
EFCaAC                   eval      *in21 = *on
EFCaAC                   eval      errmsg = *blanks
EFCaAC                   exsr      zm0108
EFCaAC                   endif
EFCaAC                   endsl
410 AC                   if        option = ' 2'  and
410 AC                             w1stat = sts04
410 AC                   eval      option = *blanks
410 AC                   endif
410 AC                   if        option = ' 9'  and
410 AC                             w1stat = sts04
410 AC                   eval      option = *blanks
410 AC                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   select
     C                   when      view = 1
     C                   z-add     recno         y
     C                   when      view = 2
     C                   z-add     recno         y
     C                   when      view = 3
     C                   z-add     recno         y
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   z-add     reccnt        y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsflgs
AVL AC                   when      client = avalon
AVL AC                   write     dspsflav
AVL MC                   other
     C                   write     dspsfl
AVL MC                   endsl
     C                   write     vw2sfl
     C                   write     vw3sfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsfcgs
AVL AC                   when      client = avalon
AVL AC                   write     dspsfcav
AVL MC                   other
     C                   write     dspsfc
AVL MC                   endsl
     C                   write     vw2sfc
     C                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
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
530 D ***                write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC     1             chain     dspsflgs                           79
AVL AC                   when      client = avalon
AVL AC     1             chain     dspsflav                           79
AVL MC                   other
     C     1             chain     dspsfl                             79
AVL MC                   endsl
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   update    dspsflgs
AVL AC                   when      client = avalon
AVL AC                   update    dspsflav
AVL MC                   other
     C                   update    dspsfl
AVL MC                   endsl
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
     C                   update    vw2sfl
     C                   endif
     C                   when      view = 3
     C     1             chain     vw3sfl                             79
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
     C                   update    vw3sfl
     C                   endif
     C                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = posrec
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   write     dspsfcgs
AVL AC                   when      client = avalon
AVL AC                   write     dspsfcav
AVL MC                   other
     C                   write     dspsfc
AVL MC                   endsl
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
     C                   select
     C                   when      view = 1
AVL MC                   select
AVL MC                   when      client = gsc
GSC AC     x             chain     dspsflgs                           79
AVL AC                   when      client = avalon
AVL AC     x             chain     dspsflav                           79
AVL MC                   other
     C     x             chain     dspsfl                             79
AVL MC                   endsl
     C                   when      view = 2
     C     x             chain     vw2sfl                             79
     C                   when      view = 3
     C     x             chain     vw3sfl                             79
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
     C                   select
     C                   when      view = 1
AVL AC                   select
AVL MC                   when      client = gsc
GSC AC                   update    dspsflgs
AVL AC                   when      client = avalon
AVL AC                   update    dspsflav
AVL MC                   other
     C                   update    dspsfl
AVL MC                   endsl
     C                   when      view = 2
     C                   update    vw2sfl
     C                   when      view = 3
     C                   update    vw3sfl
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
417b *----------------------------------------------------------------
417b *      6401  Multi trans, end using task entry.
417b *
417b C     zm6401        begsr
417b C                   eval      #msgid = 'PT64001'
417b C                   eval      #msgtp = '*DIAG  '
417b C                   eval      $md = *blanks
417b C                   exsr      zmpmsg
417b C                   endsr
417b *----------------------------------------------------------------
417b *      6402  Multi trans exists, can not use F16 to close all
417b *
417b C     zm6402        begsr
417b C                   eval      #msgid = 'PT64002'
417b C                   eval      #msgtp = '*DIAG  '
417b C                   eval      $md = *blanks
417b C                   exsr      zmpmsg
417b C                   endsr
     *----------------------------------------------------------------
417d *      6403  Flags exists, can not close this transaction.
417d *
417d C     zm6403        begsr
417d C                   eval      #msgid = 'PT64003'
417d C                   eval      #msgtp = '*DIAG  '
417d C                   eval      $md = *blanks
417d C                   exsr      zmpmsg
417d C                   endsr
500b *----------------------------------------------------------------
500b *      6405  Trans started, can not close this transaction.
500b *
500b C     zm6405        begsr
500b C                   eval      #msgid = 'PT64005'
500b C                   eval      #msgtp = '*DIAG  '
500b C                   eval      $md = *blanks
500b C                   exsr      zmpmsg
500b C                   endsr
500d *----------------------------------------------------------------
500d *      6406  Work SOS records exist, can not close this trans.
500d *
500d C     zm6406        begsr
500d C                   eval      #msgid = 'PT64006'
500d C                   eval      #msgtp = '*DIAG  '
500d C                   eval      $md = *blanks
500d C                   exsr      zmpmsg
500d C                   endsr
510aA*----------------------------------------------------------------
510aA*      6407  Closing Route with transactions not in ended status
510aA*
510aAC     zm6407        begsr
510aAC                   eval      #msgid = 'PT64007'
510aAC                   eval      #msgtp = '*DIAG  '
510aAC                   eval      $md = *blanks
510aAC                   exsr      zmpmsg
510aAC                   endsr
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
414aA*
414aA*  Test for F7 - Verify catchweights for route
414aA*
414aAC                   if        *inkg
CBIdAC                   eval      flagnc = *on
     C     partky        setll     record
     C                   dou       forevr <> forevr
415aD*R         PARTKY    READERECORD                   77
415aMC     partky        reade(n)  record                                 77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *    Include only selection transactions to close.
     *
     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        ptstat <> '4'
     C                   exsr      inzpar
     C                   eval      $pcmd = '*VRFYCW '
     C                   eval      $puky = dsukey
     C                   call      @delpg
     C                   parm                    $parms
     C                   endif
     C                   enddo
     *
     C                   endif
     *
     *  Test for F16 - Close all transactions for P.O.
     *
     C                   if        *inkq
EFCbA*  F16 not allowed for Eastland SOS orders.
EFCbAC                   if        client = eastland
EFCbAC                   eval      *in21 = *on
EFCbAC                   eval      *in01 = *on
EFCbAC                   movel     emsg(6)       errmsg
EFCbAC                   move      wrkmsg        errmsg
EFCbAC                   exsr      zm0105
EFCbAC                   goto      endcm1
EFCbAC                   endif
413cAC                   eval      clsall = *on
     C                   eval      tmpflg = *off
     C     partky        setll     record
     C                   dou       forevr <> forevr
415aD*R         PARTKY    READERECORD                   77
415aMC     partky        reade(n)  record                                 77
     C                   if        *in77
     C                   leave
     C                   endif
413bA*
 13bA*    Include only selection transactions to close.
413bA*
413bAC                   if        ptgrp1 <> 'S'
413bAC                   iter
413bAC                   endif
530bD***
530bD***        CLIENT    IFNE SAVAL
530bD***        CLIENT    ANDNEDAIRYL
530bD***        CLIENT    ANDNEFISCHR
510aA*
510aAC                   eval      ukwhse = ptwhse
510aAC                   eval      ukrte = *blanks
510aAC                   eval      ukpo = ptrtpo
510aAC                   eval      uktrn# = pttrn#
510aA*
510aAC                   if        ptstat <> '4'
510aAC                   exsr      inzpar
530bD***                  MOVE '*VRFYCW '$PCMD
530bD***                  MOVE DSUKEY    $PUKY
530bD***                  CALL @DELPG
530bD***                  PARM           $PARMS
530bMC                   exsr      zzcw
530bMC                   if        cwflg = *off  and
530bMC                             cwitm = *on
530bA*  No catch weights entered.
530bMC                   eval      cancel = *on
530bM***                  MOVE *ON       ERROR
530bAC                   eval      *in21 = *on
530bAC                   eval      *in01 = *on
610cMC                   movel     emsg(3)       errmsg
610cMC                   move      wrkmsg        errmsg
530bAC                   exsr      zm0105
530bM***                  LEAVE
530bMC                   endif
510aAC                   endif
510aA*
530bD***                  ENDIF
530bD***
500b *  Check for transaction status 2=started
510 A*     -or- Transaction suspended, interupted.
500b C                   eval      uktrn# = pttrn#
500b C                   exsr      zzchkt
500b C                   if        error = '1'
500b C                   exsr      zm6405
500b C                   eval      clsall = *off
500b C                   exsr      clrsch
500b C                   eval      cancel = *on
500b C                   leave
500b C                   endif
730aA*    Check for open order audit
730aAC                   eval      uktrn# = pttrn#
730aAC                   exsr      zzchkordaud
730aAC                   if        error = '1'
730aAC                   eval      clsall = *off
730aAC                   exsr      clrsch
730aAC                   eval      cancel = *on
730aAC                   leave
730aAC                   endif
417bA*
417bA*    Can not use F16 close all if multiple transactions exist.
417bAC                   eval      uktrn# = pttrn#
417bAC                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6402
417b C                   eval      clsall = *off
417b C                   exsr      clrsch
417b C                   eval      cancel = *on
417b **                   GOTO ENDCMD
417b C                   leave
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      uktrn# = pttrn#
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d C                   eval      clsall = *off
417d C                   exsr      clrsch
417d C                   eval      cancel = *on
417d C                   leave
417d C                   endif
500d *  Check for WORKSOS Single Order Selection in use
500d C                   eval      uktrn# = pttrn#
500d C                   exsr      zzwsos
500d C                   if        error = '1'
500d C                   exsr      zm6406
500d C                   eval      clsall = *off
500d C                   exsr      clrsch
500d C                   eval      cancel = *on
500d C                   leave
500d C                   endif
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        tmpflg = *off
     C                   eval      $puky = dsukey
     C                   endif
     *
     C                   eval      wkokyf = dsfkey
     C                   eval      wkokyu = dsukey
     C     wkounq        chain     workopt                            76
     C                   if        not *in76
410 AC                   if        ptstat <> '4'
     C                   eval      wkoopt = ' 9'
     C                   eval      wkoerr = *off
     C                   update    wkorec
410 AC                   endif
     C                   else
410 AC                   if        ptstat <> '4'
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = dsfkey
     C                   eval      wkokyu = dsukey
     C                   eval      wkoopt = ' 9'
     C                   eval      wkoerr = *off
     C                   write     wkorec
410 AC                   endif
     C                   endif
     C                   enddo
417b C                   if        cancel = '1'
530bAC                   if        *inkq
530bAC                   exsr      clrsch
530bAC                   endif
417b C                   exsr      scr02e
417b C                   else
     *
     C                   exsr      scr02i
417b C                   endif
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
     *          FILEKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain     recordu                            79
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
     *
     *    Code to use when we do have a partial key to use.
     *
415aD*R         PARTKY    READERECORD                   79
415aMC     partky        reade(n)  record                                 79
     C                   if        *in79 <> *on
     C                   if        ptgrp1 <> 'S'
406 D*          PTGRP1    ANDNE'L'
     C                   goto      try1
     C                   endif
     C                   endif
AVLaA*
AVLaAC                   if        client = avalon
AVLaA*
AVLaAC     keyal3        chain     ordlbl3
AVLaAC                   if        %found(ordlbl3)
AVLaAC                   move      *blanks       wuow              9
AVLaAC                   eval      wuow = %subst(alhtrn:1:9)
AVLaAC                   move      wuow          w1uow
AVLaAC                   else
AVLaAC                   evalr     wuow  = '000000000'
AVLaAC                   eval      w1uow = 0
AVLaAC                   endif
AVLaAC                   evalr     avuow# = %trimr(%editc(w1uow: '4'))
AVLaA*
AVLaAC                   endif
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
     *
     *    Code to use when we do have a partial key to use.
     *
415aD*R         PARTKY    REDPERECORD                   79
415aMC     partky        readpe(n) record                                 79
     C                   if        *in79 <> *on
     C                   if        ptgrp1 <> 'S'
406 D*          PTGRP1    ANDNE'L'
     C                   goto      try2
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   eval      t = 1
     C     pttask        lookup    tcod(t)                                50
     C                   if        t = 0
500 D*                    MOVE TDSC,1    W1TYPE
GSC AC                   if        client = gsc
GSC AC                   movel     tdsc(1)       w1typ2
GSC AC                   else
500 MC                   movel     tdsc(1)       w1type
GSC AC                   endif
     C                   else
500 D*                    MOVE TDSC,T    W1TYPE
GSC AC                   if        client = gsc
GSC AC                   movel     tdsc(t)       w1typ2
GSC AC                   else
500 MC                   movel     tdsc(t)       w1type
GSC AC                   endif
     C                   endif
404 A*
404 AC                   select
404 AC                   when      ptstat = '1'
404 AC                   eval      w1stat = sts01
404 AC                   when      ptstat = '2'
404 AC                   eval      w1stat = sts02
404 AC                   when      ptstat = '3'
404 AC                   eval      w1stat = sts03
404 AC                   when      ptstat = '4'
404 AC                   eval      w1stat = sts04
404 AC                   when      ptstat = '8'
404 AC                   eval      w1stat = sts08
404 AC                   when      ptstat = '9'
404 AC                   eval      w1stat = sts09
404 AC                   other
404 AC                   eval      w1stat = *blanks
404 AC                   endsl
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     thkey         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ktmpl = thztmp
530 AC                   else
530 AC                   eval      $ktmpl = $ktruk
530 AC                   endif
     *
     *   Get zone description
     *
417 AC                   eval      w1zdsc = *blanks
417 AC     pttrn#        chain     pltsum4                            79
417 AC                   if        not *in79
417 AC     zhkey         chain     zoneh                              79
417 AC                   if        not *in79
417 AC                   movel     zhdesc        w1zdsc
417 AC                   endif
417 AC                   endif
     *
417d *   Get flags
     *
417d C                   eval      w1flag = *blanks
417d C     l90ke1        setll     label90
417d C                   dow       forevr = forevr
620cDC**   l90ke1        reade     label90                                79
620cMC     l90ke1        reade(n)  label90                                79
417d C                   if        *in79
417d C                   leave
417d C                   endif
417d C                   if        not *in79  and
417d C                             lbvrfy = 'F'
417d C                   eval      w1flag = 'F'
417d C                   leave
417d C                   endif
417f C                   if        not *in79  and
417f C                             lbvrfy = 'I'
417f C                   eval      w1flag = 'I'
417f C                   leave
417f C                   endif
417d C                   enddo
650dA /free
650dA   if w1flag = ' ';
650dA     if pstype = 'L';
650dA       w1flag = 'Z';
650dA     endif;
650dA   endif;
650dA /end-free
GSC AC                   if        client = gsc
GSC AC                   eval      w1whdp = ptwhdp
GSC AC     keyal3        chain     ordlbl3                            74
GSC AC                   if        not *in74
GSC AC                   eval      w1htr# = alhtr#
GSC AC                   else
GSC AC                   eval      w1htr# = *zeros
GSC AC                   endif
GSC AC                   else
GSC A*
500cA*
500cA*    Load View 2 fields.
500cAC                   eval      w2trn# = pttrn#
500cAC                   eval      w2emp# = ptemp#
     *
PAK AC                   eval      hord = lbord
PAK AC                   eval      hitem = lbitem
PAK AC                   eval      htrn# = lbtrn#
GSC AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
HARaAC                   eval      svinp1 = *zeros
610cAC                   eval      slash  = '/'
     *
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    ptwhse
     C                   kfld                    ptgrp2
     C                   kfld                    ptrtpo
     C                   kfld                    pttrn#
     C                   kfld                    ptgrp1
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    uktrn#
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    kywhse
     C                   kfld                    kygrp2
     C                   kfld                    kyrtpo
415aA*
415aA*  Define partial key for LABEL8 file.
415aA*
415aAC     keylb         klist
415aAC                   kfld                    $kwhse
415aAC                   kfld                    $krtid
415aAC                   kfld                    kypo
415aAC                   kfld                    pttrn#
     *
     *  Define partial key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
417 A*  Define key for ZONEH file.
     *
417 AC     zhkey         klist
417 AC                   kfld                    $kwhse
530 D ***                kfld                    $ktruk
530 AC                   kfld                    $ktmpl
417 AC                   kfld                    psszon
530 A*
530 AC     thkey         klist
530 AC                   kfld                    $kwhse
530 AC                   kfld                    $ktruk
     *
417d *  Define partial key for LABEL90
     *
417d C     l90key        klist
417d C                   kfld                    ukwhse
417d C                   kfld                    uktrn#
     *
417d *  Define partial key for LABEL90
     *
417d C     l90ke1        klist
417d C                   kfld                    ptwhse
417d C                   kfld                    pttrn#
620aA*
620aA*  Define partial key for LABEL76
620aA*
620aAC     kylab76       klist
620aAC                   kfld                    $kwhse
620aAC                   kfld                    $krtid
620aAC                   kfld                    uktrn#
700aA*
700aA*  Define partial key for AMPXREF2
700aA*
700aAC     kyampx2       klist
700aAC                   kfld                    $kwhse
700aAC                   kfld                    $krtid
620aA*
620aA*  Define partial key for PREXREF2
620aA*
620aAC     kyprex2       klist
620aAC                   kfld                    $kwhse
620aAC                   kfld                    $krtid
620aA*
620bA*  Define partial key for PREXREF1
620aA*
620bMC     kyprex1       klist
620aAC                   kfld                    L76_lbwhse
620aAC                   kfld                    L76_rhrte
620aAC                   kfld                    L76_ohcord
620aAC                   kfld                    L76_lbitem
GSC A*
GSC A* DEFINE PARTIAL KEY FOR ORDLBL3 FILE.
GSC A*
GSC AC     keyal3        klist
GSC AC                   kfld                    ptwhse
GSC AC                   kfld                    pttrn#
     *
500d *  Define partial key for WORKSOS2
     *
500d C     wsokey        klist
500d C                   kfld                    ukwhse
500d C                   kfld                    uktrn#
     *
530bA*  Define key for ORDC1 file.
     *
530bAC     keyoc1        klist
530bAC                   kfld                    $kwhse
530bAC                   kfld                    lblbl#
     *
530bA*  Define partial key for LABEL7 file.
     *
530bAC     keylb7        klist
530bAC                   kfld                    pttrn#
     *
640bA*  Define partial key for LABEL7 file.
     *
640bAC     keylb7u       klist
640bAC                   kfld                    uktrn#
     *
     *  Setup option and command display lines.
     *
HAR AC                   if        client = harbor
HAR A*    Position cursor on transaction number.
HAR AC                   eval      *in35 = *on
HAR AC                   endif
HAR A*
     C                   eval      view = 1
     C                   eval      maxvw = 3
EFCaMC                   select
EFCaMC                   when      client = packer
PAK aC                   eval      optln1 = optln(2)
EFCaAC                   when      client = eastland
EFCaAC                   if        $ktype = 'S'
EFCaAC                   eval      optln1 = optln(3)
EFCaAC                   else
EFCaAC                   eval      optln1 = optln(1)
EFCaAC                   endif
EFCaAC                   other
PAK DC*                  if        client <> packer
     C                   eval      optln1 = optln(1)
EFCaAC                   endsl
EFCaDC*                  else
EFCaDC*                  eval      optln1 = optln(2)
EFCaDC*                  endif
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
     *
620aAC     kyprex2       setll     pxrec2
620aAC     kyprex2       reade     pxrec2
620aAC                   if        %eof
620aAC                   eval      hasPrepick = *off
620aAC                   else
620aAC                   eval      hasPrepick = *on
620aAC                   endif
     *
700aAC     kyampx2       setll     axrec2
700aAC     kyampx2       reade     axrec2
700aAC                   if        %eof
700aAC                   eval      hasAMPpick = *off
700aAC                   else
700aAC                   eval      hasAMPpick = *on
700aAC                   endif
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   eval      kywhse = $kwhse
     C                   eval      kygrp2 = $ktype
     C                   movel     $krtid        kyrtpo
     *
     *   Open closing program.
     *
     C                   eval      $pcmd = '*OPEN   '
     C                   eval      $puky = dsukey
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *
     *   Verify warehouse and get description.
     *
     C                   eval      wowhse = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $kwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      wowhse = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $fwhse = $kwhse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
     C                   endif
     C                   eval      worte = $krte
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   eval      lsttrn = 0
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
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   ptwhse
     C                   clear                   ptgrp1
     C                   clear                   ptgrp2
     C                   clear                   ptrtpo
     C                   clear                   pttrn#
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhse
     C                   clear                   ukrte
     C                   clear                   ukpo
     C                   clear                   uktrn#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = *blanks
     C                   eval      uktrn# = pttrn#
     C                   eval      $pouky = dsukey
     C                   endsr
417b *----------------------------------------------------------------
417b *
417b *  ZZMULT   Check if transaction is a multiple scan transaction.
417b *            Note: IF multiple, must end using TE130 task entry.
417b *
417b C     zzmult        begsr
417b C     uktrn#        chain     multran1                           75
417b C                   if        not *in75  and
417b C                             mustat = '1'
417b C                   eval      error = *on
417b C                   eval      cancel = *on
417b C                   eval      stop = *on
417b C                   movel     $perm         errmsg
417b C                   endif
417b C                   endsr

     *----------------------------------------------------------------
640cA*  ZZChkCW - Check for any C/W not entered.
     *
     C     zzchkCW       begsr

     C                   eval      clsall = *on
     C                   eval      tmpflg = *off
     C     uktrn#        chain(n)  pirtran
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        ptstat <> '4'
     C                   exsr      inzpar
     C                   exsr      zzcw
     C                   if        cwflg = *off  and
     C                             cwitm = *on
     *  No catch weights entered.
     C                   eval      cancel = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      error = *on
     C                   movel     emsg(3)       errmsg
     C                   move      wrkmsg        errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif

640cAC                   endsr

620aA*----------------------------------------------------------------
620aA*  ZZCHKPrepick  Check Pre-Pick transactions.
620aA*                Stop user from touching a Normal transaction if the
620aA*                corresponding Pre-Pick transactions aren't closed.
620aA*
620aAC     zzchkPrepick  begsr

620aA*  If transaction doesn't have associated prepick, leave.

     C                   if        not hasPrepick
     C                   leavesr
     C                   endif

620aA*  Loop through labels for normal transaction.

     C     kylab76       setll     label76
     C                   dow       forevr = forevr
     C     kylab76       reade     label76
     C                   if        %eof
     C                   leave
     C                   endif

620aA*    Get corresponding prexref record.

620bMC     kyprex1       setll     prexref1
     C                   dow       forevr = forevr
620bMC     kyprex1       reade     prexref1
     C                   if        %eof
     C                   leave
     C                   endif
620dA*
620dA*      If PRE transaction not closed,

620dAC                   if        $krtid <> pxnrte
620dAC                   iter
620dAC                   endif

620aA*      If PRE transaction not closed,
620aA*        Then normal transaction cannot be touched.

     C     pxtrn#        chain     pirtran
     C                   if        not %found
     C                             or %found and ptstat < '4'
     C                   eval      error = *on
     C                   eval      errmsg = %Trim(emsg(4))
     C                             + ' '
     C                             + pxhrte
     C                             + '/'
     C                             + %TrimL(%editc(pxtrn#:'P'))
     C                   exsr      zm0105
     C                   leave
     C                   endif

     C                   enddo

     C                   enddo

     C                   endsr
500b *----------------------------------------------------------------
500b *
500b *  ZZCHKT   Check if transaction is status 2=started.
500b *            Note: IF status 2, must end using TE130 task entry.
500b *
500b C     zzchkt        begsr
500b C     uktrn#        chain     pirtran                            75
500b C                   if        not *in75  and
500b C                             ptstat = '2'  or
510 A*
510 A*     -or- Transaction suspended, interupted.
510 AC                             not *in75  and
510 AC                             ptstat > '4'
500b C                   eval      error = *on
500b C                   eval      cancel = *on
500b C                   eval      stop = *on
500b C                   movel     $perm         errmsg
500b C                   endif
500b C                   endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  zzChkUSR  Check to see if any labels have USR slot.
640bA*
640bAC     zzChkUSR      begsr
     *
     C     keylb7u       setll     label7
     C                   dow       forevr = forevr
     C     keylb7u       reade     label7
     C                   if        %eof
     C                   leave
     C                   endif
     *
     *      If USR slot, turn on error and get out.
     C                   if        lbaisl = 'USR'
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      errmsg = %Trim(emsg(5))
     C                             + ' '
     C                             + %TrimL(%editc(uktrn#:'P'))
     C                             + '.'
     C                   exsr      zm0105
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  zzChkOrdAud  Check for open order audits for transaction
730aA*
730aAC     zzChkOrdAud   begsr

      /free

       coaWhse = ukwhse;
       coaTran = uktrn#;
       monitor;
         chkordaud ('*TRAN': coaWhse: coaRtid: coaTran: coaOrdId:
730bM               coaPltId: coaRtn: coaMsg);

         if coaRtn = '*OPEN';
           error = *on;
           cancel = *on;
           stop = *on;
           errmsg = 'Cannot close tran '
                  + %TrimL(%editc(uktrn#:'P'))
                  + ' - Open order audit exists';
           exsr zm0105;
         endif;
       on-error;
       endmon;

      /end-free

     C                   endsr
530bA*----------------------------------------------------------------
530bA*
530bA*  ZZCW     Check to see if c/w records exist.
530bA*
530bAC     zzcw          begsr
     C                   eval      cwflg = *off
     C                   eval      cwitm = *off
     C     keylb7        setll     label7
     C                   dow       forevr = forevr
     C     keylb7        reade     label7                                 78
     C                   if        *in78
610cMC                             or cwitm = *on
610cAC                             and cwflg = *off
     C                   leave
     C                   endif
610cAC                   eval      cwflg = *off
610cAC                   eval      cwitm = *off
720bdC                   eval      gPltId = lbpal#
720bdC                   exsr      GetGenInfo
CBIhAC                   select
CBIhAC                   when      client = cheney
720bDC**                 if        lbpal# >= 20000
720bMC                   if        not gGenTruck
CBIhAC                             or lbtype = 'A'
CBIiA*
CBIiAC                             or dsmeat = 'Y'
CBIiAC                             or dsppck = 'Y'
CBIhAC                   iter
CBIhAC                   endif
CBIhAC                   other
530cA*
530cA*      Omit Merge label records from catchwgt tests.
530cAC                   if        lbtype = 'M'
650aAC                             or lbtype = 'A'
530cAC                   iter
530cAC                   endif
CBIhAC                   endsl
610dA*      Omit LBQPCK = 0 records from catchwgt tests.
610dAC                   if        lbqpck = 0
610dAC                   iter
610dAC                   endif
700bA*      Omit AMP tran#s since catchwgt was recorded in AMP
700bAC                   if        hasAMPpick = '1'
720bDC**                           and lbpal# >= 20000
720bMC                             and not gGenTruck
700bAC                   iter
700bAC                   endif
700bA*
     C                   if        itcwgt = 'Y'
     C                   eval      cwitm = *on
610cAC                   else
610cAC                   iter
     C                   endif
     *  Set on c/w flag if c/w records exist.
     C     keyoc1        setll     ordc1
     C                   dow       forevr = forevr
620cDC**   keyoc1        reade     ordc1                                  79
620cMC     keyoc1        reade(n)  ordc1                                  79
     C                   if        *in79
     C                   leave
     C                   else
610cAC                   if        occwgt <> 0
     C                   eval      cwflg = *on
     C                   eval      cwitm = *on
     C                   leave
610cAC                   endif
     C                   endif
     C                   enddo
     *
610cAC                   if        cwitm = *on
610cAC                             and cwflg = *off
610cAC                   eval      eritem = lbitem
610cAC                   eval      ertrn# = %char(lbtrn#)
610cAC                   endif
     C                   enddo
     *
530bAC                   endsr
     *----------------------------------------------------------------
417d *
417d *  ZZFLAG   Check if there are open flags (shorts) for this
417d *           transaction.
417d *
417d C     zzflag        begsr
     C     l90key        setll     label90
     C                   dow       forevr = forevr
620cDC**   l90key        reade     label90                                79
620cMC     l90key        reade(n)  label90                                79
417eAC                   if        *in79
417eAC                   leave
417eAC                   endif
     C                   if        not *in79  and
     C                             lbvrfy = 'F'  or
417fAC                             not *in79  and
417fAC                             lbvrfy = 'I'
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   leave
     C                   endif
     C                   enddo
417d C                   endsr
500dA*----------------------------------------------------------------
500d *
500dA*  ZZWSOS   Check if there are SOS work records for this
500dA*           transaction (product not moved to new slot yet)
500d *
500dAC     zzwsos        begsr
500d C     wsokey        setll     worksos2
500d C                   dow       forevr = forevr
500d C     wsokey        reade     worksos2                               79
500d C                   if        *in79
500d C                   leave
500d C                   endif
500d C                   if        not *in79
500d C                   eval      error = *on
500d C                   eval      cancel = *on
500d C                   eval      stop = *on
500d C                   movel     $perm         errmsg
500d C                   leave
500d C                   endif
500d C                   enddo
500dAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     C                   select
640aA
640aA*  ET - Export transaction to staging files
640aA
640aAC                   when      wkoopt = 'ET'
640aAC                   eval      dsukey = wkokyu
640aAC                   call      'RH155ST'
640aAC                   parm      ukwhse        $swhse            3 0
640aAC                   parm      uktrn#        $strn#            7 0

     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to transaction number.
     *
     C                   if        ptinp1 <> 0
510cAC                   eval      ptwhse = $kwhse
510cAC                   movel     $krtid        ptrtpo
     C                   eval      pttrn# = ptinp1
HARaAC                   eval      svinp1 = ptinp1
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   eval      lsttrn = 0
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
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSTAT   Status check.
     *           Change RTEHED status to '5' when all transactions
     *           have been closed.
     *
     C     zzstat        begsr
710aA*
710aA*  See if any transactions should be auto closed.
710aA*
720aDC**                 call      'PT640AC'
720aDC**                 parm      $kwhse        $acwhse           3 0
720aDC**                 parm                    $krtid
720aDC**                 parm                    $ktype
     *
     *  Loop through all the transaction for route.
     *
     C                   eval      close = *on
     C     partky        setll     pirtran4
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If not a selection or letdown record then loop.
     *
     C                   if        ptgrp1 <> 'S'
408 D*R         PTGRP1    ANDNE'L'
     C                   iter
     C                   endif
     *
     *     If transaction is not closed, we're done.
     *
     C                   if        ptstat < '4'  or
510 AC                             ptstat > '4'
     C                   eval      close = *off
415aAC                   unlock    pirtran4
     C                   leave
     C                   endif
     *
415aA*    Check to make sure that all label records are closed.
415aA*    Note: If label records found that are not closed, if
415aA*          transaction is marked as closed, reset back to
415aA*          ended status so that records can be closed.
415aA*
416aD*R         KEYLB     SETLLLABEL8                   77
416aMC     keylb         setll     label8
416aAC                   read      label8                                 77
416aD*R         *IN77     IFEQ *ON
416aMC                   if        not *in77  and
416aMC                             l8trn# = pttrn#
415aAC                   eval      close = *off
415aAC                   if        ptstat = '4'
415aAC                   eval      ptstat = '3'
415aAC                   update    record
640dAc                   exsr      zzwrttrand
415aA*
415aAC                   else
415aAC                   unlock    pirtran4
415aAC                   endif
415aA*
415aAC                   leave
415aAC                   endif
415aA*
     C                   enddo
     *
     *  If all transaction were closed, update status.
     *
     C                   if        close = *on
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
412 AC                   if        rhstat < '5'
     C                   eval      rhstat = '5'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   update    rhrec
760 A*     Once all closed then rewrite final ELS Goals data for complete route
760 Ac                   monitor
760 Ac                   eval      stdwhse = rhwhse
760 Ac                   eval      stdtrn# = 0
760 Ac                   eval      stdGoal = 0
760 Ac                   call      'WRTELSSTD'
760 Ac                   parm                    stdWhse
760 Ac                   parm      '*UPDSTD'     $sStdSmd         10
760 Ac                   parm                    rhrtid
760 Ac                   parm      ' '           $pDept            5
760 Ac                   parm      ' '           $pStyp            1
760 Ac                   parm                    stdTrn#
760 Ac                   parm                    stdGoal
760 Ac                   parm      ' '           $pRtnScd         10
760 Ac                   parm      ' '           $pRtnSmsg        50
760 Ac                   on-error
760 Ac                   endmon
412 AC                   else
412 AC                   unlock    rtehed
412 AC                   endif
416bA*  Update picked qty, wt, and cube.
416bAC                   call      @pckrt
416bAC                   parm                    rhwhse
416bAC                   parm                    rhrtid
EFCaAC                   if        client = eastland
EFCbA*  Print SOS Slot Transfer Qty Report.
EFCbAC                   eval      $lcmd = '*PRINT  '
EFCbAC                   eval      $lrtn = *blanks
PAKb C                   move      rhwhse        $pwhse
PAKb C                   move      rhrtid        $prtid
EFCbAC                   call      'OR320CL'
EFCbAC                   parm                    $lcmd
EFCbAC                   parm                    $Pwhse
EFCbAC                   parm                    $prtid
EFCbAC                   parm      '*JOB      '  DEV
EFCbAC                   parm      '*STD      '  FORM
EFCbAC                   parm                    $lrtn
EFCbAC                   endif
     C                   endif
     C                   endif
415aA*
415aA*    Release record lock on PIRTRAN4.
415aAC                   unlock    pirtran4
     *
     *
CBIg *  Print one copy of Route summary report(Custom CBI)
     *
CBIg *          RHTRUK    IFNE @MEAT
CBIg *          RHTRUK    ANDNE@PPICK
CBIg *          RHTRUK    ANDNE@CNTNR
CBIg *          RHTRUK    ANDNE@WLCLL
CBIg *          RHTRUK    ANDNE@SDSVC
CBIg *          RHTRUK    ANDNE@DMGES
CBIg *          RHTRUK    ANDNE@BREKR
CBIg *                    MOVE $KWHSE    $WHSEA  3
CBIg *                    CALL 'OR670CL'
CBIg *                    PARM           $WHSEA
CBIg *                    PARM           RHRTID
CBIg *                    PARM           $PRTN
CBIg *                    ENDIF
     *
CBIa *  Print one copy of Driver's Detail report(Custom CBI)
     *
CBIc C                   movel     'OR663PR'     wkprtf
CBIc C     rpkey         chain     reports                            79
CBIc C                   if        not *in79
CBIc C                   eval      $dev = rpdev
CBIc C                   eval      $form = rpform
CBIc C                   else
CBIc C                   movel     '*JOB    '    $dev
CBIc C                   movel     '*STD    '    $form
CBIc C                   endif
CBIa C                   move      $kwhse        $whsea
CBIcD**                   MOVEL'LP10    '$DEV
CBIa C                   call      'OR663CL'
CBIa C                   parm                    $pcmd
CBIa C                   parm      '*DETAIL '    rtype             8
CBIa C                   parm                    $whsea
CBId C                   parm                    rhrtid
CBId C                   parm                    $prtn
CBId C                   parm                    $dev             10
CBId C                   parm                    $form            10
     *
     C                   endsr

620cA*----------------------------------------------------------------
620cA*  updNrmTran      Update normal transactoin from pre transaction
620cA*----------------------------------------------------------------
620cA
620cAC     updNrmTran    begsr

      /free

         // If transaction doesn't have associated prepick, leave.

         if not hasPrepick;
           leavesr;
         endif;

         // Read through normal transaction label records

         setll ($kwhse: uktrn#) label90;

         dow forever = forever;

           reade ($kwhse: uktrn#) label90;

           if %eof(label90);
             leave;
           endif;

           // Get corresponding prexref record for normal label

           setll ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           reade ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           if %eof(prexref4);
             iter;
           endif;

           if pxcpyf = 'Y';
             unlock prexref4;
             iter;
           endif;

           // Get corresponding pre-pick label

           chain (pxlbl#) label;

           if not %found(label);
             iter;
           endif;

           // Update normal label pick qty

           if lbqpck = L_lbqpck;
             unlock label90;
           else;
             lbqpck = L_lbqpck;
             update lbrec;
           endif;

           // Copy catch weights

           setll (L_lbwhse: L_lblbl#) ordc1;

           dow forever = forever;

             reade (L_lbwhse: L_lblbl#) ordc1;
             if %eof(ordc1);
               leave;
             endif;

             ocord  = lbord;
             ocseq# = lbseq;
             octran = lbtrn#;
             oclbl# = lblbl#;

             write(e) ocrec;
650bA        processstatus = '*ADD';
650bA        exsr processCWLog;

           enddo;

           // Copy Trax numbers


           // Update prexref copy flag

           pxcpyf = 'Y';
           update pxrec4;

         enddo;

      /end-free

     C                   endsr
700aA*----------------------------------------------------------------
700cA*  updDelvTran    Update Delv Rt transactoin from AMP transaction
700cA*----------------------------------------------------------------
700cA
700cAC     updDelvTran   begsr

      /free

         // If transaction doesn't have associated AMPpick, leave.

         if not hasAMPpick;
           leavesr;
         endif;

         // Read through normal transaction label records

         setll ($kwhse: uktrn#) label90;

         dow forever = forever;

           reade ($kwhse: uktrn#) label90;

           if %eof(label90);
             leave;
           endif;

           // Get corresponding AMPxref record for normal label

           setll ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 ampxref4;

           reade ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 ampxref4;

           if %eof(ampxref4);
             iter;
           endif;

           // Get corresponding AMP-pick label

           chain (axalbl#) label;

           if not %found(label);
             iter;
           endif;

           // Update normal label pick qty

           if lbqpck = L_lbqpck;
             unlock label90;
           else;
             lbqpck = L_lbqpck;
             update lbrec;
           endif;

           // Copy catch weights

           setll (L_lbwhse: L_lblbl#) ordc1;

           dow forever = forever;

             reade (L_lbwhse: L_lblbl#) ordc1;
             if %eof(ordc1);
               leave;
             endif;

             ocord  = lbord;
             ocseq# = lbseq;
             octran = lbtrn#;
             oclbl# = lblbl#;

             write(e) ocrec;
650bA        processstatus = '*ADD';
650bA        exsr processCWLog;

           enddo;

         enddo;

      /end-free

     C                   endsr
640dA*----------------------------------------------------------------*********
640dA*
640dA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640dA*
640dA /free
640dA   begsr zzwrttrand;
640eA     if wrtsaveptran# = pttrn# and wrtsaveptstat = ptstat;
640ea       leavesr;

640ea     endif;
640dA     wrtpcmd = '*ONETRAN';
640dA     wrtpwait = 0;
640dA     wrtpwhse = ptwhse;
640dA     wrtptran# = pttrn#;
640dA     wrtpfrmdate = 0;
640dA     wrtptodate = 0;
640dA     wrtpemp# = 0;
640eA     wrtsaveptran# = pttrn#;
640eA     wrtsaveptstat = ptstat;
640dA
640dA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640dA               wrtpfrmdate: wrtptodate: wrtpemp#);
640dA   endsr;
640dA /end-free

720bA*----------------------------------------------------------------
720bA*  GetGenInfo    Get pallet generation info
720bA*----------------------------------------------------------------
720bAC     GetGenInfo    begsr
      /free

        gGen = 1;
        gGenTruck = *off;
        gGenMerge = *off;
        gGenOverflow = *off;
        gGenTruckExt = *off;

        select;

          when gPltId < 20000;
            gGen = 1;
            gGenTruck = *on;

          when gPltId < 30000;
            gGen = 2;
            gGenMerge = *on;

          when gPltId < 40000;
            gGen = 3;
            gGenMerge = *on;

          when gPltId < 50000;
            gGen = 4;

          when gPltId < 60000;
            gGen = 5;
            gGenTruck = *on;
            gGenOverflow = *on;

          when gPltId < 70000;
            gGen = 6;
            gGenTruck = *on;
            gGenTruckExt = *on;

        endsl;
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 3 5 91016ET
**  OPTLN - Option display line
  2=Change and close  3=Catch Wt.  5=View  9=Quick close  10=TranInfo
  2=Change and close  3=Catch Wt.  5=View  9=Quick close  16=View UCI's
  2=Change and close  3=Catch Wt.  5=View
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F7=Verify Cwgt  F12=Cancel  F16=Close all
F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**
      * Not on File *
BULKF Bulk Pick - Full Pallet
BULKP Bulk Pick - Partial Pallet
BULKR Bulk Pick with Replenishment
FIXED Floor Pick
PIR   PIR Pick
PUTEMPReceiving
PUTMOVReceiving
PUTRTNCustomer Return
REPL  Replenishment
** EMSG ERROR MESSAGES
No UCI's exist for this transaction.
No Catch Weights Entered for Item
No C/W Entered for Trn#/Item
Pre-Pick tran not closed for rte/trn
Can't close/upd, USR slot exists for trn#
F16 Close All not allowed for SOS orders
