      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETCUST   Keeps CUSTMAST and ORDHEXA updated as well returning
     *            numeric customer# and numeric customer order# when
     *            only alpha customer# and/or alpha customer order# sent
     *  23 April 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*   04/23/20  KDE  7.40
     *     - Created
750 A*   05/03/21  KDE  7.50
     *     - Change how next customer id and next order id
     *       are retrieved to always get the next lowest available
     *       id using SQL
750aA*   12/12/21  KDE  7.50a
     *     - Change GETCUST call to use ORDH instead of ORDH10
750bA*   12/22/21  KDE  7.50b
     *     - Remove order by clause and take first available OHCORD
     *       not being used in ORDH to speed up processing time
750cA*   01/05/22  KDE  7.50c
     *     - Change to use SQL view to help speed.  Also add clause
     *       "offset 0 rows to prevent sorting for lowest CORD value
     *       with fetch first 1 row only
     *       When taking this mod make sure you take view ORDH_OCORD
     *       from QDDSFILES, compile, and run for specific files libraries.
     *       CALL ORDH_OCORD ('PIRF' 'PIRF')
760 A*   04/26/22  KDE  7.60
     *     - Add logging to understand what is being slow
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program is called from the sales order import programs.
     *   The purpose is to always provide a numeric version of alpha
     *   customer# and alpha customer order#.  These values will be
     *   stored in CUSTMAST and ORDHEXA.  This process should be called
     *   right before we add the ORDH record in the import process.  This
     *   will assign numeric values when customer sends only alpha
     *   values and will be written into ORDH.
     *
     *   *INLR is only set on with *CLOSE is sent in.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
