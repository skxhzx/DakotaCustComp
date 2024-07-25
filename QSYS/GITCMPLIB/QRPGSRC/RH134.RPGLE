520aA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH134     Undo allocation/picking.
     *  11 September 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    09/11/01  DAS  4.16
     *      - Created.
416aA*    02/11/02  MLB  4.16a
     *      - Added new file to program - RTECSUM.
     *
417 A*    08/08/03  MLB  4.17
     *      - Added new files to program - ORDC, ORDT.
417bA*    10/13/03  RH   4.17b
     *      - Clear RHSHPD & RHSHPT so new route doesn't show in use
417cA*    08/10/04  RH   4.17c
     *      - Fix: Revised to call GETSLOTITM instead of GETBASE.
     *        Re: The item being retrieved from GETBASE was being
     *            used to get the slot for the original item. However,
     *            if the original item was an Alias item for an SSB
     *            item, GETBASE would return the SSB item, which is
     *            not a slot item. Therefore no slot would be found
     *            for the original item.
     *
500aA*    02/28/05  RH   5.00a
     *      - Fix: Use LBQPCK to update slot qty for UOM 1 not LWQPCK
500bA*    01/25/06  MLB  5.00b
     *      - Fix: Revised routine ZM0105 to not set $prtn = *PGMQ.
     *        $prtn will be set by code calling routine ZM0105.
500cA*    04/03/06  RH   5.00c
     *      - Enh: Revised to remove bulk drop records for bulk pick.
     *
510 A*    08/01/07  MLB  5.10
     *      - Enh: Revised to remove any Runner Flag entries created
     *        in Runner module.
     *
520aA*    10/03/08  DAS  5.20a  P#00140
     *      - Revised to up qty before updating Whse/Slot qtys.
     *        Re: We were running in breakdown 1 ordered qtys
     *            that were greater than 999.
520bA*    01/28/09  MLB  5.20b
     *      - Enh: Revised to add support for RTESTP file so that
     *        route id can be updated in the file.
     *      - Added file RTESTP.
520cA*    02/18/08  RBD  5.20c  P#00011
     *      - Enh: Revised to update ORDHM with the new route id.
     *
520dA*    03/04/08  RBD  5.20d P#00011
     *      - Added call to OR639D to delete ORDAD recs for the
     *        route being unpicked.
520eA*    04/02/08  DAS  5.20e P#00011
     *      - Fix: Revised to call OR639D with a packed warehouse.
520fA*    10/06/08  RBD  5.20f P#00011
     *      - Added call to OR635D to delete TOTEHDR recs for the
     *        route being unpicked.
520gA*    10/06/08  RBD  5.20g
     *      - Fix: Added call to OR637D to delete ORDP recs for the
     *        route being unpicked.
520hA*    10/06/09  JCJ  5.20h
     *      - Added call to OR611D to delete ORDBSUM recs for the
     *        route being unpicked.
530aA*    08/03/10  MLB  5.30a
     *      - Fix: Revised routine UndoWorkLbl to correct code checked
     *        when reversing Breakdown 2 items. Chg'd LWUTYP to '2'
     *        from '1'
     *      - Fix: Revised routine UndoLabel to correct field checked
     *        when reversing Breakdown 1 items. Chg'd fld to LBUTYP
     *        from LWUTYP.
620aA*    11/30/10  DAS  6.20a
     *      - Revised to delete corresponding PREXREF records and
     *        corresponding PRE slots.
640 A*    02/08/11  JGD  6.40
     *      - Fix: Added call to LD637D to delete LDRHDR and LDRDETL
     *        records for the route being unpicked.
     *
640aA*    05/12/12  DAS  6.40a
     *      - Added *UNDOWEB command to be used for determining which
     *        type of message to use.
     *
640bA*    05/30/12  RBD  6.40b
     *      - Added call to TR858D to delete TTSTP recs for the
     *        route being unpicked.
640cA*    06/06/12  LMC  6.40c
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
640dA*    08/20/12  LMC  6.40d
     *      - Enh: Don't call WRTTRAN1 multiple times for same tran#
640eA*    10/11/12  LMC  6.40e
     *      - Fix: change command for wrttran1 from *undotran to *onetran
     *      - Fix: remove 640d mod.
650 A*    06/12/13  RBD  6.50
     *      - Recompiled, RTESTP file changed.
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
650bA*    12/27/13  DAS  6.50b
     *      - RHSHPD no longer used for locking route.
     *      - Program did not need to be changed because it is okay
     *        to clear RHSHPD when creating new RTEHED record.
650cA*    01/28/15  KDE  6.50c
     *      - Enh: Added code to reduce Customer Specific Work Order
     *        when orders associated to Work Orders are being backed
     *        out
700aA*    10/19/15  JCJ  7.00a
     *      - Enh: For cheney load doc doors when route is un allocated.
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
700bA*    11/05/15  NLK  7.00b
     *      - Revised to delete corresponding AMPXREF records and
     *        corresponding AMP slots.
710 A*    02/08/17  KDE  7.10
     *      - Revised to call Zero Verify for Production slots going to Z status
720 A*    04/05/18  KDE  7.20
     *      - Fix:  Issue in deleting PRD slots when we unallocate customer orders
720aA*    10/17/18  KDE  7.20a
     *      - Fix:  Reduce Component Work Orders when unallocating customer order
     *
730aA*    01/25/19  MR   7.30a
     *      - Add UPDLBLBTCH program to update EXPSPLBL when route is
     *        undone.
     *
730bA*    02/18/19  DAS  7.30b
     *      - Revised undororders to call exordh to remove order audit
     *      - Added monitor around updlblbtch call
     *
730cA*    03/04/19  KDE  7.30c
     *      - Revised to remove both PRD and PAR slots if zeroed
     *
730dA*    02/15/19  KDE  7.30d
     *      - Remove DRIPROD COMMAND *AUTOWP
     *      - Change to use new command UPDLOOP in DRIPROD
730eA*    11/25/19  KDE  7.30e
     *      - Change to Zero Verify Drop Pick Virtuals when zero
     *
730fA*    11/04/19  DAS  7.30e
     *      - Revised to use PIRTRANW
730gA*    12/05/19  DAS  7.30f
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
740a *    04/07/20  GJA  7.40a
     *      - Revised to call TR858C to update trax stop flags with
     *        new route ID.
740b *    08/07/20  KDE  7.40b
     *      - Revised to move DDTASK and DDDETAIL to History files
750  *    04/12/21  KDE  7.50
     *      - Revised to remove DDWRKFLDS records
750a *    05/04/21  KDE  7.50a
     *      - Revised to handle Super Route
750b *    11/17/21  KDE  7.50b
     *      - Do not change status for Drop Pick base slots
760c *    03/07/22  KDE  7.60c
     *      - Revised to remove ELS Goal Detail records on UNDO
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    06/06/13  MLB  GFSa
     *      - Enh: Convert unit quantity to extended wgt to update slot
     *        and warehouse files.
GFSbA*    06/06/13  MLB  GFSb
     *      - Enh: Add support for converting Eaches qty into extended
     *        weight.
GFScA*    06/17/13  MLB  GFSc
     *      - Enhancement to mod, GFS.  Revised program to check if
     *        item sold with Brkdwn1 = LB or Brkdwn2 = LB. If yes,
     *        convert Ordered Pounds into Ordered Cases and Eaches.
     *      - For items sold as Brkdwn1 = LB or Brkdwn2 = LB and if
     *        if ordered in increments that are not whole pounds,
     *        ie 5.50 lbs, Thyme will send the actual ordered weight
     *        in field OIDPO as a 7,2 numeric field padded with
     *        leading zeros.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *   This program attempts to reverse a route that has already been
     *   allocated or picked. This program makes no assumption to whether
     *   the route has been allocate, picked or a mixture of both.
     *   The program will go through the WorkLbl and Label files looking
     *   for records to reverse. After that, all order records will be
     *   reversed.
     *
     *   This program does not delete a route, it only sets it back to
     *   an open status. After that, the route can be deleted through the
     *   Open routes display, if needed. This was done in order to prevent
     *   routes from accidentally being deleted.
     *
     *   To prevent unpredictable results when the route is allocated and
     *   picked a second time, this program will assign a new route id to
     *   the route. The original route header record will be given a status
     *   of '8', a new route header record will be created and all order
     *   records will be updated with the new route id.
     *
     *   The picked quantity in the Label and WorkLbl files will be set
     *   to zero to reflect that the record was closed to zero. The
     *   original picked quantity will be saved in the RteUndo file. Also,
     *   the LBVRFY file will be set to 'U' to flag that the record was
     *   'Undone" by this program.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed    uf a e           k disk
750 AFsrrte     uf   e           k disk
750 AFsrord     uf   e           k disk
     Frtesum    uf a e           k disk
416aAFrtecsum   uf a e           k disk
520bAFrtestp    uf a e           k disk
     FLabel13   uf a e           k disk
     Fworklbl5  uf   e           k disk
     Fslot2     uf   e           k disk
     Fordh3     uf   e           k disk
