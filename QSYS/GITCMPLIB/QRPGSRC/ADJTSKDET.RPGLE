520cA *copy qcopysrc,hspecs  530aD
530aM /copy qcopysrc,hspecstrnc
     *----------------------------------------------------------------
     *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ADJTSKDET   Adjust task detail totals.
     *  21 February 1996
     *  Dave Sommerville
     *
     *  Revisions
     *
218 A*    01/30/97 HNK  2.18
     *    ABTTRN subroutine added to abort a transaction.
     *    UNDO   subroutine added to undo a transaction.
     *
     *
414 A*    06/28/00  DAS  4.14
     *      - Added commands *DECACT and *INCACT. These commands
     *        are used when multiple license plates are scanned as
     *        a single transaction. An example would be the RC300
     *        staged putaway program.
     *
416 A*    12/09/02  MLB  4.16
     *      - Enh: Added new command *END2 to perform elapsed time
     *        calculations based on end date/time set in calling
     *        program.
     *
520aA*    09/24/08  GJA  5.20a
     *      - Enh: Change task selection by department to zone when
     *        the cateogry is SELECT
520bA*    02/12/09  GJA  5.20b
     *      - Fix: TOTE transaction were not using correct zone
     *
520cA*    07/21/09  GJA  5.20c
     *      - Enh: Allow for client to select Zone or Department
     *             processing.  Depends upon OPTIONE
     *
530a *    11/16/09  MLB  5.30a
     *      - Fix: Changed hspec /copy mbr to hspectrnc which has
     *        option truncate(*yes) instead of std /copy w/ *no.
     *        This was needed because fields in TASKDET file were
     *        overflowing and causing MCH1210 Receiver value too
     *        small to hold result errors.  TASKDET file will need
     *        to have fields re-sized to hold larger values to
     *        eliminate need for this mod.
640aA*    12/22/09  GJA  6.40a  (missed in prev update)
     *      - Fix: TDFINW field can be too small, created work
     *             field WFINW to check before update
     *
640b *    07/23/12  DAS  6.40b
     *      - Fix: Changed opddta to opedta.
     *      - Fix: Revised routine getrec to always use worklbl file
     *        to get zone. Re: For *GEN, records haven't been
     *        written to label file yet.
     *      - When working with SELECT zones, zone is put into
     *        the tdwhdp and tdstyp fields.
     *      - Added recognition of command *STARTMU.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Ftaskdet   uf a e           k disk
     Ftask      if   e           k disk
640bDF*abel90   if   e           k disk
640bDF*orklbl   if   e           k disk
640bMFworklb94  if   e           k disk
520cAFoptione   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Data structure for time calculations
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @adjtd          c                   const('ADJTSKDET')
     D @cvtdt          c                   const('CVTDTE')
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
520cA*----------------------------------------------------------------
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Processing selection by voice (Y,N).
     *    OPZORD  -  Collect selection data by zone or department?
     *    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
640bDD*opddta          ds
640bMD opedta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
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
     *  Variables
     *
     D $msgf           s             10
     D #upcmd          s              8
     D cod             s              8
     D curdte          s              8  0
     D curtim          s              6  0
     D error           s              1
640bAD forever         s               n
640bAD kyrte           s                   like(lwrte)
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D wdp             s              5
     D whs             s              3  0
640aAD wfinw           s              9  0
     D wkwhdp          s              5
640bAD wkstyp          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *GEN      -  Generated transaction.
     *              *START    -  Started transaction.
     *              *END      -  Ended transaction.
     *                           This may update transaction record fields.
416 A*              *END2     -  Ended transaction.
416 A*                           This may update transaction record fields.
     *              *CLOSE    -  Closed transaction.
     *                           This may update transaction record fields.
218 A*              *ABORT    -  Abort a transaction.
218 A*              *UNDO     -  Undo a transaction.
414 A*              *DECACT   -  Decrease active totals.
414 A*              *INCACT   -  Increase active totals.
     *      $PTYPE  *INTER    - Interactive, use program msg queue.
     *              *BATCH    - Batch, send error code.
     *      PTPARM  PIRTRAN record.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *LOCKED  - TASKDET record is locked.
     *              *NOTEXST - TASKDET record does not exist.
     *              *NOTUPD  - TASKDET record not updated.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $ptype            8
     C                   parm                    ptparm
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $pmsg = *blanks
     *
     *  Get current date in century format and time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtim
     *
     *
     *  Get task detail record.
     *
     C                   exsr      getrec
     C     error         cabeq     *on           out
     *
     *  Execute corresponding routine.
     *
