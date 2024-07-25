      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  WRTDDLOG  - Write DDLOG record
     *
     *  27 March  2013
     *  Dave Sommerville
     *
     *  Revisions
     *
650aA*    03/27/13  DAS  6.50a
     *      - Created
     *
650bA*    05/02/14  DAS  6.50b
     *      - Changed to *CALLER from *NEW.
     *      - Move *INLR to top.
     *      - Added return to end.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fddlog     o    e             disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /copy qcopysrc,id#usfcorp
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D error           s               n
     D forever         s               n
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')

417iAD                 ds
417iAD  stamp20                1     20  0
417iAD  stamp7                14     20  0

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse      warehouse
     *      $pRtid      route id
     *      $pRecType   Record Type
     *      $pMovType   Move Type
     *      $pDDUsed    DD Used
     *      $pFromPlt   From Pallet
     *      $pToPlt     To Pallet
     *      $pStop      Stop
     *      $pFromLbl#  Label #
     *      $pNewLbl#   New label # (for DROPPCS)
     *      $pPcs       Pieces
     *      $pCurUser   Current User
     *      $pPgm       Program
     *
     *    Returned Parameters
     *      $PRTN   *ERROR   - Error occurred.
     *              *OK      - No problems encountered.
     *      $PMSG   Return message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pRtid            5
     C                   parm                    $pGrpId           7 0
     C                   parm                    $pRecType         1
     C                   parm                    $pMovType         1
     C                   parm                    $pDDUsed          1
     C                   parm                    $pFromPltId       7 0
     C                   parm                    $pToPltId         7 0
     C                   parm                    $pStop            2 0
     C                   parm                    $pLbl#            7 0
     C                   parm                    $pNewLbl#         7 0
     C                   parm                    $pPcs             5 0
     C                   parm                    $pCurUser        10
     C                   parm                    $pPgm            10
     C                   parm                    $pReturn         10
     C                   parm                    $pMessage        80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
      /free
         *inlr = *on;

         exsr getcurrstamp;

         getclient(client: clientLoc);

         // Initialize group id if not sent in.
         // Group Id not implemented yet.

         //if $pGrpId = 0;
         //  stamp20 = %dec(currstampsys);
         //  $pGrpId = stamp7;
         //endif;

         // Initialize current user if not sent in.

         if $pCurUser = ' ';
           $pCurUser = #curruser;
         endif;

         exsr WrtRecord;

         return;
      /end-free

     *----------------------------------------------------------------
     * WrtRecord - Write record
     *----------------------------------------------------------------

     C     WrtRecord     begsr
      /free

          clear ddlrec;

          ddlwhse = $pWhse;
          if client = usfcorp;
            ddlbrnch = %trim(clientloc);
          endif;
          ddlrtid = $pRtid;
          ddlgrpid = $pGrpId;
          ddlrectyp = $pRecType;
          ddlmovtyp = $pMovType;
          ddlddused = $pDDUsed;
          ddlfplid = $pFromPltId;
          ddltplid = $pToPltId;
          ddlstop = $pStop;
          ddllbl# = $pLbl#;
          ddlnewlbl# = $pNewLbl#;
          ddlpcs = $pPcs;
          ddlrtn = $pReturn;
          ddlmsg = $pMessage;
          ddlpgm = $pPgm;

          ddladdts = currstampsys;
          ddladduc = currstampuc;
          ddlcurusr = $pCurUser;
          ddljobusr = #user;
          ddljob = #job;
          ddljobnbr = #jobnbr;

          write ddlrec;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);

       endsr;
      /end-free
