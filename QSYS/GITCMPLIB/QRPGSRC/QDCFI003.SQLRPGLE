      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDCFI003     Startup Step 3: Create qty from comparison
     *  17 May 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    05/17/18  RTR  7.20
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     Fimpfcqty  if   e           k disk
     Fimpfstuf3 uf a e           k disk

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
     D main            pr                  extpgm('QDCFI003')

     D main            pi

     *----------------------------------------------------------------
     *  Prototypes

     *----------------------------------------------------------------
     *  Working variables
     d batId           s             11    inz(' ')
     d rtnCode         s             10
     d rtnMessage      s            200

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Read slot records
        dow forever = forever;
          read icrec;
          if %eof(impfcqty);
            leave;
          endif;

          if ictqh1 = 0
           and ictqh2 = 0;
            iter;
          endif;

          siitem = icitem;
          // Get pick slot for item
          exec sql select slwhdp,sldisp,slpick,slrsrv,slstyp
                     into :siwhdp,:sidisp,:sipick,:sirsrv,:sistyp
                     from slot
                    where slitem = :icitem
                      and slpick = 'Y';
          if sqlstt <> sqlSuccess;
            siwhdp = 'DRY';
            sidisp = 'NOTFOUND';
            sipick = 'Y';
            sirsrv = 'Y';
          endif;

          siwhse = 1;
          siqty1 = ictqh1;
          siqty2 = ictqh2;
          siqty3 = 0;

          write sirec;

        enddo;

        *inlr = *on;
      /end-free
