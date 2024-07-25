      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTBTYPE    Get TruckBuilder type
     *  05 August 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    09/05/18  DAS  7.20
     *      - Created.
     *
720aA*    09/13/18  DAS  7.20a
     *     - Revised default to 'S' instead of data area value
     *       because any route using Enhanced should have a
     *       RTEHEDEX record.
     *
720bA*    10/20/18  DAS  7.20b
     *     - Added client logic
     *
730aA*    04/03/18  DAS  7.30a
     *     - Revised to look at *FEATURE for default.
     *     - No longer using data area DRAGDROP2.
     *     - Removed old code for readability.
     *
750aA*    02/21/21  DAS  7.50a
     *     - If RTEHEDEXA rec doesn't exist and Route is not open,
     *       default to 'S' instead of *FEATURE.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Aderson DuBose
     *
ADCaA*    10/20/18  DAS  ADCa
     *      - Force to use Enhanced. At this time they are not using
     *        the RTEHEDEXA file.
     *
     *  Client Custom Revisions: Marques
     *
MQSaA*    11/17/18  DAS  MQSa
     *      - Force to use Enhanced. At this time they are not using
     *        the RTEHEDEXA file.
     *    04/03/19  DAS  MSQb
     *      - Removed hard coding.
     *      - Using *FEATURE instead.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

750aAFrtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

ADCaA /copy qcopysrc,id#adc
MQSaA /copy qcopysrc,id#mqs

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

720bAD client          s             10
720bAD clientloc       s             10
     D usingDD2        s               n   dtaara(dragdrop2)
     D exRtnCode       s             10
     D exRtnMsg        s             60
     D exWhse          s              3s 0
730aAD $gfCmd          s              8
730aAD $gfFeature      s              1
730aAD $gfLight        s              1
730aAD $gfTBType       s              1
730aAD $gfWhse         s              3p 0

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.getclien
     d/copy qcopysrc,p.exrtehed
720jAd/copy qcopysrc,p.gettbtyp
730aA /copy qcopysrc,p.getfeat

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    $pwhse  - Warehouse
     *    $prtid  - Route Id (optional)
     *
     *   Output
     *
     *    $ptype  -  S=Standard, E=Enhanced
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptype            1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

720bA  getclient(client: clientLoc);

730aA  // Get default Truck Builder Process Feature
730aA  //   S=Standard (default), E=Advanced/Enhanced, B=Both
730aA
730aA  monitor;
730aA    $gfCmd = '*GET';
730aA    $gfWhse = $pWhse;
730aA    GetFeat ($gfCmd: $gfwhse: $gfFeature: $gfLight: $gfTBType);
730aA  on-error;
730aA    $gfTBType = 'S';
730aA  endmon;

730aA  $ptype = $gfTBType;

ADCaA  // For Dubose, always used Enhanced
ADCaA
ADCaA  if client = adc;
ADCaA    $ptype = 'E';
ADCaA    return;
ADCaA  endif;

       // See if there is an override for the route
750aA  // If RTEHEDEXA doesn't exist and stat=1, then set to 'S'.

       if $prtid <> '';

730aA    monitor;
           exWhse = $pwhse;
           exrtehed('*GET': exRtnCode: exRtnMsg: exWhse: $prtid: rhatbtype);
           if exRtnCode = '*OK' and rhatbtype <> '';
             $ptype = rhatbtype;
750aA      else;
750aA        chain ($pwhse: $prtid) rtehed;
750aA        if %found(rtehed) and rhstat <> '1';
750aA           $ptype = 'S';
750aA        endif;
           endif;
730aA    on-error;
730aA    endmon;

       endif;

       return;

      /end-free


