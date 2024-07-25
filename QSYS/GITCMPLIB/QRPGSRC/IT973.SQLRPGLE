     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT973         Item Quantity Compare Report - Target Import
     *  09 October 2014
     *  Rod Roller
     *
650  *    10/09/14  RTR  6.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D cmdstr          S            200a
     D cmdlen          S             15p 5
     D mbrnam          s             10a
     D putstr          s            200a

     D filelist        S            256a   dim(500)
     D num_files       S             10i 0
     D fileno          S             10i 0
     D rc              S             10i 0
     D ErrNum          S             10i 0
     D gotfiles        S             10i 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *      pReturn    - *OK, *ERROR.
     *      pMessage   - Message
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('IT973')
     D   pReturn                     10

     D main            pi
     D   pReturn                     10

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------
      /free

        exec sql
          update impfctarg
            set siitem = upper(siitem);

        exec sql
          insert into impfcqty (ICWHSE,ICITEM,ICTQH1,ICTQH2,ICTQH3)
            (select siwhse, siitem, sum(siqty1), sum(siqty2), 0
               from impfctarg
              where siitem is not null
              group by siwhse,siitem
              order by siwhse,siitem);

        *inlr = *on;
        return;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *  *INZSR   Initialization Subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

        endsr;
      /end-free
