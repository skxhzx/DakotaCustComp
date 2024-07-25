      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M12700   Dock door entry JSON info
     *  07 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/07/14  DAS  6.50
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
     D  pDoor          s              3p 0
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
     D cube            s              7  3
     D door            s              3  0
     D dept            s              5

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pRtId        Route Id
     *      pDoor        Door
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
     c                   parm                    pDoor
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
                +  '"door":"'   + %char(door) + '",'
                +  '"dept":"'   + %trim(dept) + '"';

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
         dept = '';

         setll (pWhse: pRtId) docmtrx2;
         reade (pWhse: pRtId) docmtrx2;
         if not %eof(docmtrx2);
           assigned = *on;
           door = dmdoor;
           dept = dmwhdp;
         endif;

       endsr;
      /end-free
