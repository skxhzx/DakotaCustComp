      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  BFCTMPLIST   Work with file BFCTMPLST
     *  26 December 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    12/26/15  DAS  7.00
     *      - Created
700aA*    01/27/16  NLK  7.00a
     *      - removed $pKey on reade on *GetNext
700aA*    11/04/16  NLK  7.00b
     *      - FIX: Errors are occurring on the socket
     *        Unable to allocate a record in file BFCTMPLST
     *        This error at stmt 195.00 with cmd-*getnext
     *        unsure why this is happening, i will try to
     *        use LF read only to see if it helps
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbfctmplst uf a e           k disk
     Fbfctmplst1if   e           k disk
     F                                     rename(btlrec:btlrec1)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pCmd           s             10a
     D $pWhse          s              3  0
     D $pList          s                   like(btllist)
     D $pKey           s                   like(btlkey)
     D $pValue         s                   like(btlvalue)
     D $pReturn        s             10a

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    $pCmd      - *ADD     - Add list/key record
     *                 *CLEAR   - Delete all records for a list
     *                 *DELETE  - Delete list/key record
     *                 *GET     - Get list/key record
     *                 *GETNEXT - Get next list/key record
     *    $pWhse     - Warehouse
     *    $pList     - List code
     *    $pKey      - Key
     *    $pValue    - Value
     *
     *    Returned Parameters
     *    $pValue    - Value for *GET
     *    $pReturn   - *OK, *NOTFOUND, *ERROR
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd
     C                   parm                    $pWhse
     C                   parm                    $pList
     C                   parm                    $pKey
     C                   parm                    $pValue
     C                   parm                    $pReturn

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

      /free

        $pReturn = '*OK';

        select;
          when $pCmd = '*ADD';
            exsr AddRec;
          when $pCmd = '*CLEAR';
            exsr ClearList;
          when $pCmd = '*DELETE';
            exsr DeleteRec;
          when $pCmd = '*GET';
            exsr GetRec;
          when $pCmd = '*GETNEXT';
            exsr GetNextRec;
        endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec  Add record
     *----------------------------------------------------------------
      /free
       begsr AddRec;

         setll ($pWhse: $pList: $pKey) bfctmplst;

         // if not %found(bfctmplst);
         if not %equal(bfctmplst);

           btlwhse  = $pWhse;
           btllist  = $pList;
           btlkey   = $pKey;
           btlvalue = $pValue;

           btladdts = %timestamp();
           btladdusr = #user;
           btladdjob = #job;
           btladdnbr = #jobnbr;

           write(e) btlrec;

           if %error();
             $pReturn = '*ERROR';
           endif;

         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ClearList  Delete all records for a list
     *----------------------------------------------------------------
      /free
       begsr ClearList;

         setll ($pWhse: $pList) bfctmplst;
         dow forever = forever;
           reade ($pWhse: $pList) bfctmplst;
           if %eof(bfctmplst);
             leave;
           endif;
           delete(e) btlrec;
           if %error();
             $pReturn = '*ERROR';
           endif;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRec   Delete record
     *----------------------------------------------------------------
      /free
       begsr DeleteRec;

         chain ($pWhse: $pList: $pKey) bfctmplst;

         if %found(bfctmplst);
           delete(e) btlrec;
           if %error();
             $pReturn = '*ERROR';
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec     Get record
     *----------------------------------------------------------------
      /free
       begsr GetRec;

         chain(n) ($pWhse: $pList: $pKey) bfctmplst1;

         if %found(bfctmplst1);
           $pValue = btlvalue;
         else;
           $pValue = '';
           $pReturn = '*ERROR';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetNextRec    Get next record
700aD *  reade ($pWhse: $pList: $pKey) bfctmplst;
     *----------------------------------------------------------------
      /free
       begsr GetNextRec;

         setgt ($pWhse: $pList: $pKey) bfctmplst1;
         reade ($pWhse: $pList) bfctmplst1;
         if %eof(bfctmplst1);
           $pValue = '';
           $pReturn = '*NOTFOUND';
         else;
           $pValue = btlvalue;
         endif;

       endsr;
      /end-free
