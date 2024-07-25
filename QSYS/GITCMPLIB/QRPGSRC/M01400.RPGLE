      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M01400   Get open route JSON info
     *  03 April 2013
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    04/03/13  DAS  6.50
     *      - Created.
     *
700a *    07/21/15  DAS  7.00
     *      - Revised allowAlcBld to be 1 digit number, so it can
     *        take a value of 2 to allow closing without verification.
     *
730a *    04/02/19  DAS/LMC  7.30
     *      - Added TBType and TBProc
     *      - Added allowAlcBld checks to ensure truck is defined
     *        and TBProcess is defined.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
USFaA*    07/21/15  DAS  USFa
     *      - Revised to set allowAlcBld to 2 instead of 1 in order
     *        to bypass the verification screen.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtesum    if   e           k disk
730aAFrtehed    if   e           k disk
     Fordh3     if   e           k disk
     Fordh4     if   e           k disk    rename(ohrec:ohrec4)
620aAFordh10    if   e           k disk    prefix(oh_)
     Fordhm2    if   e           k disk
     Fcrossdk1  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chkiuse
730aA /copy qcopysrc,p.exrtehed
730aA /copy qcopysrc,p.getfeat

510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
510   /copy qcopysrc,id#packers
USFA  /copy qcopysrc,id#usfcorp

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

700aDD*allowAlcBld     s               n
700aMD allowAlcBld     s              1  0
     D allowText       s             50
     D client          s             10
     D clientloc       s             10
     D cube            s                   like(rsordc)
     D hasPrePick      s               n
     D inUse           s               n
     D isPrePick       s               n
     D iuCmd           s              8
     D iuRtn           s              8
     D iuFlag          s              1  0
     D iuSubFlag       s              1  0
     D iuText10        s             10
     D iuText30        s             30
     D openPrePick     s               n
     D pieces          s                   like(rsordp)
     D shipNbr         s             11
     D weight          s                   like(rsordw)
     D xdockPO         s                   like(cdpo)
730aAD TBProcess       s              1
730aAD TBText10        s             10
730aAD TBText30        s             30
730aAD $gfCmd          s              8
730aAD $gfFeature      s              1
730aAD $gfLight        s              1
730aAD $gfTBType       s              1
730aAD $gfWhse         s              3p 0

     *----------------------------------------------------------------
     *  Misc Data Structure
     *----------------------------------------------------------------

     *  Shipment number from Miscellaneous field
     D                 ds
     D  hmmsc1                 1     40
     D  hmmshp                 4     14

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
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pRtId
     c                   parm                    pRte
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get information

730aA   exsr GetRoute;
        exsr GetInUse;
        exsr GetCubeWgtPcs;
        exsr GetPrePick;
        exsr GetXDockPO;
730aA   exsr GetTBProcess;

        // See if allowed to Alloc/Bld based on information.

        select;
730aA     when rhtruk = '';
730aA       allowAlcBld = 0;
730aA       allowText = 'Aloc & Bld not allowed - '
730aA                 + 'No truck assigned';
          when openPrePick;
700aD       //allowAlcBld = false;
700aM       allowAlcBld = 0;
            allowText = 'Aloc & Bld not allowed - '
                      + 'PrePick Route ('
                      + %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
                      + ') not Printed';
          when inUse;
700aD       //allowAlcBld = false;
700aM       allowAlcBld = 0;
            allowText = 'Allocate & Build not allowed - '
                      + 'Route In-Use';
730aA     when $gfTBType = 'B' and TBProcess = ' ';
730aA       allowAlcBld = 0;
730aA       allowText = 'Allocate & Build not allowed - '
730aA                 + 'Set Process Method';
          other;
700aD       //allowAlcBld = true;
700aM       allowAlcBld = 1;
USFaA       if client = usfcorp;
USFaA         allowAlcBld = 2;
USFaA       endif;
            allowText = 'Allocate - Build';
        endsl;

        // Build JSON string to return

        pOutStr = '{'
