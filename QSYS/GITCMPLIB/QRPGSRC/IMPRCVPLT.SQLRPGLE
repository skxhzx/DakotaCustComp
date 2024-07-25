417cA /copy *libl/qcopysrc,hspecs
650aA*----------------------------------------------------------------
650aA* COMPILE WITH FOLLOWING OPTIONS:
650aA*
650aA*  Commitment control (COMMIT)  . . . *NONE
650aA*  Close SQL Cursor (CLOSQLCSR) . . . *ENDMOD
650aA*  Delay PREPARE (DLYPRP) . . . . . . *YES
650aA*
650aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  IMPRCVPLT   IMPRCVPLT import
     *  23 March 2011
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    03/23/11  DAS  6.40
     *      - Created.
     *
CBI A*   02/22/12   CBI-JGD
CBI A*   Expand by five new fields output file "Impsrcvp".
     *
650aA*    05/29/13  DAS  6.50a
     *      - Added compile comments at top of program. When compiled
     *        with CLOSQLCRS = *ENDACTGRP, STGBATCH file wasn't always
     *        being closed, even with calling program doing a
     *        RCLRSC *CALLER.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pUpdType    A)dd, C)hange, D)elete
     *      pPO         Purchase Order number
     *      pSeq        Purchase Order detail line number
     *      pVendor     Vendor number
     *      pLicense    License number
     *      pItem       Item number
     *      pQty1       Normal 1ty
     *      pQty2       Breakdown 1 qty
     *      pQty3       Breakdown 2 qty
     *      pExpDte     Expiration date
     *      pLicense2   New license number for UpdType 'C'
     *      pUsrId      User Id
     *      pVeNam      Vendor name
     *      pRcvDate    Receive date
     *      pRcvTime    Receive time
     *      pMnfgDate   Manufacturing date
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D imprcvplt       pr                  extpgm('IMPRCVPLT')
      * Input
     D   pWhse                        3p 0 const
     D   pUpdType                     1    const
     D   pPO                          9    const
     D   pSeq                         5p 0 const
     D   pVendor                     11p 0 const
     D   pLicense                    15    const
     D   pItem                       15    const
     D   pQty1                        5p 0 const
     D   pQty2                        5p 0 const
     D   pQty3                        5p 0 const
CBI MD   pExpDte                      8p 0 const
     D   pLicense2                   15    const
CBI AD   pUsrId                      10    const
CBI AD   pVeNam                      40    const
CBI AD   pRcvDate                     8p 0 const
CBI AD   pRcvTime                     6p 0 const
CBI AD   pMnfgDate                    8p 0 const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D imprcvplt       pi
      * Input
     D   pWhse                        3p 0 const
     D   pUpdType                     1    const
     D   pPO                          9    const
     D   pSeq                         5p 0 const
     D   pVendor                     11p 0 const
     D   pLicense                    15    const
     D   pItem                       15    const
     D   pQty1                        5p 0 const
     D   pQty2                        5p 0 const
     D   pQty3                        5p 0 const
CBI MD   pExpDte                      8p 0 const
     D   pLicense2                   15    const
CBI AD   pUsrId                      10    const
CBI AD   pVeNam                      40    const
CBI AD   pRcvDate                     8p 0 const
CBI AD   pRcvTime                     6p 0 const
CBI AD   pMnfgDate                    8p 0 const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D alphaWhse       s              3
     D cmd             s           3000    varying
     D client          s             10
     D clientLoc       s             10
     D temp3n          s              3p 0
     D uRunType        s              1
     D uType           s             10
     D wwMsgKey        s              4A

640bA*----------------------------------------------------------------
640bA*  Return parameter result set
640bA*----------------------------------------------------------------
640bA
640bAD pgmStatus       ds                  occurs(1)
640bAD  sReturn                      10
640bAD  sMessage                    200

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetClient       pr                  extpgm('GETCLIENT')
     D  pClient                      10
     D  pClientLoc                   10

     D po237s          pr                  extpgm('PO237S')
     D  pWhse                         3    const
     D  pUpdType                      1    const
     D  pPO                           9    const
     D  pSeq                          5p 0 const
     D  pVendor                      11p 0 const
     D  pLicense                     15    const
     D  pItem                        15    const
     D  pQty1                         5p 0 const
     D  pQty2                         5p 0 const
     D  pQty3                         5p 0 const
CBI MD  pExpDte                       8p 0 const
     D  pLicense2                    15    const
CBI AD  pUsrId                       10    const
CBI AD  pVeNam                       40    const
CBI AD  pRcvDate                      8p 0 const
CBI AD  pRcvTime                      6p 0 const
CBI AD  pMnfgDate                     8p 0 const
     D  pReturn                      10
     D  pMessage                    200

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         // Convert warehouse to alpha

         alphaWhse = %trim(%char(pWhse));

         // Call import program

             monitor;
               po237s(alphaWhse: pUpdType: pPO: pSeq: pVendor:
                      pLicense: pItem: pQty1: pQty2: pQty3: pExpDte:
                      pLicense2: pUsrId: pVeNam: pRcvDate: pRcvTime:
                      pMnfgDate: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRPO237S';
               pMessage = 'Error calling PO237S';
               dump(a);
             endmon;

         exsr SendSet;
         return;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         pReturn = 'U:' + #status;
         pMessage = 'U:'
                  + %trim(#pgm)
                  + '('
                  + %trim(%editc(#stmt:'Z'))
                  + ')-'
                  + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // Get client id

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SendSet    Send back result set
     *----------------------------------------------------------------

      /free
       begsr SendSet;

         sReturn = pReturn;
         sMessage = pMessage;

         exec sql
           set result sets with return to client
               array :pgmStatus for 1 rows;

       endsr;
      /end-free
