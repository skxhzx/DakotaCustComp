     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK135    Clear files for warehouse 900 pick test - Clear
     *  15 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
405 A*    09/17/97  DAS  4.05
     *      - Added files CROSSDK, POHDR, PODTL, IMPPO*, EXPPO*,
     *        POHHDR and POHDTL.
     *
411 A*    06/10/99  DAS  4.11
     *      - Added Dataareas PIRBATCH, PIRLABEL, PIRPALET, PIRPO#
     *        and PIRTRAN.
     *      - Added files ITEMADJ, EXPADJ, ITEMEXP, IMPRTN, EXPRTN,
     *        ORDRTN, ORRTNBAT, ORDSLCT, BATCTL and POMFR.
     *
413 A*    02/10/00  DAS  4.13
     *      - Added files LICENSE and VSLOT
     *
413aA*    03/13/00  DAS  4.13a
     *      - Revised to read PIRTRAN file to find greatest tran#
     *        in file, add 1 to it and then update the next tran#
     *        file. This was done because IDLE transactions do not
     *        get a warehouse attached to them and thus don't get
     *        deleted from the file.
     *
415 A*    02/07/01  DAS  4.15
     *      - Added files PORCV
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416aA*    11/08/01  RH   4.16a
    A*      - File ORRTN changed, Re-compile only.
416bA*    03/12/02  RH   4.16a
    A*      - File ORDSLCT changed, Re-compile only.
416bA*    05/23/02  RH   4.16b
    A*      - LICENSE and PORCV files changed, Re-compile only.
417aA*    07/08/03  RH   4.17a
    A*      - ORDT file changed, Re-compile only.
417bA*    01/15/04  DAS  4.17b
    A*      - Added files FLGTRAN, INVCHK, LICHIST, LICINFO, MULTTRAN,
    A*        POEXCP, POHEXCP, PRPLFIL, RCVEXCP, SLOTPOS, WORKRPL.
     *
500 A*    02/19/05  DAS  5.00
     *      - Converted to ILE.
     *      - Added files LABELPS, ORDDM, ORDBOX, ORDEXPDTE, ORDLBL
     *
500aA*    03/10/06  DAS  5.00
     *      - Added file ORDSKIPCW
510 A*    11/20/06  RAH   5.10
     *      - Enh: Add POHACCP and POHHACCP.
510bA*    01/08/07  RH    5.10b
     *      - Enh: Recompile POHHACCP file key changed.
510cA*    05/24/07  DAS  5.10c
     *      - Added file RUNNER, ITMEXCP
510dA*    06/19/07  RBD  5.10d
     *      - Added file RTECSUM.
600aA*    11/21/08  DAS  6.00a
     *      - Added file LICACTIVE, LICLOG.
600bA*    05/01/09  DAS  6.00b
     *      - Added file WORKOSS.
600cA*    05/10/09  DAS  6.00c
     *      - Added file WORKUSR.
600dA*    05/21/09  DAS  6.00d
     *      - Added file ORRTN, ORRTNM, labelnk.
610aA*    02/09/10  DAS  6.10a
     *      - Added file BULKDRP
610bA*    11/29/10  DAS  6.10b
     *      - Added file PREXREF
610cA*    12/01/10  DAS  6.10c
     *      - Added file LDRDETL
640aA*    07/22/11  DAS  6.40a
     *      - Added files ORDBSUM, ORDBDTL
640bA*    01/02/12  DAS  6.40b
     *      - Added file LABELDO
640cA*    05/29/12  DAS  6.40c
     *      - Added file RTESTP
640dA*    10/07/12  DAS  6.40d
     *      - Added file PIRTRCK
640eA*    06/06/12  LMC  6.40e
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    01/15/13  DAS  6.50a
     *      - Removed 640e change.
     *      - Added file PIRTRAND.
650bA*    01/23/13  DAS  6.50b
     *      - Added file LDRHDR, LDRTEQ
650cA*    06/13/13  RBD  6.50c
     *      - Recompiled only, RTESTP changed.
700 A*    03/05/15  KDE  7.00
     *      - Enh: Added clears for Production files
700aA*    01/30/16  DAS  7.00a
     *      - Added file AMPBOX, AMPXREF, TOTEHDR
700bA*    02/15/16  DAS  7.00b
     *      - Added file ORDCFLG
