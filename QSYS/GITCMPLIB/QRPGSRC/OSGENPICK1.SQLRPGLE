      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSGENPICK  OPS *GENPICK Upd - Pgm for SQL procedure of same name
     *  12 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    08/12/12  DAS  6.40
     *      - Created.
     *
650aA*    02/05/14  DAS  6.50a
     *      - Added call to WRTSESSLOG
     *
650bA*    03/07/14  DAS  6.50b
     *      - Added pSessId, pUser, pPgm.
     *
700aA*    07/20/15  LMC  7.00a
     *      - Added pmta, pmaxa, pdock.
     *      - Edits for pmaxa & pdock.
     *
710aA*    01/23/17  LMC  7.10a
     *      - Added prfqt, prfqto, prfcs, prfpm & prplt
     *
720aA*    05/30/18  LMC  7.20a
     *      - Added prfui
     *
720bA*    07/16/18  LMC  7.20b
     *      - Added prfzp & prfuw
     *
730aA*    05/20/19  KDE  7.30a
     *      - Added ppseq
     *      - Changed to use Generic Procedure call
     *
730bA*    09/03/19  KDE  7.30b
     *      - Defauly Slot Pick Sequence to "P" Slot Pick Sequence
     *
740aA*    03/25/20  LMC  7.40a
     *      - Added prvup, prvsl, prvcd
     *
740bA*    05/27/20  KDE  7.40b
     *      - Added pcad
     *
740cA*    08/17/20  KDE  7.40c
     *      - Added OPPMSC, OPPSVH, OPPSVM, OPPSVL, OPPISSV, OPPISSP,
     *        OPPMSSV, OPPMSSP, OPPFDB
     *      - Add message to force pallet position when *SP is merged
     *        with other stops
     *
740dA*    10/01/20  RBD  7.40d
     *      - Added opbarc.
750aA*    06/03/21  LMC  7.50a
     *      - Added SelectPrime© options
     *      - OPRFQTCW,OPRFQTAS,OPRFSSSV,OPSPPS,OPSPATRN
     *        OPSPPLBL,OPSPBTXT,OPSPPSH,OPSPPSS
     *
750bA*    06/14/21  RBD  7.50b
     *      - Added opauts.
     *
750cA*    06/18/21  LMC  7.50c
     *      - Added opsppba
750dA*    01/14/22  LMC  7.50d
     *      - Added opspjp
750eA*    03/07/22  LMC  7.50e
     *      - Added new options for SelectPrime
     *      - OPSPSSN-  SelectPrime - Same Slot/More Qty visual Notif ication
     *      - OPSPPLDL-  SelectPrime - remove items from pick list as
     *                   they are picked.
750fA*    03/10/22  LMC  7.50f
     *      - Added new options for SelectPrime
     *      - OPAUTOT-  SelectPrime - Auto Assign Truck during order         &
     *                  Import.                                              &
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*GENPICK')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650bAD  pSessId        s             40
650bAD  pUser          s             10
730aAD  pDict          s             10
650bAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  perpt          s              1
     D  pelbl          s              1
     D  prfwc          s              1
     D  pnrsc          s              1  0
     D  phpwc          s              1
     D  pmrga          s              1
     D  pplsq          s              1
     D  peadj          s              1
     D  pnopk          s              1
     D  pgpk1          s              1
     D  pgpk2          s              1
     D  pjitr          s              1
     D  ppset          s              1
     D  prfuc          s              1
     D  prflc          s              1
     D  pusf1          s              1
     D  prfsl          s              1
     D  prbn1          s              1
     D  prbn2          s              1
     D  psubt          s              1