650cAfordh      uf   e           k disk    rename(ohrec : ohreco)
650cAf                                     prefix(o_)
417 aFordc      uf   e           k disk
     Fordd      uf   e           k disk
417 aFordt      uf   e           k disk
730fDF*irtran   uf   e           k disk
730fMFpirtranw  uf   e           k disk
     Fbatctl    uf   e           k disk
500c Fbulkdrp   uf   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
510  Frunner6   uf   e           k disk    rename(rurec : rurec6)
520cAFordhm     uf   e           k disk
620aAFprexref3  uf   e           k disk
700bAFampxref3  uf   e           k disk
     Fitemadj   o    e             disk
     Frteundo   o    e             disk
650cAfplined    if   e           k disk
700aAFdocmtrx2  if a e           k disk
750 Afddwrkflds uf   e           k disk    usropn
760cAfelsstddtl uf   e           k disk    usropn
730gAFbfcdebug  o  a e           k disk    rename(bdrec : bdbrec)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a30             s              1    dim(30)
     D a50             s              1    dim(50)
     D msg             s             50    dim(5) ctdata perrcd(1)

650cA*----------------------------------------------------------------
650cA*  DRI parameters
650cA*----------------------------------------------------------------

650cA /COPY *libl/qcopysrc,C#DRIPARMS

650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#CWLOG
650aAD savever#        s                   like($cwver#)

700aA*----------------------------------------------------------------
700aA*  Dakota Client IDs
700aA*
700aA /copy qcopysrc,id#cheney
700aA /copy qcopysrc,id#cheneyo
700aA /copy qcopysrc,id#cheneyr
700aA*********copy qcopysrc,id#cheneyg
700aA /copy qcopysrc,id#cheneyp
GFS A /copy qcopysrc,id#gfs

700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*
700aAD                 ds
700aAD  client                 1     10
700aAD  cliloc                11     20
700aaD @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $prte                 22     26
     D  $prtid                27     31

GFScA*----------------------------------------------------------------
GFScA*  Re-definition field(s)
GFScA*
GFScAD                 ds
GFScAD  itminq                 4      8  2 inz(0)
GFScAD  itrcvd                 1      8  0 inz(0)
GFScA*
     *------------------------------------------------------------------
     * Constants ...
     *------------------------------------------------------------------
730bDD** forever       c                   const('1')

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

510 AD currstamp       s               z
GFSbAD brk1wgt         s                   like(lbuwgt)
     D flagop          s              1    inz(*off)
     D kywhse          s                   like(lbwhse)
     D kyitem          s                   like(lbitem)
     D kytrn#          s                   like(pttrn#)
415aAD lasttrn#        s              7  0
415aAD lasttime        s              6  0
     D newrtid         s                   like(rhrtid)
     D rundate         s              8  0
     D runtime         s              6  0
     D svqty2          s                   like(lbqpck)
     D svqpck          s                   like(lbqpck)
     D svstat          s                   like(lbstat)
     D tempa7          s              7
     D today           s              8  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
417c D @getsi          c                   const('GETSLOTITM')
650cA
650cA*----------------------------------------------------------------
650cA* Prototypes
650cA*----------------------------------------------------------------
710 A /COPY *libl/qcopysrc,C#SLOT
650cA /COPY *libl/qcopysrc,C#PROD
650cA

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  *CLOSE   -  Transaction close options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEXCD  -  Exception labels picked - code.
     *    OPNSCD  -  Not enough stock to close transaction - code.
     *    OPDICD  -  Different item found in slot - code.
     *
     * Data structure
     *
     D opdata          ds
     D  opexcd                 1      2
     D  opnscd                 3      4
     D  opdicd                 5      6
     D  clsend               117    117

640 A*----------------------------------------------------------------
640 A*  *RUNNER  -  PIR Runner Flag Options
640 A*----------------------------------------------------------------
640 A*
640 A* Fields
640 A*
640 A*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
640 A*    OPUPLR  -  Update Label with quantity shorted during manual
640 A*               flag entry (Y/N)
640 A*               NOTE: Any change to this field will cause OPUPLV
640 A*                     in the *VOICE options record to be updated.
640 A*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
640 A*               & create Priority Replenishment if necessary.
640 A*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
640 A*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
640 A*    OPRNRM  -  Send break message to user when new Runner
640 A*               task has been assigned. (Y/N)
640 A*    OPCLSF  -  Update Label quantity at flag close (Y/N).
640 A*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
640 A*    OPRPCK  -  Print Runner pick list. (Y/N)
640 A*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
640 A*               printer, 2=Belt printer
640 A*    OPRBDU  -  Allow shorts to be filled with breakdown units. (Y/N)
640 A*    OPRSCN  -  Scan tran# or label# to start pick.
640 A*                 1=tran#, 2=label#.
640 A*    OPRVFS  -  Verify pick slot, Y/N.
640 A*    OPRVFQ  -  Verify qty found, Y/N.
640 A*    OPRLOA  -  Using loader module, Y/N.
640 A*
640 A* Data structure
640 A*
640 AD oprdta          ds
640 AD  opcrtm                 1      1
640 AD  opuplr                 2      2
640 AD  oprplf                 3      3
640 AD  opmrgf                 4      4
640 AD  opclrf                 5      5
640 AD  oprnrm                 6      6
640 AD  opclsf                 7      7
640 AD  opoutf                 8      8
640 AD  oprpck                 9      9
640 AD  oprlbl                10     10
640 AD  oprbdu                11     11
640 AD  oprscn                12     12
640 AD  oprvfs                13     13
640 AD  oprvfq                14     14
640 AD  oprloa                15     15
640 AD  optendr              117    117

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

730gA /copy qcopysrc,c#pgminfds
730gDD*               sds
730gDD* #prog            *proc
730gDD* #job                 244    253
730gDD* #user                254    263
730gDD* #jobn                264    269
730gDD* #jobdt               276    281  0
730gDD* #jobtm               282    287  0

640cA*----------------------------------------------------------------
640cA*  Prototypes
640cA*----------------------------------------------------------------
640cA
640cAD wrttran1        pr                  extpgm('WRTTRAN1')
640cA * Input
640cAD   ppcmd                        8
640cAD   ppwait                       2  0
640cAD   ppwhse                       3  0
640cAD   pptran#                      7  0
640cAD   ppfromdate                   8  0
640cAD   pptodate                     8  0
640cAD   ppemp#                       5  0
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
650aA /copy qcopysrc,p.getuser
730bA /copy qcopysrc,p.exordh
730gA /copy qcopysrc,p.pirlbl#w
740bA /copy qcopysrc,p.dd2dtamo

730bA*----------------------------------------------------------------
730bA*  Standard variables
730bA*----------------------------------------------------------------
730bA
730bAD/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Work Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #litem          s             15
     D forevr          s              1
640cAD wrtpcmd         s             10
640cAD wrtpwait        s              2  0
640cAD wrtpwhse        s              3  0
640cAD wrtptran#       s                   like(pttrn#)
640cAD wrtpfrmdate     s              8  0
640cAD wrtptodate      s              8  0
640cAd wrtpemp#        s                   like(ptemp#)
640eDD*wrtsaveptran#   s                   like(pttrn#)
640eDD*wrtsaveptstat   s                   like(ptstat)
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650cAD chk4err         s               n
650cAD drierr          s               n
760cAd oldExists       s               n
650aAD processstatus   s             10
650cAd pSessId         s             40
650aAD e$whse          s              3  0
650aAD e$emp#          s              5  0
650aAD e$fnam          s             15
650aAD e$init          s              1
650aAD e$lnam          s             20
650aAD e$whdp          s              5
650aAD e$styp          s              1
650aAD e$shft          s              6
650aAD e$crew          s              6
650aAD e$nhrs          s              3  1
650aAD e$rtn           s              8
650aAD e$bpu           s              1
650aAD e$lng           s              2
650cAd prdslot         s                   like(slaisl)
730gAD pNextLbl#       s             11  0
730gAd nextLbl#        s                   like(lwlbl#)
740bAd inRtnCode       s             10
740bAd inRtnMsg        s             60
760cAd stdWhse         s              3p 0
760cAd stdTrn#         s              7p 0
760cAd stdGoal         s             13p 2

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     *
     *    Input Parameters
     *      $PCMD   *UNDO    -  Undo route to open status.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $MSGK   Message id sent to previous message queue.
     *      $PRTN   *OK      - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms

     C                   eval      $prtn = '*OK'

     *----------------------------------------------------------------
     *  Main line

     *  Grab RteHed record.

     C     keyrte        chain     rtehed                             7978

     *    Record not found.

     C                   if        *in79 = *on
     C                   movea     msg(1)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
640aAC                   if        $pcmd = '*UNDOWEB'
640aAC                   eval      $pmsg = errmsg
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm0105
500bAC                   eval      $prtn = '*PGMQ'
640aAC                   endif
     C                   goto      bottom
     C                   endif

     *    Record is locked.

     C                   if        *in78 = *on
     C                   movea     msg(2)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
