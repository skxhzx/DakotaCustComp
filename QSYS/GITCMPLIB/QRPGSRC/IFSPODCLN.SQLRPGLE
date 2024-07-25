      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IFSPODCLN   Clean up POD history
     *  10 September 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
520 A*    09/10/08  DAS  5.20
     *      - Created.
520aA*    10/21/08  RBD  5.20
     *      - Added file PODLOGP.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

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
     *  *POD1    -  POD options - Part 1
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPOPT  -  Export to POD (Y,N)
     *    OPPIFS  -  IFS folder
     *    OPPSRV  -  POD HTTP Server
     *    OPPUSR  -  POD HTTP Server User Id
     *    OPPPWD  -  POD HTTP Server Password
     *
     * Data structure
     *
     D opdata1         ds
     D  oppopt                 1      1
     D  opppth                 2     33
     D  oppsrv                34     83
     D  oppusr                84     98
     D  opppwd                99    113
     D  optend1              117    117

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)

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
          pWhse# = %dec(pWhse:8:0);
        on-error;
          return;
        endmon;

        // Compute cut off date

        dDate = '*DFT';
        cmpdte ('*POD' : 'IFSPODCLN' : pWhse : dDate);

        // Convert date into number

        monitor;
          iDate = %dec(dDate:8:0);
        on-error;
          return;
        endmon;

        // Get IFS folder

        keyop.opwhse = pWhse#;
        keyop.opcode = '*POD1';

        chain %kds(keyop) options;
        if not %found();
          return;
        endif;
        eval opdata1 = opdata;

        // Remove old files from IFS folder

        iDir = opppth;
        ifsrmvold(iDir : iDate : iReturn : iMessage);

        // Remove old records from PODLOG file

        exsr rmvPODrecs;

520aA   // Remove old records from PODLOGP file

520aA   exsr rmvPODPrecs;

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
        //  rmvPODrecs  Remove PODLOG records
        //-------------------------------------------------------------

        begsr rmvPODrecs;

          // Connect

          exec sql connect reset;
          sqlstt = sqlstt;

          // Build statment

          sqlstmt = 'delete from podlog '
                  + 'where date(podts9)<date('
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

        //-------------------------------------------------------------
520aA   //  rmvPODPrecs  Remove PODLOGP records
        //-------------------------------------------------------------

520aA   begsr rmvPODPrecs;

          // Connect

          exec sql connect reset;
          sqlstt = sqlstt;

          // Build statment

          sqlstmt = 'delete from podlogp '
                  + 'where date(pdpts9)<date('
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