700aM           +  '"alwaloc":'   + %char(allowAlcBld) + ','
                +  '"alwtxt":"'   + %trimr(allowText) + '",'
                +  '"cube":"'   + %trim(%editc(cube:'A')) + '",'
                +  '"wgt":"'   + %trim(%editc(weight:'A')) + '",'
                +  '"pcs":"'   + %trim(%editc(pieces:'A')) + '",'
                +  '"ispre":'   + isPrePick + ','
                +  '"haspre":'   + hasPrePick + ','
                +  '"opnpre":'   + openPrePick + ','
                +  '"iu":'   + inUse + ','
                +  '"iutxt":"'   + %trimr(iutext10) + '",'
730aA           +  '"TBType":"'   + $gfTBType + '",'
730aA           +  '"TBProc":"'   + TBProcess + '",'
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

     *----------------------------------------------------------------
     *  GetCubeWgtPcs   Get cube, weight and pieces
     *----------------------------------------------------------------

      /free
       begsr GetCubeWgtPcs;

         cube = 0;
         weight = 0;
         pieces = 0;

         setll (pWhse: pRtId) rtesum;

         dow forever = forever;

           reade (pWhse: pRtId) rtesum;
           if %eof(rtesum);
             leave;
           endif;

           cube   += rsordc;
           weight += rsordw;
           pieces += rsordp;

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
     *  GetPrePick   Get PrePick info
     *----------------------------------------------------------------

      /free
       begsr GetPrePick;

         isPrePick = false;
         hasPrePick = false;
         openPrePick = false;

         setll (pWhse: pRtId) ordh4;

         dow forever = forever;

           reade (pWhse: pRtId) ordh4;
           if %eof(ordh4);
             leavesr;
           endif;

           // Get out if sent route is a PrePick route

           if %subst(ohmisc:17:1) = 'Y';
             isPrePick = true;
             leavesr;
           endif;

           // Look for PrePick items on route

           setll (ohwhse: ohcord) ordh10;

           dow forever = forever;

             reade (ohwhse: ohcord) ordh10;
             if %eof(ordh10);
               leave;
             endif;

             if %subst(oh_ohmisc:17:1) <> 'Y';
               iter;
             endif;

             // Item associated with a PrePick order

             hasPrePick = true;

             // See if PrePick route is only Open or Built.

             if prte = oh_rhrte and oh_rhstat < '4';
               openPrePick = true;
               leavesr;
             endif;

           enddo;

         enddo;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  GetRoute     Get RTEHED record
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr GetRoute;

         chain (pWhse: pRtId) rtehed;
         if not %found(rtehed);
           clear rhrec;
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
730aA*----------------------------------------------------------------
730aA*  GetTBProcess Get TruckBuilder Process flag
730aA*----------------------------------------------------------------

      /free
       begsr GetTBProcess;

         // Get Truck Builder Process Feature
         //   S=Standard, E=Advanced/Enhanced, B=Both

         monitor;
           $gfCmd = '*GET';
           $gfWhse = pWhse;
           GetFeat ($gfCmd: $gfwhse: $gfFeature: $gfLight: $gfTBType);
         on-error;
           // Default to Standard
           $gfTBType = 'S';
           return;
         endmon;

         TBProcess = $gfTBType;

         // For Both, see if TBProcess is defined for Route.
         // If not, cannot Allocate

         If $gfTBType = 'B';
           monitor;
             exWhse = pWhse;
             EXRTEHED('*GET': exRtnCode: exRtnMsg:
                      exWhse: pRtId: TBProcess);
           on-error;
             exRtnCode = '*ERROR';
             TBProcess = '';
             TBText10 = 'EXRTEHED NF';
             TBText30 = 'Error calling EXRTEHED program';
           endmon;
         endif;

       endsr;
      /end-free
