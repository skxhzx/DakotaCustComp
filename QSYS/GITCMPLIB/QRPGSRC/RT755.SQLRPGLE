     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RT755     Remove exported route records - Post
     *  25 September, 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *
     *  Notes:
     *      - Removes records from files RTESUM, PLTSUM, PLTSTP, BATCTL,
     *        WORKZON, WORKLBL, LABEL, PIRTRAN, ORDH, ORDD, ORDC and ORDT.
416 A*        and RTECSUM and BULKDRP
510cA*        and RTENOTE and PLTMISC
     *
     *----------------------------------------------------------------
     *  Revisions
409 A*    04/21/98  RH
     *      - Recompiled, file ORDC changed.
410 A*    01/07/99  RH
     *      - Add file ORDSLCT3.
412 A*    08/23/99  RH
     *      - Recompiled, file ORDC changed.
412AA*    09/09/99  RH
     *      - Change to process PIRTRAN & LABEL rec. after WORKLBL
     *        just in case records were already deleted from WORKLBL.
413aA*    04/05/00  RH
     *      - Fix - LABEL8 excludes closed rec. change to use LABEL5.
     *
414aA*    04/20/00  MLB  4.14a
     *      - Revised the following routines: ZZORDC, ZZORDD, ZZORDH,
     *        ZZORDS, ZZORDT to seton EFLG2 only if 78 is on.
     *      - Revised the following routines: ZZBCTL, ZZLBL, ZZORDC,
     *        ZZORDD, ZZORDH, ZZORDS, ZZORDT, ZZPSTP, ZZPSUM, ZZRSUM
     *        ZZWLBL and  ZZWZON to remove 79 from all SETLL's.
     *      - Revised the following routines: ZZBCTL, ZZLBL, ZZORDC,
     *        ZZORDD, ZZORDH, ZZORDS, ZZORDT, ZZPSTP, ZZPSUM, ZZRSUM
     *        ZZWLBL and  ZZWZON to setoff EOF.
     *      - Revised mainline to not delete route header if EFLAG is on.
     *      - Fix - LABEL5 excludes closed rec. change to use LABEL13.
     *        Removed file LABEL from pgm, no longer needed.
     *
416 A*    02/14/02  MLB  4.16
     *      - Revised program to add file RTECSUM to cleanup process.
     *      - Created new routine ZZCSUM to remove compartment sum rcds.
416aA*    03/12/02  RH   4.16a
    A*      - File ORDSLCT changed, Re-compile only.
417aA*    07/08/03  RH   4.17a
    A*      - ORDT file changed, Re-compile only.
417bA*    11/13/03  RH   4.17b
    A*      - Add MULTRAN1 file to remove records.
417cA*    06/09/04  MLB  4.17c
     *      - ENH: Change to remove RUNNER records.
     *
500 A*    04/21/05  MLB  5.00
     *      - Enh: Change to remove LABELPS records.
500bA*    11/07/05  RH   5.00b
     *      - Fix: Change to use RUNNER6, Runner file key changed.
500cA*    04/12/06  RH   5.00c
     *      - Enh: Change to remove BULKDRP records.
500dA*    06/04/06  MLB  5.00d
     *      - Fix: Revised pgm to loop when removing records from
     *        file RUNNER6. There can be multiple rcds with the
     *        same label number.
500eA*    06/04/06  MLB  5.00e
     *      - Enh: Converted program to ILE.
     *      - Added files ORDBOX, ORDEXPDTE, ORDDM for order
     *        cleanup processing.
510aA*    11/10/06  RH   5.10a (MLB orig 5.00 & 5.00a in PIRSTD)
     *      - Enh: Change to remove ORDDS records.
     *      - Enh: Revised program to add file ORDLBL1 to clean up.
510bA*    05/30/07  MLB  5.10b
     *      - Enh: Added file PIRSEQ1 for order cleanup
     *        processing.
510cA*    10/02/07  LMC  5.10c
     *      - Enh: Added files RTENOTE and PLTMISC for cleanup process
     *      - Created new routine ZZNOTE to remove route notes records.
     *      - Created new routine ZZPMSC to remove pallet misc records.
510dA*    10/03/07  LMC  5.10d
     *      - Fix: Eof indicator was in the wrong position which was
     *        causing the program to loop in the ZZSEQ1 routine.
520aA*    10/10/07  LMC  5.20a  P#00023
     *      - Enh: Added purging to history files instead of just
     *        deleting the records.
     *        NOTE - if this is moved to client site, make sure
     *        positions 33-35 of opdata in options is initilized.
520bA*    02/04/08  LMC  5.20b  P#00009
     *      - Enh: Per Max don't write extended history on routes
     *        that are status 8 or 9
520cA*    03/06/08  GJA  5.20c  P#00023
     *      - Enh: Include ORDHH & RTEHEDH files for extended
     *        history. Added extended history option
     *      - Fix: Code was turning on error flag if no BULKDRP
     *        records was found, it should only turn on error flag
     *        if delete is in error
520dA*    01/30/09  GJA  5.20d
     *      - Enh: Include ORDP file to be purged with route
520 A*    01/22/09  MLB  5.20e
     *      - Enh: Add new file, RTESTP to clean-up process. RTESTP
     *        holds extended length stop numbers for Customer Orders.
530a *    07/05/10  GJA  5.30a
     *      - Enh: Add new file, TOTEBUND to clean-up process.
530b *    07/05/10  GJA  5.30b
     *      - Enh: Add new files, LDRHHDR and LDRHDETL to clean
     *             up process for Loader Module
530cA*    10/27/10  MLB  5.30c
     *      - Enh: Add new file, TOTEHDR to be purged with route.
     *
640aA*    10/06/09  JCJ  5.20a
     *      - Enh: Add new file, ORDBSUM to clean-up process. ORDBSUM
     *        is used for Batch Pick Processing.
640bA*    03/06/12  LMC  6.40b
     *      - Enh: Add new file, PREXREF3 to clean-up process.
640cA*    05/09/12  MLB  6.40c
     *      - Fix: Revised to add file, ORDHM2 to cleanup process.
     *
640dA*    06/07/12  RBD  6.40d
     *      - Fix: Revised to add Trax files TTITM, TTLOG, TTMERG,
     *        TTRTE, TTRTN, TTSTP, TTSTPFLG, and TTTRX to the
     *        cleanup process. Will only execute for Trax users.
640eA*    06/12/12  LMC  6.40e
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
640fA*    07/11/12  LMC  6.40f
     *      - Enh: Added totedata file for cleanup.
     *
650aA*    02/04/13  LMC  6.50a
     *      - Fix: ORDDM was not being cleaned up, code was only
     *        executing if an error was encoutered on the delete
     *        of the ORDD record. Added an else to the logic.
     *
650bA*    02/04/13  RBD  6.50b
     *      - TTSTPFLG changed.
     *
650cA*    03/19/13  LMC  6.50c
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
     *
650dA*    08/26/13  RBD  6.50d
     *      - Recompiled, TTLOG file changed.
     *
650eA*    04/14/14  LMC  6.50e
     *      - Enh: Added RTEINUSE file for cleanup.
     *
650fA*    11/26/14  RBD  6.50f
     *      - Enh: Added TTGRP file for cleanup, Trax users only.
     *
650gA*    01/20/15  RBD  6.50g
     *      - Recompiled, LDRHDETL file changed.
     *
650hA*    11/25/14  JCJ  650c
     *      - Recompiled for TOTEDATA change of TGSEQ# from 3,0 to 5,0
     *
650iA*    06/13/13  RBD  6.50i
     *      - Recompiled, RTESTP changed.
     *
700aA*    07/01/15  LMC  700a
     *      - Enh: Added RTETRAILER, RTELM.
     *      - Enh: TTRTE is no longer for Trax only, needs to execute
     *        for non trax customers. Used by GUI going forward.
     *
700bA*    08/06/15  NLK  700b
     *      - Enh: Added AMPxRef
     *
700cA*    09/03/15  DLS  700c
     *      - Added PLTSUMU for cleanup.
700dA*    04/12/16  LMC  7.00d
     *      - Moved the move to populate $kwhse into the inzsr
     *        routine. If no records exist in the file, the cycle
     *        hits LR, and executes the wrttran log cleanup but sends
     *        warehouse 0. This causes a BFCWTD000 job to be started
     *        on the clients box.
     *
700eA*    09/29/16  RBD  7.00e
     *      - Added Trax Training Routes file.  Don't do any cleanup
     *        for these routes, for as long as they exist in TTTRAIN
     *        they should be available for Trax training.
     *
710a *    02/22/17  GJA  7.10a
     *      - Added VOEXCP RF Selection and UPC exceptions.
710b *    07/10/17  LMC  7.10b
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
710c *    09/12/17  LMC  7.10c
     *      - Enh: Added cleanup for file ORDCFLG.
710d *    10/09/17  RBD  7.10d
     *      - Fix: Added Loader users for file TTMERG.
710eA*    08/02/17  JCJ  710e
     *      - Enh: Added CADECRTE
710fA*    06/13/13  RBD  7.10f
     *      - Recompiled, RTESTP changed.
720aA*    01/24/18  LMC  7.20a
     *      - Added history file ORDDH.
     *
720bA*    12/13/18  RBD  7.20b
     *      - Enh: Added TTEXCP file for cleanup, Trax users only.
     *
720cA*    12/20/18  LMC  7.20c
     *      - Enh: Added RTEHEDEXA file for cleanup.
     *
730aA*    05/30/19  KDE  7.30a
     *      - Enh: Added TTPICS file for cleanup
     *
730bA*    08/29/19  RBD  7.30b
     *      - Enh: Added TTSTPFR file for cleanup, Trax users only.
     *
