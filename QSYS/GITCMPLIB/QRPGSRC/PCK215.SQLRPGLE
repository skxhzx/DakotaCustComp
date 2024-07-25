      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK215    Create test orders for warehouse 900 - Create
     *  17 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
403 A*    07/30/97  DAS  4.03
     *      - Changed TEST6 to include a normal pick.
     *
404 A*    09/05/97  DAS  4.04
     *      - Passing order type as a parameter.
     *
405 A*    09/17/97  DAS  4.05
     *      - Passing cross dock option as a parameter.
     *      - Added files IMPPOH and IMPPOD.
     *      - Added logic to create P.O.'s for cross docks.
     *
411 A*    06/13/99  DAS  4.11
     *      - Created test #10 for Alias, Contract and SSB items.
     *
416 A*    07/16/02  DAS  4.16
     *      - Added FTP option.
     *
640aA*    07/21/11  DAS  6.40a
     *      - Converted to ILE
     *      - Added Batch Pick option
     *      - Change FTP to user OI280 '4' files.
     *
640bA*    07/29/11  DAS  6.40b
     *      - Change to SQLRPGLE
     *      - Changed W1FTP option into an Import Method option.
     *      - Added Staging import method
     *
640cA*    05/29/12  DAS  6.40c
     *      - Initialized OIHEST field.
     *      - Revisted to write out OIHEST to IMPSORDH file.
     *
640dA*    09/07/12  DAS  6.40c
     *      - Added Pre Pick option
     *
700aA*    01/30/16  DAS  7.00a
     *      - Added AMP Pick option
     *
710aA*    06/13/17  DAS  7.10a
     *      - Changed Test 7 to a Trax test.
710bA*    07/10/17  DAS  7.10b
     *      - Revised CrtOIM to write oimrecf when $pftp='F'.
720AA*    06/14/18  DAS  7.20Z
     *      - Revised to set Stop from ord# to ord# * 10.
     *
730aA*    09/04/19  DAS  7.30a
     *      - Added warehouse.
     *
730bA*    12/04/19  DAS  7.30b
     *      - Added logic to populate staging pick slot when
     *        Feature is 3.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The tests that are created with this program assume
     *      the following:
     *
     *        - Max slot qty = 50.
     *        - Bulk pick is 40 cube.
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
     Fpck215fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
416 D*MPORDH1UF  E           K        DISK                      A
416 D*MPORDD UF  E           K        DISK                      A
416 MFimpordh1  uf a e           k disk    usropn
416 MFimpordd   uf a e           k disk    usropn
640aDF*mpfordh  o  a e           k disk    usropn
640aMFimpfordh4 o  a e           k disk    usropn
     F                                     rename(oihrec:oihrecf)
700aMFimpfordhm o  a e           k disk    usropn
640aDF*mpfordd  o  a e           k disk    usropn
640aMFimpfordd4 o  a e           k disk    usropn
     F                                     rename(oidrec:oidrecf)
640aAFimpforddm o  a e           k disk    usropn
640aAF                                     rename(oimrec:oimrecf)
405 AFimppoh    uf a e           k disk
405 AFimppod    uf a e           k disk

640bA*----------------------------------------------------------------
640bA*  File data data structure
640bA*----------------------------------------------------------------
640bA
640bAD oihrecs       E ds                  extname(impsordh) inz(*EXTDFT)
640bAD oidrecs       E ds                  extname(impsordd) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D cname           s             40    dim(20) ctdata perrcd(1)
     D cadr1           s             40    dim(20) ctdata perrcd(1)
     D misc            s             20    dim(20) ctdata perrcd(1)
405 AD vname           s             40    dim(1) ctdata perrcd(1)
405 AD vadr1           s             40    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for Y/N options
     *
     D $pyn            ds
     D  test                   1     20
     D                                     DIM(20)
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
640bAD  batId          s             11
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kypo            s                   like(pihpo)
     D kyrte           s                   like(oihrte)
     D kytype          s                   like(oihtyp)
     D kywhse          s                   like(oihwhs)
     D msgk            s              4  0
     D ord#            s              7  0
     D poseq#          s                   like(pidseq)
