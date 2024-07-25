     h/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDCFI001     Clear all slots
     *  17 May 2018
     *  Rod Roller
     *
     *  Notes:
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *   05/17/18  RTR  7.20
     *     - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
     *  Working variables
     D chk4err         s               n
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
      /free

        exec sql delete from slot where slsdef = 'BF';
        exec sql delete from slot where slsdef = 'SU';
        exec sql delete from slot where slaisl = 'OSS';
        exec sql delete from slot where slaisl = 'USR';
        exec sql delete from slot where slrsrv = 'V';
        exec sql delete from slot where slloc > 599;
        exec sql delete from vslot;

        exec sql update slot set slsdte = 0,
                                 slstim = 0,
                                 slstat = 'V',
                                 slentd = 0,
                                 slexpd = 0,
                                 slslfd = 0,
                                 slitem = ' ',
                                 slstk1 = 0,
                                 slstk2 = 0,
                                 slstk3 = 0,
                                 slalc1 = 0,
                                 slalc2 = 0,
                                 slalc3 = 0,
                                 slpck1 = 0,
                                 slpck2 = 0,
                                 slpck3 = 0;

       // exec sql update slot set slrsrv = slpick
       //                    where slstyp = 'F';
       // exec sql update slot set slrsrv = 'N'
       //                    where slstyp = 'P';

       // exec sql update itemqty set iqstk1 = 0,
       //                             iqstk2 = 0;

        *inlr = *on;
        return;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     C                   endsr
