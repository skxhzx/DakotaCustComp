      /copy *libl/qcopysrc,hspecs
740 AH Dftactgrp(*No)

740 A*----------------------------------------------------------------
740 A*  Binding Directories
740 A*----------------------------------------------------------------

740 AHbnddir('BFCBND')
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
740 A*    08/18/20  KDE  7.40
     *      - Added field opckdd and changed to use newer mrc procedure
     *        call
     *
750 A*    08/13/21  KDE  7.50
     *      - Added field opddmax
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
740 AD  pDict          s             10
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
740 Ad  pckdd          s              1
750 Ad  pddmax         s              2  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

740 Ad dpCombo         s             20
650aAD logText         s            100
740 AD pparmStr1       s            999
740 AD pparmStr2       s            999
740 AD pparmStr3       s            999

740 A*----------------------------------------------------------------
740 A*  Translation strings
740 A*----------------------------------------------------------------

740 AD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
740 AD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

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
740 A*    OPCKDD  -  Check for Drop Pick Replenishments
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
740 Ad  opckdd                32     32
750 Ad  opddmax               33     34  0
414dAD  optend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl

740 A*----------------------------------------------------------------
740 A*  Sub-procedure prototypes
740 A*----------------------------------------------------------------

740 Ad ConvertField    pr
740 Ad  parmCount                     3  0
740 Ad  parmName                     10    varying
740 Ad  parmValue                   100    varying

740 Ad ExtractParms    pr

740 Ad ExtractParmStr  pr
740 Ad  parmStr                     999    varying

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

740 AC     *entry        plist
740 AC                   parm                    pMessage
740 AC                   parm                    pSessId
740 AC                   parm                    pUser
740 AC                   parm                    pDict
740 AC                   parm                    pPgm
740 AC                   parm                    pObjLoc
740 AC                   parm                    pparmStr1
740 AC                   parm                    pparmStr2
740 AC                   parm                    pparmStr3
740 DC*    *entry        plist
740 DC*                  parm                    pMessage
740 DC*                  parm                    pSessId
740 DC*                  parm                    pUser
740 DC*                  parm                    pPgm
740 DC*                  parm                    pObjLoc
740 DC*                  parm                    pSubCmd
740 DC*                  parm                    pData
740 DC*                  parm                    pWhse
740 Dc*                  parm                    prplb
740 Dc*                  parm                    poqrp
740 Dc*                  parm                    prpex
740 Dc*                  parm                    prpfi
740 Dc*                  parm                    plmts
740 Dc*                  parm                    pcqty
740 Dc*                  parm                    pbdrp
740 Dc*                  parm                    prsrt
740 Dc*                  parm                    pskpr
740 Dc*                  parm                    pjitw
740 Dc*                  parm                    plqty
740 Dc*                  parm                    psslcn
740 Dc*                  parm                    przst

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

740 A   // Combine dictionary/program
740 A
740 A   dpCombo = %trim(pDict) + '.' + pPgm;

650aA    // Write GLOSESSLOG record
650aA    logText = 'objloc:' + pObjLoc;
740 D    //wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
740 M    wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);

740 A   error = *off;

740 A   // Extract parameters from delimited string

740 A   ExtractParms();

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
740 A    opckdd = pckdd;
750 A    opddmax = pddmax;

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

           when parmName = 'OPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'OPDATA';
             pdata = %trim(parmValue);

           when parmName = 'OPRPLB';
             prplb = %trim(parmValue);

           when parmName = 'OPOQRP';
             poqrp =  parmValue;

           when parmName = 'OPRPEX';
             prpex = %trim(parmValue);

           when parmName = 'OPRPFI';
             prpfi = %trim(parmValue);

           when parmName = 'OPLMTS';
             plmts = %trim(parmValue);

           when parmName = 'OPCQTY';
             pcqty = %trim(parmValue);

           when parmName = 'OPBDRP';
             pbdrp = %trim(parmValue);

           when parmName = 'OPRSRT';
             prsrt = %trim(parmValue);

           when parmName = 'OPSKPR';
             pskpr = %trim(parmValue);

           when parmName = 'OPJITW';
             pjitw = %trim(parmValue);

           when parmName = 'OPLQTY';
             if parmValue = '';
               parmValue = '0';
             endif;
             plqty =  %dec(parmValue: 2: 0);

           when parmName = 'OPSSLCN';
             psslcn = %trim(parmValue);

           when parmName = 'OPRZST';
             przst = %trim(parmValue);

           when parmName = 'OPCKDD';
             pckdd = %trim(parmValue);

750 A      when parmName = 'OPDDMAX';
750 A        if parmValue = '';
750 A          parmValue = '0';
750 A        endif;
750 A        pddmax =  %dec(parmValue: 2: 0);

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
