      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDCFI051     Set selection method from UPC import file
     *  October 15, 2019
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730  *    10/15/19  RTR  7.30
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     Fimpfupc   if   e           k disk    rename(ucrec:record)
     Fitemfld   Uf   e           k disk
     *----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar
     *----------------------------------------------------------------
     D main            pr                  extpgm('QDCFI051')
     D main            pi
     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        dow forever = forever;

          read record;
          if %eof();
            leave;
          endif;

          chain (ucwhse:ucitem) itemfld;
          if %found();
            ifsltmth = '4';
            update ifrec;
          endif;

        enddo;

        *inlr = *on;
      /end-free