700aAD  pmta           s              1
700aAD  pmaxa          s              2  0
700aAD  pdock          s              1
710aAD  prfqt          s              1
710aAD  prfqto         s              3  0
710aAD  prfcs          s              1
710aAD  prfpm          s              1
710aAD  prplt          s              1
720aAD  prfui          s              1
730aAD  ppmta          s              1
720bAD  prfzp          s              1
720bAD  prfuw          s              1
730aAD  ppseq          s              1
740aAD  prvup          s              1  0
740aAD  prvsl          s              1  0
740aAD  prvcd          s              1  0
740bAD  pcad           s              2  0
740cAD  ppmsc          s              2  0
740cAD  ppsvh          s              1
740cAD  ppsvm          s              1
740cAD  ppsvl          s              1
740cAD  ppissv         s              5  0
740cAD  ppissp         s              3  0
740cAD  ppmssv         s              5  0
740cAD  ppmssp         s              3  0
740cAD  ppfdb          s              1
740dAD  ppbarc         s              1
750aAD  poprfqtcw      s              1
750aAD  poprfqtas      s              1
750aAD  poprfsssv      s              1
750aAd  popspps        s              1
750aAd  popspatrn      s              1
750aAD  popspplbl      s              1
750aAD  popspbtxt      s             30
750aAd  popsppsh       s              1
750aAd  popsppss       s              1
750bAd  popauts        s              1
750cAd  popsppba       s              1
750dAD  popspjp        s              5
750eAD  popspssn       s              1
750eAD  popsppldl      s              1
750fAD  popautot       s              1
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

730aAd dpCombo         s             20
650bAD logText         s            100
730aAD pparmStr1       s            999
730aAD pparmStr2       s            999
730aAD pparmStr3       s            999

700aAD client          s             10
700aAD clientloc       s             10

730aA*----------------------------------------------------------------
730aA*  Translation strings
730aA*----------------------------------------------------------------

730aAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
730aAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

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

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *GENPICK -  General picking.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N).
410BA*    OPRFWC  -  Using RF will call (Y,N).
413aA*    OPNRSC  -  Number of pallet sections (1-9).
414aA*    OPHPWC  -  Host pick Will Call (Y/N).
416 A*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
416aA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
416bA*    OPEADJ  -  Close short labels without adjustment (Y,N).
417 A*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500cM*    OPGPK1  -  <Not Used / Available>
500cM*    OPGPK2  -  <Not Used / Available>
417cA*               task has been assigned. (Y/N)
500bM*    OPJITR  -  Create JIT Letdown or JIT Replenishment
500bM*                 0=None. No replenishments are created.
500bA*                 1=Letdowns are created during Truck Builder
500bA*                   Pick/Print processing.
500bA*                 2=Priority Replenishments are created during
500bA*                   Truck Builder Pick/Print processing.
500bA*                 3=JIT Letdowns created when transaction is
500bA*                   checked out.
500bA*                 4=JIT Priority Replenishments created when
500bA*                   transaction is checked out.
500dA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
500eA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
500eA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
710aM*    OPRFSL  -  RF Pick Verify slot
710aA*               Y=Yes
710aA*               N=No
710aA*               C=Scan Check Digit
710aA*               E=Enter to Continue
640aA*    OPRBN1  -  Round robin printing compatable (Y/N)
640aA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640aA*               1=Off
640aA*               2=By route
640aA*               3=By transaction
640aA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
700aA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
700aA*    OPMAXA  -  USF Option: Staged route selection limit.
700aA*    OPDOCK  -  USF Option: Dock door prompt choice.
710aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y/N)
710aA*    OPRFQTO -     With Quantity Over (if RF Pick Allow Qty Entry = Y)
710aA*    OPRFCS  -  RF Pick Allow Change Slot (Y/N)
710aA*    OPRFPM  -  RF Pick Method
710aA*               1=Manual
710aA*               2=Directed
710aA*    OPRPLT  -  Print Pallet Label
710aA*               1=Normal
710aA*               2=Big
710aA*               3=Both
710aA*               4=No
720aA*    OPRFUI  -  Scan individual UPC for each unit.
720bA*    OPRFZP  -  Zone Pick Method
720bA*    OPRFUW  -  Auto load weights from upc scan.
730aA*    OPPSEQ  -  Slot Pick Sequence
740aA*    OPRVUP  -  RF Location UPC Verification
740aA*    OPRVSL  -  RF Location Slot Verification
740aA*    OPRVCD  -  RF Location Verification
740bA*    OPCAD   -  Customer Audit Duration (New Customer)
740cA*    OPPMSC  -  Allow merging with other Stops when cube less than this value
740cA*    OPPSVH  -    When above true allow stop as highest on pallet
740cA*    OPPSVM  -    When above true allow stop as middle on pallet
740cA*    OPPSVL  -    When above true allow stop as lowest on pallet
740cA*    OPPISSV -  Ideal trailer side-to-side weight difference
740cA*    OPPISSP -  Ideal trailer side-to-side percent difference
740cA*    OPPMSSV -  Max trailer side-to-side weight difference
740cA*    OPPMSSP -  Max trailver side-to-side percent difference
740cA*    OPPFDB  -  Allow Freezer pallet at rear door
740dA*    OPBARC  -  Print tran and label barcodes
750aA*    OPRFQTCW-  SelectPrime - allow Qty entry on cw items.
750aA*    OPRFQTAS-  SelectPrime - assume short from qty entry.
750aA*    OPRFSSSV-  SelectPrime - Same Slot skip Loc verification
750aA*    OPSPPS  -  SelectPrime - Auto display pallet Summary-82
750aA*    OPSPATRN-  SelectPrime - Auto assign transactions
750aA*    OPSPPLBL-  SelectPrime - Print pallet label on Belt Printer
750aA*    OPSPBTXT-  SelectPrime - Next Item breakdown warning text
750aA*    OPSPPSH -  SelectPrime - Print SetHed Label
750aA*    OPSPPSS -  SelectPrime - Print SetSum Label
750bA*    OPAUTS  -  Allow auto substitutions (Y/N)
750cA*    OPSPPBA -  SelectPrime - Print labels before or after pick(B/A)
750dA*    OPSPJP  -  SelectPrime - Pallet jack prefix
750eA*    OPSPSSN -  SelectPrime - Same Slot/More Qty visual Notification
750eA*    OPSPPLDL-  SelectPrime - remove items from pick list as
     *               they are picked.