640aAC                   if        $pcmd = '*UNDOWEB'
640aAC                   eval      $pmsg = errmsg
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm0105
500bAC                   eval      $prtn = '*PGMQ'
640aAC                   endif
     C                   goto      bottom
     C                   endif

     *    Route is not at Allocate, Built or Printed (Picked) status.

     C                   if        rhstat <> '2' and
     C                             rhstat <> '3' and
     C                             rhstat <> '4'
     C                   movea     msg(3)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
640aAC                   if        $pcmd = '*UNDOWEB'
640aAC                   eval      $pmsg = errmsg
640aAC                   eval      $prtn = '*ERROR  '
640aAC                   else
     C                   exsr      zm0105
500bAC                   eval      $prtn = '*PGMQ'
640aAC                   endif
     C                   unlock    rtehed
     C                   goto      bottom
     C                   endif

     *  Get new route id.

     C                   call      'PIRRTE#'
     C                   parm      $pwhse        $rwhse            3 0
     C                   parm                    newrtid

     *  Undo WorkLbl records.

     C                   exsr      undoworklbl

     *  Undo Label records.

     C                   exsr      undolabel

     *  Undo Order records.

     C                   exsr      undoorders

520dA*  Delete ORDAD sscc-18 records.

520dAC                   call      'OR639D'
520eMC                   parm      $pwhse        $rwhse
520dAC                   parm                    $prtid

520fA*  Delete TOTEHDR records.

520fAC                   call      'OR635D'
520fAC                   parm      $pwhse        $rwhse
520fAC                   parm                    $prtid

520gA*  Delete ORDP records.

520gAC                   call      'OR637D'
520gAC                   parm      $pwhse        $rwhse
520gAC                   parm                    $prtid

520hA*  Delete ORDBSUM records.

520hAC                   call      'OR611D'
520hAC                   parm      $pwhse        $rwhse
520hAC                   parm                    $prtid

640bA*  Delete TTSTP records.

640bAC                   call      'TR858D'
640bAC                   parm      $pwhse        $rwhse
640bAC                   parm                    $prtid

740aA*  Update TTSTPFLG records.

740aAC                   call      'TR858C'
740aAC                   parm      $pwhse        $rwhse
740aAC                   parm                    $prtid
740aAC                   parm                    newrtid

640 A*  Get  *Runner options record.

640 AC                   exsr      getrunrop

640 A*  Delete LDRHDR and LDRDETL records

640 AC                   if        oprloa = 'Y'
640 AC                   call      'LD637D'
640 AC                   parm      $pwhse        $rwhse
640 AC                   parm                    $prtid

640 AC                   endif

620aA*  Delete PREXREF records and corresponding PRE slots.
620a
620aAC                   call      'OR642'
620aAC                   parm      '*DELETE'     $rcmd             8
620aAC                   parm      $pwhse        $rwhse
620aAC                   parm                    $prtid

700bA*  Delete AMPXREF records and corresponding PRE slots.
700b
700bAC                   call      'OR643'
700bAC                   parm      '*DELETE'     $rcmd             8
700bAC                   parm      $pwhse        $rwhse
700bAC                   parm                    $prtid

     *  Update batch record.

     C     rhpbat        chain     btrec                              79
     C                   if        *in79 = *off
     C                   eval      btstat = '9'
     C                   eval      btendd = rundate
     C                   eval      btendt = runtime
     C                   update    btrec
     C                   endif

     *  If status 3, then move DDTASK and DDDETAIL to History files
     *  If beyond status 3 it has already been moved to History files

740bA /free
740bA                    if rhstat = '3';
740bA                      monitor;
740bA                      // Move DDDETAIL to History files
740bA                        dd2dtamove('*MTODDDH': inRtnCode: inRtnMsg:
740bA                                    $pWhse: $pRtid);
740bA                        // Move DDTASK to History files
740bA                        dd2dtamove('*MTODDTH': inRtnCode: inRtnMsg:
740bA                                    $pWhse: $pRtid);
740bA                      on-error;
740bA                      endmon;
740bA                    endif;
740bA /end-free
750 A
750 A*  Remove records for Extra Flags file for DD2
750 A
750 AC                   monitor
750 Ac                   if        not %open(ddwrkflds)
750 Ac                   open      ddwrkflds
750 Ac                   endif
750 A /free
750 A                    setll (rhwhse:rhrtid) ddwrkflds;
750 A                    dow forever=forever;
750 A                      reade (rhwhse:rhrtid) ddwrkflds;
750 A                      if not %equal(ddwrkflds) or %eof(ddwrkflds);
750 A                        leave;
750 A                      endif;
750 A                      delete ddrecw;
750 A                    enddo;
750 A                    if %open(ddwrkflds);
750 A                      close ddwrkflds;
750 A                    endif;
750 A /end-free
750 Ac                   on-error
750 Ac                   endmon

     *  Update original route record.

     C                   eval      rhstat = '8'
     C                   eval      rhstsd = rundate
     C                   eval      rhstst = runtime
     C                   update    rhrec

730aA*  Update EXPSPLBL record to 'S' status.

730bAC                   monitor
730aAC                   call      'UPDLBLBTCH'
730aAC                   parm      'RH134'       $rcmd             8
730aAC                   parm                    $rwhse            3 0
730aAC                   parm                    $prtid            5
730bAC                   on-error
730bAC                   endmon

     *  Get original RteSum record.

416 AC     keyrte        setll     rtesum
416 AC                   dow       forevr = forevr
416 D*    KeyRte        Chain     RteSum                             79
416 MC     keyrte        reade     rtesum                                 79

416 AC                   if        *in79 = *on
416 AC                   leave
416 AC                   endif

     *    Create out new RteSum record.

     C                   if        *in79 = *off
     C                   eval      rsrtid = newrtid
     C                   write     rsrec
     C                   endif
416 AC                   enddo
416aA
416aA*  Get original RteCSum records.
416aA
416aAC     keyrte        setll     rtecsum
416aAC                   dow       forevr = forevr
416aAC     keyrte        reade     rtecsum                                79
416aA
416aA*    Create new RteCSum record.
416aA
416aAC                   select
416aAC                   when      *in79
416aAC                   leave
416aA*
416aAC                   other
416aAC                   eval      rcrtid = newrtid
416aAC                   eval      rcpckc = 0
416aAC                   eval      rcpckw = 0
416aAC                   eval      rcpckp = 0
416aAC                   write     rcrec
416aAC                   endsl
416aAC                   enddo
520bA
520bA*  Get original RteSum record.
520bA
520bAC     keyrte        setll     rtestp
520bAC                   dow       forevr = forevr
520bAC     keyrte        reade     rtestp
520bA
520bAC                   if        %eof(rtestp)
520bAC                   leave
520bAC                   endif
520bA
520bA*    Create new RteStp record.
520bA
520bAC                   if        not %eof(rtestp)
520bAC                   eval      rtsrid = newrtid
520bAC                   write     rtsrec
520bAC                   endif
520bAC                   enddo

700aA*    Create new DocMtrx records.

700aAC                   if        client = cheney

700aAC     keyrte        setll     docmtrx2
700aAC                   dow       forevr = forevr
700aAC     keyrte        reade     docmtrx2                               79

700aAC                   if        *in79 = *on
700aAC                   leave
700aAC                   endif

700aA*    Create out new RteSum record.

700aAC                   if        *in79 = *off
700aAC                   eval      dmrtid = newrtid
700aAC                   eval      dmhdte = rundate
700aAC                   eval      dmhtim = runtime
700aAC                   eval      dmadte = rundate
700aAC                   eval      dmatim = runtime
700aAC                   write     dmrec
700aAC                   endif
700aAC                   enddo
700aAC                   endif

     *  Create new route record.

     C                   eval      rhrtid = newrtid
     C                   eval      rhstat = '1'
     C                   eval      rhstsd = rundate
     C                   eval      rhstst = runtime
     C                   eval      rhbldd = 0
     C                   eval      rhbldt = 0
     C                   eval      rhprtd = 0
     C                   eval      rhprtt = 0
     C                   eval      rhpbat = 0
417a C                   eval      rhshpd = 0
417a C                   eval      rhshpt = 0
     C                   write     rhrec


     C                   movea     msg(5)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
640aAC                   if        $pcmd = '*UNDOWEB'
640aAC                   eval      $pmsg = errmsg
640aAC                   else
     C                   exsr      zm0105
640aAC                   endif

750aA /free
750aA    // If undoing Super Route we should update SRRTE and SRORD
750aA    // with new Super Route Id and return "M" (Merge) routes
750aA    // back to status 1
750aA    if %subst(rhrte:1:3)='#SR';
750aA      // Return Merge(children for super routes) to status 1
750aA      setll (rhwhse:$prtid) srrte;
750aA      dow forevr = forevr;
750aA        reade (rhwhse:$prtid) srrte;
750aA         if %eof(srrte) or not %equal(srrte);
750aA          leave;
750aA        endif;
750aA        srsrtid=newrtid;
750aA        update srrec;
750aA        chain (srwhse:srmrtid) rtehed;
750aA        rhstat = '1';
750aA        update rhrec;
750aA      enddo;
750aA      // Return Merge(children for super routes) to status 1
750aA      setll (rhwhse:$prtid) srord;
750aA      dow forevr = forevr;
750aA        reade (rhwhse:$prtid) srord;
750aA         if %eof(srord) or not %equal(srord);
750aA          leave;
750aA        endif;
750aA        // reapply "M" ohtype when undoing super route
750aA        chain (srowhs:sromordid) ordh;
750aA        if %found(ordh);
750aA          o_ohtype='M';
750aA          update ohreco;
750aA        endif;
750aA        srosrtid=newrtid;
750aA        update srorec;
750aA      enddo;
750aA    endif;
750aA /end-free

