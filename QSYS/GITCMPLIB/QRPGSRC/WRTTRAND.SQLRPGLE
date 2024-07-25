      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  PIRSQL must be on library list to run this program
     *  because this program uses user defined SQL functions.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WRTTRAND   Write PIRTRAND records
     *  15 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    06/15/10  DAS  5.30
     *      - Created.
     *
530aA*    08/18/10  DAS  5.30a
     *      - Added logic for indirect transactions during Direct tran.
     *      - Added logic for multiple transactions picked together.
     *
640aA*    09/27/11  DAS  6.40a
     *      - Changed PTDTRN# to PTDTRAN
     *      - Changed PTDEMP# to PTDEMPNUM
     *
640bA*    11/16/11  DAS  6.40b
     *      - Revised CreateEndDay to set shift info correctly.
     *
640cA*    11/18/11  DAS  6.40c
     *      - Revised WrtDetailRec to correctly handle a transaction
     *        where the start/end date/times are the same.
     *      - Revised GetIndirect to join to Task file.
     *
640dA*    11/18/11  DAS  6.40d
     *      - Added logging
     *
640eA*    12/19/11  DAS  6.40e
     *      - Added GetShiftValues routine.
     *      - Revised to call GetShiftValues instead of calculating
     *        Shift info in different places.
     *      - Revised WrtDetailRec to check for blank shift/crew.
     *
640fA*    12/20/11  DAS  6.40f
     *      - Added optional parms pFromDate, pToDate, pEmp#.
     *        New parms are to limit what is selected when PIRTRAND
     *        file is empty. These are mainly used to limit what is
     *        selected for testing purposes.
     *      - When PIRTRAND file is empty pFromDate not sent,
     *        then gFromDate will be set to first of previous month.
     *      - Revised WRTSELDETAIL to call GetZone.
     *
640gA*    12/27/11  DAS  6.40g
     *      - In GetIndirect, remove left outer join
     *        to Task file and replaced with exists select stmt.
     *        Re: For some reason the SQL optimizer was selecting the
     *        Task file as the primary file instead of PIRTRAN.
     *
640hA*    01/17/12  DAS  6.40h
     *      - Added flag field ptdnrmnv to pirtrand to indicate
     *        at least one normal selection label was not touched
     *        by voice.
     *      - Added flag field ptdmrgnv to pirtrand to indicate
     *        at least one merge selection label was not touched
     *        by voice.
     *      - Revised to not add a separate record for pieces not
     *        picked by voice. Instead, we will add the missed pieces
     *        to the record created for the PIRTRAN record. If the
     *        PIRTRAN record has an overlapping Indirect task, then
     *        the missed pieces will be added to the first record
     *        created for the PIRTRAN record.
     *      - Revised WrtSelTran to not set the new nv fields for
     *        a BULKF/P transaction.
     *
640iA*    02/01/12  DAS  6.40i
     *      - Revised to set pieces for Receivier record (PTDRCV).
     *      - Revised to set pieces for Returner record (PTDRTN).
     *      - Revised SetFlags to not set flag for PTDRPL if
     *        transaction pieces are zero.
     *      - Added fields ptdgrsblk, ptdblkpcs, ptdblklbls to contain
     *        merge values related to a bulk pick.
     *        Old merge fields will now only contain merge values
     *        not related to a bulk pick.
     *      - Added field ptdmrgzns to contain the number of merge
     *        zones in a transaction.
     *
640jA*    02/03/12  DAS  6.40i
     *      - Revised to caclulate UC times. Since we are currenly
     *        not updating PIRTRAND in real-time, this is the best
     *        we can do.
     *
640kA*    02/08/12  DAS  6.40k
     *      - Revised GetIndirect to ignore records that have
     *        a start date/time that comes before end date/time.
     *      - Revised to GetIndirect to ignore records that have
     *        the same start date/time and end date/time.
     *      - Revised WrtDetailRec to get out of Indirect loop
     *        after looping 20 times. We shouldn't run into 20
     *        overlapping Indirect tasks for a transaction.
     *      - Revised CreateEndDay to not create record if the
     *        sent in date is the same as the new end date.
     *      - Revised GetShiftInfo so if an ENDDAY isn't created
     *        in the over 12 hour logic, then don't create BEGDAY.
     *
640lA*    02/10/12  DAS  6.40l
     *      - When a task is found that is greater than 8 hours,
     *        revised to reduce end time by 5 seconds in order to
     *        allow a BEGDAY/ENDDAY to be created if necessary.
     *
640mA*    02/14/12  DAS  6.40m
     *      - Added GetLabelPut to get info for putaway transaction.
     *      - Revise GetPieces to call GetLabelPut for putaway tran.
     *      - Added ptdpick flag to indicate if a putaway touches
     *        a pick slot.
     *
640oA*    02/14/12  DAS  6.40o
     *      - Added ptdrpltf/ptdrpltfi for task REPLTF.
     *
640pA*    02/15/12  DAS  6.40p
     *      - Added message, warehouse and record fields to log file.
     *      - Added pCmd and pWait parameters.
     *      - Revised to loop through warehouses when sent whse is 0.
     *      - Revised to be never ending.
     *
640qA*    02/20/12  DAS  6.40q
     *      - Revised condition in WrtNewDetail SQL selection statement.
     *      - Changed some gWhse to gCurrWhse.
     *      - Revised GetZone to use whse and rte so it will use
     *        the key of worklbl94 instead of needing to creat a new LF.
     *
640rA*    02/28/12  DAS  6.40r
     *      - Revised fetch stmt in UpdDetail to include both file recs.
     *      - Revised WrtOpnDetail to initialize emp#, shift, crew.
     *      - Revised UpdShiftInfo to include status '2'.
     *
640sA*    03/01/12  DAS  6.40s
     *      - Revised to create BEG/ENDDAY records with status '4'.
     *
640tA*    03/08/12  DAS  6.40t
     *      - Fixed routine GetLabelPcs to include 'B' records.
     *      - Added check for sqlNullValElim to SQL statements
     *        that did a Left Outer Join.
     *
640uA*    03/26/12  DAS  6.40u
     *      - Revised GetPieces to force zero pcs for IDLE tran.
     *      - Revised GetSimCount to set count to 1 if start/end
     *        date/times are zero.
     *      - Revised GetSimCount to protect against count greater
     *        than 999.
     *
640vA*    05/14/12  DAS  6.40v
     *      - When file is empty, revised to only look at today
     *        instead of starting on the 1st of last month.
     *
640wA*    05/18/12  DAS  6.40w
     *      - Revised to get new Add stamp for each record instead
     *        of just using one for a batch of records that are added.
     *
640xA*    05/18/12  DAS  6.40x
     *      - Added fields ptdidlesec, ptdlabrsec and ptdcortran
     *        to pirtrand file.
     *      - Revised to do special handling of IDLE transactions
     *        at a status of 3 or 4. Now we are going to associate
     *        the IDLE record with the first Direct transaction
     *        record that preceeds it.
     *
640yA*    05/31/12  LMC  6.40y
     *      - Revised to run real time. Added new parm pTran#
     *        New logic to handle the interfaces from our existing
     *        program.
640zA*    07/18/12  LMC  6.40z
     *      - Revised to only refrence DQCLEAR on commands *ONCE and
     *        *NONSTOP.
641aA*    08/21/12  LMC  6.41a
     *      - changed mainend to log the transaction# on *ONETRAN
641bA*    09/03/12  DAS  641b
     *      - Added command *QUIT to shut down program.
     *      - Added parameter gSentTS, which is timestamp entry was
     *        put onto PIRTRAND2 data queue in program WRTTRAN1.
     *      - Revised to not log Parms message for *ONETRAN
650aA*    01/17/13  LMC  6.50a
     *      - Fixed routine GetVoicePcs to include 'B' records.
     *        on Non Merge pcs picked by voice.
650bA*    04/04/13  LMC  6.50b
     *      - Fixed sqlstmt in UpdShiftInfo  - problem found at
     *        Get Fresh in joblog.
     *        Select or omit error on field
     *        Cast(Translate(PIRTRAND_1.PTDSTAT, *UNNAMED
     *          Table) AS Integer) member PIRTRAND.
650cA*    04/08/13  LMC  6.50c
     *      - added first row only to sql to eliminate sql0811 error
     *        in joblog.
650dA*    04/22/13  LMC  6.50d
     *      - Check for the existence of BEGDAY before creating one
     *        in case user enters a BEGDAY after we have automatically
     *        created the BEGDAY due to activity.
650eA*    05/16/13  LMC  6.50e
     *      - Added RCVPO/RCVRTN transaction logic.
650fA*    12/03/13  LMC  6.50f
     *      - Added task to GetShiftValue.
     *      - Revised GetShiftValue, if working with BEGDAY, do not
     *        change start date if shift range is over midnight.
650gA*    02/03/14  DAS  6.50g
     *      - Created FixEndTime.
     *      - Replaced 650f changes when start/end over 8 hours with
     *        call to FixEndTime.
650hA*    02/12/14  LMC  6.50h
     *      - Correcting problems with BEGDAY transactions getting the
     *        wrong shift date.
650iA*    03/19/14  LMC  6.50i
     *      - Adding the begday time to FixEndTime if the begday time
     *        falls within the users normal shift hours, then the end
     *        time logic will be based on end of shift, otherwise
     *        end time is start time plus 1 minute.
650jA*    05/09/14  LMC  6.50j
     *      - Added *UNDOTRAN & *QUIT to check for valide commands.
650kA*    07/09/14  LMC  6.50k
     *      - Revised UpdDetail - allowing us to get shift info
     *        loaded into status 2 records.
650lA*    07/24/14  LMC  6.50l
     *      - Added call to GETEPMPCS for Putaway and Replenishments
650mA*    08/01/14  LMC  6.50m
     *      - Added file SHIFTDTE to be updated on BEGDAY transaction.
700aA*    09/22/16  LMC  7.00a
     *      - Enhanced logic on determining whether to create a
     *        BEGDAY.
700bA*    11/22/16  LMC  7.00b
     *      - Enhanced logic to not auto load RCVPO/RCVRTN task if
     *        client already has either of these task in PIRTRAN.
     *        If for some reason we need to clear PIRTRAND and reload
     *        the file, and the client already has RCVPO/RCVRTN tasks
     *        in PIRTRAN, we get duplicate RCVPO/RCVRTN task generated
     *        into PIRTRAND. The second set of RCVPO/RCVRTN tasks are
     *        loaded with the same transaction number as the PUTEMP/
     *        PUTRTN transactions. This was needed before we were
     *        creating RCVPO during receiving and RCVRTN during returns
710aA*    06/20/17  LMC  7.10a
     *      - Enhanced logic to load the close date into transactions
     *        where the employee number, the shift day date are 0 and
     *        the transaction is at status 4.
     *        Shift Day Date will be set to the close date.
710bA*    07/10/17  LMC  7.10b
     *      - Enhanced logic to handle extended history transactions
     *        We will base the adding of transaction records in
     *        WrtNewDetail if the generated date of the record found
     *        is more than six months old.
     *      - Enhanced logic in UpdDetail, to only delete the record
     *        in PIRTRAND if the generated dates match.
     *      - Enhanced logic in CleanUp, to only delete the record
     *        in PIRTRAND if the generated dates matchs the date sent
     *        in gFromDate.
710cA*    07/17/17  LMC  7.10c
     *      - Modification to 710a logic. Some transactions without
     *        an employee number don't have a close date, so timestamp
     *        error is occurring.
710dA*    07/28/17  LMC  7.10d
     *      - Modification to 710a logic. needs to also apply to a
     *        full load.
710eA*    08/29/17  KDE  7.10e
     *      - Enh:  Changed to not perform FIXENDTIME for Production
     *              module Task
710fA*    12/22/17  MR   7.10f
     *      - Add email and pics parms to GETEMPL.
720aA*    11/07/18  LMC  7.20a
     *      - Fix end time stamp in getpieces to set milliseconds
     *        all 9's.
720bA*    01/10/19  LMC  7.20b
     *      - At this time we will no longer load RUNNER task to
     *        PIRTRAND. RUNNER task are not handled like normal
     *        direct task. If this changes in the future we will
     *        need to address RU120 and RU310 to accurately account
     *        for pieces and time for the employee doing the runner
     *        activity.
730aA*    04/15/19  LMC  7.30a
     *      - Do Not display the message stating that runner
     *        transaction is not processed.
730bA*    12/05/19  LMC  7.30b
     *      - Enh: Handle new command STEPTRN from TE112.
730cA*    10/14/19  DAS  7.30b
     *      - Revised to use whs when continue to tran and lbl files
740aA*    12/29/20  LMC  7.40a
     *      - Revised we will base fixendtime on a 6 hour gap instead
     *        of 8 hour. we have been having more clients who have
     *        issues with no endday when their employees don't have
     *        an 8 hour gap in time.
750aA*    06/23/21  LMC  7.50a
     *      - *undotran was not leaving the main loop, and seemed to
     *        be causing the read of the  dataq to just sit.
     *        Added  it to the leave of the mainline.
760 A*    04/11/22  KDE  7.60
     *      - Call APTTRNSEL for Yhata to send APT selection data
760aA*    04/26/22  KDE  7.60a
     *      - Sbmjob Call to APTTRNSEL using command.  This way if
     *        APTTRNSEL gets and error it will only be one transaction
     *        for given employee
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  - If the elapsed time between the start and end times is 8
     *    hours or greater, then the PTDETS will be set to 1 hour
     *    after the PTDSTS. The PIRTRAN end date/time will not be
     *    changed.
     *
     *  - This program automatically creates missing BEGDAY/ENDAY
     *    transactions. A BEGDAY transaction will be created if
     *    12 hours has elapsed since the previous transaction for
     *    the employee. The start of the BEGDAY transaction will be
     *    set to 1 second before the start of the transaction that
     *    triggered the BEGDAY to be created. The ENDDAY transaction
     *    will be set to 1 second after the last transaction of the
     *    day for the employee.
     *
     *  - This program calculates a 'Shift' day for the transaction.
     *    The Shift day is start date of the corresponding BEGDAY
     *    transaction.
     *
     *  - Receiver records are written with task RCVPO (WrkRcvDetail).
700bA*    This is only done if no RCVPO records exist in PIRTRAN.
     *
     *  - Returner records are written with task RCVRTN (WrkRtnDetail).
700bA*    This is only done if no RCVRTN records exist in PIRTRAN.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

      *----------------------------------------------------------------
      * File Specs
      *----------------------------------------------------------------

760 Afoptions   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.adjtran2
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getempl
      /copy qcopysrc,p.getuser

650lA*----------------------------------------------------------------
650lA*  Prototypes
650lA*----------------------------------------------------------------
650lAD getepmpcs       pr                  extpgm('GETEPMPCS')
650lA * Input
650lAD   pparm1                       3s 0
650lAD   pparm2                       7  0
650lAD   pparm3                       5  0
650lAD   pparm4                       5  0
650lAD   pparm5                       5  0
650lAD   pparm6                       5  0
760 AD apttrnsel       pr                  extpgm('APTTRNSEL')
760 A * Input
760 AD   iWhse                        3  0
760 AD   iTran                        7  0
760 AD   iCmd                        10a
760 Ad   iEmp                         5  0
760 Ad   iReWrte                      1a
760 A * Output
760 AD   iRtn                        40a
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lbrec         E ds                  extname(label) inz(*EXTDFT)
     D llrec         E ds                  extname(labelnk) inz(*EXTDFT)
640dAD ltdrec        E ds                  extname(logtrand) inz(*EXTDFT)
     D orrec         E ds                  extname(orrtn) inz(*EXTDFT)
     D pasrec        E ds                  extname(passtran) inz(*EXTDFT)
     D ptrec         E ds                  extname(pirtran) inz(*EXTDFT)
530aAD ptreci        E ds                  extname(pirtran) prefix(ind_)
700bAD ptrecck       E ds                  extname(pirtran) prefix(ck_)
720bAD ptrunck       E ds                  extname(pirtran) prefix(ru_)
     D ptdrec        E ds                  extname(pirtrand) inz(*EXTDFT)
     D ptdrecsav     E ds                  extname(pirtrand) prefix(sav)
640xAD ptdrecdir     E ds                  extname(pirtrand) prefix(dir_)
650dAD ptdbegdayfld  E ds                  extname(pirtrand) prefix(beg_)
     D porrec        E ds                  extname(porcv) inz(*EXTDFT)
     D shrec         E ds                  extname(shift) inz(*EXTDFT)
     D tkrec         E ds                  extname(task) inz(*EXTDFT)
640pAD whrec         E ds                  extname(warehs) inz(*EXTDFT)
650mAD shdrec        E ds                  extname(shiftdte) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  dsplyMsg       s             32
     D  gBegDayStamp   s               z
     D  gCmd           s              8
640pAD  gCurrWhse      s              3  0
     D  gDuration      s              7  2
640fAD  gEmp#          s              5s 0
640fAD  gFromDate      s              8s 0
     D  gLastShift     s                   like(shcode)
640eMD  gLastShftStim  s              6s 0
640eMD  gLastShftEtim  s              6s 0
760 Ad  go12To3        s               n   inz(*off)
640pAD  gMessage       s                   like(ltdmsg)
640fAD  gToDate        s              8s 0
700bAD  gRCVPOFnd      s               n
700bAD  gRCVRTNFnd     s              1
640pAD  gRecsAdded     s              9  0
640pAD  gRecsDeleted   s              9  0
640pAD  gRecsShift     s              9  0
640pAD  gRecsUpdated   s              9  0
641bAD  gSentSec       s              9  0
641bAD  gSentTS        s               z
640yAD  gTran#         s              7  0
640pAD  gWait          s              2p 0
     D  gWhse          s              3  0
730bAD  gnsDate        s              8s 0
730bAD  gnsTime        s              6s 0
730bAD  gneDate        s              8s 0
730bAD  gneTime        s              6s 0
710eAd  wkctyp         s              1
710eAd  ictyp          s              5i 0
760 Ad logapt          s               n   inz(*off)
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  neStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  nsStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  heStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  hsStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  neStampUC      s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  nsStampUC      s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  heStampUC      s               z   inz(z'0001-01-01-00.00.00.000000')
730bAD  hsStampUC      s               z   inz(z'0001-01-01-00.00.00.000000')
710fAd  e$email        s              1
710fAd  e$pics         s              1
760 Ad  wkCmd          s             10
760 Ad  wkReWrte       s              1
760 Ad  wkRtn          s             40

640pA*----------------------------------------------------------------
640pA*  Data Queue Variables
640pA*----------------------------------------------------------------

     D  dqname         s             10    inz('WRTTRAND')
     D  dqlib          s             10    inz('*LIBL')
     D  dqdata         s             50
     D  dqlen          s              5  0
     D  dqwait         s              5  0
     D  dqorder        s              2
     D  dqkeylen       s              3  0
     D  dqkey          s              1
     D  dqsenderlen    s              3  0 inz(44)

     D  dqsenderinf    ds
     D    dqbytesrtn                  7p 0
     D    dqbytesavl                  7p 0
     D    dqjobname                  10
     D    dquser                     10
     D    dqjobnum                    6
     D    dqcurruser                 10

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z
640pAD startStampLoc   s               z
640pAD startStampSys   s               z
640pAD startStampUC    s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
640jaD ucOffset        s              3  0


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

640pAD  pCmd           s             10
640pAD  pWait          s              2  0
640pMD  pWhse          s              3  0
640yAD  pTran#         s              7  0
640pMD  pFromDate      s              8  0
640pMD  pToDate        s              8  0
640pMD  pEmp#          s              5  0
641bAD  pSentTS        s               z
730bAD  pnsDate        s              8  0
730bAD  pnsTime        s              6  0
730bAD  pneDate        s              8  0
730bAD  pneTime        s              6  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcHours       pr             5p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

640yAd CleanUp         pr

     d ClearFlags      pr
530aAd ClearIdFlags    pr
530aAd ClearTaskFlags  pr
530aAd ClearValues     pr

640pAd DQClear         pr
640pAd DQRead          pr             1p 0

650gAd FixEndTime      pr
650gAd  shift                         6    const
650gAd  startTS                        z   const
650gAd  endTS                          z   const
650gAd  newEndTS                       z
650gAd  newEndUC                       z

640wAd GetAddStamp     pr

     d GetCurrStamp    pr

     d CreateBegDay    pr              z

     d CreateEndDay    pr              z
     d  begdayStamp                    z   const

     d CreateTS        pr              z
     d  date                          8p 0 const
     d  time                          6p 0 const

640jAd CreateUC        pr              z
640jAd  stamp                          z   const