750fA*    OPAUTOT -  Auto Assign Truck during order import.
     *
     * Data structure
     *
     D optionRec       ds
     D  operpt                 1      1
     D  opelbl                 2      2
410BAD  oprfwc                 3      3
413aAD  opnrsc                 4      4  0
414aAD  ophpwc                 5      5
416 AD  opmrga                 6      6
416aAD  opplsq                 7      7
416aAD  opeadj                 8      8
417 AD  opnopk                 9      9
500cMD  opgpk1                10     10
500cMD  opgpk2                11     11
417dAD  opjitr                12     12
500dAD  oppset                13     13
500eAD  oprfuc                14     14
500eAD  oprflc                15     15
510hAD  opusf1                16     16
520aAD  oprfsl                17     17
640aAD  oprbn1                18     18
640aAD  oprbn2                19     19
640aAD  opsubt                20     20
710aAD  oprfqt                21     21
710aAD  oprfcs                22     22
700aAD  oppmta                23     23
700aAD  opmaxa                24     25  0
700aAD  opdock                26     26
710aMD  oprfqto               27     29  0
710aAD  oprfpm                30     30
710dAD  oprplt                31     31
720aAD  oprfui                32     32
720bAD  oprfzp                33     33
720bAD  oprfuw                34     34
730aAD  oppseq                35     35
740aAD  oprvup                36     36  0
740aAD  oprvsl                37     37  0
740aAD  oprvcd                38     38  0
740abD  opcad                 39     40  0
740acD  oppmsc                41     42  0
740acD  oppsvh                43     43
740acD  oppsvm                44     44
740acD  oppsvl                45     45
740acD  oppissv               46     50  0
740acD  oppissp               51     53  0
740acD  oppmssv               54     58  0
740acD  oppmssp               59     61  0
740acD  oppfdb                62     62
740dAD  opbarc                63     63
750aAD  oprfqtcw              64     64
750aAD  oprfqtas              65     65
750aAD  oprfsssv              66     66
750aAD  opspps                67     67
750aAD  opspatrn              68     68
750aAD  opspplbl              69     69
750aAD  opspbtxt              70     99
750aAD  opsppsh              100    100
750aAD  opsppss              101    101
750bAD  opauts               102    102
750cAD  opsppba              103    103
750dAD  opspjp               104    108
750eAD  opspssn              109    109
750eAD  opsppldl             110    110
750fAD  opautot              111    111
     D  optend               117    117

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl
700aA /copy qcopysrc,p.getclien

