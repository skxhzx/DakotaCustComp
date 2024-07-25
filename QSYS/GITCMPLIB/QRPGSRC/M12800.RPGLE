      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  RH182
     *  M12800   Route Sub entry JSON info
     *  08 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/08/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordh      if   e           k disk
     Fordd      if   e           k disk
     Frtehed    if   e           k disk
     Foptions   if   e           k disk
     Fworklbl8  if   e           k disk

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

510bA /copy qcopysrc,id#citylin
FFC A /copy qcopysrc,id#fischer
GFCaA /copy qcopysrc,id#glazier
520bA /copy qcopysrc,id#ifd
KFSaA /copy qcopysrc,id#kfs
520dA /copy qcopysrc,id#palmer

     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------

      /copy qcopysrc,p.driitem
      /COPY *libl/qcopysrc,c#item
     D savever#        s                   like($itver#)

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D allowSubs       s               n
     D allowSubsTxt    s             50
     D rteId           s              5
     D rteSts          s              1
     D cust            s             11  0
     D pltId           s              7  0
     D itemLkup        s             10
     D dftItem         s             15
     D dftSeq          s              5  0
     D slotLkup        s             10
     D blank15         s             15
     D rtnCode         s              8
     D rtnMessage      s             60

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
520cA* OHMISC data structure
     *----------------------------------------------------------------

520cAD dsmisc          DS
520cAD  dssubf                10     10
GFCcA /copy qcopysrc,ohmisc_gfc

