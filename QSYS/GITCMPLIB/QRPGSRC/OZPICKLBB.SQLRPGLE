417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OZPICKLBB  OPTIONZ *PICKLBB Upd - Pgm for SQL procedure of same name
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
     D  plb4           s              1
     D  pcu4           s              1
     D  plp4           s             10
     D  pdv4           s             10
     D  pfm4           s             10
     D  plb5           s              1
     D  pcu5           s              1
     D  plp5           s             10
     D  pdv5           s             10
     D  pfm5           s             10
     D  plb6           s              1
     D  pcu6           s              1
     D  plp6           s             10
     D  pdv6           s             10
     D  pfm6           s             10
     D  plb7           s              1

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
520 A*  *PICKLBB -  Label printing options for the pick list and
     *              ASN labels and pick list report.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBB which holds printing info
     *         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
530 A*    OPLB7   -  Print PICK labels for ZONPKUP D/S- Pick labels
     *
     * Data structure
     *
520 AD picklbbRec      ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
530 AD  oplb7                 97     97
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
     c                   parm                    plb4
     c                   parm                    pcu4
     c                   parm                    plp4
     c                   parm                    pdv4
     c                   parm                    pfm4
     c                   parm                    plb5
     c                   parm                    pcu5
     c                   parm                    plp5
     c                   parm                    pdv5
     c                   parm                    pfm5
     c                   parm                    plb6
     c                   parm                    pcu6
     c                   parm                    plp6
     c                   parm                    pdv6
     c                   parm                    pfm6
     c                   parm                    plb7

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
         opzcod = '*PICKLBB';
         exsr FillRec;
         opzdta = picklbbRec;

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
         opzcod = '*PICKLBB';

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

         oplb4 = plb4;
         opcu4 = pcu4;
         oplp4 = plp4;
         opdv4 = pdv4;
         opfm4 = pfm4;
         oplb5 = plb5;
         opcu5 = pcu5;
         oplp5 = plp5;
         opdv5 = pdv5;
         opfm5 = pfm5;
         oplb6 = plb6;
         opcu6 = pcu6;
         oplp6 = plp6;
         opdv6 = pdv6;
         opfm6 = pfm6;
         oplb7 = plb7;

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
         opzcod = '*PICKLBB';

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
         opzcod = '*PICKLBB';
         exsr FillRec;
         opzdta = picklbbRec;

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
