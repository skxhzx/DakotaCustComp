      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ACDSHCREC  Add/Chg/Dlt SHIFTCLR record
     *  27 August 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    08/27/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fshiftclr  uf a e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pACD        Add, Change, Delete
     *      pWhse       Warehouse
     *      pCode       Shift code
     *      pColor      Color
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     D acdshcrec       pr                  extpgm('ACDSHCREC')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pACD                          1
     D  pWhse                         3p 0
     D  pCode                         6
     D  pColor                        7

     D acdshcrec       pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pACD                          1
     D  pWhse                         3p 0
     D  pCode                         6
     D  pColor                        7

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       pACD = %xlate(xlower: xupper: pACD);
       pCode = %xlate(xlower: xupper: pCode);

       select;

         when pACD = 'A';
           exsr AddRec;

         when pACD = 'C' or pACD = 'U';
           exsr ChangeRec;

         when pACD = 'D';
           exsr DeleteRec;

       endsl;

       return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec      Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         shcwhse = pWhse;
         shccode = pCode;
         shccolor = pColor;

         write(e) shcrec;
         if %error;
           if pACD = 'A';
             exsr ChangeRec;
           else;
             pErrMsg = 'Error updating(2) SHIFTCLR for '
                     + %char(pWhse) + '/' + %trim(pCode);
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChangeRec   Change record
     *----------------------------------------------------------------

      /free
       begsr ChangeRec;

         chain (pWhse: pCode) shiftclr;

         if not %found(shiftclr);
           if pACD <> 'A';
             exsr AddRec;
           else;
             pErrMsg = 'Error adding(2) SHIFTCLR for '
                     + %char(pWhse) + '/' + %trim(pCode);
           endif;
           leavesr;
         endif;

         shccolor = pColor;

         update(e) shcrec;
         if %error;
           pErrMsg = 'Error updating SHIFTCLR for '
                   + %char(pWhse) + '/' + %trim(pCode);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRec   Delete record
     *----------------------------------------------------------------

      /free
       begsr DeleteRec;

         chain (pWhse: pCode) shiftclr;

         if not %found(shiftclr);
           leavesr;
         endif;

         delete(e) shcrec;
         if %error;
           pErrMsg = 'Error deleting SHIFTCLR for '
                   + %char(pWhse) + '/' + %trim(pCode);
         endif;

       endsr;
      /end-free