730cA*    10/15/19  DAS  7.30d
     *      - Revised to use PIRTRANW, MULTRAN1W
     *
740aA*    05/08/20  NLK  7.40a
     *      - Added PirTran LOAD records which no Label rcds exist
     *        Never cleaned up and caused issue linking with New tran#
     *        Current tran#s wouldn't close if these OLD rcds linked
     *
740bA*    05/19/20  NLK  7.40b
     *      - FIX: zzvoexcp only cleans up last tran#, this needs to
     *        be moved to zzlbl when each trn# is processed.
740cA*    06/24/20  MLB  7.40c
     *      - Fix: Revised pgm to add missing code for v6.50e mod
     *        that was lost for cleanup of RTEINUSE.
740dA*    09/23/20  KDE  7.40d
     *      - Enh: Add cleanup for GLORTELOG, RTETRCK and DDLOG
740eA*    12/01/20  LMC  7.40e
     *      - Enh: Add uciinfo cleanup for selection labels
     *
740fA*    12/15/20  RBD  7.40f
     *      - Enh: Add cleanup for TTIVC, TTIVCH, TTIVCD and TTIVCC
     *        for Trax users.
750 A*    06/14/21  KDE  7.50
     *      - Enh: Add SRRTE and SRORD cleanup
750aA*    06/16/21  KDE  7.50a
     *      - Enh: Add ITEMSUBLOG
750bA*    03/18/22  LMC  7.50b
     *      - Fix: Mod 740b was causing only one label & pirtran
     *        record to be processed, because zzvoexcp has a do loop
     *        that chgs the value of EOF to 1, which then causes the
     *        do loop on the label to no longer process.
     *        change voexcp to not modify the value of eof.
760 A*    04/18/22  KDE  7.60
     *      - Enh:  Add files ELSSTDDTL, ELSSTDLOG and APTSELWK
760aA*    05/02/22  KDE  7.60a
     *      - Enh:  Add file APTDATA
760bA*    05/06/22  KDE  7.60b
     *      - Enh:  Add misc., cleanup for ELS files
760cA*    06/16/22  LMC  7.60c
     *      - Enh:  Add cleanup for labelout file
770aA*    05/08/23  NLK  7.70a
     *      - FIX:  zztotedata inside if opishs = 0
     *        This is no longer true and is controlled by
     *        route cleanup.
770bA*    05/15/23  KDE  7.70b
     *      - Enh:  Add cleanup for labelexa file
770cA*    08/09/23  KDE  7.70c
     *      - Enh:  Add cleanup for ddtaskh, dddetailh after removal from rt755h
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
     *
HAR A*    07/19/06  RMC  HAR
     *      - Enh: Add subroutine to delete route from TXFTPLOG,
     *        Tax-Right FTP log file.
HARaA*    08/18/11  RBD  HARa
     *      - Enh: Added file ORDAD to clean-up process.
     *
     *----------------------------------------------------------------
     * Indicators
     *
510aA*  71        - Error deleting record from ORDDS
500 A*  72        - Error deleting record from LABELPS
500 A*  73        - EOF for LABELPS
     *  79        - EOF for FILES
740aA*  80        - reade PirTran15
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Frtehed    up   e           k disk
720cAFrtehedexa uf   e           k disk
740cAFrteinuse  uf   e           k disk
     Frtesum    uf   e           k disk
416 AFrtecsum   uf   e           k disk
510cAFrtenote   uf   e           k disk
520eAFrtestp    uf   e           k disk
700cAFpltsumu   uf   e           k disk
     Fpltsum1   uf   e           k disk
     Fpltstp1   uf   e           k disk
510cAFpltmisc   uf   e           k disk
     Fbatctl2   uf   e           k disk
     Fworkzon1  uf   e           k disk
     Fworklbl7  uf   e           k disk
414aD*LABEL   UF  E           K        DISK
413AD*ABEL8  IF  E           K        DISK
413aD*LABEL5  IF  E           K        DISK
414aMFLabel13   uf   e           k disk
500 AFLabelps   uf   e           k disk
730cDF*irtran   uf   e           k disk
730cMFpirtranw  uf   e           k disk
740aAFpirtran15 uf   e           k disk    rename(ptrec:ptrec15)
HARaAFordad     uf   e           k disk
     Fordh3     uf   e           k disk
640cAFordhm2    uf   e           k disk
     Fordd      uf   e           k disk
510aAFordds     uf   e           k disk
     F                                     rename(osrec:ossrec)
500eAForddm     uf   e           k disk
500eAFordbox    uf   e           k disk
640aAFordbsum1  uf   e           k disk
500eAFordexpdte uf   e           k disk
     Fordc      uf   e           k disk
510aAFordlbl1   uf   e           k disk
     Fordt      uf   e           k disk
410 AFordslct3  uf   e           k disk
510bAFpirseq1   uf   e           k disk
730cDF*ultran1  uf   e           k disk
730cMFmultran1w uf   e           k disk
500bD*UNNER  UF  E           K        DISK
500bMFrunner6   uf   e           k disk
500cAFbulkdrp   uf   e           k disk
520aAFpirtranh  o  a e             disk    rename(ptrec:ptrech)
640bAFprexref3  uf   e           k disk
700bAFampxref3  uf   e           k disk
700aAFrtetraileruf   e           k disk
700aAFrtelm     uf   e           k disk
520aAFlabelh    o  a e             disk    rename(lbrec:lbrech)
HAR AFtxftplog  uf   e           k disk    usropn
520cAFordhh     o  a e             disk    rename(ohrec:ohrech)
720aAForddh     o  a e             disk    rename(odrec:odrech)
520cAFrtehedh   o  a e             disk    rename(rhrec:rhrech)
520cAFoptions   if   e           k disk
520dAFordp      uf   e           k disk
530aAFtotebund2 uf   e           k disk
530cAFtotehdr   uf   e           k disk
720bAFttexcp    uf   e           k disk
640dAFttitm     uf   e           k disk
650fAFttgrp     uf   e           k disk
640dAFttlog     uf   e           k disk
730aAFttpics    uf   e           k disk
640dAFttmerg    uf   e           k disk
640dAFttrte     uf   e           k disk
640dAFttrtn3    uf   e           k disk
640dAFttstp     uf   e           k disk
640dAFttstpflg  uf   e           k disk
730bAFttstpfr   uf   e           k disk
640dAFtttrx     uf   e           k disk
640fAFtotedata  uf   e           k disk
530bAFldrhhdr   uf   e           k disk
530bAFldrhdetl  uf   e           k disk
700eAFtttrain   if   e           k disk
710aAFvoexcp    uf   e           k disk
710eAFcadecrte  uf   e           k disk
710cAFordcflg   uf   e           k disk
760CAFlabelout  uf   e           k disk
HAR A
HAR A*----------------------------------------------------------------
HAR A*  Customer id
HAR A*----------------------------------------------------------------
HAR A
HAR A /copy qcopysrc,id#harbor
740eA*----------------------------------------------------------------
740eA*  DRI parameters
740eA*----------------------------------------------------------------

740eA /COPY *libl/qcopysrc,C#DRIPARMP
740eA /COPY *libl/qcopysrc,C#DRIPARMS

650cA*----------------------------------------------------------------
650cA*  Data Formats
650cA*----------------------------------------------------------------
650cA /COPY *libl/qcopysrc,C#CWLOG
740eA /COPY *libl/qcopysrc,C#UCIINFO
650cAD savever#        s                   like($cwver#)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
640eA*----------------------------------------------------------------
640eA*  Prototypes
640eA*----------------------------------------------------------------
650cA /copy qcopysrc,p.cw800
740eA /copy qcopysrc,p.driuci
640eA
640eAD wrttran1        pr                  extpgm('WRTTRAN1')
640eA * Input
640eAD   ppcmd                        8
640eAD   ppwait                       2  0
640eAD   ppwhse                       3  0
640eAD   pptran#                      7  0
640eAD   ppfromdate                   8  0
640eAD   pptodate                     8  0
640eAD   ppemp#                       5  0
520cA*----------------------------------------------------------------
520cA*  *SYSTEM  -  System options.
520cA*----------------------------------------------------------------
520cA*
520cA* Fields
520cA*
520cA*    OPEPM   -  Using EPM module (Y,N).
520cA*    OPRF    -  Using RF module (Y,N).
520cA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
520cA*    OPLETD  -  Print letdown labels (Y,N).
520cA*    OPWRNC  -  Perform catch weight variance check (Y,N).
520cA*    OPRG1C  -  Catch weight low variance percentage.
520cA*    OPRG2C  -  Catch weight high variance percentage.
520cA*    OPIMPI  -  Import Item fields (Y,N).
520cA*    OPICW   -  Individual catch weight entry (Y,N).
520cA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
520cA*    OPRCDY  -  Number of days to keep receiving logs.
520cA*    OPMPCK  -  Number of days to keep picking logs.
520cA*    OPRTHS  -  Number of weeks - exported routes to keep.
520cA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
520cA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
520cA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
520cA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
520cA*    OPISHS  -  Number of weeks - extra history files to keep.
520cA*
520cA* Data structure
520cA*
710dDD*opdata          ds
710dMD opdat1          ds
520cAD  opepm                  1      1
520cAD  oprf                   2      2
520cAD  opcapc                 3      3
520cAD  opletd                 4      4
520cAD  opwrnc                 5      5
520cAD  oprg1c                 6      8  1
520cAD  oprg2c                 9     11  1
520cAD  opimpi                12     12
520cAD  opicw                 13     13
520cAD  opmpck                14     14
520cAD  oprcdy                15     15  0
520cAD  oppkdy                16     16  0
520cAD  oprths                17     19  0
520cAD  opcrhs                20     22  0
520cAD  oppohs                23     25  0
520cAD  opiahs                26     28  0
520cAD  opmshs                29     31  0
520cAD  opishs                33     35  0
640dAD  optrax                39     39
710dDD* optend               117    117
710dMD  opten1               117    117
     *----------------------------------------------------------------
