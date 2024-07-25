      /copy *libl/qcopysrc,hspecs
     h dftactgrp(*no) bnddir('HTTPAPI')
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  INTAPINS    Interface API call for NetSuite
     *  July 14, 2020
     *  Rod Roller
     *
     *----------------------------------------------------------------
     * Notes
     *  - You must add lib HTTPBFC to library list before compiling.
     *  - Error messages are written to BFCLOG.
     *  - If path provided in OPTIONINT, webservice response file
     *     created in that path.
     *----------------------------------------------------------------
     *  Revisions:
     *
740 A*    07/14/20  RTR  7.40
     *      - Created.
     *
750 A*    08/17/21  KDE  7.50
     *      - Add interface to pull in NetSuite Inventory Balances
     *        for Inventory Comparison Report
     *
750aA*    09/10/21  LMC  7.50a
     *      - Submit the process.
750bA*    09/13/21  LMC  7.50b
     *      - Don't submit inventory comparison
     *      - Don't submit route export
     *      - Don't submit full export
     *----------------------------------------------------------------
     *  Program information data structure
     d/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables
     d/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  HTTP source
     d/copy qrpglesrc,httpapi_h

     *----------------------------------------------------------------
     *  Prototypes
      /copy qcopysrc,p.wrtlog
      /copy qcopysrc,p.getopint
750aA /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Variables
     d ifs             s            256a   varying
     d rc              s             10i 0
     d url             s            300a   varying
     d urlEXPPO        s            100a
     d urlEXPPOF       s            100a
     d urlEXPADJUST    s            100a
     d urlEXPROUTE     s            100a
     d urlEXPRETURN    s            100a
750 Ad urlIMPICOMP     s            100a
750aAd pejobq          s             10a   inz('QS36EVOKE')
750aAd pename          s             10a   INZ('REALTIME')
750aAD pecmd           S           3000A   varying
750aAD CMD             S           3000A   varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('INTAPINS')
      * Input
     d   pxWhs                        3    const
     d   pxBatch                     11    const
     d   pxType                      10    const
      * Output
     d   pxRet                       10
     d   pxMsg                      200
750aAd   pxrun                        1

     d main            pi
      * Input
     d   pxWhs                        3    const
     d   pxBatch                     11    const
     d   pxType                      10    const
      * Output
     d   pxRet                       10
     d   pxMsg                      200
750aAd   pxrun                        1

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Set Interface URL to call based on export type.
        select;
          when pxType = 'EXPADJUST';
            url = %trim(urlEXPADJUST) + '/' + %trim(pxWhs)
                + '/' + %trim(pxBatch) + '/' + %trim(pxType);
          when pxType = 'EXPPO';
            url = %trim(urlEXPPO) + '/' + %trim(pxWhs)
                + '/' + %trim(pxBatch) + '/' + %trim(pxType);
          when pxType = 'EXPPOF';
            url = %trim(urlEXPPOF) + '/' + %trim(pxWhs)
                + '/' + %trim(pxBatch) + '/' + %trim(pxType);
          when pxType = 'EXPROUTE';
            url = %trim(urlEXPROUTE) + '/' + %trim(pxWhs)
                + '/' + %trim(pxBatch) + '/' + %trim(pxType);
          when pxType = 'EXPRETURN';
            url = %trim(urlEXPRETURN) + '/' + %trim(pxWhs)
                + '/' + %trim(pxBatch) + '/' + %trim(pxType);
750 A     when pxType = 'IMPICOMP';
750 A       url = %trim(urlIMPICOMP);

          other;
            url = *blanks;
        endsl;

        // Make Interface URL call.
        if url <> *blanks;
          rc = http_url_get( url :ifs );
        endif;

        // Log any Interface error.
        select;
          when url = *blanks;
750 A       pxRet = '*ERROR';
            log.pgm = #pgm;
            log.type = 'Error    ';
            log.text = pxBatch + ' | ' + %trim(pxType)
                     + ' | URL not defined in OPTIONINT.';
            WrtLog(log.pgm: log.type: log.text);
          when rc <> 1;
