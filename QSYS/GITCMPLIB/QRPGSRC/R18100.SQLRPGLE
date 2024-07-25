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
     *  FR18100  Get TTFLAG display time (predefined stop flags)
     *
     *  10 Mar 2016
     *  Retha Davis
     *
     *  Revisions:
     *
700 A*    03/10/16  RBD  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pFlgChar    Stop flag character
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
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

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

     D psession        s             40    varying
     D pWhse           s              3p 0
     D pFlgChar        s              1
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D ttarec        E Ds                  Extname(ttflag)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    psession
     c                   parm                    pWhse
     c                   parm                    pFlgChar
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        pOutStr = ' ';

        // get display time
        exec sql select * into :ttarec
           from ttflag
             where ttawhs = :pWhse
               and ttachr = :pFlgChar;
        If sqlstt = sqlSuccess;
        else;
          ttadsp = '1';
        endif;


        // Put together JSON string

        pOutStr = '{'
               +  '"dsptim":"'  + %trimr(ttadsp) + '"';

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

