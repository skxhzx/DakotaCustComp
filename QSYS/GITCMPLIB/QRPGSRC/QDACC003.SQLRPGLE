      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDACC003     Startup Step 3: Create qty from comparison
     *  17 May 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
ACC  *    11/05/18  RTR  ACC
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     fimpscqty  uf a e           k disk
     fpiritem   if   e           k disk
     fimpfstuf3 uf a e           k disk    extmbr('PICKQTY')
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
     *  Prototypes
     d main            pr                  extpgm('QDACC003')
     d main            pi
     *----------------------------------------------------------------
     *  Working variables
     d batId           s             11    inz(' ')
     d rtnCode         s             10
     d rtnMessage      s            200

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Read records
        dow forever = forever;
          read icrec;
          if %eof(impscqty);
            leave;
          endif;

          if ictqh1 = 0
           and ictqh2 = 0;
            iter;
          endif;

          chain (icwhse: icitem) piritem;
          if not %found;
            icstatus = 'E';
            ictext = 'Item not found.';
            update icrec;
            iter;
          endif;

          siwhse = 1;
          siitem = icitem;
          siqty1 = ictqh1;
          siqty2 = ictqh2;
          siqty3 = ictqh3;

          // Get pick slot for item
          exec sql select slwhdp,sldisp,slpick,slrsrv,slstyp
                     into :siwhdp,:sidisp,:sipick,:sirsrv,:sistyp
                     from slot
                    where slitem = :icitem
                      and slpick = 'Y';
          if sqlstt <> sqlSuccess;
            siwhdp = itwhdp;
            sidisp = '888-900-1';
            sipick = 'Y';
            sirsrv = 'N';
          endif;

          write sirec;

        enddo;

        *inlr = *on;
      /end-free
