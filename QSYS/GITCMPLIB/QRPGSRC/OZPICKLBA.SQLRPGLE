417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OZPICKLBA  OPTIONZ *PICKLBA Upd - Pgm for SQL procedure of same name
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
     D  plb1           s              1
     D  pcu1           s              1
     D  plp1           s             10
     D  pdv1           s             10
     D  pfm1           s             10
     D  plb2           s              1
     D  pcu2           s              1
     D  plp2           s             10
     D  pdv2           s             10
     D  pfm2           s             10
     D  plb3           s              1
     D  pcu3           s              1
     D  plp3           s             10
     D  pdv3           s             10
     D  pfm3           s             10

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
520 A*  *PICKLBA -  Label printing options for the standard pick,
     *              retail, and tote labels.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
520 AD picklbaRec      ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
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
     *      pCmd        A=Add, U=Update, D=Delete
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
     c                   parm                    plb1
     c                   parm                    pcu1
     c                   parm                    plp1
     c                   parm                    pdv1
     c                   parm                    pfm1
     c                   parm                    plb2
     c                   parm                    pcu2
     c                   parm                    plp2
     c                   parm                    pdv2
     c                   parm                    pfm2
     c                   parm                    plb3
     c                   parm                    pcu3
     c                   parm                    plp3
     c                   parm                    pdv3
     c                   parm                    pfm3

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
         opzcod = '*PICKLBA';
         exsr FillRec;
         opzdta = picklbaRec;

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
         opzcod = '*PICKLBA';

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

         oplb1 = plb1;
         opcu1 = pcu1;
         oplp1 = plp1;
         opdv1 = pdv1;
         opfm1 = pfm1;
         oplb2 = plb2;
         opcu2 = pcu2;
         oplp2 = plp2;
         opdv2 = pdv2;
         opfm2 = pfm2;
         oplb3 = plb3;
         opcu3 = pcu3;
         oplp3 = plp3;
         opdv3 = pdv3;
         opfm3 = pfm3;

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
         opzcod = '*PICKLBA';

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
         opzcod = '*PICKLBA';
         exsr FillRec;
         opzdta = picklbaRec;

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