414 AC                   eval      #upcmd = $pcmd
     *
     C     $pcmd         caseq     '*GEN    '    gentrn
     C     $pcmd         caseq     '*START  '    strtrn
640bAC     $pcmd         caseq     '*STARTMU'    strtrn
     C     $pcmd         caseq     '*END    '    endtrn
416 AC     $pcmd         caseq     '*END2   '    endtr2
     C     $pcmd         caseq     '*CLOSE  '    clstrn
218 AC     $pcmd         caseq     '*ABORT  '    abttrn
218 AC     $pcmd         caseq     '*UNDO   '    undtrn
414 AC     $pcmd         caseq     '*DECACT '    updttl
414 AC     $pcmd         caseq     '*INCACT '    updttl
     C                   endcs
     *
     *  Update task detail record.
     *
     C                   update    tdrec                                79
     C                   if        *in79
     C                   if        $ptype = '*INTER  '
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7872
     C                   eval      $prtn = '*PGMQ   '
     C                   else
     C                   eval      $prtn = '*NOTUPD '
     C                   endif
     C                   endif
     *
     C     out           tag
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
     C                   eval      #upcmd = *blanks
     *
     *  Define file keys
     *
     *  Define key for TASKDET file.
     *
     C     keytd         klist
     C                   kfld                    pttask
     C                   kfld                    ptwhse
520aMC                   kfld                    wkwhdp
640bDC**                 kfld                    ptstyp
640bMC                   kfld                    wkstyp
     *
520aA*  Define full key for label file.
520aA*
520aAC     lbkey         klist
520aAC                   kfld                    ptwhse
520aAC                   kfld                    pttrn#
520cA*  Define full key for option file.
520cA*
520cAC     opkey         klist
520cAC                   kfld                    cod
520cAC                   kfld                    whs
520cAC                   kfld                    wdp

640bA*  Define partial key for worklb94 file.
640bA
640bAC     keylw94       klist
640bAC                   kfld                    ptwhse
640bAC                   kfld                    kyrte
640bAC                   kfld                    pttrn#
520cA*
520cAC                   movel     '*USER'       cod
     C                   endsr