760cA /free
760cA    // When un-doing route we should remove ELS Goal detail records
760cA    monitor;
760cA    if not %open(elsstddtl);
760cA      open elsstddtl;
760cA    endif;
760cA    oldExists = *off;
760cA    setll ($pWhse:$prtid) elsstddtl;
760cA    dow forevr = forevr;
760cA      reade ($pWhse:$prtid) elsstddtl;
760cA      if %eof(elsstddtl);
760cA        leave;
760cA      endif;
760cA      oldExists = *on;
760cA      delete edrec;
760cA    enddo;
760cA /end-free
760cA*    Generate/Update ELS Goal for new Route Id after removing previous
760cA*    route Id.
760cAc                   if        oldExists
760cAc                   eval      stdwhse = $pwhse
760cAc                   eval      stdtrn# = 0
760cAc                   eval      stdGoal = 0
760cAc                   call      'WRTELSSTD'
760cAc                   parm                    stdWhse
760cAc                   parm      '*UPDSTD'     $sStdSmd         10
760cAc                   parm                    newRtid
760cAc                   parm      ' '           $pDept            5
760cAc                   parm      ' '           $pStyp            1
760cAc                   parm                    stdTrn#
760cAc                   parm                    stdGoal
760cAc                   parm      ' '           $pRtnScd         10
760cAc                   parm      ' '           $pRtnSmsg        50
760cAc                   endif
760cAc                   on-error
760cAc                   endmon

     C     bottom        tag

760cAc                   monitor
760cAc                   if        %open(elsstddtl)
760cAc                   close     elsstddtl
760cAc                   endif
760cAc                   on-error
760cAc                   endmon

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

700aA* Get client id.

700aAC                   call      @getcl
700aAC                   parm                    client
700aAC                   parm                    cliloc

     *  Define key for Options file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     *  Define partial key for LABEL13/WORKLBL5 files.

     C     keyrte        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for SLOT2 file from LABEL fields.

     C     keysl2        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp

     *  Define key for SLOT2 file from WORKLBL fields.

     C     keysl2w       klist
     C                   kfld                    lwwhse
     C                   kfld                    lwwhdp
     C                   kfld                    lwdisp

     *  Define key for PIRITEM file.

     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem

     *  Define key for PirTran file.

     C     keypt         klist
730fAC                   kfld                    $pwhse
     C                   kfld                    kytrn#

     *  Define key for OrdD file.

     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord

510 A*  Define key for RUNNER6 file.

510 AC     keyru         klist
510 AC                   kfld                    lbwhse
510 AC                   kfld                    lblbl#

     *  Get current date.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
510 AC                   time                    currstamp

     *  Capture Run date/time

     C                   eval      rundate = today
     C                   time                    runtime
     C                   eval      lasttime = rutime
416aAC                   eval      forevr = *on
650cA*
650cA*  Define a unique Session for Production routines
650cA*
650cAc                   eval      pSessId = %trim('RH134' +
650cAc                             %char(%date():*iso0) +
650cAc                             %char(%time():*hms0))
650cA /free
650cA
650cA    setll ($pwhse) plined;
650cA    reade ($pwhse) plined;
650cA    if %found(plined);
650cA       prdslot = inpckaisl;
650cA    else;
650cA       prdslot = 'PRD';
650cA    endif;

650aA    getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA            e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA            e$bpu: e$lng);
650aA /end-free
     C                   endsr

520aA*----------------------------------------------------------------
520aA*  avail   Calculate available quantities for slot.
520aA*----------------------------------------------------------------
520aA
520aAC     avail         begsr

     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3

     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3

     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3

     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3

     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3

     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0

     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0

     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif

     C                   endsr

650cA*----------------------------------------------------------------
650cA*  chkForWo   Check for matching Work Order
650cA*----------------------------------------------------------------
650cA
650cAC     chkForWo      begsr
650cA /free
650cA
650cA           savever# = $ppver#;
650cA           $ppver# = savever#;
650cA
750aD           //chain (lwwhse:lword) ordh;
750aM           chain(n) (lwwhse:lword) ordh;
650cA
650cA   // returns matching Work Order number or *NF for not found in
650cA   // $ppWo#
650cA
650cA           $ppSessIdu = *on;
650cA           $ppSessid  = pSessId;
650cA           $ppwhseu = *on;
650cA           $ppwhse  = $pwhse;
650cA           $ppitemu = *on;
650cA           $ppitem  = lwitem;
650cA           $ppuser = #User;
650cA           $ppuseru = *on;
650cA           $ppdest = 'C';
650cA           $ppdestu = *on;
650cA           $ppcust = o_ohcust;
650cA           $ppcustu = *on;
650cA           $ppcustwo = ' ';
650cA           $ppcustwou = *on;
650cA           $ppcord = 0;
650cA           $ppcordu = *on;
650cA
650cA           $dricommand = '*PROD';
650cA           $drisubcmd = '%CHKFORWO';
650cA           $drisys2upd = 'D';
650cA           exsr zzzDriCop;
650cA
650cA /end-free
650cAC                   endsr

650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free
     *----------------------------------------------------------------
     *  GetCloseOpt  Get *CLOSE options.
     *----------------------------------------------------------------

     C     getcloseopt   begsr

     C                   if        flagop = *off
     C                   eval      flagop = *on

     C                   eval      opcode = '*CLOSE'
     C     keyop         chain     options                            78
     C                   if        *in78 = *on
     C                   eval      opexcd = 'X1'
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  GetItem  Get item record.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      #litem = kyitem
     C                   eval      #bitem = kyitem

     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      ittype = *blanks
GFSbAC                   eval      itum2  = ' '
     C                   eval      itumq2 = 0
GFSbAC                   eval      itum3  = ' '
     C                   eval      itumq3 = 0
GFSbAC                   eval      itswgt = 0
GFScAC                   eval      itrcvd = 0
GFScA*
GFScAC                   else
GFScA*
GFScAC                   if            client = Getfresh
GFScA*
GFScAC                   if           (itum2 = 'LB'
GFScAC                             or  itum3 = 'LB')
GFScAC                             and itrcvd = 0
GFScA*      Set Min. Order Qty to 1.00 lbs.
GFScAC                   eval      itrcvd = 100
GFScAC                   endif
GFScA*
GFScAC                   endif
GFScA*
     C                   endif
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itumq2 > 0
GFSbAC                   eval (h)  brk1wgt = itswgt / itumq2
GFSbAC                   endif
GFSbA*

     C                   eval      #bityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     *
     *     If Contract, Alias or SSB item
     *       Then get Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
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
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
417c *     get slot item.
417cAC                   call      @getsi
417cAC                   parm      itwhse        $gwhse
417cAC                   parm      ititem        $gitem
417cAC                   parm      ' '           #sitem           15
417cAC                   parm                    #sityp            1
417cAC                   parm                    #sdesc           30
417cAC                   parm                    #spdsc           15
417cAC                   parm                    #srtn            10
417cAC                   parm                    #smsg            60

     C                   endsr