700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*----------------------------------------------------------------
700aA /copy qcopysrc,id#usfcrp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessId     Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pobjLoc     MRC Object Location
     *      pparmStr1   Parm String 1
     *      pparmStr2   Parm String 2
     *      pparmStr3   Parm String 3
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650bA*      pSessId     Session Id
650bA*      pUser       GUI User
650bA*      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONS data field
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

730aAC     *entry        plist
730aAC                   parm                    pMessage
730aAC                   parm                    pSessId
730aAC                   parm                    pUser
730aAC                   parm                    pDict
730aAC                   parm                    pPgm
730aAC                   parm                    pObjLoc
730aAC                   parm                    pparmStr1
730aAC                   parm                    pparmStr2
730aAC                   parm                    pparmStr3
730aDC*    *entry        plist
730aDC*                  parm                    pMessage
730aDC*                  parm                    pSessId
730aDC*                  parm                    pUser
730aDC*                  parm                    pPgm
730aDC*                  parm                    pObjLoc
730aDC*                  parm                    pSubCmd
730aDC*                  parm                    pData
730aDC*                  parm                    pWhse
730aDc*                  parm                    perpt
730aDc*                  parm                    pelbl
730aDc*                  parm                    prfwc
730aDc*                  parm                    pnrsc
730aDc*                  parm                    phpwc
730aDc*                  parm                    pmrga
730aDc*                  parm                    pplsq
730aDc*                  parm                    peadj
730aDc*                  parm                    pnopk
730aDc*                  parm                    pgpk1
730aDc*                  parm                    pgpk2
730aDc*                  parm                    pjitr
730aDc*                  parm                    ppset
730aDc*                  parm                    prfuc
730aDc*                  parm                    prflc
730aDc*                  parm                    pusf1
730aDc*                  parm                    prfsl
730aDc*                  parm                    prbn1
730aDc*                  parm                    prbn2
730aDc*                  parm                    psubt
730aDc*                  parm                    pmta
730aDc*                  parm                    pmaxa
730aDc*                  parm                    pdock
730aDc*                  parm                    prfqt
730aDc*                  parm                    prfqto
730aDc*                  parm                    prfcs
730aDc*                  parm                    prfpm
730aDc*                  parm                    prplt
730aDc*                  parm                    prfui
730aDc*                  parm                    prfzp
730aDc*                  parm                    prfuw

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

730aA   // Combine dictionary/program
730aA
730aA   dpCombo = %trim(pDict) + '.' + pPgm;

650aA    // Write GLOSESSLOG record
650bA    logText = 'objloc:' + pObjLoc;
730aD    //wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
730aM    wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);

730aA   error = *off;

730aA   // Extract parameters from delimited string

730aA   ExtractParms();

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'BEFOREACT';
             exsr BeforeAct;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;
         opdata = optionRec;

         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  BeforeAct    Before action update
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr BeforeAct;

         optionRec = pData;
         exsr FillRec;
         pData = optionRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opcode = optionCode;
         opwhse = pWhse;

         operpt = perpt;
         opelbl = pelbl;
         oprfwc = prfwc;
         opnrsc = pnrsc;
         ophpwc = phpwc;
         opmrga = pmrga;
         opplsq = pplsq;
         opeadj = peadj;
         opnopk = pnopk;
         opgpk1 = pgpk1;
         opgpk2 = pgpk2;
         opjitr = pjitr;
         oppset = ppset;
         oprfuc = prfuc;
         oprflc = prflc;
         opusf1 = pusf1;
         oprfsl = prfsl;
         oprbn1 = prbn1;
         oprbn2 = prbn2;
         opsubt = psubt;
         oppmta = pmta;
         opmaxa = pmaxa;
         opdock = pdock;

         oprfqt = prfqt;
         oprfqto = prfqto;
         oprfcs = prfcs;
         oprfpm = prfpm;
         oprplt = prplt;
         oprfui = prfui;
         oprfzp = prfzp;