520cA*----------------------------------------------------------------
520cA*  *FEATURE  -  PIR Feature options.
520cA*----------------------------------------------------------------
520cA*
520cA* Fields
520cA*
520cA*    OPFEAT  -  PIR Installed feature.
520cA*
520cA* Data structure
520cA*
520cAD opfdta          DS
520cAD  opfeat                 1      1
520cAD  opfend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getitmsb

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pOrd           s              7p 0
     D  pSeq           s              5p 0
     D  pItem          s             15
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pOrd         Order number
     *      pSeq         Order detail seq#
     *      pItem        Item
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pOrd
     c                   parm                    pSeq
     c                   parm                    pItem
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

         allowSubs = *on;
         allowSubsTxt = '';

        // Convert fields to uppercase

         pItem = %xlate(xlower: xupper: pItem);

        // Get order header
        exsr GetORDH;

        // Get substitute option

        exsr GetSubOpt;

        // Get route header
        exsr GetRTEHED;

        // Get Pallet Id
        exsr GetPltId;

        // Get default seq#
        exsr GetDftSeq;

        // Get item lookup type
        exsr GetItemLookup;

        // Get slot lookup type
        exsr GetSlotLookup;

        // Build JSON string to return

        pOutStr = '{'
                +  '"alwsub":'      + allowSubs + ','
                +  '"alwsubtxt":"'  + %trim(allowSubsTxt) + '",'
                +  '"rteid":"'      + %trim(rteId) + '",'
                +  '"rtests":"'     + %trim(rteSts) + '",'
                +  '"cust":"'      + %char(cust) + '",'
                +  '"pltid":"'      + %char(pltId) + '",'
                +  '"dftseq":"'     + %char(dftSeq) + '",'
                +  '"dftitem":"'    + %trim(dftItem) + '",'
                +  '"itemlkup":"'   + %trim(itemLkup) + '",'
                +  '"slotlkup":"'   + %trim(slotLkup) + '"';

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
     *  GetDftSeq   Get default seq#
     *----------------------------------------------------------------

      /free
       begsr GetDftSeq;

         dftSeq = 0;

         // Don't need if subs not allowed

         if not allowSubs;
           leavesr;
         endif;

         // Some clients leave gaps in their seq #'s

         if client = cityline
           or client = ifd
           or client = fischerFoods;
             dftSeq = pSeq + 1;
             leavesr;
         endif;

         // For everyone else, create seq # at end.

         setgt (pWhse: pOrd) ordd;
         readpe (pWhse: pOrd) ordd;

         if not %eof(ordd);
           if odseq = 99999;
             dftSeq = odseq;
           else;
             dftSeq = odseq + 1;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetItemLookup  Get item lookup type
     *----------------------------------------------------------------

      /free
       begsr GetItemLookup;

         itemLkup = 'any';
         dftItem = '';

         // Don't need if subs not allowed

         if not allowSubs;
           leavesr;
         endif;

         // Get default for item

         getitemsub ('*GETLIMIT': pWhse: pItem: ohcust:
                     dftItem: rtnCode: rtnMessage);

         select;
          when rtnCode = '*CUST';
            itemLkup = 'limitcust';
          when rtnCode = '*ITEM';
            itemLkup = 'limititem';
          other;
            itemLkup = 'any';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetORDH     Get ORDH record
     *----------------------------------------------------------------

      /free
       begsr GetORDH;

         rteId = '';
         cust = 0;

         chain (pWhse: pOrd) ordh;
         if not %found(ordh);
           clear ohrec;
           allowSubs = *off;
           allowSubsTxt = 'Sub not allowed - '
                        + 'Order not found '
                        + '(' + %char(pWhse) + '/' + %char(pOrd) + ')';
           leavesr;
         endif;

         // Set return variable

         rteId = ohrte;
         cust = ohcust;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPltId    Get pallet id
     *----------------------------------------------------------------

      /free
       begsr GetPltId;

         pltId = 0;

         // Don't need if subs not allowed

         if not allowSubs;
           leavesr;
         endif;

         setll (pWhse: rteId: pItem) worklbl8;

         dow forever = forever;
           reade (pWhse: rteId: pItem) worklbl8;
           if %eof(worklbl8);
             leave;
           endif;

           if lword <> ohord;
             iter;
           endif;

           if lwgen = 1
            or (lwgen = 2 and lwctr# <> 0);
              pltId = lwpal#;
              leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRTEHED   Get RTEHED record
     *----------------------------------------------------------------

      /free
       begsr GetRTEHED;

         rteSts = '';

         // Don't need if subs not allowed

         if not allowSubs;
           leavesr;
         endif;

         // Otherwise get record

         chain (pWhse: rteId) rtehed;
         if not %found(rtehed);
           clear rhrec;
           allowSubs = *off;
           allowSubsTxt = 'Sub not allowed - '
                        + 'Route not found '
                        + '(' + %char(pWhse) + '/' + %trim(rteId) + ')';
           leavesr;
         endif;

         // Set return variable

         rteSts = rhstat;

         // Only allow subs for Open, Built and Printed routes

         if rhstat > '4';
           allowSubs = *off;
           allowSubsTxt = 'Sub not allowed - '
                        + 'Route not open/built/printed '
                        + '(' + rhstat + ')';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSlotLookup  Get slot lookup type
     *----------------------------------------------------------------

      /free
       begsr GetSlotLookup;

         slotLkup = 'none';

         // Don't need if subs not allowed

         if not allowSubs;
           leavesr;
         endif;

         // Don't need if route is not built or printed

         if rteSts <> '3' and rteSts <> '4';
           leavesr;
         endif;

         // Otherwise, set slot lookup type based on feature

         chain (pWhse: '*FEATURE') options;
         if not %found(options);
           opfeat = '2';
         else;
           opfdta = opdata;
         endif;

         // If Feature is outbound only,
         //   Then limit slots to same department as sub item.
         //   Otherwise, limit slots to ones that contain sub item.

         if opfeat = '3';
           slotLkup = 'limitdept';
         else;
           slotLkup = 'limititem';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSubOpt   Get Subtitution option
     *----------------------------------------------------------------

      /free
       begsr GetSubOpt;

         // Don't need if subs not allowed (because ordh not found)

         if not allowSubs;
           leavesr;
         endif;

         // First do standard check

         getitemsub ('*CHKALLOW': pWhse: pItem: ohcust:
                     blank15: rtnCode: rtnMessage);

         if rtnCode = '*ERROR';
           allowSubs = *off;
           allowSubsTxt = rtnMessage;
           leavesr;
         endif;

         // Then do custom checks

         if client = Glazier;
           gfcmsc_base = ohmisc;
         else;
           dsmisc = ohmisc;
         endif;

         if (client = glazier and gfcmsc_sub <> 'Y')
           or (client = palmer and dssubf <> 'Y')
           or (client = kellys and dssubf <> 'Y')
           or (client = ifd and dssubf <> 'Y');
             allowSubs = *off;
             allowSubsTxt = 'Sub not allowed by Host '
                        + '(' + %char(pWhse) + '/' + %char(pOrd) + ')';
             leavesr;
         endif;

       endsr;
      /end-free