730gA*----------------------------------------------------------------
730gA*  GetNextLbl#    Get next label number
730gA*----------------------------------------------------------------
730gA
730gAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lbwhse) + ', '
                    + 'Rtid: ' + %trimr(lbrte) + ', '
                    + 'Ord: ' + %char(lbord) + ', '
                    + 'Seq: ' + %char(lbseq) + ', '
                    + 'Itm: ' + %trimr(lbitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr

640 A*----------------------------------------------------------------
640 A*  getrunrop Get *Runner Option record.
640 A*----------------------------------------------------------------
640 A
640 AC     getrunrop     begsr
640 A
     C                   eval      opcode = '*RUNNER '

     C     keyop         chain     options
     C                   if        not %found(options)
     C                   eval      oprloa = 'N'
     C                   else
     C                   movel     opdata        oprdta
     C                   endif

     C                   endsr

     *
     *----------------------------------------------------------------
     *  LogIt   Log record that was changed.
     *----------------------------------------------------------------

     C     logit         begsr

     C                   eval      ruwhse = $pwhse
     C                   eval      rurtid = $prtid
     C                   eval      runewr = newrtid
     C                   time                    rutime
     C                   if        rutime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   endif
     C                   eval      rudate = today
     C                   eval      lasttime = rutime

     C                   select

     C                   when      rufile = 'L'
     C                   eval      runum = lblbl#
     C                   eval      ruqpck = lbqpck
     C                   eval      rustat = lbstat
     C                   eval      rusdte = lbsdte
     C                   eval      rustim = lbstim

     C                   when      rufile = 'T'
     C                   eval      runum = pttrn#
     C                   eval      ruqpck = 0
     C                   eval      rustat = ptstat
     C                   eval      rusdte = ptcdte
     C                   eval      rustim = ptctim

     C                   when      rufile = 'W'
     C                   eval      runum = lwlbl#
     C                   eval      ruqpck = lwqpck
     C                   eval      rustat = lwstat
     C                   eval      rusdte = lwsdte
     C                   eval      rustim = lwstim

     C                   endsl

     C                   write     rurec

     C                   endsr

500x *----------------------------------------------------------------
500c *  RmvBulk  Remove Bulk Drop records for Bulk pick labels.
500c *----------------------------------------------------------------

500c C     rmvbulk       begsr
500c C     lblbl#        chain     bdrec                              79
500c C                   if        *in79 = *off
500c C                   delete    bdrec
500c C                   endif

500c C                   endsr

510  *----------------------------------------------------------------
510  *  RmvRunner  Remove Runner Flag entries.
510  *----------------------------------------------------------------

510  C     rmvrunner     begsr
510  C     keyru         setll     runner6
510  C                   dow       forever = forever
510  C     keyru         reade     runner6
510  C                   select
510  C                   when      %eof(runner6)
510  C                   leave

510  C                   other
510  C                   eval      rustat = 'D'
510  C                   eval      rucdts = currstamp
510  C                   update    rurec6
510  C                   endsl

510  C                   enddo

510  C                   endsr
     *----------------------------------------------------------------
     *  UndoLabel  Un-Allocate/Pick LABEL records.
     *----------------------------------------------------------------

     C     undolabel     begsr

     *  Loop through WorkLbl records for route.

     C     keyrte        setll     label13
     C                   dow       forever = forever
     C     keyrte        reade     label13                                77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *     Only work with normal, bulk pick and merge records.

     C                   if        lbtype <> 'O' and
     C                             lbtype <> 'B' and
     C                             lbtype <> 'M'
     C                   iter
     C                   endif

     *     Only update slot for Merge labels and unclosed OUT labels.

     C                   if        lbtype = 'M' or lbasl2 = 'OUT'
     C                   goto      updlbl
     C                   endif

     *    Get Item Info.

     C                   eval      kywhse = lbwhse
     C                   eval      kyitem = lbitem
     C                   exsr      getitem

     *     Get slot record.

     C     keysl2        chain     slot2                              77
     C                   if        *in77 = *on
     C                   goto      updlbl
     C                   endif

     *  Update slot record.

     C                   select

     *    Record alredy 'Closed'

     C                   when      lbstat = 'C'

     *      Normal uom.

     C                   select
     C                   when      lbutyp = 'N'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lbuwgt > 0
GFS AC                   eval      slstk1 = slstk1 + (lbqpck * lbuwgt)
GFS AC                   else
     C                   eval      slstk1 = slstk1 + lbqpck
GFS AC                   endif
GFS A*
     C                   eval      $acmd = '*STOCK'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lbuwgt > 0
GFS AC                   eval      $aqty1 = lbqpck * lbuwgt
GFS AC                   else
     C                   eval      $aqty1 = lbqpck
GFS AC                   endif
GFS A*
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

530aMC                   when      lbutyp = '1'
530aDC**                 when      lwutyp = '1'
520aD**                 Eval      SLStk2 = SLStk2 + LBQPck
     C                   eval      $acmd = '*STOCK'
     C                   eval      $aqty1 = 0
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itum2 = 'LB'
GFSbAC                             and itumq2 > 0
GFSbAC                             and itminq > 0
GFSbAC                   eval      $aqty2 = lbqpck * itminq
GFSbAC                   else
     C                   eval      $aqty2 = lbqpck
GFSbAC                   endif
GFSbA*
     C                   eval      $aqty3 = 0
520aAC                   exsr      undoslotstk2
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval (h)  $aqty2 = lbqpck * lbuwgt
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval (h)  $aqty2 = lbqpck * itminq
GFSbcC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lbutyp = '2'
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itum3 = 'LB'
GFSbAC                             and itumq3 > 0
GFSbAC                             and itminq > 0
GFSbAC                   eval      slstk3 = slstk3 + (lbqpck * itminq)
GFSbAC                   else
GFSbA*
     C                   eval      slstk3 = slstk3 + lbqpck
GFSbAC                   endif
GFSbA*
     C                   eval      $acmd = '*STOCK'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lbqpck
GFSbA*
GFSbAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval (h)  $aqty3 = lbqpck * itminq
GFSbcC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     C                   endsl

     *    Record not 'Closed', only picked.

     C                   other

     *      Normal uom.

     C                   select
     C                   when      lbutyp = 'N'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lbuwgt > 0
GFS AC                   eval      slpck1 = slpck1 - (lbqpck * lbuwgt)
GFS AC                   else
GFS A*
     C                   eval      slpck1 = slpck1 - lbqpck
GFS AC                   endif
GFS A*
     C                   if        slpck1 < 0
     C                   eval      slpck1 = 0
     C                   endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOCN'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lbuwgt > 0
GFS AC                   eval      $aqty1 = lbqpck * lbuwgt
GFS AC                   else
     C                   eval      $aqty1 = lbqpck
GFS AC                   endif
GFS A*
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lbutyp = '1'
520aD**                 Eval      SLPck2 = SLPck2 - LBQPck
500aD*                  Eval      SLPck2 = SLPck2 - LWQPck
520aD**                 If        SLPck2 < 0
520aD**                 Eval      SLPck2 = 0
520aD**                 Endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lbqpck
     C                   eval      $aqty3 = 0
520aAC                   exsr      undoslotpck2
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval      $aqty2 = lbqpck * lbuwgt
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty2 = lbqpck * itminq
GFSbAC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

500aMC                   when      lbutyp = '2'
500aD*                  When      LWUTyp = '1'
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itum3 = 'LB'
GFSbAC                             and itminq > 0
GFSbAC                   eval      slpck3 = slpck3 - (lbqpck * itminq)
GFSbAC                   else
GFSbA*
500aMC                   eval      slpck3 = slpck3 - lbqpck
GFSbAC                   endif
GFSbA*
500aD*                  Eval      SLPck3 = SLPck3 - LWQPck
     C                   if        slpck3 < 0
     C                   eval      slpck3 = 0
     C                   endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lbqpck
GFScA*
GFScAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty3 = lbqpck * itminq
GFScAC                   endsl
GFScA*
     C                   exsr      updwhseqty

     C                   endsl

     C                   endsl

     C                   update    slrec

     *  Update records.

     C     updlbl        tag

     C                   eval      rufile = 'L'
     C                   exsr      logit

     C                   eval      svstat = lbstat
     C                   eval      svqpck = lbqpck
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = rundate
     C                   eval      lbstim = runtime
     C                   eval      lbqpck = 0
     C                   eval      lbvrfy = 'U'
     C                   update    lbrec

500c *  Remove Bulk Drop Records.
500c C                   if        lbtype = 'B'
500c C                   exsr      rmvbulk
500c C                   endif

510  *  Remove Runner Flag records.
510  C                   exsr      rmvrunner

     C                   eval      kytrn# = lbtrn#
     C                   exsr      updtranrec

     *  If label record was not for a closed OUT label.
     *    Then loop and get next label record.

     C                   if        lbasl2 <> 'OUT' or
     C                             svstat <> 'C' or
     C                             svqpck = 0
     C                   iter
     C                   endif

     *  Otherwise, create reverse adjustment.

     C                   eval      iawhse = $pwhse
     C                   if        ittype = 'A'
417cD**                 Eval      IAItem = #BItem
417cMC                   eval      iaitem = #sitem
     C                   else
     C                   eval      iaitem = lbitem
     C                   endif
     C                   eval      iadate = rundate
     C                   eval      iatime = runtime
     C                   eval      iaby   = #user
     C                   eval      iawhdp = lbwhdp
     C                   eval      iadisp = lbdisp
     C                   eval      iacwta = 0
     C                   eval      iaqty1 = 0
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   eval      iaudte = 0
     C                   eval      iautim = 0

     *    For SSB item, qty must be converted from Base qty type
     *      into SSB qty type (ie. Brkdwn1 into Normal).

     C                   if        ittype = 'S'

     C                   select
     C                   when      lbutyp = '1'
     C                   eval      iaqty1 = svqpck * -1
     C                   when      lbutyp = '2'
     C                   eval      iaqty2 = svqpck * -1
     C                   endsl

     C                   else

     C                   select
     C                   when      lbutyp = 'N'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lbuwgt > 0
GFS AC                   eval      iaqty1 = (svqpck * lbuwgt) * -1
GFS AC                   else
     C                   eval      iaqty1 = svqpck * -1
GFS AC                   endif
GFS A*
     C                   when      lbutyp = '1'
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval      iaqty1 = (svqpck * lbuwgt) * -1
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      iaqty1 = (svqpck * itminq) * -1
GFSbAC                   other
     C                   eval      iaqty2 = svqpck * -1
GFSbAC                   endsl
GFSbA*
     C                   when      lbutyp = '2'
GFScA*
GFScAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      iaqty3 = (svqpck * itminq) * -1
GFSbAC                   other
GFScA*
     C                   eval      iaqty3 = svqpck * -1
GFSbAC                   endsl
GFScA*
     C                   endsl

     C                   endif

     C                   movea     msg(4)        a30
     C                   movea     lbrte         a30(16)
     C                   move      lblbl#        tempa7
     C                   movea     tempa7        a30(24)
     C                   movea     a30           iamemo

     C                   exsr      getcloseopt
     C                   eval      iacode = opexcd
     C                   write     iarec

     *      Create label adjustment record.

     C                   eval      lbctr# = lblbl#
730dDC**                 call      'PIRLBL#'
730dDC**                 parm                    lblbl#
730dMC                   exsr      GetNextLbl#
730dMC                   eval      lblbl# = nextLbl#
     C                   eval      lbgrp1 = ' '
     C                   eval      lbgrp2 = ' '
     C                   eval      lbtype = 'A'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = rundate
     C                   eval      lbstim = runtime
     C                   eval      lbrdte = rundate
     C                   eval      lbqpck = svqpck * -1
     C                   write     lbrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoOrders   Undo order records.
     *----------------------------------------------------------------

     C     undoorders    begsr

     *  Loop through order header records for route.

     C     keyrte        setll     ordh3
     C                   dow       forever = forever
     C     keyrte        reade     ordh3                                  77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *    Loop through order detail records for order.

     C     keyod         setll     ordd
     C                   dow       forever = forever
     C     keyod         reade     ordd                                   76

     C                   if        *in76 = *on
     C                   leave
     C                   endif

     *      Update detail record.

     C                   eval      odstat = 'O'
     C                   eval      odqpk1 = 0
     C                   eval      odqpk2 = 0
     C                   eval      odqpk3 = 0

     C                   update    odrec

     C                   enddo
417 A
417 A*    Loop through order catchwgt records for order.
417 A
417 AC     keyod         setll     ordc
417 AC                   dow       forever = forever
417 AC     keyod         reade     ordc                                   76
417 A
417 AC                   if        *in76 = *on
417 AC                   leave
417 AC                   endif
417 A
417 A*      Delete all catchweight entries.
417 A
417 AC                   delete    ocrec
650aAc                   eval      processstatus = '*DELETE'
650aAc                   exsr      processCWLog
417 A
417 AC                   enddo
417 A
417 A*    Loop through order transaction records for order.
417 A
417 AC     keyod         setll     ordt
417 AC                   dow       forever = forever
417 AC     keyod         reade     ordt                                   76
417 A
417 AC                   if        *in76 = *on
417 AC                   leave
417 AC                   endif
417 A
417 A*      Delete all order transaction entries.
417 A
417 AC                   delete    otrec
417 A
417 AC                   enddo

520cA*    Update order header misc record with new route id.
520cAC     keyod         chain     ordhm
520cAC                   if        %found(ordhm)
520cAC                   eval      hmrtid  = newrtid
520cAC                   update    hmrec
520cAC                   endif


     *    Update header record.

     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = rundate
     C                   eval      ohstim = runtime
     C                   eval      ohpbat = 0
     C                   eval      ohrte  = newrtid
     C                   update    ohrec

730bA*    Delete order audit
730bA
730bA /free
730bA    ohaaudflg = '';
730bA    ohaaudid = 0;
730bA    ohaaudcmp = '';
730bA    ohaaudby = 0;
730bA    exWhse = ohwhse;
730bA    monitor;
730bA      exordh ('*CHANGE': exRtnCode: exRtnMsg: exWhse: ohord:
730aM              ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby);
730bA    on-error;
730bA    endmon;
730bA /end-free

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoWorkLbl  Un-Allocate/Pick WORKLBL records.
     *----------------------------------------------------------------

     C     undoworklbl   begsr

     *  Loop through WorkLbl records for route.

     C     keyrte        setll     worklbl5
     C                   dow       forever = forever
     C     keyrte        reade     worklbl5                               77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *     Ignore labels that have already been processed.

     C                   if        lwstat = 'X'
     C                   iter
     C                   endif

     *     Only work with normal, bulk pick and merge records.

     C                   if        lwtype <> 'O' and
     C                             lwtype <> 'B' and
     C                             lwtype <> 'M'
     C                   iter
     C                   endif

     *     Only update slot for Merge and Out labels.

     C                   if        lwtype = 'M' or
     C                             lwasl2 = 'OUT'
     C                   goto      updlblw
     C                   endif

     *    Get Item Info.

     C                   eval      kywhse = lwwhse
     C                   eval      kyitem = lwitem
     C                   exsr      getitem

     *     Get slot record.

     C     keysl2w       chain     slot2                              77
     C                   if        *in77 = *on
     C                   goto      updlblw
     C                   endif

     *  Update slot record.

     C                   select

     *    Record alredy 'Picked'

     C                   when      lwstat = 'P'

     *      Normal uom.

     C                   select
     C                   when      lwutyp = 'N'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lwuwgt > 0
GFS AC                   eval      slpck1 = slpck1 - (lwqpck * lwuwgt)
GFS AC                   else
     C                   eval      slpck1 = slpck1 - lwqpck
GFS AC                   endif
GFS A*
     C                   if        slpck1 < 0
     C                   eval      slpck1 = 0
     C                   endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOCN'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lwuwgt > 0
GFS AC                   eval      $aqty1 = lwqpck * lwuwgt
GFS AC                   else
     C                   eval      $aqty1 = lwqpck
GFS AC                   endif
GFS A*
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lwutyp = '1'
520aD**                 Eval      SLPck2 = SLPck2 - LWQPck
520aD**                 If        SLPck2 < 0
520aD**                 Eval      SLPck2 = 0
520aD**                 Endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lwqpck
     C                   eval      $aqty3 = 0
520aAC                   exsr      undoslotpck2
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lwuwgt > 0
GFSbAC                   eval      $aqty2 = lwqpck * lwuwgt
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty2 = lwqpck * itminq
GFSbAC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lwutyp = '2'
GFSbA*
GFSbAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      slpck3 = slpck3 - (lwqpck * itminq)
GFSbAC                   other
GFSbA*
     C                   eval      slpck3 = slpck3 - lwqpck
GFSbAC                   endsl
GFSbA*
     C                   if        slpck3 < 0
     C                   eval      slpck3 = 0
     C                   endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lwqpck
GFSbA*
GFSbAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty3 = lwqpck * itminq
GFSbAC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     C                   endsl

     *    Record not 'Picked', only allocated.

     C                   other

     *      Normal uom.

     C                   select
     C                   when      lwutyp = 'N'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lwuwgt > 0
GFS AC                   eval      slalc1 = slalc1 - (lwqalc * lwuwgt)
GFS AC                   else
     C                   eval      slalc1 = slalc1 - lwqalc
GFS AC                   endif
GFS A*
     C                   if        slalc1 < 0
     C                   eval      slalc1 = 0
     C                   endif
     C                   eval      $acmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOCN'
GFS A*
GFS AC                   if        client = Getfresh
GFS AC                             and itcwgt = 'Y'
GFS AC                             and lwuwgt > 0
GFS AC                   eval      $aqty1 = lwqalc * lwuwgt
GFS AC                   else
     C                   eval      $aqty1 = lwqalc
GFS AC                   endif
GFS A*
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lwutyp = '1'
520aD**                 Eval      SLAlc2 = SLAlc2 - LWQAlc
520aD**                 If        SLAlc2 < 0
520aD**                 Eval      SLAlc2 = 0
520aD**                 Endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lwqalc
     C                   eval      $aqty3 = 0
520aAC                   exsr      undoslotalc2
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lwuwgt > 0
GFSbAC                   eval      $aqty2 = lwqalc * lwuwgt
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty2 = lwqalc * itminq
GFSbAC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

530aMC                   when      lwutyp = '2'
530aDC**                 when      lwutyp = '1'
GFSbA*
GFSbAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      slalc3 = slalc3 - (lwqalc * itminq)
GFSbAC                   other
GFSbA*
     C                   eval      slalc3 = slalc3 - lwqalc
GFSbAC                   endsl
GFSbA*
     C                   if        slalc3 < 0
     C                   eval      slalc3 = 0
     C                   endif
520aD**                 Eval      $ACmd = '*UNALLOC'
520aMC                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lwqalc
GFSbA*
GFSbAC                   select
GFScAC                   when      client = Getfresh
GFScAC                             and itum3 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      $aqty3 = lwqalc * itminq
GFSbAC                   endsl
GFSbA*
     C                   exsr      updwhseqty

     C                   endsl

     C                   endsl

     C                   update    slrec

650cA*   If Production Work Order exists then reduce quantity
650cA*   per the order quantity being reversed
650cA
650cA /free
650cA                    if lwaisl = prdslot
730cA                       or lwaisl = inStkaisl;
650cA                    clear $pprod;
650cA                    clear $pprod2;
650cA /end-free
650cAc                   exsr      chkForWo
650cAc                   if        $ppWo# <> '*NF'
650cAc                   exsr      updProdWo
650cAc                   endif
650cA
650cA *  If production line slot then mark Zero
650cA *  Verify if quantity goes to zero
720 Dc*                  if        slaisl = prdslot and slstk1=0
720 Dc*                            and slstk2=0 and slstk3=0
730cDc*                  if        slaisl = prdslot and slalc1=0
730cAc                   if        (slaisl = prdslot or slaisl=inStkAisl)
720 Ac                             and slalc2=0 and slalc3=0
730cMc                             and slstk1=0 and slalc1=0
720 Ac                             and slstk2=0 and slstk3=0
730eAc                   exsr      zeroVfy
650cAc                   endif
650cAc                   endif
650cA
730eA*
730eA*    Zero Verify empty Drop Pick Virtuals
730eA*
730eAc                   if        (sldesg='*DROP' and slstat='DP'
750bAc                              and slrsrv='V')
730eAc                             and slalc2=0 and slalc3=0
730eAc                             and slstk1=0 and slalc1=0
730eAc                             and slstk2=0 and slstk3=0
730eAc                   exsr      zeroVfy
730eAc                   endif

     *  Update records.

     C     updlblw       tag

     C                   eval      rufile = 'W'
     C                   exsr      logit

     C                   eval      lwstat = 'X'
     C                   eval      lwsdte = rundate
     C                   eval      lwstim = runtime
     C                   eval      lwqpck = 0
     C                   eval      lwvrfy = 'U'
     C                   update    lwrec

     C                   eval      kytrn# = lwtrn#
     C                   exsr      updtranrec

     C                   enddo

     C                   endsr

730eA*----------------------------------------------------------------
730eA*  zeroVfy  -  Zero Verify Production and Drop Pick slots when zero
520aA*----------------------------------------------------------------
730eAC     zeroVfy       Begsr
730eAC     keysl2w       chain     slot2                              77
730eAc                   if        %found(slot2)
730eAc                   eval      slstat = 'Z '
730eAC                   update    slrec
730eA /free
730eA           // call Zerovfy for Production Slots once unallocated
730eA           // to ensure cleanup of PCSLOT file.
730eA           // Also cleanup any PAR slots
730eA                    savever# = $slver#;
730eA                    clear $slot;
730eA                    clear $slot2;
730eA                    $slver# = savever#;
730eA                    $slwhseu = *on;
730eA                    $slwhse = slwhse;
730eA                    $slwhdpu = *on;
730eA                    $slwhdp = slwhdp;
730eA                    $sldispu = *on;
730eA                    $sldisp = sldisp;
730eA                    $slaislu = *on;
730eA                    $slaisl = slaisl;
730eA                    $slstatu = *on;
730eA                    $slstat = slstat;
730eA                    $sllocu = *on;
730eA                    $slloc = slloc;
730eA                    $slrlvlu = *on;
730eA                    $slrlvl = slrlvl;
730eA                    $slhandu = *on;
730eA                    $slhand = slhand;
730eA                    $slsideu = *on;
730eA                    $slside = slside;
730eA                    $dricommand = '*SLOT';
730eA                    $drisubcmd  = '%ZEROVFY';
730eA                    $drisys2upd = 'D';
730eA                    exsr zzzDriCop;
730eA /end-free
730eAc                   endif
730eAC                   endsr

520aA*----------------------------------------------------------------
520aA*  UndoSlotAlc2  Un-Allocate qty from slot
520aA*----------------------------------------------------------------
520aA
520aAC     undoslotalc2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, try to undo full cases.

     C                   dow       svqty2 >= itumq2
     C                             and slalc1 > 0
     C                             and itumq2 > 0

GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slalc1 -= itswgt
GFSbAC                   eval      svqty2 -= itumq2
GFSbAC                   else
GFSbA*
     C                   eval      slalc1 -= 1
     C                   eval      svqty2 -= itumq2
GFSbAC                   endif
GFSbA*

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     *     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slalc2
GFSbAC                             and itcwgt = 'N'
GFSbA*
GFSbAC                             or  svqty2 * brk1wgt <= slalc2
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and client = Getfresh
GFSbA*
GFSbAC                             or  svqty2 * itminq <= slalc2
GFSbAC                             and itum2 = 'LB'
GFSbAC                             and client = Getfresh
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slalc2 -= (svqty2 * brk1wgt)
GFSbAC                   eval      svqty2 = 0
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      slalc2 -= (svqty2 * itminq)
GFScAC                   eval      svqty2 = 0
GFSbAC                   other
GFSbA*
     C                   eval      slalc2 -= svqty2
     C                   eval      svqty2 = 0
GFSbAC                   endsl
GFSbA*
     C                   leave
     C                   endif

     *     Not enough avaialble, break down a case and loop.

     C                   if        slalc1 > 0
     C                              and itumq2 > 0
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slalc1 -= itswgt
GFSbAC                   eval      slalc2 += itswgt
GFSbAC                   else
GFSbA*
     C                   eval      slalc1 -= 1
     C                   eval      slalc2 += itumq2
GFSbAC                   endif
GFSbA*
     C                   iter
     C                   endif

     *     Case not available, zero out allocated qty.

     C                   eval      slalc2 = 0

     C                   leave
     C                   enddo

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
GFSbAC                              and itcwgt = 'N'
GFSbA*
GFSbAC                              or  avail2 >= itswgt
GFSbAC                              and slstk2 >= itswgt
GFSbAC                              and itumq2 > 0
GFSbAC                              and itcwgt = 'Y'
GFSbAC                              and client = Getfresh
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slstk1 += itswgt
GFSbAC                   eval      slstk2 -= itswgt
GFSbAC                   eval      avail2 -= itswgt
GFSbAC                   else
GFSbA*
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
GFSbAC                   endif
GFSbA*
     C                   enddo

     C                   endsr

520aA*----------------------------------------------------------------
520aA*  UndoSlotPck2  Un-Pick qty from slot
520aA*----------------------------------------------------------------
520aA
520aAC     undoslotpck2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, try to undo full cases.

     C                   dow       svqty2 >= itumq2
     C                             and slpck1 > 0
     C                             and itumq2 > 0

GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slpck1 -= itswgt
GFSbAC                   eval      svqty2 -= itumq2
GFSbAC                   else
GFSbA*
     C                   eval      slpck1 -= 1
     C                   eval      svqty2 -= itumq2
GFSbAC                   endif
GFSbA*

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     *     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slpck2
GFSbAC                             and itcwgt = 'N'
GFSbA*
GFSbAC                             or  svqty2 * brk1wgt <= slpck2
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and client = Getfresh
GFSbA*
GFSbAC                             or  svqty2 * itminq <= slpck2
GFSbAC                             and itum2 = 'LB'
GFSbAC                             and client = Getfresh
GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slpck2 -= (svqty2 * brk1wgt)
GFSbAC                   eval      svqty2 = 0
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      slpck2 -= (svqty2 * itminq)
GFScAC                   eval      svqty2 = 0
GFSbAC                   other
GFSbA*
     C                   eval      slpck2 -= svqty2
     C                   eval      svqty2 = 0
GFSbAC                   endsl
GFSbA*
     C                   leave
     C                   endif

     *     Not enough avaialble, break down a case and loop.

     C                   if        slpck1 > 0
     C                              and itumq2 > 0
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slpck1 -= itswgt
GFSbAC                   eval      slpck2 += itswgt
GFSbAC                   else
GFSbA*
     C                   eval      slpck1 -= 1
     C                   eval      slpck2 += itumq2
GFSbAC                   endif
GFSbA*
     C                   iter
     C                   endif

     *     Case not available, zero out allocated qty.

     C                   eval      slpck2 = 0

     C                   leave
     C                   enddo

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
GFSbAC                              and itcwgt = 'N'
GFSbA*
GFSbAC                              or  avail2 >= itswgt
GFSbAC                              and slstk2 >= itswgt
GFSbAC                              and itumq2 > 0
GFSbAC                              and itcwgt = 'Y'
GFSbAC                              and client = Getfresh
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and itswgt > 0
GFSbAC                   eval      slstk1 += itswgt
GFSbAC                   eval      slstk2 -= itswgt
GFSbAC                   eval      avail2 -= itswgt
GFSbAC                   else
GFSbA*
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
GFSbAC                   endif
GFSbA*
     C                   enddo

     C                   endsr

520aA*----------------------------------------------------------------
520aA*  UndoSlotStk2  Un-Stock qty from slot
520aA*----------------------------------------------------------------
520aA
520aAC     undoslotstk2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, undo full cases.
     *    Actually, we are adding the qty back into stock.

     C                   dow       svqty2 >= itumq2
     C                             and itumq2 > 0
GFSbAC                             and itcwgt = 'N'
GFSbA*
GFSbAC                             or  svqty2 * lbuwgt >= itswgt
GFSbAC                             and itumq2 > 0
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and client = Getfresh

GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval (h)  slstk1 += itswgt
GFSbAC                   eval      svqty2 -= itumq2
GFSbAC                   else
GFSbA*

     C                   eval      slstk1 += 1
     C                   eval      svqty2 -= itumq2
GFSbAC                   endif

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty
     *    Again, we are adding the qty back into stock.

GFSbA*
GFSbAC                   select
GFSbAC                   when      client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval      slstk2 += svqty2 * lbuwgt
GFScA*
GFScAC                   when      client = Getfresh
GFScAC                             and itum2 = 'LB'
GFScAC                             and itminq > 0
GFScAC                   eval      slstk2 += svqty2 * itminq
GFSbAC                   other
GFSbA*
     C                   eval      slstk2 += svqty2
GFSbAC                   endsl

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
GFSbAC                              and itcwgt = 'N'
GFSbA*
GFSbAC                             or  avail2 >= itswgt
GFSbAC                             and slstk2 >= itswgt
GFSbAC                             and itumq2 > 0
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and client = Getfresh
GFSbA*
GFSbAC                   if        client = Getfresh
GFSbAC                             and itcwgt = 'Y'
GFSbAC                             and lbuwgt > 0
GFSbAC                   eval      slstk1 += itswgt
GFSbAC                   eval      slstk2 -= itswgt
GFSbAC                   eval      avail2 -= itswgt
GFSbAC                   else
GFSbA*
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
GFSbAC                   endif
GFSbA*
     C                   enddo

     C                   endsr
650cA
650cA*----------------------------------------------------------------
650cA*  updProdWO  Update Production Work Order calling DRIPROD
650cA*----------------------------------------------------------------
650cA
650cAC     updProdWO     begsr
650cA /free
650cA
650cA           savever# = $ppver#;
650cA           $ppver# = savever#;
650cA
750aD           //chain (lwwhse:lword) ordh;
750aM           chain(n) (lwwhse:lword) ordh;
650cA
650cA           $ppSessIdu = *on;
650cA           $ppSessid  = pSessId;
650cA           $ppwhseu = *on;
650cA           $ppwhse  = $pwhse;
650cA           $ppwo#u = *on;
650cA      //   $ppwo#  = wkwo#;   $ppwo# will exist from chkforwo
650cA           $ppitemu = *on;
650cA           $ppitem  = lwitem;
650cA           $ppuser = #User;
650cA           $ppuseru = *on;
650cA           $ppdest = 'C';
650cA           $ppdestu = *on;
650cA           $ppcust = o_ohcust;
650cA           $ppcustu = *on;
650cA           $ppcustwo = ' ';
650cA           $ppcustwou = *on;
650cA           $ppcord = o_ohcord;
650cA           $ppcordu = *on;
650cA           // reverse customer order Work Order
650cA           // if production has already been produced do not
650cA           // reduce below the produced value.
650cA           $ppmake = $ppmake - $aqty1;
650cA           if $ppmake < $ppqtyp;
650cA              $ppmake = $ppqtyp;
650cA           endif;
650cA           $ppmakeu = *on;
650cA        // $pplneno = ipmfgno; $pplneno will exist from chkforwo
650cA           $pplnenou = *on;
650cA           $ppstat = 'P';       // Status is Planning
650cA           $ppstatu = *on;
650cA           $ppprio = 3;
650cA           $pppriou = *on;
730dA           $ppwipa=' ';
730dA           $ppwipau=*on;
730dA           $ppovrdu=*on;
730dA           $ppovrd=0;
730dA           $ppcbd1u=*on;
730dA           $ppcbd1=0;
730dA           $ppcbd2u=*on;
730dA           $ppcbd2=0;
730dA           $ppNeedu=*on;
730dA           $ppNeed=0;
650cA
650cA           $dricommand = '*PROD';
730bD           //$drisubcmd = '%UPDPRODWO';
730bA           $drisubcmd = '%UPDLOOP';
650cA           $drisys2upd = 'D';
650cA           exsr zzzDriCop;
650cA
730dD           //if $ppmake = 0;
730dD           //   $dricommand = '*PROD';
730dD           //   $drisubcmd = '%DELWO';
730dD           //   $drisys2upd = 'D';
730dD           //   exsr zzzDriCop;
730dD           //endif;
650cA
650cA /end-free
650cAC                   endsr

     *----------------------------------------------------------------
     *  UpdTranRec  Update transaction record.
     *----------------------------------------------------------------

     C     updtranrec    begsr

     C                   if        kytrn# = 0 or kytrn# = lasttrn#
     C                   goto      endupdtrn
     C                   endif

730fMC     keypt         chain     pirtranw                           77

     C                   if        *in77 = *off

     C                   eval      rufile = 'T'
     C                   exsr      logit

     C                   if        ptstat <> '4'
     C                   eval      ptstat = '4'
     C                   eval      ptcdte = rundate
     C                   eval      ptctim = runtime
     C                   endif
     C                   update    ptrec
640cAc                   exsr      zzwrttrand

     C                   endif

     C                   eval      lasttrn# = kytrn#

     C     endupdtrn     endsr

     *----------------------------------------------------------------
     *  UpdWhseQty  Update warehouse quantity.
     *----------------------------------------------------------------

     C     updwhseqty    begsr

     *    When item is an Alias or SSB ...
     *      Update Base item instead of label item.

     C                   if        ittype = 'A' or ittype = 'S'
417cD**                 Eval      $AItem = #BItem
417cMC                   eval      $aitem = #sitem
     C                   else
     C                   eval      $aitem = #litem
     C                   endif

     *    Call program to update warehouse quantity.

     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm      #prog         $aprg            10
     C                   parm      '*BATCH  '    $atype            8
     C                   parm      kywhse        $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm            60

     *    If item is a Contract item and restocking slot
     *      Then we must restock and allocate base item.

     C                   if        ittype = 'C' and $acmd = '*STOCK'

     C                   call      'ADJQTY'
     C                   parm      '*STOCK  '    $acmd
     C                   parm      #prog         $aprg
     C                   parm      '*BATCH  '    $atype
     C                   parm      kywhse        $awhse
417cD**                 PARM      #BItem        $AITEM           15
417cMC                   parm      #sitem        $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm

     C                   call      'ADJQTY'
     C                   parm      '*ALLOC  '    $acmd
     C                   parm      #prog         $aprg
     C                   parm      '*BATCH  '    $atype
     C                   parm      kywhse        $awhse
417cD**                 PARM      #BItem        $AITEM           15
417cMC                   parm      #sitem        $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm

     C                   endif

     C                   endsr

730gA*----------------------------------------------------------------
730gA*  wrtDebug    Write out debug record
730gA*----------------------------------------------------------------
730gA
730gA /free
730gA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdbrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSGP'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *      0105
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
500bD*                  MOVEL(P)  '*PGMQ'       $PRTN
     C                   endsr

640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640cA*
640cA /free
640cA   begsr zzwrttrand;
640eD     //if wrtsaveptran# = pttrn# and wrtsaveptstat = ptstat;
640eD       //leavesr;
640eD     //endif;
640eD     //tpcmd = '*UNDOTRAN';
640eM     wrtpcmd = '*ONETRAN';
640cA     wrtpwait = 0;
640cA     wrtpwhse = ptwhse;
640cA     wrtptran# = pttrn#;
640cA     wrtpfrmdate = 0;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640eD     //wrtsaveptran# = pttrn#;
640eD     //wrtsaveptstat = ptstat;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
650cA
650cA*----------------------------------------------------------------
650cA*  zzzdricop  Call DRICOP
650cA*----------------------------------------------------------------
650cA
650cAC     zzzdricop     begsr
650cAC                   eval      drierr = *off
650cA
650cAC                   select
650cAC                   when      $dricommand = '*PROD'
650cAC                   eval      $dridata = $pprod
650cAC                   eval      $dridata2 = $pprod2
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2
650cAC                   endsl
650cA
650cAC                   call(e)   'DRICOP'
650cAC                   parm                    $dricommand
650cAC                   parm                    $drisubcmd
650cAC                   parm                    $drisys2upd
650cAC                   parm      #prog         $driprogram
650cAC                   parm      ' '           $drireturn
650cAC                   parm      ' '           $drimessage
650cAC                   parm                    $dridata
650cAC                   parm                    $dridata2
650cA
650cAC                   select
650cA
650cAC                   when      chk4err and %error
650cAC                   eval      drierr = *on
650cAC                   eval      errmsg    = 'Error occured on call to '
650cAC                                       + 'DRICOP'
650cAC                                       + '/' + %trim($drisubcmd)
650cAC                                       + ' from ' + #prog
650cA
650cAC                   when      chk4err and $drireturn <> '*OK'
650cAC                   eval      drierr = *on
650cA
650cAC                   endsl
650cA
650cAC                   select
650cAC                   when      $dricommand = '*PROD'
650cAC                   eval      $pprod = $dridata
650cAC                   eval      $pprod2 = $dridata2
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
650cAC                   endsl
650cA
650cAC                   eval      chk4err = *off
650cAC     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
     *----------------------------------------------------------------

**  MSG - Error Messages
Route xxxxx does not exist
Route xxxxx locked by another program
Route xxxxx is not at Built, Allocated or Picked Status
Out Lbl Undo R:99999 L:9999999
Route xxxxx reversed successfully
