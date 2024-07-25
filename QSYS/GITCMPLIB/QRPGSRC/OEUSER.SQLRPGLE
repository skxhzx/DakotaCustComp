      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OEUSER     OPE *USER Upd - Pgm for SQL procedure of same name
     *  16 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    08/16/12  DAS  6.40
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

     D operec        E ds                  extname(optione) inz(*EXTDFT)
     D  optionCode     s             10    inz('*USER')

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
     D  pWhdp          s              5
     D  pman           s              1
     D  pnxte          s              5  0
     D  pvyn           s              1
     D  pzord          s              1
     D  ptbd           s              1

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
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Revisions
     *
520aA* 07/21/09 GJA 5.20a
     *          Enh:  Add zone or department option, Tote/Drop
     *                fuction, voice LABELDO exist
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
520aA*    OPVYN   -  Processing selection by voice (Y,N).
520aA*    OPZORD  -  Collect selection data by zone or department?
520aA*    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
     D optionRec       ds
     D  opman                  1      1
     D  opnxte                 2      6  0 inz(0)
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
     D  opend                117    117

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
     *      pWhdp       Department
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONE data field
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
     c                   parm                    pWhdp
     c                   parm                    pman
     c                   parm                    pnxte
     c                   parm                    pvyn
     c                   parm                    pzord
     c                   parm                    ptbd

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA
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
         opedta = optionRec;

         exec sql insert into optione values(:operec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opecod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Whdp(' + %trim(pWhdp) + ') '
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

         exec sql delete from optione
                  where opecod = :optionCode
                    and opewhs = :pWhse
                    and opewdp = :pWhdp;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opecod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Whdp(' + %trim(pWhdp) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opecod = optionCode;
         opewhs = pWhse;
         opewdp = pWhdp;

	        opman   = pman;
	        opnxte  = pnxte;
	        opvyn   = pvyn;
	        opzord  = pzord;
	        optbd   = ptbd;

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

         exec sql select * into :operec
                  from optione
                  where opecod = :optionCode
                    and opewhs = :pWhse
                    and opewdp = :pWhdp;

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
         opedta = optionRec;

         exec sql update optione
                  set opedta = :opedta
                  where opecod = :opecod
                    and opewhs = :pWhse
                    and opewdp = :pWhdp;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opecod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Whdp(' + %trim(pWhdp) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