218 A*----------------------------------------------------------------
218 A*
218 A*  ABTTRN  Abort a transaction.
218 A*
218 AC     abttrn        begsr
218 A*
218 AC                   select
218 A*
218 A*   When end date is zero.
218 A*
218 A*       - Reduce active totals.
218 AC                   when      ptedte = 0
218 AC                   eval      #upcmd = '*DECACT '
218 AC                   exsr      updttl
218 A*
218 AC                   endsl
218 AC                   endsr
     *----------------------------------------------------------------
     *
     *  CLSTRN  Closing transaction.
     *
     C     clstrn        begsr
     *
     C                   select
     *
     *   When start date is zero.
     *
     *       - Set start date/time to generated date/time/
     *       - Set end date/time to current date/time.
     *       - Set end type to 'C'.
     *       - Set close date/time to current date/time.
     *       - Calculate time spent.
     *       - Reduce pending totals.
     *       - Increase finished and closed totals.
     *
     C                   when      ptsdte = 0
     C                   eval      ptsdte = ptgdte
     C                   eval      ptstim = ptgtim
     C                   eval      ptedte = curdte
     C                   eval      ptetim = curtim
     C                   eval      ptetyp = 'C'
     C                   eval      ptcdte = curdte
     C                   eval      ptctim = curtim
     C                   exsr      zztime
     C                   eval      #upcmd = '*DECPND '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCFIN '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCCLS '
     C                   exsr      updttl
     *
     *   When end date is zero.
     *
     *       - Set end date/time to current date/time.
     *       - Set end type to 'C'.
     *       - Set close date/time to current date/time.
     *       - Calculate time spent.
     *       - Reduce active totals.
     *       - Increase finished and closed totals.
     *
     C                   when      ptedte = 0
     C                   eval      ptedte = curdte
     C                   eval      ptetim = curtim
     C                   eval      ptetyp = 'C'
     C                   eval      ptcdte = curdte
     C                   eval      ptctim = curtim
     C                   exsr      zztime
     C                   eval      #upcmd = '*DECACT '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCFIN '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCCLS '
     C                   exsr      updttl
     *
     *   Otherwise
     *
     *       - Set close date/time to current date/time.
     *       - Increase closed totals.
     *
     C                   other
     C                   eval      ptcdte = curdte
     C                   eval      ptctim = curtim
     C                   eval      #upcmd = '*INCCLS '
     C                   exsr      updttl
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENDTRN  Ending transaction.
     *
     C     endtrn        begsr
     *
     C                   select
     *
     *   When start date is zero.
     *
     *       - Set start date/time to generated date.
     *       - Set end date/time to current date/time.
     *       - Calculate time spent.
     *       - Reduce pending totals.
     *       - Increase finished.
     *
     C                   when      ptsdte = 0
     C                   eval      ptsdte = ptgdte
     C                   eval      ptstim = ptgtim
     C                   eval      ptedte = curdte
     C                   eval      ptetim = curtim
     C                   exsr      zztime
     C                   eval      #upcmd = '*DECPND '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCFIN '
     C                   exsr      updttl
     *
     *   When end date is zero.
     *
     *       - Set end date/time to current date/time.
     *       - Calculate time spent.
     *       - Reduce active totals.
     *       - Increase finished totals.
     *
     C                   when      ptedte = 0
     C                   eval      ptedte = curdte
     C                   eval      ptetim = curtim
     C                   exsr      zztime
     C                   eval      #upcmd = '*DECACT '
     C                   exsr      updttl
     C                   eval      #upcmd = '*INCFIN '
     C                   exsr      updttl
     *
     C                   endsl
     *
     C                   endsr
416 A*----------------------------------------------------------------
416 A*
416 A*  ENDTR2  Ending transaction using date/time set in calling pgm.
416 A*
416 AC     endtr2        begsr
416 A*
416 AC                   select
416 A*
416 A*   When start date is zero.
416 A*
416 A*       - Set start date/time to generated date.
416 A*       - Set end date/time to current date/time.
416 A*       - Calculate time spent.
416 A*       - Reduce pending totals.
416 A*       - Increase finished.
416 A*
416 AC                   when      ptsdte = 0
416 AC                   eval      ptsdte = ptgdte
416 AC                   eval      ptstim = ptgtim
416 AC                   if        ptedte = 0
416 AC                   eval      ptedte = curdte
416 AC                   eval      ptetim = curtim
416 AC                   endif
416 AC                   exsr      zztime
416 AC                   eval      #upcmd = '*DECPND '
416 AC                   exsr      updttl
416 AC                   eval      #upcmd = '*INCFIN '
416 AC                   exsr      updttl
416 A*
416 A*   When end date is greater than or equal zero.
416 A*
416 A*       - Set end date/time to current date/time.
416 A*       - Calculate time spent.
416 A*       - Reduce active totals.
416 A*       - Increase finished totals.
416 A*
416 AC                   when      ptedte >= 0
416 AC                   if        ptedte = 0
416 AC                   eval      ptedte = curdte
416 AC                   eval      ptetim = curtim
416 AC                   endif
416 AC                   exsr      zztime
416 AC                   eval      #upcmd = '*DECACT '
416 AC                   exsr      updttl
416 AC                   eval      #upcmd = '*INCFIN '
416 AC                   exsr      updttl
416 A*
416 AC                   endsl
416 A*
416 AC                   endsr
     *----------------------------------------------------------------
     *
     *  GENTRN  Generating transaction.
     *
     C     gentrn        begsr
     *
     *   Increase pending totals.
     *
     C                   eval      #upcmd = '*INCPND '
     C                   exsr      updttl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETREC  Get task detail record.
     *
     *    It is assumed that the department/section information is
     *    written to the transaction record according the the task
     *    tracking level found in the TASK file.
     *
     *    For example, if a task is only being tracked at the warehouse
     *    level then the department and section should be blank. If at
     *    the department level, the section should be blank.
     *
     *    This was done so the transaction file could easily be joined
     *    to the task detail file in order to get standards.
     *
     C     getrec        begsr
