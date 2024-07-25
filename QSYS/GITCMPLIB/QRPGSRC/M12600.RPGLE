      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M12600   Dock door entry JSON info
     *  30 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/30/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fdocmtrx2  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtId          s              5
     D  pDept          s              5
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D assigned        s               n
     D door            s              3  0
     D dept            s              5

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pRtId        Route Id
     *      pDept        Department
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pRtId
     c                   parm                    pDept
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get information

        exsr GetDoor;

        // Build JSON string to return

        pOutStr = '{'
                +  '"assigned":'   + assigned + ','
                +  '"door":"'   + %char(door) + '"';

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
     *  GetDoor     Get current door, if any
     *----------------------------------------------------------------

      /free
       begsr GetDoor;

         assigned = *off;
         door = 0;

         setll (pWhse: pRtId: pDept) docmtrx2;
         reade (pWhse: pRtId: pDept) docmtrx2;
         if not %eof(docmtrx2);
           assigned = *on;
           door = dmdoor;
         endif;

       endsr;
      /end-free