710dA*  *RUNNER  -  PIR Runner Flag Options
710dA*----------------------------------------------------------------
710dA*
710dA* Fields
710dA*
710dA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
710dA*    OPUPLR  -  Update Label with quantity shorted during manual
710dA*               flag entry (Y/N)
710dA*               NOTE: Any change to this field will cause OPUPLV
710dA*                     in the *VOICE options record to be updated.
710dA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
710dA*               & create Priority Replenishment if necessary.
710dA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
710dA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
710dA*    OPRNRM  -  Send break message to user when new Runner
710dA*               task has been assigned. (Y/N)
710dA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
710dA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
710dA*    OPRPCK  -  Print Runner pick list. (Y/N)
710dA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
710dA*               printer, 2=Belt printer
710dA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
710dA*    OPRSCN  -  Scan tran# or label# to start pick.
710dA*                 1=tran#, 2=label#.
710dA*    OPRVFS  -  Verify pick slot, Y/N.
710dA*    OPRVFQ  -  Verify qty found, Y/N.
710dA*    OPRLOA  -  Using loader module, Y/N.
710dA*
710dA* Data structure
710dA*
710dAD opdat2          ds
710dAD  opcrtm                 1      1
710dAD  opuplr                 2      2
710dAD  oprplf                 3      3
710dAD  opmrgf                 4      4
710dAD  opclrf                 5      5
710dAD  oprnrm                 6      6
710dAD  opclsf                 7      7
710dAD  opoutf                 8      8
710dAD  oprpck                 9      9
710dAD  oprlbl                10     10
710dAD  oprbdu                11     11
710dAD  oprscn                12     12
710dAD  oprvfs                13     13
710dAD  oprvfq                14     14
710dAD  oprloa                15     15
710dAD  opten2               117    117
710dA*
     *----------------------------------------------------------------
     *  Working variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D eflag           s              1
     D eflg2           s              1
     D eof             s              1
     D forevr          s              1
740aAD forever         s              1
520cAd kycode          s                   like(opcode)
520cAd kywhse          s                   like(opwhse)
740aAD loadtxt         s              6    inz('LOAD  ')
740aAD rhrtidx         s              9
720bAd whsea           s              3
640eAD wrtpcmd         s             10
640eAD wrtpwait        s              2  0
640eAD wrtpwhse        s              3  0
640eAD wrtptran#       s                   like(pttrn#)
640eAD wrtpfrmdate     s              8  0
640eAD wrtptodate      s              8  0
640eAd wrtpemp#        s                   like(ptemp#)
650cAD CWcmd           s             10
650cAD CWpgm           s             10
650cAD CWrtn           s             10
650cAD CWmsg           s             60
650cAD CWdata          s            512
650cAD processstatus   s             10
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
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
740eA*----------------------------------------------------------------
740eA*  Called program flags
740eA*----------------------------------------------------------------

740eAD driUciCalled    s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
700dDC*                  move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     C                   if        rhwhse <> $kwhse  or
     C                             rhexpd >= $kdate
     C                   goto      bottom
     C                   endif

     *  Don't cleanup Trax training route
700eAC     keyrs         chain     tttrain
700eAC                   if        %found(tttrain)
700eAC                   goto      bottom
700eAC                   endif

414aAC                   eval      eflag = *off
     *  Delete exported Route summary records.
     C                   exsr      zzrsum
416 A*  Delete exported Route compartment summary records.
416 AC                   exsr      zzcsum
740cA*  Delete exported Route Inuse records.
740cAC                   exsr      zzrteinuse
510cA*  Delete exported Route note records.
510cAC                   exsr      zznote
520eA*  Delete exported Route note records.
520eAC                   exsr      zzextstop
530aA*  Delete exported Route tote and bundle records
530aAC                   exsr      zztotbun
530bA*  Delete exported Route loader module records
530bAC                   exsr      zzload
     *  Delete exported BATCTL records.
     C                   exsr      zzbctl
     *  Delete exported Pallet stop records.
     C                   exsr      zzpstp
     *  Delete exported Pallet summary records.
     C                   exsr      zzpsum
510cA*  Delete exported Pallet Misc records.
510cAC                   exsr      zzpmsc
     *  Delete exported WORKZON records.
     C                   exsr      zzwzon
     *  Delete exported WORKLBL records.
     C                   exsr      zzwlbl
750 A*  Delete Super Route records (SRRTE, SRORD)
750 AC                   exsr      zzsr
750aA*  Delete Item Substitution log (ITEMSUBLOG)
750aAC                   exsr      zzitmslog
760 A*  Delete ELSSTDDTL and ELSSTDLOG
760 AC                   exsr      zzelsfiles
760 A*  Delete APTSELWK (APT Selection Work File)
760 AC                   exsr      zzaptsel
412AA*  Delete exported PIRTRAN records.
412AA*  Delete exported LABEL records.
412AAC                   exsr      zzlbl
740aA*  Delete LOADR task records in PirTran.
740aAC                   exsr      zzloadr
     *  Delete exported ORDH order head records
     C                   exsr      zzordh
640cA*  Delete exported ORDHM2 order header misc records
640cAC                   exsr      zzordhm
510aA*  Delete exported ORDLBL1 order detail label records.
510aAC                   exsr      zzolbl
510bA*  Delete exported PIRSEQ1 label records.
510bAC                   exsr      zzseq1
640aA*  Delete exported ORDBSUM1 records.
640aAC                   exsr      zzordbsum
520dA*  Delete associated ORDP records
520dAC                   exsr      zzordp
530cA*  Delete associated TOTEHDR records
530cAC                   exsr      zztotehdr
640bA*  Delete associated PREXREF3 records
640bAC                   exsr      zzprexref
700bA*  Delete associated AMPXREF3 records
700bAC                   exsr      zzampxref
700aA*  Delete associated RTETRAILER records
700aAC                   exsr      zzrtetrailer
700aA*  Delete associated RTELM records
700aAC                   exsr      zzrtelm
720cA*  Delete associated RTEHEDEXA records
720cAC                   exsr      zzrtehedexa
700aM*    Moved so this executes for all clients, not just Trax.
700aM*    Gui TB allows driver to be assigned.
700aM*    Delete associated TTRTE records
700aMC                   exsr      zzttrte
700cA*  Delete exported PLTSUMU records
700cAC                   exsr      zzpltsumu
740b *  Delete associated VOEXCP records
740bM *           **     exsr      zzvoexcp
710eA*  Delete associated CADECRTE records
710eAC                   exsr      zzcadecrte
760cA*  Delete LABELOUT
760cAC                   exsr      zzlabelout
     *
640dA*  Clean up Trax files if this is a Trax user.
640dAC                   if        optrax = 'Y'
640dA*    Delete associated TTITM records
640dAC                   exsr      zzttitm
640dA*    Delete associated TTLOG records
640dAC                   exsr      zzttlog
730aA*    Delete associated TTPICS records
730aAC                   exsr      zzttpics
710dD**   Delete associated TTMERG records
710dDC**                 exsr      zzttmerg
700aD*    Delete associated TTRTE records
700aDC*                  exsr      zzttrte
640dA*    Delete associated TTRTN records
640dAC                   exsr      zzttrtn
640dA*    Delete associated TTSTP records
640dAC                   exsr      zzttstp
640dA*    Delete associated TTSTPFLG records
640dAC                   exsr      zzttstpflg
640dA*    Delete associated TTTRX records
640dAC                   exsr      zztttrx
650fA*    Delete associated TTGRP records
650fAC                   exsr      zzttgrp
720bA*    Delete associated TTEXCP records
720bAC                   exsr      zzttexcp
730bA*    Delete associated TTSTPFR records
730bAC                   exsr      zzttstpfr
740fA*    Delete associated Trax invoice records
740fAC                   exsr      zzinvoice
640dAC                   endif
     *
710dA*  Clean up TTMERG file if Trax or Loader user.
710dAC                   if           optrax = 'Y'
710dAC                             or oprloa = 'Y'
710dAC                   exsr      zzttmerg
710dAC                   endif
     *
     *  Delete exported route header record.
     *
414a C                   if        eflag = *off
520cAC                   if        opishs <> 0
520cAC                   Select
520cAC                   when      rhstat = '8'
520cAC                   when      rhstat = '9'
520cAC                   other
520cAC                   write     rhrech
520cAC                   endsl
520cAC                   endif
     C                   add       1             errecs
     C                   delete    rhrec                                79
414aAC                   endif
HAR A*  Delete exported Tax-Right records
HAR AC                   select
HAR AC                   when        client = HARBOR
HAR AC                   exsr      zztxftp
HAR AC                   endsl
HAR A*
     C     bottom        tag

770cA*  Delete normal ddtask and dddetail
740dAclr                 exsr      zzdd2files
770cA*  Delete ddtaskh and dddetailh
770cAClr                 exsr      zzdd2merge
640eACLR                 exsr      zzwrttrandlog
760bACLR                 exsr      zzclnels
     CLr                 exsr      zm0750
740eAclr                 exsr      zzclose
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
HAR A*  Get client id.
HAR A
HAR AC                   call      'GETCLIENT'
HAR AC                   parm                    client           10
     *
     c* moved from mainline - if LR with no records $kwhse is 0
