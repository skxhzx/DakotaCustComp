      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UT882      Retrieve FTP Import Backup Directory
     *  15 February 2013
     *  Rod Roller
     *
650 A*    02/15/13  RTR  6.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     *  Variables
     *
     d whsenum         s              3s 0
     d direc           s            117a

     *----------------------------------------------------------------
     *  Called Programs
     *
     d GetOpt          pr                  extpgm('UT881')
     d  pWhse                         3a   const
     d  pCode                         8a   const
     d  pPos                          3a   const
     d  pLen                          3a   const
     d  pValue                      117a

     *----------------------------------------------------------------
     *  Program Prototype and Entry Parms
     *
     d Main            pr                  extpgm('UT882')
     d                                3    const
     d                              100
     d Main            pi
     d  pWhs                          3a   const
     d  pDir                        100a

     *----------------------------------------------------------------
     * Parameters
     *   Incoming Values:
     *
     *   Returned Values:
     *     pDir   - Directory
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

          // Get options record
          GetOpt(pwhs: '*FTPIMP': '064': '032': direc);
          if direc <> *blanks;
            pDir = %subst(direc: 1: %len(%trim(direc))-1)
                   + '_Backup/';
          else;
            pDir = '*ERROR';
          endif;

          *inlr = *on;

      /end-free
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;
        endsr;
      /end-free