760 AFbfclog    o    e           k disk
     d custrec       e ds                  extname(custmast) inz(*EXTDFT)
     d oharec        e ds                  extname(ordhexa) inz(*EXTDFT)
     d ohrec         e ds                  extname(ordh) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d cnt             s              3  0
     d fldc            s              3  0
     d dblqte          s              1    inz('"')
     d backslash       s              1    inz('\')
     d singlequote     s              1    inz(x'7d')
     d spcChar         s              1
     d ordhexaExists   s               n
     d lastcust        s             11  0
     d lastorder       s              7  0
     D pos             s              3  0
     d rplspace        s              2    inz(' ')
     d todaydte        s               z
     d wkstr           s             40
760 AD logging         s               n
750 Ad minCust         s                   like(ohcust)
750 Ad minOrder        s                   like(ohcord)
750cAd wkRRN           s             12  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d doUpdate        pr

     d doGet           pr

     d rplChars        pr
760 Ad wrtlog          pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *  iCmd      - *GETALL, *GETORDER, *GETCUST, *UPDORDER
     *  iRtnCode
     *  iRtnMsg
     *  icmwhse  - Warehouse
     *  icmcust  - Customer number (Dakota Numeric)
     *  icmcusta - Customer number (Customer Alpha)
     *  icmname  - Customer name sent
     *  icmcad1  - Customer Address 1
     *  icmcad2  - Customer Address 2
     *  icmccty  - Customer City
     *  icmcst   - Customer State
     *  icmczip  - Customer Zip Code
     *  iohcord  - Customer order number (Customer numeric)
     *  iohcorda - Customer order number (Customer Alpha)
     *  iohord   - Customer order number (Dakota Numeric)
     *  iohrte   - Route Id
     *
     *----------------------------------------------------------------

     d GETCUST         pr                  extpgm('GETCUST')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  icmwhse                             like(cmwhse)
     d  icmcust                             like(cmcust)
     d  icmcusta                     30
     d  icmname                      40
     d  icmcad1                      40
     d  icmcad2                      40
     d  icmccty                      20
     d  icmcst                        2
     d  icmczip                      10
     d  iohcord                       7  0
     d  iohcorda                     15
     d  iohord                        7  0

     d GETCUST         pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  icmwhse                             like(cmwhse)
     d  icmcust                             like(cmcust)
     d  icmcusta                     30
     d  icmname                      40
     d  icmcad1                      40
     d  icmcad2                      40
     d  icmccty                      20
     d  icmcst                        2
     d  icmczip                      10
     d  iohcord                       7  0
     d  iohcorda                     15
     d  iohord                        7  0

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

       iRtnCode = '*OK';
       iRtnMsg = '';
760 A  logging = *on;

       // determine whether ORDHEXA exist.  This will
       // determine if used below in sql statements
       ordhexaExists = *on;
       monitor;
          exec sql select * into :oharec
                  from ordhexa
              fetch first row only;
       on-error;
         ordhexaExists = *off;
       endmon;

       select;

         when %subst(iCmd:1:4) = '*GET';
           doGet();

         when %subst(iCmd:1:4) = '*UPD';
           doUpdate();

         //*inlr = *on;

       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         iRtnCode = '*ERROR';
         iRtnMsg = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DoGet   Get record
     *----------------------------------------------------------------

     p DoGet           b
     d DoGet           pi

      /free
       // This routine will get and return customer#, Customer Order,
       // information with what was passed in.  If nothing is found
       // it will return an error

        // Warehouse must be sent for all commands
        if icmwhse = *zeros;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Warehouse cannot be zero';
          return;
        endif;

        select;
           when iCmd='*GETALL' or iCmd='*UPDORDER';

              // Information for "ALL" information being returned
              // must start with one of the order numbers
              if iohord=0 and iohcord=0 and iohcorda=*blanks;
                iRtnCode = '*ERROR';
                iRtnMsg = 'To return customer and order information ' +
                          'you must pass in either Dakota Order, ' +
                          'numeric Customer Order, or alpha Customer Order';
                return;
              endif;

              // perform reads based on incoming parms
              clear oharec;
              if ordhexaExists;
                 exec sql select * into :oharec
                             from ordhexa
                           where (ohawhse = :icmwhse and
                                  ohaord = :iohord) or
                                  ohaorda = :iohcorda
                             fetch first row only;
              endif;
              if sqlstt = '00000' and ohaord<>0 and ordhexaExists;
                 exec sql select ohcnam,ohcust into :icmcust,:icmname
                           from ordh
                        where ohwhse=:icmwhse and ohord=:ohaord
                           fetch first row only;
                 icmcusta = ohacusta;
                 iohcord = ohcord;
                 iohcorda = ohaorda;
                 iohord = ohaord;
                 iRtnMsg = *blanks;
                 return;
              else;
                 // the else here means nothings was found in ORDHEXA
                 // so we will pull what we can from ORDH and return it
                 exec sql select ohord,ohcust,ohcord,ohcnam
                            into :iohord, :icmcust, :iohcord, :icmname
                           from ordh
                        where ohwhse=:icmwhse and ohord=:iohord
                           fetch first row only;
                 icmcusta = *blanks;
                 iohcord = ohcord;
                 iohcorda = ohaorda;
                 iohord = ohaord;
                 iRtnMsg = *blanks;
                 return;
              endif;

           when iCmd='*GETCUST';

              // Customer information can be retrieved by sending only
              // customer information or the order information
              if iohord=0 and iohcord=0 and iohcorda=*blanks and
                 icmcust=0 and icmcusta=*blanks;
                 iRtnCode = '*ERRORS';
                 iRtnMsg = 'To return customer information you must either' +
                           ' send the numeric customer number, alpha ' +
                           'customer number, or either the Dakota order ' +
                           'number, Customer order number, or alpha Customer ' +
                           'order number';
                  return;
              endif;

              // if order information is sent to get customer use that first,
              // otherwise use the customer information
              select;
                when iohcorda<>*blanks or icmcusta<>*blanks;
                   if ordhexaExists;
                      exec sql select ohacusta,ohcust,ohcnam
                                into :icmcusta,:icmcust,:icmname
                                   from ordhexa, ordh
                              where ((ohawhse=:icmwhse and ohacusta=:icmcusta)
                                  or(ohawhse=:icmwhse and ohaorda=:iohcorda))
                                 and ohawhse=ohwhse and ohaord=ohord
                                   fetch first row only;
                   endif;
                   if sqlstt = '00000' and ordhexaExists;
                     iohcord = 0;
                     iohord = 0;
                     iRtnMsg = *blanks;
                     return;
                   else;
                     // coming here means either the ORDHEXA file
                     // does not exist or nothing found in it.  Either
                     // way we need to look in ORDH only
                     exec sql select ohcust, ohcnam
                            into :icmcust,:icmname
                                 from ordh
                         where ohwhse=:icmwhse and ohcust=:icmcust
                             fetch first row only;
                     if sqlstt = '00000';
                       icmcusta = *blanks;
                       iohcord = 0;
                       iohord = 0;
                       iRtnMsg = *blanks;
                       return;
                     else;
                       // no customer information found
                       iRtnCode = '*ERROR';
                       iRtnMsg = 'No customer information found';
                       return;
                     endif;
                   endif;
                 when iohcord  <> *zeros or icmcust<>*zeros or iohord<>*zeros;
                    exec sql select ohcust, ohcnam
                           into :icmcust,:icmname
                                from ordh
                        where (ohwhse=:icmwhse and ohcust=:icmcust) or
                              (ohwhse=:icmwhse and ohord=:iohord) or
                              (ohwhse=:icmwhse and ohcord=:iohcord)
                            fetch first row only;
                    if sqlstt = '00000';
                      icmcusta = *blanks;
                      iohcord = 0;
                      iohord = 0;
                      iRtnMsg = *blanks;
                      return;
                    else;
                      // no customer information found
                      iRtnCode = '*ERROR';
                      iRtnMsg = 'No customer information found';
                      return;
                    endif;
               endsl;

           when iCmd='*GETORDER';

              // Order information requires one of the order numbers
              // to be snet
              if iohord=0 and iohcord=0 and iohcorda=*blanks;
                 iRtnCode = '*ERRORS';
                 iRtnMsg = 'To order information you must send either ' +
                           'the numeric Dakota Order Number, ' +
                           'Customer order number, or the alpha Customer ' +
                           'order number';
                  return;
               endif;

               // start with ordhexa if it exist
               if ordhexaExists;
                  exec sql select ohaord,ohcord,ohaorda,ohcust,ohacusta
                           into :iohord,:iohcord,:iohcorda,:icmcust,:icmcusta
                           from ordhexa, ordh
                     where ((ohawhse=:icmwhse and ohaord=:iohord) or
                           (ohawhse=:icmwhse and ohcord=:iohcord) or
                           (ohawhse=:icmwhse and ohaorda=:icmcusta)) and
                           ohawhse=ohwhse and ohaord=ohord
                       fetch first row only;
               endif;
               if ordhexaExists and sqlStt='00000';
                 iRtnMsg = *blanks;
                 return;
               else;
                 // look in ordh only
                 exec sql select ohord,ohcord,ohcust
                        into :ohord,:ohcord, :ohcust
                           from ordh
                     where (ohwhse=:icmwhse and ohord=:iohord) or
                     (ohwhse=:icmwhse and ohcord=:iohcord)
                       fetch first row only;
                 if sqlstt = '00000';
                   iohcorda=*blanks;
                   icmcusta=*blanks;
                   iRtnMsg=*blanks;
                   return;
                 else;
                 endif;
               endif;

        endsl;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  doUpdate  -  Perform updates to ORDHEXA and CUSTMAST
     *----------------------------------------------------------------

     p doUpdate        b
     d doUpdate        pi

      /free

         // to perform updates the Dakota Order number must be passed
         // along with either an alpha or numeric customer number and
         // either an alpha or numeric customer order number
         if iohord = *zeros or (iohcorda=*blanks and icmcusta=*blanks);
            iRtnCode = '*ERROR';
            iRtnMsg  = 'In order to update you must send the Dakota ' +
                       'order along with either alpha customer number ' +
                       'and/or the alpha customer order number';
             return;
         endif;

         // now lets determine values and update the files and return
         // proper values to be placed on the incoming orders
         if not ordhexaExists;
           if icmcusta<>*blanks or iohcorda<>*blanks;
             iRtnCode = '*ERROR';
             iRtnMsg = 'ORDHEXA not found, and therefore no place to ' +
                       'store the alpha customer number or alpha ' +
                       'customer order number';
             return;
           endif;
         endif;

         select;
           when icmcusta<>*blanks or iohcorda<>*blanks;
             // first ensure the custmast is updated properly
             if icmcusta<>*blanks;
760 A *
760 A                    blgtext = 'check/get custmast ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', icmcusta:' + %trim(icmcusta);
760 A                    blgtype = 'CHKCUST';
760 A                    WrtLog();
760 A *
               exec sql select * into :custrec
                       from custmast
                   where cmwhse=:icmwhse and cmcusta=:icmcusta
                      fetch first row only;
               if sqlstt = '00000';
                 icmcust = cmcust;
                 // update customer address to ensure kept up todate
                 rplchars();
                 todaydte = %timestamp();
760 A *
760 A                    blgtext = 'update existing custmast ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', icmcust:' + %char(icmcust);
760 A                    blgtype = 'UPDCUST';
760 A                    WrtLog();
760 A *
                 exec sql update custmast
                      set cmname=:icmname, cmcad1=:icmcad1, cmcad2=:icmcad2,
                          cmccty=:icmccty, cmcst=:icmcst, cmczip=:icmczip,
                          cmupdts=:todaydte
                        where cmwhse=:icmwhse and cmcust=:icmcust;
               else;
                 // since record not found add record
                 lastcust = 0;

760 A *
760 A                    blgtext = 'add new custmast, next next number ---- ' +
760 A                              'icmwhse:' + %char(icmwhse);
760 A                    blgtype = 'GETCUSTNUM';
760 A                    WrtLog();
760 A *
750 A            // get lowest customer number
750 A            exec sql select min(cmcust) into :minCust
750 A                      from custmast
750 A                   where cmwhse=:icmwhse;
750 A            if minCust=1;
750 A              minCust=0;
750 A            endif;
                 // select next available customer number from customer master
760 A *
760 A                    blgtext = 'minCust + 1 custmast ---- ' +
760 A                              'icmwhse:' + %char(icmwhse);
760 A                    blgtype = 'GETMIN1';
760 A                    WrtLog();
760 A *
                 exec sql
                  select cst.cmcust - :minCust + 1 into :lastcust
                  FROM custmast as cst
750 D             //LEFT JOIN custmast AS alt
750 D             //ON alt.cmwhse = cst.cmwhse
750 D             //and  alt.cmcust = cst.cmcust + 1
750 D             //WHERE alt.cmcust IS NULL and cst.cmwhse=:icmwhse
750 A             where cst.cmwhse=:icmwhse
750 A             and not exists (select * from custmast as alt
750 A             where alt.cmwhse = cst.cmwhse
750 A             and alt.cmcust = cst.cmcust - :minCust + 1)
750 A             order by cst.cmwhse,cst.cmcust
                  fetch first row only;

                 if sqlstt <> '00000';
                   icmcust = 1;
                 else;
                   icmcust = lastcust;
                 endif;

                 // write new CUSTMAST record
                 monitor;
                    todaydte = %timestamp();
                    rplchars();
760 A *
760 A                    blgtext = 'insert new custmast ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', icmcusta:' + %trim(icmcusta);
760 A                    blgtype = 'INSERTCUST';
760 A                    WrtLog();
760 A *
                    exec sql insert into custmast
                         values(:icmwhse,:icmcust,:icmcusta,:icmname,
                              :icmcad1,:icmcad2,:icmccty,:icmcst,:icmczip,'A',
                              :todaydte,:todaydte,:#job,:#user,:#jobnbr);
                 on-error;
                 endmon;
               endif;
             endif;

             // now we need to setup an order id if alpha order was sent
             if iohcorda<>*blanks and iohcord=0;
               lastorder=0;

750 A          // get lowest order id
750bD          //exec sql select min(ohcord) into :minOrder
750aD                    //from ordh10
750bD          //          from ordh
750bD          //       where ohwhse=:icmwhse;
750bD          //if minOrder=1;
750bD          //  minOrder=0;
750bD          //endif;
750cA          // Add code to extract next available CORD id from ORDH
750cA          // using SQL view instead of straight query below.  if this
750cA          // fails it will use the straight query method.  Most likely
750cA          // failure would be if SQL view has not been built.  I have
750cA          // choosen that to confirm it exists to prevent the slowdown
750cA          // of checking.  Will place note up top when applying 750c change
760 A *
760 A                    blgtext = 'get next order number ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', ordh_cocord view';
760 A                    blgtype = 'NXTORD';
760 A                    WrtLog();
760 A *
750cA          exec sql
750cA               select rrn(ordh_ocord),nextcord into :wkrrn,:lastorder
750cA                       from ordh_ocord
750cA                 //where nextwhse = :icmwhse
750cA                 //order by rrn(ordh_ocord)
750cA                 //offset 0 rows
750cA                 fetch first 1 row only;
750cA          // If the query above fails because the view ordh_ocord
750cA          // is not found then use the stated query below.  We have
750cA          // introduced the view above thinking it will have a better
750cA          // response than running full query below each time.
750cA          if sqlstt = '42704';
760 A *
760 A                    blgtext = 'get next order number ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', ordh_cocord-failed';
760 A                    blgtype = 'NXTORDSQL';
760 A                    WrtLog();
760 A *
                 exec sql
750bD             //select ord.ohcord - :minOrder + 1 into :lastorder
750bM             select ord.ohcord + 1 into :lastorder
750aD             //FROM ordh10 as ord
750aM             FROM ordh as ord
750 D             //LEFT JOIN ordh10 AS alt
750 D             //ON alt.ohwhse = ord.ohwhse
750 D             //and alt.ohcord = ord.ohcord + 1
750 D             //WHERE alt.ohcord IS NULL and ord.ohwhse=:icmwhse
750 A             where ord.ohwhse=:icmwhse and
750aD             //not exists(select * from ordh10 as alt
750aM             not exists(select * from ordh as alt
750 A             where alt.ohwhse = ord.ohwhse
750bD             //and alt.ohcord = ord.ohcord - :minOrder + 1)
750bM             and alt.ohcord = ord.ohcord + 1)
750bD             //order by ord.ohwhse,ord.ohcord
                  fetch first row only;
750cA          endif;
               if sqlstt <> '00000';
                 iohcord = 1;
               else;
                 iohcord = lastorder;
               endif;
760 A *
760 A                    blgtext = 'chk/get ordhexa ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', iohord:' + %char(iohord);
760 A                    blgtype = 'GETORDEXA';
760 A                    WrtLog();
760 A *
               exec sql select ohaord into :iohord
                        from ordhexa
                  where ohawhse=:icmwhse and ohaord=:iohord;
               if sqlstt <> '00000';
                 // write new ORDHEXA record
                 monitor;
                   todaydte = %timestamp();
760 A *
760 A                    blgtext = 'add new ordhexa for order ---- ' +
760 A                              'icmwhse:' + %char(icmwhse) +
760 A                              ', iohord:' + %char(iohord);
760 A                    blgtype = 'GETORDEXA';
760 A                    WrtLog();
760 A *
                    exec sql insert into ORDHEXA
                         values(:icmwhse,:iohord,' ',0,' ',0,
                               :todaydte,:iohcorda,:icmcusta);
                 on-error;
                 endmon;
               endif;
             endif;

         endsl;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  rplchars  -  Replace characters that cause issue in SQL
     *----------------------------------------------------------------

     p rplchars        b
     d rplchars        pi

      /free
         fldc=1;
         // loop through each field with possible characters to cause
         // issue with the sql insert and replace those characters with
         // blank
         dow fldc<6;
           select;
             when fldc=1;
               wkStr = icmname;       // Customer Name
             when fldc=2;
               wkStr = icmcad1;       // Customer Address 1
             when fldc=3;
               wkStr = icmcad2;       // Customer Address 2
             when fldc=4;
               wkStr = icmccty;       // Customer City
             when fldc=5;
               wkStr = icmcst;        // Customer State
             when fldc=6;
               wkStr = icmczip;       // Customer Zip Code
           endsl;
           cnt=1;
           dow cnt<4;
             // interate 3 times replacing double quotes, single quotes and
             // back slashes with a space
             select;
               when cnt=1;
                 spcChar = dblqte;
               when cnt=2;
                 spcChar = singlequote;
               when cnt=3;
                 spcChar = backslash;
             endsl;
             // let's check for our special character and replace with space
             pos = %scan(spcChar: wkstr);
             dow pos > 0;
               wkstr = %replace(rplspace: wkstr: pos: %len(spcChar)) ;
               if (pos+%len(rplspace) > %len(wkstr));
                 pos = 0;
               else;
                 pos = %scan(spcChar: wkstr: pos+%len(rplspace));
               endif;
             enddo;
             cnt=cnt+1;
           enddo;
           select;
             when fldc=1;
               icmname = wkStr;       // Customer Name
             when fldc=2;
               icmcad1 = wkStr;       // Customer Address 1
             when fldc=3;
               icmcad2 = wkStr;       // Customer Address 2
             when fldc=4;
               icmccty = wkStr;       // Customer City
             when fldc=5;
               icmcst = wkStr;        // Customer State
             when fldc=6;
               icmczip = wkStr;       // Customer Zip Code
           endsl;
           fldc=fldc+1;
         enddo;
      /end-free

     p                 e

760 A*----------------------------------------------------------------
760 A*  wrtLog    Write out skip log record
760 A*----------------------------------------------------------------
760 A
760 Ap wrtlog          b
760 Ad wrtlog          pi
760 A
760 A /free
760 A
760 A    if not logging;
760 A      return;
760 A    endif;
760 A
760 A    blgaddpgm = #pgm;
760 A    blgcallpgm = 'OI335S';
760 A    blgcallcmd = icmd;
760 A    blgwhse = icmwhse;
760 A    blgrtid=' ';
760 A    blglbl# = 0;
760 A    blgrtid = '';
760 A
760 A    blgaddts = %timestamp();
760 A    blgstrts = blgaddts;
760 A    blgsec = 0;
760 A
760 A    blgtext = 'msg:' + blgtext;
760 A
760 A    blgaddcusr = #curruser;
760 A    blgaddjusr = #user;
760 A    blgaddjob = #job;
760 A    blgaddnbr = #jobnbr;
760 A
760 A    write(e) blgrec;
760 A
760 A /end-free
760 A
760 Ap                 e
