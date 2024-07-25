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
     *  R17101       PO Receiving - Received Weights - CVTBAR UCI
     *  27 December 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    12/27/16  LMC  7.00
     *      - Created.
710aA*    03/09/17  LMC  7.10a
     *      - fix - Decimal Date error occurring when the UCI field
     *       is not a gs1 barcode. Conditioning the loading of the
     *       $barcode/$barcode2 on a successful return of gs1 barcode
     *       information from CVTBAR.
740aA*    05/26/20  LMC  7.40a
     *      - Enh - Get vendor number in order to pass to cvtbar for
     *       barcode definition.
740bA*    08/25/20  LMC  7.40b
     *      - Enh - If po is not found in open files, check po history
     *       files.
750aA*    08/30/20  LMC  7.50a
     *      - Enh - Initialize Date fields if the sent field is not
     *       On.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBaA*    03/09/17  LMC  ICBa
     *      - Revised program to load Lot from parm sent in.
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pUCI        UCI to convert
     *      pPO         Purchase Order
     *      pwhse       Warehouse
710aA*      pLcns       License
710aA*      pLot        Lot
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
     * Client ID
     *----------------------------------------------------------------
ICBaA /COPY QCOPYSRC,ID#ICB
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

740aAD phrec         E Ds                  Extname(pohdr)
740abD phhrec        E Ds                  Extname(pohhdr)
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
     D pWhse           s              3p 0
710aAD pLcns           s             15
710aAD pLot            s             30
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
     c                   parm                    pWhse
710aAc                   parm                    pLcns
710aAc                   parm                    pLot
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
740aA   exec sql select * into :phrec
740aA        from pohdr
740aA        where phwhse = :pWhse
740aA          and phpo   = :pPO;

        If sqlstt <> sqlSuccess;
740bA     exec sql select * into :phhrec
740bA          from pohhdr
740bA          where phhwhs = :pWhse
740bA            and phhpo   = :pPO;
740bA     If sqlstt =  sqlSuccess;
740bA       $cbven = phhven;
740bA     endif;
740bA   else;
740bM     $cbven = phven;
        endif;

        // Decipher UCI

        cvtbar('*ALL': pUCI:
           $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740aM      $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: pwhse:
740aA            $cbkilolbsSent: $cbitem);
710aA   if $CBRTN <> '*INVALID';
          $barcode = $cvtdata;
          $barcode2 = $cvtdata2;
710aA   endif;

750aA   if not $bcProdDSent;
750aA     $bcProdd = 0;
750aA   endif;
750aA   if not $bcPackDSent;
750aA     $bcPackd = 0;
750aA   endif;
750aA   if not $bcSlbyDSent;
750aA     $bcSlbyd = 0;
750aA   endif;
750aA   if not $bcExpDSent;
750aA     $bcexpd = 0;
750aA   endif;
        // only do the date conversion if the UCI was gs1 format
        if $bcGtinSent;
          // convert dates into mmddyy format.
          if $bcProdDSent and $bcProdD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcProdD);
            cvtdte($cvtdt);
            $bcProdD = $cvd6o;
          else;
            $bcProdD = 0;
          endif;
          if $bcPackDSent and $bcPackD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcPackD);
            cvtdte($cvtdt);
            $bcPackD = $cvd6o;
          else;
            $bcPackD = 0;
          endif;
          if $bcSlByDSent and $bcSlByD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcSlByD);
            cvtdte($cvtdt);
            $bcSlByD = $cvd6o;
          else;
            $bcSlByD = 0;
          endif;
          if $bcExpDSent and $bcExpD <> 0;
            $cvcmd = '*YMDMDY';
            $cvd6i = %char($bcExpD);
            cvtdte($cvtdt);
            $bcExpD = $cvd6o;
          else;
            $bcExpD = 0;
          endif;
        endif;
ICBaA   select;
ICBaA     when client = icb;
ICBaA     $bclot = plot;
ICBaA   endsl;
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
