500gA /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)

      *----------------------------------------------------------------
      *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  RH600 - Pre-Invoice Shipping Document for Route/Stop
      *  Kenneth Elder
      *
650 A *    01/26/18  KDE  7.20
      *      - Created
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Notes
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *      *OPEN        Open program and return.
      *
      *      *CLOSE       Close program with *INLR = *ON
      *
      *
      *----------------------------------------------------------------
      *  Binding Directories
      *----------------------------------------------------------------

     Hbnddir('BFCBND')

      *----------------------------------------------------------------
      * File Specs
      *----------------------------------------------------------------
     frh600pr   o    e             printer oflind(*in90)
     fwarehsad  if   e           k disk

      *----------------------------------------------------------------
      * Function prototypes.
      *----------------------------------------------------------------

650aA /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti

      *----------------------------------------------------------------
      *  Customer id
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

      *----------------------------------------------------------------
      *  Data Formats
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT

      *----------------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

      *----------------------------------------------------------------
      *  Query used FOR ROUTE/ORDER DATA
      *----------------------------------------------------------------
     d rhrec           ds           368    Qualified
     D  rhwhse                        3  0
     D  rhrtid                        5
     D  rhrte                         5
     D  rtsst5                        2  0
     D  ohord                         7  0
     D  ohcord                        7  0
     D  ohcust                       11  0
     D  ohcnam                       40
     D  ohcad1                       40
     D  ohcad2                       40
     D  ohccty                       20
     D  ohcst                         2
     D  ohczip                       10
     D  ohcpo                        15
     D  odseq                         5  0
     D  oditem                       15
     d  odqor1                        5  0
     d  odqor2                        5  0
     d  odqor3                        5  0
     d  odqpk1                        5  0
     d  odqpk2                        5  0
     d  odqpk3                        5  0
     d  odstat                        1
     d  itpdsc                       15
     d  itswgt                        7  2
     d  itdesc                       30
     d  rhstst                        6  0
     d  rhstsd                        8  0
     d  itum1                         2
     d  itum2                         2
     d  itum3                         2
     d  itumq2                        3  0
     D  itwhdp                        3
     D  dept                         30A

     d prvrec          ds                  likeds(rhrec)

      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

     D bfcoffset       s              3  0 inz(0)
     d bdwght          s              9  4 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     d linectr         s              2  0
     d ic              s              3  0
     d Nullind         s              5i 0
     d pgetotbd        s              5  0
     d pgetotcase      s              5  0
     d stptotbd        s              5  0
     d stptotcase      s              5  0
     d stpweight       s              8  2
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D ucOffset        s              3  0
     d wkbrand         s              7
     d wkwgt           s              7  2
     d wkcnam          s             36
     d wkcnam1         s             36
     d wkcad1          s             36
     d wkcad11         s             36
     d wkcad2          s             36
     d wkcad21         s             36
     d wkcty           s             36
     d wkcty1          s             36
     d wkday           s              2
     d wkmnth          s              2
     d wkyear          s              2
     d wktime          s              5
     d wkpge           s              3  0
     d wkrte           s              5
     d wktele          s             13
     d wkstop          s              2  0
     d wkcpo           s             13
     d wkcust          s             11  0
     d wkcust1         s             11  0
     d wkshort1        s             35
     d wkshort2        s             35
     d wkinvno         s             14
     d wkout           s              5
     d wkdisp          s             12
     d pWhse           s              3  0

      *  Program information data structure
      *----------------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

      *----------------------------------------------------------------
      *  Parameters
      *

     c     *entry        plist
     c                   parm                    cWhse             3
     c                   parm                    pRteid            5

      /free
         // convert character warehouse to numeric
         monitor;
            pWhse = %dec(cWhse:3:0);
         on-error;
            pWhse = 001;
         endmon;

