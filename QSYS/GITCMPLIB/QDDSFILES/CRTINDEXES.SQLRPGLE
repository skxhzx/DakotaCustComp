      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  CRTINDEXES  Create all SQl indexes
     *  29 February 2020
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    02/29/20  DAS  7.40
     *      - Created.
     *
740aA*    04/13/20  DAS  7.40a
     *      - Added indexes for DLYHIT, for Optricity Hits report
     *
740bA*    04/16/20  DAS  7.40b
     *      - Added special logic when library has 'GLO' in char 4-6
     *      - Added index for BFCDEBUG
     *
740cA*    06/08/20  DAS  7.40c
     *      - Revised GLO logic
     *
740cA*    07/21/20  DAS  7.40c
     *      - Added PIRTRAN index 5 as advised by IBM to help
     *        speed up WRTTRAND on SGC.
     *
740dA*    08/07/20  KDE  7.40d
     *      - Added DDTASK, DDTASKH, DDDETAIL, and DDDETAILH indexes
     *        that IBM index advisor suggests
     *
740eA*    09/02/20  KDE  7.40e
     *      - Added PODTL and POHDR indexes
     *
740fA*    10/21/20  KDE  7.40f
     *      - Added Slot, Licactive, Licinfo, and Itemmsc indexes
     *
740gA*    12/17/20  KDE  7.40g
     *      - Added DDDETAIL index for DDROW (only)
     *      - Added indexes to PLTSUM
     *      - Added indexes to RTEHED
     *      - Added index to Label
     *
740hA*    12/29/20  DAS  7.40h
     *      - Arranged files in alpha order (did not apply mod mark)
     *      - Added SLOT, SLOTDEF, PLTSUMU, PIRTRAN, PIRTRAND indexes
     *        that IBM index advisor suggests
     *
740iA*    01/04/20  KDE  7.40i
     *      - Add index to slot, PLTSTP, IMPSORDD, PIRTRAN, PIRTRAND,
     *        EXPSPLBL, DOCROUTE, TRUCKH
     *
750 A*    04/30/21  KDE  7.50
     *      - Add indexes to RTEHED
     *
750aA*    05/01/21  DAS  7.50a
     *      - Added IBM recommend RTEHED index for Cheney PG issues
     *
750bA*    05/12/21  DAS  7.50b
     *      - Add indexes to LABELOUT
     *      - Added optional 'file' parameter
     *
750cA*    05/21/21  KDE  7.50c
     *      - Add indexes to SLOT, HACCPLOG, PIRHOLD, LICLOG, LABEL, ITEMADJ
     *
750dA*    06/25/21  DAS  7.50d
     *      - Fixed unique LABELOUT index
     *
750eA*    08/17/21  KDE  7.50e
     *      - Add indexes to SLOT, VSLOT
     *
750fA*    09/01/21  DAS  7.50f
     *      - Add indexes to BFCSKTLOG
     *
750gA*    11/11/21  KDE  7.50g
     *      - Add indexes to ORDHEXA
     *
750hA*    12/09/21  KDE  7.50h
     *      - Add indexes to WORKLBL
     *      - Add indexes to LABEL
     *      - Add indexes to SLOT
     *      - Add indexes to ORDH
     *      - Add indexes to BFCLOG
     *
750iA*    12/22/21  KDE  7.50i
     *      - Add indexes to ORDH
     *
750jA*    01/06/22  KDE  7.50j
     *      - Add process to generate misc. views
     *
750kA*    02/22/22  KDE  7.50k
     *      - Add index to PIRTRAND
     *
     *
760 A*    04/18/22  KDE  7.60
     *      - Add indexes to PIRTRAND
     *      - Add indexes for APTSELWK
     *
760aA*    07/26/22  KDE  7.60a
     *      - Add indexes to PIRTRAND
     *
760bA*    08/29/22  KDE  7.60b
     *      - Add indexes to LABEL
     *      - Add indexes to SLOT
     *
760cA*    10/09/22  KDE  7.60c
     *      - Add indexes to LABEL
     *      - Add indexes to WORKLBL
     *      - Add indexes to RTEHED
     *
760dA*    11/21/22  DAS  7.60d
     *      - Add indexes to LABEL, LICLOG, ORDC
     *      - These came from a program Rod created on A&D, named
     *        RH155SIDX, which created indexes RH155SIDX1/2/3.
     *      - Although I don't see why they were created, we will
     *        keep them around using this program.
     *
760eA*    01/04/23  DAS  7.60e
     *      - Add indexes to INTLOG
     *
770aA*    03/21/23  KDE  7.70a
     *      - Add indexes to LABEL
     *
770bA*    04/18/23  KDE  7.70b
     *      - Change alternate index to 3 on pirhold index
     *
770cA*    04/28/23  KDE  7.70c
     *      - Add indexes to DDDETAIL
     *
770dA*    05/15/23  KDE  7.70d
     *      - Add indexes to RTEHED
     *
770eA*    07/14/23  KDE  7.70e
     *      - Add indexes to POHDR and GLOSESS
     *
770fA*    11/21/23  KDE  7.70f
     *      - Add indexes to HACCPLOG, PIRTRAND, RTEHED, ITEMEXT, UPC
     *        POHHDR, ITEMADJ, PIRITEM, LABELDO, IMPSITMN, IMPSPCKQ2,
     *        UCIINFO, IMPSPOD, LICLOG, STGBATCH, DFPICKDTL, HACCPQ
     *
770gA*    11/28/23  KDE  7.70g
     *      - Add indexes to PIRTRAND, PIRTRAN, SUM001, HACCPQC, BARDEFH,
     *        BRCMRCRSE, BFCMRCRPRM, RTEHED, IMPSPCKQ, IMPSPOH, TTRTN,
     *        RTEHED, LICACTIVE
     *
