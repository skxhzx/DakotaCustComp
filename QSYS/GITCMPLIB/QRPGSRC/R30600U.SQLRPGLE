      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR30600U     PO Receiving - Mark po complete
     *  26 September 2018
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    09/26/18  LMC  7.20
     *      - Created.
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pcomplete   Complete
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Called program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     d/copy qcopysrc,p.expohdr

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
650eA /COPY QCOPYSRC,ID#PACKERS

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3p 0
     D pPo             s              9
     D pcomplete       s              1
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D exRtnCode       s             10
     D exRtnMsg        s             60
     D exWhse          s              3s 0
     D failed          s              1
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pcomplete
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';

        failed = ' ';
        // Update 'Complete' flag

        monitor;
          exWhse = pwhse;
          expohdr('*CHANGE': exRtnCode: exRtnMsg:
                   exWhse: ppo: pcomplete);
          if exRtnCode <> '*OK';
            expohdr('*ADD': exRtnCode: exRtnMsg:
                     exWhse: ppo: pcomplete);
            if exRtnCode <> '*OK';
              failed = 'Y';
            endif;
          endif;
          on-error;
        endmon;

         pOutStr = '{'
                +  '"PO":"'  + %trimr(pPO) + '",'
                      +  '"NO":"'  + %trimr(Failed) + '",'
                +  '"Complete":"'  + %trimr(pcomplete) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

