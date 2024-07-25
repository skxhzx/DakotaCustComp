      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSITEMMNT  OPS *ITEMMNT Upd - Pgm for SQL procedure of same name
     *  15 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    08/15/12  DAS  6.40
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

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*ITEMMNT')

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
     D  pstyp          s              1
     D  pwhdp          s              5
     D  pum1           s              2
     D  pdum           s             15
     D  pcum           s             20
     D  pcdiv          s              9  2
     D  pcaut          s              1
     D  pcwrn          s              1
     D  pcrng          s              3  1
     D  pwum           s             15
     D  pxdsc          s              1
     D  phvy           s              2  0

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
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
219 A*    03/05/97  RH
     *      - Added OPXDSC
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
219 A*    OPXDSC  -  Use extended description (Y/N)
219 A*    OPHVY   -  Heavy items are greater than or equal to
     *
     * Data structure
     *
     D optionRec       ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2 inz(0)
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1 inz(0)
     D  opwum                 58     72
219 AD  opxdsc                73     73
     D  ophvy                 74     75  0 inz(0)
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
     c                   parm                    pstyp
     c                   parm                    pwhdp
     c                   parm                    pum1
     c                   parm                    pdum
     c                   parm                    pcum
     c                   parm                    pcdiv
     c                   parm                    pcaut
     c                   parm                    pcwrn
     c                   parm                    pcrng
     c                   parm                    pwum
     c                   parm                    pxdsc
     c                   parm                    phvy

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

	        opstyp  = pstyp;
	        opwhdp  = pwhdp;
	        opum1   = pum1 ;
	        opdum   = pdum ;
	        opcum   = pcum ;
	        opcdiv  = pcdiv;
	        opcaut  = pcaut;
	        opcwrn  = pcwrn;
	        opcrng  = pcrng;
	        opwum   = pwum ;
	        opxdsc  = pxdsc;
	        ophvy   = phvy ;

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
