      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDCFI050     Set selection method
     *  27 Sept 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    09/27/18  RTR  7.20
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     Fslot      if   e           k disk

     *----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Parameters
     *    Input Parameters
     *      none
     *    Returned Parameters
     *      none
     *----------------------------------------------------------------
     D main            pr                  extpgm('QDCFI050')

     D main            pi

     *----------------------------------------------------------------
     *  Working variables
     d batId           s             11    inz(' ')
     d xdisp           s             15a

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Read slot records
        dow forever = forever;

          read slrec;
          if %eof(slot);
            leave;
          endif;

          if slaisl < ' AA'
           or slaisl > ' AZ';
            iter;
          endif;
          if slpick <> 'Y'
           or slitem = *blanks;
            iter;
          endif;
          exec sql select qddisp into :xdisp from qdcfiskip
                    where qditem = :slitem
                    fetch first 1 rows only;
          if sqlstt = sqlsuccess;
            iter;
          else;
            exec sql update itemfld
                        set ifsltmth = 4
                      where ifitem = :slitem;
          endif;

        enddo;

        *inlr = *on;
      /end-free