640bAD  rtnCode        s             10
640bAD  rtnMessage     s            200
     D sclear          s              1
     D temp4a          s              4
     D truck           s             10
     D x               s              2  0
730aAD i               s              3  0
730bAD $gfCmd          s              8
730bAD $gfFeature      s              1
730bAD $gfLight        s              1
730bAD $gfTBType       s              1
730bAD $gfWhse         s              3p 0

640bA*----------------------------------------------------------------
640bA*  Standard SQL variables and constants
640bA*----------------------------------------------------------------
640bA
640bA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     ** SUB PROCEDURE PROTOTYPES
     *----------------------------------------------------------------

730bAd GetPickSlot     pr            12

640bA*----------------------------------------------------------------
640bA* Function prototypes.
640bA*----------------------------------------------------------------

640bAD dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
     D   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

640bAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

730bA /copy qcopysrc,p.getfeat

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
404 A*      $PTYPE  ' ' - Normal
404 A*              'W' - Will call
405 A*      $PXDK   'Y' - Yes
405 A*              'N' - No
640bD**     $PFTP   'Y' - Yes
640bD**             'N' - No
640bM*      $PFTP   'F' - FTP
640bM*              'S' - Staging
640aA*      $PBPCK  'Y' - Yes
640aA*              'N' - No
640dA*      $PPPCK  'Y' - Yes
640dA*              'N' - No
700aA*      $PAPCK  'Y' - Yes
700aA*              'N' - No
700aA*      $PACOD  AMP Staging area code
     *      $PYN    Yes/No options.
730aA*      $PWHSEA Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
404 AC                   parm                    $ptype            1
405 AC                   parm                    $pxdk             1
416 AC                   parm                    $pftp             1
640aAC                   parm                    $pbpck            1
640dAC                   parm                    $pppck            1
700aAC                   parm                    $papck            1
700aAC                   parm                    $pacod            3
     C                   parm                    $pyn
730aAC                   parm                    $pwhsea           3
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
730aA*  Now use sent warehouse
     *
730aDC**                 eval      kywhse = 900
      /free
730aM    kywhse = %dec($pwhsea: 3: 0);
730aA    if kywhse < 900;
730aA      dsply 'Whse must be 900+';
730aA      return;
730aA     endif;
      /end-free
730bA*
730bA*  Get Feature code
730bA*
730bA /free
730bA      $gfWhse = kywhse;
730bA      GetFeat ('*GET': $gfwhse: $gfFeature: $gfLight: $gfTBType);
730bA /end-free
405 A*
405 A*  For cross dock, initialize P.O.
405 A*
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      delpo
405 AC                   exsr      crtpih
405 AC                   clear                   oidrec
405 AC                   eval      pidwhs = pihwhs
405 AC                   eval      pidpo = pihpo
405 AC                   endif
640bA*
640bA*  Get batch id to use with Staging files
640bA*
640bAC                   if        $pftp = 'S'
640bAC                   exsr      GetBatchId
640bAC                   endif
     *
     *  Create selected tests.
     *
     C     1             do        20            x
     C                   if        test(x) = 'Y'
     C                   if        $pjtyp = *on
     C                   eval      w1test = x
     C                   write     screen1
     C                   endif
     C     x             caseq     1             test1
     C     x             caseq     2             test2
     C     x             caseq     3             test3
     C     x             caseq     4             test4
     C     x             caseq     5             test5
     C     x             caseq     6             test6
     C     x             caseq     7             test7
     C     x             caseq     8             test8
     C     x             caseq     9             test9
     C     x             caseq     10            test10
     C     x             caseq     11            test11
     C     x             caseq     12            test12
     C     x             caseq     13            test13
     C     x             caseq     14            test14
     C     x             caseq     15            test15
     C     x             caseq     16            test16
     C     x             caseq     17            test17
     C     x             caseq     18            test18
     C     x             caseq     19            test19
     C     x             caseq     20            test20
     C                   endcs
     C                   endif
     C                   enddo
