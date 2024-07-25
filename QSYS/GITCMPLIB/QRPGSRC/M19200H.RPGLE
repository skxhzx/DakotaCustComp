      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M19200H  Get CW totals cw entry header JSON info
     *  12 January 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700  *    01/12/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirhold   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  pirhold structures
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDCT

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  psessid        s             40
     D  pWhse          s              3p 0
     D  pPo            s              9
     D  pPOSeq         s              5  0
     D  pPoItem        s             15
     D  pPOqty1        s              5  0
     D  pPOqty2        s              5  0
     D  pPOqty3        s              5  0
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D cCmd            s             10    inz(' ')
     D cTrn            s              7p 0 inz(0)
     D chrOutStr       s            512
     D chrSessId       s             40
     D chrUser         s             10
     D chrRtid         s              5
     D dpcombo         s             20
     D ttlCnt          s              5  0
     D ttlWgt          s             13  2
     D hvskp           s               n
     D ihrng           s             13  2
     D ihvar           s             13  2
     D ilrng           s             13  2
     D ilvar           s             13  2
     D lvskp           s               n
     D prg1c           s              4  3
     D prg2c           s              4  3
     D pieces          s              6  0
     D rngText         s             30
     D cnttxtmsg       s             60
     D vartxtmsg       s             60

     D extwg2          s                   like(exwgt)
     D extwg3          s                   like(exwgt)
     D exwgt           s              9  2
     D hirng           s              9  2
     D hivar           s              9  2
     D lwrng           s              9  2
     D lwvar           s              9  2
     D olywg2          s                   like(itswgt)
     D olywg3          s                   like(itswgt)

     D pokey           s             50
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opuci                 36     36
     D  optend               117    117

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessid      Session id
     *      pWhse        Warehouse
     *      pPO          PO#
     *      pPOSeq       PO Seq#
     *      pPOItem      PO Item
     *      pPOqty1      PO received qty1
     *      pPOqty2      PO received qty2
     *      pPOqty3      PO received qty3
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    pPOqty1
     c                   parm                    pPOqty2
     c                   parm                    pPOqty3
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pieces = ppoqty1 + ppoqty2 + ppoqty3;

         // Start JSON string

         pOutStr = '{';

        // Add CW Total info to string

        hotype = 'PODTLCT';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        chain (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          pirhldctds = hodata;
        else;
          svcw# = 0;
          svtcw = 0;
          cntflag = '1';
        endif;

        // create cnttxt for string
        select;

          when cntflag = '1';
            cnttxtmsg = 'No Weights Entered';
          when cntflag = '2';
            cnttxtmsg = 'Warning: Missing Weights ';
          when cntflag = '3';
            cnttxtmsg = 'Count warning has been overriden';
          other;
            cnttxtmsg = ' ';
        endsl;

         pOutStr = %trimr(pOutStr)
                 +  '"cntflg":"' + cntflag + '",'
                 +  '"cnttxt":"' + %trimr(cnttxtmsg) + '",';

        // Add CW variance flag to string

         pOutStr = %trimr(pOutStr)
                 +  '"varflg":"' + varflag + '",';

         // Add total variances to string

         exsr GetVariance;
         select;

           when varflag = '2';
             vartxtmsg = 'Warning: Total Weight is outside Total Range ' +
                         rngText;
           when varflag = '3';
             vartxtmsg = 'Total Weight has been overriden';
           other;
             vartxtmsg = ' ';
         endsl;
         pOutStr = %trimr(pOutStr)
                 +  '"vartxt":"' + %trimr(vartxtmsg) + '",'
                 +  '"lowvar":"' + %char(lwrng) + '",'
                 +  '"hivar":"' + %char(hirng) + '",'
                 +  '"rngtxt":"' + %trimr(rngText) + '",';

         // Add picked pieces to string

         pOutStr = %trimr(pOutStr)
                 +  '"pcs":"' + %char(pieces) + '",';

         // Add total count and weight to string
         pOutStr = %trimr(pOutStr)
                 +  '"ttlcnt":"' + %char(svcw#) + '",'
                 +  '"ttlwgt":"' + %char(svtcw) + '",';

         // Add total variances to string

         //exsr GetVariance;
         pOutStr = %trimr(pOutStr)
                 +  '"lowttlvar":"' + %char(lwrng) + '",'
                 +  '"hittlvar":"' + %char(hirng) + '",'
                 +  '"ttlrngtxt":"' + %trimr(rngText) + '"';

         // Close JSON string

         pOutStr = %trimr(pOutStr)
                 +  '}';

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
     *  GetVariance   Get variances (based on code from CW122)
     *----------------------------------------------------------------

      /free
       begsr GetVariance;

         // Get options

         chain (0: '*SYSTEM') options;
         if not %found(options);
           oprg1c = 0;
           oprg2c = 0;
         endif;

         // Get range

         lvskp = *off;
         hvskp = *off;
         prg1c = 0;
         prg2c = 0;
         ilvar = 0;
         ihvar = 0;
         ilrng = 0;
         ihrng = 0;

         // get item

         chain(n) (pwhse: ppoitem) piritem;
         if %found(piritem);
         else;
           itumq2 = *zeros;
           itumq3 = *zeros;
         endif;
         // convert weight for break-down 2 qty.
         if itumq2 > *zeros;
           eval(h) olywg2 = itswgt/itumq2;
         else;
           olywg2 = *zeros;
         endif;

         // convert weight for break-down 3 qty.
         if itumq3 > *zeros;
           eval(h) olywg3 = itswgt/itumq3;
         else;
           olywg3 = *zeros;
         endif;

         // Extend weight for case qty.
         exwgt =  ppoqty1 * itswgt;

         // Extend weight for break-down 2 qty.
         if ppoqty2 > *zeros;
           if olywg2 > *zeros;
             extwg2 = ppoqty2 * olywg2;
           else;
             extwg2 = *zeros;
           endif;
           exwgt = exwgt + extwg2;
         endif;

         // Extend weight for breadk-down 3 qty.
         if ppoqty3 > *zeros;
           if olywg3 > *zeros;
             extwg3 = ppoqty3 * olywg3;
           else;
             extwg3 = *zeros;
           endif;
           exwgt = exwgt + extwg3;
         endif;

         // See if there is an item variance percentage

         chain (pwhse: ppoitem) itemmsc;

         if %found(itemmsc);

           if imrg1c > 0;
             prg1c = imrg1c / 100;
             if imrg1c = 99;
               lvskp = *on;
             endif;
           endif;

           if imrg2c > 0;
             prg2c = imrg2c / 100;
             if imrg2c = 99;
               hvskp = *on;
             endif;
           endif;

         endif;

         // If no item variance percentage, get system variance percentage.

         if prg1c = 0;
           if oprg1c > 0;
             prg1c = oprg1c / 100;
           endif;
         endif;

         if prg2c = 0;
           if oprg2c > 0;
             prg2c = oprg2c / 100;
           endif;
         endif;

         // Calculate weight variance

         if not lvskp;
           if prg1c = 0;
             lvskp = *on;
           else;
             //ilvar = (pieces * lbuwgt) * prg1c;
             //ilrng = (pieces * lbuwgt) - ilvar;
             lwvar = exwgt * prg1c;
             ilvar = itswgt * prg1c;
             lwrng = exwgt - lwvar;
             ilrng = itswgt - ilvar;
           endif;
         endif;

         if not hvskp;
           if prg2c = 0;
             hvskp = *on;
           else;
             //ihvar = (pieces * lbuwgt) * prg2c;
             //ihrng = (pieces * lbuwgt) + ihvar;
             hivar = exwgt * prg2c;
             ihvar = itswgt * prg2c;
             hirng = exwgt + hivar;
             ihrng = itswgt + ihvar;
           endif;
         endif;

         // Create range text

         select;
           when lvskp and hvskp;
             ilrng = 0;
             ihrng = 0;
             rngText = '0 - Maximum';
           when lvskp;
             ilrng = 0;
             rngText = '0 - ' + %char(ihrng);
           when hvskp;
             ihrng = 0;
             rngText = %char(ilrng) + ' - Maximum';
           other;
             rngText = %char(lwrng) + ' - ' + %char(hirng);
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetTotalWeight  Get total weight
     *----------------------------------------------------------------

      /free
       begsr GetTotalWeight;

         ttlCnt = 0;
         ttlWgt = 0;

         ttlCnt = svcw#;
         ttlWgt = svtcw;



       endsr;
      /end-free
