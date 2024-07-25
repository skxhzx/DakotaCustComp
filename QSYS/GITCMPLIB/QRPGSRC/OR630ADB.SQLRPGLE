      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     * Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OR630ADB  Create ADB Pallets
     *  10 April 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
720 A*    04/10/18  KDE  7.20
     *      - Created.
     *
720aA*    05/10/18  KDE  7.20a
     *      - Generate SSCC18 numbers using PLTSUM3 which orders by
     *        Compartment and reverse order of Unloading Sequence
     *
720bA*    09/10/18  KDE  7.20b
     *      - Generate SSCC18 numbers with zero prefix when customer
     *        prefix not defined. Runs code whether using SSCC18 or not
     *
720cA*    11/17/18  KDE  7.20c
     *      - Fix:  Ignore Pallet type B-Bulk records in pltsum
     *
760aA*    09/15/22  KDE  7.60a
     *      - Fix:  Instead of deleting and recreating pallet id records
     *        in pltmisc just skip if already exists
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fgs1whspre uf   e           k disk
720aDf*pltsum1   if   e           k disk
720aMfpltsum3   if   e           k disk
     fpltmisc   uf a e           k disk

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     d pReturn         s             10
     d pPallet#        s              5  0

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d genADBPLT       pr

     d calcsscc18      pr            18

     d getAdbPlt5      pr                  extpgm('GETADBPLT5')
     d  iPallet#                      5  0
     d  iReturn                      10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRteId      Route ID
     *
     *----------------------------------------------------------------

     d OR630ADB        pr                  extpgm('OR630ADB')
     d  pWhse                         3  0
     d  pRteId                        5

     d OR630ADB        pi
     d  pWhse                         3  0
     d  pRteId                        5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       // Loop Pallet Summary file for passed Warehouse and Route ID

       setll (pWhse:pRteId) pltsum3;
       reade (pWhse:pRteId) pltsum3;

       dow not %eof(pltsum3);
720cD     //if psType='P' or psType='B';
720cA     if psType='P';
             genADBPlt();
          endif;
          reade (pWhse:pRteId) pltsum3;
       enddo;

       return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Subprocedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  genADBPLT   Generate ADB Pallet
     *----------------------------------------------------------------

     p genADBPLT       b
     d genADBPLT       pi

     * Local Variables

      /free

        // get ADB Pallet number from data area PIRADBPLT5
760aA   // Moved inside if below if pallet not found in PLTMISC
760aD   //pPallet# = 0;
760aD   //pReturn = *blanks;
760aD   //getAdbPlt5(pPallet#:pReturn);

        // if not able to secure unique pallet id for sscc18 then return without adding
760aD   //if pReturn <> '*OK';
760aD   //   return;
760aD   //endif;

        // while this should never happen we will confirm
        // no pltmisc record exist for whse, pltid and code
760aD   //exec sql delete from pltmisc
760aD   //         where pmwhse=:pWhse and pmrtid=:pRteid
760aD   //           and pmplid=:psplid and pmcode='ADBPLT5';
760aA
760aA   chain (pWhse:pRteId:psplid:'ADBPLT5') pltmisc;

760aA   if not %found(pltmisc);

760aA     // Moved the getAdbPlt5 into this if so it would only
760aA     // get if one did not already exist.  Reason for this,
760aA     // the sub process adds a pallet sum "P" record and
760aA     // updates pltsum "O" record.  This process needs to
760aA     // add PLTMISC record so Truck Map will print correctly
760aA     // but no need to retrieve next number if already added
          // get ADB Pallet number from data area PIRADBPLT5
760aM     pPallet# = 0;
760aM     pReturn = *blanks;
760aM     getAdbPlt5(pPallet#:pReturn);

760aM     // if not able to secure unique pallet id for sscc18 then return without adding
760aM     if pReturn <> '*OK';
760aM        return;
760aM     endif;

          // write ADBPLT5 record to PLTMISC
          pmwhse = pWhse;
          pmrtid = pRteid;
          pmplid = psplid;
          pmcode = 'ADBPLT5';
          pmseq  = *zeros;
          pmValue= %editc(pPallet#:'X');
          pmAddts = %timestamp();
          pmaddjob = #job;
          pmaddusr = #user;
          pmaddnbr=#jobn;
          pmchgts=pmaddts;
          pmchgusr=#user;
          pmchgjob=#job;
          pmchgnbr=#jobn;
          write pmrec;
760aA   else;
760aA     unlock pltmisc;
760aA     // convert pmvalue back to pallet# so process below can do
760aA     // check digit if that pltmisc record is missing
760aA     monitor;
760aA       pPallet# = %dec(pmValue:5:0);
760aA     on-error;
760aA       return;
760aA     endmon;
760aA   endif;

        // while this should never happen we will confirm
        // no pltmisc record exist for whse, pltid and code
760aD   //exec sql delete from pltmisc
760aD   //         where pmwhse=:pWhse and pmrtid=:pRteid
760aD   //           and pmplid=:psplid and pmcode='ADBSSCC18';
760aA
760aA   chain (pWhse:pRteId:psplid:'ADBSSCC18') pltmisc;

760aA   if not %found(pltmisc);
          // write ADBPLT5 record to PLTMISC
          pmwhse = pWhse;
          pmrtid = pRteid;
          pmplid = psplid;
          pmcode = 'ADBSSCC18';
          pmseq  = *zeros;
          pmvalue = calcsscc18();
          pmAddts = %timestamp();
          pmaddjob = #job;
          pmaddusr = #user;
          pmaddnbr=#jobn;
          pmchgts=pmaddts;
          pmchgusr=#user;
          pmchgjob=#job;
          pmchgnbr=#jobn;
          write pmrec;
760aA   else;
760aA     unlock pltmisc;
760aA   endif;

      /end-free
     p genADBPLT       e

     *----------------------------------------------------------------
     *  calcsscc18  Calculate SSCC 18 barcode
     *----------------------------------------------------------------

     p calcsscc18      b
     d calcsscc18      pi            18

     * Local Variables
     d  chkdgt         s              1  0
     d  digitsSum      s              5  0
     d  instring       s             18
     d  lp             s              2  0

      /free

         // Build 18 character string.  Position 18 is 0 since it will
         // be passed in a check digit calculated.

         setll (pWhse) gs1whspre;
         reade (pWhse) gs1whspre;
720bA    if %eof(gs1whsPre) or not %equal(gs1whspre);
720bA       gpPckType = '1';
720bA       gpPreFix = '00000000000';
720bA    endif;
720bD    //if not %eof(gs1whspre);
            inString = gpPckType;
            instring = %trim(inString) + %trim(gpPreFix);
            if %len(%trim(inString)) < 12;
               dow %len(%trim(inString)) < 12;
                  inString = %trim(inString) + '0';
               enddo;
            endif;
            inString = %trim(inString) + %editc(pPallet#:'X') + '0';
720bD    //else;
            // no Prefix found for passed Warehouse
720bD    //   inString = '000000000000000000';
720bD    //   return inString;
720bD    //endif;

         lp = 1;
         dow lp < 19;
           // for odd number digits multiply number by 3 nd add to sum
           digitsSum = digitsSum + (%dec(%subst(inString:lp:1):1:0))*3;
           lp = lp + 1;
           // for even number digits simply add digit to sum
           digitsSum = digitsSum + %dec(%subst(inString:lp:1):1:0);
           lp = lp +1;
         enddo;
         chkDgt = %rem((10-%rem(digitsSum:10)-1):9)+1;
         inString = %subst(inString:1:17) + %char(chkDgt);

         return inString;

      /end-free

     p calcsscc18      e
