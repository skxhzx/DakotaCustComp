      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSTRAXCLN   Clean up TRAX history
     *  07 July 2010
     *  Retha Davis
     *
     *  Revisions
     *
530 A*    07/07/10  RBD  5.30
     *      - Created.
     *
640 A*    02/02/12  RBD  6.40
     *      - Only execute this pgm if the client uses Trax.
     *
650 A*    08/26/13  RBD  6.50
     *      - Recompiled, TTLOG file changed.
     *
700aA*    09/28/16  RBD  7.00a
     *      - Enh: added Trax training routes file.  Don't delete Trax
     *        training routes from TTLOG file.
     *
710aA*    05/18/17  RBD  7.10a
     *      - Discontinue TTLOG cleanup in this program as it's being
     *        done in RT755 on the same schedule as route cleanup.
     *
710bA*    12/07/17  RBD  7.10b
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs

640 AFoptions   if   e           k disk

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
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

640 AD keyop           ds                  likerec(oprec : *key)

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

640 A*----------------------------------------------------------------
640 A*  *SYSTEM  -  System options.
640 A*----------------------------------------------------------------
640 A*
640 A* Fields
640 A*
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

710bA*----------------------------------------------------------------
710bA*  *TRAX2  -  More TRAX options
710bA*----------------------------------------------------------------
710bA*
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
     *    OPTV12  -  Default = N.  Y = create V1.2 xml.
     *    OPTV20  -  Default = N.  Y = create V2.0 xml.
     *    OPTDIR  -  IFS main directory
     *    OPTIU   -  IFS user
     *
     * Data structure
     *
     D opdta2          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
     D  optv12                18     18
     D  optv20                19     19
     D  optdir                20     39
     D  optiu                 40     49
     D  opten2               117    117

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
640 M     pWhse# = %dec(pWhse:3:0);
        on-error;
          return;
        endmon;

640 A   exsr getOptions;

        // Compute cut off date

        dDate = '*DFT';
        cmpdte ('*TRAX' : 'IFSTRAXCLN' : pWhse : dDate);

        // Convert date into number

        monitor;
          iDate = %dec(dDate:8:0);
        on-error;
          return;
        endmon;

        // Remove old files from IFS folder

710bA    select;
710bA
710bA      when optdir <> '';
710bA        if %subst(optdir:1:1) <> '/';
710bA          iDir = '/' + optdir;
710bA        else;
710bA          iDir = optdir;
710bA        endif;

710bD      //if client = JSilvert;
710bM      when client = JSilvert;
JSLaA        iDir = '/JSLTrax';

710bD      //else;
710bM      other;
JSLaA        iDir = '/BFCTrax';

710bD      //endif;
710bA    endsl;

        ifsrmvold(iDir : iDate : iReturn : iMessage);

        // Remove old records from TTLOG file

710aA   // Discontinue TTLOG cleanup in this program
710aD   // exsr rmvTRAXrecs;

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

640 A   //---------------------------------------------------------------
640 A   //  getOptions  Get options
640 A   //---------------------------------------------------------------
640 A
640 A   begsr getOptions;

710bA   //  get *TRAX2 options
710bA
710bA     chain (pwhse#: '*TRAX2') Options;
710bA
710bA     if not %found;
710bA       opdta2  = ' ';
710bA     else;
710bA       opdta2  = opdata;
710bA     endif;

        //  get *SYSTEM options

          keyop.opWhse = 0;
          keyop.opCode = '*SYSTEM ';

          chain %kds(keyop) Options;

          if not %found
             or %found and optrax <> 'Y';
               return;
          endif;

        endsr;

        //-------------------------------------------------------------
        //  rmvTRAXrecs  Remove TTLOG records
        //-------------------------------------------------------------

        begsr rmvTRAXrecs;

          // Connect

          exec sql connect reset;
          sqlstt = sqlstt;

          // Build statement

          sqlstmt = 'delete from ttlog '
                  + 'where date(ttlts9)<date('
                  + sq + %char(%date(iDate:*ISO)) + sq
                  + ')'
700aA             + ' and not exists (select tttwhs '
700aA             +                'from tttrain '
700aA             +                'where tttwhs = ttlwhse '
700aA             +                  'and tttrid = ttlrtid)';

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