700cA*    07/11/16  LMC  7.00c
     *      - Recompile only - DB change to workoss.
710 A*    02/13/17  KDE  7.10
     *      - Recompile only - DB change to prodlog.
710aA*    11/20/17  DAS  710a
     *      - Added ORDP, TT Trax files
     *      - Removed ITEMEXP because it doesn't exist.
     *      - Revised PIRRTE# to set to 99001 for user DAVE.
710bA*    01/05/18  DAS  710b
     *      - Added PIRCADEC dataarea.
720 A*    01/22/18  KDE  720
     *      - Added more Production Files
720aA*    04/12/18  DAS  720a
     *      - Added DDDETAIL, DDTASK files
720bA*    01/07/19  DAS  720b
     *      - Added ITEMADJL, ITEMADJM, UCIINFO, UCILOG, UCISPLITS
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
730bA*    04/24/19  DAS  720b
     *      - Added PLTMISC, RTEHEDEXA, ORDHEXA
     *
730cA*    09/04/19  DAS  7.30a
     *      - Added warehouse.
730dA*    12/04/19  DAS  720d
     *      - Added STGBATCH, IMPSORDH, IMPSORDD, PIRRECID#
750aA*    08/05/21  DAS  750a
     *      - Added DDDETAILH, DDTASKH files
750bA*    09/15/21  DAS  750b
     *      - Added LABELOUT file
760aA*    04/15/22  DAS  7.60a
     *      - Added ORDAUD, ORDAUDA, ORDAUDCH, ORDAUDCD, ORDAUDH
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpck135fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
413aAFpirtran   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
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
     *  Variables
     *
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s              3  0
     D msgk            s              4  0
     D sclear          s              1
730aAD i               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
730cA*      $PWHSEA Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
730cAC                   parm                    $pwhsea           3
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
730aA*  Now uses sent warehouse.
     *
730aDC**                 eval      kywhse = 900
      /free
730cM    kywhse = %dec($pwhsea: 3: 0);
730cA    if kywhse < 900;
730cA      dsply 'Whse must be 900+';
730cA      return;
730cA     endif;
      /end-free
700aA*-------------------------------------------------------------------------
700aA*
700aA*  Clear file AMPBOX
700aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'AMPBOX'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ampbox
     C+  where  (abxwhse = :kywhse)
     C/END-EXEC
