417cA /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTECLSTRN   Route close tran - Pgm for SQL procedure of same name
     *  01 April 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    04/01/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    The verification logic was taken from RH120A.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     F*tehed    if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n

     D logText         s            100

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId  Session id
     *      pUser    User
     *      pPgm     Calling dictionary.pgm
     *      pWhse    Warehouse
     *      pRtid    Route id (9 because coming from ptrtpo)
     *      pTrn     Tran number
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         80
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pPgm             20
     C                   parm                    pWhse             3 0
     C                   parm                    pRtid             9
     C                   parm                    pTrn              7 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record

         logText = 'whs:' + %char(pWhse) + ','
                 + 'rtid:' + %trim(pRtid) + ','
                 + 'trn:' + %char(pTrn);
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR    Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr


     C                   endsr
