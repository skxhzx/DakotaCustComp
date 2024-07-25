      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  COPYWHSE    Copy WAREHS info to GLOWHSE
     *  February 6, 2012
     *  Rod Roller
     *
     *  Revisions:
     *
640 A*    02/06/12  RTR  6.40
     *      - Created.
640aA*    01/02/13  RTR  6.40a
     *      - Changed select to get recs with no WAREHSAD.
     *      - Hard code BFCGLOBALF.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D debug           s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     D copywhse        pr                  extpgm('COPYWHSE')

     D copywhse        pi

      /free

640aD  //Exec Sql insert into GLOWHSE
640aD  //                (GWWHSE,GWNAME,GWADR1,GWADR2,GWCITY,GWSTATE,GWZIP)
640aD  //         select WAREHS.WHCODE, WAREHS.WHDESC, WAREHSAD.WHAAD1,
640aD  //                WAREHSAD.WHAAD2, WAREHSAD.WHACTY, WAREHSAD.WHAST,
640aD  //                WAREHSAD.WHAZIP
640aD  //         from   WAREHS, WAREHSAD
640aD  //         where WAREHS.WHCODE = WAREHSAD.WHACOD;

640aA    Exec Sql insert into BFCGLOBALF/GLOWHSE (GWWHSE,GWNAME)
640aA             select WHCODE,WHDESC from WAREHS;
640aA
640aA    Exec Sql update BFCGLOBALF/GLOWHSE A
640aA             set (GWADR1,GWADR2,GWCITY,GWSTATE,GWZIP)
640aA               = (select WHAAD1,WHAAD2,WHACTY,WHAST,WHAZIP
640aA                  from WAREHSAD B where A.GWWHSE = B.WHACOD);

         sqlstt = sqlstt;

         debug = *on;
         if debug;
           exsr wrtDebugParms;
         endif;

         *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'sqlstt:' + %trimr(sqlstt);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