640bA*
640bA*  For staging files, immediatly do import
640bA*
640bAC                   if        $pftp = 'S'
640bAC                   exsr      DoImport
640bAC                   endif
     *
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
405 AC                   eval      poseq# = 0
     *
     *   Define keys
     *
     C                   eval      kytype = *blanks
     C     keyoih        klist
     C                   kfld                    kywhse
     C                   kfld                    kytype
     C                   kfld                    kyrte
     *
     C     keyoid        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
     *
405 AC     keypih        klist
405 AC                   kfld                    kywhse
405 AC                   kfld                    kypo
     *
405 AC     keypid        klist
405 AC                   kfld                    pihwhs
405 AC                   kfld                    pihpo
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck215fm
     C                   endif
416 A*
416 A*   Open import files.
416 A*
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bMC                   when      $pftp = 'F'
640aMC                   open      impfordh4
700aAC                   open      impfordhm
640aMC                   open      impfordd4
640aAC                   open      impforddm
640bDC**                 else
640bMC                   when      $pftp = 'X'
416 AC                   open      impordh1
416 AC                   open      impordd
416 AC                   endsl
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
     C                   read      pck215fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTOIH  Create import order header record.
     *
     C     crtoih        begsr
     *
     *   Create IMPORDH record.
     *
     C                   clear                   oihrec
700aAC                   clear                   ohmrec
     C                   eval      oihwhs = kywhse
700aAC                   eval      ohmwhs = oihwhs
710aDC*                  eval      oihord = x * 10
710aMC                   eval      oihord = (x * 10) + ord#
710ADC*                  add       ord#          oihord
700aAC                   eval      ohmord = oihord
404 D*                    MOVE *BLANKS   OIHTYP
404 MC                   eval      oihtyp = $ptype
710aDC*                  eval      oihcus = 1000 + x
710aMC                   eval      oihcus = 1000 + oihord
     C                   move      oihcus        temp4a
     C                   eval      oihcpo = %trimr('PO') + temp4a
