      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKEACH   Check for *EACH slot for item
     *  10 June 2016
     *  Dave Sommerville
     *
     *  Revisions
     *
700 A*    06/09/16  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D sldisp          s             12

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse   Warehouse number.
     *      pItem   Item
     *
     *    Returned Parameters
     *      pRtnFlag  1 = *EACH slot exists for item.
     *                0 = *EACH slot does not exist for item.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pItem            15
     C                   parm                    pRtnFlag          1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
610cA
610cA   exec sql select sldisp into :sldisp
610cA            from slot
610cA            left outer join slotdef
610cA              on sdwhse = slwhse
610cA                 and sdcode = slsdef
                 where slwhse = :pwhse
                   and slitem = :pitem
                   and sdpal = '*EACH'
                 fetch first 1 rows only;
610cA
610bA   If sqlstt = sqlSuccess;
610aA     pRtnFlag = '1';
610bA   else;
610aA     pRtnFlag = '0';
610bA   endif;

        return;
      /end-free