730aA    oprfuw = prfuw;

730aA    oppseq = ppseq;

740aA    oprvup = prvup;
740aA    oprvsl = prvsl;
740aA    oprvcd = prvcd;
740bA    opcad  = pcad;
740cA    opcad  = pcad;
740cA    oppmsc  = ppmsc;
740cA    oppsvh  = ppsvh;
740cA    oppsvm  = ppsvm;
740cA    oppsvl  = ppsvl;
740cA    oppissv  = ppissv;
740cA    oppissp  = ppissp;
740cA    oppmssv  = ppmssv;
740cA    oppmssp  = ppmssp;
740cA    oppfdb  = ppfdb;
740dA    opbarc  = ppbarc;

750aA    oprfqtcw = poprfqtcw;
750aA    oprfqtas = poprfqtas;
750aA    oprfsssv = poprfsssv;
750aA    opspps   = popspps;
750aA    opspatrn = popspatrn;
750aA    opspplbl = popspplbl;
750aA    opspbtxt = popspbtxt;
750aA    opsppsh  = popsppsh;
750aA    opsppss  = popsppss;
750cA    opsppba  = popsppba;
750dA    opspjp   = popspjp;
750eA    opspssn  = popspssn;
750eA    opsppldl = popsppldl;
750fA    opautot  = popautot;

750bA    opauts   = popauts;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;
700aA    if client = usfcrp;
700aA      if pmaxa < 1 or pmaxa > 10;
700aA        pMessage = 'Invalid Maximum # of Routes that can '
700aA                 + 'be staged together. Must be 1-10';
700aA        leavesr;
700aA      endif;
700aA      if pdock < '1' or pdock > '2';
700aA        pMessage = 'Invalid Dock Door Prompt choice '
700aA                 + '1=Staging or 2=Pick/Print';
700aA        leavesr;
700aA      endif;
700aA    endif;

         // confirm that Slot Pick Sequence is valid
         if ppseq<>'A' and ppseq<>'D' and ppseq<>'P';
700aA       pMessage = 'Invalid Slot Pick Sequence';
700aA       leavesr;
         endif;

740aA    // RF location verification priorities must be unique
740aA    if prvup > 0;
740aA      select;
740aA        when prvup = prvsl;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA        when prvup = prvcd;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA      endsl;
740aA    endif;
740aA    if prvsl > 0;
740aA      select;
740aA        when prvsl = prvup;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA        when prvsl = prvcd;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA      endsl;
740aA    endif;
740aA    if prvcd > 0;
740aA      select;
740aA        when prvcd = prvup;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA        when prvcd = prvsl;
740aA          pMessage = 'RF Location Verification must be unique';
740aA          leavesr;
740aA      endsl;
740aA    endif;
740aA    // priority 1-3
740aA    if prvcd > 3;
740aA      pMessage = 'Check Digit verification priority must be 1,2 or 3';
740aA      leavesr;
740aA    endif;
740aA    if prvsl > 3;
740aA      pMessage = 'Slot verification priority must be 1,2 or 3';
740aA      leavesr;
740aA    endif;
740aA    if prvup > 3;
740aA      pMessage = 'UPC verification priority must be 1,2 or 3';
740aA      leavesr;
740aA    endif;

740cA    // Truck Builder *SP Less than Cube option
740cA
740cA    if ppmsc<>0 and ppsvh<>'Y' and ppsvm<>'Y' and ppsvl<>'Y';
740cA      pmessage = 'When *SP merged w/oth pallets, must specify' +
740cA                  ' pallet position';
740cA      leavesr;
740cA    endif;
740cA
740cA    if ppmsc=0 and (ppsvh='Y' or ppsvm='Y' or ppsvl='Y');
740cA      pmessage = 'When *SP pallet position selected, must ' +
740cA                  ' specify cube';
740cA      leavesr;
740cA    endif;