700dMC                   move      $pwhse        $kwhse
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     *   Define partial key for RTESUM, PLTSUM,PLTSTP file.
416 A*     and RTECSUM.
510cA*     and RTENOTE and PLTMISC
730aA*     and TTPICS
740cA*     and RTEINUSE
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
413aA*
413aA*   Define partial key for LABLE5 file.
413aA*
413aAC     keylb         klist
413aAC                   kfld                    rhwhse
414aD*R                   KFLD           RHTYPE
413aAC                   kfld                    rhrtid
740a *   Define partial key for PirTran15 file
740a *
740aAC     keyrtidd      klist
740aAC                   kfld                    rhwhse
740aAC                   kfld                    rhrtidx
740aAC                   kfld                    loadtxt
740aAC                   kfld                    rhexpd
740aAC     keyrtid       klist
740aAC                   kfld                    rhwhse
740aAC                   kfld                    rhrtidx
740aAC                   kfld                    loadtxt
500 A*
500 A*   Define partial key for LABELPS file.
500 A*
500 AC     keyls         klist
500 AC                   kfld                    lbwhse
500 AC                   kfld                    lblbl#
500 A*
500cA*   Define key for BULKDRP file.
500cA*
500cAC     keybd         klist
500cAC                   kfld                    lblbl#
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
710aA*
710aA*   Define partial key for VOEXCP file.
710aA*
710aAC     keyvo         klist
710aAC                   kfld                    ptwhse
710aAC                   kfld                    pttrn#
     *
530bAC     keyld         klist
530bAC                   kfld                    rhwhse
530bAC                   kfld                    rhrte
530bAC                   kfld                    rhrtid
     *
     *
520cA*
520cA*    Define full key for file OPTIONS.
520cA*
520cAC                   eval      kywhse = *zeros
520cAC                   eval      kycode = '*SYSTEM '
520cAC     keyop         klist
520cAC                   kfld                    kywhse
520cAC                   kfld                    kycode
730aA*
730aA*   Define key for pirtranw
730aA*
730aAC     keypt         klist
730aAC                   kfld                    lbwhse
730aAC                   kfld                    lbtrn#
520cA*
520cA*    Retrieve System options.
520cA*
520cAC     keyop         chain     options                            79
520cAC                   if        *in79
520cAC                   eval      opishs = 0
710dAC                   else
710dAC                   eval      opdat1 = opdata
520cAC                   endif

710dA*
710dA*    Retrieve Runner options.
710dA*
710dAC                   eval      kywhse = $kwhse
710dAC                   eval      kycode = '*RUNNER '
710dAC     keyop         chain     options                            79
710dAC                   if        not %found
710dAC                   eval      oprloa = 'N'
710dAC                   else
710dAC                   eval      opdat2 = opdata
710dAC                   endif
     C                   endsr
650cA*----------------------------------------------------------------
650cA*  clrCWLog     Clear $cwlog   data structure fields
650cA*----------------------------------------------------------------

650cA /free
650cA   begsr ClrCWLog;

650cA     savever# = $cwver#;
650cA     clear $cwlog;
650cA     $cwver# = savever#;
650cA     $cwaddemp = 0;
650cA     $cwaddusr = ' ';
650cA     $cwaddpgm  = ' ';
650cA     $cwaddjob  = ' ';
650cA     $cwaddnbr = ' ';

650cA   endsr;
650cA /end-free

650cA*----------------------------------------------------------------
650cA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650cA*----------------------------------------------------------------

650cA /free
650cA   begsr processCWlog;
650cA     exsr clrCWLog;
650cA     $cwwhse = ocwhse;
650cA     $cwitem = ocitem;
650cA     $cwseltrn# = octran;
650cA     $cwsellbl# = oclbl#;
650cA     $cwselord  = ocord;
650cA     $cwselseq  = ocseq#;
650cA     $cwselcseq = ocseq;
650cA     $cwwgtlbs = occwgt;
650cA     $cwentflg = 3;

650cA     cwdata = $cwlog;
650cA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650cA     $cwlog = cwdata;

650cA   endsr;
650cA /end-free
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
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     C     zm0750        begsr
     C                   eval      #msgid = 'PIR0750'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZBCTL  Delete exported BATCTL records for route id.
     *
     C     zzbctl        begsr
     *
     *  Delete exported BATCTL records.
     *
414aD*R         KEYRS     SETLLBATCTL2              79
414aMC     keyrs         setll     batctl2
414aD*R                   MOVE *IN79     EOF     1
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     batctl2                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    btrec                                78
414aAC                   if        not *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
740eA*---------------------------------------------------------------
740eA*
740eA*    ZZCLOSE close dri programs called
740eA*
740eAC     zzclose       begsr
740eA /free
740eA    if driUCICalled;
740eA      driuciinfo('%CLOSE': $pprogram: $drireturn: $drimessage:
740eA               $dridata: $dridata2);
740eA    endif;
740eA
740eA /end-free
740eAC                   endsr
740dA*---------------------------------------------------------------
740dA*
740dA*    ZZDD2FILES  Purge DD2 files based on RTEHED
740dA*
740dAC     zzdd2files    begsr
     *
     *  DDTASK and DDDETAIL are automatically cleaned up
     *  within OR605 with program DD2DTAMOVE.  These SQL's
     *  are here in case anything is not moved that should be
     *---Insert any records to History that should be

     c                   monitor
     C/EXEC SQL
     C+  insert into ddtaskh
     C+  select ddtask.* from ddtask,rtehed
     C+  where ddtwhse=rhwhse and ddtrtid=rhrtid and rhstat>3
     C/END-EXEC
     c                   on-error
     c                   endmon

    A*---Delete same records from Live
     c                   monitor
     C/EXEC SQL
     C+  delete from ddtask as t
     C+  where (select count(*) from rtehed as r where t.ddtwhse=r.rhwhse and
     C+  t.ddtrtid=r.rhrtid and r.rhstat>3)<>0
     C/END-EXEC
     c                   on-error
     c                   endmon
     *
    A*---Insert any records to History that should be

     c                   monitor
     C/EXEC SQL
     C+  insert into dddetailh
     C+  select dddetail.* from dddetail,rtehed
     C+  where dddwhse=rhwhse and dddrtid=rhrtid and rhstat>3
     C/END-EXEC
     c                   on-error
     c                   endmon

    A*---Delete same records from Live
     c                   monitor
     C/EXEC SQL
     C+  delete from dddetail as d
     C+  where (select count(*) from rtehed as r where d.dddwhse=r.rhwhse and
     C+  d.dddrtid=r.rhrtid and r.rhstat>3)<>0
     C/END-EXEC
     c                   on-error
     c                   endmon
     *
     *  Will add purge to DDTASKH and DDDETAILH based on RTEHED
     *  once we have the stats being captured from this data
     *  Will also add GLORTELOG once stats being populted
     *
     *  Purge route ids from RTETRCK no longer in RTEHED
     *
     c                   monitor
     C/EXEC SQL
     C+  delete from rtetrck as rt
     C+  where (select count(*) from rtehed as r where r.rhwhse=rt.rttwhs and
     C+  r.rhrtid=rt.rttrid)=0
     C/END-EXEC
     c                   on-error
     c                   endmon
     *
     *  Purge route ids from DDLOG no longer in RTEHED
     *
     c                   monitor
     C/EXEC SQL
     C+  delete from ddlog as d
     C+  where (select count(*) from rtehed as r where r.rhwhse=d.ddlwhse and
     C+  r.rhrtid=d.ddlrtid)=0
     C/END-EXEC
     c                   on-error
     c                   endmon
740dAC                   endsr
520eA*---------------------------------------------------------------
520eA*
520eA*    ZZEXTSTOP  Delete RTESTP records for route.
520eA*
520eAC     zzextstop     begsr
     *
     C     keyrs         setll     rtestp
     C                   dou       %eof(rtestp)
     C     keyrs         reade     rtestp
     C                   if        not %eof(rtestp)
     C                   delete    rtsrec
     C                   endif
     C                   enddo
     *
520 AC                   endsr
740fA*---------------------------------------------------------------
740fA*
740fA*    ZZINVOICE  Purge Trax invoice files:
740fA*               TTIVC, TTIVCH, TTIVCD, TTIVCC
740fA*

      /free
       begsr zzinvoice;

         // Trax invoice file
         exec sql delete from ttivc
              where ttvwhs=:rhwhse and ttvrti=:rhrtid;

         // Trax invoice order header
         exec sql delete from ttivch
              where tvhwhs=:rhwhse and tvhrteid=:rhrtid;

         // Trax invoice order detail
         exec sql delete from ttivcd
              where tvdwhs=:rhwhse and tvdrteid=:rhrtid;

         // Trax invoice catch weights
         exec sql delete from ttivcc
              where tvcwhs=:rhwhse and tvcrteid=:rhrtid;

       endsr;

      /end-free

412AA*---------------------------------------------------------------
412AA*
412AA*    ZZLBL   Delete exported LABEL/PIRTRAN records for route id.
412AA*
412AAC     zzlbl         begsr
412AA*
412AA*  Delete dependent LABEL and PIRTRAN records.
412AA*
413aD*          KEYRS     SETLLLABEL8               79
414aD*R         KEYLB     SETLLLABEL5               79
414aMC     keylb         setll     label13
414aD*R                   MOVE *IN79     EOF
414aMC                   eval      eof = *off
412AAC                   dow       eof = *off
413AD*          KEYRS     READELABEL8                   79
414aD*R         KEYLB     READELABEL5                   79
414aMC     keylb         reade     label13                                79
412AAC                   move      *in79         eof
412AAC                   if        not *in79
413AD*          L8LBL#    CHAINLABEL                77
414aD*R         L5LBL#    CHAINLABEL                77
414aD*R         *IN77     IFEQ *OFF
520aAT* Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520bAC                   Select
520bAC                   when      rhstat = '8'
520bAC                   when      rhstat = '9'
520bAC                   other
520aAC                   write     lbrech
520bAc                   endsl
520aAC                   endif
412AAC                   delete    lbrec                                77
414aAC                   if        *in77
414aAC                   move      *in77         eflag
414aAC                   endif
740eA /free
740eA   if opishs = 0;
740eA     exsr zzuci;
740eA   endif;
740eA /end-free
414aD*R                   ENDIF
413AD*          L8TRN#    CHAINPIRTRAN              77
414aD*R         L5TRN#    CHAINPIRTRAN              77
730cDC**   lbtrn#        chain     pirtran                            77
730cMC     keypt         chain     pirtranw                           77
412AAC                   if        not *in77
520aA * Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520bAC                   Select
520bAC                   when      rhstat = '8'
520bAC                   when      rhstat = '9'
520bAC                   other
520aAC                   write     ptrech
520bAC                   endsl
520aAC                   endif
412AAC                   delete    ptrec                                77
414aAC                   if        *in77
414aAC                   move      *in77         eflag
414aAC                   endif
640eAc                   if        opishs = 0
640eAc                   exsr      zzwrttrand
770aM ** moved below     exsr      zztotedata
640eAc                   endif
770a *  Delete associated TOTEDATA records
770aMc                   exsr      zztotedata
740b *  Delete associated VOEXCP records
740bMC                   exsr      zzvoexcp
412AAC                   endif
     *
