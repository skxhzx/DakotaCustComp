417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OZPICKLBL  OPTIONZ *PICKLBL Upd - Pgm for SQL procedure of same name
     *  11 April 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    04/11/12  DAS  6.40
     *      - Created.
     *
650aA*    03/07/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm.
     *      - Added call to WRTSESSLOG with submitted info.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D opzrec        E ds                  extname(optionz) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pWhse          s              3  0
     D  pTruck         s             10
     D  pZone          s              6
     D  pclvl          s              3  0
     D  pcwra          s              1
     D  pcwrb          s              1
     D  puwra          s              1
     D  puwrb          s              1
     D  ptext          s             43
     D  perr           s              2  0
     D  pcwgt          s              2  0
520 AD  paisl          s              1
520 AD  ptaxr          s              1
520 AD  pchkr          s              1

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

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
520 A*     08/12/09  RBD
     *       - Added notation for option OPAISL which was previously
     *         added to ZH122.
     *       - Added options OPTAXR and OPCHKR to *PICKLBL.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
300 A*    OPPDEV  -  Printer device.
300 A*    OPPFRM  -  Printer form.
520 A*    OPAISL  -  Print aisle change label (Y/N).
520 A*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
520 A*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
     D picklblRec      ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
300 AD  oppdev                65     74
300 AD  oppfrm                75     84
520 AD  opaisl                85     85
520 AD  optaxr                86     86
520 AD  opchkr                87     87
     D  optend               117    117

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
     *      pCmd        A=Add, U=Update, D=Delete, B=Build
     *      pWhse       Warehouse
     *      pTruck      Truck
     *      pZone       Zone
     *
     *    Returned Parameters
     *      pMessage   Return error message
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
     C                   parm                    pWhse
     C                   parm                    pTruck
     C                   parm                    pZone
     c                   parm                    pclvl
     c                   parm                    pcwra
     c                   parm                    pcwrb
     c                   parm                    puwra
     c                   parm                    puwrb
     c                   parm                    ptext
     c                   parm                    perr
     c                   parm                    pcwgt
520 Ac                   parm                    paisl
520 Ac                   parm                    ptaxr
520 Ac                   parm                    pchkr

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
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  AddRec    Add record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr AddRec;

         error = *off;
         opzcod = '*PICKLBL';
         exsr FillRec;
         opzdta = picklblRec;

         exec sql insert into optionz values(:opzrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  AfterAct     After action update
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr AfterAct;

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
500sA*  DelRec    Delete record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr DelRec;

         error = *off;
         opzcod = '*PICKLBL';

         exec sql delete from optionz
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  FillRec   Fill record fields
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr FillRec;

         opzwhs = pWhse;
         opztrk = pTruck;
         opzzon = pZone;

         opclvl = pclvl;
         opcwra = pcwra;
         opcwrb = pcwrb;
         opuwra = puwra;
         opuwrb = puwrb;
         optext = ptext;
         operr  = perr;
         opcwgt = pcwgt;
520 A    opaisl = paisl;
520 A    optaxr = ptaxr;
520 A    opchkr = pchkr;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  FldValid   Validate fields
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  GetRec    Get record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr GetRec;

         found = *off;
         opzcod = '*PICKLBL';

         exec sql select * into :opzrec
                  from optionz
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free


500sA*----------------------------------------------------------------
500sA*  UpdRec    Update record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr UpdRec;

         error = *off;
         opzcod = '*PICKLBL';
         exsr FillRec;
         opzdta = picklblRec;

         exec sql update optionz
                  set opzdta = :opzdta
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