770hA*    12/15/23  MLB  7.70h
     *      - Add indexes to OPTIONS, RTEHED.
     *
770iA*    01/25/24  KDE  7.70i
     *      - Add indexes to LICLOG and LICINFO
     *
780aA*    02/04/24  KDE  7.80a
     *      - Add indexes to Label, Liclog, and SUM022
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program is to be used to create all SQL indexes for
     *    all Dakota files.
     *
     *    This program uses a long SQL name for the index and
     *    lets the system generate the 10-Char file name.
     *
     *    The long name will be a combination of the  physical file
     *    name, followed by 'INDEX', followed by a manually assigned
     *    5-digit.
     *
     *       Example: WORKLBL_INDEX_00001
     *
     *    The short name will be the first 5 characters of the
     *    physical file name, followed by a 5-digit sequence number
     *    assigned by the system.
     *
     *       Example: WORKL00001
     *
     *    The Text for the files will be 'CRTINDEXES - ' followed
     *    by the long index name.
     *
     *    This program does not recreate indexes that already exist.
     *
     *    Every client and every files library will have the same long
     *    file name, but it is not guaranteed every long file name
     *    will have the same short file name between cients or libraries.
     *
     *    ** Therefore, the short file name should not be used in
     *    ** an F-spec. In SQL statements, only the Physical File
     *    ** name should be used and let the system determine the
     *    ** best access path to use.
     *
     *----------------------------------------------------------------

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

     D  debugStr1      s           1000    varying
     D  debugStr2      s           1000    varying
     D  dsplyMsg       s             52    varying
     D  gLibrary       s             10    varying
     d  gTable         s             10    varying
750bAd  limitFile      s               n

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pPFLib         s             10
750bAD  pFile          s             10

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CrtIdx          pr
     d  indexNum                      5  0 const
     d  fields                      200    const varying

     d CrtUnqIdx       pr
     d  indexNum                      5  0 const
     d  fields                      200    const varying

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

750jAd ordhocord       pr                  extpgm('ORDH_OCORD')
     d  pfLib                        10
     d  pfLib                        10

750jAd slot16          pr                  extpgm('SLOT16')
     d  pfLib                        10
     d  pfLib                        10

750jAd slot17          pr                  extpgm('SLOT17')
     d  pfLib                        10
     d  pfLib                        10

750jAd slot18          pr                  extpgm('SLOT18')
     d  pfLib                        10
     d  pfLib                        10

750jAd dpckncfg        pr                  extpgm('DPCKNCFG')
     d  pfLib                        10
     d  pfLib                        10

750jAd tsdetail        pr                  extpgm('TSDETAIL')
     d  pfLib                        10
     d  pfLib                        10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pPFLib       Library where PF is located
750bA*      pFile        Optional file to create indexes for
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pPFLib
750bAc                   parm                    pFile

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       // Verify parameters have been sent in

       if %parms < 1 or pPFLib = '';
           dsplyMsg = 'Error: Missing Parm - '
                    + 'CALL CRTINDEXES (pfLib)';
           dsply DsplyMsg;
           return;
       endif;

750bA  // See if optional File was sent in
750bA
750bA  limitFile = *off;
750bA  if %parms >= 2 and pFile <> '';
750bA    limitFile = *on;
750bA  endif;

750jA  // Create Misc., Views for passed Library
750jA  if not limitFile;
750jA    exsr bldViews;
750jA  endif;

       // Create Indexes

       // Use CrtIdx for non-unique indexs and CrtUnqIdx for unique indexes

       // Parameters:
       //   Index Number (Unique number within the table, starting at 1)
       //   Key fields

       gLibrary = %trim(pPFLib);

       // When working with Global library, just do its files and return

740cA  monitor;
         if %subst(gLibrary: 4: 3) = 'GLO';
           gTable='BFCDEBUG';
             CrtIdx    (1: 'BDADDJUSR, BDADDJOB, BDADDNBR, BDTYPE, BDADDTS');
770eA      gTable='GLOSESS';
770eA        CrtIdx (1: 'GSWHSE');
           return;
         endif;
740cA  on-error;
740cA  endmon;

       // Otherwise, do all other files

760 A  gTable='APTSELWK';
760 A    CrtIdx (1: 'APTRN#, APLINE#');
760 A    CrtIdx (2: 'APTRNM, APLINE#');

770gA  gTable='BARDEFH';
770gA    CrtIdx (1: 'BDHWHSE, BDHMFR#, BDHLEN, BDHIDSTRT');

770gA  gTable='BFCMRCRPRM';
770gA    CrtIdx (1: 'BSVALUE');
770gA    CrtIdx (2: 'BSMRCTBL, BSMRCPRM, BSVALUE, BSWHSE, BSRPTPGM, BSSCHSEQ');

770gA  gTable='BFCMRCRSE';
770gA    CrtIdx (1: 'SESTAT, SEDAY, SESCHTIME');
770gA    CrtIdx (2: 'SESTAT, SEADDTS');

750fA  gTable='BFCSKTLOG';
750fA    CrtIdx (1: 'SLGUSER, SLGTS');

750hA  gTable='BFCLOG';
750hA    CrtIdx (1: 'BLGTEXT');

