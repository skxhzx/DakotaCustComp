      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M01800   Get exported route JSON info
     *  05 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/04/14  DAS  6.50
     *      - Created.
700a *    06/09/16  LMC  7.00A
     *      - Revised to use Pick fields instead of Order fields for
     *      calculating Cube, Weight and Pcs.
     *
720aA*    04/14/18  DAS  7.20a
     *      - Added DD2 to identify route is a DD2 route.
     *      - Added file DDDETAIL.
     *
720bA*    09/12/18  DAS  7.20b
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
     *      - Removed DDDETAIL file since check is not needed anymore.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtesum    if   e           k disk
     Fordh3     if   e           k disk
     Fordhm2    if   e           k disk
     Fcrossdk1  if   e           k disk


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chkiuse

510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
510   /copy qcopysrc,id#packers

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtId          s              5
     D  pRte           s              5
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D allowExport     s               n
     D allowText       s             50
     D client          s             10
     D clientloc       s             10
     D cube            s                   like(rsordc)
     D inUse           s               n
     D iuCmd           s              8
     D iuRtn           s              8
     D iuFlag          s              1  0
     D iuSubFlag       s              1  0
     D iuText10        s             10
     D iuText30        s             30
     D pieces          s                   like(rsordp)
     D shipNbr         s             11
720bAd tbEnhanced      s               n
720bAd tbPalletType    s              1
720bAd tbType          s              1
720bAd tbWhse          s              3  0
     D weight          s                   like(rsordw)
     D xdockPO         s                   like(cdpo)

     *----------------------------------------------------------------
     *  Misc Data Structure
     *----------------------------------------------------------------

510  *  Shipment number from Miscellaneous field
510  D                 ds
510  D  hmmsc1                 1     40
510  D  hmmshp                 4     14

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pRtId        Route Id
     *      pRte         Route
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
610aAc                   parm                    pRtId
     c                   parm                    pRte
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get information

        exsr GetInUse;
        exsr GetCubeWgtPcs;
        exsr GetXDockPO;
720aA   exsr chkDD2;

        // See if allowed to ReExport Trans based on information.

        select;
          when inUse;
            allowExport = false;
            allowText = 'ReExporting Route not allowed - '
                      + 'Route In-Use';
          other;
            allowExport = true;
            allowText = 'ReExport Route';
        endsl;


        // Build JSON string to return

        pOutStr = '{'
                +  '"alwexport":'   + allowExport + ','
                +  '"alwtxt":"'   + %trimr(allowText) + '",'
                +  '"cube":"'   + %trim(%editc(cube:'A')) + '",'
                +  '"wgt":"'   + %trim(%editc(weight:'A')) + '",'
                +  '"pcs":"'   + %trim(%editc(pieces:'A')) + '",'
                +  '"iu":'   + inUse + ','
                +  '"iutxt":"'   + %trimr(iutext10) + '",'
720bM           +  '"dd2":' + tbEnhanced + ','
                +  '"xpo":"'  + %trimr(xdockPO) + '"';

        // Add custom client fields

        if client = packers;
          exsr GetShipNbr;
          pOutStr = %trimr(pOutStr) + ','
                  +  '"shnbr":"'  + %trimr(shipNbr) + '"';
        endif;

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

720aA*----------------------------------------------------------------
720aA*  ChkDD2     Check if route is a DD2 route
720aA*----------------------------------------------------------------
720aA
720aA /free
720aA  begsr ChkDD2;

720bA    // Determine if using TruckBUilder Enhanced
720bA
720bA      tbWhse = pwhse;
720bA      GetTBType(tbWhse: prtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA        tbPalletType = 'P';
720bA      else;
720bA        tbEnhanced = *off;
720bA        tbPalletType = 'O';
720bA      endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetCubeWgtPcs   Get cube, weight and pieces
     *----------------------------------------------------------------

      /free
       begsr GetCubeWgtPcs;

600nA    cube = 0;
600nA    weight = 0;
600nA    pieces = 0;

         setll (pWhse: pRtId) rtesum;

         dow forever = forever;

           reade (pWhse: pRtId) rtesum;
           if %eof(rtesum);
             leave;
           endif;

700aD      //cube   += rsordc;
700aD      //weight += rsordw;
700aD      //pieces += rsordp;
700aM      cube   += rspckc;
700aM      weight += rspckw;
700aM      pieces += rspckp;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetInUse   Get In-Use flag
     *----------------------------------------------------------------

      /free
       begsr GetInUse;

         iuCmd = '*GETIUSE';

         monitor;
           ChkIUse(iuCmd: pwhse: pRtId: iuRtn:
                   iuFlag: iuSubFlag: iuText10: iuText30);
         on-error;
           iuRtn = '*ERROR';
           iuText10 = 'GETIUSE NF';
           iuText30 = 'Error calling GETIUSE program';
         endmon;

        if iuRtn = '*ERROR' or iuFlag <> 0;
          inUse = true;
        else;
          inUse = false;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetShipNbr   Get Packers shipment number
     *----------------------------------------------------------------

      /free
       begsr GetShipNbr;

600nA    shipNbr = '';

         chain (pWhse: pRtId) ordhm2;
         if %found(ordhm2);
           shipNbr = hmmshp;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetXDockPO   Get crossdock PO
     *----------------------------------------------------------------

      /free
       begsr GetXDockPO;

600nA    xdockPO = '';

         setll (pWhse: pRtId) ordh3;

         dow forever = forever;

           reade (pWhse: pRtId) ordh3;
           if %eof(ordh3);
             leave;
           endif;

           chain (ohwhse: ohord) crossdk1;
           if %found(crossdk1);
             xdockPO = cdpo;
             leave;
           endif;

         enddo;

       endsr;
      /end-free
