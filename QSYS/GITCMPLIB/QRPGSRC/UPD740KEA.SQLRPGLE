      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPD740KEA Update CUSTMAST and ORDHEXA with Alpha Customer
     *            and alpha Customer Order
     *  29 April 2020
     *  Kenneth Elder
     *  Requires data area NXTCUST
     *    NXTCUST is locked prior to GETCUST and released after writing or updating ORDH
     *
     *  Revisions
     *
740 A*   04/29/20  KDE  7.40
     *     - Created
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos Foods
     *
PANa *    04/29/20  KDE  PANa
     *      - Setup initial list of customers in CUSTMAST and ORDHEXA
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest
     *
SWTa *    04/29/20  KDE  SWTa
     *      - Setup initial list of customers in CUSTMAST and ORDHEXA
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBIa *    05/01/21  KDE  CBIa
     *      - Setup like Southwest to populate custmast and update ORDH
     *        with numeric customer number
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program is should be ran if a customer uses alpha
     *   customer numbers or alpha customer order numbers.  It will
     *   read through everything in ORDH and use Customer Specific
     *   code to retrieve the alpha customer number and alpha customer
     *   order number and call getcust.  Getcust will take those parms
     *   passed in and generate a CUSTMAST record to xref alpha customer
     *   number to a numeric value, write a record to ORDHEXA with the
     *   alphas for each, and update ordh numeric assign value for ohcust
     *   and ohcord.  Just add the respective customer to the respective
     *   existing customer that finds the correct customer data.  If a
     *   new customer stores that data elsewhere add another if for that
     *   customer.  Submit to QSYSNOMAX calling as CALL UPD740KEA (X'001F')
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d custrec       e ds                  extname(custmast) inz(*EXTDFT)
     d ohrec         e ds                  extname(ordh) inz(*EXTDFT)
     d hmrec         e ds                  extname(ordhm) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
PANaA /copy qcopysrc,id#pan
SWTaA /copy qcopysrc,id#swt
CBIaA /COPY QCOPYSRC,Id#CHENEY
PANaA /copy qcopysrc,p.getcust
PANaA /copy qcopysrc,p.exordh

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d wkorda          s             15
     d wkwhse          s              3  0
     d nxtcust         s              1    dtaara
PANaAd lower           c                   'abcdefghijklmnopqrstuvwxyz'
PANaAd UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
PANaAD @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *  icmwhse  - Warehouse
     *
     *----------------------------------------------------------------

     d UPD740KEA       pr                  extpgm('UPD740KEA')
     d  icmwhse                       3  0

     d UPD740KEA       pi
     d  icmwhse                       3  0

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
      /free
         // loop through Order Header and ensure CUSTMAST and ORDHEXA
         // are setup for all previous orders
         sqlstmt = 'Select * from ordh where (ohcust=0 or' +
                   ' ohcord=0) and ohwhse=' + %char(icmwhse);
         exec sql PREPARE oh FROM :SqlStmt;
         exec sql DECLARE ordhd SCROLL CURSOR FOR oh;
         exec sql OPEN ordhd;
         dow sqlstt = '00000';
           exec sql fetch next from ordhd into :ohrec;
           if sqlstt <> '00000';
             leave;
           endif;
PANaA      // Panos only has alpha customer number and they store it in
PANaA      // ORDHM, HMMSC1.  Any other customer the same way can be added
PANaA      // to this if statement and block of code
PANaA      if client = Panos;
PANaA        // Update CUSTMAST, OrdHexa and ORDH with numeric customer
PANaA        monitor;
PANaA          exrtnCode=*blanks;
PANaA          exrtnMsg=*blanks;
PANaA          wkorda=*blanks;
PANaA          // Panos sends an alpha Customer, but numeric order number
PANaA          // Therefore, we send 0 in ohcust, alpha customer in hmmsc1,
PANaA          // and blanks in wkorda for alpha customer order number
PANaA          clear oharec;
PANaA          exWhse = ohwhse;
PANaA          wkWhse = ohwhse;
PANaA          ohaord = ohord;
PANaA          ohaorda = *blanks;
PANaA          exec sql select * into :hmrec
PANaA               from ordhm where hmwhse=:ohwhse and hmord=:ohord;
PANaA          if sqlstt<>'00000';
PANaA            hmmsc1=*blanks;
PANaA          endif;
PANaA          ohacusta = hmmsc1;
PANaA          ohacusta = %xlate(lower:UPPER:ohacusta);
PANaA          exsr lockCust;
PANaA          getcust('*UPDORDER': exRtnCode: exRtnMsg: wkWhse: ohcust:
PANaA                   ohacusta: ohcnam: ohcad1: ohcad2: ohccty:
PANaA                   ohcst: ohczip:
PANaA                   ohcord: wkorda: ohord);
PANaA          exec sql update ordh set ohcust=:ohcust
PANaA                where ohwhse=:ohwhse and ohord=:ohord;
PANaA                out nxtCust;
PANaA        on-error;
PANaA        endmon;
PANaA    endif;

SWTaA      // Southwest uses a alpha customer and alpha customer order
SWTaA      // number.  These values are already stored in the ORDHEXA
SWTaA      // record so all this job needs to do is add the customer
SWTaA      // number to CUSTMAST and update OHCUST in ORDH with numeric
SWTaA      // assigned customer number
SWTaA      if client = SWT or client=cheney;
SWTaA        // Update CUSTMAST, OrdHexa and ORDH with numeric customer
SWTaA        monitor;
SWTaA          exrtnCode=*blanks;
SWTaA          exrtnMsg=*blanks;
SWTaA          wkorda=*blanks;
SWTaA          // Panos sends an alpha Customer, but numeric order number
SWTaA          // Therefore, we send 0 in ohcust, alpha customer in hmmsc1,
SWTaA          // and blanks in wkorda for alpha customer order number
SWTaA          clear oharec;
SWTaA          exWhse = ohwhse;
SWTaA          wkWhse = ohwhse;
SWTaA          exec sql select * into :oharec
SWTaA               from ordhexa where ohawhse=:ohwhse and ohaord=:ohord;
SWTaA          if sqlstt<>'00000';
SWTaA            ohacusta=*blanks;
SWTaA            ohaorda=*blanks;
SWTaA          endif;
SWTaA          exsr lockCust;
SWTaA          getcust('*UPDORDER': exRtnCode: exRtnMsg: wkWhse: ohcust:
PANaA                   ohacusta: ohcnam: ohcad1: ohcad2: ohccty:
PANaA                   ohcst: ohczip:
SWTaA                   ohcord: ohaorda: ohord);
SWTaA          exec sql update ordh set ohcust=:ohcust, ohcord=:ohcord
SWTaA                where ohwhse=:ohwhse and ohord=:ohord;
SWTaA          out nxtCust;
SWTaA        on-error;
SWTaA        endmon;
SWTaA    endif;
         enddo;
         exec sql close ordhd;
         *inlr=*on;

         // Routine to Lock Customer Data Area to
         // force the GETCUST to be single threaded.
         // The lock should be called prior to GETCUST
         // when doing an update command and after the
         // write or update to ORDH with the OHCUST
         // and OHCORD
         begsr lockCust;
            *in99=*on;
            dow *in99=*on;
              in(e) *lock nxtcust;
              // if no error on locking nxtcust it
              // will turn off in99 and fall out,
              // otherwise it will loop until it
              // can lock the data area
              *in99=%error;
            enddo;
         endsr;

      /end-free