530aAd GetIndirect     pr
530aAd  sentSDte                      8s 0
530aAd  sentSTim                      6s 0
530aAd  sentEDte                      8s 0
530aAd  sentETim                      6s 0
530aAd  outSDte                       8s 0
530aAd  outSTim                       6s 0
530aAd  outEDte                       8s 0
530aAd  outETim                       6s 0
530aAd  outFound                       n
530aAd  outMoreFlag                    n

     d GetLabelPcs     pr
     d  grossPcs                      5p 0
     d  grossMrg                      5p 0
640iAd  grossBlk                      5p 0
     d  pcs                           5p 0
     d  mrgPcs                        5p 0
640iAd  blkPcs                        5p 0
     d  labels                        5p 0
     d  mrgLabels                     5p 0
640iAd  blkLabels                     5p 0
640iAd  mrgzones                      5p 0
640iAd  blkzones                      5p 0
640iAd  slots                         5p 0

640mAd GetLabelPut     pr
640mAd  grossPcs                      5p 0
640mAd  pcs                           5p 0
640mAd  labels                        5p 0
640mAd  slots                         5p 0
640mAd  pick                          1s 0

     d GetMissedPcs    pr
     d  grossPcs                      5p 0
     d  grossMrg                      5p 0
640iAd  grossBlk                      5p 0
     d  pcs                           5p 0
     d  mrgPcs                        5p 0
640iAd  blkPcs                        5p 0
     d  labels                        5p 0
     d  mrgLabels                     5p 0
640iAd  blkLabels                     5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0

530aAd GetPieces       pr
530aAd  sentEmp#                      5p 0
530aAd  sentRoutine                  30    const
640hAd sentInclMissed                  n
530aAd  sentStartTS                    z
530aAd  sentEndTS                      z
530aad  outGrossPcs                   5p 0
530aAd  outGrossMrg                   5p 0
640iAd  outGrossBlk                   5p 0
530aAd  outPcs                        5p 0
530aAd  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0
530aAd  outLabels                     5p 0
530aAd  outMrgLabels                  5p 0
640iAd  outBlkLabels                  5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0
640mAd  outPick                       1s 0

640eAd GetShiftValues  pr
640eAd  shift                         6    const
650FAd  task                          6    const
640eAd  startTS                        z   const
640eAd  shiftDay                      6s 0
640eAd  shiftDOW                      1s 0
640eAd  shiftWeek                     2s 0
640eAd  shiftSunday                   6s 0

     d GetShiftInfo    pr
     d  shiftDay                      6s 0
     d  shiftDOW                      1s 0
     d  shiftWeek                     2s 0
     d  shiftSunday                   6s 0

530aAd GetSimCount     pr             5p 0

     d GetVoicePcs     pr
     d  emp#                          5p 0 const
     d  fromTS                         z   const
     d  toTS                           z   const
     d  grossPcs                      5p 0
     d  grossMrg                      5p 0
640iAd  grossBlk                      5p 0
     d  pcs                           5p 0
     d  mrgPcs                        5p 0
640iAd  blkPcs                        5p 0
     d  labels                        5p 0
     d  mrgLabels                     5p 0
640iAd  blkLabels                     5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0

640pAd GetNextWhse     pr             3p 0

     d GetZone         pr             6

640pAd LogCleanup      pr
     d  cmd                          10    const

640dAd LogIt           pr
     d  cmd                          10    const

     d SetFlags        pr

730bAd SteppedOnTran   pr

640yAd ClearFile       pr
640yAd  ClrWhse                       3  0

     d UpdDetail       pr

640yAd UpdDelete       pr
640yAd  updSts                        1    const

650mAd UpdShiftDte     pr

     d UpdShiftInfo    pr
     d VoiceRecExists  pr             1p 0

530aAd WrtDetailRec    pr
530aAd  sentEmp#                      5p 0
530aAd  sentRoutine                  30    const
530aAd  sentSDte                      8s 0
530aAd  sentSTim                      6s 0
530aAd  sentEDte                      8s 0
530aAd  sentETim                      6s 0

640xAd WrtIdleDetail   pr
     d WrtOpnDetail    pr
     d WrtNewDetail    pr
     d WrtNewDetail2   pr
     d WrtNewDetail3   pr
     d WrtRcvDetail    pr
     d WrtRtnDetail    pr
     d WrtSelDetail    pr
     d WrtSelNoVoice   pr

     d WrtVoiceMiss    pr
     d  passtranFound                  n
530aAd  passtranEmp#                  5p 0

     d WrtVoicePass    pr
     d  ptemp#Found                    n
     d  passtranFound                  n
530aAd  passtranEmp#                  5p 0

     d WrtVoiceTran    pr
     d  ptemp#Found                    n

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pCmd        Command
     *        *CLEANUP  -
     *        *CLEANLOG -
     *        *CLEAR    -
     *        *DLTTRAN  -
     *        *NONSTOP  -
     *        *ONCE     -
     *        *ONETRAN  -
641bA*        *QUIT     -
650jA*        *UNDOTRAN -
730bA*        *STEPTRN  -
     *      pWait       Wait Time
     *      pWhse       Warehouse
     *      pTran#      Transaction Number
     *      pFromDate   From Date
     *      pToDate     To Date
     *      pEmp#       Employee Number
     *      pnsdate     Start date for STEPTRN command
     *      pnstime     Start time for STEPTRN command
     *      pnedate     End date for STEPTRN command
     *      pnetime     End time for STEPTRN command
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
640pAc                   parm                    pCmd
640pAc                   parm                    pWait
     c                   parm                    pWhse
640yAc                   parm                    pTran#
640fAc                   parm                    pFromDate
640fAc                   parm                    pToDate
640fAc                   parm                    pEmp#
641bAc                   parm                    pSentTS
730bAc                   parm                    pNsDate
730bAc                   parm                    pNsTime
730bAc                   parm                    pNeDate
730bAc                   parm                    pNeTime

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
760 A *   Check for APT logging option
760 A      chain (1:'*APTFTP') options;
760 A      if %found(options)
760 A         and %subst(opdata:1:1) = 'Y';
760 A         logapt = *on;
760 A      else;
760 A         logapt = *off;
760 A       endif;

640yA   if pCmd = '*ONCE' or
640yA      pCmd = '*NONSTOP' or
640yA      pCmd = '*CLEAR  ' or
640yA      pCmd = '*CLEANLOG';
          *inlr = *on;
640yA   endif;

