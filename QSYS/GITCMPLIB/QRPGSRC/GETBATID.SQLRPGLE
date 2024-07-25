      /copy *libl/qcopysrc,hspecs
650aA*----------------------------------------------------------------
650aA* COMPILE WITH FOLLOWING OPTIONS:
650aA*
650aA*  Commitment control (COMMIT)  . . . *NONE
650aA*  Close SQL Cursor (CLOSQLCSR) . . . *ENDMOD
650aA*  Delay PREPARE (DLYPRP) . . . . . . *YES
650aA*
650aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETBATID    Get batch id
     *  31 December 2010
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    12/31/10  DAS  6.40
     *      - Created.
     *
650aA*    05/29/13  DAS  6.50a
     *      - Added compile comments at top of program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *      pStatus     Initial Status
     *
     *    Returned Parameters
     *      pBatId      Batch id
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D getbatid        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     D getbatid        pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  batIdExists    s               n
     D  recId          s             11p 0
     D  recIdA         s             11
     D  try            s              3p 0
     D  uStatus        s              1
     D  uType          s             10
     D  whse3S         s              3s 0

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';
         pBatId = ' ';

         // Translate input into upper case.

         uType = %xlate(xlower: xupper: pType);
         uStatus = %xlate(xlower: xupper: pStatus);

         // Get unique batch id.

         for try = 1 to 101;

           // Give up after 100 tries

           if try > 100;
             pReturn = '*BATIDERR1';
             pMessage = 'Unique batch id not found after '
                      + '100 tries. Last id tried: '
                      + recIdA;
             return;
           endif;

           // Call program to get 11 digit record id

           whse3S = pWhse;

           monitor;
             GetRecId(whse3S: 'STGBATCH': recId);
           on-error;
             pReturn = '*BATIDERR2';
             pMessage = 'Error calling GetRecId';
             return;
           endmon;

           recIdA = %trim(%char(recId));

           // Create STGBATCH record.

           exsr CrtSTGBATCH;

           if batIdExists;
             iter;
           endif;

           if pReturn <> '*OK';
             return;
           endif;

           leave;

         endfor;

         pBatId = recIdA;

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
     *  CrtSTGBATCH  Create STGBATCH record
     *----------------------------------------------------------------

      /free
       begsr CrtSTGBATCH;

         batIdExists = *off;

         clear sbrec;

         sbwhse = pWhse;
         sbbatid = recIdA;
         sbtype  = uType;
         sbstatus = uStatus;
         sbtext = 'Created by GetBatId Stored Procedure';

         exec sql insert into stgbatch
                  (sbwhse, sbbatid, sbtype, sbstatus, sbtext,
                   sbststs, sbstsuc, sbaddts, sbadduc)
                  values(:sbwhse, :sbbatid, :sbtype, :sbstatus, :sbtext,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         current_timestamp,
                         current_timestamp - current_timezone);

         if sqlstt <> sqlSuccess;
           select;
             when sqlstt = '23505';
              batIdExists = *on;
             when sqlstt = '42704';
              pReturn  = '*BATIDERR3';
              pMessage = 'File STGBATCH not found - '
                       + 'SQLSTT ' + sqlstt;
             other;
              pReturn  = '*BATIDERR4';
              pMessage = 'Unexpected error writing STGBATCH '
                       + ' record - SQLSTT ' + sqlstt;
           endsl;
         endif;

       endsr;
      /end-free