520aAC                   eval      wkwhdp = ptwhdp
640bAC                   eval      wkstyp = ptstyp
520cA****Get EPM option for zone data collection
520aAC                   if        ptcat = 'SELECT'
520cAC                   eval      wdp = ptwhdp
520cAC                   move      ptwhse        whs
520cAC     opkey         chain     optione
520aAC                   if        not %found(optione)
520cAC                   eval      wdp = *blanks
520cAC                   eval      whs = 0
520cAC     opkey         chain     optione
520aAC                   if        not %found(optione)
520cAC                   eval      opzord = ' '
520cAC                   endif
520cAC                   endif
520aA*  Check for selection records
520cAC                   if        opzord = 'Z'

640bDC**   lbkey         chain     label90                            76
640bDC**                 if        not *in76
640bDC**                 if        lbucod <> 'TO'
640bDC**   lblbl#        chain     worklbl                            77
640bDC**                 if        not *in77
640bDC**                 movel     lwszon        wkwhdp
640bDC**                 endif
640bDC**                 endif
640bDC**                 endif

640bAC                   eval      kyrte = ptrtpo
640bAC     keylw94       setll     worklb94
640bAC                   dow       forever = forever
640bAC     keylw94       reade     worklb94
640bAC                   if        %eof(worklb94)
640bAC                   leave
640bAC                   endif
640bAC                   if        lwucod = 'TO'
640bAC                   iter
640bAC                   endif
640bAC                   eval      wkwhdp = %subst(lwszon:1:5)
640bAC                   eval      wkstyp = %subst(lwszon:6:1)
640bAC                   leave
640bAC                   enddo

520aAC                   endif
520cAC                   endif
     C     tryagn        tag
     C                   eval      error = *off
     *
     *  Get task detail record.
     *
     C     keytd         chain     taskdet                            7978
     *
     *     Record is locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   if        $ptype = '*INTER  '
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7978
     C                   eval      $prtn = '*PGMQ   '
     C                   else
     C                   eval      $prtn = '*LOCKED '
     C                   endif
     C                   endif
     *
     *     Record not found.- Create it.
     *
     C                   if        *in79
     C                   clear                   tdrec
     C                   eval      tdcode = pttask
     C                   eval      tdwhse = ptwhse
520aM**                   MOVE PTWHDP    TDWHDP
520aMC                   eval      tdwhdp = wkwhdp
640bDC**                 eval      tdstyp = ptstyp
640bMC                   eval      tdstyp = wkstyp
     C                   write     tdrec                                78
     *
     *       If no error then loop around and try reading the
     *       record again. Otherwise, send back an error.
     *
     C     *in78         cabeq     *off          tryagn
     C                   eval      error = *on
     C                   if        $ptype = '*INTER  '
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7979
     C                   eval      $prtn = '*PGMQ   '
     C                   else
     C                   eval      $prtn = '*NOTEXST'
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  STRTRN  Starting transaction.
     *
     C     strtrn        begsr
     *
     *   Set start date/time to current date/time.
     *
     C                   eval      ptsdte = curdte
     C                   eval      ptstim = curtim
     *
     *   Decrease pending totals.
     *
     C                   eval      #upcmd = '*DECPND '
     C                   exsr      updttl
     *
     *   Increase active totals.
     *
     C                   eval      #upcmd = '*INCACT '
     C                   exsr      updttl
     *
     C                   endsr
