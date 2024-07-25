      /copy *libl/qcopysrc,hspecs
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
650bAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D* perpt          s              1
     D  pelbl          s              1
     D* prfwc          s              1
     D* pnrsc          s              1  0
     D* phpwc          s              1
     D* pmrga          s              1
     D* pplsq          s              1
     D* peadj          s              1
     D* pnopk          s              1
     D* pgpk1          s              1
     D* pgpk2          s              1
     D* pjitr          s              1
     D* ppset          s              1
     D* prfuc          s              1
     D* prflc          s              1
     D* pusf1          s              1
     D* prfsl          s              1
     D* prbn1          s              1
     D* prbn2          s              1
     D* psubt          s              1
700aAD* pmta           s              1
700aAD* pmaxa          s              2  0
700aAD* pdock          s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650bAD logText         s            100

700aAD client          s             10
700aAD clientloc       s             10
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
610aA*    OPRFSL  -  RF Pick Verify slot (Y/N)
640aA*    OPRBN1  -  Round robin printing compatable (Y/N)
640aA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640aA*               1=Off
640aA*               2=By route
640aA*               3=By transaction
640aA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
700aA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
700aA*    OPMAXA  -  USF Option: Staged route selection limit.
700aA*    OPDOCK  -  USF Option: Dock door prompt choice.
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
700aAD  oppmta                23     23
700aAD  opmaxa                24     25  0
700aAD  opdock                26     26
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
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
650bAC                   parm                    pSessId
650bAC                   parm                    pUser
650bAC                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
     c*                  parm                    perpt
     c                   parm                    pelbl
     c*                  parm                    prfwc
     c*                  parm                    pnrsc
     c*                  parm                    phpwc
     c*                  parm                    pmrga
     c*                  parm                    pplsq
     c*                  parm                    peadj
     c*                  parm                    pnopk
     c*                  parm                    pgpk1
     c*                  parm                    pgpk2
     c*                  parm                    pjitr
     c*                  parm                    ppset
     c*                  parm                    prfuc
     c*                  parm                    prflc
     c*                  parm                    pusf1
     c*                  parm                    prfsl
     c*                  parm                    prbn1
     c*                  parm                    prbn2
     c*                  parm                    psubt
700aAc*                  parm                    pmta
700aAc*                  parm                    pmaxa
700aAc*                  parm                    pdock

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650bA    logText = 'objloc:' + pObjLoc;
650bA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

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

         //operpt = perpt;
         opelbl = pelbl;
         //oprfwc = prfwc;
         //opnrsc = pnrsc;
         //ophpwc = phpwc;
         //opmrga = pmrga;
         //opplsq = pplsq;
         //opeadj = peadj;
         //opnopk = pnopk;
         //opgpk1 = pgpk1;
         //opgpk2 = pgpk2;
         //opjitr = pjitr;
         //oppset = ppset;
         //oprfuc = prfuc;
         //oprflc = prflc;
         //opusf1 = pusf1;
         //oprfsl = prfsl;
         //oprbn1 = prbn1;
         //oprbn2 = prbn2;
         //opsubt = psubt;
700aA    //if %parms >= 29;
700aA      //oppmta = pmta;
700aA      //opmaxa = pmaxa;
700aA      //opdock = pdock;
700aA    //endif;

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
700aA    //if client = usfcrp and %parms > 29;
700aA      //if pmaxa < 1 or pmaxa > 10;
700aA        //pMessage = 'Invalid Maximum # of Routes that can '
700aA          //       + 'be staged together. Must be 1-10';
700aA        //leavesr;
700aA      //endif;
700aA      //if pdock < '1' or pdock > '2';
700aA        //pMessage = 'Invalid Dock Door Prompt choice '
700aA          //       + '1=Staging or 2=Pick/Print';
700aA        //leavesr;
700aA      //endif;
700aA    //endif;

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

