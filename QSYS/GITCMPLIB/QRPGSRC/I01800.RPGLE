      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  I01800   Order Detail JSON info
     *  09 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/09/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * NOTE: If the parms change on this program please update M11400.
     * M11400 also calls this program.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fordh      if   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

520bA /copy qcopysrc,id#ifd
520dA /copy qcopysrc,id#palmer
GFCaA /copy qcopysrc,id#glazier
KFSaA /copy qcopysrc,id#kfs

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
     D blank15         s             15
     D rtnCode         s              8
     D rtnMessage      s             60

     *----------------------------------------------------------------
520cA* OHMISC data structure
     *----------------------------------------------------------------

520cAD dsmisc          DS
520cAD  dssubf                10     10
GFCcA /copy qcopysrc,ohmisc_gfc

640cA*----------------------------------------------------------------
640cA*  *GENPICK -  General picking.
640cA*----------------------------------------------------------------
640cA*
640cA* Fields
640cA*
640cA*    OPERPT  -  Print exception (short) error report (Y,N).
640cA*    OPELBL  -  Print exception (short) labels (Y,N).
640cA*    OPRFWC  -  Using RF will call (Y,N).
640cA*    OPNRSC  -  Number of pallet sections (1-9).
640cA*    OPHPWC  -  Host pick Will Call (Y/N).
640cA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
640cA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
640cA*    OPEADJ  -  Close short labels without adjustment (Y,N).
640cA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
640cA*    OPGPK1  -  <Not Used / Available>
640cA*    OPGPK2  -  <Not Used / Available>
640cA*               task has been assigned. (Y/N)
640cA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
640cA*                 0=None. No replenishments are created.
640cA*                 1=Letdowns are created during Truck Builder
640cA*                   Pick/Print processing.
640cA*                 2=Priority Replenishments are created during
640cA*                   Truck Builder Pick/Print processing.
640cA*                 3=JIT Letdowns created when transaction is
640cA*                   checked out.
640cA*                 4=JIT Priority Replenishments created when
640cA*                   transaction is checked out.
640cA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
640cA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
640cA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
640cA*    OPRFSL  -  RF Pick Verify slot (Y/N)
640cA*    OPRBN1  -  Round robin printing compatable (Y/N)
640cA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
640cA*               1=Off
640cA*               2=By route
640cA*               3=By transaction
640cA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
640cA*
640cA* Data structure
640cA*
640cAD oppdta          ds
640cAD  operpt                 1      1
640cAD  opelbl                 2      2
640cAD  oprfwc                 3      3
640cAD  opnrsc                 4      4  0
640cAD  ophpwc                 5      5
640cAD  opmrga                 6      6
640cAD  opplsq                 7      7
640cAD  opeadj                 8      8
640cAD  opnopk                 9      9
640cAD  opgpk1                10     10
640cAD  opgpk2                11     11
640cAD  opjitr                12     12
640cAD  oppset                13     13
640cAD  oprfuc                14     14
640cAD  oprflc                15     15
640cAD  opusf1                16     16
640cAD  oprfsl                17     17
640cAD  oprbn1                18     18
640cAD  oprbn2                19     19
640cAD  opsubt                20     20
640cAD  oppend               117    117

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

        // Get order header
        exsr GetORDH;

        // Get substitute option

        exsr GetSubOpt;

        // Get route header
        exsr GetRTEHED;

        // Build JSON string to return

        pOutStr = '{'
                +  '"alwsub":'   + allowSubs + ','
                +  '"alwsubtxt":"'   + %trim(allowSubsTxt) + '"';

        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  GetORDH     Get ORDH record
     *----------------------------------------------------------------

      /free
       begsr GetORDH;

         rteId = '';

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
