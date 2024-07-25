      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSPOASNCL   Clean up POASN IFS files.
     *  10 August 2012
     *  Lynn McMahon
     *
     *  Revisions
     *
640 A*    08/10/12  LMC  6.40
     *      - Created.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs


     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D cmpdte          pr                  extpgm('CMPDTE')
     D  cmd                           8    const
     D  prg                          10    const
     D  whse                          3    const
     D  date                          8

     D getclient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

     D ifsrmvold       pr                  extpgm('IFSRMVOLD')
     D  dir                         640    const
     D  date                          8  0 const
     D  return                        8
     D  message                      60

     *----------------------------------------------------------------
     *  Key definitions


     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D iDated          s               d
     D iDateda         s             10

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
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
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
     D  optend               117    117

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pWhse           s              3
     D pWhse#          s              3  0

     D dDate           s              8

     D iDir            s            640
     D iDate           s              8  0
     D iReturn         s              8
     D iMessage        s             60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse   Warehouse
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
      /free
        *inlr = *on;

        // Convert warehouse parm into number

        monitor;
          pWhse# = %dec(pWhse:3:0);
        on-error;
          return;
        endmon;

        // Compute cut off date

        dDate = '*DFT';
        cmpdte ('*POH    ' : 'IFSPOASNCL' : pWhse : dDate);

        // Convert date into number

        monitor;
          iDate = %dec(dDate:8:0);
        on-error;
          return;
        endmon;

        // Remove old files from IFS folder

        iDir = '/BFC/PIRF/ASN Import';
        ifsrmvold(iDir : iDate : iReturn : iMessage);

        // Remove old records from POASNLOG file

        exsr rmvPOASNrecs;

        return;

        //-------------------------------------------------------------
        //       Subroutines in Alphabetical Order
        //-------------------------------------------------------------

        //-------------------------------------------------------------
        //  *inzsr  Initialization subroutine
        //-------------------------------------------------------------

        begsr *inzsr;

          //  Get client id

          getclient(client : clientloc);

        endsr;

        //-------------------------------------------------------------
        //  rmvPOASNrecs  Remove POASNLOG records
        //-------------------------------------------------------------

        begsr rmvPOASNrecs;

          // Connect

          exec sql connect reset;
          sqlstt = sqlstt;

          // Build statement

          sqlstmt = 'delete from poasnlog '
                  + 'where date(pamaddts)<date('
                  + sq + %char(%date(iDate:*ISO)) + sq
                  + ')';

          // Prepare statement

          exec sql prepare sel from :sqlstmt;
          sqlstt = sqlstt;

          // Execute statement

          exec sql execute sel;
          sqlstt = sqlstt;

          // Disconnect

          exec sql disconnect current;
          sqlstt = sqlstt;

        endsr;

      /end-free