710cA* Remove ORDCFLG records
710cA /free
710cA    setll (lbwhse: lbtrn#) ordcflg;
710cA    dow forevr = forevr;
710cA      reade (lbwhse: lbtrn#) ordcflg;
710cA      if %eof(ordcflg);
710cA        leave;
710cA      endif;
710cA      delete ocfrec;
710cA    enddo;
710cA /end-free
     *
730cDC**   lbtrn#        chain     multran1                           77
730cMC     keypt         chain     multran1w                          77
417bAC                   if        not *in77
417bAC                   delete    murec                                77
417bAC                   if        *in77
417bAC                   move      *in77         eflag
417bAC                   endif
417bAC                   endif
417cA*
417cA*    Remove label record from Runner file.
500bD*          LBLBL#    SETLLRUNNER                   75
500bMC     keyls         setll     runner6                                75
417cAC                   if        *in75
417cAC                   eval      *in75 = *off
500bD*          LBLBL#    CHAINRUNNER               75
500dMC     keyls         reade     runner6                                75
500dD*          *IN75     IFEQ *OFF
500dMC                   dow       not *in75
417cAC                   delete    rurec                                74
417cAC                   if        *in74
417cAC                   move      *in74         eflag
417cAC                   endif
500dAC     keyls         reade     runner6                                75
500dD*                    ENDIF
500dMC                   enddo
417cAC                   endif
500 A*
500 A*    Remove label records from LABELPS file.
500 AC     keyls         setll     labelps                                73
500 AC                   if        *in73
500 AC                   eval      *in73 = *off
500 AC                   dow       forevr = forevr
500 AC     keyls         reade     labelps                                73
500 AC                   select
500 AC                   when      *in73
500 AC                   leave
500 AC                   when      not *in73
500 AC                   delete    lsrec                                72
500 AC                   if        *in72
500 AC                   move      *in72         eflag
500 AC                   endif
500 AC                   endsl
500 AC                   enddo
500 AC                   endif
     *
500cA*
500cA*    Remove records from BULKDRP file by label
500cAC     keybd         chain     bulkdrp                            71
500cAC                   if        not *in71
500cAC                   delete    bdrec                                71
520cdC*                  else                                           71
520cAC                   if        *in71
500cAC                   move      *in71         eflag
520cAC                   endif
500cAC                   endif
     *
412AAC                   endif
412AAC                   enddo
412AAC                   endsr
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZLOADR  Delete LOAD task records in PirTran from Loader
740aA*
740aAC     zzloadr       begsr
740a * Remove PirTran LOAD records, no LABEL link, read by rhrtid
740a *    Here I read many trn#s / don't remove if cdte=0
740aAC                   eval      rhrtidx = rhrtid
740aAC     keyrtidd      setll     pirtran15
740aAC                   dow       forever = forever
740aAC     keyrtid       reade     pirtran15                              80
740aAC                   if        %eof or ptcdte = 0
740aAC                   leave
740aAC                   endif
740a  * Only write history if additional history is set in options
740aAC                   if        opishs <> 0
740aAC                   Select
740aAC                   when      rhstat = '8'
740aAC                   when      rhstat = '9'
740aAC                   other
740aAC                   write     ptrech
740aAC                   endsl
740aAC                   endif
740aAC                   delete    ptrec15                              77
740aAC                   enddo
740aAC                   endsr
640aA*---------------------------------------------------------------
640aA*
640aA*    ZZORDBSUM  Delete ORDBSUM records for route.
640aA*
640aAC     zzordbsum     begsr
     *
     C     keyrs         setll     ordbsum1
     C                   dou       %eof(ordbsum1)
     C     keyrs         reade     ordbsum1
     C                   if        not %eof(ordbsum1)
     C                   delete    bprec
     C                   endif
     C                   enddo
     *
640aAC                   endsr
     *---------------------------------------------------------------
HARaA*
HARaA*    ZZORDAD  Delete exported ORDAD records for order.
HARaA*
HARaAC     zzordad       begsr
HARaA*
     C     keyod         setll     ordad
     C                   dou       %eof(ordad)
     C     keyod         reade     ordad
     C                   if        not %eof(ordad)
     C                   delete    ordrec
     C                   endif
     C                   enddo
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDC  Delete exported ORDC Order catch wt records for order.
     *
     C     zzordc        begsr
     *
     *  Delete exported customer order detail catch weight records.
     *
414aD*R         KEYOD     SETLLORDC                 79
414aMC     keyod         setll     ordc
414aD*R                   MOVE *IN79     EOF     1
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyod         reade     ordc                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    ocrec                                78
414aAC                   if        *in78
414aD*R                   MOVE *IN78     EFLAG   1
414aMC                   move      *in78         eflg2
414aAC                   endif
650cAc                   eval      processstatus = '*CLEANUP'
650cAc                   exsr      processCWLog
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDD  Delete exported ORDD Order detail records for route id.
     *
     C     zzordd        begsr
     *
     *  Delete exported customer order detail records.
     *
414aD*R         KEYOD     SETLLORDD                 79
414aMC     keyod         setll     ordd
414aD*R                   MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyod         reade     ordd                                   79
     C                   move      *in79         eof
     C                   if        not *in79
720aA * Only write history if additional history is set in options
720aAC                   if        opishs <> 0
720aAC                   Select
720aAC                   when      rhstat = '8'
720aAC                   when      rhstat = '9'
720aAC                   other
720aAC                   write     odrech
720aAC                   endsl
720aAC                   endif
     C                   delete    odrec                                78
414aAC                   if        *in78
414aD*R                   MOVE *IN78     EFLAG
414aMC                   move      *in78         eflg2
650aAc                   else
500eA*
500eA*      Remove order detail misc. record if found.
500eAC     keyod         setll     orddm
500eAC                   if        %equal(orddm)
500eAC     keyod         chain     orddm
500eAC                   if        %found(orddm)
500eAC                   delete    omrec
500eAC                   endif
500eAC                   endif
500eA*
414aAC                   endif
     C                   endif
     C                   enddo
500eA*
500eA*      Remove order detail box number records if found.
500eAC     keyod         setll     ordbox
500eAC                   if        %equal(ordbox)
500eAC     keyod         reade     ordbox
500eAC                   dow       not %eof(ordbox)
500eAC                   delete    obrec
500eAC     keyod         reade     ordbox
500eAC                   enddo
500eAC                   endif
500eA*
500eA*      Remove order detail expiration date records if found.
500eAC     keyod         setll     ordexpdte
500eAC                   if        %equal(ordexpdte)
500eAC     keyod         reade     ordexpdte
500eAC                   dow       not %eof(ordexpdte)
500eAC                   delete    oerec
500eAC     keyod         reade     ordexpdte
500eAC                   enddo
500eAC                   endif
500eA*
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDH  Delete exported ORDH Order head records for route id.
     *
     C     zzordh        begsr
     *
     *  Delete exported Order head records.
     *
414aD*R         KEYRS     SETLLORDH3                79
414aMC     keyrs         setll     ordh3
414aD*R                   MOVE *IN79     EOF     1
414aMC                   eval      forevr = *off
414aD*          EOF       DOWEQ*OFF
414aMC                   dow       forevr = *off
     C     keyrs         reade     ordh3                                  79
414aD*                    MOVE *IN79     EOF
414aMC                   move      *in79         forevr
     C                   if        not *in79
414aD*R                   MOVE *OFF      EFLAG   1
414aMC                   eval      eflg2 = *off
     C                   exsr      zzordd
     C                   exsr      zzordc
     C                   exsr      zzordt
410 AC                   exsr      zzords
510aAC                   exsr      zzpcks
HARaAC                   if        client = harbor
HARaAC                   exsr      zzordad
HARaAC                   endif
414aD*R         EFLAG     IFEQ *OFF
414aMC                   if        eflg2 = *off
520aA * Only write history if additional history is set in options
520aAC                   if        opishs <> 0
520cAC                   Select
520cAC                   when      rhstat = '8'
520cAC                   when      rhstat = '9'
520cAC                   other
520cAC                   write     ohrech
520cAC                   endsl
520cAC                   endif
     C                   delete    ohrec                                78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
414aAC                   else
414aA*
414aA*    If any errors, seton error flag so next time cleanup
414aA*    is run the orders will be removed.
414aA*
414aAC                   if        eflg2 = *on
414aAC                   eval      eflag = eflg2
414aAC                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
640cA*
640cA*---------------------------------------------------------------
640cA*
640cA*    ZZORDHM  Delete exported ORDHM Order hdr misc rcds for route id
640cA*
640cAC     zzordhm       begsr
640cA*
640cA*  Delete exported Order header misc. records.
640cA*
640cAC     keyrs         setll     ordhm2
640cAC                   eval      forevr = *off
640cAC                   dow       forevr = *off
640cAC     keyrs         reade     ordhm2                                 79
640cAC                   move      *in79         forevr
640cA*
640cAC                   if        not *in79
640cAC                   delete    hmrec                                78
640cAC                   if        *in78
640cAC                   move      *in78         eflag
640cAC                   endif
640cA*
640cAC                   endif
640cA*
640cAC                   enddo
640cA*
640cAC                   endsr
640cA*
520dA*---------------------------------------------------------------
520dA*
520dA*    ZZORDP  Delete ORDP records for route id.
520dA*
520dAC     zzordp        begsr
520dA*
520dA*  Delete exported BATCTL records.
520dA*
520dAC     keyrs         setll     ordp
520dAC                   eval      eof = *off
520dAC                   dow       eof = *off
520dAC     keyrs         reade     ordp                                   79
520dAC                   move      *in79         eof
520dAC                   if        not *in79
520dAC                   delete    orprec                               78
520dAC                   endif
520dAC                   enddo
520dAC                   endsr
700cA*----------------------------------------------------------------
700cA*    ZZPLTSUMU  Delete PLTSUMU records.
700cA*----------------------------------------------------------------
700cA /free
700cA   begsr zzpltsumu;

700cA     setll keyrs pltsumu;
700cA     dou %eof(pltsumu);
700cA       reade keyrs pltsumu;
700cA       if not %eof(pltsumu);
700cA         delete psurec;
700cA       endif;
700cA     enddo;

700cA   endsr;
700cA /end-free
530cA*---------------------------------------------------------------
530cA*
530cA*    ZZTOTEHDR  Delete TOTEHDR records for route id.
530cA*
530cAC     zztotehdr     begsr
530cA*
530cA*  Delete exported TOTEHDR records.
530cA*
530cAC     keyrs         setll     totehdr
530cAC                   eval      eof = *off
530cAC                   dow       eof = *off
530cAC     keyrs         reade     totehdr                                79
530cAC                   move      *in79         eof
530cAC                   if        not *in79
530cAC                   delete    tohrec                               78
530cAC                   endif
530cAC                   enddo
530cAC                   endsr
700bA*---------------------------------------------------------------
700bA*
700bA*    ZZAMPXREF  Delete AMPXREF records for route id.
700bA*
700bAC     zzampxref     begsr
700bA*
700bA*  Delete prexref for exproted routes
700bA*
700bAC     keyrs         setll     ampxref3
700bAC                   eval      eof = *off
700bAC                   dow       eof = *off
700bAC     keyrs         reade     ampxref3                               79
700bAC                   move      *in79         eof
700bAC                   if        not *in79
700bAC                   delete    axrec                                78
700bAC                   endif
700bAC                   enddo
700bAC                   endsr
640bA*---------------------------------------------------------------
640bA*
640bA*    ZZPREXREF  Delete PREXREF records for route id.
640bA*
640bAC     zzprexref     begsr
640bA*
640bA*  Delete prexref for exproted routes
640bA*
640bAC     keyrs         setll     prexref3
640bAC                   eval      eof = *off
640bAC                   dow       eof = *off
640bAC     keyrs         reade     prexref3                               79
640bAC                   move      *in79         eof
640bAC                   if        not *in79
640bAC                   delete    pxrec                                78
640bAC                   endif
640bAC                   enddo
640bAC                   endsr
710aA*---------------------------------------------------------------
710aA*
710aA*    ZZvoexcp   Delete VOEXCP records for transaction
710aA*
710aAC     zzvoexcp      begsr
710aA*
710aA*  Delete prexref for exproted routes
710aA*
710aAC     keyvo         setll     voexcp
750bDC**                 eval      eof = *off
710aAC                   dow       not %eof(voexcp)
710aAC     keyvo         reade     voexcp                                 79
750bDC**                 move      *in79         eof
710aAC                   if        not *in79
710aAC                   delete    sxrec                                78
710aAC                   endif
710aAC                   enddo
770bA /free
770bA           // Cleanup records from label extension file
770bA                    monitor;
770bA                      exec sql delete from labelexa
770bA                          where lbawhse=:ptwhse and
770bA                                lbatrn#=:pttrn#;
770bA                    on-error;
770bA                    endmon;
770bA /end-free
710aAC                   endsr
710eA*---------------------------------------------------------------
710eA*
710eA*    ZZCADECRTE  Delete CADECRTE records for route id.
710eA*
710eAC     zzcadecrte    begsr
710eA*
710eA*  Delete prexref for exproted routes
710eA*
710eAC     rhrtid        setll     cadecrte
710eAC                   eval      eof = *off
710eAC                   dow       eof = *off
710eAC     rhrtid        reade     cadecrte                               79
710eAC                   move      *in79         eof
710eAC                   if        not *in79
710eAC                   delete    crfrec                               78
710eAC                   endif
710eAC                   enddo
710eAC                   endsr
700aA*---------------------------------------------------------------
700aA*
700aA*    ZZRTETRAILER Delete RTETRAILER records for route id.
700aA*
700aAC     zzrtetrailer  begsr
700aA*
700aA*  Delete rtetrailer for exported routes
700aA*
700aAC     keyrs         setll     rtetrailer
700aAC                   eval      eof = *off
700aAC                   dow       eof = *off
700aAC     keyrs         reade     rtetrailer                             79
700aAC                   move      *in79         eof
700aAC                   if        not *in79
700aAC                   delete    rttrec                               78
700aAC                   endif
700aAC                   enddo
700aAC                   endsr
700aA*---------------------------------------------------------------
700aA*
700aA*    ZZRTELM      Delete RTELM records for route id.
700aA*
700aAC     zzrtelm       begsr
700aA*
700aA*  Delete rtelm for exported routes
700aA*
700aAC     keyrs         setll     rtelm
700aAC                   eval      eof = *off
700aAC                   dow       eof = *off
700aAC     keyrs         reade     rtelm                                  79
700aAC                   move      *in79         eof
700aAC                   if        not *in79
700aAC                   delete    rlrec                                78
700aAC                   endif
700aAC                   enddo
700aAC                   endsr
720cA*---------------------------------------------------------------
720cA*
720cA*    ZZRTEHEDEXA  Delete RTEHEDEXA records for route id.
720cA*
720cAC     zzrtehedexa   begsr
720cA*
720cA*  Delete rtehedexa for exported routes
720cA*
720cAC     keyrs         setll     rtehedexa
720cAC                   eval      eof = *off
720cAC                   dow       eof = *off
720cAC     keyrs         reade     rtehedexa                              79
720cAC                   move      *in79         eof
720cAC                   if        not *in79
720cAC                   delete    rharec                               78
720cAC                   endif
720cAC                   enddo
720cAC                   endsr
HAR A*---------------------------------------------------------------
HAR A*
HAR A*    ZZTXFTP Delete exported TXFTPLOG records for route id       .
HAR A*
HAR AC     zztxftp       begsr
HAR A*
HAR AC                   if          (not %open(txftplog))
HAR AC                   open      txftplog
HAR AC                   Endif
HAR AC     keyrs         setll     txftplog
HAR AC                   eval      eof = *off
HAR AC                   dow       eof = *off
HAR AC     keyrs         reade     txftplog                               79
HAR AC                   move      *in79         eof
HAR AC                   if        not *in79
HAR AC                   delete    txftpr                               78
HAR AC                   endif
HAR AC                   enddo
HAR AC                   endsr
510aA*---------------------------------------------------------------
510aA*
510aA*    ZZOLBL  Delete exported ORDLBL1 Order detail label records.
510aA*
510aAC     zzolbl        begsr
510aA*
510aA*  Delete exported Order detail label records3.
510aA*
510aAC     keyrs         setll     ordlbl1
510aAC                   eval      forevr = *off
510aAC                   dow       forevr = *off
510aAC     keyrs         reade     ordlbl1                                79
510aAC                   move      *in79         forevr
510aAC                   if        not *in79
510aAC                   delete    alrec                                78
510aAC                   endif
510aAC                   enddo
510aAC                   endsr
     *---------------------------------------------------------------
410 A*
410 A*    ZZORDS  Delete exported ORDSLCT order selection records for order.
410 A*
410 AC     zzords        begsr
410 A*
410 A*  Delete exported order selection records.
410 A*
414aD*          KEYOD     SETLLORDSLCT3             79
414aMC     keyod         setll     ordslct3
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
410 AC                   dow       eof = *off
410 AC     keyod         reade     ordslct3                               79
410 AC                   move      *in79         eof
410 AC                   if        not *in79
410 AC                   delete    osrec                                78
414aAC                   if        *in78
414aD*R                   MOVE *IN78     EFLAG
414aMC                   move      *in78         eflg2
414aAC                   endif
410 AC                   endif
410 AC                   enddo
410 AC                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDT  Delete exported ORDT Order detail trans records for order.
     *
     C     zzordt        begsr
     *
     *  Delete exported customer order detail transaction records.
     *
414aD*          KEYOD     SETLLORDT                 79
414aMC     keyod         setll     ordt
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyod         reade     ordt                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    otrec                                78
414aAC                   if        *in78
414aD*R                   MOVE *IN78     EFLAG
414aMC                   move      *in78         eflg2
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
510aA*---------------------------------------------------------------
510aA*
510aA*    ZZPCKS  Delete exported ORDDS Order detail pick slot records.
510aA*
510aAC     zzpcks        begsr
510aA*
510aA*  Delete exported order detail pick slot records.
510aA*
510aAC     keyod         setll     ordds
510aAC                   eval      eof = *off
510aAC                   dow       eof = *off
510aAC     keyod         reade     ordds                                  79
510aAC                   move      *in79         eof
510aAC                   if        not *in79
510aAC                   delete    ossrec                               78
510aAC                   if        *in78
510aAC                   move      *in78         eflg2
510aAC                   endif
510aAC                   endif
510aAC                   enddo
510aA*
510aAC                   endsr
510aA*
416 A*---------------------------------------------------------------
416 A*
416 A*    ZZCSUM  Delete exported Route compartment summary records.
416 A*
416 AC     zzcsum        begsr
416 A*
416 A*  Delete exported Route summary records.
416 A*
416 AC     keyrs         setll     rtecsum
416 AC                   eval      eof = *off
416 AC                   dow       eof = *off
416 AC     keyrs         reade     rtecsum                                79
416 AC                   move      *in79         eof
416 AC                   if        not *in79
416 AC                   delete    rcrec                                78
416 AC                   if        *in78
416 AC                   move      *in78         eflag
416 AC                   endif
416 AC                   endif
416 AC                   enddo
416 AC                   endsr
740cA*
740cA*---------------------------------------------------------------
740cA*
740cA*    ZZRTEINUSE  Delete Route Inuse records.
740cA*
740cAC     zzrteinuse    begsr
740cA*
740cA*  Delete exported Route summary records.
740cA*
740cAC     keyrs         setll     rteinuse
740cAC                   eval      eof = *off
740cAC                   dow       eof = *off
740cAC     keyrs         reade     rteinuse                               79
740cAC                   move      *in79         eof
740cAC                   if        not *in79
740cAC                   delete    riurec                               78
740cAC                   if        *in78
740cAC                   move      *in78         eflag
740cAC                   endif
740cAC                   endif
740cAC                   enddo
740cA*
740cAC                   endsr
740cA*
530bA*---------------------------------------------------------------
530bA*
530bA*    ZZLOAD  Delete exported Route loader module records
530bA*
530bAC     zzload        begsr
530bA*
530bAC                   eval      eof = *off
530bAC     keyld         chain     LDRHHDR
530bAC                   if        %found(LDRHHDR)
530bAC     keyld         setll     ldrhdetl
530bAC                   dou       %eof(ldrhdetl)
530bAC     keyld         reade     ldrhdetl
530bAC                   if        not %eof(ldrhdetl)
530bAC                   delete    ldhrec
530bAC                   endif
530bAC                   enddo
530bAC                   delete    lhhrec
530bAC                   endif
     *
530bAC                   endsr
510cA*---------------------------------------------------------------
510cA*
510cA*    ZZNOTE  Delete exported Route note records.
510cA*
510cAC     zznote        begsr
510cA*
510cA*  Delete exported Route summary records.
510cA*
510cAC     keyrs         setll     rtenote
510cAC                   eval      eof = *off
510cAC                   dow       eof = *off
510cAC     keyrs         reade     rtenote                                79
510cAC                   move      *in79         eof
510cAC                   if        not *in79
510cAC                   delete    rnrec                                78
510cAC                   if        *in78
510cAC                   move      *in78         eflag
510cAC                   endif
510cAC                   endif
510cAC                   enddo
510cAC                   endsr
510cA*---------------------------------------------------------------
510cA*
510cA*    ZZPMSC  Delete Pallet Misc records.
510cA*
510cAC     zzpmsc        begsr
510cA*
510cA*  Delete exported Pallet misc records.
510cA*
510cAC     keyrs         setll     pltmisc
510cAC                   eval      eof = *off
510cAC                   dow       eof = *off
510cAC     keyrs         reade     pltmisc                                79
510cAC                   move      *in79         eof
510cAC                   if        not *in79
510cAC                   delete    pmrec                                78
510cAC                   if        *in78
510cAC                   move      *in78         eflag
510cAC                   endif
510cAC                   endif
510cAC                   enddo
510cAC                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSTP  Delete exported Pallet stop records for route id.
     *
     C     zzpstp        begsr
     *
     *  Delete exported Pallet stop records.
     *
414aD*          KEYRS     SETLLPLTSTP1              79
414aMC     keyrs         setll     pltstp1
414aD*                    MOVE *IN79     EOF     1
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     pltstp1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    pssrec                               78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSUM  Delete exported Pallet summary records for route id.
     *
     C     zzpsum        begsr
     *
     *  Delete exported Pallet summary records.
     *
414aD*          KEYRS     SETLLPLTSUM1              79
414aMC     keyrs         setll     pltsum1
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     pltsum1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    psrec                                78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRSUM  Delete exported Route summary records for route id.
     *
     C     zzrsum        begsr
     *
     *  Delete exported Route summary records.
     *
414aD*          KEYRS     SETLLRTESUM               79
414aMC     keyrs         setll     rtesum
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     rtesum                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    rsrec                                78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
510bA*---------------------------------------------------------------
510bA*
510bA*    ZZSEQ1  Delete exported PIRSEQ1 label records.
510bA*
510bAC     zzseq1        begsr
510bA*
510bA*  Delete exported customer order detail catch weight records.
510bA*
510bAC     keyrs         setll     pirseq1
510bAC                   eval      eof = *off
510bAC                   dow       eof = *off
510dDC*    keyrs         reade     pirseq1                              79
510dAC     keyrs         reade     pirseq1                                79
510bAC                   move      *in79         eof
510bAC                   if        not *in79
510bAC                   delete    psqrec                               78
510bAC                   endif
510baC                   enddo
510bAC                   endsr
530aA*---------------------------------------------------------------
530aA*
530aA*    ZZTOTBUN  Delete exported Route tote and bundle records
530aA*
530aAC     zztotbun      begsr
530aA*
530aAC                   eval      eof = *off
530aAC     keyrs         setll     totebund2
530aAC                   dou       %eof(totebund2)
530aAC     keyrs         reade     totebund2
530aAC                   if        not %eof(totebund2)
530aAC                   delete    tbrec
530aAC                   endif
530aAC                   enddo
     *
530aAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTITM  Delete associated TTITM records.
640dA*
640dAC     zzttitm       begsr
640dA*
640dAC     keyrs         setll     ttitm
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttitm                                  79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttirec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTLOG  Delete associated TTLOG records.
640dA*
640dAC     zzttlog       begsr
640dA*
640dAC     keyrs         setll     ttlog
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttlog                                  79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttlrec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
730aA*---------------------------------------------------------------
730aA*
730aA*    ZZTTPICS  Delete associated TTPICS records.
730aA*
730aAC     zzttpics      begsr
730aA*
730aAC     keyrs         setll     ttpics
730aAC                   eval      forevr = *off
730aAC                   dow       forevr = *off
730aAC     keyrs         reade     ttpics                                 79
730aAC                   move      *in79         forevr
730aA*
730aAC                   if        not *in79
730aAC                   delete    ttpcrec                              78
730aAC                   if        *in78
730aAC                   move      *in78         eflag
730aAC                   endif
730aAC                   endif
730aA*
730aAC                   enddo
730aA*
730aAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTMERG  Delete associated TTMERG records.
640dA*
640dAC     zzttmerg      begsr
640dA*
640dAC     keyrs         setll     ttmerg
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttmerg                                 79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttmrec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTRTE  Delete associated TTRTE records.
640dA*
640dAC     zzttrte       begsr
640dA*
640dAC     keyrs         setll     ttrte
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttrte                                  79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttrrec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTRTN  Delete associated TTRTN records.
640dA*
640dAC     zzttrtn       begsr
640dA*
640dAC     keyrs         setll     ttrtn3
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttrtn3                                 79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttrec                                78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTSTP  Delete associated TTSTP records.
640dA*
640dAC     zzttstp       begsr
640dA*
640dAC     keyrs         setll     ttstp
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     ttstp                                  79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttprec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTSTPFLG  Delete associated TTSTPFLG records.
640dA*
640dAC     zzttstpflg    begsr
640dA*
650bDC**   keyld         setll     ttstpflg
650bMC     keyrs         setll     ttstpflg
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
650bDC**   keyld         reade     ttstpflg                               79
650bMC     keyrs         reade     ttstpflg                               79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttfrec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
     *---------------------------------------------------------------
640dA*
640dA*    ZZTTTRX  Delete associated TTTRX records.
640dA*
640dAC     zztttrx       begsr
640dA*
640dAC     keyrs         setll     tttrx
640dAC                   eval      forevr = *off
640dAC                   dow       forevr = *off
640dAC     keyrs         reade     tttrx                                  79
640dAC                   move      *in79         forevr
640dA*
640dAC                   if        not *in79
640dAC                   delete    ttxrec                               78
640dAC                   if        *in78
640dAC                   move      *in78         eflag
640dAC                   endif
640dAC                   endif
640dA*
640dAC                   enddo
640dA*
640dAC                   endsr
650fA*---------------------------------------------------------------
650fA*
650fA*    ZZTTGRP  Delete associated TTGRP records.
650fA*
650fAC     zzttgrp       begsr
650fA*
     C     keyrs         chain     ttgrp
     C                   if        %found(ttgrp)
     C                   delete    ttgrec                               78
     C                   if        *in78
     C                   eval      eflag = '1'
     C                   endif
     C                   endif
     *
     C                   endsr
720bA*---------------------------------------------------------------
720bA*
720bA*    ZZTTEXCP  Delete associated TTEXCP records.
720bA
720bA /free
720bA  begsr zzttexcp;

         whsea = %char(rhwhse);
         chain(n) (whsea: rhrtid) ttexcp;

         if %found;
           monitor;
             delete tterec;
           on-error;
             eflag = *on;
           endmon;
         endif;

       endsr;
      /end-free

730bA*---------------------------------------------------------------
730bA*
730bA*    ZZTTSTPFR  Delete associated TTSTPFR records.
730bA
730bA /free
730bA  begsr zzttstpfr;

         setll (rhwhse: rhrtid) ttstpfr;
         dow forevr = forevr;
           reade (rhwhse: rhrtid) ttstpfr;
           if %eof(ttstpfr);
             leave;
           endif;
           delete ttfrrc;
         enddo;

       endsr;
      /end-free

     *---------------------------------------------------------------
640fA*
640fA*    ZZTOTEDATA  Delete associated TOTEDATA records.
640fA*
640fac     zztotedata    begsr
640fA /free
640fa    setll (ptwhse: pttrn#) totedata;
640fA    forevr = *off;
640fA    dow forevr = *off;
640fa      reade (ptwhse: pttrn#) totedata;
640fa      if %eof(totedata);
640fa        leave;
640fa      endif;
640fa /end-free
640fAc                   delete    tgrec                                78
640fAC                   if        *in78
640fAC                   move      *in78         eflag
640fAC                   endif
640fA*
640fAC                   enddo
640fA*
640fAC                   endsr
740eA*---------------------------------------------------------------
740eA*
740eA*    ZZUCI   Delete uci records for selection label/tran
740eA*
740eAC     zzuci         begsr
740eA*
740eA  /free
740eA        clear $uciinfo;
740eA        clear $uciinfo2;
740eA        $uiver# = savever#;

740eA        $uiwhse = lbwhse;
740eA        $uisellbl# = lblbl#;
740eA        $uiseltrn# = lbtrn#;

740eA        $dridata = $uciinfo;
740eA        $dridata2 = $uciinfo2;
740eA        driUCICalled = *on;
740eA        driuciinfo('%CLEANUP1': $pprogram: $drireturn:
740eA                 $drimessage: $dridata: $dridata2);
740eA  /end-free
740eAC                   endsr
     *---------------------------------------------------------------
     *
     *    ZZWLBL  Delete exported WORKLBL records for route id.
     *
     C     zzwlbl        begsr
     *
     *  Delete exported WORKLBL records.
     *  Delete dependent LABEL and PIRTRAN records.
     *
414aD*          KEYRS     SETLLWORKLBL7             79
414aMC     keyrs         setll     worklbl7
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     worklbl7                               79
     C                   move      *in79         eof
     C                   if        not *in79
412AD*          LWLBL#    CHAINLABEL                77
412AD*          *IN77     IFEQ *OFF
412AD*                    DELETLBREC                  77
412AD*                    ENDIF
412AD*          LWTRN#    CHAINPIRTRAN              77
412AD*          *IN77     IFEQ *OFF
412AD*                    DELETPTREC                  77
412AD*                    ENDIF
     C                   delete    lwrec                                78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
750 A*---------------------------------------------------------------
750 A*
750 A*    ZZSR    Delete Super Route records for route id.
750 A*
750 AC     zzsr          begsr
      /free
        if %subst(rhrte:1:3) = '#SR';
          monitor;
     *
     *  Delete Super Route (Route Xref records) SRRTE
     *
            exec sql delete from srrte
                      where srwhse=:rhwhse and srsrtid=:rhrtid;
     *
     *  Delete Super Route Order (Order/Stop Xref records) SRORD
     *
            exec sql delete from srord
                      where srowhs=:rhwhse and srosrtid=:rhrtid;
          on-error;
          endmon;
        endif;
      /end-free
750aAC                   endsr
750aA*---------------------------------------------------------------
750aA*
750aA*    ZZITMSLOG  Delete from ITEMSUBLOG for route id
750aA*
750aAC     zzitmslog     begsr
      /free
          monitor;
     *
     *  Delete Item Sub Log (ITEMSUBLOG)
     *
            exec sql delete from itemsublog
                      where islwhse=:rhwhse and islrtid=:rhrtid;
          on-error;
          endmon;
      /end-free
750aAC                   endsr
760 A*---------------------------------------------------------------
760 A*
760 A*    ZZELSFILES  Delete from ELSSTDDTL, and ELSSTDLOG
760 A*
760 AC     zzelsfiles    begsr
760 A /free
760 A     monitor;
760 A*
760 A*  Delete ELSSTDDTL and ELSSTDLOG
760 A*
760 A       exec sql delete from elsstddtl
760 A                 where edwhse=:rhwhse and edrtid=:rhrtid;
760 A       exec sql delete from elsstdlog
760 A                 where egwhse=:rhwhse and egrtid=:rhrtid;
760 A     on-error;
760 A     endmon;
760 A /end-free
760 AC                   endsr
760 A*---------------------------------------------------------------
760 A*
760 A*    zzAptSel  Delete from APTSELWK (APT Selection Work File)
760 A*
760 AC     zzaptsel      begsr
760 A /free
760 A     monitor;
760 A*
760 A*  Delete APT Selection Work File (APTSELWK)
760 A*
760aA       exec sql delete from APTDATA
760aA                 where apwhse=:rhwhse and aprte=:rhrtid;
760 A       exec sql delete from APTSELWK
760 A                 where apwhse=:rhwhse and aprtid=:rhrtid;
760 A     on-error;
760 A     endmon;
760 A /end-free
760 AC                   endsr
760bA*---------------------------------------------------------------
760bA*
760bA*    ZZCLNELS  Process some misc ELS clenup sql
760bA*
760bAC     zzclnels      begsr
760bA /free
760bA     monitor;
760bA*
760bA*  Delete any ELSSTDDLT or ELSSTDLOG records associated to status 9 routes
760bA*
760bA       exec sql delete from elsstddtl
760bA                where (select count(*) from rtehed where edwhse=rhwhse and
760bA                edrtid=rhrtid and rhstat='9')>0;
760bA       exec sql delete from elsstdlog
760bA                where (select count(*) from rtehed where egwhse=rhwhse and
760bA                egrtid=rhrtid and rhstat='9')>0;
760bA     on-error;
760bA     endmon;
760bA /end-free
760bAC                   endsr
760cA*---------------------------------------------------------------
760cA*
760cA*    ZZLABELOUT  Delete from LABELOUT
760cA*
760cAC     zzlabelout    begsr
760cA /free
760cA     monitor;
760cA*
760cA*  Delete LABELOUT
760cA*
760cA       exec sql delete from labelout
760cA                 where lowhse=:rhwhse and lortid=:rhrtid;
760cA     on-error;
760cA     endmon;
760cA /end-free
760cAC                   endsr
770cA*---------------------------------------------------------------
770cA*
770cA*    ZZDD2MERGE  Delete from DDTASKH and DDDETAILH
770cA*
770cAC     zzDD2merge    begsr
770cA /free
770cA     monitor;
770cA*
770cA*  Delete DDTASKH, DDDETAILH where route id no longer in RTEHED
770cA*  or the one in the History file(s) is older than on in RTEHED
770cA*
770cA       exec sql delete from ddtaskh
770cA       where
770cA        (ddtaddts < (select timestamp(substring(char(rhimpd),1,4) ||
770cA       '-' || substring(char(rhimpd),5,2) || '-' ||
770cA       substring(char(rhimpd),7,2) || '-00.00.00') from rtehed where
770cA       rhwhse=ddtwhse and rhrtid=ddtrtid)
770cA       or not exists (select * from rtehed where rhwhse=ddtwhse and
770cA       rhrtid=ddtrtid));
770cA*
770cA       exec sql delete from dddetailh
770cA       where
770cA        (dddaddts < (select timestamp(substring(char(rhimpd),1,4) ||
770cA       '-' || substring(char(rhimpd),5,2) || '-' ||
770cA       substring(char(rhimpd),7,2) || '-00.00.00') from rtehed where
770cA       rhwhse=dddwhse and rhrtid=dddrtid)
770cA       or not exists (select * from rtehed where rhwhse=dddwhse and
770cA       rhrtid=dddrtid));
770cA*
770cA     on-error;
770cA     endmon;
770cA /end-free
770cAC                   endsr
640eA*----------------------------------------------------------------*********
640eA*
640eA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640eA*
640eA /free
640eA   begsr zzwrttrand;
640eA     wrtpcmd = '*CLEANUP';
640eA     wrtpwait = 0;
640eA     wrtpwhse = ptwhse;
640eA     wrtptran# = pttrn#;
710bD     //wrtpfrmdate = 0;
710bM     wrtpfrmdate = ptgdte;
640eA     wrtptodate = 0;
640eA     wrtpemp# = 0;
640eA
640eA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640eA               wrtpfrmdate: wrtptodate: wrtpemp#);
640eA   endsr;
640eA /end-free
640eA*----------------------------------------------------------------*********
640eA*
640eA*  ZZWRTTRANDLOG Execute new WRTTRAN1 program to cleanup LOGTRAND
640eA*
640eA /free
640eA   begsr zzwrttrandlog;
640eA     wrtpcmd = '*CLEANLOG';
640eA     wrtpwait = 0;
640eA     wrtpwhse = $kwhse;
640eA     wrtptran# = 0;
640eA     wrtpfrmdate = 0;
640eA     wrtptodate = 0;
640eA     wrtpemp# = 0;
640eA
640eA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640eA               wrtpfrmdate: wrtptodate: wrtpemp#);
640eA   endsr;
640eA /end-free
     *---------------------------------------------------------------
     *
     *    ZZWZON  Delete exported WORKZON records for route id.
     *
     C     zzwzon        begsr
     *
     *  Delete exported WORKZON records.
     *
414aD*          KEYRS     SETLLWORKZON1             79
414aMC     keyrs         setll     workzon1
414aD*                    MOVE *IN79     EOF
414aMC                   eval      eof = *off
     C                   dow       eof = *off
     C     keyrs         reade     workzon1                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    zwrec                                78
414aAC                   if        *in78
414aAC                   move      *in78         eflag
414aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported route records
