      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11100   Get transaction close JSON info
     *  01 April 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/01/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpirtran   if   e           k disk
     F*abel     if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCmd           s             10
     D  pWhse          s              3p 0
     D  pRtid          s              5
     D  pTrn           s              7p 0
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D trnNotFound     s               n

     *----------------------------------------------------------------
     *  OutStr Variables
     *
     *    allowCls   1 = Allow, 0 = Do not allow
     *
     *    clsflg     Lowest number of lblflg/wgtflg fields
     *
     *    lblflg     1 = Error
     *               2 = Warning - needs overriding
     *               3 = Warning - no override needed
     *               4 = No errors or warnings
     *
     *    wgtflg     1 = Error
     *               2 = Warning - needs overriding
     *               3 = Warning - no override needed
     *               4 = No errors or warnings
     *
     *
     *----------------------------------------------------------------

     D allowCls        s               n
     D clsflg          s              1
     D ClsFlgText      s             50
     D lblflg          s              1
     D lblflgText      s             50
     D wgtflg          s              1
     D wgtflgText      s             50

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pRtid        Route Id
     *      pTrn         Tran number
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pTrn
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get tran record

         chain (pTrn) pirtran;
         if not %found(pirtran);
           clear ptrec;
           trnNotFound = *on;
         else;
           trnNotFound = *off;
         endif;

        // Check labels

        exsr ChkLabels;

        // Check weights

        exsr ChkWgts;

        // See if allowed to close transaction

        exsr GetAllowCls;

        // Build JSON string to return
        // Note, sts must come first so it can be used for sorting

        pOutStr = '{'
                +  '"alwcls":' + allowCls + ','
                +  '"alwtxt":"' + %trimr(allowClsText) + '",'
                +  '"lblflg":' + lblflg + ','
                +  '"lbltxt":"' + %trimr(lblflgText) + '",'
                +  '"wgtflg":' + wgtflg + ','
                +  '"wgttxt":"' + %trimr(wgtflgText) + ','
                +  '"stat":' + ptstat;

        // Add custom client fields


        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetAllowCls     See if allowed to close transaction
     *----------------------------------------------------------------

      /free
       begsr GetAllowCls;

         allowCls = *on;
         allowClsText = '';

         select;
           when trnNotFound;
             allowCls = *off;
             allowClsText = 'Cannot close - '
                          + 'Transaction record not found';
           when ptstat = '4';
             allowCls = *off;
             allowClsText = 'Cannot close - '
                          + 'Transaction already closed';
           when lblflg = '1';
             allowCls = *off;
             allowClsText = 'Cannot close - '
                          + 'Label error';
           when wgtflg = '1';
             allowCls = *off;
             allowClsText = 'Cannot close - '
                          + 'Weight error';
           when wgtflg = '2';
             allowCls = *off;
             allowClsText = 'Cannot close - '
                          + 'Weight warning needs override';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkLabels       Check labels
     *----------------------------------------------------------------

      /free
       begsr ChkLabels;

         lblflg = '4';
         lblflgText = 'No label errors';

         //lblflg = '1';
         //lblflgText = 'Errors';

         // Loop through labels for transaction


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkWgts         Check weights
     *----------------------------------------------------------------

      /free
       begsr ChkWgts;

         wgtflg = '4';
         wgtflgText = 'No weight errors';

         //wgtflg = '3';
         //wgtflgText = 'Warnings overridden';

         //wgtflg = '2';
         //wgtflgText = 'Warnings without overrides';

         //wgtflg = '1';
         //wgtflgText = 'Errors';


       endsr;
      /end-free