710aDC*                  eval      oihcnm = cname(x)
710aMC                   eval      oihcnm = %trimr(cname(x)) + %char(ord#)
     C                   eval      oihca1 = cadr1(x)
     C                   eval      oihca2 = *blanks
     C                   eval      oihcct = %trimr('Test') + ' ' + 'City'
     C                   eval      oihcst = 'IL'
     C                   eval      oihczp = %trimr('9') + temp4a
     C                   eval      oihrte = kyrte
710aDC*                  eval      oihstp = 1
720aDC*                  eval      oihstp = ord#
720aMC                   eval      oihstp = ord# * 10
640cAC                   eval      oihest = oihstp + 100
     C                   eval      oihtrk = truck
     C                   eval      oihmsc = misc(x)
640dAC                   if        $pppck = 'Y'
640dAC                   eval      %subst(oihmsc: 17: 1) = 'Y'
640dAC                   endif
700aAC                   if        $papck = 'Y'
700aAC                   eval      %subst(ohmms4: 13: 1) = 'Y'
700aAC                   eval      %subst(ohmms4: 14: 3) = $pacod
700aAC                   endif
     *
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bMC                   when      $pftp = 'F'
416 AC                   write     oihrecf                              78
700aAC                   if        $papck = 'Y'
700aAC                   write     ohmrec                               78
700aAC                   endif
640bAC                   when      $pftp = 'S'
640bAC                   exsr      WriteOIHREC
640bDC**                 else
640bMC                   when      $pftp = 'X'
     C                   write     oihrec                               78
416 AC                   endsl
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  CRTOIM  Create import order detail misc record
640aA*----------------------------------------------------------------
640aA
640aAC     crtoim        begsr

640bAC                   if        $pbpck <> 'Y'
     C                   leavesr
     C                   endif

     C                   clear                   oimrecf
     C                   eval      oimwhs = oidwhs
     C                   eval      oimord = oidord
     C                   eval      oimseq = oidseq
     C                   eval      oimitm = oiditm
     C                   eval      oimms1 = 'Y'

710bDC**                 if        $pftp <> 'F'
710bAC                   if        $pftp = 'F'
     C                   write     oimrecf                              78
640bAC                   endif

     C                   endsr

405 A*----------------------------------------------------------------
405 A*
405 A*  CRTPID  Create import P.O. detail record.
405 A*
405 AC     crtpid        begsr
405 A*
405 A*   Create IMPPOD record.
405 A*
405 AC                   add       1             poseq#
405 AC                   eval      pidseq = poseq#
405 AC                   eval      piditm = oiditm
405 AC                   eval      pidqo1 = oidq1
405 AC                   write     pidrec                               78
405 A*
405 AC                   endsr
405 A*----------------------------------------------------------------
405 A*
405 A*  CRTPIH  Create import P.O. header record.
405 A*
405 AC     crtpih        begsr
405 A*
405 A*   Create IMPPOH record.
405 A*
405 AC                   clear                   pihrec
405 AC                   eval      pihwhs = kywhse
405 AC                   eval      pihpo = 'XDOCK'
405 AC                   eval      pihven = 1
405 AC                   eval      pihvna = vname(1)
405 AC                   eval      pihva1 = vadr1(1)
405 AC                   eval      pihva2 = *blanks
405 AC                   eval      pihvct = %trimr('Test') + ' ' + 'City'
405 AC                   eval      pihvst = 'IL'
405 AC                   eval      pihvzp = '99999'
405 A*
405 AC                   write     pihrec                               78
405 A*
405 AC                   endsr
405 A*----------------------------------------------------------------
405 A*
405 A*  DELPO   Delete existing PO import records.
405 A*
405 AC     delpo         begsr
405 A*
405 A*   Delete IMPPOH records.
405 A*
405 AC                   eval      kypo = 'XDOCK'
405 AC     keypih        setll     imppoh
405 AC                   dow       forevr = forevr
405 AC     keypih        reade     imppoh                                 78
405 AC                   if        *in78
405 AC                   leave
405 AC                   endif
405 A*
405 A*      Delete IMPPOD records.
405 A*
405 AC     keypid        setll     imppod
405 AC                   dou       forevr <> forevr
405 AC     keypid        reade     imppod                                 77
405 AC                   if        *in77
405 AC                   leave
405 AC                   endif
405 AC                   delete    pidrec
405 AC                   enddo
405 A*
405 AC                   delete    pihrec
405 AC                   enddo
405 A*
405 AC                   endsr
     *----------------------------------------------------------------
     *
     *  DELREC  Delete existing import records.
     *
     C     delrec        begsr
416 A*
416 A*   Skip for FTP.
416 A*
640bDC**   $pftp         cabeq     'Y'           enddel
640bMC     $pftp         cabne     'X'           enddel
     *
     *   Delete IMPORDH records.
     *
     C     keyoih        setll     impordh1
     C                   dou       forevr <> forevr
     C     keyoih        reade     impordh1                               78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *      Delete IMPORDD records.
     *
     C     keyoid        setll     impordd
     C                   dou       forevr <> forevr
     C     keyoid        reade     impordd                                77
     C                   if        *in77
     C                   leave
     C                   endif
     C                   delete    oidrec
     C                   enddo
     *
     C                   delete    oihrec
     C                   enddo
     *
416 MC     enddel        endsr

640bA*----------------------------------------------------------------
640bA*  DoImport     Call DktImport
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr DoImport;

730aD    //DktImport(900: 'IMPROUTE': batId: 'I':
730aM    DktImport(kywhse: 'IMPROUTE': batId: 'I':
                   'PCK215': rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  GetBatchId   Get batch id
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr GetBatchId;

730aD    //GetBatId(900: 'IMPROUTE': 'R':
730aM    GetBatId(kywhse: 'IMPROUTE': 'R':
                  batId: rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  TEST1   Create order for test 1.
     *
     *    Route: RTE01   Order: 1   Item: DA101 (10)
     *
     *    This is a very simple test with one route, one order and one item.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      A single truck pallet. No merging, no bulk picks, no letdowns.
     *
     C     test1         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE01'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C*****              eval      truck = 'TRUCK1'
     C                   eval      truck = ''
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA101'
     C                   eval      oidq1 = 10
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bMC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST2   Create order for test 2.
     *
     *    Route: RTE02   Order: 2   Item: DA101 (10)
     *                                    DP101 (5)
     *
     *    This is a very simple test with one route, one order and two items.
     *    One item is from the DRY/Fixed and the other from DRY/Pir.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      One truck pallet. One merge pallet.
     *      No bulk picks, no letdowns.
     *
     C     test2         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE02'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record 1.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA101'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DP101'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST3   Create order for test 3.
     *
     *    Route: RTE03   Order: 3   Item: DA102 (10)
     *                                    FA102 (10)
     *
     *    This is a very simple test with one route, one order and two items.
     *    One item is from the DRY department and the other from FRZ.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      Two truck pallets. One for compartment 'D' and one for 'F'.
     *      No merging, no bulk picks, no letdowns.
     *
     C     test3         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE03'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record 1.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA102'
     C                   eval      oidq1 = 10
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'FA102'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST4   Create order for test 4.
     *
     *    Route: RTE04   Order: 4   Item: DA102 (10)
     *                                    DP102 (5)
     *                                    FA102 (10)
     *                                    FP102 (5)
     *
     *    This is a very simple test with one route, one order and four items.
     *    The items are from DRY/Fixed, DRY/Pir, FRZ/Fixed and FRZ/Pir.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      Two truck pallets. One for compartment 'D' and one for 'F'.
     *      Two merge pallets.
     *      No bulk picks, no letdowns.
     *
     C     test4         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE04'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA102'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DP102'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 3
     C                   eval      oiditm = 'FA102'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 4
     C                   eval      oiditm = 'FP102'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST5   Create order for test 5.
     *
     *    Route: RTE05   Order: 5   Item: DP103 (15)
     *
     *    This is a very simple test with one route, one order and one item.
     *    Thie item is from DRY/Pir.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      One truck pallet. One merge pallet.
     *      No bulk picks, no letdowns.
     *
     C     test5         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE05'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DP103'
     C                   eval      oidq1 = 15
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST6   Create order for test 6.
     *
     *    Route: RTE06   Order: 6   Item: DA103 (50)
     *                                    DB103 (10)
     *
     *    This is a very simple test with one route, one order and two items.
     *    The items are from DRY/Fixed.
     *    One item is a full pallet bulk pick.
     *    The other item is a normal pick.
     *    This test could be used to test merging the two together.
     *
     *    Expected result:
     *
     *      Two truck pallets. One bulk pick pallet.
     *      No letdowns.
     *
     C     test6         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE06'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA103'
     C                   eval      oidq1 = 50
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DB103'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST7   Create order for test 7.
     *
     *    Route: RTE07   Order: 71  Item: DA101 (1.1) Normal
     *                                    DA102 (1)   Catchweight
     *                                    DA103 (5)   Combo
     *                                    DA104 (10)  Bulk
     *                                    DB101 (1)   Tote
     *                                    DB104 (1)   Tote
     *                                    DB103 (1)   Batch
     *                                    RA101 (1)
     *                                    FA101 (1)
     *
     *                   Order: 72  Item: DA101 (1)
     *                                    DB103 (1)   Batch
     *                                    RA101 (1)
     *                                    FA101 (1)
     *
     *
     *    This is a simple Trax route test
     *    This includes the different types of picks.
     *
     *    Expected result:
     *
     *      A Dry/Ref/Frz pallet with multiple stops
     *      A Combo pick
     *      A Bulk pick
     *      A Batch pick
     *      A Tote pick
     *
     C     test7         begsr
      /FREE

       // Delete existing orders for this test.

       kyrte = 'RTE07';
       exsr delrec;

       // Create first order

         // Create header

         truck = 'TRAX1';
         ord# = 1;
         exsr crtoih;

         // Create detail

         clear oidrec;
         oidwhs = oihwhs;
         oidord = oihord;
         if $pxdk = 'Y';
           oidspc = 'XD';
           oidpo = pihpo;
         endif;

         oidseq = 1;
         oiditm = 'DA101';
         oidq1 = 1;
         oidq2 = 1;
         exsr WriteRec;

         oidseq = 2;
         oiditm = 'DA102';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 3;
         oiditm = 'DA103';
         oidq1 = 5;
         exsr WriteRec;

         oidseq = 4;
         oiditm = 'DA104';
         oidq1 = 10;
         exsr WriteRec;

         oidseq = 5;
         oiditm = 'DB101';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 6;
         oiditm = 'DB104';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 7;
         oiditm = 'DB103';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 8;
         oiditm = 'RA101';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 9;
         oiditm = 'FA101';
         oidq1 = 1;
         exsr WriteRec;

       // Create second order

         // Create header

         ord# = 2;
         exsr crtoih;

         // Create detail

         clear oidrec;
         oidwhs = oihwhs;
         oidord = oihord;
         if $pxdk = 'Y';
           oidspc = 'XD';
           oidpo = pihpo;
         endif;

         oidseq = 1;
         oiditm = 'DA101';
         oidq1 = 1;
         oidq2 = 1;
         exsr WriteRec;

         oidseq = 2;
         oiditm = 'DB103';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 3;
         oiditm = 'RA101';
         oidq1 = 1;
         exsr WriteRec;

         oidseq = 4;
         oiditm = 'FA101';
         oidq1 = 1;
         exsr WriteRec;

      /END-FREE

     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST8   Create order for test 8.
     *
     *    Route: RTE08   Order: 1   Item: DA105 (30)
     *                                    DB105 (20)
     *                   Order: 2   Item: DA106 (20)
     *                                    DB106 (30)
     *
     *    This is a very simple test with one route, two orders and four items.
     *    The items are from DRY/Fixed.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      Two truck pallets for compartment 'D'.
     *      First pallet should have items DA105 and DA106.
     *      Second pallet should have items DB105 and DB106.
     *      No bulk picks, no merge pallets, letdowns.
     *
     C     test8         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE08'
     C                   exsr      delrec
     *
     *   Create IMPORDH record for first order.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD records for first order.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA105'
     C                   eval      oidq1 = 30
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DB105'
     C                   eval      oidq1 = 20
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     *   Create IMPORDH record for second order.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 2
     C                   exsr      crtoih
     *
     *   Create IMPORDD records for first order.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA106'
     C                   eval      oidq1 = 20
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DB106'
     C                   eval      oidq1 = 30
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST9   Create order for test 8.
     *
     *    Route: RTE09   Order: 1   Item: DA107 (100)
     *
     *    This is a very simple test with one route, One orders and one item.
     *    The items is from DRY/Fixed and is a non-bulk pick item.
     *    The quantity picked is greater than one pallet.
     *
     *    Expected result:
     *
     *      Two truck pallets for compartment 'D'.
     *      No bulk picks, no merge pallets, letdowns.
     *
     C     test9         begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE09'
     C                   exsr      delrec
     *
     *   Create IMPORDH record for first order.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD records for first order.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
405 AC                   if        $pxdk = 'Y'
405 AC                   eval      oidspc = 'XD'
405 AC                   eval      oidpo = pihpo
405 AC                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DA107'
     C                   eval      oidq1 = 100
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
405 AC                   if        $pxdk = 'Y'
405 AC                   exsr      crtpid
405 AC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST10  Create order for test 10.
     *
411 A*    Route: RTE10   Order: 10  Item: DC101BA (5)
     *                                    DC102BC (5)
     *                                    DC103S  (5)
     *                                    DC104A (10)
     *                                    DC105C (10)
     *
     *    This is a very simple test with one route, one order and five items.
     *    The items consist of the new item types: Alias, Contract, SSB.
     *    The quantity picked is less than one pallet.
     *
     *    Expected result:
     *
     *      One truck pallet for compartment 'D'.
     *      No bulk picks.
     *      Brokencase letdown from DA101 to DC101B.
     *      Brokencase letdown from DA102 to DC102B.
     *      Internal breakdown for DC103.
     *
     C     test10        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE10'
     C                   exsr      delrec
     *
     *   Create IMPORDH record.
     *
     C                   eval      truck = 'TRUCK1'
     C                   eval      ord# = 1
     C                   exsr      crtoih
     *
     *   Create IMPORDD record.
     *
     C                   clear                   oidrec
     C                   eval      oidwhs = oihwhs
     C                   eval      oidord = oihord
     C                   if        $pxdk = 'Y'
     C                   eval      oidspc = 'XD'
     C                   eval      oidpo = pihpo
     C                   endif
     *
     C                   eval      oidseq = 1
     C                   eval      oiditm = 'DC101BA'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif
     *
     C                   eval      oidseq = 2
     C                   eval      oiditm = 'DC102BC'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif
     *
     C                   eval      oidseq = 3
     C                   eval      oiditm = 'DC103S'
     C                   eval      oidq1 = 5
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif
     *
     C                   eval      oidseq = 4
     C                   eval      oiditm = 'DC104A'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif
     *
     C                   eval      oidseq = 5
     C                   eval      oiditm = 'DC105C'
     C                   eval      oidq1 = 10
640bDC**                 if        $pftp = 'Y'
640bAC                   select
640bAC                   when      $pftp = 'F'
640aAC                   exsr      CrtOIM
416 AC                   write     oidrecf                              78
640bAC                   when      $pftp = 'S'
640aAC                   exsr      CrtOIM
640bAC                   exsr      WriteOIDREC
640bDC**                 else
640bAC                   when      $pftp = 'X'
     C                   write     oidrec                               78
416 AC                   endsl
     *
     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST11  Create order for test 11.
     *
     C     test11        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE11'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST12  Create order for test 12.
     *
     C     test12        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE12'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST13  Create order for test 13.
     *
     C     test13        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE13'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST14  Create order for test 14
     *
     C     test14        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE14'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST15  Create order for test 15.
     *
     C     test15        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE15'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST16  Create order for test 16.
     *
     C     test16        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE16'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST17  Create order for test 17.
     *
     C     test17        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE17'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST18  Create order for test 18.
     *
     C     test18        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE18'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST19  Create order for test 19.
     *
     C     test19        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE19'
     C                   exsr      delrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST20  Create order for test 20.
     *
     C     test20        begsr
     *
     *   Delete existing orders for this test.
     *
     C                   eval      kyrte = 'RTE20'
     C                   exsr      delrec
     *
     C                   endsr

640bA*----------------------------------------------------------------
640bA*  WriteOrdD    Write Order Detail record
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr WriteOIDREC;

         oidstatus = 'R';

730bA    // For Feature 3, fill in pick slot
730bA
730bA    if $gfFeature = '3';
730bA      oidslt = GetPickSlot;
730bA      oidblk = 'N';
730bA    endif;

         exec sql insert into impsordd
                  (oidwhs, oidbatid, oidordid,
                   oidstatus, oidststs, oidstsuc, oidtext,
                   oidord, oidseq, oiditm, oidq1, oidq2, oidq3,
                   oidwh2, oidor2, oidoit, oidspc, oidpo,
                   oimdsc, oimpds, oimrds, oimbox, oimexp,
                   oimms1, oimms2, oimms3, oimms4, oimms5,
730bA              oidslt, oidblk,
                   oidaddts, oidadduc)
                  values(:oidwhs, :batid, :oidordid, :oidstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oidtext, :oidord, :oidseq, :oiditm,
                         :oidq1, :oidq2, :oidq3,
                         :oidwh2, :oidor2, :oidoit, :oidspc, :oidpo, :oimdsc,
                         :oimpds, :oimrds, :oimbox, :oimexp, :oimms1, :oimms2,
                         :oimms3, :oimms4, :oimms5,
730bA                    :oidslt, :oidblk,
                         current_timestamp,
                         current_timestamp - current_timezone);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDD error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  WriteOrdH    Write Order Header record
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr WriteOIHREC;

         oihstatus = 'R';

         exec sql insert into impsordh
                  (oihwhs, oihbatid, oihrteid, oihordid,
                   oihstatus, oihststs, oihstsuc, oihtext,
                   oihord, oihtyp, oihcus, oihcpo, oihcnm,
                   oihca1, oihca2, oihcct, oihcst, oihczp,
                   oihrte, oihstp, oihtrk, oihmsc, ohmms1,
                   ohmms2, ohmms3, ohmms4, ohmms5,
640cM              oihaddts, oihadduc, oihest)
                  values(:oihwhs, :batid, :oihrteid, :oihordid, :oihstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :oihtext, :oihord, :oihtyp, :oihcus, :oihcpo, :oihcnm,
                         :oihca1, :oihca2, :oihcct, :oihcst, :oihczp, :oihrte,
                         :oihstp, :oihtrk, :oihmsc, :ohmms1, :ohmms2, :ohmms3,
                         :ohmms4, :ohmms5,
                         current_timestamp,
640cM                    current_timestamp - current_timezone,
640cA                    :oihest);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'ORDH error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  WriteRec   Write import record
     *
     C     WriteRec      begsr

     C                   select

     C                   when      $pftp = 'F'
     C                   exsr      CrtOIM
     C                   write     oidrecf                              78

     C                   when      $pftp = 'S'
     C                   exsr      CrtOIM
     C                   exsr      WriteOIDREC

     C                   when      $pftp = 'X'
     C                   write     oidrec                               78

     C                   endsl

     C                   if        $pxdk = 'Y'
     C                   exsr      crtpid
     C                   endif

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

     *---------------------------------------------------------------
     *  Sub Procedures
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     ** GetPickSlot
     *---------------------------------------------------------------
     *
     p GetPickSlot     b
     d GetPickSlot     pi            12
     *
     * Local Variables
     *
     d pWhse           s              3  0
     d pUser           s             10
     d pSlot           s             12
     d
     c                   call      'GETPCKSLT'
     c                   parm      kywhse        pwhse
     C                   parm                    oiditm
     c                   parm      ''            pUser
     c                   parm      ''            pSlot

     c                   return    pSlot
     P                 e

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  CNAME
Test Customer 1
Test Customer 2
Test Customer 3
Test Customer 4
Test Customer 5
Test Customer 6
Test Customer 7
Test Customer 8
Test Customer 9
Test Customer 10
Test Customer 11
Test Customer 12
Test Customer 13
Test Customer 14
Test Customer 15
Test Customer 16
Test Customer 17
Test Customer 18
Test Customer 19
Test Customer 20
**  CADR1
101 Mulberry Street
102 Mulberry Street
103 Mulberry Street
104 Mulberry Street
105 Mulberry Street
106 Mulberry Street
107 Mulberry Street
108 Mulberry Street
109 Mulberry Street
110 Mulberry Street
111 Mulberry Street
112 Mulberry Street
113 Mulberry Street
114 Mulberry Street
115 Mulberry Street
116 Mulberry Street
117 Mulberry Street
118 Mulberry Street
118 Mulberry Street
120 Mulberry Street
**  MISC
Order for Test 1
Order for Test 2
Order for Test 3
Order for Test 4
Order for Test 5
Order for Test 6
Order for Test 7
Order for Test 8
Order for Test 9
Order for Test 10
Order for Test 11
Order for Test 12
Order for Test 13
Order for Test 14
Order for Test 15
Order for Test 16
Order for Test 17
Order for Test 18
Order for Test 19
Order for Test 20
**  VNAME
Test Vendor 1
**  VADR1
101 Sellers Lane