750 A       pxRet = '*ERROR';
            log.pgm = #pgm;
            log.type = 'Error    ';
            log.text = pxBatch + ' | ' + %trim(http_error);
            WrtLog(log.pgm: log.type: log.text);
            log.text = %trim(url);
            WrtLog(log.pgm: log.type: log.text);
          other;
750 A       pxRet = '*OK';
            log.pgm = #pgm;
            log.type = 'Debug    ';
            log.text = pxBatch + ' | ' + %trim(http_error);
            WrtLog(log.pgm: log.type: log.text);
            log.text = %trim(url);
            WrtLog(log.pgm: log.type: log.text);
        endsl;

        *inlr = *on;
        return;

      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
      /free
        begsr *inzsr;

750aA   if %parms < 6
750bA      and pxtype <> 'IMPICOMP'
750bA      and pxtype <> 'EXPPOF'
750bA      and pxtype <> 'EXPROUTE';
750aA     // Submit job

750aA    pecmd = 'CALL  '
750aA           +   'PGM(' + %trimr(#pgm) + ') '
750aA           +   'PARM('
750aA           +      sq + pxWhs + sq + ' '
750aA           +      sq + pxBatch + sq + ' '
750aA           +      sq + pxType + sq + ' '
750aA           +      sq + pxRet + sq + ' '
750aA           +      sq + pxMsg + sq + ' '
750aA           +      sq + 'Y' + sq + ' '
750aA           +   ')';

750aA     cmd = 'SBMJOB CMD(' + peCmd + ') ' +
750aA           'JOBQ(' + peJobQ +') ' +
750aA           'JOB(' + peName+ ')';

750aA     monitor;
750aA       qcmdexc(%trim(cmd): %len(%trim(cmd)));
750aA     on-error *all;
750aA     endmon;
750aA     *inlr = *on;
750aA     return;
750aA   endif;

        // Get/set log file path
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'Log File Path       ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK' and optint.vala <> *blanks;
          callp http_debug(*ON);
750 A     if %trim(pxBatch)='';
750 A      ifs = %trim(optint.vala) + 'NSInt-' + pxWhs + '.txt';
750 A     else;
           ifs = %trim(optint.vala) + 'NSInt-' + pxWhs + '-' + pxBatch + '.txt';
750 A     endif;
        else;
          ifs = *blanks;
        endif;

        // Get Adjustment Export URL
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'EXPADJUST URL       ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK';
          urlEXPADJUST = optint.vala;
        else;
          urlEXPADJUST = *blanks;
        endif;

        // Get PO RTI Export URL
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'EXPPO URL           ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK';
          urlEXPPO = optint.vala;
        else;
          urlEXPPO = *blanks;
        endif;

        // Get PO Full Export URL
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'EXPPOF URL          ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK';
          urlEXPPOF = optint.vala;
        else;
          urlEXPPOF = *blanks;
        endif;

        // Get Route Export URL
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'EXPROUTE URL        ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK';
          urlEXPROUTE = optint.vala;
        else;
          urlEXPROUTE = *blanks;
        endif;

        // Get Returns Export URL
        optint.type = 'Interface   ';
        optint.cat  = 'NetSuite API        ';
        optint.name = 'EXPRETURN URL       ';
        GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                  optint.valn: optint.vala: optint.return);
        if optint.return = '*OK';
          urlEXPRETURN = optint.vala;
        else;
          urlEXPRETURN = *blanks;
        endif;

750 A   // Retrieve Inventory Balances from NetSuite
750 A   optint.type = 'Interface   ';
750 A   optint.cat  = 'NetSuite API        ';
750 A   optint.name = 'IMPICOMP URL        ';
750 A   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750 A             optint.valn: optint.vala: optint.return);
750 A   if optint.return = '*OK';
750 A     urlIMPICOMP = optint.vala;
750 A   else;
750 A     urlIMPICOMP = *blanks;
750 A   endif;
750 A
750 A   endsr;  // *inzsr
      /end-free