218 A*----------------------------------------------------------------
218 A*
218 A*  UNDTRN  Undo a transaction.
218 A*
218 AC     undtrn        begsr
218 A*
218 A*       - Decrease active totals.
218 AC                   eval      #upcmd = '*DECACT '
218 AC                   exsr      updttl
218 A*
218 A*       - Increase pending totals.
218 AC                   eval      #upcmd = '*INCPND '
218 AC                   exsr      updttl
218 A*
218 AC                   endsr
     *----------------------------------------------------------------
     *
     *  UPDTTL  Update totals.
     *
     *    Input:  #UPCMD  -  *INCPND - Increase pending totals
     *                       *DECPND - Decrease pending totals
     *
     *                       *INCACT - Increase active totals
     *                       *DECACT - Decrease active totals
     *
     *                       *INCFIN - Increase finished totals
     *                       *DECFIN - Decrease finished totals
     *
     *                       *DECCLS - Decrease closed totals
     *                       *INCCLS - Increase closed totals
     *
     C     updttl        begsr
     *
     C                   select
     *
     *   PENDING totals.
     *
     *      Decrease pending totals. Don't let totals go negative.
     *
     C                   when      #upcmd = '*DECPND'
     C                   if        tdpndj >= 1
     C                   eval      tdpndj = tdpndj - 1
     C                   else
     C                   eval      tdpndj = 0
     C                   endif
     C                   if        ptcube <= tdpndc
     C                   sub       ptcube        tdpndc
     C                   else
     C                   eval      tdpndc = 0
     C                   endif
     C                   if        ptswgt <= tdpndw
     C                   sub       ptswgt        tdpndw
     C                   else
     C                   eval      tdpndw = 0
     C                   endif
     C                   if        ptpcs <= tdpndp
     C                   eval      tdpndp = tdpndp - ptpcs
     C                   else
     C                   eval      tdpndp = 0
     C                   endif
     C                   if        ptqty1 <= tdpnd1
     C                   eval      tdpnd1 = tdpnd1 - ptqty1
     C                   else
     C                   eval      tdpnd1 = 0
     C                   endif
     C                   if        ptqty2 <= tdpnd2
     C                   eval      tdpnd2 = tdpnd2 - ptqty2
     C                   else
     C                   eval      tdpnd2 = 0
     C                   endif
     C                   if        ptqty3 <= tdpnd3
     C                   eval      tdpnd3 = tdpnd3 - ptqty3
     C                   else
     C                   eval      tdpnd3 = 0
     C                   endif
     *
     *      Increase pending totals.
     *
     C                   when      #upcmd = '*INCPND'
     C                   add       1             tdpndj
     C                   add       ptcube        tdpndc
     C                   add       ptswgt        tdpndw
     C                   add       ptpcs         tdpndp
     C                   add       ptqty1        tdpnd1
     C                   add       ptqty2        tdpnd2
     C                   add       ptqty3        tdpnd3
     *
     *   ACTIVE totals.
     *
     *      Decrease active totals.  Don't let totals go negative.
     *
     C                   when      #upcmd = '*DECACT'
     C                   if        tdactj >= 1
     C                   eval      tdactj = tdactj - 1
     C                   else
     C                   eval      tdactj = 0
     C                   endif
     C                   if        ptcube <= tdactc
     C                   sub       ptcube        tdactc
     C                   else
     C                   eval      tdactc = 0
     C                   endif
     C                   if        ptswgt <= tdactw
     C                   sub       ptswgt        tdactw
     C                   else
     C                   eval      tdactw = 0
     C                   endif
     C                   if        ptpcs <= tdactp
     C                   eval      tdactp = tdactp - ptpcs
     C                   else
     C                   eval      tdactp = 0
     C                   endif
     C                   if        ptqty1 <= tdact1
     C                   eval      tdact1 = tdact1 - ptqty1
     C                   else
     C                   eval      tdact1 = 0
     C                   endif
     C                   if        ptqty2 <= tdact2
     C                   eval      tdact2 = tdact2 - ptqty2
     C                   else
     C                   eval      tdact2 = 0
     C                   endif
     C                   if        ptqty3 <= tdact3
     C                   eval      tdact3 = tdact3 - ptqty3
     C                   else
     C                   eval      tdact3 = 0
     C                   endif
     *
     *      Increase active totals.
     *
     C                   when      #upcmd = '*INCACT'
     C                   add       1             tdactj
     C                   add       ptcube        tdactc
     C                   add       ptswgt        tdactw
     C                   add       ptpcs         tdactp
     C                   add       ptqty1        tdact1
     C                   add       ptqty2        tdact2
     C                   add       ptqty3        tdact3
     *
     *   FINISHED totals.
     *
     *      Decrease finished totals.  Don't let totals go negative.
     *
     C                   when      #upcmd = '*DECFIN'
     C                   if        tdfinj >= 1
     C                   eval      tdfinj = tdfinj - 1
     C                   else
     C                   eval      tdfinj = 0
     C                   endif
     C                   if        ptcube <= tdfinc
     C                   sub       ptcube        tdfinc
     C                   else
     C                   eval      tdfinc = 0
     C                   endif
     C                   if        ptswgt <= tdfinw
     C                   sub       ptswgt        tdfinw
     C                   else
     C                   eval      tdfinw = 0
     C                   endif
     C                   if        ptpcs <= tdfinp
     C                   eval      tdfinp = tdfinp - ptpcs
     C                   else
     C                   eval      tdfinp = 0
     C                   endif
     C                   if        ptqty1 <= tdfin1
     C                   eval      tdfin1 = tdfin1 - ptqty1
     C                   else
     C                   eval      tdfin1 = 0
     C                   endif
     C                   if        ptqty2 <= tdfin2
     C                   eval      tdfin2 = tdfin2 - ptqty2
     C                   else
     C                   eval      tdfin2 = 0
     C                   endif
     C                   if        ptqty3 <= tdfin3
     C                   eval      tdfin3 = tdfin3 - ptqty3
     C                   else
     C                   eval      tdfin3 = 0
     C                   endif
     *
     *      Increase finished totals.
     *
     C                   when      #upcmd = '*INCFIN'
     C                   add       1             tdfinj
     C                   add       ptcube        tdfinc
