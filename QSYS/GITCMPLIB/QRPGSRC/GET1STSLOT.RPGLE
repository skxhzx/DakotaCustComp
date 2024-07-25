      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GET1STSLOT Get the first slot for an item
     *  13 April 2016
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700 A*    04/13/16  LMC  7.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------

      /copy qcopysrc,p.drislot
      /COPY *libl/qcopysrc,c#slot
     D savever#        s                   like($slver#)

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D rtnCode         s              8
     D rtnMessage      s             60

     D $pcmd           s              8

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3  0
     D  pWhdp          s              5
     D  pItem          s             15
     D  pSldisp        s             12

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getitmsb

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pWhdp       Department
     *      pItem       Item
     *
     *    Returned Parameters
     *      pSldisp    Return first slot
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pWhdp
     C                   parm                    pItem
     C                   parm                    pSldisp

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pSldisp = '';

        // Convert fields to uppercase

        pItem = %xlate(xlower: xupper: pItem);
        exsr getslot;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSlot        Get first slot for Item
     *----------------------------------------------------------------

      /free
       begsr GetSlot;

        exsr clr$slot;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp  = pwhdp;
        $slitemu = *on;
        $slitem  = pitem;
        $slstatu = *on;
        $slstat = 'A';
        $slaislu = *on;
        $slpsequ = *on;
        $slrlvlu = *on;
        $slhandu = *on;
        $slprtyu = *on;
        $slexpdu = *on;
        $slentdu = *on;
        $slpicku = *on;

        $dridata = $slot;
        $dridata2 = $slot2;

        driSlot('%NXTITEM': $pprogram: $drireturn: $drimessage:
                 $dridata: $dridata2);
        $slot = $dridata;
        $slot2 = $dridata2;

        pSldisp = $sldisp;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     O*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*----------------------------------------------------------------
