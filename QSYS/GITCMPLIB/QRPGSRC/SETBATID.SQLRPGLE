      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SETBATID    Set batch id status
     *  16 September 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    09/16/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pBatId      Batch id
     *      pStatus     Initial Status
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D getbatid        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pBatId                      11
     D   pStatus                      1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D getbatid        pi
      * Input
     D   pWhse                        3p 0 const
     D   pBatId                      11
     D   pStatus                      1    const
      * Output
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

     D  whse3S         s              3s 0

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         sbwhse = pWhse;
         sbbatid = %xlate(xlower: xupper: pBatId);
         sbstatus = %xlate(xlower: xupper: pStatus);

         exec sql update stgbatch
                    set sbstatus = :sbstatus,
                        sbststs = current_timestamp,
                        sbstsuc = current_timestamp - current_timezone
                  where sbwhse = :sbwhse
                    and sbbatid = :sbbatid;

         if sqlstt <> sqlSuccess;
           pReturn  = '*UPDSTAT';
           pMessage = 'Error updating STGBATCH status - '
                    + 'SQLSTT ' + sqlstt;
         endif;

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