640aAC                   eval      wfinw = 0
640aAC     tdfinw        add       ptswgt        wfinw
640aAC                   if        wfinw <= 99999
     C                   add       ptswgt        tdfinw
640aAC                   endif
     C                   add       ptpcs         tdfinp
     C                   add       ptqty1        tdfin1
     C                   add       ptqty2        tdfin2
     C                   add       ptqty3        tdfin3
     *
     *
     *   CLOSED totals.
     *
     *      Decrease closed totals.  Don't let totals go negative.
     *
     C                   when      #upcmd = '*DECCLS'
     C                   if        tdclsj >= 1
     C                   eval      tdclsj = tdclsj - 1
     C                   else
     C                   eval      tdclsj = 0
     C                   endif
     C                   if        ptcube <= tdclsc
     C                   sub       ptcube        tdclsc
     C                   else
     C                   eval      tdclsc = 0
     C                   endif
     C                   if        ptswgt <= tdclsw
     C                   sub       ptswgt        tdclsw
     C                   else
     C                   eval      tdclsw = 0
     C                   endif
     C                   if        ptpcs <= tdclsp
     C                   eval      tdclsp = tdclsp - ptpcs
     C                   else
     C                   eval      tdclsp = 0
     C                   endif
     C                   if        ptqty1 <= tdcls1
     C                   eval      tdcls1 = tdcls1 - ptqty1
     C                   else
     C                   eval      tdcls1 = 0
     C                   endif
     C                   if        ptqty2 <= tdcls2
     C                   eval      tdcls2 = tdcls2 - ptqty2
     C                   else
     C                   eval      tdcls2 = 0
     C                   endif
     C                   if        ptqty3 <= tdcls3
     C                   eval      tdcls3 = tdcls3 - ptqty3
     C                   else
     C                   eval      tdcls3 = 0
     C                   endif
     *
     *      Increase closed totals.
     *
     C                   when      #upcmd = '*INCCLS'
     C                   add       1             tdclsj
     C                   add       ptcube        tdclsc
     C                   add       ptswgt        tdclsw
     C                   add       ptpcs         tdclsp
     C                   add       ptqty1        tdcls1
     C                   add       ptqty2        tdcls2
     C                   add       ptqty3        tdcls3
     *
     C                   endsl
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
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
     *     PIR7872  Record not updated.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7978  Record is locked.
     *
     C     zm7978        begsr
     C                   eval      #msgid = 'PIR7978'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = ptstim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = ptetim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        ptetim < ptstim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     pttask        chain     task                               78
     C                   if        not *in79  and
     C                             tktype = 'I'
     C                   eval      ptimin = timlen
     C                   else
     C                   eval      ptdmin = timlen
     C                   endif
     *
     C     endtim        endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Task Detail
