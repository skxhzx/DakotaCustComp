      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  GETHOST      Get BFC Dakota client id from data area PIRCLIENT
     *  23 February 2018
     *  Rod Roller
     *
     *  Revisions
     *
720  *    02/23/18  RTR  7.20
     *      - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     foptionint uf a e           k disk

     *----------------------------------------------------------------
     * Parameters
     *   Incoming Values:
     *     None.
     *
     *   Returned Values:
     *     pHostId - Host ERP Name
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('GETHOST')
      * Output
     d   pHostId                    100

     d main            pi
     d   pHostId                    100

     *----------------------------------------------------------------
     *  Main Line
     *
      /free

          // Get values from OPTIONINT
          chain ('Interface': 'General Options': 'Host ERP System') optionint;
          if %found(optionint);
            pHostId = opivala;
          else;
            opitype = 'Interface';
            opicat  = 'General Options';
            opiname = 'Host ERP System';
            opicmod = 'N';
            opivalt = 'A';
            opivaln = 0;
            opivala = 'Unspecified';
            opidesc = 'Host ERP System that is interfaced with.';
            write opirec;
            pHostId = 'Unspecified';
          endif;

          *inlr = *on;

      /end-free