640pA   // Record parameters
640pA
730bA   Select;
730bA     when pCmd = '*STEPTRN';
730bA       gMessage =  %trim(pCmd)
730bA              + '/' + %char(pTran#)
730bA              + '/' + %char(pnsDate)
730bA              + '/' + %char(pnsTime)
730bA              + '/' + %char(pneDate)
730bA              + '/' + %char(pneTime)
730bA              + '/' + %char(pEmp#);
730bA       LogIt('Message');
730bA     when pCmd = '*ONETRAN';
730bA     other;
730bD   //if pCmd <> '*ONETRAN';
640pA       gMessage = 'Parms: ' + %trim(pCmd) + '/' + %char(pWait)
640yD              //+ '/' + %char(pwhse) + '/' + %char(pFromDate)
640yM              + '/' + %char(pwhse) + '/' + %char(pTran#)
640yA              + '/' + %char(pFromDate)
640pA              + '/' + %char(pToDate) + '/' + %char(pEmp#);
640pA     LogIt('Message');
730bD   //endif;
730bA   endsl;

641bA   if pCmd = '*QUIT';
641bA     *inlr = *on;
641bA     return;
641bA   endif;

640fA   // Initialize parameters
640fA
640fA   gWhse = 0;
640fA   gFromDate = 0;
640fA   gToDate = 0;
640fA   gEmp# = 0;
640pA
640pA   if pCmd <> '*ONCE'
640yA     and pCmd <> '*ONETRAN'
640yA     and pCmd <> '*DLTTRAN'
640yA     and pCmd <> '*CLEAR  '
640yA     and pCmd <> '*CLEANUP'
640yA     and pCmd <> '*CLEANLOG'
650jA     and pCmd <> '*UNDOTRAN'
650jA     and pCmd <> '*QUIT'
730bA     and pCmd <> '*STEPTRN'
640pA     and pCmd <> '*NONSTOP';
640pA       dsplyMsg =  'Invalid command: ' + pCmd;
640pA       gMessage = dsplyMsg;
640pA       LogIt('Message');
640pA       dsply dsplyMsg;
640pA       return;
640pA   endif;
640pA

640pA   monitor;
640pA     gWait = pWait;
640pA     if pWait <= 0;
640pA       eval gWait = 5;
640pA     endif;
640pA   on-error;
640pA     dsplyMsg =  'Invalid wait: ' + %char(pWait);
640pA     gMessage = dsplyMsg;
640pA     LogIt('Message');
640pA     dsply dsplyMsg;
640pA     return;
640pA   endmon;
640fA
640fA   monitor;
640pD     //gWhse = %dec(pWhse:3:0);
640pM     gWhse = pWhse;
640fA   on-error;
640pM     dsplyMsg =  'Invalid warehouse: ' + %char(pWhse);
640pA     gMessage = dsplyMsg;
640pA     LogIt('Message');
640fA     dsply dsplyMsg;
640fA     return;
640fA   endmon;
640fA
640yA   monitor;
640yA     gTran# = pTran#;
640yA   on-error;
640yA     dsplyMsg =  'Invalid transaction: ' + %char(pTran#);
640yA     gMessage = dsplyMsg;
640yA     LogIt('Message');
640yA     dsply dsplyMsg;
640yA     return;
640yA   endmon;

640yA   monitor;
640yA     gcmd = pcmd;
640yA   on-error;
640yA     dsplyMsg =  'Invalid Command: ' + (pCmd);
640yA     gMessage = dsplyMsg;
640yA     LogIt('Message');
640yA     dsply dsplyMsg;
640yA     return;
640yA   endmon;

640yA   // make sure warehouse number is passed in
640yA   if pCmd = '*ONETRAN' and gWhse  <= 0 or
640yA      pCmd = '*DLTTRAN' and gWhse  <= 0 or
730bA      pCmd = '*SETPTRN' and gWhse  <= 0 or
640yA      pCmd = '*CLEANUP' and gWhse  <= 0;
640yA     dsplyMsg =  'Invalid Warehouse: ' + %char(pwhse);
640yA     gMessage = dsplyMsg;
640yA     LogIt('Message');
640yA     dsply dsplyMsg;
640yA     return;
640yA   endif;

640yA   // make sure transaction number is passed in
640yA   if pCmd = '*ONETRAN' and gTran# <= 0 or
640yA      pCmd = '*DLTTRAN' and gTran# <= 0 or
730bA      pCmd = '*STEPTRN' and gTran# <= 0 or
640yA      pCmd = '*CLEANUP' and gTran# <= 0;
640yA     dsplyMsg =  'Invalid transaction: ' + %char(pTran#);
640yA     gMessage = dsplyMsg;
640yA     LogIt('Message');
640yA     dsply dsplyMsg;
640yA     return;
640yA   endif;


640pD   //if %parms >= 4 and pFromDate <> ' ';
640yD   //if %parms >= 4 and pFromDate > 0;
640yM   if %parms >= 5 and pFromDate > 0;
640fA     monitor;
640pD       //gFromDate = %dec(pFromDate:8:0);
640pM       gFromDate = pFromDate;
640fA     on-error;
640pM       dsplyMsg =  'Invalid From Date: ' + %char(pFromDate);
640pA       gMessage = dsplyMsg;
640pA       LogIt('Message');
640fA       dsply dsplyMsg;
640fA       return;
640fA     endmon;
640fA   endif;
640fA
640pD   //if %parms >= 5 and pToDate <> ' ';
640yD   //if %parms >= 5 and pToDate > 0;
640yM   if %parms >= 6 and pToDate > 0;
640fA     monitor;
640pD       //gToDate = %dec(pToDate:8:0);
640pM       gToDate = pToDate;
640fA     on-error;
640pM       dsplyMsg =  'Invalid To Date: ' + %char(pToDate);
640pA       gMessage = dsplyMsg;
640pA       LogIt('Message');
640fA       dsply dsplyMsg;
640fA       return;
640fA     endmon;
640fA   endif;
640fA
640pD   //if %parms >= 6 and pEmp# <> ' ';
640yD   //if %parms >= 6 and pEmp# > 0;
640yM   if %parms >= 7 and pEmp# > 0;
640fA     monitor;
640pD       //gEmp# = %dec(pEmp#:5:0);
640pM       gEmp# = pEmp#;
640fA     on-error;
640fA       dsplyMsg =  'Invalid Emp#: ' + %char(pEmp#);
640pA       gMessage = dsplyMsg;
640pA       LogIt('Message');
640fA       dsply dsplyMsg;
640fA       return;
640fA     endmon;
640fA   endif;

641bA   if %parms >= 8;
641bA     monitor;
641bA       gSentTS = pSentTS;
641bA     on-error;
641bA     endmon;
641bA   endif;

730bA   if %parms >= 9 and pnsDate > 0;
730bA     monitor;
730bA       gnsDate = pnsDate;
730bA     on-error;
730bA       dsplyMsg =  'Invalid New Start Date: ' + %char(pnsDate);
730bA       gMessage = dsplyMsg;
730bA       LogIt('Message');
730bA       dsply dsplyMsg;
730bA       return;
730bA     endmon;
730bA   endif;

730bA   if %parms >= 10 and pnsTime > 0;
730bA     monitor;
730bA       gnstime = pnsTime;
730bA     on-error;
730bA       dsplyMsg =  'Invalid New Start Time: ' + %char(pnsTime);
730bA       gMessage = dsplyMsg;
730bA       LogIt('Message');
730bA       dsply dsplyMsg;
730bA       return;
730bA     endmon;
730bA   endif;

730bA   if %parms >= 11 and pneDate > 0;
730bA     monitor;
730bA       gneDate = pneDate;
730bA     on-error;
730bA       dsplyMsg =  'Invalid New End Date: ' + %char(pneDate);
730bA       gMessage = dsplyMsg;
730bA       LogIt('Message');
730bA       dsply dsplyMsg;
730bA       return;
730bA     endmon;
730bA   endif;

730bA   if %parms >= 12 and pneTime > 0;
730bA     monitor;
730bA       gnetime = pneTime;
730bA     on-error;
730bA       dsplyMsg =  'Invalid New End Time: ' + %char(pneTime);
730bA       gMessage = dsplyMsg;
730bA       LogIt('Message');
730bA       dsply dsplyMsg;
730bA       return;
730bA     endmon;
730bA   endif;

640pA   // Remove old log records
640pA
640yA   if pCmd = '*ONCE' or
640yA      pCmd = '*NONSTOP' or
640yA      pCmd = '*CLEAR' or
640yA      pCmd = '*CLEANLOG';
640pA     LogCleanUp('Date');
640yA   endif;

640yA   if pCmd = '*CLEANLOG';
640yA     return;
640yA   endif;

640pA   // Clear any left over commands from data queue.
640pA
640zA   if pCmd = '*ONCE' or
640zA      pCmd = '*NONSTOP';
640pA     DQClear();
640zA   endif;

720bA   // if this is a runner task - do nothing just return
730bD   //if pCmd = '*ONETRAN';
730bM   if pCmd = '*ONETRAN'  or
730bM      pCmd = '*STEPTRN';
700bA     exec sql select * into :ptrunck
700bA            from  pirtran
700bA            where pttask = 'RUNNER'
730cA             and  ptwhse = :pwhse
700bA             and  pttrn# = :ptran#
700ba            fetch first 1 rows only;
700bA     if sqlstt = sqlSuccess;
720bA       dsplyMsg =  'Runner Task: ' + %char(pTran#);
720bA       gMessage = dsplyMsg;
720bA       LogIt('Message');
730aD       //dsply dsplyMsg;
720bA       return;
700bA     endif;
720bA   endif;

700bA   // Setup gRCVPO and gRCVRTN flags
700bA
700bA   // check to see if RCVPO transactions exist in PIRTRAN
700bA   // if so we don't need to do this process.
700bA   exec sql select * into :ptrecck
700bA            from  pirtran
700bA            where pttask = 'RCVPO'
730cA             and  ptwhse = :pwhse
700ba            fetch first 1 rows only;

700bA   if sqlstt = sqlSuccess;
700bA     gRCVPOFnd = *on;
700bA   endif;

700bA   // check to see if RCVRTN transactions exist in PIRTRAN
700bA   // if so we don't need to do this process.
700bA   exec sql select * into :ptrecck
700bA            from  pirtran
700bA            where pttask = 'RCVRTN'
730cA             and  ptwhse = :pwhse
700ba            fetch first 1 rows only;

700bA   if sqlstt = sqlSuccess;
700bA     gRCVRTNFnd = *on;
700bA   endif;
640pA   // Main loop.
640pA   // Conditions for leaving loop are at the end of the loop.
640pA
640pA   dow forever = forever;

640pA     // Remove 'zero' records
640pA     // This is done here to clean up the zero records from last
640pA     // time through warehouses.
640pA
640yA     if pCmd = '*ONCE' or
640yA        pCmd = '*NONSTOP' or
640yA        pCmd = '*CLEAR';
640pA       LogCleanUp('Zero');
640yA     endif;
640pA
640pA     // Loop through all warehouses
640pA
640pA     gCurrWhse = 0;
640pA
640pA     dow forever = forever;
640pA
640pA       // Get next warehouse
640pA
640pA       gCurrWhse = GetNextWhse();
640pA       if gCurrWhse < 0;
640pA         leave;
640pA       endif;

            // Get timestamp to tag all records with

            GetCurrStamp();
640pA       startStampLoc = CurrStampLoc;
640pA       startStampSys = CurrStampSys;
640pA       startStampUC  = CurrStampUC;

640dA       LogIt('MainStart');

640yA       // Pcmd = '*CLEAR  ' Clear file for startup or testing By Whse

640yA       if pcmd = '*CLEAR  ';
640yA         LogIt('ClrStart');
640yA         ClearFile (pwhse);
640yA         LogIt('ClrEnd');
640yA         LogIt('MainEnd');
640yA         leave;
640yA       endif;

640yA       // Pcmd = '*CLEANUP' System cleanup delete the transaction it ha
640yA       // already been deleted from pirtran.

640yA       if pcmd = '*CLEANUP';
640yA         LogIt('ClnStart');
640yA         cleanUp ();
640yA         LogIt('ClnEnd');
640yA         LogIt('MainEnd');
640yA         leave;
640yA       endif;

            // First, see if any records need to be updated because
            // the status changed.

640yA       if pcmd = '*DLTTRAN';
640yA         updDelete('X');
750aA         leave;
640yA       endif;

640yA       if pcmd = '*UNDOTRAN';
640yA         updDelete('U');
750aA         leave;
640yA       endif;

730bA       if pcmd = '*STEPTRN';
730bA         SteppedOnTran();
730bA         leave;
730bA       endif;

640dA       LogIt('UpdStart');
            updDetail();
640dA       LogIt('UpdEnd');

            // Next, create records for new transactions.

640dA       LogIt('NewStart');
            wrtNewDetail();
640dA       LogIt('NewEnd');

            // Last, update Shift date information.

640dA       LogIt('ShiftStart');
            updShiftInfo();
640dA       LogIt('ShiftEnd');

641aA       if gCmd = '*ONETRAN';
641aA         gMessage = 'MainEnd ' + %trim(pCmd)
641aA                  + '/' + %char(pwhse) + '/' + %char(pTran#);
641aA       endif;
640dA       LogIt('MainEnd');

640pA     enddo;

640pA     // Leave main loop if command was *ONCE
640pA
640pA     if pCmd = '*ONCE';
640pA       leave;
640pA     endif;

640yA     // Leave main loop if command was *ONETRAN

640yA     if pCmd = '*ONETRAN' or
640yA        pCmd = '*DLTTRAN' or
640yA        pCmd = '*CLEAR  ' or
730bA        pCmd = '*STEPTRN' or
750aA        pCmd = '*UNDOTRAN' or
640yA        pCmd = '*CLEANUP';
640yA       leave;
640yA     endif;


640pA     // Otherwise, read data queue.
640pA     // If nothing is sent, it will automatically wake up for processing.
640pA
640pA     if DQRead < 0;
640pA       leave;
640pA     endif;
640pA
640pA   enddo;

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CalcHours   Calculate hours between timestamps
     *----------------------------------------------------------------

     p CalcHours       b
     d CalcHours       pi             5p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D hours           s              5p 0

      /free

        select;
          when fromTS = noStamp;
            hours = 0;
          when toTS = noStamp;
            hours = 0;
          when fromTS > toTS;
            hours = 0;
          other;
            monitor;
              hours = %diff(toTS: fromTS: *HOURS);
            on-error;
              hours = 0;
            endmon;
        endsl;

        return hours;

      /end-free

     p CalcHours       e

     *----------------------------------------------------------------
     *  CalcSeconds   Calculate seconds between timestamps
     *----------------------------------------------------------------

     p CalcSeconds     b
     d CalcSeconds     pi             7p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D seconds         s              7p 0

      /free

        select;
          when fromTS = noStamp;
            seconds = 0;
          when toTS = noStamp;
            seconds = 0;
          when fromTS > toTS;
            seconds = 0;
          other;
            monitor;
              seconds = %diff(toTS: fromTS: *SECONDS);
            on-error;
              seconds = 0;
            endmon;
        endsl;

        return seconds;

      /end-free

     p CalcSeconds     e

     *----------------------------------------------------------------
     *  CreateBegDay  Get BEGDAY record
     *----------------------------------------------------------------

     p CreateBegDay    b
     d CreateBegDay    pi              z

     *  Local Variables

     d begdayStamp     s               z
     d sundayStamp     s               z

     D  acmd           s             10
     D  aprg           s             10
     D  atype          s              8
     D  atrn#          s              7  0
     D  atask          s              6
     D  awhse          s              3  0
     D  awhdp          s              5
     D  astyp          s              1
     D  acube          s              9  3
     D  aswgt          s              9  2
     D  apcs           s              5  0
     D  aaisl          s              5  0
     D  aqty1          s              5  0
     D  aqty2          s              5  0
     D  aqty3          s              5  0
     D  arte           s              5
     D  apo            s              9
     D  agrp1          s              1
     D  agrp2          s              1
     D  adate          s              8  0
     D  atime          s              6  0
     D  auser          s             10
     D  artn           s              8
     D  amsg           s              4

     D e$whse          s              3  0
     D e$user          s             10
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
710fAD e$email         s              1
710fAD e$pics          s              1

      /free

        // Set BEGDAY stamp to 1 micro second before transaction stamp.
        // Since we are reading the PIRTRAN file in date/time order,
        // this will ensure we won't read this record.

        if ptdsts = noStamp;
          begdayStamp = ptdsts;
        else;
          begdayStamp = ptdsts - %mseconds(1);
        endif;

        // Get employee information

        getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD    //     e$bpu: e$lng);
710fM           e$bpu: e$lng: e$email: e$pics);

        // Create PIRTRAN record

        acmd  = '*BEGDAYMIS';
        aprg  = #pgm;
        atype = '*INTER';
        atrn# = 0;
        atask = 'BEGDAY';
        awhse = ptdwhse;
        awhdp = ' ';
        astyp = ' ';
        acube = 0;
        aswgt = 0;
        apcs  = 0;
        aaisl = 0;
        aqty1 = 0;
        aqty2 = 0;
        aqty3 = 0;
        arte  = ' ';
        apo   = ' ';
        agrp1 = ' ';
        agrp2 = ' ';
        if begdayStamp = noStamp;
          adate = 0;
          atime = 0;
        else;
          adate = %dec(%date(begdayStamp):*iso);
          atime = %dec(%time(begdayStamp):*hms);
        endif;
        auser = e$user;
        artn  = ' ';
        amsg  = ' ';

        //AdjTran2(acmd: aprg: atype: atrn#: atask: awhse:
        //         awhdp: astyp: acube: aswgt: apcs: aaisl: aqty1:
        //         aqty2: aqty3: arte: apo: agrp1: agrp2: adate:
        //         atime: auser: artn: amsg);

        // Save current PTDREC values

        ptdrecsav = ptdrec;

        // Create PIRTRAND record

        ClearFlags();
        ptdtran = atrn#;
        ptdtask = 'BEGDAY';
640sA   ptdstat = '4';
640sA   ptddetl = 'Y';
        ptdbegday = 1;
530aA   ptdsimtran = 1;

530aA   ClearValues();

        // Calculate stamps

        ptdsts = begdayStamp;
640jA   ptdsuc = CreateUC(ptdsts);
        ptdgts = ptdsts;
640jA   ptdguc = ptdsuc;
        ptdets = ptdsts;
640jA   ptdeuc = ptdsuc;
        ptdcts = ptdsts;
640jA   ptdcuc = ptdsuc;

        if ptdgts = noStamp;
          ptdgdte = 0;
          ptdgtim = 0;
        else;
          ptdgdte = %dec(%date(ptdgts):*iso);
          ptdgtim = %dec(%time(ptdgts):*hms);
        endif;

        // Create shift info

        if ptdsts = noStamp;
          ptdshftDay = 0;
          ptdshftWk  = 0;
          ptdshftDOW = 0;
          ptdshftSun = 0;
        else;
650fD     //GetShiftValues(ptdshft: ptdsts:
650fM     GetShiftValues(ptdshft: ptdtask: ptdsts:
640eA                    ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

640eD     //ptdshftday = %dec(%date(ptdsts):*ymd);

640eD     //exec sql set :ptdshftwk = week(:ptdsts),
640eD     //             :ptdshftdow  = dayofweek(:ptdsts);

640eD     //sundayStamp = ptdsts - %days(ptdshftdow-1);
640eD     //ptdshftsun = %dec(%date(sundayStamp):*ymd);
        endif;

640bA   ptdsec = 0;
640bA   ptdzone = ' ';

650mA   // update SHIFTDTE file
650mA   UpdShiftDte();
        // Write BEGDAY record


640wA   GetAddStamp();
        exec sql insert into pirtrand values(:ptdrec);

        if sqlstt <> sqlSuccess;
        endif;

640pA   gRecsAdded += 1;

        // Restore PTDREC values

        ptdrec = ptdrecsav;

        return begdayStamp;

      /end-free

     p CreateBegDay    e

     *----------------------------------------------------------------
     *  CreateEndDay  Get ENDDAY record
     *----------------------------------------------------------------

     p CreateEndDay    b
     d CreateEndDay    pi              z
     d begdayStampIn                   z   const

     *  Local Variables

     D begdayStamp     s               z
     D begdayInd       s              2b 0
     D enddayStamp     s               z
     D enddayInd       s              2b 0
     D prevStamp       s               z
     D prevInd         s              2b 0
     D sundayStamp     s               z
700aAD lsttrnStamp     s               z
700aAD lsttrnInd       s              2b 0

     D  acmd           s             10
     D  aprg           s             10
     D  atype          s              8
     D  atrn#          s              7  0
     D  atask          s              6
     D  awhse          s              3  0
     D  awhdp          s              5
     D  astyp          s              1
     D  acube          s              9  3
     D  aswgt          s              9  2
     D  apcs           s              5  0
     D  aaisl          s              5  0
     D  aqty1          s              5  0
     D  aqty2          s              5  0
     D  aqty3          s              5  0
     D  arte           s              5
     D  apo            s              9
     D  agrp1          s              1
     D  agrp2          s              1
     D  adate          s              8  0
     D  atime          s              6  0
     D  auser          s             10
     D  artn           s              8
     D  amsg           s              4

     D e$whse          s              3  0
     D e$user          s             10
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

      /free

        // Get record prior to BEGDAY stamp sent in.

        exec sql select max(ptdsts) into :prevStamp :prevInd
                 from pirtrand
                 where ptdwhse = :ptdwhse
                   and ptdempnum = :ptdempnum
                   and ptdsts < :begdayStampIn
                   and ptdsts <> :noStamp;

        if sqlstt <> sqlSuccess or prevInd < 0;
          return noStamp;
        endif;

        // Now get the end date.

        exec sql select max(ptdets) into :enddayStamp :enddayInd
                 from pirtrand
                 where ptdwhse = :ptdwhse
                   and ptdempnum = :ptdempnum
                   and ptdsts = :prevStamp
                   and ptdets <> :noStamp;

        if sqlstt <> sqlSuccess or enddayInd < 0;
          return noStamp;
        endif;

640kA   // Don't create ENDDAY record if there is no time between
640kA   // begdayStampIn and the enddayStamp.
640kA   if begdayStampIn = enddayStamp;
640kA     return nostamp;
640kA   endif;

640eD   //if enddayStamp = noStamp
640eM   if enddayStamp = noStamp or enddayStamp = prevStamp;
          enddayStamp = prevStamp + %mseconds(1);
        endif;

640bA   // Get previous BEGDAY
640bA
640bA     exec sql select max(ptdsts) into :begdayStamp :begdayInd
640bA              from pirtrand
640bA              where ptdwhse = :ptdwhse
640bA                and ptdempnum = :ptdempnum
640bA                and ptdtask = 'BEGDAY'
640bA                and ptdsts <= :enddayStamp;
640bA
640bA     if sqlstt <> sqlSuccess or begdayInd < 0;
640bA       begdayStamp = nostamp;
640bA     endif;

        // Get employee information

        getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD       //  e$bpu: e$lng);
710fM           e$bpu: e$lng: e$email: e$pics);

        // Create PIRTRAN record

        acmd  = '*ENDDAYMIS';
        aprg  = #pgm;
        atype = '*INTER';
        atrn# = 0;
        atask = 'ENDDAY';
        awhse = ptdwhse;
        awhdp = ' ';
        astyp = ' ';
        acube = 0;
        aswgt = 0;
        apcs  = 0;
        aaisl = 0;
        aqty1 = 0;
        aqty2 = 0;
        aqty3 = 0;
        arte  = ' ';
        apo   = ' ';
        agrp1 = ' ';
        agrp2 = ' ';
        if enddayStamp = noStamp;
          adate = 0;
          atime = 0;
        else;
          adate = %dec(%date(enddayStamp):*iso);
          atime = %dec(%time(enddayStamp):*hms);
        endif;
        auser = e$user;
        artn  = ' ';
        amsg  = ' ';

        //AdjTran2(acmd: aprg: atype: atrn#: atask: awhse:
        //         awhdp: astyp: acube: aswgt: apcs: aaisl: aqty1:
        //         aqty2: aqty3: arte: apo: agrp1: agrp2: adate:
        //         atime: auser: artn: amsg);

        // Save current PTDREC values

        ptdrecsav = ptdrec;

        // Create PIRTRAND record

        ClearFlags();
        ptdtran = atrn#;
        ptdtask = 'ENDDAY';
640sA   ptdstat = '4';
640sA   ptddetl = 'Y';
        ptdendday = 1;
530aA   ptdsimtran = 1;

530aA   ClearValues();

        // Calculate stamps

        ptdgts = enddayStamp;
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = enddayStamp;
640jA   ptdsuc = ptdguc;
        ptdets = enddayStamp;
640jA   ptdeuc = ptdguc;
        ptdcts = enddayStamp;
640jA   ptdcuc = ptdguc;

        if ptdgts = noStamp;
          ptdgdte = 0;
          ptdgtim = 0;
        else;
          ptdgdte = %dec(%date(ptdgts):*iso);
          ptdgtim = %dec(%time(ptdgts):*hms);
        endif;

        // Create shift info

640bD   //if ptdsts = noStamp;
640bM   if begdayStamp = noStamp;
          ptdshftDay = 0;
          ptdshftWk  = 0;
          ptdshftDOW = 0;
          ptdshftSun = 0;
640bA     ptdsec = 0;
        else;
650fD     //GetShiftValues(ptdshft: begdayStamp:
650fM     GetShiftValues(ptdshft: ptdtask: begdayStamp:
640eA                    ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

640bD     //ptdshftday = %dec(%date(ptdsts):*ymd);
640eD     //ptdshftday = %dec(%date(begdayStamp):*ymd);

640bD     //exec sql set :ptdshftwk = week(:ptdsts),
640bD     //             :ptdshftdow  = dayofweek(:ptdsts);
640eD     //exec sql set :ptdshftwk = week(:begdayStamp),
640eD     //             :ptdshftdow  = dayofweek(:begdayStamp);

640bD     //sundayStamp = ptdsts - %days(ptdshftdow-1);
640eD     //sundayStamp = begdayStamp - %days(ptdshftdow-1);
640eD     //ptdshftsun = %dec(%date(sundayStamp):*ymd);

640bA     ptdsec = CalcSeconds(begdayStamp: enddayStamp);
        endif;

640bD   //  ptdsec = CalcSeconds(begdayStamp: enddayStamp);
640bD   // Calculate seconds between BEGDAY and ENDDAY
640bD   //  (moved earlier in routine)
640bD   //
640bD   //exec sql select max(ptdsts) into :begdayStamp :begdayInd
640bD   //         from pirtrand
640bD   //         where ptdwhse = :ptdwhse
640bD   //           and ptdempnum = :ptdempnum
640bD   //           and ptdtask = 'BEGDAY'
640bD   //           and ptdsts <= :enddayStamp;
640bD   //
640bD   //if sqlstt <> sqlSuccess or begdayInd < 0;
640bD   //  ptdsec = 0;
640bD   //else;
640bD   //  ptdsec = CalcSeconds(begdayStamp: enddayStamp);
640bD   //endif;

640bA   ptdzone = ' ';

        // Write ENDAY record

640wA   GetAddStamp();
        exec sql insert into pirtrand values(:ptdrec);

        if sqlstt <> sqlSuccess;
        endif;

640pA   gRecsAdded += 1;

        // Restore PTDREC values

        ptdrec = ptdrecsav;

        return enddayStamp;

      /end-free

     p CreateEndDay    e

     *----------------------------------------------------------------
     *  CreateTS   Create timestamp from Date/Time
     *----------------------------------------------------------------

     p CreateTS        b
     d CreateTS        pi              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *  Local Variables

     D stamp           s               z
     D temp26          s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6


      /free

        clear stamp;

        if date = 0;
          return stamp;
        endif;

        yyyymmdd = date;
        hhmiss = time;
        temp26 = yyyy + '-' + mm + '-' + dd + '-'
               + hh + '.' + mi + '.' + ss + '.000000';

        monitor;
          stamp = %timestamp(temp26);
        on-error;
          clear stamp;
        endmon;

        return stamp;

      /end-free

     p CreateTS        e

     *----------------------------------------------------------------
     *  CreateUC      Create UC stamp
     *----------------------------------------------------------------

     p CreateUC        b
     d CreateUC        pi              z
     d stampIn                         z   const

     *  Local Variables

     D ucStamp         s               z

      /free

        if stampIn = noStamp;
          ucStamp = stampIn;
        else;
          ucStamp = stampIn + %hours(ucOffset);
        endif;

        return ucStamp;

      /end-free

     p CreateUC        e

     *----------------------------------------------------------------
     *  ClearFlags   Clear flag fields
     *----------------------------------------------------------------

     p ClearFlags      b
     d ClearFlags      pi

      /free

530aM   ClearIdFlags();

530aM   ClearTaskFlags();

        return;

      /end-free

     p ClearFlags      e

530aA*----------------------------------------------------------------
530aA*  ClearIdFlags    Clear identifier flags
530aA*
530aA*     These flags are used as transaction type identifiers.
530aA*     These will be set for every record in the PIRTRAND file.
530aA*     This will allow for summarizing values based on Id.
530aA*
530aA*----------------------------------------------------------------
530aA
530aAp ClearIdFlags    b
     d ClearIdFlags    pi

      /free

        ptdbegday = 0;
        ptdendday = 0;

640mA   ptdpick   = 0;

        ptddiri   = 0;
        ptdindi   = 0;
        ptdidlei  = 0;
        ptdvoicei = 0;

        ptdrcvi   = 0;
        ptdrcvdlti= 0;
        ptdrcvputi= 0;
        ptdstagei = 0;
        ptdrpli   = 0;
640oA   ptdrpltfi = 0;
        ptdtfri   = 0;
        ptdvfyi   = 0;
        ptdseli   = 0;
        ptdfixi   = 0;
        ptdpiri   = 0;
        ptdbulki  = 0;
        ptdrtni   = 0;
        ptdrtnputi= 0;
        ptdequipi = 0;
        ptdruni   = 0;
        ptdloadi  = 0;
        ptdotheri = 0;

        return;

      /end-free

     p ClearIdFlags    e

530aA*----------------------------------------------------------------
530aA*  ClearTaskFlags   Clear task flag fields
530aA*
530aA*     These flags are used as transaction counters. In the case
530aA*     where multiple PIRTRAND records are created for a single
530aA*     employee/transaction, only the first record will have a
530aA*     task flag set.
530aA*
530aA*----------------------------------------------------------------
530aA
530aAp ClearTaskFlags  b
     d ClearTaskFlags  pi

      /free

        ptddir    = 0;
        ptdind    = 0;
        ptdidle   = 0;
        ptdvoice  = 0;

        ptdrcv    = 0;
        ptdrcvdlt = 0;
        ptdrcvput = 0;
        ptdstage  = 0;
        ptdrpl    = 0;
640oA   ptdrpltf  = 0;
        ptdtfr    = 0;
        ptdvfy    = 0;
        ptdsel    = 0;
        ptdfix    = 0;
        ptdpir    = 0;
        ptdbulk   = 0;
        ptdrtn    = 0;
        ptdrtnput = 0;
        ptdequip  = 0;
        ptdrun    = 0;
        ptdload   = 0;
        ptdother  = 0;

        return;

      /end-free

     p ClearTaskFlags  e

530aA*----------------------------------------------------------------
530aA*  ClearValues      Clear value fields
530aA*----------------------------------------------------------------
530aA
530aAp ClearValues     b
     d ClearValues     pi

      /free

        ptdgrspcs = 0;
        ptdgrsmrg = 0;
640iA   ptdgrsblk = 0;
        ptdpcs    = 0;
        ptdmrgpcs = 0;
640iA   ptdblkpcs = 0;
        ptdlabels = 0;
        ptdmrglbls = 0;
640iA   ptdblklbls = 0;
        ptdslots  = 0;
640iA   ptdmrgzns = 0;
640iA   ptdblkzns = 0;

640hA   ptdnrmnv  = 0;
640hA   ptdmrgnv  = 0;

640xA   ptdcortran = 0;
640xA   ptdidlesec = 0;
640xA   ptdlabrsec = 0;

        return;

      /end-free

     p ClearValues     e

640pA*----------------------------------------------------------------
640pA*  DQClear     Clear data queue
640pA*----------------------------------------------------------------
640pA
640pAp DQClear         b
640pAd DQClear         pi

     C                   dou       dqlen = 0

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm      0             dqwait

     C                   enddo

     p DQClear         e

640pA*----------------------------------------------------------------
640pA*  DQRead      Read data queue
640pA*----------------------------------------------------------------
640pA
640pAp DQRead          b
640pAd DQRead          pi             1p 0

     *  Local Variables

     D tempWait        s              5p 0
     D waitValue       s              2p 0
     D value           s                   like(dqdata)

      /free

        // Convert sent wait time into seconds.

        tempWait = gWait * 60;

        // Start read loop for data queue

        dow forever = forever;

      /end-free

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm      tempWait      dqwait
     C                   parm      ' '           dqorder
     C                   parm      0             dqkeylen
     C                   parm      ' '           dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf

      /free

          // If nothing returned, proceed with processing.

          if dqlen = 0;
            return 0;
          endif;

          // Extract data.

          value = %subst(dqdata: 1 : dqlen);

          // If QUIT is sent, return -1 to get out of program.

          if value = 'QUIT';
            gMessage = 'DQ: ' + %trim(value) + '/' + %trim(dqJobName)
                     + '/' + %trim(dqUser) + '/' + %trim(dqJobNum)
                     + '/' + %trim(dqCurrUser);
            LogIt('Message');
            return -1;
          endif;

          // If WAIT is sent, change global wait value
          // Don't return because we want to clean up dtaq

          if %subst(value:1:4) = 'WAIT';
            gMessage = 'DQ: ' + %trim(value) + '/' + %trim(dqJobName)
                     + '/' + %trim(dqUser) + '/' + %trim(dqJobNum)
                     + '/' + %trim(dqCurrUser);
            LogIt('Message');
            if %subst(value:5:2) <> ' ';
              monitor;
                waitValue = %dec(%subst(value:5:2):2:0);
              on-error;
              endmon;
              if waitValue > 0;
                gWait = waitValue;
              endif;
            endif;
          endif;

          // If FORCE is sent there is nothing extra to do.
          // Don't return because we want to clean up dtaq
          // and we only want to process one FORCE command.

          if %subst(value:1:5) = 'FORCE';
            gMessage = 'DQ: ' + %trim(value) + '/' + %trim(dqJobName)
                     + '/' + %trim(dqUser) + '/' + %trim(dqJobNum)
                     + '/' + %trim(dqCurrUser);
            LogIt('Message');
          endif;

          // Temporarily change wait time to zero.
          // We want to clear out the queue so commands don't stack up.

          tempWait = 0;

        enddo;

      /end-free

     p DQRead          e

650gA*----------------------------------------------------------------
650gA*  FixEndTime    Fix end time. Called when start/end > 8 hours
650gA*
650gA*    This is only called when the length of a tran is greater
650gA*    than 8 hours. In that case, we assume the user did not check
650gA*    out with an ENDDAY and we either set the end TS to the end
650gA*    of the shift or to 1 minute.
650gA*
650gA*----------------------------------------------------------------
650gA
650gap FixEndTime      b
     d FixEndTime      pi
     d shift                          6    const
     d startTS                         z   const
     d endTS                           z   const
     d newEndTS                        z
     d newEndUC                        z

     *  Local Variables

     d shiftEndTS      s               z
     d shiftStartTS    s               z
     d startYMD        s              8s 0

      /free

710eA   // Return if task is a Production Module Standard Task
710eA   if tkcat = 'PROD';
710eA      exec sql select lcctyp into :wkctyp indicator :ictyp
710eA                from pLabCstLne
710eA              where lcempno=:ptemp#
710eA            fetch first row only;
710eA      if ictyp<>0 or sqlStt<>sqlSuccess;
710eA         wkctyp=*blanks;
710eA      endif;
710eA
710eA      if wkctyp='S';     //Standard Labor versus Actual clocks
710eA         return;
710eA      endif;

710eA   endif;

        // Get Shift record

        exec sql select * into :shrec
                 from shift
                 where shwhse = :gCurrWhse
                   and shwhdp = ' '
                   and shcode = :shift;

        // If Shift record not found, get out.
        // The end TS/UC should have been passed in as the 'new' values.

        if sqlstt <> sqlSuccess;
          return;
        endif;

        // Create Shift start/end timestamps

        startYMD = %dec(%date(startTS):*iso);
        shiftStartTS = CreateTS(startYMD: shstim);
        shiftEndTS = CreateTS(startYMD: shetim);

650iA     GetShiftInfo(ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

        // Adjust Shift end TS if shift over midnight

        if shetim < shstim;
          shiftEndTS += %days(1);
        endif;

        // If transaction started within Shift range,
        //   Then set newEndTS to end of Shift.
        //   Otherwise, trim transaction down to 1 minute.

650iD   //if startTS >= shiftStartTS and startTS <= shiftEndTS;
650iM   if startTS >= shiftStartTS and startTS <= shiftEndTS
650iA      and gbegdaystamp >= shiftStartTS
650iA      and gbegdaystamp <= shiftEndts;
          newEndTS = shiftEndTS;
        else;
          newEndTS = startTS + %minutes(1);
        endif;

        // Create UC

        newEndUC = CreateUC(newEndTS);
650iA   gbegdaystamp = nostamp;

        return;

      /end-free

     p FixEndTime      e

640wA*----------------------------------------------------------------
640wA*  GetAddStamp  Get Add timestamps
640wA*----------------------------------------------------------------
640wA
640wAp GetAddStamp     b
     d GetAddStamp     pi

      /free

         GetCurrStamp();
         ptdaddts = CurrStampSys;
         ptdadduc = CurrStampUC;

      /end-free

     p GetAddStamp     e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

530aA*----------------------------------------------------------------
530aA*  GetIndirect   Get Indirect time that overlaps transaction
530aA*----------------------------------------------------------------
530aA
530aAp GetIndirect     b
     d GetIndirect     pi
     d  sentSDte                      8s 0
     d  sentSTim                      6s 0
     d  sentEDte                      8s 0
     d  sentETim                      6s 0
     d  outSDte                       8s 0
     d  outSTim                       6s 0
     d  outEDte                       8s 0
     d  outETim                       6s 0
     d  outFound                       n
     d  outMoreFlag                    n

     *  Local Variables


      /free

        outSDte = 0;
        outSTim = 0;
        outEDte = 0;
        outETim = 0;
        outFound = *off;
        outMoreFlag = *off;

        //  Look for an Indirect task that falls with in the time
        //  of the current task.

        SqlStmt =
              'select * '
            + 'from pirtran a '
640qM       + 'where ptwhse = ' + %char(gCurrWhse) + ' '
            +   'and ptemp# = ' + %char(ptemp#) + ' '
            +   'and pttrn# <> ' + %char(pttrn#) + ' ';

        if sentSDte = sentEDte;
          SqlStmt = %trimr(sqlStmt) + ' '
            +   'and ptsdte=' + %char(sentSDte) + ' '
            +   'and ptstim>=' + %char(sentSTim) + ' '
            +   'and ptstim<=' + %char(sentETim) + ' '
            +   'and ptetim>=' + %char(sentSTim) + ' '
            +   'and ptetim<=' + %char(sentETim);
        else;
          SqlStmt = %trimr(sqlStmt) + ' '
            +   'and ('
            +         '('
            +          'ptsdte=' + %char(sentSDte) + ' '
            +          'and ptstim>=' + %char(sentSTim) + ' '
            +          'and ptedte=' + %char(sentEDte) + ' '
            +          'and ptetim<=' + %char(sentETim)
            +         ') '
            +         'or '
            +         '('
            +          'ptsdte=' + %char(sentSDte) + ' '
            +          'and ptstim>=' + %char(sentSTim) + ' '
            +          'and ptedte<' + %char(sentEDte)
            +         ') '
            +         'or '
            +         '('
            +          'ptsdte>' + %char(sentSDte) + ' '
            +          'and ptsdte<=' + %char(sentEDte) + ' '
            +          'and ptedte=' + %char(sentEDte) + ' '
            +          'and ptetim<=' + %char(sentETim)
            +         ') '
            +         'or '
            +         '('
            +          'ptsdte>' + %char(sentSDte) + ' '
            +          'and ptsdte<' + %char(sentEDte) + ' '
            +          'and ptedte>' + %char(sentSDte) + ' '
            +          'and ptedte<' + %char(sentEDte)
            +         ') '
            +       ') ';
        endif;

        SqlStmt = %trimr(sqlStmt) + ' '
640gA       +   'and exists (select tktype from task where tkcode=a.pttask '
640gA       +               'and tktype=' + sq + 'I' + sq + ') '
            + 'order by ptwhse, ptsdte, ptstim, pttrn# '
            + 'fetch first row only';


        exec sql prepare indsel from :SqlStmt;
        exec sql declare indcsr cursor for indsel;
        exec sql open indcsr;

        dow forever = forever;

          exec sql fetch next from indcsr
                   into :ptreci;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

640kA     // Ignore records where Start comes before End.
640kA
640kA     if ind_ptsdte > ind_ptedte
640kA       or ind_ptsdte = ind_ptedte
640kA       and ind_ptstim > ind_ptetim;
640kA         iter;
640kA     endif;

640kA     // Ignore records where Start is the same as End.
640kA
640kA     if ind_ptsdte = ind_ptedte
640kA       and ind_ptstim = ind_ptetim;
640kA         iter;
640kA     endif;

          // First time through set return fields and loop

          if not outFound;
            outFound = *on;
            outSDte = ind_ptsdte;
            outSTim = ind_ptstim;
            outEDte = ind_ptedte;
            outETim = ind_ptetim;
            iter;
          endif;

          // See if next Indirect task starts immediately
          // after previous Indirect task

          if ind_ptsdte = outEDte
             and ind_ptstim = outETim;
               outEDte = ind_ptedte;
               outETim = ind_ptetim;
               iter;
          endif;

          // Send back flag that there is another overlapping task.

          outMoreFlag = *on;
          leave;

        enddo;

        exec sql close indcsr;

        return;

      /end-free

     p GetIndirect     e

     *----------------------------------------------------------------
     *  GetLabelPcs   Get Pieces from Label file
     *----------------------------------------------------------------

     p GetLabelPcs     b
     d GetLabelPcs     pi
     d  outGrossPcs                   5p 0
     d  outGrossMrg                   5p 0
640iAd  outGrossBlk                   5p 0
     d  outPcs                        5p 0
     d  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0
     d  outLabels                     5p 0
     d  outMrgLabels                  5p 0
640iAd  outBlkLabels                  5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D count           s              5p 0
     D countInd        s              2b 0
     D aloc            s              5p 0
     D alocInd         s              2b 0
640iAD slots           s              5p 0
640iAD slotsInd        s              2b 0
640iAD zones           s              5p 0
640iAD zonesInd        s              2b 0

      /free

        // Calculate non-merge pcs

        exec sql select count(*), sum(lbqpck), sum(lbqalc),
640iA                   count(distinct lbwhdp || lbdisp)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :aloc :alocInd,
640iA                 :slots :slotsInd
                 from label
                 where lbtrn# = :pttrn#
730cA             and  lbwhse = :ptwhse
640tM              and (lbtype = 'O' or lbtype = 'B');
640tD              //and lbtype = 'O';

        select;
          when sqlstt <> sqlSuccess;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          when count = 0;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          other;
            outGrossPcs = aloc;
            outPcs = pcs;
            outLabels = count;
640iA       outSlots = slots;
        endsl;

640iM   // Calculate merge pcs not associated with Bulk pick

        exec sql select count(*), sum(m.lbqpck), sum(m.lbqalc),
640iA                   count(distinct m.lbwhdp || m.lbstyp)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :aloc :alocInd,
640iA                 :zones :zonesInd
                 from label as m
640iA            left outer join label b on b.lblbl# = m.lbctr#
730cA                                       and  b.lbwhse = m.lbwhse
                 where m.lbtrn# = :pttrn#
730cA             and  m.lbwhse = :ptwhse
                   and m.lbtype = 'M'
640iA              and b.lbtype <> 'B';

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          when count = 0;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          other;
            outGrossMrg = aloc;
            outMrgPcs = pcs;
            outMrgLabels = count;
640iA       outMrgZones = zones;
        endsl;

640iA   // Calculate merge pcs associated with Bulk pick
640iA
640iA   exec sql select count(*), sum(m.lbqpck), sum(m.lbqalc),
640iA                   count(distinct m.lbwhdp || m.lbstyp)
640iA            into :count :countInd,
640iA                 :pcs :pcsInd,
640iA                 :aloc :alocInd,
640iA                 :zones :zonesInd
640iA            from label as m
640iA            left outer join label b on b.lblbl# = m.lbctr#
730cA                                    and  b.lbwhse = m.lbwhse
640iA            where m.lbtrn# = :pttrn#
730cA             and  m.lbwhse = :pwhse
640iA              and m.lbtype = 'M'
640iA              and b.lbtype = 'B';
640iA
640iA   select;
640iA     when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     when count = 0;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     other;
640iA       outGrossBlk = aloc;
640iA       outBlkPcs = pcs;
640iA       outBlkLabels = count;
640iA       outBlkZones = zones;
640iA   endsl;

      /end-free

     p GetLabelPcs     e

640mA*----------------------------------------------------------------
640mA*  GetLabelPut   Get putawy info from label file
640mA*----------------------------------------------------------------
640mA
640mAp GetLabelPut     b
     d GetLabelPut     pi
     d  outGrossPcs                   5p 0
     d  outPcs                        5p 0
     d  outLabels                     5p 0
     d  outSlots                      5p 0
     d  outPick                       1s 0

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D count           s              5p 0
     D countInd        s              2b 0
     D aloc            s              5p 0
     D alocInd         s              2b 0
     D slots           s              5p 0
     D slotsInd        s              2b 0
     D pick            s              1
     D pickInd         s              2b 0

      /free

        exec sql select count(*), sum(lbqpck), sum(lbqalc),
                        count(distinct lbwhdp || lbdisp),
                        max(slpick)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :aloc :alocInd,
                      :slots :slotsInd,
                      :pick :pickInd
                 from label
                 left outer join slot
                      on slwhse=lbwhse and slwhdp=lbwhdp and sldisp=lbdisp
                 where lbtrn# = :pttrn#
730cA             and  lbwhse = :ptwhse;

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
            outSlots = 0;
            outPick = 0;
          when count = 0;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
            outSlots = 0;
            outPick = 0;
          other;
            outGrossPcs = aloc;
            outPcs = pcs;
            outLabels = count;
            outSlots = slots;
            if pick = 'Y';
              outPick = 1;
            else;
              outPick = 0;
            endif;
        endsl;

      /end-free

     p GetLabelPut     e

     *----------------------------------------------------------------
     *  GetMissedPcs   Get Pieces from Label file not in LabelDO file
     *----------------------------------------------------------------

     p GetMissedPcs    b
     d GetMissedPcs    pi
     d  outGrossPcs                   5p 0
     d  outGrossMrg                   5p 0
640iAd  outGrossBlk                   5p 0
     d  outPcs                        5p 0
     d  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0
     d  outLabels                     5p 0
     d  outMrgLabels                  5p 0
640iAd  outBlkLabels                  5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D count           s              5p 0
     D countInd        s              2b 0
     D aloc            s              5p 0
     D alocInd         s              2b 0
640iAD slots           s              5p 0
640iAD slotsInd        s              2b 0
640iAD zones           s              5p 0
640iAD zonesInd        s              2b 0

      /free

        // Calculate non-merge pcs not picked by voice

        exec sql select count(*), sum(lbqpck), sum(lbqalc),
640iA                   count(distinct lbwhdp || lbdisp)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :aloc :alocInd,
640iA                 :slots :slotsInd
                 from label
                 exception join labeldo on lbolbl#=lblbl# and lbotrn#=lbtrn#
730cA                                   and lbowhse = lbwhse
                 where lbtrn# = :pttrn#
730cA             and  lbwhse = :ptwhse
                   and lbtype = 'O';

        select;
          when sqlstt <> sqlSuccess;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          when count = 0;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          other;
            outGrossPcs = aloc;
            outPcs = pcs;
            outLabels = count;
640iA       outSlots = slots;
        endsl;

640iM   // Calculate merge pcs not picked via voice not associated with bulk pick

        exec sql select count(*), sum(m.lbqpck), sum(m.lbqalc),
640iA                   count(distinct m.lbwhdp || m.lbstyp)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :aloc :alocInd,
640iA                 :zones :zonesInd
                 from label m
                 exception join labeldo on lbolbl#=m.lblbl# and lbotrn#=m.lbtrn#
730cA                                    and lbowhse = m.lbwhse
640iA            left outer join label b on b.lblbl#=m.lbctr#
730cA                                    and b.lbwhse = m.lbwhse
                 where m.lbtrn# = :pttrn#
730cA             and  m.lbwhse = :ptwhse
                   and m.lbtype = 'M'
640iA              and b.lbtype <> 'B';

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          when count = 0;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          other;
            outGrossMrg = aloc;
            outMrgPcs = pcs;
            outMrgLabels = count;
640iA       // This will inflate zones if some were picked by voice.
640iA       // Therefore, don't calculate.
640iA       //outMrgZones = zones;
640iA       outMrgZones = 0;
        endsl;

640iA   // Calculate merge pcs not picked via voice associated with bulk pick
640iA
640iA   exec sql select count(*), sum(m.lbqpck), sum(m.lbqalc),
640iA                   count(distinct m.lbwhdp || m.lbstyp)
640iA            into :count :countInd,
640iA                 :pcs :pcsInd,
640iA                 :aloc :alocInd,
640iA                 :zones :zonesInd
640iA            from label m
640iA            exception join labeldo on lbolbl#=m.lblbl# and lbotrn#=m.lbtrn#
730cA                                      and lbowhse = m.lbwhse
640iA            left outer join label b on b.lblbl#=m.lbctr#
730cA                                   and  b.lbwhse = m.lbwhse
640iA            where m.lbtrn# = :pttrn#
730cA             and  m.lbwhse = :ptwhse
640iA              and m.lbtype = 'M'
640iA              and b.lbtype = 'B';
640iA
640iA   select;
640iA     when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     when count = 0;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     other;
640iA       outGrossBlk = aloc;
640iA       outBlkPcs = pcs;
640iA       outBlkLabels = count;
640iA       // This will inflate zones if some were picked by voice.
640iA       // Therefore, don't calculate.
640iA       //outBlkZones = zones;
640iA       outBlkZones = 0;
640iA   endsl;

      /end-free

     p GetMissedPcs    e

530aA*----------------------------------------------------------------
530aA*  GetPieces    Get pieces
530aA*----------------------------------------------------------------
530aA
530aAp GetPieces       b
     d GetPieces       pi
     d  sentEmp#                      5p 0
     d  sentRoutine                  30    const
640hAd sentInclMissed                  n
     d  sentStartTS                    z
     d  sentEndTS                      z
     d  outGrsPcs                     5p 0
     d  outGrSMrg                     5p 0
640iAd  outGrSBlk                     5p 0
     d  outPcs                        5p 0
     d  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0
     d  outLabels                     5p 0
     d  outMrgLbls                    5p 0
640iAd  outBlkLbls                    5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0
640mAd  outPick                       1s 0

     *  Local Variables

640hAd  misGrsPcs      s              5p 0
640hAd  misGrSMrg      s              5p 0
640iAd  misGrSBlk      s              5p 0
640hAd  misPcs         s              5p 0
640hAd  misMrgPcs      s              5p 0
640iAd  misBlkPcs      s              5p 0
640hAd  misLabels      s              5p 0
640hAd  misMrgLbls     s              5p 0
640iAd  misBlkLbls     s              5p 0
640iAd  misMrgZones    s              5p 0
640iAd  misBlkZones    s              5p 0
640iAd  misSlots       s              5p 0
650lAd  EPMGrs         s              5p 0
650lAd  EPMPcs         s              5p 0

      /free

640mA   outGrsPcs   = 0;
640mA   outGrSMrg   = 0;
640mA   outGrSBlk   = 0;
640mA   outPcs      = 0;
640mA   outMrgPcs   = 0;
640mA   outBlkPcs   = 0;
640mA   outLabels   = 0;
640mA   outMrgLbls  = 0;
640mA   outBlkLbls  = 0;
640mA   outMrgZones = 0;
640mA   outBlkZones = 0;
640mA   outSlots    = 0;
640mA   outPick     = 0;
650lA   EPMGrs      = 0;
650lA   EPMPcs      = 0;

        // For a selection transaction,

        select;

640uA     when ptdtask = 'IDLE';
640uA       // Leave pcs zero.
640uA
          when sentRoutine = 'WrtNewDetail3';
640mA       if ptdrcvput = 1 or ptdrtnput = 1;
640mM         GetLabelPut(outgrspcs: outpcs: outlabels: outslots: outpick);
640mM       else;
              outgrspcs = ptpcs;
              outpcs = ptpcs;
640mM       endif;
            // calculate EPM Pcs
650lA       if ptdrcvput = 1 or ptdrtnput = 1 or
650lA          ptdstage = 1 or ptdrpl = 1 or
650lA          ptdrpltf = 1 or ptdtfr = 1;
650lA         getepmpcs(ptdwhse:ptdtran:outgrspcs:outpcs:EPMGrs:EPMPcs);
650la         outgrspcs = EPMGrs;
650la         outpcs = EPMPcs;
            endif;

          when sentRoutine = 'WrtSelNoVoice';
640iM       GetLabelPcs(outgrspcs: outgrsmrg: outgrsblk:
640iM                   outpcs: outmrgpcs: outblkpcs:
640iM                   outlabels: outmrglbls: outblklbls:
640iM                   outMrgZones: outBlkZones: outSlots);

          when sentRoutine = 'WrtVoicePass';
720aA       sentEndTS=sentEndTS + %MSECONDS(999999);
            GetVoicePcs(sentemp#: sentStartTS: sentEndTS:
640iM                   outgrspcs: outgrsmrg: outgrsblk:
640iM                   outpcs: outmrgpcs: outblkpcs:
640iM                   outlabels: outmrglbls: outblklbls:
640iM                   outMrgZones: outBlkZones: outSlots);

          when sentRoutine = 'WrtVoiceTran';
720aA       sentEndTS=sentEndTS + %MSECONDS(999999);
            GetVoicePcs(sentemp#: sentStartTS: sentEndTS:
640iM                   outgrspcs: outgrsmrg: outgrsblk:
640iM                   outpcs: outmrgpcs: outblkpcs:
640iM                   outlabels: outmrglbls: outblklbls:
640iM                   outMrgZones: outBlkZones: outSlots);
640hA       if sentInclMissed;
640iM          GetMissedPcs(misgrspcs: misgrsmrg: misgrsblk:
640iM                       mispcs: mismrgpcs: misblkpcs:
640iM                       mislabels: mismrglbls: misblklbls:
640iM                       misMrgZones: misBlkZones: misSlots);
640hA          outgrspcs += misgrspcs;
640hA          outgrsmrg += misgrsmrg;
640iA          outgrsblk += misgrsblk;
640hA          outpcs    += mispcs;
640hA          outmrgpcs += mismrgpcs;
640iA          outblkpcs += misblkpcs;
640hA          outlabels += mislabels;
640hA          outmrglbls += mismrglbls;
640iA          outblklbls += misblklbls;
640iA          outMrgZones += misMrgZones;
640iA          outBlkZones += misBlkZones;
640iA          outSlots  += misSlots;
640hA          if mispcs > 0;
640hA            ptdnrmnv = 1;
640hA          endif;
640hA          if mismrgpcs > 0;
640hA            ptdmrgnv = 1;
640hA          endif;
640hA          sentInclMissed = *off;
640hA       endif;

        endsl;

        return;

      /end-free

     p GetPieces       e

640eA*----------------------------------------------------------------
640eA*  GetShiftValues   Get Shift values
640eA*----------------------------------------------------------------
640eA
640eap GetShiftValues  b
     d GetShiftValues  pi
     d shift                          6    const
650fAd task                           6    const
     d startTS                         z   const
     d shiftDay                       6s 0
     d shiftDOW                       1s 0
     d shiftWeek                      2s 0
     d shiftSunday                    6s 0

     *  Local Variables

     d overMidnight    s               n
     d startDate       s               d
     d startTime       s              6s 0
     d sundayDate      s               d

      /free

        // Get Shift record when shift changes

        if shift <> gLastShift;

          exec sql select * into :shrec
                   from shift
640qM              where shwhse = :gCurrWhse
                     and shwhdp = ' '
                     and shcode = :shift;

          if sqlstt <> sqlSuccess;
            shstim = 0;
            shetim = 240000;
          endif;

          gLastShift = shcode;
          gLastShftSTim = shstim;
          gLastShftETim = shetim;

        endif;

        // Determine shift date

        startDate = %date(startTS);

        if gLastShftETim < gLastShftSTim;
          overMidnight = *on;
        else;
          overMidnight = *off;
        endif;

        if overMidnight;
          startTime = %dec(%time(startTS):*hms);
650hD     //if task <> 'BEGDAY';
            if startTime <= gLastShftETim;
              startDate -= %days(1);
650fD         //if shift <> 'SHIFT3';
650fD           //startDate = startDate;
650fD         //endif;
            endif;
650hD     //endif;
        endif;

        shiftDay = %dec(startDate:*ymd);

        exec sql set :shiftWeek = week(:startDate),
                     :shiftDOW  = dayofweek(:startDate);

        sundayDate = startDate - %days(shiftDOW-1);
        shiftSunday = %dec(sundayDate:*ymd);

        return;

      /end-free

     p GetShiftValues  e

     *----------------------------------------------------------------
     *  GetShiftInfo  Get Shift Day, Day of week, week, sunday date
     *----------------------------------------------------------------

     p GetShiftInfo    b
     d GetShiftInfo    pi
     d shiftDay                       6s 0
     d shiftDOW                       1s 0
     d shiftWeek                      2s 0
     d shiftSunday                    6s 0

     *  Local Variables

     d begdayStamp     s               z
     D begdayHours     s              5p 0
     D begdayInd       s              2b 0
     D begdayTrn#      s              7p 0
     d enddayStamp     s               z
     D enddayInd       s              2b 0
     d pttranStart     s               z
     d sundayStamp     s               z
700aAd lsttrnStamp     s               z
700aAD lsttrnInd       s              2b 0
700AAD lsttrnHours     s              5p 0

      /free

        shiftDay = 0;
        shiftWeek = 0;
        shiftDOW = 0;
        shiftSunday = 0;

        // Nothing to do if there is no start date.

        if ptdsts = noStamp;
          return;
        endif;

        pttranStart = ptdsts;

        // Get the last BEGDAY for employee

        if ptdtask = 'BEGDAY';
          exec sql select max(ptdsts) into :begdayStamp :begdayInd
                   from pirtrand
                   where ptdwhse = :ptdwhse
                     and ptdempnum = :ptdempnum
                     and ptdtask = 'BEGDAY'
                     and ptdsts < :pttranStart;
        else;
          exec sql select max(ptdsts) into :begdayStamp :begdayInd
                   from pirtrand
                   where ptdwhse = :ptdwhse
                     and ptdempnum = :ptdempnum
                     and ptdtask = 'BEGDAY'
                     and ptdsts <= :pttranStart;
        endif;

        if sqlstt <> sqlSuccess or begdayInd < 0;
          begdayStamp = noStamp;
          begdayHours = *hival;
        else;
          begdayHours = CalcHours(begdayStamp: pttranStart);
        endif;

        // Get the last ENDDAY for employee

        if ptdtask = 'ENDDAY';
          enddayStamp = pttranStart;
        else;
          exec sql select max(ptdsts) into :enddayStamp :enddayInd
                   from pirtrand
                   where ptdwhse = :ptdwhse
                     and ptdempnum = :ptdempnum
                     and ptdtask = 'ENDDAY'
                     and ptdsts <= :pttranStart;

          if sqlstt <> sqlSuccess or enddayInd < 0;
            enddayStamp = noStamp;
          endif;
        endif;

        // If a BEGDAY isn't found, then create it.

        if begdayStamp = noStamp;
          if ptdtask = 'BEGDAY';
            begdayStamp = pttranStart;
          else;
            begdayStamp = CreateBegDay();
          endif;
          begdayHours = 0;
        endif;

        // If a ENDDAY isn't found, then create it.

        if enddayStamp = noStamp;
          enddayStamp = CreateEndDay(begdayStamp);
        endif;

        // Now we know we have a BEGDAY and possibly a ENDDAY.
        // So now we see if we are missing a BEGDAY or ENDAY.

        select;

          // If we are working with an ENDDAY record,
          //   nothing is missing.

          when ptdtask = 'ENDDAY';

          // If a BEGDAY comes before ENDDAY,
          //   We are missing a BEGDAY.

          when begdayStamp < enddayStamp;
            if ptdtask = 'BEGDAY';
              begdayStamp = pttranStart;
            else;
              begdayStamp = CreateBegDay();
            endif;

          // Now we know the BEGDAY comes after the ENDDAY.
          // If BEGDAY is 12 hours old,
          //   We assume we are missing an ENDDAY and BEGDAY.
640kA     // If pttranStart ends up being the same as the end date/time
640kA     // of the previous transaction,
640kA     //   Then an ENDDAY won't be created, so we don't want to
640kA     //   create a BEGDAY.
700aA     //   Enhanced logic for creating endday/begday transactions
700aA     //   We now check for the users last transaction.
700aA     //   if that transaction start time is >= 4 hours from the
700aA     //   current transaction then do the endday/begday creation.

          when begdayHours >= 12;
700aA       // lets grab the last transaction
700aA       exec sql select max(ptdsts) into :lsttrnStamp :lsttrnInd
700aA                from pirtrand
700aA                where ptdwhse = :ptdwhse
700aA                  and ptdempnum = :ptdempnum
700aA                  and ptdsts < :pttranStart;

700aA       if sqlstt <> sqlSuccess or lsttrnInd < 0;
700aA         lsttrnStamp = noStamp;
700aA       endif;
700aA       lsttrnHours = CalcHours(lsttrnStamp: pttranStart);

700aA       if lsttrnhours >= 4;
              enddayStamp = CreateEndDay(pttranStart);
              if ptdtask = 'BEGDAY';
                begdayStamp = pttranStart;
              else;
640kA           if enddayStamp <> nostamp;
                  begdayStamp = CreateBegDay();
640kA           endif;
              endif;
700aA       endif;

        endsl;

        // Now that we have the BEGDAY/ENDAY's taken care of,
        // we can calculate the Shift values.

        if begdayStamp = noStamp;
          shiftDay = 0;
          shiftWeek = 0;
          shiftDOW = 0;
          shiftSunday = 0;
        else;
650fD     //GetShiftValues(ptdshft: begdayStamp:
650fM     GetShiftValues(ptdshft: ptdtask: begdayStamp:
640eA                    ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

640eD     //shiftDay = %dec(%date(begdayStamp):*ymd);

640eD     //exec sql set :shiftWeek = week(:begdayStamp),
640eD     //             :shiftDOW  = dayofweek(:begdayStamp);

640eD     //sundayStamp = begdayStamp - %days(shiftDOW-1);
640eD     //shiftSunday = %dec(%date(sundayStamp):*ymd);
        endif;

640kA   // When working with an ENDDAY task,
640kA   //   Then calculate total seconds for the day.
640kA
640kA   if ptdtask = 'ENDDAY';
640kA     if begdayStamp <> noStamp;
640kA       ptdsec = CalcSeconds(begdayStamp: enddayStamp);
640kA     endif;
640kA   endif;

650iA   gbegdaystamp = begdaystamp;
        return;

      /end-free

     p GetShiftInfo    e

530aA*----------------------------------------------------------------
530aA*  GetSimCount   Get simultaneous transaction count
530aA*----------------------------------------------------------------
530aA
530aAp GetSimCount     b
     d GetSimCount     pi             5p 0

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0

      /free

640uA   // If start/end date/time are zero, return 1.
640uA
640uA   if ptsdte=0 and ptstim=0 and ptedte=0 and ptetim=0;
640uA     count = 1;
640uA     return count;
640uA   endif;
640uA
        // Calculate non-merge pcs picked via voice

        exec sql select count(*)
                 into :count :countInd
                 from pirtran
                 where ptemp# = :ptemp#
730cA             and  ptwhse = :ptwhse
                   and ptsdte = :ptsdte
                   and ptstim = :ptstim
                   and ptedte = :ptedte
                   and ptetim = :ptetim;

        if sqlstt <> sqlSuccess;
          count = 1;
        endif;

640uA   // Protect against extra large sim count.
640uA
640uA   if count > 999;
640uA     count = 999;
640uA   endif;
640uA
        return count;

      /end-free

     p GetSimCount     e

     *----------------------------------------------------------------
     *  GetVoicePcs   Get Pieces picked with voice
     *----------------------------------------------------------------

     p GetVoicePcs     b
     d GetVoicePcs     pi
     d  sentEmp#                      5p 0 const
     d  sentStartTS                    z   const
     d  sentEndTS                      z   const
     d  outGrossPcs                   5p 0
     d  outGrossMrg                   5p 0
640iAd  outGrossBlk                   5p 0
     d  outPcs                        5p 0
     d  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0
     d  outLabels                     5p 0
     d  outMrgLabels                  5p 0
640iAd  outBlkLabels                  5p 0
640iAd  outMrgZones                   5p 0
640iAd  outBlkZones                   5p 0
640iAd  outSlots                      5p 0

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D count           s              5p 0
     D countInd        s              2b 0
     D short           s              5p 0
     D shortInd        s              2b 0
640iAD slots           s              5p 0
640iAD slotsInd        s              2b 0
640iAD zones           s              5p 0
640iAD zonesInd        s              2b 0

      /free

        // Calculate non-merge pcs picked via voice

        exec sql select count(*), sum(lboqty), sum(lboqtys),
640iA                   count(distinct lbwhdp || lbdisp)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :short :shortInd,
640iA                 :slots :slotsInd
                 from labeldo
                 left outer join label on lblbl# = lbolbl#
730cA                                 and lbwhse = lbowhse
                 where lbotrn# = :pttrn#
730cA             and  lbowhse = :ptwhse
                   and lboemp# = :sentEmp#
650aD              //and lboltype = 'O'
650aM              and (lboltype = 'O' or lboltype = 'B')
                   and lboaddts >= :sentStartTS
                   and lboaddts <= :sentEndTS;

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          when count = 0;
            outGrossPcs = 0;
            outPcs =0;
            outLabels = 0;
640iA       outSlots = 0;
          other;
            outGrossPcs = pcs + short;
            outPcs = pcs;
            outLabels = count;
640iA       outSlots = slots;
        endsl;

640iA   // Calculate merge pcs picked via voice not associated with bulk pick

        exec sql select count(*), sum(lboqty), sum(lboqtys),
640iA                   count(distinct lbozone)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :short :shortInd,
640iA                 :zones :zonesInd
                 from labeldo
640iA            left outer join label m on m.lblbl# = lbolbl#
730cA                                   and m.lbwhse = lbowhse
640iA            left outer join label b on b.lblbl# = m.lbctr#
730cA                                   and b.lbwhse = m.lbwhse
                 where lbotrn# = :pttrn#
730cA             and  lbowhse = :ptwhse
                   and lboemp# = :sentEmp#
                   and lboltype = 'M'
                   and lboaddts >= :sentStartTS
                   and lboaddts <= :sentEndTS
640iA              and b.lbtype <> 'B';

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          when count = 0;
            outGrossMrg = 0;
            outMrgPcs =0;
            outMrgLabels = 0;
640iA       outMrgZones = 0;
          other;
            outGrossMrg = pcs + short;
            outMrgPcs = pcs;
            outMrgLabels = count;
640iA       outMrgZones = zones;
        endsl;

640iA   // Calculate merge pcs picked via voice associated with bulk pick
640iA
640iA   exec sql select count(*), sum(lboqty), sum(lboqtys),
640iA                   count(distinct lbozone)
640iA            into :count :countInd,
640iA                 :pcs :pcsInd,
640iA                 :short :shortInd,
640iA                 :zones :zonesInd
640iA            from labeldo
640iA            left outer join label m on m.lblbl# = lbolbl#
730cA                                   and m.lbwhse = lbowhse
640iA            left outer join label b on b.lblbl# = m.lbctr#
730cA                                   and b.lbwhse = m.lbwhse
640iA            where lbotrn# = :pttrn#
730cA             and  lbowhse = :ptwhse
640iA              and lboemp# = :sentEmp#
640iA              and lboltype = 'M'
640iA              and lboaddts >= :sentStartTS
640iA              and lboaddts <= :sentEndTS
640iA              and b.lbtype = 'B';
640iA
640iA   select;
640iA     when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     when count = 0;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA       outBlkLabels = 0;
640iA       outBlkZones = 0;
640iA     other;
640iA       outGrossBlk = pcs + short;
640iA       outBlkPcs = pcs;
640iA       outBlkLabels = count;
640iA       outBlkZones = zones;
640iA   endsl;

      /end-free

     p GetVoicePcs     e

640pA*----------------------------------------------------------------
640pA*  GetNextWhse    Get next warehouse to use
640pA*----------------------------------------------------------------
640pA
640pAp GetNextWhse     b
640pAd GetNextWhse     pi             3  0

     *  Local Variables

     d zone            s              6

      /free

640yA   // Don't read multiple warrehouse records unnecessarily.

640yA   if gWhse > 0;
640yA     if gCurrWhse > 0;
640yA       return -1;
640yA     else;
640yA       return gWhse;
640yA     endif;
640yA   endif;

        // First time through, initialize cursor.

        if gCurrWhse = 0;
          SqlStmt = 'select * from warehs order by whcode';
          exec sql prepare whssel from :SqlStmt;
          exec sql declare whscsr cursor for whssel;
          exec sql open whscsr;
        endif;

        // Get next warehouse record.

        dow forever = forever;
          exec sql fetch next from whscsr
                   into :whrec;

          if sqlstt <> sqlSuccess;
            exec sql close whscsr;
            whcode = -1;
            leave;
          endif;

          // If a warehouse was sent into the program,
          //   Then we only want to work with that warehouse.

          if gWhse > 0 and whcode <> gWhse;
            iter;
          endif;

          leave;
        enddo;

        return whcode;

      /end-free

     p GetNextWhse     e

     *----------------------------------------------------------------
     *  GetZone       Get zone
     *----------------------------------------------------------------

     p GetZone         b
     d GetZone         pi             6

     *  Local Variables

     d zone            s              6

      /free

        // Note, with these selection fields, SQL should
        // use WORKLB94 for the access path.

        exec sql select lwszon into :zone
                 from worklbl
640qA            where lwwhse = :ptwhse
640qA              and lwrte  = :ptrtpo
640qM              and lwtrn# = :pttrn#
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess or zone = ' ';
          zone = ptwhdp;
        endif;

        return zone;

      /end-free

     p GetZone         e

640pA*----------------------------------------------------------------
640pA*  LogCleanup   Keep log clean
640pA*----------------------------------------------------------------
640pA
640pAp LogCleanup      b
     d LogCleanup      pi
     d  cmd                          10    const

     *  Local Variables

640fAd beginDate       s               z
640fAd tempDate        s               d
     d weeksToKeep     s              2  0

      /free

        // Remove any records before a certain date

        if cmd = 'Date';
          weeksToKeep = 2;
          GetCurrStamp();
640fA     tempDate = %date(currstampsys) - %days(weeksToKeep*7);
640fA     //beginDate = %char(%dec(tempDate:*iso));
640fA     beginDate = %timestamp(tempDate);
          exec sql delete from logtrand
                   where ltdttlbeg < :beginDate;
          if sqlstt <> sqlSuccess;
          endif;
        endif;

        // Remove any records where all 'record' fields are zero.
        // This would mean nothing was done when program ran, so no need to keep them.

        if cmd = 'Zero';
          exec sql delete from logtrand
                   where ltdupdadd=0 and ltdupdupd=0
                     and ltdupddel=0 and ltdnewrec=0
                     and ltdshfrec=0;
          if sqlstt <> sqlSuccess;
          endif;
        endif;

        return;

      /end-free

     p LogCleanup      e

640dA*----------------------------------------------------------------
640dA*  LogIt     Write/Update log record
640dA*----------------------------------------------------------------
640dA
640dAp LogIt           b
     d LogIt           pi
     d  cmd                          10    const

     *  Local Variables

     d zone            s              6
     d saveStamploc    s               z
     d saveStampsys    s               z
     d saveStampuc     s               z
     d nowSys          s               z
     d nowUC           s               z

      /free

        // Get current stamp

        GetCurrStamp();

640pA   if cmd = 'Message';
640pA     clear ltdrec;
640pA     ltdnewrec = 1;
640pA     ltdmsg = gMessage;
640pA     ltdttlbeg = currStampSys;
640pA     ltdttlbegu = currStampUC;
640pA     ltduser = #user;
640pA     ltdjob = #job;
640pA     ltdjobnbr = #jobnbr;
640pA     exec sql insert into logtrand values(:ltdrec);
640pA     if sqlstt <> sqlSuccess;
640pA     endif;
640pA     return;
640pA   endif;

        if cmd = 'MainStart';
          clear ltdrec;
640pA     ltdmsg = cmd;
640pA     ltdwhse = gCurrWhse;
          ltdttlbeg = startStampsys;
          ltdttlbegu = startStampuc;
          ltduser = #user;
          ltdjob = #job;
          ltdjobnbr = #jobnbr;
          exec sql insert into logtrand values(:ltdrec);
          if sqlstt <> sqlSuccess;
          endif;
          return;
        endif;

        // Get log record

        exec sql select * into :ltdrec
                 from logtrand
                 where ltdttlbegu = :startStampuc
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          return;
        endif;

        // Update appropriate fields

        select;
          when cmd = 'MainEnd';
            ltdttlend = currStampSys;
            ltdttlendu = currStampUC;
            ltdttlsec = CalcSeconds(ltdttlbegu: ltdttlendu);
          when cmd = 'NewStart';
            ltdnewbeg = currStampSys;
            ltdnewbegu = currStampUC;
          when cmd = 'NewEnd';
            ltdnewend = currStampSys;
            ltdnewendu = currStampUC;
            ltdnewsec = CalcSeconds(ltdnewbegu: ltdnewendu);
640pA       ltdnewrec = gRecsAdded;
          when cmd = 'ShiftStart';
            ltdshfbeg = currStampSys;
            ltdshfbegu = currStampUC;
          when cmd = 'ShiftEnd';
            ltdshfend = currStampSys;
            ltdshfendu = currStampUC;
            ltdshfsec = CalcSeconds(ltdshfbegu: ltdshfendu);
640pA       ltdshfrec = gRecsShift;
          when cmd = 'UpdStart';
            ltdupdbeg = currStampSys;
            ltdupdbegu = currStampUC;
          when cmd = 'UpdEnd';
            ltdupdend = currStampSys;
            ltdupdendu = currStampUC;
            ltdupdsec = CalcSeconds(ltdupdbegu: ltdupdendu);
640pA       ltdupddel = gRecsDeleted;
640pA       ltdupdupd = gRecsUpdated;
640pA       ltdupdadd = gRecsAdded;
        endsl;

        // Update record

641aA     if pCmd = '*ONETRAN';
641bA       gSentSec  = CalcSeconds(gSentTS: ltdttlend);
641bM       ltdmsg = %trim(gmessage) + '/' + %char(gSentSec);
641aA     else;
            ltdmsg = cmd;
641aA     endif;
          exec sql update logtrand set
                     ltdmsg     = :ltdmsg,
                     ltdttlend  = :ltdttlend,
                     ltdttlendu = :ltdttlendu,
                     ltdttlsec  = :ltdttlsec,
                     ltdupdbeg  = :ltdupdbeg,
                     ltdupdbegu = :ltdupdbegu,
                     ltdupdend  = :ltdupdend,
                     ltdupdendu = :ltdupdendu,
                     ltdupdsec  = :ltdupdsec,
640pA                ltdupddel  = :ltdupddel,
640pA                ltdupdupd  = :ltdupdupd,
640pA                ltdupdadd  = :ltdupdadd,
                     ltdnewbeg  = :ltdnewbeg,
                     ltdnewbegu = :ltdnewbegu,
                     ltdnewend  = :ltdnewend,
                     ltdnewendu = :ltdnewendu,
                     ltdnewsec  = :ltdnewsec,
640pA                ltdnewrec  = :ltdnewrec,
                     ltdshfbeg  = :ltdshfbeg,
                     ltdshfbegu = :ltdshfbegu,
                     ltdshfend  = :ltdshfend,
                     ltdshfendu = :ltdshfendu,
                     ltdshfsec  = :ltdshfsec,
640pA                ltdshfrec  = :ltdshfrec
                 where ltdttlbegu = :startStampuc;

        if sqlstt <> sqlSuccess;
        endif;

        return;

      /end-free

     p LogIt           e

     *----------------------------------------------------------------
     *  SetFlags     Set flag fields
     *----------------------------------------------------------------

     p SetFlags        b
     d SetFlags        pi

      /free

        // First clear all the flags

        ClearFlags();

        // Next, get the corresponding Task record

        exec sql select * into :tkrec
                 from  task
                 where tkcode = :pttask
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          tktype = 'I';
        endif;

        // Now set the flags

        if pttask = 'IDLE';
          ptdidle = 1;
530aA     ptdidlei = 1;
          return;
        endif;

        if pttask = 'BEGDAY';
          ptdbegday = 1;
          return;
        endif;

        if pttask = 'ENDDAY';
          ptdendday = 1;
          return;
        endif;

        if tktype = 'D';
          ptddir = 1;
530aA     ptddiri = 1;
        else;
          ptdind = 1;
530aA     ptdindi = 1;
        endif;

        if pttask = 'PUTEMP';
          ptdrcvput = 1;
530aA     ptdrcvputi = 1;
          return;
        endif;

        if pttask = 'PUTSTG';
          ptdstage = 1;
530aA     ptdstagei = 1;
          return;
        endif;

        if pttask = 'PUTRTN';
          ptdrtnput = 1;
530aA     ptdrtnputi = 1;
          return;
        endif;

640oD   //if %subst(pttask:1:4) = 'REPL';
640oM   if pttask = 'REPL';
640iA     if ptpcs > 0;
            ptdrpl = 1;
640iA     endif;
530aA     ptdrpli = 1;
          return;
        endif;

640oA   if pttask = 'REPLTF';
640oA     if ptpcs > 0;
640oA       ptdrpltf = 1;
640oA     endif;
640oA     ptdrpltfi = 1;
640oA     return;
640oA   endif;

        if pttask = 'TFRMOV';
          ptdtfr = 1;
530aA     ptdtfri = 1;
          return;
        endif;

        if pttask = 'VERIFY';
          ptdvfy = 1;
530aA     ptdvfyi = 1;
          return;
        endif;

        if %subst(pttask:1:4) = 'BULK';
          ptdbulk = 1;
530aA     ptdbulki = 1;
          ptdsel = 1;
530aA     ptdseli = 1;
          return;
        endif;

        if pttask = 'FIXED';
          ptdfix = 1;
530aA     ptdfixi = 1;
          ptdsel = 1;
530aA     ptdseli = 1;
          return;
        endif;

        if pttask = 'PIR';
          ptdpir = 1;
530aA     ptdpiri = 1;
          ptdsel = 1;
530aA     ptdseli = 1;
          return;
        endif;

        if pttask = 'EQCHK';
          ptdequip = 1;
530aA     ptdequipi = 1;
          return;
        endif;

        if pttask = 'RUNNER';
          ptdrun = 1;
530aA     ptdruni = 1;
          return;
        endif;

        if pttask = 'LOAD';
          ptdload = 1;
530aA     ptdloadi = 1;
          return;
        endif;

650eA   if pttask = 'RCVPO';
650eA     ptdrcv = 1;
650eA     ptdrcvi = 1;
650eA     return;
650eA   endif;

650eA   if pttask = 'RCVRTN';
650eA     ptdrtn = 1;
650eA     ptdrtni = 1;
650eA     return;
650eA   endif;

        ptdother = 1;
530aA   ptdotheri = 1;

        return;

      /end-free

     p SetFlags        e

640yA*----------------------------------------------------------------
640yA*  ClearFile    Delete all records for whse Start up or Testing
640yA*----------------------------------------------------------------

640yAp ClearFile       b
640yAd ClearFile       pi
640yAd  Clrwhse                       3  0

640yA /free

640yA   // Delete PIRTRAND for Warehouse Startup.

640yA   exec sql delete from pirtrand
640yA    where ptdwhse = :clrwhse;

640yA   if sqlstt <> sqlSuccess;
640yA   endif;

640yA   return;

640yA /end-free

640yAp ClearFile       e

640yA*----------------------------------------------------------------
640yA*  CleanUp      Delete transaction as part of system cleanup.
640yA*----------------------------------------------------------------

640yAp CleanUp         b
640yAd CleanUp         pi

640yA /free

640yA   // Delete PIRTRAND for Warehouse Startup.

640yA   exec sql delete from pirtrand
710bD    //where ptdtran = :gTran#;
710bM    where ptdtran = :gTran#
730cA      and ptdwhse = :gCurrWhse
710bA      and ptdgdte = :gFromDate;

640yA   if sqlstt <> sqlSuccess;
640yA   endif;

640yA   return;

640yA /end-free

640yAp CleanUp         e

730bA*----------------------------------------------------------------
730bA*  SteppedOnTran  copy and Update PIRTRAND records
730bA*----------------------------------------------------------------

730bAp SteppedOnTran   b
730bAd SteppedOnTran   pi

730bA*  Local Variables

730bAD tempDate        s               d

730bA /free

730bA   // setup date/time passed in
730bA     nsStamp  =  CreateTS(gnsDate: gnsTime);
730bA     neStamp  =  CreateTS(gneDate: gneTime);
730bA     neStampUC = CreateUC(neStamp);
730bA     nsStampUC = CreateUC(nsStamp);

730bA       SqlStmt = 'select * '
730bA               + 'from pirtrand '
730bA               + 'where ptdwhse = ' + %char(gCurrWhse) + ' '
730bA               +   'and ptdtran = ' + %char(gTran#);

730bA   exec sql prepare upddetlsel1 from :SqlStmt;
730bA   exec sql declare upddetlcsr1 dynamic scroll cursor for upddetlsel1;
730bA   exec sql open upddetlcsr1;

730bA   dow forever = forever;

730bA     exec sql fetch next from upddetlcsr1
730bA              into :ptdrec;

730bA     if sqlstt <> sqlSuccess;
730bA       leave;
730bA     endif;

730bA     // Ignore records in PIRTRAND with status 'B' 'U' 'X'
730bA     // These records are showing an odd occurance

730bA     if (ptdstat < '0');
730bA       iter;
730bA     endif;

730bA     // need to ensure this is the correct record to update.
730bA     // the dates sent in must fall between the start and end of
730bA     // this record.
730bA     select;
730bA       when nsstamp <= ptdsts;
730bA         iter;
730bA       when nestamp >= ptdets;
730bA         iter;
730bA     endsl;

730bA     // now save the ptdsts and ptests in hold fields for the new
730bA     // record I will need to add
730bA     hsstamp = ptdsts;
730bA     hestamp = ptdets;
730bA     hsStampUC = ptdsuc;
730bA     heStampUC = ptdeuc;

730bA     eval(h) ptdsec = CalcSeconds(ptdsts: nsStamp) / ptdsimtran;

730bA     // now update the end date to be the start date sent in
730bA     exec sql update pirtrand set
730bA                ptdets     = :nsStamp,
730bA                ptdeuc     = :nsStampuc,
730bA                ptdsec     = :ptdsec,
730bA                ptdchgts   = :startstampsys,
730bA                ptdchguc   = :startstampuc,
730bA                ptdchgusr  = :#user,
730bA                ptdchgjob  = :#job,
730bA                ptdchgnbr  = :#jobnbr
730bA              where ptdtran = :ptdtran
730cA                  and ptdwhse = :ptdwhse
730bA                  and ptdsts = :hsstamp
730bA                  and ptdets = :hestamp
730bA                  and ptdstat not in ('B','U','X');

730bA     gRecsUpdated += 1;

730bA     // what do I need to load up before adding the new one
730bA     //this should have the new start time, what about pieces and
730bA     // flags to know if it should be counted as another trans.
730bA     ptdsts = nestamp;
730bA     ptdsuc = nestampUC;
730bA     ptdets = hestamp;
730bA     ptdeuc = hestampUC;
730bA     ClearTaskFlags();
730bA     ClearValues();
730bA     eval(h) ptdsec = CalcSeconds(ptdsts: ptdets) / ptdsimtran;

730bA     exec sql insert into pirtrand values(:ptdrec);
730bA     leave;

730bA   enddo;

730bA   exec sql close upddetlcsr1;

730bA   return;

730bA /end-free

730bAp SteppedOnTran   e

     *----------------------------------------------------------------
     *  UpdDetail    Upadate PIRTRAND records
     *----------------------------------------------------------------

     p UpdDetail       b
     d UpdDetail       pi

     *  Local Variables

     D threeMonthsAgo  s              8p 0
     D tempDate        s               d

      /free

640pA   gRecsAdded = 0;
640pA   gRecsUpdated = 0;
640pA   gRecsDeleted = 0;
760 A   go12To3 = *off;

        // Grab recs where status changed.
        // Limiting updates to last 3 months for speed reasons.
        // The main reason for this update is to add transaction detail
        // for transactions that were open (1 or 2) the last time this
        // was run. Transactions that were a status 2 should be moved
        // to a 3 within 3 months.

        threeMonthsAgo = %dec(%date(startStampSys-%months(3)):*iso);

640yA   select;
640yA     when gTran# > 0;
640yA       SqlStmt = 'select * '
640yA               + 'from pirtran '
640yA               + 'inner join pirtrand '
640yA               +   'on ptdtran = pttrn# '
730cA               +     'and ptdwhse = ptwhse '
640yA               +     'and ptdgdte=ptgdte and ptdgtim=ptgtim '
640yA               + 'where ptwhse = ' + %char(gCurrWhse) + ' '
640yA               +   'and pttrn# = ' + %char(gTran#);
640yA     other;
            SqlStmt = 'select * '
                    + 'from pirtran '
                    + 'inner join pirtrand '
                    +   'on ptdtran = pttrn# '
730cA               +      'and ptdwhse = ptwhse '
                    +     'and ptdgdte=ptgdte and ptdgtim=ptgtim '
640qM               + 'where ptwhse = ' + %char(gCurrWhse) + ' '
                    +   'and ptgdte >= ' + %char(threeMonthsAgo) + ' '
                    +   'and ptstat <> ptdstat '
                    + 'order by ptwhse, ptgdte, ptgtim, pttrn#';

640ya   endsl;
        exec sql prepare upddetlsel from :SqlStmt;
        exec sql declare upddetlcsr dynamic scroll cursor for upddetlsel;
        exec sql open upddetlcsr;

        dow forever = forever;

          exec sql fetch next from upddetlcsr
640rM              into :ptrec, :ptdrec;
640rD              //into :ptrec;


          if sqlstt <> sqlSuccess;
            leave;
          endif;



640yA     // Ignore records in PIRTRAND with status 'B' 'U' 'X'
640yA     // These records are showing an odd occurance

640yA     if (ptdstat < '0') and gCmd = '*ONETRAN';
640yA       iter;
640yA     endif;

640yA     // When pirtrand status > pirtran status we must assume the  the
640yA     // user backed up and we need to delete the pirtrand record  e
640yA     // to ensure we have the most current information in the file
640yA     if (ptdstat > ptstat) and gCmd = '*ONETRAN';

640yA       updDelete('B');
640yA       gRecsDeleted += 1;
640yA       iter;

640yA     endif;

          // When stat changed from '1' or '2' to '3' or '4'
650kA     // or when stat changes from '1' to '2'
          // Then we call the routine to do the heavy duty record creation.
          // But first we will delete the current record becuse it is
          // not needed anymore.

          if (ptdstat = '1' or ptdstat = '2')
650kD        //and (ptstat = '3' or ptstat = '4');
650kM        and (ptstat = '3' or ptstat = '4')
650kA        or (ptdstat = '1')
650kA        and (ptstat = '2');

760 A       if (ptdStat='1' or ptdStat='2') and
760aA           (ptStat='3' or ptStat='4');
760 A         go12To3 = *on;
760 A       endif;

            exec sql delete from pirtrand
640yD                //where ptdtran = :pttrn#;
640yM                where ptdtran = :pttrn#
730cA                  and ptdwhse = :ptwhse
710bA                  and ptdgdte = :ptgdte
710bA                  and ptdgtim = :ptgtim
640yA                  and ptdstat not in ('B','U','X');
640pA       gRecsDeleted += 1;
            wrtNewDetail2();
760 A       // when selection and changing from 1 or 2 to 3,
760 A       // selection and logging APT then call APTTRNSEL
760 A       if go12To3 and logapt and (ptdsel=1 or ptdseli=1);
760 A         // generate APT selection data KVI's
760 A         wkCmd = 'CRTAPTDTA';
760 A         wkRtn = *blanks;
760 A         wkReWrte = 'N';
760aD         //callp apttrnsel(pWhse:pTran#:wkCmd:ptEmp#:wkReWrte:wkRtn);
760aA         qcmd = 'sbmjob cmd(APTTRNSEL WHS(' + %char(pWhse) + ')' +
760aA                                     ' TRAN(' + %char(pTran#) + ')' +
760aA                                     ' EMP(' + %char(ptEmp#) + ')' +
760aA                                     ' REWRTE(' + sq + wkReWrte + sq + ')'
760aA                                   + ' CMD(' + sq + %trim(wkCmd) + sq + ')'
760aA                                     + ' RTN(' + sq + %trim(wkRtn) + sq +
760aA                                     ')) JOBQ(BFCJOBQ)';
760aA         qlen = %len(%trim(qcmd));
760aA /end-free
760aAc                   monitor
760aAC                   call      'QCMDEXC'
760aAC                   parm                    qcmd            512
760aAC                   parm                    qlen             15 5
760aAc                   on-error
760aAc*              might want to consider an email or something
760aAc*              in case this ever happens to alert us with the
760aAc*              transaction it happened on so we can be proactive
760aAc                   endmon
760aA /free
760 A       endif;
            iter;

          endif;

          // Otherwise, we just update the current record with the new status.

          exec sql update pirtrand set
                     ptdstat    = :ptstat,
                     ptdchgts   = :startstampsys,
                     ptdchguc   = :startstampuc,
                     ptdchgusr  = :#user,
                     ptdchgjob  = :#job,
                     ptdchgnbr  = :#jobnbr
                   where ptdtran = :pttrn#
730cA                  and ptdwhse = :ptwhse
640yA                  and ptdstat not in ('B','U','X');

640pA     gRecsUpdated += 1;
        enddo;

        exec sql close upddetlcsr;

        return;

      /end-free

     p UpdDetail       e

640yA*----------------------------------------------------------------
640yA*  UpdDelete    Upadate PIRTRAND records where PIRTRAN is deleted
640yA*----------------------------------------------------------------

640yAp UpdDelete       b
640yAd UpdDelete       pi
640yAd  updSts                        1    const

640yA /free

640yA   clearflags();
640yA   ptdstat = updsts;

640yA   // Clear flags/indicators in PIRTRAND when PIRTRAN is deleted.

640yA     exec sql update pirtrand set
640yA          ptdstat   = :ptdstat,
640yA          ptdbegday = :ptdbegday,
640ya          ptdendday = :ptdendday,
640yA          ptdpick   = :ptdpick,
640yA          ptddiri   = :ptddiri,
640yA          ptdindi   = :ptdindi,
640yA          ptdidlei  = :ptdidlei,
640yA          ptdvoicei = :ptdvoicei,
640yA          ptdrcvi   = :ptdrcvi,
640ya          ptdrcvdlti= :ptdrcvdlti,
640yA          ptdrcvputi= :ptdrcvputi,
640yA          ptdstagei = :ptdstagei,
640yA          ptdrpli   = :ptdrpli,
640yA          ptdrpltfi = :ptdrpltfi,
640yA          ptdtfri   = :ptdtfri,
640yA          ptdvfyi   = :ptdvfyi,
640ya          ptdseli   = :ptdseli,
640yA          ptdfixi   = :ptdfixi,
640yA          ptdpiri   = :ptdpiri,
640yA          ptdbulki  = :ptdbulki,
640yA          ptdrtni   = :ptdrtni,
640yA          ptdrtnputi= :ptdrtnputi,
640yA          ptdequipi = :ptdequipi,
640ya          ptdruni   = :ptdruni,
640yA          ptdloadi  = :ptdloadi,
640yA          ptdotheri = :ptdotheri,
640yA          ptddir    = :ptddir,
640yA          ptdind    = :ptdind,
640yA          ptdidle   = :ptdidle,
640yA          ptdvoice  = :ptdvoice,
640ya          ptdrcv    = :ptdrcv,
640yA          ptdrcvdlt = :ptdrcvdlt,
640yA          ptdrcvput = :ptdrcvput,
640yA          ptdstage  = :ptdstage,
640yA          ptdrpl    = :ptdrpl,
640yA          ptdrpltf  = :ptdrpltf,
640yA          ptdtfr    = :ptdtfr,
640ya          ptdvfy    = :ptdvfy,
640yA          ptdsel    = :ptdsel,
640yA          ptdfix    = :ptdfix,
640yA          ptdpir    = :ptdpir,
640yA          ptdbulk   = :ptdbulk,
640yA          ptdrtn    = :ptdrtn,
640yA          ptdrtnput = :ptdrtnput,
640ya          ptdequip  = :ptdequip,
640yA          ptdrun    = :ptdrun,
640yA          ptdload   = :ptdload,
640yA          ptdother  = :ptdother,
640yA          ptdchgts  = :startstampsys,
640yA          ptdchguc  = :startstampuc,
640yA          ptdchgusr = :#user,
640yA          ptdchgjob = :#job,
640yA          ptdchgnbr = :#jobnbr
640yA      where ptdtran = :gTran#
730cA        and ptdwhse = :gCurrWhse;

640yA     if sqlstt <> sqlSuccess;
640yA     endif;

640yA   ptdstat = ' ';
640yA   return;

640yA /end-free

640yAp UpdDelete       e

650mA*----------------------------------------------------------------
650mA*  UpdShiftDte  Update SHIFTDTE file with current shift date
650mA*----------------------------------------------------------------

650mAp UpdShiftDte     b
650mAd UpdShiftDte     pi

650mA /free
650mA   // update SHIFTDTE with current shift day
650mA   exec sql select * into :shdrec
650mA            from shiftdte
650mA            where shdwhse = :gCurrWhse
650mA              and shdcode = :ptdshft;
650mA   if sqlstt = sqlSuccess;
650mA     exec sql update shiftdte set
650mA          shdshftday = :ptdshftday
650mA        where shdwhse = :gCurrWhse
650mA          and shdcode = :ptdshft;
650mA   else;
650mA     shdwhse = gCurrwhse;
650mA     shdcode = ptdshft;
650mA     shdshftday = ptdshftday;
650mA     exec sql insert into shiftdte values(:shdrec);
650mA   endif;

650mA /end-free

650mAp UpdShiftDte     e

     *----------------------------------------------------------------
     *  UpdShiftInfo   Update missing shift info in PIRTRAND records
     *----------------------------------------------------------------

     p UpdShiftInfo    b
     d UpdShiftInfo    pi

     *  Local Variables
710aAd closeDate       s               d

      /free

640pA   gRecsShift = 0;

        // Grab Ended/Closed records that don't have shift info.

640yA   if gTran# > 0;
640yA     SqlStmt = 'select * '
640yA             + 'from pirtrand '
640yA             + 'where ptdwhse = ' + %char(gCurrWhse) + ' '
650bD             //+   'and ptdstat in (2,3,4) '
650bM             +   'and ptdstat in (''2'',''3'',''4'') '
710aD             //+   'and ptdempnum > 0 '
640yA             +   'and ptdshftday = 0 '
640yA             +   'and ptdtran = ' + %char(gTran#) + ' '
640yA             + 'order by ptdwhse, ptdempnum, ptdsts, ptdtran '
640yA             + 'for update of ptdshftday,ptdshftdow,ptdshftwk,ptdshftsun,'
640yA             +   'ptdsec,ptdchgts,ptdchguc,ptdchgusr,ptdchgjob,ptdchgnbr';
640yA   else;
          SqlStmt = 'select * '
                  + 'from pirtrand '
640qM             + 'where ptdwhse = ' + %char(gCurrWhse) + ' '
650bD             //+   'and ptdstat in (2,3,4) '
650bM             +   'and ptdstat in (''2'',''3'',''4'') '
710dD             //+   'and ptdempnum > 0 '
                  +   'and ptdshftday = 0 '
                  + 'order by ptdwhse, ptdempnum, ptdsts, ptdtran '
                  + 'for update of ptdshftday,ptdshftdow,ptdshftwk,ptdshftsun,'
640kA             +   'ptdsec,ptdchgts,ptdchguc,ptdchgusr,ptdchgjob,ptdchgnbr';
640yA   endif;

        exec sql prepare updshftsel from :SqlStmt;
        exec sql declare updshftcsr dynamic scroll cursor for updshftsel;
        exec sql open updshftcsr;

        dow forever = forever;

          exec sql fetch next from updshftcsr
                   into :ptdrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Initialize PIRTRAND record

          ptdchgts = startstampsys;
          ptdchguc = startstampuc;
          ptdchgusr = #user;
          ptdchgjob = #job;
          ptdchgnbr = #jobnbr;

710aA     if ptdempnum > 0;
            GetShiftInfo(ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);
710aA     else;
710aA       if ptdstat = '4';
710cA         Select;
710cA           when ptdcts <> *loval;
710aA             closeDate = %date(ptdcts);
710cA           when ptdets <> *loval;
710cA             closeDate = %date(ptdets);
710cA           when ptdsts <> *loval;
710cA             closeDate = %date(ptdsts);
710cA           when ptdgts <> *loval;
710cA             closeDate = %date(ptdgts);
710cA           other;
710cA             closeDate = %date(ptdchgts);
710cA         endsl;
710aA         ptdshftday = %dec(closeDate:*ymd);
710aA       endif;
710aA     endif;

          exec sql update pirtrand set
                     ptdshftday = :ptdshftday,
                     ptdshftdow = :ptdshftdow,
                     ptdshftwk  = :ptdshftwk,
                     ptdshftsun = :ptdshftsun,
640kA                ptdsec     = :ptdsec,
                     ptdchgts   = :startstampsys,
                     ptdchguc   = :startstampuc,
                     ptdchgusr  = :#user,
                     ptdchgjob  = :#job,
                     ptdchgnbr  = :#jobnbr
                   where current of updshftcsr;

640pA     gRecsShift += 1;

        enddo;

        exec sql close updshftcsr;

        return;

      /end-free

     p UpdShiftInfo    e

     *----------------------------------------------------------------
     *  VoiceRecExists  See if voice records exist
     *----------------------------------------------------------------

     p VoiceRecExists  b
     d VoiceRecExists  pi             1p 0

     *  Local Variables

     D pcs             s              5p 0

      /free

        // See if record exists in LABELDO for transaction

        exec sql select lboqty into :pcs
                 from  labeldo
                 where lbotrn# = :pttrn#
730cA              and lbowhse = :ptwhse
                 fetch first 1 rows only;

        if sqlstt = sqlSuccess;
          return 1;
        else;
          return 0;
        endif;

      /end-free

     p VoiceRecExists  e

640xA*----------------------------------------------------------------
640xA*  WrtIdleDetail   Write IDLE detail record
640xA*----------------------------------------------------------------

     p WrtIdleDetail   b
     d WrtIdleDetail   pi

     *  Local Variables

     D directFound     s               n
     D hours           s              5p 0

      /free

        // First, get the Direct previouse Direct transaction.

        ptdsts = CreateTS(ptsdte: ptstim);
        if ptdsts = noStamp;
          ptdgts = CreateTS(ptgdte: ptgtim);
          ptdsts = ptdgts;
        endif;
        ptdsuc = CreateUC(ptdsts);

        exec sql select *  into :ptdrecdir
                 from pirtrand
                 where ptdwhse = :ptwhse
                   and ptdempnum = :ptemp#
                   and ptddiri = 1
650bD              //and ptdstat in (3, 4)
650bM              and ptdstat in ('3','4')
                   and ptdeuc <= :ptdsuc
                 order by ptdeuc desc,
                          ptdtran desc
                 fetch first 1 rows only;

        if sqlstt = sqlSuccess;
          hours = CalcHours(dir_ptdsuc: ptdsuc);
          if hours < 8;
            directFound = *on;
            ptdcortran = dir_ptdtran;
          else;
            directFound = *off;
            ptdcortran = -1;
          endif;
        endif;

        // Now write IDLE record.

        ptddetl = 'Y';
        wrtNewDetail3();

        // Now update Direct record.

        if directFound;

          dir_ptdidlesec += ptdsec;

          exec sql update pirtrand
                   set ptdidlesec = :dir_ptdidlesec
                   where ptdwhse = :dir_ptdwhse
                     and ptdadduc = :dir_ptdadduc
                     and ptdtran = :dir_ptdtran;

          if sqlstt <> sqlSuccess;
          endif;

        endif;

        ptdcortran = 0;
        ptdidlesec = 0;

        return;

      /end-free

     p WrtIdleDetail   e

     *----------------------------------------------------------------
     *  WrtNewDetail   Write new PIRTRAN records to PIRTRAND
      *----------------------------------------------------------------

     p WrtNewDetail    b
     d WrtNewDetail    pi

     *  Local Variables

640fAd beginDate       s              8
640fAd tempDate        s               d
710bAd testDate        s              8

      /free

640pA   gRecsAdded = 0;
710bA   GetCurrStamp();
710bA   tempDate = %date(currstampsys) - %days(182);
710bA   testDate = %char(%dec(tempDate:*iso));

640ya   // Tran# is passed in will only process that tran#
640ya   select;
640ya     when gTran# > 0;
640yA       // if the tranaction is already in pirtrand get out of here
640yA       exec sql select * into :ptdrec
640yA                from  pirtrand
640yA                where ptdwhse = :gCurrWhse
640ya                 and ptdtran = :gTran#
710ba                 and ptdgdte > :testDate
650cD                 //and ptdstat not in ('B','U','X');
650cM                 and ptdstat not in ('B','U','X')
650cA                 fetch first 1 rows only;

640ya       if sqlstt =  sqlNoData;
640ya         SqlStmt = 'select * '
640ya                 + 'from pirtran '
640ya                 + 'where ptwhse = ' + %char(gCurrWhse) + ' '
640ya                 +   'and pttrn# = ' + %char(gTran#);
640ya       else;
640ya         return;
640ya       endif;
640ya     other;
            // Get last record written to detail file
            // Then position to PIRTRAN to read new records

            exec sql select * into :ptdrec
                     from  pirtrand
640qA                where ptdwhse = :gCurrWhse
                     order by ptdwhse, ptdgdte desc, ptdgtim desc
                     fetch first 1 rows only;

            if sqlstt <> sqlSuccess;

640fA         if gFromDate = 0;
640vD           //tempDate = %date(startstampsys) - %months(1);
640vM           tempDate = %date(startstampsys);
640fA           beginDate = %char(%dec(tempDate:*iso));
640vD           //%subst(beginDate:7:2) = '01';
640fA         else;
640fA           beginDate = %char(gFromDate);
640fA         endif;

              SqlStmt = 'select * '
                      + 'from pirtran '
640qM                 + 'where ptwhse = ' + %char(gCurrWhse) + ' '
640fM                 +   'and ptgdte >= ' + beginDate;

640fA         if gToDate > 0;
640fA           SqlStmt = %trim(SqlStmt) + ' '
640fM                   + 'and ptgdte <= ' + %char(gToDate);
640fA         endif;

640fA         if gEmp# > 0;
640fA           SqlStmt = %trim(SqlStmt) + ' '
640fM                   + 'and ptemp# = ' + %char(gEmp#);
640fA         endif;

640fA         SqlStmt = %trim(SqlStmt) + ' '
                      + 'order by ptwhse, ptgdte, ptgtim, pttrn#';

            else;

              // Note, with the following statement we are taking the risk that
              // within a specific Generated date/time we didn't loop tran #'s.
              // It would be very rare to not grab all of the transactions for
              // a specific Generated date/time in one pass of this program.

              SqlStmt = 'select * '
                      + 'from pirtran '
640qM                 + 'where ptwhse = ' + %char(gCurrWhse) + ' '
                      +   'and '
                      +    '('
640qA                 +      '('
640qA                 +       'ptgdte=' + %char(ptdgdte) + ' '
640qA                 +       'and ptgtim=' + %char(ptdgtim) + ' '
640qA                 +       'and pttrn#>' + %char(ptdtran)
640qA                 +      ') '
640qA                 +      'or '
                      +      '('
                      +       'ptgdte=' + %char(ptdgdte) + ' '
640qM                 +       'and ptgtim>' + %char(ptdgtim)
640qD                 //+       'and ptgtim>=' + %char(ptdgtim) + ' '
640qD                 //+       'and pttrn#>' + %char(ptdtran)
                      +      ') '
                      +      'or '
                      +      '('
                      +       'ptgdte>' + %char(ptdgdte)
                      +      ') '
                      +    ') '
                      + 'order by ptwhse, ptgdte, ptgtim, pttrn#';

            endif;
640ya   endsl;

        // Initialize Add/Change information

        // Whip through PIRTRAN file to get new records

        exec sql prepare newsel from :SqlStmt;
        exec sql declare newcsr cursor for newsel;
        exec sql open newcsr;

        dow forever = forever;

          exec sql fetch next from newcsr
                   into :ptrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          wrtNewDetail2();

        enddo;

        exec sql close newcsr;

        return;

      /end-free

     p WrtNewDetail    e

     *----------------------------------------------------------------
     *  WrtNewDetail2  Write new PIRTRAN records to PIRTRAND - Part 2
     *----------------------------------------------------------------

     p WrtNewDetail2   b
     d WrtNewDetail2   pi

     *  Local Variables

      /free

        // Initialize PIRTRAND record

        clear ptdrec;

        ptdwhse = ptwhse;
        ptdtran = pttrn#;
        ptdgdte = ptgdte;
        ptdgtim = ptgtim;
        ptddetl = 'N';
        ptdstat = ptstat;
        ptdtask = pttask;
        ptdeadjflg = ' ';

        ptdaddts = startstampsys;
        ptdadduc = startstampuc;
        ptdaddusr = #user;
        ptdaddjob = #job;
        ptdaddnbr = #jobnbr;
        ptdchgts = startstampsys;
        ptdchguc = startstampuc;
        ptdchgusr = #user;
        ptdchgjob = #job;
        ptdchgnbr = #jobnbr;

        // Determine what to create

530aA   SetFlags();

        select;

          // If transaction not Ended or Closed,
          //   Just write out a record without new info. New info
          //   will be updated when it changes to a '3' or '4'.

          when ptstat <> '3' and ptstat <> '4';
            wrtOpnDetail();

          // Special handling for Selection

530aM     when ptdsel = 1;
            ptddetl = 'Y';
            wrtSelDetail();

          // For a normal putaway,
          //   First try to create a record for the Receiver.
          //   Then create the record for the putaway.
640iA     //   Don't create putaway record if tran was deleted.

530aM     when ptdrcvput = 1;
            ptddetl = 'Y';
700bD       //if gCmd = '*ONETRAN';
700bM       if gCmd = '*ONETRAN'
700bA          or gRCVPOFnd = *on;
640yA       else;
              WrtRcvDetail();
640yA       endif;
530aA       SetFlags();
640iA       if ptdrcvdlt = 0;
              wrtNewDetail3();
640iA       endif;

          // For a Returns putaway,
          //   First try to create a record for the Returner.
          //   Then create the record for the putaway.

530aM     when ptdrtnput = 1;
            ptddetl = 'Y';
700bD       //if gCmd = '*ONETRAN';
700bM       if gCmd = '*ONETRAN'
700bA          or gRCVRTNFnd = *on;
640yA       else;
              wrtRtnDetail();
640yA       endif;
530aA       SetFlags();
            wrtNewDetail3();

640xA     // Special handling for IDLE transactions
640xA
640xA     when ptdtask = 'IDLE';
640xA       wrtIdleDetail();

          // Otherwise, just create single record for PIRTRAN rec.

          other;
            ptddetl = 'Y';
            wrtNewDetail3();
        endsl;

        return;

      /end-free

     p WrtNewDetail2   e

     *----------------------------------------------------------------
     *  WrtNewDetail3  Write new PIRTRAN records to PIRTRAND - Part 3
     *----------------------------------------------------------------

     p WrtNewDetail3   b
     d WrtNewDetail3   pi

     *  Local Variables

     D hours           s              5p 0

      /free

        // Now create standard detail record

        ptdshft = ptshft;
        ptdcrew = ptcrew;
        ptdzone = ptwhdp;
        ptdempnum = ptemp#;

530aD   //ptdgrspcs = ptpcs;
530aD   //ptdpcs = ptpcs;

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);

        ptdsts = CreateTS(ptsdte: ptstim);
        if ptdsts = noStamp;
          ptdsts = ptdgts;
          ptsdte = ptgdte;
          ptstim = ptgtim;
        endif;
640jA   ptdsuc = CreateUC(ptdsts);

        ptdets = CreateTS(ptedte: ptetim);
        if ptdtask = 'BEGDAY' or ptdtask = 'ENDDAY';
          if ptdets = noStamp;
            ptdets = ptdsts;
            ptedte = ptsdte;
            ptetim = ptstim;
          endif;
        endif;
640jA   ptdeuc = CreateUC(ptdets);

        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

640lA   // Check duration between start/end.
640lA   // If >= 8 hours, then reduce end stamp by 5 seconds.
640lA   // This is to ensure that there is room to add ENDDAY/BEGDAY records.
650gM   // As of 650g, see FixEndTime for how end TS is changed.
640lA
640lA     hours = CalcHours(ptdsts: ptdets);
740aD     //if hours >= 8;
740aM     if hours >= 6;
650gD       //ptdets = ptdets - %seconds(5);
650gA       FixEndTime(ptdshft: ptdsts: ptdets: ptdets: ptdeuc);
640lA       ptdeadjflg = 'Y';
640lA     endif;

530aD   //ptdsec = CalcSeconds(ptdsts: ptdets);

530aD   //SetFlags();

530aA   WrtDetailRec(ptdempnum: 'WrtNewDetail3':
530aA                ptsdte: ptstim: ptedte: ptetim);

530aD   //exec sql insert into pirtrand values(:ptdrec);
530aD
530aD   //if sqlstt <> sqlSuccess;
530aD   //endif;

        return;

      /end-free

     p WrtNewDetail3   e

     *----------------------------------------------------------------
     *  WrtOpnDetail   Write detail for stat <> 3 or 4
     *----------------------------------------------------------------

     p WrtOpnDetail    b
     d WrtOpnDetail    pi

     *  Local Variables

640eAD e$whse          s              3  0
640eAD e$user          s             10
640eAD e$fnam          s             15
640eAD e$init          s              1
640eAD e$lnam          s             20
640eAD e$whdp          s              5
640eAD e$styp          s              1
640eAD e$shft          s              6
640eAD e$crew          s              6
640eAD e$nhrs          s              3  1
640eAD e$rtn           s              8
640eAD e$bpu           s              1
640eAD e$lng           s              2

      /free

640rA   ptdempnum = ptemp#;
640rA   ptdshft = ptshft;
640rA   ptdcrew = ptcrew;

640eA   // Get shift/crew if missing for a Started transaction
640eA
640eA   if ptdempnum > 0 and ptstat = '2';
640eA     if ptdshft = ' ' or ptdcrew = ' ';
640eA       getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
640eA               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD         //    e$bpu: e$lng);
710fM               e$bpu: e$lng: e$email: e$pics);
640eA       if ptdshft = ' ';
640eA         ptdshft = e$shft;
640eA       endif;
640eA       if ptdcrew = ' ';
640eA         ptdcrew = e$crew;
640eA       endif;
640eA     endif;
640eA   endif;

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = CreateTS(ptsdte: ptstim);
640jA   ptdsuc = CreateUC(ptdsts);
        ptdets = CreateTS(ptedte: ptetim);
640jA   ptdeuc = CreateUC(ptdets);
        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

530aA   ClearTaskFlags();

530aA   ptdsimtran = 1;

640wA   GetAddStamp();
        exec sql insert into pirtrand values(:ptdrec);

        if sqlstt <> sqlSuccess;
        endif;

640pA   gRecsAdded += 1;

        return;

      /end-free

     p WrtOpnDetail    e

     *----------------------------------------------------------------
     *  WrtRcvDetail  Write Reciever's detail record
     *----------------------------------------------------------------

     p WrtRcvDetail    b
     d WrtRcvDetail    pi

     *  Local Variables

     D e$whse          s              3  0
     D e$user          s             10
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     D saveTask        s              6

      /free


        // Then get corresponding PORCV record

        exec sql select * into :porrec
                 from  porcv
                 where portrn = :pttrn#
730cA              and porwhs = :ptwhse
                   and pordte = :ptgdte
                 order by portrn, pordte, portim
                 fetch first 1 rows only;

        // If not found, get out

        if sqlstt <> sqlSuccess;
          return;
        endif;

        // Get employee information

        ptdempnum = poremp;

        getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD     //    e$bpu: e$lng);
710fM           e$bpu: e$lng: e$email: e$pics);

        ptdshft = e$shft;
        ptdcrew = e$crew;
        ptdzone = ptwhdp;

        // Set appropriate RCV flag

530aA   ptdrcvput = 0;
530aA   ptdrcvputi = 0;

        select;
          when poract = 'R';
            ptdrcv = 1;
530aA       ptdrcvi = 1;
          when poract = 'D';
            ptdrcvdlt = 1;
530aA       ptdrcvdlti = 1;
          other;
            return;
        endsl;

530aA   ptdsimtran = 1;

        // Set all times to Generated time
        // Right now we are not tracking a Receiver's time

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = ptdgts;
640jA   ptdsuc = ptdguc;
        ptdets = ptdgts;
640jA   ptdeuc = ptdguc;
        ptdcts = ptdgts;
640jA   ptdcuc = ptdguc;

        ptdsec = 0;

        // GetShiftInfo(ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

640iM   ptdpcs = ptpcs;
        ptdmrgpcs = 0;
640iA   ptdgrspcs = ptpcs;
640iA   ptdgrsmrg = 0;

        saveTask = ptdtask;
        ptdtask = 'RCVPO';

        // Write/Update Receiver's record

640wA   GetAddStamp();
        exec sql insert into pirtrand values(:ptdrec);

        if sqlstt <> sqlSuccess;
        endif;

640pA   gRecsAdded += 1;

        ptdtask = saveTask;

        return;

      /end-free

     p WrtRcvDetail    e

     *----------------------------------------------------------------
     *  WrtRtnDetail  Write Returner's detail record
     *----------------------------------------------------------------

     p WrtRtnDetail    b
     d WrtRtnDetail    pi

     *  Local Variables

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     D saveTask        s              6

      /free

        // Then get corresponding LABELNK record

        exec sql select * into :llrec
                 from  labelnk
                 where lltrn# = :pttrn#
                 fetch first 1 rows only;

        // If not found, get out

        if sqlstt <> sqlSuccess;
          return;
        endif;

        // Then get corresponding ORRTN record

        exec sql select * into :orrec
                 from  orrtn
                 where orolb# = :lllblo
                   and orrdte = :ptgdte
                 fetch first 1 rows only;

        // If not found, get out

        if sqlstt <> sqlSuccess;
          return;
        endif;

        // Get employee information

        getUser(orrusr: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        ptdempnum = e$emp#;
        ptdshft = e$shft;
        ptdcrew = e$crew;
        ptdzone = ptwhdp;

        // Set RTN flag

530aA   ptdrtnput = 0;
530aA   ptdrtnputi = 0;

        ptdrtn = 1;
530aA   ptdrtni = 1;

530aA   ptdsimtran = 1;

        // Set all times to Generated time
        // Right now we are not tracking a Returner's time

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = ptdgts;
640jA   ptdsuc = ptdguc;
        ptdets = ptdgts;
640jA   ptdeuc = ptdguc;
        ptdcts = ptdgts;
640jA   ptdcuc = ptdguc;

        ptdsec = 0;

        // GetShiftInfo(ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);

640iM   ptdpcs = ptpcs;
        ptdmrgpcs = 0;
640iA   ptdgrspcs = ptpcs;
640iA   ptdgrsmrg = 0;

        saveTask = ptdtask;
        ptdtask = 'RCVRTN';

        // Write Returner's record

640wA   GetAddStamp();
        exec sql insert into pirtrand values(:ptdrec);

        if sqlstt <> sqlSuccess;
        endif;

640pA   gRecsAdded += 1;

        ptdtask = saveTask;

        return;

      /end-free

     p WrtRtnDetail    e

     *----------------------------------------------------------------
     *  WrtSelDetail  Write Selector's detail record(s)
     *----------------------------------------------------------------

     p WrtSelDetail    b
     d WrtSelDetail    pi

     *  Local Variables

     D ptemp#Found     s               n
     D passtranFound   s               n
530aAD passtranEmp#    s              5p 0

      /free

        // Determine if voice was used

        ptdvoice = VoiceRecExists();
530aA   ptdvoicei = ptdvoice;

        // Voice was not used ...
640hA   // Set No Voice flags on.

        if ptdvoice = 0;
640hA     if ptdtask = 'BULKF' or ptdtask = 'BULKP';
640hA       ptdnrmnv = 0;
640hA       ptdmrgnv = 0;
640hA     else;
640hA       ptdnrmnv = 1;
640hA       ptdmrgnv = 1;
640hA     endif;
          WrtSelNoVoice();
          return;
        endif;

        // Voice was used ...

640hA     ptdnrmnv = 0;
640hA     ptdmrgnv = 0;

640fA   // Get zone
640fA
640fA   ptdZone = GetZone();

        // First, write record for each PASSTRAN record

530aM   WrtVoicePass(ptemp#Found: passtranFound: passtranEmp#);

        // Next, write record for PIRTRAN record

        WrtVoiceTran(ptemp#Found);

640hD   // Now, cretae a record for labels not picked through voice
640hD   // As of 640h, missed pieces will be added to WrtVoiceTran record.

640hD   //WrtVoiceMiss(passtranFound: passtranEmp#);

        return;

      /end-free

     p WrtSelDetail    e

     *----------------------------------------------------------------
     *  WrtSelNoVoice  Write record for PIRTRAN when voice not used
     *----------------------------------------------------------------

     p WrtSelNoVoice   b
     d WrtSelNoVoice   pi

      /free

        ptdempnum = ptemp#;
        ptdshft = ptshft;
        ptdcrew = ptcrew;

        // Calculate stamps

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = CreateTS(ptsdte: ptstim);
640jA   ptdsuc = CreateUC(ptdsts);
        ptdets = CreateTS(ptedte: ptetim);
640jA   ptdeuc = CreateUC(ptdets);
        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

530aD   // Calculate seconds from Start to End
530aD
530aD   //ptdsec = CalcSeconds(ptdsts: ptdets);
530aD
530aD   // Caculate pieces picked by Selector
530aD
530aD   //GetLabelPcs(ptdgrspcs: ptdgrsmrg: ptdpcs: ptdmrgpcs:
530aD   //            ptdlabels: ptdmrglbls);

        // Get zone

        ptdZone = GetZone();

        //ptdslots = GetPassSlots(ptemp#);

        // Write Selector's record

530aA   WrtDetailRec(ptdempnum: 'WrtSelNoVoice':
530aA                ptsdte: ptstim: ptedte: ptetim);

530aD   //exec sql insert into pirtrand values(:ptdrec);
530aD
530aD   //if sqlstt <> sqlSuccess;
530aD   //endif;

        return;

      /end-free

     p WrtSelNoVoice   e

     *----------------------------------------------------------------
     *  WrtVoiceMiss  Write records missing from LABELDO
640h *  Routine no longer used as of 640h.
640h *  Missed pieces will now be added to WrtVoiceTran record.
     *----------------------------------------------------------------

     p WrtVoiceMiss    b
     d WrtVoiceMiss    pi
     d passtranFound                   n
530aAd passtranEmp#                   5p 0

640eAD e$whse          s              3  0
640eAD e$user          s             10
640eAD e$fnam          s             15
640eAD e$init          s              1
640eAD e$lnam          s             20
640eAD e$whdp          s              5
640eAD e$styp          s              1
640eAD e$shft          s              6
640eAD e$crew          s              6
640eAD e$nhrs          s              3  1
640eAD e$rtn           s              8
640eAD e$bpu           s              1
640eAD e$lng           s              2

      /free

        ptdvoice = 0;
530aA   ptdvoicei = 0;

        // Caculate pieces that were not picked through voice

640iD   //GetMissedPcs(ptdgrspcs: ptdgrsmrg: ptdpcs: ptdmrgpcs:
640iD   //             ptdlabels: ptdmrglbls: ptdslots);

        // If no labels were found, get out.

        if ptdlabels=0 and ptdmrglbls=0;
           return;
        endif;

        // If a record was found in PASSTRAN
        //   and the PASSTRAN employee number doesn't match tran Empl#,
        //     (if multiple PASSTRAN employees, field will be set to -1)
        //   Then we don't know who actually picked these pieces

530aM   if passtranFound and passtranEmp# <> ptemp#;
          ptdempnum = 0;
          ptdshft = ' ';
          ptdcrew = ' ';
530aA     ClearTaskFlags();
        else;
530aM     if passtranFound and passtranEmp# = ptemp#;
530aA       ClearTaskFlags();
530aA     else;
530aA       SetFlags();
530aM     endif;
          ptdempnum = ptemp#;
          ptdshft = ptshft;
          ptdcrew = ptcrew;
640eA     if ptdshft = ' ' or ptdcrew = ' ';
640eA       getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
640eA               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD         //    e$bpu: e$lng);
710fM               e$bpu: e$lng: e$email: e$pics);
640eA       if ptdshft = ' ';
640eA         ptdshft = e$shft;
640eA       endif;
640eA       if ptdcrew = ' ';
640eA         ptdcrew = e$crew;
640eA       endif;
640eA     endif;
        endif;

        // Calculate stamps

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        clear ptdsts;
640jA   clear ptdsuc;
        clear ptdets;
640jA   clear ptdeuc;
        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

        ptdsec = 0;

        // Get zone

        ptdZone = GetZone();

        //ptdslots = GetPassSlots(ptemp#);

        // Write Selector's record

640wA     GetAddStamp();
          exec sql insert into pirtrand values(:ptdrec);

          if sqlstt <> sqlSuccess;
          endif;

640pA     gRecsAdded += 1;

        return;

      /end-free

     p WrtVoiceMiss    e

     *----------------------------------------------------------------
     *  WrtVoicePass  Write record for each PASSTRAN record
     *----------------------------------------------------------------

     p WrtVoicePass    b
     d WrtVoicePass    pi
     d ptemp#Found                     n
530aAd passtranFound                   n
530aAd passtranEmp#                   5p 0

     *  Local Variables

     D seconds         s              7  0

      /free

        passtranFound = *off;
530aA   passtranEmp#  = 0;

        ptdvoice = 1;
530aA   ptdvoicei = 1;

        // Calculate stamps that come from PIRTRAN

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

        // Read through PASSTRAN file for transaction

        SqlStmt = 'select * from passtran '
                + 'where pastrn# = ' + %char(pttrn#) + ' '
                + 'order by pastrn#, pasemp#, passdte, passtim';
        exec sql prepare passSel from :SqlStmt;
        exec sql declare passCsr cursor for passSel;
        exec sql open passCsr;

        ptdempnum = *loval;
        ptemp#Found = *off;

        dow forever = forever;

          exec sql fetch next from passCsr
                   into :pasrec;

          // If not found, get out

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          passtranFound = *on;

530aA     select;
530aA       when passtranEmp# = 0;
530aA         passtranEmp# = pasemp#;
530aA       when passtranEmp# <> pasemp# and passtranEmp# > 0;
530aA         passtranEmp# = -1;
530aA     endsl;

          // Flag if PASSTRAN emp# matches PIRTRAN emp#

          if pasemp# = ptemp#;
            ptemp#Found = *on;
          endif;

          // Only set flags for first record for an employee
          // This prevents getting multiple credit for same transaction.
530aA     // Field ptdemp# contains last emp#.

          if pasemp# = ptdempnum;

530aM       ClearTaskFlags();

          else;

530aM       SetFlags();
530aM       ptdvoice = 1;
530aM       ptdvoicei = 1;

          endif;

          ptdempnum = pasemp#;
          ptdshft = passhft;
          ptdcrew = pascrew;

          // Calculate stamps from PASSTRAN Start/End date/times

          ptdsts = CreateTS(passdte: passtim);
640jA     ptdsuc = CreateUC(ptdsts);
          ptdets = CreateTS(pasedte: pasetim);
640jA     ptdeuc = CreateUC(ptdets);

530aD     // Calculate seconds from Start to End
530aD
530aD     //ptdsec = CalcSeconds(ptdsts: ptdets);
530aD
530aD     // Caculate pieces picked by Selector
530aD
530aD     //GetVoicePcs(pasemp#: ptdsts: ptdets:
530aD     //            ptdgrspcs: ptdgrsmrg: ptdpcs: ptdmrgpcs:
530aD     //            ptdlabels: ptdmrglbls);

          //ptdslots = GetPassSlots(pasemp#);

          // Write Selector's record

530aA     WrtDetailRec(ptdempnum: 'WrtVoicePass':
530aA                  passdte: passtim: pasedte: pasetim);

530aD     //exec sql insert into pirtrand values(:ptdrec);
530aD
530aD     //if sqlstt <> sqlSuccess;
530aD     //endif;

        enddo;

        exec sql close passCsr;

        return;

      /end-free

     p WrtVoicePass    e

     *----------------------------------------------------------------
     *  WrtVoiceTran  Write record for PIRTRAN record
     *----------------------------------------------------------------

     p WrtVoiceTran    b
     d WrtVoiceTran    pi
     d ptemp#Found                     n

      /free

        ptdvoice = 1;
530aA   ptdvoicei = 1;

        // Only set flags for first record for an employee
        // This prevents getting multiple credit for same transaction.

        if ptemp#Found;

530aM     ClearTaskFlags();

        else;

530aM     SetFlags();
530aM     ptdvoice = 1;
530aM     ptdvoicei = 1;

        endif;

        ptdempnum = ptemp#;
        ptdshft = ptshft;
        ptdcrew = ptcrew;

        // Calculate stamps

        ptdgts = CreateTS(ptgdte: ptgtim);
640jA   ptdguc = CreateUC(ptdgts);
        ptdsts = CreateTS(ptsdte: ptstim);
640jA   ptdsuc = CreateUC(ptdsts);
        ptdets = CreateTS(ptedte: ptetim);
640jA   ptdeuc = CreateUC(ptdets);
        ptdcts = CreateTS(ptcdte: ptctim);
640jA   ptdcuc = CreateUC(ptdcts);

530aD   // Calculate seconds from Start to End
530aD
530aD   //ptdsec = CalcSeconds(ptdsts: ptdets);
530aD
530aD   // Caculate pieces picked by Selector
530aD
530aD   //GetVoicePcs(ptemp#: ptdsts: ptdets:
530aD   //            ptdgrspcs: ptdgrsmrg: ptdpcs: ptdmrgpcs:
530aD   //            ptdlabels: ptdmrglbls);

        //ptdslots = GetPassSlots(ptemp#);

        // Write Selector's record

530aA   WrtDetailRec(ptdempnum: 'WrtVoiceTran':
530aA                ptsdte: ptstim: ptedte: ptetim);

530aD   //exec sql insert into pirtrand values(:ptdrec);
530aD
530aD   //if sqlstt <> sqlSuccess;
530aD   //endif;

        return;

      /end-free

     p WrtVoiceTran    e

530aA*----------------------------------------------------------------
530aA*  WrtDetailRec    Write detail record
530aA*----------------------------------------------------------------
530aA
530aAp WrtDetailRec    b
     d WrtDetailRec    pi
     d  sentEmp#                      5p 0
     d  sentRoutine                  30    const
     d  sentSDte                      8s 0
     d  sentSTim                      6s 0
     d  sentEDte                      8s 0
     d  sentETim                      6s 0

     *  Local Variables

     d startDate       s              8s 0
     d startTime       s              6s 0
     d endDate         s              8s 0
     d endTime         s              6s 0
     d fmtdateSDte     s             45
     d fmtdateEDte     s             45
     d fmtdateStart    s             45
     d fmtdateEnd      s             45
     D hours           s              5p 0
     d iSDte           s              8s 0
     d iSTim           s              6s 0
     d iEDte           s              8s 0
     d iETim           s              6s 0
     d iFound          s               n
     d iMore           s               n
640cAd indFlag         s               n
640hAd inclMissed      s               n
640kAd loopCount       s              3  0

640eAD e$whse          s              3  0
640eAD e$user          s             10
640eAD e$fnam          s             15
640eAD e$init          s              1
640eAD e$lnam          s             20
640eAD e$whdp          s              5
640eAD e$styp          s              1
640eAD e$shft          s              6
640eAD e$crew          s              6
640eAD e$nhrs          s              3  1
640eAD e$rtn           s              8
640eAD e$bpu           s              1
640eAD e$lng           s              2

      /free

640eA   // Get shift/crew if missing
640eA
640eA   if ptdempnum > 0;
640eA     if ptdshft = ' ' or ptdcrew = ' ';
640eA       getEmpl(ptdempnum: e$whse: e$user: e$fnam: e$init: e$lnam:
640eA               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710fD          //   e$bpu: e$lng);
710fA               e$bpu: e$lng: e$email: e$pics);
640eA       if ptdshft = ' ';
640eA         ptdshft = e$shft;
640eA       endif;
640eA       if ptdcrew = ' ';
640eA         ptdcrew = e$crew;
640eA       endif;
640eA     endif;
640eA   endif;

640hA   // Set flag to include pieces missed by voice;
640hA   // This will only be done for the first WrtVoiceTran created.
640hA
640hA   if sentRoutine = 'WrtVoiceTran';
640hA     inclMissed = *on;
640hA   endif;

        // For a selection transaction,
        //   look for multiple transactions picked simultaneously.

        if ptdseli = 1;
          ptdsimtran = GetSimCount();
        else;
          ptdsimtran = 1;
        endif;

        // Loop until no overlapping indirect task found.

        startDate = sentSDte;
        startTime = sentSTim;
        endDate   = sentEDte;
        endTime   = sentETim;

640cA   indFlag   = *off;
640kA   loopCount = 0;

        dow forever = forever;

640kA     loopCount += 1;
640kA     if loopCount > 20;
640kA       leave;
640kA     endif;

          GetIndirect(startDate: startTime: endDate: endTime:
                      iSDte: iSTim: iEDte: iETim: iFound: iMore);

          if not iFound;
            leave;
          endif;

          // Overlapping Indirect task found
          // Create record that ends at the beginning of the Indirect task.

          // Calculate pieces
          // For VoicePass/Tran we do it every time.
          // For everything else we do it only the first time through.
          // To ensure we don't miss anything, use end time of indirect task.

          if ptdsplit = 0
             or sentRoutine = 'WrtVoicePass'
             or sentRoutine = 'WrtVoiceTran';
               ptdets = CreateTS(iEDte: iETim);
640jA          ptdeuc = CreateUC(ptdets);
640hD          //GetPieces(sentemp#: sentRoutine: ptdsts: ptdets:
640hM          GetPieces(sentemp#: sentRoutine: inclMissed: ptdsts: ptdets:
640iM                    ptdgrspcs: ptdgrsmrg: ptdgrsblk:
640iM                    ptdpcs: ptdmrgpcs: ptdblkpcs:
640iM                    ptdlabels: ptdmrglbls: ptdblklbls:
640mM                    ptdmrgzns: ptdblkzns: ptdslots: ptdpick);
          endif;

          // Set End TS to the beginning date/time of the Indirect task.

          ptdets = CreateTS(iSDte: iSTim);
640jA     ptdeuc = CreateUC(ptdets);

          // Check duration between start/end.
640lM     // If >= 8 hours, reduce end time by 5 seconds instead of leaving.
640lM     // This is done to allow room for ENDDAY/BEGDAY records.
650gM     // As of 650g, see FixEndTime for how end TS is changed.

          hours = CalcHours(ptdsts: ptdets);
740aD     //if hours >= 8;
740aM     if hours >= 6;
640lD       //leave;
650gD       //ptdets = ptdets - %seconds(5);
650gA       FixEndTime(ptdshft: ptdsts: ptdets: ptdets: ptdeuc);
650gA       ptdeadjflg = 'Y';
          endif;

          // Set split flag for next record.

          ptdSplit = 1;

          // Calculate seconds

          eval(h) ptdsec = CalcSeconds(ptdsts: ptdets) / ptdsimtran;

          // Write record

640wA     GetAddStamp();
          exec sql insert into pirtrand values(:ptdrec);

          if sqlstt <> sqlSuccess;
          endif;

640pA     gRecsAdded += 1;

640cA     indFlag = *on;

          // Change start date to end of Indirect task

          startDate = iEDte;
          startTime = IETim;

          ptdsts = CreateTS(iEDte: iETim);
640jA     ptdsuc = CreateUC(ptdsts);

          // Clear task flags.
          // Re: These flags are used for calculating the number of transactions
          // a user did. Therefore, we only want to give credit once.

          ClearTaskFlags();

          // Clear values like pieces

          ClearValues();

        enddo;

        ptdsts = CreateTS(startDate: startTime);
640jA   ptdsuc = CreateUC(ptdsts);
        ptdets = CreateTS(endDate: endTime);
640jA   ptdeuc = CreateUC(ptdets);

        // If start/end are different, then write final record.
        // The only reason they would be the same is if the last Indirect
        // task had the same end date/time as the main transaction.
640cA   // Oops, not true. There is a special Pick Slot Receiving, where
640cA   // the PUTEMP transaction will be created with the same start/end.
640cA   // So, if there was no overlapping Indirect transaction, write rec.

640cD   //if ptdsts <> ptdets;
640cM   if ptdsts <> ptdets or not indFlag;

          // Calculate pieces
          // For VoicePass/Tran we do it every time.
          // For everything else we do it only the first time through.

          if ptdsplit = 0
             or sentRoutine = 'WrtVoicePass'
             or sentRoutine = 'WrtVoiceTran';
640hD          //GetPieces(sentemp#: sentRoutine: ptdsts: ptdets:
640hM          GetPieces(sentemp#: sentRoutine: inclMissed: ptdsts: ptdets:
640iM                    ptdgrspcs: ptdgrsmrg: ptdgrsblk:
640iM                    ptdpcs: ptdmrgpcs: ptdblkpcs:
640iM                    ptdlabels: ptdmrglbls: ptdblklbls:
640mM                    ptdmrgzns: ptdblkzns: ptdslots: ptdpick);
          endif;

640lA     // Check duration between start/end.
640lA     // If >= 8 hours, then reduce end stamp by 5 seconds.
650gM     // As of 650g, see FixEndTime for how end TS is changed.
640lA
640lA       hours = CalcHours(ptdsts: ptdets);
740aD       //if hours >= 8;
740aM       if hours >= 6;
650gD         //ptdets = ptdets - %seconds(5);
650gA         FixEndTime(ptdshft: ptdsts: ptdets: ptdets: ptdeuc);
640lA         ptdeadjflg = 'Y';
640lA       endif;

          // Calculate seconds

          eval(h) ptdsec = CalcSeconds(ptdsts: ptdets) / ptdsimtran;

          // Write record

640wA     GetAddStamp();

650dA     // If BEGDAY check to make sure BEGDAY was not already created
650dA     // need to determine shift info first in order to check for
650dA     // an existing BEGDAY record
650dA     if ptdtask = 'BEGDAY';
650dA       GetShiftInfo(ptdshftday: ptdshftdow: ptdshftwk: ptdshftsun);
650dA       // Now see if BEGDAY already exist
650dA       exec sql select * into :ptdbegdayfld
650dA                from pirtrand
650dA                where ptdwhse    = :ptdwhse
650dA                  and ptdempnum  = :ptdempnum
650dA                  and ptdshftday = :ptdshftday
650dA                  and ptdtask    = :ptdtask;
650dA
650dA       // found BEGDAY already in file
650dA       if sqlstt = sqlSuccess;
650dA         return;
650mA       else;
650mA         UpdShiftDte();
650dA       endif;
650dA     endif;

          exec sql insert into pirtrand values(:ptdrec);

640pA     gRecsAdded += 1;

        endif;

        return;

      /end-free

     p WrtDetailRec    e
