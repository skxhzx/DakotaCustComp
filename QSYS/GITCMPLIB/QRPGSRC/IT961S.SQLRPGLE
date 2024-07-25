      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2024 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IT961S      Inventory Comparison - Snapshot of Dakota
     *  27 February 2024
     *  Lynn McMahon
     *
780  *    02/27/24  LMC  7.80
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     H*bnddir('BFCBND')

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D larec         E ds                  extname(licactive) inz(*EXTDFT)
     D bdrec         E ds                  extname(bfcdebug) inz(*EXTDFT)
     D itrec         E ds                  extname(piritem) inz(*EXTDFT)
     D ic3rec        E ds                  extname(impscqty3) inz(*EXTDFT)
     D cplrec        E ds                  extname(complic) inz(*EXTDFT)
     D cpirec        E ds                  extname(compitem) inz(*EXTDFT)
     D cphrec        E ds                  extname(comphost) inz(*EXTDFT)
     D qcdrec        E ds                  extname(comprptd) inz(*EXTDFT)
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /copy *libl/qcopysrc,c#licinfo
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getsloti
      /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10


     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d pClientid       s             10
     d pClientloc      s             10
     d pClientinit     s              3
     d pClienthost     s             10

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     d MyfieldNull     s              5i 0
     d $batch          s             11a
     d recId           s             11p 0
     d savts           s               z
     d whs#            s              3  0
     D chk4err         s               n
     d cl1qty1         s             15p 0
     d cl1qty2         s             15p 0
     d cl1qty3         s             15p 0
     D clcvt1          s             15p 0
     D clcvt2          s             15p 0
     D clcvt3          s             15p 0
     D cltqtyN         s             15  5
     D cltqty1         s             15  5
     D cltqty2         s             15  5
     D cpdiff1         s             15p 0
     D cpdiff2         s             15p 0
     D cpdiff3         s             15p 0
     D cpdiffw         s              1  0
     D cpdiffh         s              1  0
     D wdiff           s              7  0
     D hdiff           s              7  0
     d cwhse           s              3S 0
     d cbatid          s             11
     d citem           s             15
     d clot            s             30
     d errMsg          s             99    varying
     d debugMsg        s           1024    varying
     D itemError       s              5  0
     D LcnsError       s              5  0
     D wrtDebug        s               n
     D zmsflag         s               n
     D newqtyN         s              7  0
     D newqty1         s              7  0
     D newqty2         s              7  0
     D hostlot         s             30
     D lacvt1          s              5  0
     D lacvt2          s              5  0
     D lacvt3          s              5  0
     d hlot            s             30
     d hwhse           s              3S 0
     d hbatid          s             11
     d hitem           s             15
     d hitype          s              1
     d hwhdp           s              5
     d hostqty1        s              5  0
     d hostqty2        s              5  0
     d hostqty3        s              5  0
     d itemqty1        s              5  0
     d itemqty2        s              5  0
     d itemqty3        s              5  0
     d sltwhse         s              3  0
     d sltitem         s             15
     d slttype         s              1
     d sltdesc         s             30
     d sltpdsc         s             15
     d sltreturn       s             10
     d sltmessage      s             60
     d txtcnt          s            200a

     d clen            s             15p 5
     d cmd             s           3000a
     *----------------------------------------------------------------
     *  Customer id
     *
      /COPY qcopysrc,hostsystem

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d AAAInit         pr


     d GetItem         pr
     d  whse                               like(lawhse)
     d  item                               like(lasitem)

     d GetLicinfo      pr
     d  whse                               like(lawhse)
     d  orglcns                            like(laolcns)

     d addHostLot      pr

     d addItem         pr

     d addLicense      pr

     d clientHostLot   pr

     d clientItem      pr

     d crtCompRptDitm  pr

     d crtCompRptDlot  pr

     d createCompItem  pr

     d updImport       pr

     d WrtDebugMsg     pr

     d zzzdricop       pr

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z
     D NoDate          s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *
      *    Returned Parameters
      *
      *----------------------------------------------------------------
     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $Pwhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        aaainit();

        // create the data in the COMPLIC file
        // License detail
        addLicense();

        // summary by host lot
        addHostLot();

        // summary by host slot item
        addItem();

        // create the data in the COMPHOST file
        // summary by host lot
        ClientHostLot();

        // summary by host slot item
        clientItem();

        // create the data in the COMPLIC file
        createCompItem();

        // create the comprptd file for the actual report
        crtCompRPTDitm();
        crtCompRPTDlot();

        // Update the import file and stage batch as processed
        updImport();
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  AAAInit      Pre-subcommand initialization.
     *----------------------------------------------------------------

     p AAAInit         b
     d AAAInit         pi

      /free

        savts = %timestamp();
        whs# = %dec($pWhse3A: 3: 0);
        GetClient(pClientid: pClientloc: pClientinit: pClienthost);

        getUser(#curruser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        // Set batch status
        exec sql
          insert into COMPRPTH
            values (:whs#,:$pBatId,:savts,'Processing...','Processing...');

      /end-free
     p AAAInit         e

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     p clr$item        b
     d clr$item        pi

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C*                  eval      $saemp#U = *on
     C*                  eval      $saemp# = e$emp#

     p                 e

     *----------------------------------------------------------------
     *  clr$licinfo clear $licinfo data structure fields
     *----------------------------------------------------------------

     p clr$licinfo     b
     d clr$licinfo     pi

     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#
     C*                  eval      $saemp#U = *on
     C*                  eval      $saemp# = e$emp#

     p                 e

     *----------------------------------------------------------------
     *  GetItem    Get Item
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi
     d  whse                               like($itwhse)
     d  item                               like($ititem)

      /free

       clr$item();
       $itwhse  = whse;
       $ititem  = item;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETMAIN';
       $drisys2upd = 'D';
       chk4err = *on;
       zmsflag = *off;
       zzzdricop();
       if error;
         error = *off;
         $itcwgt = 'N';
         itemError += 1;
         if wrtDebug;
           debugMsg = 'Error getting item '
                    + %char($itwhse) + ', ' + %trim($ititem) + ', '
                    + 'Rtn: ' + %trim($drireturn) +', '
                    + 'Msg: ' + %trim(errmsg);
           WrtDebugMsg();
         endif;
       endif;


      /end-free
     p                 e

     *----------------------------------------------------------------
     *  GetLicinfo Get Licinfo for host lot
     *----------------------------------------------------------------

     p GetLicinfo      b
     d GetLicinfo      pi
     d  whse                               like($itwhse)
     d  orglcns                            like(laolcns)

      /free

       clr$licinfo();
       $lnwhse  = whse;
       $lnlcns = orglcns;

       $dricommand = '*LICINFO';
       $drisubcmd  = '%GET';
       $drisys2upd = 'D';
       chk4err = *on;
       zmsflag = *off;
       zzzdricop();
       if error;
         error = *off;
         LcnsError += 1;
         if wrtDebug;
           debugMsg = 'Error getting Licinfo '
                    + %char($lnwhse) + ', ' + %trim($lnlcns) + ', '
                    + 'Rtn: ' + %trim($drireturn) +', '
                    + 'Msg: ' + %trim(errmsg);
           WrtDebugMsg();
         endif;
       endif;


      /end-free
     p                 e

     *----------------------------------------------------------------
     *  addHostLot      Process complic L records to write complic H
     *----------------------------------------------------------------

     p addHostLot      b
     d addHostLot      pi

      /free

       SqlStmt =
        'SELECT cplhstlot,cplwhse,cplbatid,cplitem,cplitype,'
        +'sum(cplaqty1),sum(cplaqty2),sum(cplaqty3) '
        +'from complic where cpllevel=' + sq + 'L' + sq
        +'and cplbatid = ' + sq + %char($pBatId) + sq
        +' group by cplwhse,cplbatid,cplitem,cplitype'
        +',cplhstlot';

       exec sql prepare hstinsel from :SqlStmt;
       exec sql declare hstincsr dynamic scroll cursor for hstinsel;
       exec sql open hstincsr;

       dow forever = forever;

         exec sql fetch next from hstincsr
         into :hlot,:hwhse,:hbatid,:hitem,:hitype,
              :hostqty1,:hostqty2,:hostqty3;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         GetItem(hwhse: hitem);
         // rollup breakdowns properly
         if (hostqty2<>0 and $itumq2<>0) or (hostqty3<>0 and $itumq3<>0);
           select;
             when hostqty3 <> 0;
              //First, take to lowest level quantity based on breakdowns
               newqty2 = ((hostqty1 * $itumq2 * $itumq3) +
                         (hostqty2 * $itumq3) +
                          hostqty3);
               newqty1=*zeros;
               newqtyn=*zeros;
             when hostqty2 <> 0;
               newqty1 = ((hostqty1 * $itumq2) +
                           hostqty2);
               newqtyn=*zeros;
               newqty2=*zeros;
           endsl;
          //Next, roll back up with breakdown structure
           // check for negative quantities
           *in49=*off;
           if newqtyn<0;
             *in49=*on;
             newqtyn = %abs(newqtyn);
           endif;
           if newqty1<0;
             *in49=*on;
             newqty1 = %abs(newqty1);
           endif;
           if newqty2<0;
             *in49=*on;
             newqty2 = %abs(newqty2);
           endif;

           dow $itumq3 > 0 and +
               newqty2 >= $itumq3;
             newqty2 -= $itumq3;
             newqty1 += 1;
           enddo;

           dow $itumq2 > 0 and +
               newqty1 >= $itumq2;
             newqty1 -= $itumq2;
             newqtyn += 1;
           enddo;

           if *in49;
             newqtyn = newqtyn * -1;
             newqty1 = newqty1 * -1;
             newqty2 = newqty2 * -1;
           endif;
           lacvt1 = newqtyn;
           lacvt2 = newqty1;
           lacvt3 = newqty2;
         else;
           lacvt1 = hostqty1;
           lacvt2 = hostqty2;
           lacvt3 = hostqty3;
         endif;
         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into complic
            values ('H',:hwhse,:hbatid,:hitem,:hitype,' ',
                    ' ',:hlot,:hostqty1,:hostqty2,:hostqty3,
                    :lacvt1,:lacvt2,:lacvt3,' ',' ',
                    :currstampsys,:currstampuc,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p addHostLot      e

     *----------------------------------------------------------------
     *  addItem         Process complic L records to write complic S
     *----------------------------------------------------------------

     p addItem         b
     d addItem         pi

      /free

       SqlStmt =
        'SELECT cplwhse,cplbatid,cplitem,cplitype,'
        +'sum(cplaqty1),sum(cplaqty2),sum(cplaqty3) '
        +'from complic where cpllevel=' + sq + 'L' + sq
        +'and cplbatid = ' + sq + %char($pBatId) + sq
        +' group by cplwhse,cplbatid,cplitem,cplitype';

       exec sql prepare itminsel from :SqlStmt;
       exec sql declare itmincsr dynamic scroll cursor for itminsel;
       exec sql open itmincsr;

       dow forever = forever;

         exec sql fetch next from itmincsr
         into :hwhse,:hbatid,:hitem,:hitype,
              :itemqty1,:itemqty2,:itemqty3;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         GetItem(hwhse: hitem);
         // rollup breakdowns properly
         if (itemqty2<>0 and $itumq2<>0) or (itemqty3<>0 and $itumq3<>0);
           select;
             when itemqty3 <> 0;
              //First, take to lowest level quantity based on breakdowns
               newqty2 = ((itemqty1 * $itumq2 * $itumq3) +
                         (itemqty2 * $itumq3) +
                          itemqty3);
               newqty1=*zeros;
               newqtyn=*zeros;
             when itemqty2 <> 0;
               newqty1 = ((itemqty1 * $itumq2) +
                           itemqty2);
               newqtyn=*zeros;
               newqty2=*zeros;
           endsl;
          //Next, roll back up with breakdown structure
           // check for negative quantities
           *in49=*off;
           if newqtyn<0;
             *in49=*on;
             newqtyn = %abs(newqtyn);
           endif;
           if newqty1<0;
             *in49=*on;
             newqty1 = %abs(newqty1);
           endif;
           if newqty2<0;
             *in49=*on;
             newqty2 = %abs(newqty2);
           endif;

           dow $itumq3 > 0 and +
               newqty2 >= $itumq3;
             newqty2 -= $itumq3;
             newqty1 += 1;
           enddo;

           dow $itumq2 > 0 and +
               newqty1 >= $itumq2;
             newqty1 -= $itumq2;
             newqtyn += 1;
           enddo;

           if *in49;
             newqtyn = newqtyn * -1;
             newqty1 = newqty1 * -1;
             newqty2 = newqty2 * -1;
           endif;
           lacvt1 = newqtyn;
           lacvt2 = newqty1;
           lacvt3 = newqty2;
         else;
           lacvt1 = itemqty1;
           lacvt2 = itemqty2;
           lacvt3 = itemqty3;
         endif;
         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into complic
            values ('S',:hwhse,:hbatid,:hitem,:hitype,' ',
                    ' ',' ',:itemqty1,:itemqty2,:itemqty3,
                    :lacvt1,:lacvt2,:lacvt3,' ',' ',
                    :currstampsys,:currstampuc,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p addItem         e

     *----------------------------------------------------------------
     *  addLicense      Process LICACTIVE file write complic L records
     *----------------------------------------------------------------

     p addLicense      b
     d addLicense      pi

      /free

       SqlStmt = 'select * '
               + 'from ' + 'licactive '
               + 'where lawhse=' + %char(whs#);

       exec sql prepare adjinsel from :SqlStmt;
       exec sql declare adjincsr dynamic scroll cursor for adjinsel;
       exec sql open adjincsr;

       dow forever = forever;

         exec sql fetch next from adjincsr into :larec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         GetItem(lawhse: lasitem);
         hostlot = ' ';
         if pclientHost = freshbyte;
           GetLicinfo(lawhse: laolcns);
           hostlot = $lnlot;
         endif;
         if pclientHost = NetSuite;
           hostlot = laolcns;
         endif;
         // rollup breakdowns properly
         if (laqty2<>0 and $itumq2<>0) or (laqty3<>0 and $itumq3<>0);
           select;
             when laqty3 <> 0;
              //First, take to lowest level quantity based on breakdowns
               newqty2 = ((laqty1 * $itumq2 * $itumq3) +
                         (laqty2 * $itumq3) +
                          laqty3);
               newqty1=*zeros;
               newqtyn=*zeros;
             when laqty2 <> 0;
               newqty1 = ((laqty1 * $itumq2) +
                           laqty2);
               newqtyn=*zeros;
               newqty2=*zeros;
           endsl;
          //Next, roll back up with breakdown structure
           //exsr zzupQty;
           // check for negative quantities
           *in49=*off;
           if newqtyn<0;
             *in49=*on;
             newqtyn = %abs(newqtyn);
           endif;
           if newqty1<0;
             *in49=*on;
             newqty1 = %abs(newqty1);
           endif;
           if newqty2<0;
             *in49=*on;
             newqty2 = %abs(newqty2);
           endif;

           dow $itumq3 > 0 and +
               newqty2 >= $itumq3;
             newqty2 -= $itumq3;
             newqty1 += 1;
           enddo;

           dow $itumq2 > 0 and +
               newqty1 >= $itumq2;
             newqty1 -= $itumq2;
             newqtyn += 1;
           enddo;

           if *in49;
             newqtyn = newqtyn * -1;
             newqty1 = newqty1 * -1;
             newqty2 = newqty2 * -1;
           endif;
           lacvt1 = newqtyn;
           lacvt2 = newqty1;
           lacvt3 = newqty2;
         else;
           lacvt1 = laqty1;
           lacvt2 = laqty2;
           lacvt3 = laqty3;
         endif;
         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into complic
            values ('L',:lawhse,:$pBatId,:lasitem,:$ittype,:lalcns,
                    :laolcns,:hostlot,:laqty1,:laqty2,:laqty3,
                    :lacvt1,:lacvt2,:lacvt3,:lawhdp,:ladisp,
                    :currstampsys,:currstampuc,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p addLicense      e

     *----------------------------------------------------------------
     *  clientHostLot   Process impscqty3 records to write comphost H
     *----------------------------------------------------------------

     p clientHostLot   b
     d clientHostLot   pi

      /free

       SqlStmt =
        'SELECT ic3whse,ic3batid,ic3item,ic3hstlot,'
        +'sum(ic3qty1),sum(ic3qty2),sum(ic3qty3) '
        +'from impscqty3 where '
        +'ic3batid = ' + sq + %char($pBatId) + sq
        +' group by ic3whse,ic3batid,ic3item,ic3hstlot';

       exec sql prepare cl2insel from :SqlStmt;
       exec sql declare cl2incsr dynamic scroll cursor for cl2insel;
       exec sql open cl2incsr;

       dow forever = forever;

         exec sql fetch next from cl2incsr
         into :cwhse,:cbatid,:citem,:clot,
              :cl1qty1,:cl1qty2,:cl1qty3;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         GetItem(cwhse: citem);

         // rollup breakdowns properly
         if (cl1qty2<>0 and $itumq2<>0) or (cl1qty3<>0 and $itumq3<>0  );
           select;
             when cl1qty3 <> 0;
              //First, take to lowest level quantity based on breakdowns
               cltqty2 = ((cl1qty1 * $itumq2 * $itumq3) +
                         (cl1qty2 * $itumq3) +
                          cl1qty3);
               cltqty1=*zeros;
               cltqtyn=*zeros;
             when cl1qty2 <> 0;
               cltqty1 = ((cl1qty1 * $itumq2) +
                           cl1qty2);
               cltqtyn=*zeros;
               cltqty2=*zeros;
           endsl;
          //Next, roll back up with breakdown structure
           // check for negative quantities
           *in49=*off;
           if cltqtyn<0;
             *in49=*on;
             cltqtyn = %abs(cltqtyn);
           endif;
           if cltqty1<0;
             *in49=*on;
             cltqty1 = %abs(cltqty1);
           endif;
           if cltqty2<0;
             *in49=*on;
             cltqty2 = %abs(cltqty2);
           endif;

           dow $itumq3 > 0 and +
               cltqty2 >= $itumq3;
             cltqty2 -= $itumq3;
             cltqty1 += 1;
           enddo;

           dow $itumq2 > 0 and +
               cltqty1 >= $itumq2;
             cltqty1 -= $itumq2;
             cltqtyn += 1;
           enddo;

           if *in49;
             cltqtyn = cltqtyn * -1;
             cltqty1 = cltqty1 * -1;
             cltqty2 = cltqty2 * -1;
           endif;
           clcvt1 = cltqtyn;
           clcvt2 = cltqty1;
           clcvt3 = cltqty2;
         else;
           clcvt1 = cl1qty1;
           clcvt2 = cl1qty2;
           clcvt3 = cl1qty3;
         endif;
         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into comphost
            values ('H',:cwhse,:cbatid,:citem,:clot,
                    :cl1qty1,:cl1qty2,:cl1qty3,
                    :clcvt1,:clcvt2,:clcvt3,' ',' ',' ',' ',0,0,0,
                    :currstampsys,:currstampuc,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p clientHostLot   e

     *----------------------------------------------------------------
     *  clientItem      Process impscqty3 records to write comphost S
     *----------------------------------------------------------------

     p clientItem      b
     d clientItem      pi

      /free

       SqlStmt =
        'SELECT ic3whse,ic3batid,ic3item,'
        +'sum(ic3qty1),sum(ic3qty2),sum(ic3qty3) '
        +'from impscqty3 where '
        +'ic3batid = ' + sq + %char($pBatId) + sq
        +' group by ic3whse,ic3batid,ic3item';

       exec sql prepare cl1insel from :SqlStmt;
       exec sql declare cl1incsr dynamic scroll cursor for cl1insel;
       exec sql open cl1incsr;

       dow forever = forever;

         exec sql fetch next from cl1incsr
         into :cwhse,:cbatid,:citem,
              :cl1qty1,:cl1qty2,:cl1qty3;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         GetItem(cwhse: citem);
         // rollup breakdowns properly
         if (cl1qty2<>0 and $itumq2<>0) or (cl1qty3<>0 and $itumq3<>0  );
           select;
             when cl1qty3 <> 0;
              //First, take to lowest level quantity based on breakdowns
               cltqty2 = ((cl1qty1 * $itumq2 * $itumq3) +
                         (cl1qty2 * $itumq3) +
                          cl1qty3);
               cltqty1=*zeros;
               cltqtyn=*zeros;
             when cl1qty2 <> 0;
               cltqty1 = ((cl1qty1 * $itumq2) +
                           cl1qty2);
               cltqtyn=*zeros;
               cltqty2=*zeros;
           endsl;
          //Next, roll back up with breakdown structure
           // check for negative quantities
           *in49=*off;
           if cltqtyn<0;
             *in49=*on;
             cltqtyn = %abs(cltqtyn);
           endif;
           if cltqty1<0;
             *in49=*on;
             cltqty1 = %abs(cltqty1);
           endif;
           if cltqty2<0;
             *in49=*on;
             cltqty2 = %abs(cltqty2);
           endif;

           dow $itumq3 > 0 and +
               cltqty2 >= $itumq3;
             cltqty2 -= $itumq3;
             cltqty1 += 1;
           enddo;

           dow $itumq2 > 0 and +
               cltqty1 >= $itumq2;
             cltqty1 -= $itumq2;
             cltqtyn += 1;
           enddo;

           if *in49;
             cltqtyn = cltqtyn * -1;
             cltqty1 = cltqty1 * -1;
             cltqty2 = cltqty2 * -1;
           endif;
           clcvt1 = cltqtyn;
           clcvt2 = cltqty1;
           clcvt3 = cltqty2;
         else;
           clcvt1 = cl1qty1;
           clcvt2 = cl1qty2;
           clcvt3 = cl1qty3;
         endif;
         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into comphost
            values ('S',:cwhse,:cbatid,:citem,' ',
                    :cl1qty1,:cl1qty2,:cl1qty3,
                    :clcvt1,:clcvt2,:clcvt3,' ',' ',' ',' ',0,0,0,
                    :currstampsys,:currstampuc,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p clientItem      e

     *----------------------------------------------------------------
     *  createCompItem  Process dakota item file - snap shot
     *----------------------------------------------------------------

     p createCompItem  b
     d createCompItem  pi

      /free

       SqlStmt = 'select * '
               + 'from ' + 'piritem '
               + 'where itwhse=' + %char(whs#);

       exec sql prepare mstinsel from :SqlStmt;
       exec sql declare mstincsr dynamic scroll cursor for mstinsel;
       exec sql open mstincsr;

       dow forever = forever;

         exec sql fetch next from mstincsr into :itrec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // need to get slot item for S or A types, otherwise slot item=item
         sltwhse = itwhse;
         GetSlotItm(sltwhse:
                    itItem:
                    sltitem:
                    slttype:
                    sltdesc:
                    sltpdsc:
                    sltreturn:
                    sltmessage);

         getmicrotime(currstampuc:currstampsys);

         exec sql
          insert into compitem
            values (:itwhse,:$pBatId,:ititem,:ittype,:itdesc,
                    :itwhdp,:itum1,:itum2,:itumq2,:itflg1,
                    :itum3,:itumq3,:itflg2,:sltitem,:slttype,
                    :currstampsys,:currstampuc,:#prog,
                    :#user,:#jobn,:#jobnbr);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

      /end-free
     p createCompItem  e

     *----------------------------------------------------------------
     *  crtCompRPTDitm  Process host & dakota data for report
     *----------------------------------------------------------------

     p crtCompRPTDitm  b
     d crtCompRPTDitm  pi

      /free

       SqlStmt = 'select * '
               + 'from ' + 'complic '
               + 'where cplwhse=' + %char(whs#)
               +' and cpllevel=' + sq + 'S' + sq
               +' and cplbatid = ' + sq + %char($pBatId) + sq;

       exec sql prepare ds1insel from :SqlStmt;
       exec sql declare ds1incsr dynamic scroll cursor for ds1insel;
       exec sql open ds1incsr;

       dow forever = forever;

         exec sql fetch next from ds1incsr into :cplrec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // get the compitem data
         exec sql select * into :cpirec
              from compitem
              where cpiwhse = :cplWhse
                and cpibatid = :cplbatid
                and cpisitem  = :cplitem
                fetch first 1 rows only;

         // clear host converted qty
         CPHCQTY1 = 0;
         CPHCQTY2 = 0;
         CPHCQTY3 = 0;

         // clear host converted qty
         cpdiff1 = 0;
         cpdiff2 = 0;
         cpdiff3 = 0;
         cpdiffw = 0;
         cpdiffh = 0;

         // get the comphost data for the item
         exec sql select * into :cphrec
              from comphost
              where cphwhse = :cplWhse
                and cphbatid = :cplbatid
                and cphitem   = :cplitem
                and cphlevel  = 'S';

         // calculate difference
         cpdiff1 = cplcqty1 - cphcqty1;
         cpdiff2 = cplcqty2 - cphcqty2;
         cpdiff3 = cplcqty3 - cphcqty3;
         cpdiff1 = %abs(cpdiff1);
         cpdiff2 = %abs(cpdiff2);
         cpdiff3 = %abs(cpdiff3);
         if cpdiff1 <> 0 or cpdiff2 <> 0 or cpdiff3 <> 0;
           cpdiffw= 1;
         endif;

         exec sql insert into comprptd
            values (:cplwhse,'D',:cplbatid,'W','S',:cpiwhdp,
                    :cplitem,:cplitype,' ',' ',:cplitem,:cplitype,' ',
                    ' ',' ',' ',' ',:CPLCQTY1,:cpium1,:CPLCQTY2,
                    :cpium2,:CPLCQTY3,:cpium3,
                    :cphcqty1,:cphcqty2,:cphcqty3,
                    :cpdiff1,:cpdiff2,:cpdiff3,:cpdiffw,:cpdiffh);
         if sqlstt <> sqlSuccess;
           error = error;
         endif;
       enddo;

       // load any item records from comphost that don't exist in Dakota
       SqlStmt = 'select * '
               + 'from ' + 'comphost '
               + 'where cphwhse=' + %char(whs#)
               +' and cphlevel=' + sq + 'S' + sq
               +' and cphbatid = ' + sq + %char($pBatId) + sq;

       exec sql prepare hs1insel from :SqlStmt;
       exec sql declare hs1incsr dynamic scroll cursor for hs1insel;
       exec sql open hs1incsr;

       dow forever = forever;

         exec sql fetch next from hs1incsr into :cphrec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // check to see if it already is loaded in the comprptd file
         exec sql select * into :qcdrec
              from comprptd
              where qcdwhse = :cphWhse
                and qcdcompid = :cphbatid
                and qcdsltitem = :cphitem
                and qcdrulevel = 'W'
                fetch first 1 rows only;
         if sqlstt = sqlsuccess;
           iter;
         endif;
         // get the compitem data
         clear cpirec;
         exec sql select * into :cpirec
              from compitem
              where cpiwhse = :cphWhse
                and cpibatid = :cphbatid
                and cpisitem  = :cphitem
                fetch first 1 rows only;
         // clear host converted qty
         CPlCQTY1 = 0;
         CPlCQTY2 = 0;
         CPlCQTY3 = 0;

         // clear host converted qty
         cpdiff1 = 0;
         cpdiff2 = 0;
         cpdiff3 = 0;
         cpdiffw = 0;
         cpdiffh = 0;

         cpdiff1 = 0 - cphcqty1;
         cpdiff2 = 0 - cphcqty2;
         cpdiff3 = 0 - cphcqty3;
         cpdiff1 = %abs(cpdiff1);
         cpdiff2 = %abs(cpdiff2);
         cpdiff3 = %abs(cpdiff3);

         if cpdiff1 <> 0 or cpdiff2 <> 0 or cpdiff3 <> 0;
           cpdiffw= 1;
         endif;

         exec sql insert into comprptd
            values (:cphwhse,'H',:cphbatid,'W','S',:cpiwhdp,
                    :cphitem,:cpitype,' ',' ',:cphitem,:cpitype,' ',
                    ' ',' ',' ',' ',0,:cpium1,0,
                    :cpium2,0,:cpium3,
                    :cphcqty1,:cphcqty2,:cphcqty3,
                    :cpdiff1,:cpdiff2,:cpdiff3,:cpdiffw,:cpdiffh);
         if sqlstt <> sqlSuccess;
           error = error;
         endif;
       enddo;

       // need to update the comprpth file field qctextw(item aka Whse)
       exec sql select qcdwhse,qcdcompid,sum(qcddiffw)
                  into :hwhse,:hbatid,:wdiff
                 from comprptd
                where qcdrulevel = 'W'
                  and qcdcompid = :$pBatId
                  and qcdwhse = :whs#
                group by qcdwhse,qcdcompid;

         if sqlstt <> sqlSuccess;
         else;
           txtcnt = %char(wdiff) + ' differences found.';
           exec sql
             update comprpth
                set qchtextw = :txtcnt
              where qchcompid = :$pBatId;
         endif;
      /end-free
     p crtCompRPTDitm  e

     *----------------------------------------------------------------
     *  crtCompRPTDlot  Process host & dakota data for report
     *----------------------------------------------------------------

     p crtCompRPTDlot  b
     d crtCompRPTDlot  pi

      /free

       SqlStmt = 'select * '
               + 'from ' + 'complic '
               + 'where cplwhse=' + %char(whs#)
               +' and cpllevel=' + sq + 'H' + sq
               +' and cplbatid = ' + sq + %char($pBatId) + sq;

       exec sql prepare ds2insel from :SqlStmt;
       exec sql declare ds2incsr dynamic scroll cursor for ds2insel;
       exec sql open ds2incsr;

       dow forever = forever;

         exec sql fetch next from ds2incsr into :cplrec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // get the compitem data
         exec sql select * into :cpirec
              from compitem
              where cpiwhse = :cplWhse
                and cpibatid = :cplbatid
                and cpisitem  = :cplitem
                fetch first 1 rows only;

         // clear host converted qty
         CPHCQTY1 = 0;
         CPHCQTY2 = 0;
         CPHCQTY3 = 0;

         // clear host converted qty
         cpdiff1 = 0;
         cpdiff2 = 0;
         cpdiff3 = 0;
         cpdiffw = 0;
         cpdiffh = 0;

         // get the comphost data for the item
         exec sql select * into :cphrec
              from comphost
              where cphwhse = :cplWhse
                and cphbatid = :cplbatid
                and cphitem   = :cplitem
                and cphhstlot = :cplhstlot
                and cphlevel  = 'H';

         // calculate difference
         cpdiff1 = cplcqty1 - cphcqty1;
         cpdiff2 = cplcqty2 - cphcqty2;
         cpdiff3 = cplcqty3 - cphcqty3;
         cpdiff1 = %abs(cpdiff1);
         cpdiff2 = %abs(cpdiff2);
         cpdiff3 = %abs(cpdiff3);

         if cpdiff1 <> 0 or cpdiff2 <> 0 or cpdiff3 <> 0;
           cpdiffh= 1;
         endif;

         exec sql  insert into comprptd
            values (:cplwhse,'D',:cplbatid,'H','H',:cpiwhdp,
                    :cplitem,:cplitype,' ',' ',:cplitem,:cplitype,' ',
                    ' ',' ',' ',:CPLHSTLOT,:CPLCQTY1,:cpium1,:CPLCQTY2,
                    :cpium2,:CPLCQTY3,:cpium3,
                    :cphcqty1,:cphcqty2,:cphcqty3,
                    :cpdiff1,:cpdiff2,:cpdiff3,:cpdiffw,:cpdiffh);
          if sqlstt <> sqlSuccess;
             error = error;
          endif;
       enddo;

       // load any item records from comphost that don't exist in Dakota
       SqlStmt = 'select * '
               + 'from ' + 'comphost '
               + 'where cphwhse=' + %char(whs#)
               +' and cphlevel=' + sq + 'H' + sq
               +' and cphbatid = ' + sq + %char($pBatId) + sq;

       exec sql prepare hs2insel from :SqlStmt;
       exec sql declare hs2incsr dynamic scroll cursor for hs2insel;
       exec sql open hs2incsr;

       dow forever = forever;

         exec sql fetch next from hs2incsr into :cphrec;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

         // check to see if it already is loaded in the comprptd file
         exec sql select * into :qcdrec
              from comprptd
              where qcdwhse = :cphWhse
                and qcdcompid = :cphbatid
                and qcdsltitem = :cphitem
                and qcdhstlot  = :cphhstlot
                and qcdrulevel = 'H';
         if sqlstt = sqlsuccess;
           iter;
         endif;
         // get the compitem data
         clear cpirec;
         exec sql select * into :cpirec
              from compitem
              where cpiwhse = :cphWhse
                and cpibatid = :cphbatid
                and cpisitem  = :cphitem
                fetch first 1 rows only;
         // clear host converted qty
         CPlCQTY1 = 0;
         CPlCQTY2 = 0;
         CPlCQTY3 = 0;

         // clear host converted qty
         cpdiff1 = 0;
         cpdiff2 = 0;
         cpdiff3 = 0;
         cpdiffw = 0;
         cpdiffh = 0;

         cpdiff1 = 0 - cphcqty1;
         cpdiff2 = 0 - cphcqty2;
         cpdiff3 = 0 - cphcqty3;
         cpdiff1 = %abs(cpdiff1);
         cpdiff2 = %abs(cpdiff2);
         cpdiff3 = %abs(cpdiff3);

         if cpdiff1 <> 0 or cpdiff2 <> 0 or cpdiff3 <> 0;
           cpdiffh= 1;
         endif;

         exec sql insert into comprptd
            values (:cphwhse,'H',:cphbatid,'H','H',:cpiwhdp,
                    :cphitem,:cpitype,' ',' ',:cphitem,:cpitype,' ',
                    ' ',' ',' ',:cphhstlot,0,:cpium1,0,
                    :cpium2,0,:cpium3,
                    :cphcqty1,:cphcqty2,:cphcqty3,
                    :cpdiff1,:cpdiff2,:cpdiff3,:cpdiffw,:cpdiffh);
         if sqlstt <> sqlSuccess;
           error = error;
         endif;
       enddo;
       // need to update the comprpth file field qctexth(host)
       exec sql select qcdwhse,qcdcompid,sum(qcddiffh)
                  into :hwhse,:hbatid,:hdiff
                 from comprptd
                where qcdrulevel = 'H'
                  and qcdcompid = :$pBatId
                  and qcdwhse = :whs#
                group by qcdwhse,qcdcompid;

         if sqlstt <> sqlSuccess;
         else;
           txtcnt = %char(hdiff) + ' differences found.';
           exec sql
             update comprpth
                set qchtexth = :txtcnt
              where qchcompid = :$pBatId;
         endif;

      /end-free
     p crtCompRPTDlot  e

     *----------------------------------------------------------------
     *  updImport    Updates impscqty3 & stgbatch as processed
     *----------------------------------------------------------------

     p updImport       b
     d updImport       pi

      /free

        getmicrotime(currstampuc:currstampsys);
        // All done, mark records as processed.
        exec sql
          update stgbatch
          set sbstatus = 'S',
              sbtext   = 'Comparison report data is generated.',
              sbststs  = :currstampsys,
              sbstsuc  = :currstampuc,
              sbendts  = :currstampsys,
              sbenduc  = :currstampuc
          where sbwhse = :whs#
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;   // send error message
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: IT961S Comparison Report '
              + sqlstt + ' in staging batch ID ' + $pBatId
              + sq + ') TOUSR(*SYSOPR)';
          clen = %len(cmd);
          qcmdexc(cmd: clen);
        else;
          exec sql
          update impscqty3
          set ic3status = 'S',
              ic3text   = ' ',
              ic3ststs  = :currstampsys,
              ic3sstuc  = :currstampuc
          where ic3whse = :whs#
            and ic3batid = :$pBatId;
        endif;

      /end-free
     p updImport       e

     *----------------------------------------------------------------
     *  wrtDebugMsg    Write out debug message
     *----------------------------------------------------------------

     p WrtDebugMsg     b
     d WrtDebugMsg     pi

      /free

         bdvalues = debugMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         exec sql insert into bfcdebug values(:bdrec);

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p zzzdricop       b
     d zzzdricop       pi

     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      errmsg = $drimessage

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off

     p                 e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------