700eA    // Set SQL default parms
700eA    //exec sql
700eA    //  set Option Commit=*none, Dlyprp=*Yes,
700eA    //             Closqlcsr = *ENDMOD;

      /end-free

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

      /free

          // Setup sequel statement to read selected Route and order properly
          sqlstmt = 'select rhwhse,rhrtid,rhrte,rtsst5,ohord,ohcord,ohcust,' +
                    'ohcnam,ohcad1,ohcad2,ohccty,ohcst,ohczip,ohcpo,odseq,' +
                    'oditem,odqor1,odqor2,odqor3,odqpk1,odqpk2,odqpk3,' +
                    'odstat,itpdsc,itswgt,itdesc,rhstst,rhstsd,itum1, ' +
                    'itum2,itum3,itumq2,itwhdp, ' +
                    'case when itwhdp=' + sq + 'DRY' + sq + ' and itdesg=' +
                    sq + 'CHEM' + sq + ' then ' + sq + ' 98 - CHEMICALS' + sq +
                    ' when itwhdp =' + sq + 'DRY' + sq + ' and itdesg<>' +
                    sq + 'CHEM' + sq + ' then ' + sq + '01 - DRY GOODS' + sq +
                    ' when itwhdp=' + sq + 'CLR' + sq + ' then ' + sq +
                    '02 - COOLER' + sq + ' when itwhdp=' + sq + 'FRZ' + sq +
                    ' then ' + sq + '03 - FREEZER' + sq + ' else ' + sq +
                    '01 - DRY GOODS' + sq + ' end as dept' +
                    ' from rtehed,ordh,ordd,piritem,rtestp' +
                    ' where rhwhse =' + cWhse + ' and rhrtid=' + sq +
                    %trim(pRteId) + sq +
                    ' and rhwhse=ohwhse and rhrtid=ohrte and ohwhse=odwhse ' +
                    ' and ohord=odord and odwhse=itwhse and oditem=ititem' +
                    ' and rtswhs=rhwhse and rtsrid=rhrtid and rtsord=ohord' +
                    ' and rtsstp=ohstop' +
                    ' order by rhrtid,rtsst5,ohord,dept,odseq,oditem';

           exec sql PREPARE rh FROM :SqlStmt;
           exec sql DECLARE rhdta SCROLL CURSOR FOR rh;
           exec sql OPEN rhdta;

           exec sql fetch first from rhdta into :rhrec;

           prvrec.rhrtid=*blanks;
           prvrec.rtsst5=*zeros;
           wkstatic = '___cs  ___pk   r m  s  d   ck' + sq + 'd by ____';

           // Print first headings if data found
           //if sqlstt='00000' or sqlstt='01004';
              exsr headings;
           //endif;

           dow sqlstt='00000' or sqlstt='01004';

              // Print Totals and start new page if Route or Stop change
              if prvrec.rhrtid<>*blanks and (rhrec.rhrtid<>prvrec.rhrtid
                     or rhrec.rtsst5<>prvrec.rtsst5
                     or rhrec.ohord<>prvrec.ohord) or linectr>=45;
                 exsr totrtn;
              else;
              endif;

              // print detail line
              exsr prnt_Detl;

              prvrec = rhrec;
              exec sql fetch next from rhdta into :rhrec;
           enddo;

           exec sql CLOSE rhdta;
           // Print detail for last record and department total line
           *inlr = *on;
           exsr prnt_Detl;
           exsr totrtn;

          // Print Detail Line
           begsr prnt_Detl;

              // print department break when changes
              if prvrec.dept<>*blanks and rhrec.dept<>prvrec.dept;
                 wkdeptsub = '********** ' + %trim(prvrec.dept) +
                    ' *************************';
                 write deptsub;
                 linectr = linectr + 2;
              endif;

              if linectr >=45;
                 exsr totrtn;
              endif;

              // add to Stop and Route Totals
              pgetotcase = pgetotcase + rhrec.odqpk1;
              pgetotbd = pgetotbd + rhrec.odqpk2;
              stptotcase = stptotcase + rhrec.odqpk1;
              stptotbd = stptotbd + rhrec.odqpk2;

              wkseq = rhrec.odseq;
              wkcaseqty = rhrec.odqpk1;
              wkbdqty = rhrec.odqpk2;
              wkitem = rhrec.oditem;
              // remove leading zeros on item number
              ic=0;
              dow ic<10;
                 ic = ic + 1;
                 if %subst(wkitem:ic:1) = '0' or %subst(wkitem:ic:1)=' ';
                    %subst(wkitem:ic:1)=' ';
                    iter;
                 else;
                    wkitem = %trim(wkitem);
                    leave;
                 endif;
              enddo;
              wkpdsc = rhrec.itpdsc;
              wkdesc1 = rhrec.itdesc;


              exec sql select imbrnd into :wkbrand:Nullind  // get brand
                  from itemmsc where imwhse=:rhrec.rhwhse and
                       imitem=:rhrec.oditem;
              if nullind = -1;
                 wkbrand = *blanks;
              endif;

              exec sql select sum(occwgt) into :wkwgt:nullind  // get weight
                  from ordc
                 where ocwhse=:rhrec.rhwhse and ocord=:rhrec.ohord and
                       ocseq#=:rhrec.odseq and ocitem=:rhrec.oditem;
              if nullind=-1;
                 wkwgt=rhrec.itswgt * rhrec.odqpk1;
                 // if breakdown exist partial the weight
                 if rhrec.odqpk2<>0;
                    monitor;
                       bdwght = rhrec.itswgt/rhrec.itumq2;
                    on-error;
                       if rhrec.itswgt<>0;
                          bdwght = rhrec.itswgt;
                       else;
                          bdwght = 0;
                       endif;
                    endmon;
                    wkwgt = wkwgt + (rhrec.odqpk2 * bdwght);
                 endif;
              endif;
              stpweight = stpweight + wkwgt;

              exec sql select distinct lbdisp into :wkdisp:nullind  // get pick slot
                  from label14
                 where lbwhse=:rhrec.rhwhse and lbitem=:rhrec.oditem and
                       lbseq=:rhrec.odseq and lbord=:rhrec.ohord and
                       lbwhdp=:rhrec.itwhdp
                       fetch first row only;
              if nullind=-1;
                 wkdisp=*blanks;
              endif;

              // if no cases shipped move order qty in so OUT prints correctly
              // and customer knows how many were out
              if wkcaseqty=0 and rhrec.odqor1<>0;
                 wkcaseqty = rhrec.odqor1;
              endif;
              if wkbdqty=0 and rhrec.odqor2<>0;
                 wkbdqty = rhrec.odqor2;
              endif;

              linectr = linectr + 1;
              write detail;

              // if case quantity write C.O. indicator
              if wkcaseqty<>0 or wkbdqty<>0;
              // setup *OUT* print when nothing picked
                 if (rhrec.odqor1 + rhrec.odqor2 + rhrec.odqor3) <> 0
                    and (rhrec.odqpk1 + rhrec.odqpk2 + rhrec.odqpk3) = 0;
                    wkout = '*OUT*';
                    stpweight = stpweight - wkwgt;
                 else;
                    wkout = *blanks;
                 endif;
                 if wkcaseqty<>0;
                    wkcofld = 'C.O.';
                 else;
                    wkcofld = *blanks;
                 endif;
                 write cofldrec;
                 linectr = linectr +1;
              else;
                 wkcofld = *blanks;
              endif;

              // do not print check line or shorted if out completely
              if wkwgt<>0;
                 exsr chkShort;           // Check for shorts and outs
                 if wkshort1 <> *blanks;
                    linectr = linectr + 1;
                    write short1;        // print short line if populated
                 endif;
                 if wkshort2 <> *blanks;
                    linectr = linectr + 1;
                    write short2;        // print short line if populated
                 endif;
                 linectr = linectr + 1;
                 write detlchk;          // Check line for someone to check they received
              endif;

           endsr;

          // Populate fields and write Headings
           begsr headings;

              linectr=18;
              // form default invoice by warehouse
              chain (pWhse) warehsad;
              if %found(warehsad);
                 wkinvno = %trim(%subst(whaad1:1:14));
              else;
                 wkinvno = *blanks;
              endif;
              wkpge = wkpge + 1;
              wkcust1 = rhrec.ohcust;
              wkcnam = rhrec.ohcnam;
              wkcnam1 = rhrec.ohcnam;
              wkcad1 = rhrec.ohcad1;
              wkcad11 = rhrec.ohcad1;
              wkcad2 = rhrec.ohcad2;
              wkcad21 = rhrec.ohcad2;
              wkcty = %trim(rhrec.ohccty) + ',' + rhrec.ohcst + '  ' +
                      %trim(rhrec.ohczip);
              wkcty1 = %trim(rhrec.ohccty) + ',' + rhrec.ohcst + '  ' +
                      %trim(rhrec.ohczip);
              wktele = '(561)640-1007';
              wkcust = rhrec.ohcust;
              wktime = %subst(%editc(rhrec.rhstst:'X'):1:2) + ':' +
                       %subst(%editc(rhrec.rhstst:'X'):3:2);
              wkmnth = %subst(%editc(rhrec.rhstsd:'X'):5:2);
              wkday = %subst(%editc(rhrec.rhstsd:'X'):7:2);
              wkyear = %subst(%editc(rhrec.rhstsd:'X'):3:2);
              wkcpo = %char(rhrec.ohcord);
              wkrte = rhrec.rhrte;
              wkstop = rhrec.rtsst5;
              write heading;

           endsr;

           // determine if short or out
           begsr chkShort;
              wkshort1=*blanks;
              wkshort2=*blanks;
              wkout = *blanks;

              // at least some were in stock so now look for shorts
              if (rhrec.odqor1 + rhrec.odqor2 + rhrec.odqor3) >
                 (rhrec.odqpk1 + rhrec.odqpk2 + rhrec.odqpk3);
                 select;
                    // when both case and breakdown have different qty's
                    // ordered versus what was picked
                    when rhrec.odqor1 <> rhrec.odqpk1 and
                         rhrec.odqor2 <> rhrec.odqpk2;
                       wkshort1 = 'YOUR ORDER OF ' +
                                  %trim(%editc(rhrec.odqor1:'Z')) +
                                  ' ' + rhrec.itum1 + ' and ' +
                                 %trim(%editc(rhrec.odqor2:'Z')) + rhrec.itum2;
                       wkshort2 = 'WAS SHORTED BY ';
                       if rhrec.odqor1<>rhrec.odqpk1;
                          wkshort2 = wkshort2 +
                                 %trim(%editc(rhrec.odqor1-rhrec.odqpk1:'Z')) +
                                     ' ' + rhrec.itum1;
                       endif;
                       if rhrec.odqor2<>rhrec.odqpk2;
                          wkshort2 = wkshort2 + ' and ' +
                                 %trim(%editc(rhrec.odqor2-rhrec.odqpk2:'Z')) +
                                     ' ' + rhrec.itum2;
                       endif;
                    // when only case has different qty's
                    when rhrec.odqor1 <> rhrec.odqpk1;
                       wkshort1 = 'YOUR ORDER OF ' +
                                  %trim(%editc(rhrec.odqor1:'Z')) +
                                  ' ' + rhrec.itum1 +
                                  ' WAS SHORTED BY ';
                       wkshort2 = %trim(%editc(rhrec.odqor1-rhrec.odqpk1:'Z')) +
                                     ' ' + rhrec.itum1;
                    // when only breakdown two has different qty's
                    when rhrec.odqor2 <> rhrec.odqpk2;
                       wkshort1 = 'YOUR ORDER OF ' +
                                  %trim(%editc(rhrec.odqor2:'Z')) +
                                  ' ' + rhrec.itum2 +
                                  ' WAS SHORTED BY ';
                       wkshort2 = %trim(%editc(rhrec.odqor2-rhrec.odqpk2:'Z')) +
                                  ' ' + rhrec.itum2;
                 endsl;
              endif;

           endsr;

           // determine what to do depending on what is changing
           begsr totrtn;

              // if Route is changing or Stop is changing we should print
              // Total Qty Invoice and nothing in Estimated Total
              if (rhrec.rhrtid<>prvrec.rhrtid or rhrec.rtsst5<>prvrec.rtsst5
                    or rhrec.ohord <> prvrec.ohord)
                     or *inlr=*on;

                 // Print Department summary line and check line
                 wkdeptsub = '********** ' + %trim(prvrec.dept) +
                    ' *************************';
                 write deptsub;
                 linectr = linectr + 2;

                 write pgetot;
                 linectr=linectr+1;
                 write wgttot;
                 contfld = 'Completed';
                 write contrec;
                 linectr=linectr+1;
                 write stptot;
                 pgetotcase=*zeros;
                 pgetotbd = *zeros;
                 stptotcase=*zeros;
                 stptotbd = *zeros;
                 stpweight = *zeros;
                 prvrec=rhrec;
                 wkpge = 0;
                 if *inlr = *off;
                    // do not print headings on next page if end of job
                    exsr headings;
                 endif;
              else;
                 // page is full and need to start new page
                 if linectr>=45;
                    write pgetot;
                    pgetotcase=*zeros;
                    pgetotbd = *zeros;
                    stptotcase = stptotcase + rhrec.odqpk1;
                    stptotbd = stptotbd + rhrec.odqpk2;
                    write blkrec;
                    contfld = 'Continued';
                    write contrec;
                    exsr headings;
                 endif;
              endif;

           endsr;

      /end-free
