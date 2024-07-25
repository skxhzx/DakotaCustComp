      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R17100       PO Receiving - Received Weights - CVTBAR UCI
     *  15 January 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    01/15/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pUCI        UCI to convert
     *      pPO         Purchase Order
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtbar
      /copy qcopysrc,p.cvtdte
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pUCI            s            100
     D pPo             s              9
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pUCI
     c                   parm                    pPO
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';

        // Decipher UCI

        cvtbar('*ALL': pUCI:
           $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
           $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2);
        $barcode = $cvtdata;
        $barcode2 = $cvtdata2;

        // only do the date conversion if the UCI was gs1 format
        if $bcGtinSent;
          // convert dates into mmddyy format.
          if $bcProdDSent and $bcProdD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcProdD);
            cvtdte($cvtdt);
            $bcProdD = $cvd6o;
          endif;
          if $bcPackDSent and $bcPackD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcPackD);
            cvtdte($cvtdt);
            $bcPackD = $cvd6o;
          endif;
          if $bcSlByDSent and $bcSlByD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcSlByD);
            cvtdte($cvtdt);
            $bcSlByD = $cvd6o;
          endif;
          if $bcExpDSent and $bcExpD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcExpD);
            cvtdte($cvtdt);
            $bcExpD = $cvd6o;
          endif;
        endif;
        // Now load up json with info from UCI converted

         // Put together JSON string

         pOutStr = '{'
                +  '"GTIN":"'  + %trimr($bcGtin) + '",'
                +  '"Lot":"'  + %trimr($bcLot) + '",'
                +  '"ProdDt":"'  + %trim(%editc($bcProdD:'Y')) + '",'
                +  '"PackDt":"'  + %trim(%editc($bcPackD:'Y')) + '",'
                +  '"SellDt":"'  + %trim(%editc($bcSlByD:'Y')) + '",'
                +  '"ExprDt":"'  + %trim(%editc($bcExpD:'Y')) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *
     *
