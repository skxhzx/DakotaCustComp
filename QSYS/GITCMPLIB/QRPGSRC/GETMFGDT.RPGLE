      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETMFGDT   Get Manufactured Date for Original License
     *  16 May 2016
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700 A*    05/16/16  LMC  7.00
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

      /copy qcopysrc,p.drilcnsi
      /COPY *libl/qcopysrc,c#licinfo
     D savever#        s                   like($lnver#)

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
     D  pOLcns         s             15
     D  pMfgdt         s              8  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pOLcns      Original License
     *
     *    Returned Parameters
     *      pMfgdt     Return Manufactured Date
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pOLcns
     C                   parm                    pMfgdt

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMfgdt = 0;

        // Convert fields to uppercase

        pOlcns = %xlate(xlower: xupper: pOLcns);
        exsr getlicinfo;

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
     *  GetLicinfo     Get Licinfo Record
     *----------------------------------------------------------------

      /free
       begsr GetLicinfo;

        exsr clr$licinfo;
        $lnwhse  = pwhse;
        $lnlcns  = pOlcns;
        $lnseq = 1;

        $dridata = $licinfo;
        $dridata2 = $licinfo2;

        driLicinfo('%GET': $pprogram: $drireturn: $drimessage:
                 $dridata: $dridata2);
        $licinfo = $dridata;
        $licinfo2 = $dridata2;

        if $LNMFGFLAG = 'Y';
          pMfgdt = $lnmfgdate;
        endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   endsr


     O*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*----------------------------------------------------------------
