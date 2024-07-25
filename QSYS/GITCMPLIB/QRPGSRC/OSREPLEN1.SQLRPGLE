      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSREPLEN   OPS *REPLEN Upd - Pgm for SQL procedure of same name
     *  13 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    08/13/12  DAS  6.40
     *      - Created.
     *
650aA*    03/07/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm.
     *      - Added call to WRTSESSLOG with submitted info.
     *
720 A*    02/23/18  KDE  7.20
     *      - Added fields opskpr, opjitw, oplqty, opsslcn, oprzst
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sdrec         E ds                  extname(slotdef) inz(*EXTDFT)
     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*REPLEN')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
	    d  prplb          s              8
	    d  poqrp          s              1
	    d  prpex          s              1
	    d  prpfi          s              1
	    d  plmts          s              1
	    d  pcqty          s              1
	    d  pbdrp          s              1
	    d  prsrt          s             10
720 Ad  pskpr          s              1
720 Ad  pjitw          s              1
720 Ad  plqty          s              2  0
720 Ad  psslcn         s              1
720 Ad  przst          s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100

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

413bA*----------------------------------------------------------------
413bA*  *REPLEN  -  Replenishment options.
413bA*----------------------------------------------------------------
413bA*
413bA* Fields
413bA*
413bA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
414dA*    OPOQRP  -  Order qty replenishment (Y/N).
416hA*    OPRPEX  -  Allow replenishment on expired items.
416hA*               1=Allow, 2=Don't allow, 3=Warn
416hA*    OPRPFI  -  Allow replenishments out of FIFO order.
416hA*               1=Allow, 3=Warn
417aA*    OPLMTS  -  Limit Specific Slot replenishment program to
417aA*               to display only one overflow location at a
417aA*               time. (Y/N)
500nA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
500nA*               letdown/transfer. (Y/N)
510aA*    OPBDRP  -  Check for Bulk Drops. (Y/N)
640hA*    OPRSRT  -  Sort Replenishment  (*DEMAND, *TOSLOT).
720 A*    OPSKPR  -  Skip if pick slot physical qty is greater than
720 A*               item replenishment level.
720 A*    OPJITW  -  During specific slot repl if this option = N don't
720 A*               bother checking for JIT's as the user does not want
720 A*               the JIT notification window.
720 A*    OPLQTY  -  Replenish pick slots that display less than X    t
720 A*               cases.                                           nt
720 A*    OPSSLCN -  Initiate Specific Slot Replenishment from License
720 A*               scan vs. Pick Slot
720 A*    OPRZST  -  Slot Type for Replenishment Zone Staging when pick
720 A*               slot can live in both WH and Store/Remote Area
413bA*
413bA* Data structure
413bA*
413bAD optionRec       ds
413bAD  oprplb                 1      8
414dAD  opoqrp                 9      9
416hAD  oprpex                10     10
416hAD  oprpfi                11     11
417aAD  oplmts                12     12
500nAD  opcqty                13     13
510aAD  opbdrp                14     14
640hAD  oprsrt                15     24
720 Ad  opskpr                25     25
720 Ad  opjitw                26     26
720 Ad  oplqty                27     28  0
720 Ad  opsslcn               29     29
720 Ad  oprzst                30     31
414dAD  optend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aA*      pSessId     Session Id
650aA*      pUser       GUI User
650aA*      pPgm        GUI dictionary.program
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
650aAC                   parm                    pSessId
650aAC                   parm                    pUser
650aAC                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
	    c                   parm                    prplb
	    c                   parm                    poqrp
	    c                   parm                    prpex
	    c                   parm                    prpfi
	    c                   parm                    plmts
	    c                   parm                    pcqty
	    c                   parm                    pbdrp
	    c                   parm                    prsrt
720 Ac                   parm                    pskpr
720 Ac                   parm                    pjitw
720 Ac                   parm                    plqty
720 Ac                   parm                    psslcn
720 Ac                   parm                    przst

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA    logText = 'objloc:' + pObjLoc;
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

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

	        oprplb = prplb;
	        opoqrp = poqrp;
	        oprpex = prpex;
	        oprpfi = prpfi;
	        oplmts = plmts;
	        opcqty = pcqty;
	        opbdrp = pbdrp;
	        oprsrt = prsrt;
720 A    opskpr = pskpr;
720 A    opjitw = pjitw;
720 A    oplqty = plqty;
720 A    opsslcn = psslcn;
720 A    oprzst = przst;

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
