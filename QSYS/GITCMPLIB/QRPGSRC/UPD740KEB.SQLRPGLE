      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPD740KEB Ensure all ORDH customers exist in CUSTMAST and
     *            CUSTMASTXA
     *  03 June 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*   06/03/20  KDE  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program should be ran to populate CUSTMAST and CUSTMASTXA
     *   with all customers found in ORDH.  Moving forward SETRTEAUD
     *   will populate with any new customers.  The reason it is an
     *   issue moving forward would be if the customer uses a new option
     *   in General Picking options that automatically sets up a customer
     *   Audit for new Customers.  That is determined based on whether
     *   the customer exists in CUSTMASTXA, therefore we need to start with
     *   all current customers populated
     *
     *----------------------------------------------------------------
     Fcustmast  if a e           k disk

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d ohrec         e ds                  extname(ordh) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,p.excustma

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d wkaudflg        s              1
     d wkaudexpd       s              8  0
     d wkspflg         s              1
     d wkaudr          s            500    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *----------------------------------------------------------------

     d UPD740KEA       pr                  extpgm('UPD740KEA')
     d  icmwhse                       3  0

     d UPD740KEA       pi
     d  icmwhse                       3  0

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

        *inlr=*on;

        // Loop thru Customer in ORDH to add to Customer Files
        sqlStmt = 'Select distinct ohwhse,ohcust from ordh';

        exec sql PREPARE cs FROM :SqlStmt;
        exec sql DECLARE csLst SCROLL CURSOR FOR cs;
        exec sql OPEN csLSt;
        dow forever=forever;
          exec sql fetch next from cslSt into :ohwhse, :ohcust;
          if sqlStt <> sqlSuccess;
            leave;
          endif;
         exWhse = ohwhse;
         excustmast ('*GET': exRtnCode: exRtnMsg: exWhse: ohcust:
                     wkaudflg: wkaudexpd :wkspflg :wkaudr);
         if exRtnCode <> '*OK';
           wkaudflg='N';
           wkaudexpd=0;
           wkspflg='N';
           wkaudr=' ';
           excustmast ('*ADD': exRtnCode: exRtnMsg: exWhse: ohcust:
                       wkaudflg: wkaudexpd :wkspflg :wkaudr);

740aA            // Create CUSTMAST if necessary
740aA            chain (cmawhse: cmacust) custmast;
740aA            if not %found(custmast);
740aA              clear custrec;
740aA              cmwhse = exWhse;
740aA              cmcust = ohcust;
740aA              cmname = 'Create by UPD740KEB';
740aA              cmstat = 'A';
740aA              cmaddts = %timestamp();
740aA              cmupdts = cmaddts;
740aA              cmjob = #job;
740aA              cmuser = #curruser;
740aA              cmjobnbr = #jobnbr;
740aA              write(e) custrec;
740aA           endif;
         endif;
        enddo;
        exec sql close csLSt;

      /end-free