740dA  gTable='DDDETAIL';
740dA    CrtIdx (1: 'DDDRTID');
740dA    CrtIdx (2: 'DDDPLID');
740dA    CrtIdx (3: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDLEVEL, DDDRTID, DDDPLID, +
740dA                DDDCOL');
740dA    CrtIdx (4: 'DDDWHSE, DDDSNAP, DDDLEVEL, DDDRTID, DDDPLID');
740dA    CrtIdx (5: 'DDDWHSE, DDDSNAP, DDDRTID, DDDLEVEL, DDDPLID');
740dA    CrtIdx (6: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDLEVEL, DDDRTID, DDDCOL');
740dA    CrtIdx (7: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDSIDE, DDDLEVEL, DDDRTID');
740dA    CrtIdx (8: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDRTID, DDDLEVEL, DDDCOL');
740dA    CrtIdx (9: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDRTID, DDDLEVEL, DDDPLID, +
                     DDDCOL');
740gA    CrtIdx (10: 'DDDROW');
770cA    CrtIdx (11: 'DDDWHSE, DDDRTID, DDDSNAP, DDDPID');

740dA  gTable='DDDETAILH';
740dA    CrtIdx (1: 'DDDRTID');
740dA    CrtIdx (2: 'DDDPLID');
740dA    CrtIdx (3: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDLEVEL, DDDRTID, DDDPLID, +
740dA                DDDCOL');
740dA    CrtIdx (4: 'DDDWHSE, DDDSNAP, DDDLEVEL, DDDRTID, DDDPLID');
740dA    CrtIdx (5: 'DDDWHSE, DDDSNAP, DDDRTID, DDDLEVEL, DDDPLID');
740dA    CrtIdx (6: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDLEVEL, DDDRTID, DDDCOL');
740dA    CrtIdx (7: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDSIDE, DDDLEVEL, DDDRTID');
740dA    CrtIdx (8: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDRTID, DDDLEVEL, DDDCOL');
740dA    CrtIdx (9: 'DDDWHSE, DDDSNAP, DDDGROUP, DDDRTID, DDDLEVEL, DDDPLID, +
                     DDDCOL');
740gA    CrtIdx (10: 'DDDROW');
770cA    CrtIdx (11: 'DDDWHSE, DDDRTID, DDDSNAP, DDDPID');

740dA  gTable='DDTASK';
740dA    CrtIdx (1: 'DDTRTID');
740dA    CrtIdx (2: 'DDTADDTS');
740dA    CrtIdx (3: 'DDTWHSE, DDTTASKGRP, DDTRTID, DDTTYPE, DDTSEQ');
740dA    CrtIdx (4: 'DDTWHSE, DDTRTID, DDTTASKGRP, DDTADDTS, DDTTYPE, +
740DA                DDTSEQ, DDTSUBTYPE');
740dA    CrtIdx (5: 'DDTTASKGRP, DDTRTID, DDTSEQ');
740dA    CrtIdx (6: 'DDTWHSE, DDTTASKGRP');

740dA  gTable='DDTASKH';
740dA    CrtIdx (1: 'DDTRTID');
740dA    CrtIdx (2: 'DDTADDTS');
740dA    CrtIdx (3: 'DDTWHSE, DDTTASKGRP, DDTRTID, DDTTYPE, DDTSEQ');
740dA    CrtIdx (4: 'DDTWHSE, DDTRTID, DDTTASKGRP, DDTADDTS, DDTTYPE, +
740DA                DDTSEQ, DDTSUBTYPE');
740dA    CrtIdx (5: 'DDTTASKGRP, DDTRTID, DDTSEQ');
740dA    CrtIdx (6: 'DDTWHSE, DDTTASKGRP');

770fA  gTable='DFPICKDTL';
770fA    CrtIdx    (1: 'DFDWHSE,DFDCMPPRTY,DFDLVL2');

       gTable='DLYHIT';
         CrtIdx    (1: 'HTWHSE, HTITEM, HTSHFTDAY');
         CrtIdx    (2: 'HTWHSE, HTSHFTDAY, HTITEM');
         CrtIdx    (3: 'HTTYPE, HTSHFTDAY');

740iA  gTable='DOCROUTE';
740iA    CrtIdx    (1: 'DRRTE');

740iA  gTable='EXPSPLBL';
740iA    CrtIdx    (1: 'LBESTATUS, LBEWHS, LBEBATID');

770fA  gTable='HACCPQ';
770fA    CrtIdx    (1: 'HIWHSE,HIACTIVE,HILEVL,HISAMP');
770fA    CrtIdx    (2: 'HIACTIVE,HILEVL,HISAMP');

770gA  gTable='HACCPQC';
770gA    CrtIdx    (1: 'HDWHSE, HDSEQ#');

750cA  gTable='HACCPLOG';
750cA    CrtIdx    (1: 'HLPO, HLWHSE, HLSEQ#, HLEXPTS, HLOBSOLETE');
750cA    CrtIdx    (2: 'HLWHSE, HLEXPTS, HLPO, HLLEVL');
750cA    CrtIdx    (3: 'HLLEVL, HLWHSE, HLPO, HLITEM, HLPOSEQ, HLEXPTS,' +
750cA                  'HLOBSOLETE');
750cA    CrtIdx    (4: 'HLITEM, HLPO, HLWHSE, HLEXPTS, HLOBSOLETE');
750cA    CrtIdx    (5: 'HLLEVL, HLWHSE, HLPO, HLPOSEQ, HLEXPTS, HLOBSOLETE');
750cA    CrtIdx    (6: 'HLWHSE, HLEXPTS, HLPO, HLOBSOLETE');
750cA    CrtIdx    (7: 'HLLEVL, HLWHSE, HLPO, HLOBSOLETE');
750cA    CrtIdx    (8: 'HLWHSE, HLPO, HLLEVL, HLOBSOLETE');
770fA    CrtIdx    (9: 'HLWHSE, HLSEQ#, HLEXPTS, HLPO, HLOBSOLETE');
770fA    CrtIdx    (10: 'HLWHSE, HLLCNS, HLPOSEQ, HLSEQ#, HLEXPTS,HLPO,' +
                        'HLOBSOLETE');
750cA    CrtIdx    (11: 'HLPO, HLOBSOLETE');
770fA    CrtIdx    (12: 'HLWHSE, HLLCNS, HLPOSEQ, HLSEQ#, HLPO, HLEXPTS,' +
                        'HLOBSOLETE');

740iA  gTable='IMPSORDD';
740iA    CrtIdx (1: 'OIDOR2, OIDBATID, OIDORD, OIDSEQ');

770gA  gTable='IMPSPOH';
770gA    CrtIdx (1: 'PIHWHS, PIHBATID, PIHSTSTS');

770fA  gTable='IMPSPOD';
770fA    CrtIdx (1: 'PIDWHS, PIDBATID, PIDSTSTS');
770fA    CrtIdx (2: 'PIDWHS, PIDBATID, PIDPO, PIDSTSTS');

760eA  gTable='INTLOG';
760eA    CrtIdx (1: 'ILADDTS');
760eA    CrtIdx (2: 'ILWHSE, ILBATID, ILADDTS');

750cA  gTable='ITEMADJ';
750cA    CrtIdx (1: 'IAWHSE, IAITEM, IAMEMO');
750cA    CrtIdx (2: 'IAUDTE, IAUTIM');

740fA  gTable='ITEMMSC';
740fA    CrtIdx (1: 'IMWHSE, IMLTRK');
740fA    CrtIdx (2: 'IMWHSE, IMLOT, IMLTRK');

       gTable='LABEL';
         CrtUnqIdx (1: 'LBWHSE, LBLBL#');
740gA    CrtIdx    (2: 'LBRTE, LBTYPE');
750cA    CrtIdx    (3: 'LBTRN#, LBQPCK');
750cA    CrtIdx    (4: 'LBWHD2, LBWHSE, LBDSP2, LBITEM');
750cA    CrtIdx    (5: 'LBQPCK');
750cA    CrtIdx    (6: 'LBTYPE, LBTRN#, LBVRFY');
750cA    CrtIdx    (7: 'LBTYPE, LBVRFY');
750HA    CrtIdx    (8: 'LBSEQ,LBRTE,LBITEM,LBTRN#,LBORD,LBWHSE');
750HA    CrtIdx    (9: 'LBTRN#,LBRTE,LBSEQ');
750HA    CrtIdx    (10: 'LBWHSE,LBWHDP,LBDISP,LBSTAT');
750HA    CrtIdx    (11: 'LBWHD2,LBWHS2,LBDSP2,LBSTAT');
750HA    CrtIdx    (12: 'LBLBL#,LBTYPE,LBQPCK');
750HA    CrtIdx    (13: 'LBTYPE,LBTRN#,LBCTR#');
750HA    CrtIdx    (14: 'LBWHDP,LBDISP,LBGRP1,LBSTYP,LBQPCK,LBTRN#,LBQPCK');
750HA    CrtIdx    (15: 'LBRTE,LBPAL#');
750HA    CrtIdx    (16: 'LBWHSE,LBORD,LBRTE,LBGRP1');
750HA    CrtIdx    (17: 'LBWHSE,LBGRP1,LBRTE,LBSTAT');
750HA    CrtIdx    (18: 'LBTYPE,LBWHSE,LBRDTE');
750HA    CrtIdx    (19: 'LBWHSE,LBITEM,LBRTE,LBORD,LBSEQ,LBTYPE');
750HA    CrtIdx    (20: 'LBITEM,LBWHDP,LBRTE,LBSTOP');
750HA    CrtIdx    (21: 'LBITEM');
750HA    CrtIdx    (22: 'LBWHSE,LBTRN#,LBTYPE,LBCTR#');
750HA    CrtIdx    (23: 'LBWHSE,LBLBL#,LBTYPE');
750HA    CrtIdx    (24: 'LBTRN#');
760bA    CrtIdx    (25: 'LBWHSE,LBWHDP,LBSDTE');
760bA    CrtIdx    (26: 'LBWHSE,LBWHDP,LBDISP,LBSDTE');
760bA    CrtIdx    (27: 'LBWHSE,LBWHDP,LBDSP2,LBSDTE');
760bA    CrtIdx    (28: 'LBWHSE ASC,LBWHDP ASC, LBSDTE DESC');
760cA    CrtIdx    (29: 'LBVRFY ASC,LBWHSE ASC, LBCTR# ASC');
760dA    CrtIdx    (30: 'LBWHSE,LBRTE,LBORD,LBSEQ,LBITEM,LBTYPE,LBLBL#');
770aA    CrtIdx    (31: 'LBTRN#,LBWHSE,LBRTE,LBLVL2,LBWHDP,LBSTYP, +
770aA                    LBAISL,LBPSEQ,LBRLVL,LBHAND,LBSTOP DESC');
770aA    CrtIdx    (32: 'LBTRN#,LBWHSE,LBRTE,LBLVL2,LBWHDP,LBSTYP, +
770aA                    LBAISL,LBPSEQ,LBRLVL,LBHAND,LBSTOP');
770aA    CrtIdx    (33: 'LBLBL#,LBSDTE DESC');
770aA    CrtIdx    (34: 'LBLBL#,LBSDTE');
770fA    CrtIdx    (35: 'LBORD');
770fA    CrtIdx    (36: 'LBWHSE,LBTRN#,LBORD');
780aA    CrtIdx    (37: 'LBGRP1,LBWHSE,LBITEM');
780aA    CrtIdx    (38: 'LBGRP1,LBTYPE');

750bA  gTable='LABELOUT';
750dM    CrtUnqIdx (1: 'LOWHSE, LORTID, LOSET, LOFMT, ' +
                    'LOPRTSEQ, LOPART, LOTRN');
750bA    CrtIdx    (2: 'LOWHSE, LORTID, LOLBL, LOLBLCNT , LOPART');
750bA    CrtIdx    (3: 'LOWHSE, LORTID, LOTRN, LOFMT , LOPART');

740fA  gTable='LICACTIVE';
740fA    CrtIdx (1: 'LADISP');
740fA    CrtIdx (2: 'LAWHDP, LAWHSE, LAPRTY, LAEXPD, LAENTD, LALCNS');
740fA    CrtIdx (3: 'LAWHDP, LAWHSE, LADISP, LAPRTY, LAEXPD, LAENTD, LALCNS');
770gA    CrtIdx (4: 'LAWHDP, LAAISL, LAEXPD, LAENTD, LALCNS');

770iA  gTable='LICINFO';
770iA    CrtIdx (1: 'LNLCNS, LNWHSE');

750cA  gTable='LICLOG';
750cA    CrtIdx (1: 'LLACTION, LLWHSE, LLLCNS');
760dA    CrtIdx (2: 'LLORD, LLSEQ, LLITEM, LLACTION, LLLCNS');
770fA    CrtIdx (3: 'LLWHSE, LLSITEM');
770fA    CrtIdx (4: 'LLSITEM, LLAISL');
770fA    CrtIdx (5: 'LLLCNS, LLACTION, LLCODE');
770fA    CrtIdx (6: 'LLLCNS, LLTRN#');
770fA    CrtIdx (6: 'LLLCNS, LLTRN#,LLACTION,LLCODE');
770iA    CrtIdx (7: 'LLWHSE, LLLBL#');
780aA    CrtIdx (8: 'LLACTION, LLWHSE, LLLBL#');
780aA    CrtIdx (9: 'LLACTION, LLWHSE, LLOLCNS');

770hA  gTable='OPTIONS';
770hA    CrtIdx (1: 'OPCODE, OPWHSE');

750gA  gTable='ORDHEXA';
750gA    CrtIdx (1: 'OHAORD');
750gA    CrtIdx (2: 'OHAORDA');

760dA  gTable='ORDC';
760dA    CrtIdx (1: 'OCWHSE, OCORD, OCSEQ#, OCTRAN, OCLBL#');

750hA  gTable='ORDH';
750hA    CrtIdx (1: 'OHRTE,OHTRUK,OHTYPE');
750iA    CrtIdx (2: 'OHCORD');
770fA    CrtIdx (3: 'OHORD');

740iA  gTable='PIRCOLORSH';
740iA    CrtIdx (1: 'CLRHWHSE, CLRHSET');

750cA  gTable='PIRHOLD';
750cA    CrtIdx (1: 'HOKEY, HOSESS, HOTYPE');
750cA    CrtIdx (2: 'HOTYPE, HOSESS');
770bD    //CrtIdx (1: 'HOKEY, HOTYPE, HOSESS');
770bM    CrtIdx (3: 'HOKEY, HOTYPE, HOSESS');

740fA  gTable='PIRITEM';
740fA    CrtIdx (1: 'ITWHSE, ITCWGT, ITITEM');
740fA    CrtIdx (2: 'ITWHSE, ITCWGT, ITITEM');
740fA    CrtIdx (3: 'ITITEM, ITSTYP');
770fA    CrtIdx (4: 'ITTYPE, ITITEM');

770fA  gTable='ITEMEXT';
770fA    CrtIdx (1: 'IKITEM');

770fA  gTable='IMPSITMN';
770fA    CrtIdx (1: 'IUWHSE,IUBATID,IUSTSTS');
770fA    CrtIdx (2: 'IUWHSE,IUBATID');

770fA  gTable='IMPSPCKQ2';
770fA    CrtIdx (1: 'IPQWHS,IPQBATID,IPQSTSTS');

770fA  gTable='LABELDO';
770fA    CrtIdx (1: 'LBOWHSE, LBOEMP#, LBOTRN#, LBOLTYPE');
770fA    CrtIdx (2: 'LBOWHSE, LBOLTYPE, LBOEMP#, LBOTRN#, LBOLBL#, LBOADDTS');

770fA  gTable='POHHDR';
770fA    CrtIdx (1: 'PHHPO, PHHEDT, PHHETI');

       gTable='PIRTRAN';
         CrtUnqIdx (1: 'PTWHSE, PTTRN#');
         CrtIdx    (2: 'PTWHSE, PTRTPO, PTTRN#, PTEMP#');
         CrtIdx    (3: 'PTWHSE, PTRTPO, PTEMP#');
         CrtIdx    (4: 'PTWHSE, PTRTPO, PTSTAT');
740cA    CrtIdx    (5: 'PTWHSE, PTTASK');
740hA    CrtIdx    (6: 'PTTASK');
740iA    CrtIdx    (7: 'PTTASK, PTEMP#, PTSDTE, PTWHSE, PTETIM');
770gA    CrtIdx    (8: 'PTWHSE, PTEMP#, PTSDTE, PTETIM');
770gA    CrtIdx    (9: 'PTETIM');
770gA    CrtIdx    (10: 'PTWHSE, PTEMP#, PTSDTE, PTSTIM, PTTRN#');
770gA    CrtIdx    (11: 'PTWHSE, PTTASK, PTRTPO, PTPCS');
770aA    CrtIdx    (12: 'PTWHSE, PTTASK, PTRTPO');

       gtable='PIRTRAND';
         CrtIdx    (1: 'PTDWHSE, PTDTRAN, PTDGDTE, PTDGTIM');
         CrtIdx    (2: 'PTDWHSE, PTDTRAN, PTDEMPNUM');
         CrtIdx    (3: 'PTDWHSE, PTDSELI, PTDTRAN, PTDSTAT');
740hA    CrtIdx    (4: 'PTDWHSE, PTDSHFTDAY, PTDTRAN, PTDSTAT');
740iA    CrtIdx    (5: 'PTDTRAN, PTDWHSE, PTDSTAT, PTDGDTE');
740iA    CrtIdx    (6: 'PTDSTAT');
750kA    CrtIdx    (7: 'PTDSTS, PTDEMPNUM, PTDINDI, PTDIND');
760 A    CrtIdx    (8: 'PTDTASK, PTDSTAT');
760 A    CrtIdx    (9: 'PTDSELI, PTDSTAT');
760 A    CrtIdx    (10: 'PTDINDI, PTDSTAT');
760 A    CrtIdx    (11: 'PTDIND, PTDSTAT');
760 A    CrtIdx    (12: 'PTDSEL, PTDSTAT');
760 A    CrtIdx    (13: 'PTDEMPNUM, PTDSTS');
760aA    CrtIdx    (14: 'PTDTRAN,PTDWHSE,PTDGTIM,PTDGDTE,PTDSTAT');
760aA    CrtIdx    (15: 'PTDEMPNUM,PTDWHSE,PTDSTS,PTDETS');
760aA    CrtIdx    (16: 'PTDEMPNUM,PTDWHSE,PTDTASK,PTDSHFTDAY');
760aA    CrtIdx    (17: 'PTDSHFTDAY,PTDSTAT');
760aA    CrtIdx    (18: 'PTDEMPNUM,PTDWHSE,PTDSHFTDAY,PTDSTAT,PTDSTS,PTDTRAN');
760aA    CrtIdx    (19: 'PTDCREW,PTDSHFT,PTDSHFTDAY');
760aA    CrtIdx    (19: 'PTDCREW,PTDSHFT,PTDWHSE,PTDSHFTDAY');
760aA    CrtIdx    (21: 'PTDWHSE,PTDSTAT');
760aA    CrtIdx    (22: 'PTDSELI,PTDWHSE,PTDEMPNUM,PTDSHFTDAY');
770fA    CrtIdx    (23: 'PTDWHSE, PTDTASK, PTDEMPNUM, PTDSTS');
770fA    CrtIdx    (24: 'PTDWHSE,PTDGDTE,PTDGTIM,PTDTRAN,PTDSTAT');
770fA    CrtIdx    (25: 'PTDWHSE,PTDDIRI,PTDEMPNUM,PTDSTAT,PTDEUC');
770fA    CrtIdx    (26: 'PTDWHSE,PTDTRAN,PTDADDUC');
770fA    CrtIdx    (27: 'PTDTASK');
770fA    CrtIdx    (28: 'PTDWHSE,PTDRCVI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770fA    CrtIdx    (29: 'PTDWHSE,PTDRPLI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770fA    CrtIdx    (30: 'PTDWHSE,PTDSELI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770fA    CrtIdx    (31: 'PTDWHSE,PTDTFRI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770fA    CrtIdx    (32: 'PTDWHSE,PTDLOADI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770fA    CrtIdx    (33: 'PTDWHSE,PTDSELI,PTDSHFT,PTDSTAT,PTDEMPNUM,' +
770fA                   'PTDSHFTDAY');
770fA    CrtIdx    (34: 'PTDWHSE,PTDSELI,PTDSHFT,PTDSTAT,PTDEMPNUM,PTDSHFTDAY');
770fA    CrtIdx    (35: 'PTDRPLI, PTDSHFT');
770fA    CrtIdx    (36: 'PTDWHSE,PTDRPLI,PTDSHFT,PTDSHFTDAY,PTDEMPNUM');
770fA    CrtIdx    (37: 'PTDTFRI, PTDSHFT');
770fA    CrtIdx    (38: 'PTDWHSE,PTDTFRI,PTDSHFT,PTDSHFTDAY,PTDEMPNUM');
770fA    CrtIdx    (38: 'PTDWHSE,PTDLOADI,PTDSHFT,PTDSHFTDAY,PTDSTS');
770gA    CrtIdx    (39: 'PTDSELI, PTDSHFT');
770gA    CrtIdx    (40: 'PTDWHSE,PTDSELI,PTDSHFT,PTDSHFTDAY,PTDEMPNUM');
770gA    CrtIdx    (41: 'PTDRCVI, PTDSHFT');
770gA    CrtIdx    (42: 'PTDWHSE,PTDRCVI,PTDSHFT,PTDSHFTDAY,PTDEMPNUM');
770gA    CrtIdx    (43: 'PTDWHSE,PTDSHFT,PTDSHFTDAY,PTDEMPNUM');

740iA  gTable='PLTSTP';
740iA    CrtIdx    (1: 'PSSPLI');

740gA  gTable='PLTSUM';
740gA    CrtIdx    (1: 'PSWHSE, PSGEN, PSTYPE, PSRTID, PSPCS');
740gA    CrtIdx    (2: 'PSWHSE, PSRTID, PSROW, PSCOL');
740gA    CrtIdx    (3: 'PSGEN, PSTYPE');
750hA    CrtIdx    (4: 'PSWHSE,PSRTID,PSPLID');
750hA    CrtIdx    (5: 'PSWHSE,PSRTID,PSTYPE');
740gA    CrtIdx    (6: 'PSWHSE, PSRTID, PSGEN, PSPLID');

740hA  gTable='PLTSUMU';
740hA    CrtIdx    (1: 'PSUVID, PSUADDTS');

740eA  gTable='PODTL';
740eA    CrtIdx (1: 'PDWHSE, PDPO, PDSPCL');
740eA    CrtIdx (2: 'PDWHSE, PDPO, PDSEQ, PDSPCL');
740eA    CrtIdx (3: 'PDITEM');

740eA  gTable='POHDR';
740eA    CrtIdx (1: 'PHPO, PHWHSE');
740eA    CrtIdx (2: 'PHSTAT');
740eA    CrtIdx (3: 'PHUDTE, PHWHSE, PHSTAT');
740eA    CrtIdx (4: 'PHUDTE, PHSTAT');
740eA    CrtIdx (5: 'PHVNAM');
740eA    CrtIdx (6: 'PHDATE, PHWHSE, PHPO');
770eA    CrtIdx (7: 'PHWHSE, PHPO, PHDATE');
770eA    CrtIdx (8: 'PHDATE');

740gA  gTable='RTEHED';
740gA    CrtIdx    (1: 'RHTYPE, RHSTAT');
740gA    CrtIdx    (2: 'RHSTAT');
740gA    CrtIdx    (3: 'RHWHSE, RHTYPE, RHRTE, RHRTID, RHSTAT');
740gA    CrtIdx    (4: 'RHTYPE, RHSTAT, RHRTE, RHRTID');
740gA    CrtIdx    (5: 'RHTYPE, RHWHSE, RHSTAT');
740gA    CrtIdx    (6: 'RHTYPE, RHRTE, RHRTID');
770hA    CrtIdx    (7: 'RHRTE, RHRTID');
750 D    //CrtIdx    (8: 'RHTYPE, RHSTAT, RHRTE, RHRTID');
750 A    CrtIdx    (9: 'RHRTID');
750 A    CrtIdx    (10: 'RHTYPE, RHSTAT, RHEXPD, RHEXPT, RHRTE, RHRTID');
750aA    CrtIdx    (11: 'RHTYPE, RHSTAT, RHWHSE, RHTRUK, RHRTE, RHRTID');
760cA    CrtIdx    (12: 'RHSTAT, RHWHSE, RHRTID');
770dA    CrtIdx    (13: 'RHWHSE, RHRTID, RHIMPD');
770fA    CrtIdx    (14: 'RHRTID, RHSTAT');
770fA    CrtIdx    (15: 'RHTYPE, RHSTAT, RHEXPD');
770gA    CrtIdx    (16: 'RHSTAT, RHTYPE');
770gA    CrtIdx    (17: 'RHSTAT, RHRTE, RHRTID');

740fA  gTable='SLOT';
740fA    CrtIdx (1: 'SLITEM, SLWHSE, SLEXPD');
740fA    CrtIdx (2: 'SLWHSE, SLEXPD');
740fA    CrtIdx (3: 'SLWHDP, SLWHSE, SLSDEF');
740fA    CrtIdx (4: 'SLWHDP, SLDISP, SLWHSE, SLSTAT');
740fA    CrtIdx (5: 'SLWHDP, SLSTAT, SLWHSE');
740fA    CrtIdx (6: 'SLITEM, SLWHSE, SLSDEF');
740fA    CrtIdx (7: 'SLAISL, SLWHDP, SLWHSE, SLDISP');
740fA    CrtIdx (8: 'SLSDEF, SLWHDP, SLWHSE, SLBLD');
740fA    CrtIdx (9: 'SLWHDP, SLAISL, SLLOC');
740fA    CrtIdx (10: 'SLPICK, SLSTAT, SLEXPD');
740fA    CrtIdx (11: 'SLWHSE, SLITEM, SLPICK, SLENTD');
740fA    CrtIdx (12: 'SLSTAT, SLWHSE, SLPICK');
740hA    CrtIdx (13: 'SLWHSE, SLITEM, SLSDEF');
740iA    CrtIdx (14: 'SLWHSE, SLWHDP, SLSDEF, SLBLD');
750cA    CrtIdx (15: 'SLWHDP, SLWHSE, SLSTAT');
750eA    CrtIdx (16: 'SLWHDP, SLPICK, SLSTAT, SLWHSE, SLITEM');
750eA    CrtIdx (18: 'SLWHDP, SLSTAT, SLITEM, SLDESG, SLWHSE');
750eA    CrtIdx (19: 'SLDESG, SLSTAT, SLWHSE, SLDISP, SLWHDP');
750eA    CrtIdx (20: 'SLWHDP, SLSTAT, SLDESG, SLITEM');
750eA    CrtIdx (21: 'SLWHDP, SLWHSE, SLSTK1');
750eA    CrtIdx (22: 'SLWHDP, SLWHSE, SLSTK2');
750eA    CrtIdx (23: 'SLWHDP, SLWHSE, SLSTK3');
750eA    CrtIdx (24: 'SLITEM, SLAISL, SLWHSE, SLSIDE, SLWHDP, SLRLVL');
750eA    CrtIdx (25: 'SLAISL, SLWHSE, SLITEM');
750eA    CrtIdx (26: 'SLRLVL, SLITEM, SLWHSE, SLDISP');
750eA    CrtIdx (27: 'SLAISL, SLWHSE, SLWHDP, SLDISP');
750hA    CrtIdx (28: 'SLPICK, SLITEM, SLWHSE');
750hA    CrtIdx (29: 'SLPICK, SLWHDP, SLITEM, SLWHSE,SLSTAT');
760bA    CrtIdx (30: 'SLWHSE, SLSTAT');

740hA  gTable='SLOTDEF';
740hA    CrtIdx (1: 'SDWHSE, SDPAL, SDCODE');

770fA  gTable='STGBATCH';
770fA    CrtIdx (1: 'SBSTATUS, SBTYPE');
770fA    CrtIdx (2: 'SBSTATUS, SBTYPE,SBBATID');

770gA  gTable='SUM001';
770gA    CrtIdx (1: 'SMSHIFT, SMTYPE, SMSESSID, SMPCS');

780aA  gTable='SUM022';
780aA    CrtIdx (1: 'SMADDTS');

740iA  gTable='TRUCKH';
740iA    CrtIdx (1: 'THTYPE, THWHSE');

770gA  gTable='TTRTN';
770gA    CrtIdx (1: 'TTWHSE, TTSTOP, TTRTID');

770fA  gTable='UCIINFO';
770fA    CrtIdx (1: 'UIWHSE,UIRTNTRN#,UIUCI,UISELTRN#');
770fA    CrtIdx (2: 'UIWHSE,UISELTRN#,UIUCI');
770fA    CrtIdx (3: 'UIWHSE,UISELTRN#,UILCNS');
770fA    CrtIdx (4: 'UIWHSE,UILCNS,UIWGTLBS');
770fA    CrtIdx (5: 'UIWHSE,UIRTNTRN#,UISELTRN#,UISELLBL#');
770fA    CrtIdx (6: 'UIWHSE,UISELTRN#,UISELLBL#,UIUCI');

770fA  gTable='UPC';
770fA    CrtIdx (1: 'UPWHSE,UPUTYP,UPITEM,UPCTYP');

750eA  gTable='VSLOT';
750eA    CrtIdx (1: 'VSPDIS, VSWHSE');
750eA    CrtIdx (2: 'VSDISP, VSWHDP');

       gTable='WORKLBL';
         CrtUnqIdx (1: 'LWWHSE, LWLBL#');
750hA    CrtIdx (2: 'LWWHSE,LWRTE,LWCTR#,LWTYPE,LWPAL#');
750hA    CrtIdx (3: 'LWWHSE,LWSEQ,LWORD,LWRTE,LWPAL#,LWITEM,LWTYPE,LWDISP');
750hA    CrtIdx (4: 'LWWHSE,LWRTE,LWORD,LWSEQ,LWPAL#,LWITEM,LWTYPE,LWDISP, +
750hA                LWCTR#,LWASL2,LWUTYP');
750hA    CrtIdx (5: 'LWWHSE,LWTYPE,LWCTR#');
750hA    CrtIdx (6: 'LWWHSE,LWTYPE,LWPAL#,LWRTE,LWCTR#');
750hA    CrtIdx (7: 'LWWHSE,LWTYPE,LWLBL#');
760cA    CrtIdx (8: 'LWTYPE,LWLVL2,LWTRN#,LWWHSE,LWRTE');
770fA    CrtIdx (9: 'LWTRN#');
       return;

      /end-free

750jA*----------------------------------------------------------------
750jA*  bldViews - Build Misc., Views
750jA*----------------------------------------------------------------

750jA /free
          begsr bldViews;

750jA       // Build view to determine available OHCORD id's for
750jA       // customers using alpha order numbers.  Used in GETCUST
            monitor;
750jA       ordhocord(pPFLib: pPFLib);

750jA       // Build several views over Slot file
750jA       slot16(pPFLib: pPFLib);

750jA       // Build several views over Slot file
750jA       slot17(pPFLib: pPFLib);

750jA       // Build several views over Slot file
750jA       slot18(pPFLib: pPFLib);

750jA       // Drop Pick View
750jA       dpckncfg(pPFLib: pPFLib);

750jA       // GUI Truck Map Detail View
750jA       tsdetail(pPFLib: pPFLib);
            on-error;
            endmon;

          endsr;
750jA /end-free

     *----------------------------------------------------------------
     *  CrtIdx  Create non-unique Index
     *----------------------------------------------------------------

     p CrtIdx          b
     d CrtIdx          pi
     d  indexNum                      5  0 const
     d  fields                      200    const varying

     d  indexName      s             50    varying

      /free

750bA  // See if we are limiting to specific file
750bA
750bA  if limitFile and gTable <> pFile;
750bA    return;
750bA  endif;

       indexName = gTable + '_INDEX_' + %editc(indexNum:'X');

       sqlstmt = 'CREATE INDEX ' + gLibrary + '.' + indexName
               + ' ON ' + gLibrary + '.' + gTable
               + ' (' + fields + ')'
               + ' UNIT ANY'
               + ' KEEP IN MEMORY NO';

       //debugStr1 = %subst(sqlstmt:1:1000);
       //debugStr2 = %subst(sqlstmt:1001);

       exec sql execute immediate :sqlstmt;

       // Leave if Index already exists

       if sqlstt = sqlDupObj;
         return;
       endif;

       // Error Occured

       if sqlstt <> sqlSuccess;
         dsplyMsg = '(' + sqlstt + ') ' + indexName + ' not created';
         dsply dsplyMsg;
         return;
       endif;

       // Otherwise, Index created, add Label

       sqlstmt = 'LABEL ON INDEX ' + gLibrary + '.' + indexName
               + ' IS ' + sq + 'CRTINDEXES - ' + indexName + sq;

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
        endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CrtUnqIdx  Create unique Index
     *----------------------------------------------------------------

     p CrtUnqIdx       b
     d CrtUnqIdx       pi
     d  indexNum                      5  0 const
     d  fields                      200    const varying

     d  indexName      s             50    varying

      /free

750bA  // See if we are limiting to specific file
750bA
750bA  if limitFile and gTable <> pFile;
750bA    return;
750bA  endif;

       indexName = gTable + '_INDEX_' + %editc(indexNum:'X');

       sqlstmt = 'CREATE UNIQUE INDEX ' + gLibrary + '.' + indexName
               + ' ON ' + gLibrary + '.' + gTable
               + ' (' + fields + ')'
               + ' UNIT ANY'
               + ' KEEP IN MEMORY NO';

       //debugStr1 = %subst(sqlstmt:1:1000);
       //debugStr2 = %subst(sqlstmt:1001);

       exec sql execute immediate :sqlstmt;

       // Leave if Index already exists

       if sqlstt = sqlDupObj;
         return;
       endif;

       // Error Occured

       if sqlstt <> sqlSuccess;
         dsplyMsg = '(' + sqlstt + ') ' + indexName + ' not created';
         dsply dsplyMsg;
         return;
       endif;

       // Otherwise, Index created, add Label

       sqlstmt = 'LABEL ON INDEX ' + gLibrary + '.' + indexName
               + ' IS ' + sq + 'CRTINDEXES - ' + indexName + sq;

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
        endif;

       return;

      /end-free

     p                 e