740dA    // edit print barcode option
740dA    if ppbarc<>'1' and ppbarc<>'2' and ppbarc<>'3' and ppbarc<>'9';
740dA       pMessage = 'Invalid Print barcode option';
740dA       leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :oprec
                  from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;
         opdata = optionRec;

         exec sql update options
                  set opdata = :opdata
                  where opcode = :opcode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
700aA*----------------------------------------------------------------
700aA*  *INZSR   Initialization subroutine
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr *INZSR;

700aA    getclient(client: clientLoc);

700aA  endsr;

700aA /end-free

730aA*----------------------------------------------------------------
730aA*  ConvertField   Convert incoming field to DRI field
730aA*----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPERPT';
             perpt = %trim(parmValue);

           when parmName = 'OPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'OPELBL';
             pelbl =  parmValue;

           when parmName = 'OPRFWC';
             prfwc = %trim(parmValue);

           when parmName = 'OPNRSC';
             if parmValue = '';
               parmValue = '0';
             endif;
             pnrsc =  %dec(parmValue: 1: 0);

           when parmName = 'OPHPWC';
             phpwc = %trim(parmValue);

           when parmName = 'OPMRGA';
             pmrga = %trim(parmValue);

           when parmName = 'OPPLSQ';
             pplsq = %trim(parmValue);

           when parmName = 'OPEADJ';
             peadj = %trim(parmValue);

           when parmName = 'OPNOPK';
             pnopk = %trim(parmValue);

           when parmName = 'OPJITR';
             pjitr = %trim(parmValue);

           when parmName = 'OPPSET';
             ppset = %trim(parmValue);

           when parmName = 'OPRFUC';
             prfuc = %trim(parmValue);

           when parmName = 'OPRFLC';
             prflc = %trim(parmValue);

           when parmName = 'OPUSF1';
             pusf1 = %trim(parmValue);

           when parmName = 'OPRFSL';
             prfsl = %trim(parmValue);

           when parmName = 'OPRBN1';
             prbn1 = %trim(parmValue);

           when parmName = 'OPRBN2';
             prbn2 = %trim(parmValue);

           when parmName = 'OPSUBT';
             psubt = %trim(parmValue);

           when parmName = 'OPRFQT';
             prfqt = %trim(parmValue);

           when parmName = 'OPRFCS';
             prfcs = %trim(parmValue);

           when parmName = 'OPPMTA';
             ppmta = %trim(parmValue);

           when parmName = 'OPMAXA';
             if parmValue = '';
               parmValue = '0';
             endif;
             pmaxa =  %dec(parmValue: 2: 0);

           when parmName = 'OPDOCK';
             pdock = %trim(parmValue);

           when parmName = 'OPRFQTO';
             if parmValue = '';
               parmValue = '0';
             endif;
             prfqto =  %dec(parmValue: 3: 0);

           when parmName = 'OPRFPM';
             prfpm = %trim(parmValue);

           when parmName = 'OPRPLT';
             prplt = %trim(parmValue);

           when parmName = 'OPRFUI';
             prfui = %trim(parmValue);

           when parmName = 'OPRFZP';
             prfzp = %trim(parmValue);

           when parmName = 'OPRFUW';
             prfuw = %trim(parmValue);

           when parmName = 'OPPSEQ';
             ppseq = %trim(parmValue);
730bA        if ppseq=*blanks;
730bA           ppseq='P';
730bA        endif;

740aA      when parmName = 'OPRVUP';
740aA        if parmValue = '';
740aA          parmValue = '0';
740aA        endif;
740aA        prvup =  %dec(parmValue: 1: 0);

740aA      when parmName = 'OPRVSL';
740aA        if parmValue = '';
740aA          parmValue = '0';
740aA        endif;
740aA        prvsl =  %dec(parmValue: 1: 0);