700aA*-------------------------------------------------------------------------
700aA*
700aA*  Clear file AMPXREF
700aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'AMPXREF'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ampxref
     C+  where  (axwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file BATCTL.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'BATCTL  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   batctl
     C+  where  (btwhse = :kywhse)
     C/END-EXEC
610aA*-------------------------------------------------------------------------
610aA*
610aA*  Clear file BULKDRP
610aA*
610aAC                   if        $pjtyp = *on
     C                   eval      w1file = 'BULKDRP '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   bulkdrp
     C+  where  (bdwhse = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file CROSSDK.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'CROSSDK '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   crossdk
405 AC+  where  (cdwhse = :kywhse)
405 AC/END-EXEC
720aA*-------------------------------------------------------------------------
720aA*
720aA*  Clear file DDDETAIL
720aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'DDDETAIL'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   dddetail
     C+  where  (dddwhse = :kywhse)
     C/END-EXEC
750aA*-------------------------------------------------------------------------
750aA*
750aA*  Clear file DDDETAILH
750aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'DDDETAILH'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   dddetailh
     C+  where  (dddwhse = :kywhse)
     C/END-EXEC
720aA*-------------------------------------------------------------------------
720aA*
720aA*  Clear file DDDTASK
720aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'DDTASK'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ddtask
     C+  where  (ddtwhse = :kywhse)
     C/END-EXEC
750aA*-------------------------------------------------------------------------
750aA*
750aA*  Clear file DDDTASKH
750aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'DDTASKH'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ddtaskh
     C+  where  (ddtwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file EXPADJ.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'EXPADJ  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   expadj
     C+  where  (iewhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPORDD.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'EXPORDD '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   expordd
     C+  where  (oedwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file EXPORDH.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'EXPORDH '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   expordh
     C+  where  (oehwhs = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file EXPPOD.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'EXPPOD  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   exppod
405 AC+  where  (pedwhs = :kywhse)
405 AC/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file EXPPOH.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'EXPPOH  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   exppoh
405 AC+  where  (pehwhs = :kywhse)
405 AC/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file EXPRTN.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'EXPRTN  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   exprtn
     C+  where  (oewhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPORDD.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'IMPORDD '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   impordd
     C+  where  (oidwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file IMPORDH.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'IMPORDH '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   impordh
     C+  where  (oihwhs = :kywhse)
     C/END-EXEC
730dA*-------------------------------------------------------------------------
730dA*
730dA*  Clear file IMPSORDD
730dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'IMPSORDD '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   impsordd
     C+  where  (oidwhs = :kywhse)
     C/END-EXEC
730dA*-------------------------------------------------------------------------
730dA*
730dA*  Clear file IMPSORDH
730dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'IMPSORDH '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   impsordh
     C+  where  (oihwhs = :kywhse)
     C/END-EXEC
730dA*-------------------------------------------------------------------------
730dA*
730dA*  Clear file STGBATCH
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'STGBATCH'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   stgbatch
     C+  where  sbwhse = :kywhse and sbtype in ('IMPROUTE', 'EXPROUTE')
     C/END-EXEC

417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file FLGTRAN
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'FLGTRAN '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   flgtran
     C+  where  (fgwhse = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file IMPPOD.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'IMPPOD  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   imppod
405 AC+  where  (pidwhs = :kywhse)
405 AC/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file IMPPOH.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'IMPPOH  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   imppoh
405 AC+  where  (pihwhs = :kywhse)
405 AC/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file IMPRTN.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'IMPRTN  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   imprtn
     C+  where  (oirwhs = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file INVCHK
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'INVCHK  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   invchk
     C+  where  (ivcwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ITEMADJ.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ITEMADJ '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   itemadj
     C+  where  (iawhse = :kywhse)
     C/END-EXEC
720bA*-------------------------------------------------------------------------
720bA*
720bA*  Clear file ITEMADJL
720bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ITEMADJL'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   itemadjl
     C+  where  (ialwhse = :kywhse)
     C/END-EXEC
720bA*-------------------------------------------------------------------------
720bA*
720bA*  Clear file ITEMADJM
720bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ITEMADJM'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   itemadjm
     C+  where  (inwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
710aD*  Clear file ITEMEXP.
710aD*
710aDC*                  if        $pjtyp = *on
710aDC*                  eval      w1file = 'ITEMEXP '
710aDC*                  write     screen1
710aDC*                  endif
710aDC*EXEC SQL
710aDC*  delete
710aDC*  from   itemexp
710aDC*  where  (exwhse = :kywhse)
710aDC*END-EXEC
510cA*-------------------------------------------------------------------------
510cA*
510cA*  Clear file ITMEXCP
510cA*
510cAc                   if        $pjtyp = *on
510cAc                   eval      w1file = 'ITMEXCP'
510cAc                   write     screen1
510cAc                   endif
510cAc/exec sql
510cAc+  delete
510cAc+  from   itmexcp
510cAc+  where  (exwhse = :kywhse)
510cAc/end-exec
     *-------------------------------------------------------------------------
     *
     *  Clear file LABEL.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LABEL   '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   label
     C+  where  (lbwhse = :kywhse)
     C/END-EXEC
640bA*-------------------------------------------------------------------------
640bA*
640bA*  Clear file LABELDO
640bA*
640bAC                   if        $pjtyp = *on
     C                   eval      w1file = 'LABELDO '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   labeldo
     C+  where  (lbowhse = :kywhse)
     C/END-EXEC
600dA*-------------------------------------------------------------------------
600dA*
600dA*  Clear file LABELNK
600dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LABELNK'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   labelnk
     C+  where  not exists (select lblbl# from label where lblbl#=lllblo)
     C/END-EXEC
750bA*-------------------------------------------------------------------------
750bA*
750bA*  Clear file LABELOUT
750bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LABELOUT'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   labelout
     C+  where  (lowhse = :kywhse)
     C/END-EXEC
500 A*-------------------------------------------------------------------------
500 A*
500 A*  Clear file LABELPS
500 A*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LABELPS '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   labelps
     C+  where  (lswhse = :kywhse)
     C/END-EXEC
600aA*-------------------------------------------------------------------------
600aA*
600aA*  Clear file LICACTIVE
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LICACTIVE'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   licactive
     C+  where  (lawhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
413 A*  Clear file LICENSE.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LICENSE '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   license
     C+  where  (liwhse = :kywhse)
     C/END-EXEC
600aA*-------------------------------------------------------------------------
600aA*
600aA*  Clear file LICLOG
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LICLOG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   liclog
     C+  where  (llwhse = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file LICHIST
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LICHIST '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   lichist
     C+  where  (lrwhse = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file LICINFO
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'LICINFO '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   licinfo
     C+  where  (lnwhse = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file MULTRAN
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'MULTRAN '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   multran
     C+  where  (muwhse = :kywhse)
     C/END-EXEC
760aA*-------------------------------------------------------------------------
760aA*
760aA*  Clear file ORDAUD
760aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDAUD'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordaud
     C+  where  (oawhse = :kywhse)
     C/END-EXEC
760aA*-------------------------------------------------------------------------
760aA*
760aA*  Clear file ORDAUDA
760aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDAUDA'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordauda
     C+  where  (oaawhse = :kywhse)
     C/END-EXEC
760aA*-------------------------------------------------------------------------
760aA*
760aA*  Clear file ORDAUDCH
760aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDAUDCH'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordaudch
     C+  where  (oachwhse = :kywhse)
     C/END-EXEC
760aA*-------------------------------------------------------------------------
760aA*
760aA*  Clear file ORDAUDCD
760aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDAUDCD'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordaudcd
     C+  where  (oacdwhse = :kywhse)
     C/END-EXEC
760aA*-------------------------------------------------------------------------
760aA*
760aA*  Clear file ORDAUDH
760aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDAUDH'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordaudh
     C+  where  (oahwhse = :kywhse)
     C/END-EXEC
640aA*-------------------------------------------------------------------------
640aA*
640aA*  Clear file ORDBDTL
640aA*
640aAC                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDBDTL '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordbdtl
     C+  where  (bpdwhs = :kywhse)
     C/END-EXEC
640aA*-------------------------------------------------------------------------
640aA*
640aA*  Clear file ORDBSUM
640aA*
640aAC                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDBSUM '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordbsum
     C+  where  (bpwhse = :kywhse)
     C/END-EXEC
500 A*-------------------------------------------------------------------------
500 A*
500 A*  Clear file ORDBOX
500 A*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDBOX  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordbox
     C+  where  (obwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDC.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDC    '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordc
     C+  where  (ocwhse = :kywhse)
     C/END-EXEC
700bA*-------------------------------------------------------------------------
700bA*
700bA*  Clear file ORDCFLG
700bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDCFLG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordcflg
     C+  where  (ocfwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDD.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDD    '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordd
     C+  where  (odwhse = :kywhse)
     C/END-EXEC
500 A*-------------------------------------------------------------------------
500 A*
500 A*  Clear file ORDDM
500 A*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDDM   '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   orddm
     C+  where  (omwhse = :kywhse)
     C/END-EXEC
500 A*-------------------------------------------------------------------------
500 A*
500 A*  Clear file ORDEXPDTE
500 A*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDEXPDTE'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordexpdte
     C+  where  (oewhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDH.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDH    '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordh
     C+  where  (ohwhse = :kywhse)
     C/END-EXEC
730bA*-------------------------------------------------------------------------
730bA*
730bA*  Clear file ORDHEXA
730bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDHEXA  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordhexa
     C+  where  (ohawhse = :kywhse)
     C/END-EXEC
500 A*-------------------------------------------------------------------------
500 A*
500 A*  Clear file ORDLBL
500 A*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDLBL'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordlbl
     C+  where  (alwhse = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file ORDP
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDP'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordp
     C+  where  (orpwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORRTN.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORRTN  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   orrtn
     C+  where  (orwhse = :kywhse)
     C/END-EXEC
600dA*-------------------------------------------------------------------------
600dA*
600dA*  Clear file ORRTN.
600dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORRTN  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   orrtn
     C+  where  (orwhse = :kywhse)
     C/END-EXEC
600dA*-------------------------------------------------------------------------
600dA*
600dA*  Clear file ORRTNM
600dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORRTNM '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   orrtnm
     C+  where  (rmwhse = :kywhse)
     C/END-EXEC
500aA*-------------------------------------------------------------------------
500aA*
500aA*  Clear file ORDSKIPCW
500aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDSKIPCW'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordskipcw
     C+  where  (oscwhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORDSLCT.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDSLCT '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordslct
     C+  where  (oswhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file ORDT.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORDT    '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ordt
     C+  where  (otwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file ORTNBAT
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORTNBAT '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ortnbat
     C+  where  (obrwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file ORRTNM
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'ORRTNM'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   orrtnm
     C+  where  (rmwhse = :kywhse)
     C/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PBOMMAR - Production Marinade Assoc. to BOM
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PBOMMAR   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pbommar
720 AC+  where  (pawhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PBOMSUB - Production Substitutes
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PBOMSUB   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pbomsub
720 AC+  where  (sbwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PBOMVERH - Production Dynamic BOM Header
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PBOMVERH  '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pbomverh
720 AC+  where  (phwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PBOMVERS - Production Dynamic BOM Detail
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PBOMVERS  '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pbomvers
720 AC+  where  (pxwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PCOSTSTSD - Production Costing Status Detail
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PCOSTSTSD '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pcoststsd
720 AC+  where  (pdwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PCOSTSTSH - Production Costing Daily Statue Header
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PCOSTSTSH '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pcoststsh
720 AC+  where  (pcwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PCOSTWOL - Production Costing Labor
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PCOSTWOL '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pcostwol
720 AC+  where  (cslwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PCOSTWOM - Production Costing Material
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PCOSTWOM '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pcostwom
720 AC+  where  (csmwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PCOSTWOO - Production Costing Overhead
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PCOSTWOO  '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pcostwoo
720 AC+  where  (csowhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PMARIND - Production Marinade Detail
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PMARIND   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pmarind
720 AC+  where  (mdwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PMARINH - Production Marinade Header
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PMARINH   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pmarinh
720 AC+  where  (mhwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PMARINI - Production Marinade Instructions
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PMARINI   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pmarini
720 AC+  where  (miwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PMARINM - Production Marinade Measurements
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PMARINM   '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pmarinm
720 AC+  where  (mewhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PSUBITMLOG -  Production Substitution Log
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PSUBITMLOG'
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   psubitmlog
720 AC+  where  (slwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PWRKMEATD -  Production Meat Work File
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PWRKMEATD '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pwrkmeatd
720 AC+  where  (pdwhse = :kywhse)
720 AC/END-EXEC
720 A*-------------------------------------------------------------------------
720 A*
720 A*  Clear file PWRKMEATH - Production Meat Work Header File
720 A*
720 AC                   if        $pjtyp = *on
720 AC                   eval      w1file = 'PWRKMEATH '
720 AC                   write     screen1
720 AC                   endif
720 AC/EXEC SQL
720 AC+  delete
720 AC+  from   pwrkmeath
720 AC+  where  (pwwhse = :kywhse)
720 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PALTERITEM - Production Alternate Item Work File
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PALTERITEM'
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   palteritem
700 AC+  where  (alwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PCSLOT - Production Customer Specific Slot
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PCSLOT   '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   pcslot
700 AC+  where  (cswhse = :kywhse)
700 AC/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRBATCH.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRBATCH'
     C                   write     screen1
     C                   endif
     C     *dtaara       define    pirbatch      next1             7 0
     C     *lock         in        next1
     C                   eval      next1 = 1
     C                   out       next1
     *-------------------------------------------------------------------------
     *
710bA*  Clear DataArea PIRCADEC.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRCADEC'
     C                   write     screen1
     C                   endif
     C     *dtaara       define    pircadec      nextcd#           5 0
     C     *lock         in        nextcd#
     C                   eval      nextcd# = 1
     C                   out       nextcd#
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRLABEL.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRLABEL'
     C                   write     screen1
     C                   endif
     C     *dtaara       define    pirlabel      next2             7 0
     C     *lock         in        next2
417bD**                   Z-ADD1         NEXT2
417bMC                   eval      next2 = 1001
     C                   out       next2
     *-------------------------------------------------------------------------
     *
730dA*  Reset PIRRECID# values
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRRECID#'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  update pirrecid#
     C+  set    nrirecid = 1000
     C+  where  nriwhse = :kywhse and nrifile = 'LABEL'
     C/END-EXEC
     C/EXEC SQL
     C+  update pirrecid#
     C+  set    nrirecid = 2000
     C+  where  nriwhse = :kywhse and nrifile = 'PIRTRAN'
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRORD#.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRORD# '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pirord#
     C+  where  (nxowhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRPALET.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRPALET'
     C                   write     screen1
     C                   endif
     C     *dtaara       define    pirpalet      next3             7 0
     C     *lock         in        next3
     C                   eval      next3 = 1
     C                   out       next3
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRPO#.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRPO#  '
     C                   write     screen1
     C                   endif
     C     *dtaara       define    pirpo#        next4             7 0
     C     *lock         in        next4
     C                   eval      next4 = 1
     C                   out       next4
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRRTE#.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRRTE# '
     C                   write     screen1
     C                   endif

710aAC                   if        #user = 'DAVE'
710aAC/EXEC SQL
710aAC+  update pirrte#
710aAC+  set    nxrnum = 99001
710aAC+  where  (nxrwhs = :kywhse)
710aAC/END-EXEC
710aAC                   else
     C/EXEC SQL
     C+  delete
     C+  from   pirrte#
     C+  where  (nxrwhs = :kywhse)
710aAC/END-EXEC
     C                   endif
     *-------------------------------------------------------------------------
     *
     *  Clear file PIRTRAN.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRTRAN '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pirtran
     C+  where  (ptwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear DataArea PIRTRAN.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRTRAN '
     C                   write     screen1
     C                   endif
413aAC     *hival        setgt     pirtran
413aAC                   readp     pirtran                                79
413aAC                   if        *in79
417bD**                   Z-ADD1         PTTRN#
417bMC                   eval      pttrn# = 2001
413aAC                   else
417bAC                   if        pttrn# < 2001
417bAC                   eval      pttrn# = 2001
417bAC                   else
413aAC                   add       1             pttrn#
417bAC                   endif
413aAC                   endif
     C     *dtaara       define    pirtran       next5             7 0
     C     *lock         in        next5
413aD**                   Z-ADD1         NEXT5
413aMC                   eval      next5 = pttrn#
     C                   out       next5
650aA*-------------------------------------------------------------------------
650aA*
650aA*  Clear file PIRTRAND
650aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRTRAND'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pirtrand
     C+  where  (ptdwhse = :kywhse)
     C/END-EXEC
640dA*-------------------------------------------------------------------------
640dA*
640dA*  Clear file PIRTRCK
640dA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PIRTRCK '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pirtrck
     C+  where  (trwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file PLTSTP.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PLTSTP  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pltstp
     C+  where  (psswhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file PLTSUM.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PLTSUM  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pltsum
     C+  where  (pswhse = :kywhse)
     C/END-EXEC
730bA*-------------------------------------------------------------------------
730bA*
730bA*  Clear file PLTMISC
730bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PLTMISC '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pltmisc
     C+  where  (pmwhse = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file PODTL.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'PODTL   '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   podtl
405 AC+  where  (pdwhse = :kywhse)
405 AC/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file POEXCP
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'POEXCP  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   poexcp
     C+  where  (pewhse = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHDR.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'POHDR   '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   pohdr
405 AC+  where  (phwhse = :kywhse)
405 AC/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHDTL.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'POHDTL  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   pohdtl
405 AC+  where  (phdwhs = :kywhse)
405 AC/END-EXEC
417bA*-------------------------------------------------------------------------
     *
510 a*  Clear file POHACCP.
     *
510 ac                   if        $pjtyp = *on
510 ac                   eval      w1file = 'POHACCP '
510 ac                   write     screen1
510 ac                   endif
510 ac/exec sql
510 ac+  delete
510 ac+  from   pohaccp
510 ac+  where  (hawhse = :kywhse)
510 ac/end-exec
     *-------------------------------------------------------------------------
     *
510 a*  Clear file POHHACCP.
     *
510 ac                   if        $pjtyp = *on
510 ac                   eval      w1file = 'POHHACCP'
510 ac                   write     screen1
510 ac                   endif
510 ac/exec sql
510 ac+  delete
510 ac+  from   pohhaccp
510 ac+  where  (hahwhse = :kywhse)
510 ac/end-exec
     *-------------------------------------------------------------------------
417bA*
417bA*  Clear file POHEXCP
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'POHEXCP '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pohexcp
     C+  where  (phewhs = :kywhse)
     C/END-EXEC
405 A*-------------------------------------------------------------------------
405 A*
405 A*  Clear file POHHDR.
405 A*
405 AC                   if        $pjtyp = *on
405 AC                   eval      w1file = 'POHHDR  '
405 AC                   write     screen1
405 AC                   endif
405 AC/EXEC SQL
405 AC+  delete
405 AC+  from   pohhdr
405 AC+  where  (phhwhs = :kywhse)
405 AC/END-EXEC
     *-------------------------------------------------------------------------
     *
411 A*  Clear file POMFR.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'POMFR   '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   pomfr
     C+  where  (pmwhse = :kywhse)
     C/END-EXEC
415 A*-------------------------------------------------------------------------
415 A*
415 A*  Clear file PORCV.
415 A*
415 AC                   if        $pjtyp = *on
415 AC                   eval      w1file = 'PORCV   '
415 AC                   write     screen1
415 AC                   endif
415 AC/EXEC SQL
415 AC+  delete
415 AC+  from   porcv
415 AC+  where  (porwhs = :kywhse)
415 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PRDDATE - Production Date File
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PRDDATE  '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   prddate
700 AC+  where  (pdwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PRDLBHIST - Production Label History
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PRDLBHIST'
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   prdlbhist
700 AC+  where  (lhwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PREMWGT - Production End of Day Actual Weight
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PREMWGT  '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   premwgt
700 AC+  where  (rwwhse = :kywhse)
700 AC/END-EXEC
610bA*-------------------------------------------------------------------------
610bA*
610bA*  Clear file PREXREF
610bA*
610bAC                   if        $pjtyp = *on
     C                   eval      w1file = 'PREXREF '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   prexref
     C+  where  (pxwhse = :kywhse)
     C/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PRMSUM - Production Raw Material Summary
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PRMSUM   '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   prmsum
700 AC+  where  (smwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PRODLOG - Production Log File
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PRODLOG  '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   prodlog
700 AC+  where  (plwhse = :kywhse)
700 AC/END-EXEC
610cA*-------------------------------------------------------------------------
610cA*
610cA*  Clear file LDRDETL
610cA*
610cAC                   if        $pjtyp = *on
     C                   eval      w1file = 'LDRDETL '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ldrdetl
     C+  where  (ldwhse = :kywhse)
     C/END-EXEC
650bA*-------------------------------------------------------------------------
650bA*
650bA*  Clear file LDRHDR
650bA*
650bAC                   if        $pjtyp = *on
     C                   eval      w1file = 'LDRHDR  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ldrhdr
     C+  where  (lhwhse = :kywhse)
     C/END-EXEC
650bA*-------------------------------------------------------------------------
650bA*
650bA*  Clear file LDRTEQ
650bA*
650bAC                   if        $pjtyp = *on
     C                   eval      w1file = 'LDRTEQ  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ldrteq
     C+  where  (ltwhse = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file PRPLFIL
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'PRPLFIL '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   prplfil
     C+  where  (prwhse = :kywhse)
     C/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PWRKORD - Production Work Order Header
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PWRKORD  '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   pwrkord
700 AC+  where  (wowhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PWRKORDR - Production Work Order RM Requirements
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PWRKORDR '
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   pwrkordr
700 AC+  where  (wrwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PWRKORDRU - Production Work Ord RM Usage
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PWRKORDRU'
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   pwrkordru
700 AC+  where  (urwhse = :kywhse)
700 AC/END-EXEC
700 A*-------------------------------------------------------------------------
700 A*
700 A*  Clear file PYIELDRPT - Production Yield Report Work File
700 A*
700 AC                   if        $pjtyp = *on
700 AC                   eval      w1file = 'PYIELDRPT'
700 AC                   write     screen1
700 AC                   endif
700 AC/EXEC SQL
700 AC+  delete
700 AC+  from   pyieldrpt
700 AC+  where  (smwhse = :kywhse)
700 AC/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file RTEHED.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'RTEHED  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   rtehed
     C+  where  (rhwhse = :kywhse)
     C/END-EXEC
730bA*-------------------------------------------------------------------------
730bA*
730bA*  Clear file RTEHEDEXA
730bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'RTEHEDEXA'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   rtehedexa
     C+  where  (rhawhse = :kywhse)
     C/END-EXEC
640cA*-------------------------------------------------------------------------
640cA*
640cA*  Clear file RTESTP.
640cA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'RTESTP  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   rtestp
     C+  where  (rtswhs = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file RTESUM.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'RTESUM  '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   rtesum
     C+  where  (rswhse = :kywhse)
     C/END-EXEC
510dA*-------------------------------------------------------------------------
510dA*
510dA*  Clear file RTECSUM.
510dA*
510dAC                   if        $pjtyp = *on
510dAC                   eval      w1file = 'RTECSUM '
510dAC                   write     screen1
510dAC                   endif
510dAC/EXEC SQL
510dAC+  delete
510dAC+  from   rtecsum
510dAC+  where  (rcwhse = :kywhse)
510dAC/END-EXEC
510cA*-------------------------------------------------------------------------
510cA*
510cA*  Clear file RUNNER.
510cA*
510cAc                   if        $pjtyp = *on
510cAc                   eval      w1file = 'RUNNER'
510cAc                   write     screen1
510cAc                   endif
510cAc/exec sql
510cAc+  delete
510cAc+  from   runner
510cAc+  where  (ruwhse = :kywhse)
510cAc/end-exec
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file SLOTPOS
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'SLOTPOS '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   slotpos
     C+  where  (spwhse = :kywhse)
     C/END-EXEC
700aA*-------------------------------------------------------------------------
700aA*
700aA*  Clear file TOTEHDR
700aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TOTEHDR'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   totehdr
     C+  where  (tohwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTFLAG
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTFLAG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttflag
     C+  where  (ttawhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTGRP
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTGRP'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttgrp
     C+  where  (ttgwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTITM
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTITM'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttitm
     C+  where  (ttiwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTLOG
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTLOG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttlog
     C+  where  (ttlwhse = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTMERG
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTMERG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttmerg
     C+  where  (ttmwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTRTE
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTRTE'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttrte
     C+  where  (ttrwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTRTN
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTRTN'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttrtn
     C+  where  (ttwhse = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTSTP
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTSTP'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttstp
     C+  where  (ttpwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTSTPFLG
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTSTPFLG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttstpflg
     C+  where  (ttfwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTSTPFR
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTSTPFR'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ttstpfr
     C+  where  (ttfrwh = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTTRKFLG
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTTRKFLG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   tttrkflg
     C+  where  (ttkwhs = :kywhse)
     C/END-EXEC
710aA*-------------------------------------------------------------------------
710aA*
710aA*  Clear file TTTRX
710aA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'TTTRX'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   tttrx
     C+  where  (ttxwhs = :kywhse)
     C/END-EXEC
720bA*-------------------------------------------------------------------------
720bA*
720bA*  Clear file UCIINFO
720bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'UCIINFO'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   uciinfo
     C+  where  (uiwhse = :kywhse)
     C/END-EXEC
720bA*-------------------------------------------------------------------------
720bA*
720bA*  Clear file UCILOG
720bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'UCILOG'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ucilog
     C+  where  (ulwhse = :kywhse)
     C/END-EXEC
720bA*-------------------------------------------------------------------------
720bA*
720bA*  Clear file UCISPLITS
720bA*
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'UCISPLITS'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   ucisplits
     C+  where  (uswhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
413 A*  Clear file VSLOT.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'VSLOT   '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   vslot
     C+  where  (vswhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file WORKLBL.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'WORKLBL '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   worklbl
     C+  where  (lwwhse = :kywhse)
     C/END-EXEC
600bA*-------------------------------------------------------------------------
600bA*
600bA*  Clear file WORKOSS
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'WORKOSS'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   workoss
     C+  where  (wowhse = :kywhse)
     C/END-EXEC
417bA*-------------------------------------------------------------------------
417bA*
417bA*  Clear file WORKRPL
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'WORKRPL '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   workrpl
     C+  where  (wrwhse = :kywhse)
     C/END-EXEC
600cA*-------------------------------------------------------------------------
600cA*
600cA*  Clear file WORKUSR
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'WORKUSR'
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   workusr
     C+  where  (wuwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     *
     *  Clear file WORKZON.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1file = 'WORKZON '
     C                   write     screen1
     C                   endif
     C/EXEC SQL
     C+  delete
     C+  from   workzon
     C+  where  (zwwhse = :kywhse)
     C/END-EXEC
     *-------------------------------------------------------------------------
     C                   eval      *inlr = *on
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
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck135fm
     C                   endif
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C                   read      pck135fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
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
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
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
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'UT81201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'UT81221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'UT81222'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'UT81223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