740aA      when parmName = 'OPRVCD';
740aA        if parmValue = '';
740aA          parmValue = '0';
740aA        endif;
740aA        prvcd =  %dec(parmValue: 1: 0);

740bA      when parmName = 'OPCAD';
740bA        if parmValue = '';
740bA          parmValue = '0';
740bA        endif;
740bA        pcad =  %dec(parmValue: 2: 0);

740cA      when parmName = 'OPPMSC';
740cA        if parmValue = '';
740cA          parmValue = '0';
740cA        endif;
740cA        ppmsc =  %dec(parmValue: 2: 0);

740cA      when parmName = 'OPPSVH';
740cA        ppsvh = %trim(parmValue);

740cA      when parmName = 'OPPSVM';
740cA        ppsvm = %trim(parmValue);

740cA      when parmName = 'OPPSVL';
740cA        ppsvl = %trim(parmValue);

740cA      when parmName = 'OPPISSV';
740cA        if parmValue = '';
740cA          parmValue = '0';
740cA        endif;
740cA        ppissv =  %dec(parmValue: 5: 0);

740cA      when parmName = 'OPPISSP';
740cA        if parmValue = '';
740cA          parmValue = '0';
740cA        endif;
740cA        ppissp =  %dec(parmValue: 3: 0);

740cA      when parmName = 'OPPMSSV';
740cA        if parmValue = '';
740cA          parmValue = '0';
740cA        endif;
740cA        ppmssv =  %dec(parmValue: 5: 0);

740cA      when parmName = 'OPPMSSP';
740cA        if parmValue = '';
740cA          parmValue = '0';
740cA        endif;
740cA        ppmssp =  %dec(parmValue: 3: 0);

740cA      when parmName = 'OPPFDB';
740cA        ppfdb = %trim(parmValue);

740dA      when parmName = 'OPBARC';
740dA        ppbarc = %trim(parmValue);

750aA      when parmName = 'OPRFQTCW';
750aA        pOPRFQTCW = %trim(parmValue);

750aA      when parmName = 'OPRFQTAS';
750aA        pOPRFQTAS = %trim(parmValue);

750aA      when parmName = 'OPRFSSSV';
750aA        pOPRFSSSV = %trim(parmValue);

750aA      when parmName = 'OPSPPS';
750aA        pOPSPPS = %trim(parmValue);

750aA      when parmName = 'OPSPATRN';
750aA        pOPSPATRN = %trim(parmValue);

750aA      when parmName = 'OPSPPLBL';
750aA        pOPSPPLBL = %trim(parmValue);

750aA      when parmName = 'OPSPBTXT';
750aA        pOPSPBTXT = %trim(parmValue);

750aA      when parmName = 'OPSPPSH';
750aA        pOPSPPSH = %trim(parmValue);

750aA      when parmName = 'OPSPPSS';
750aA        pOPSPPSS = %trim(parmValue);

750cA      when parmName = 'OPSPPBA';
750cA        pOPSPPBA = %trim(parmValue);

750dA      when parmName = 'OPSPJP';
750dA        pOPSPJP = %xlate(xlower: xupper: parmValue);

750bA      when parmName = 'OPAUTS';
750bA        pOPAUTS = %trim(parmValue);

750eA      when parmName = 'OPSPSSN';
750eA        pOPSPSSN = %trim(parmValue);

750eA      when parmName = 'OPSPPLDL';
750eA        pOPSPPLDL = %trim(parmValue);

750fA      when parmName = 'OPAUTOT';
750fA        pOPAUTOT  = %trim(parmValue);

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
                  + %char(parmCount) + ' '
                  + parmName + ' '
                  + '(' + parmValue + ')'
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';

       endmon;

       return;

      /end-free

     p                 e

730aA*----------------------------------------------------------------
730aA*  ExtractParms   Extract parms from parameter string
730aA*----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

730aA*----------------------------------------------------------------
730aA*  ExtractParmStr   Extract parms from single parameter string
730aA*----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
                    + %char(parmCount) + ' '
                    + '(' + parmGroup + ')'
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
