      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SETRTEAUD   Set route orders audit flag
     *  19 October 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    10/19/18  DAS  7.20
     *      - Created
     *
720aA*    10/23/18  DAS  7.20a
     *      - Added expiration date
     *
730aA*    01/22/19  DAS  7.30a
     *      - Added ohaaudts field.
     *      - Set ohaaudcmp to 'N'.
     *      - Revised GetAuditId to us localized variables.
     *
740 A*    04/29/20  DAS  7.40
     *      - Call EXORDH as a change if the *ADD fails
     *
740aA*    06/03/20  KDE  7.40a
     *      - Force Customer Add if not found.  EXCUSTMAST will setup
     *        automated Audit for set number of days based on setting
     *        in GENPICK options for Customer Audit Duration setting
     *      - Mark Audit as No once date passes
     *
770aA*    11/01/23  KDE  7.70a
     *      - Fix:  Correct key issue on chain
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordh3     if   e           k disk    rename(ohrec:ohrec3)
     Fcustmast  if a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

710aAd today           s              8  0

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetAuditId      pr             5  0

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.excustma
     D/copy qcopysrc,p.exordh
     D/copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

       // Get today's date YYYYMMDD

       today = %dec(%date(%timestamp()):*iso);

       // Loop through orders for the route

       setll ($pwhse: $prtid) ordh3;

       dow forever = forever;

         reade ($pwhse: $prtid) ordh3;
         if %eof(ordh3);
           leave;
         endif;

         exWhse = $pwhse;
         excustmast ('*GET': exRtnCode: exRtnMsg: exWhse: ohcust:
720aM                cmaaudflg: cmaaudexpd :cmspflg: cmaudr);

740aA    if exRtnCode <> '*OK';
740aA      // if not found an add will be sent with no Audit.  EXCUSTMAST will
740aA      // look for Option that specifies a number of days for new customers
740aA      // to be audited.  If that setting is greater than zero the new customer
740aA      // will be setup for audits for that number of days
740aA      cmaaudflg='N';
740aA      cmaaudexpd=0;
740aA      cmspflg=*blanks;
740aA      cmaudr=*blanks;
740aA      excustmast ('*ADD': exRtnCode: exRtnMsg: exWhse: ohcust:
740aA                  cmaaudflg: cmaaudexpd: cmspflg: cmaudr);
740aA
740aA            // Create CUSTMAST if necessary
740aA
770aD            //chain (cmawhse: cmacust) custmast;
770aM            chain (exWhse: ohCust) custmast;
740aA            if not %found(custmast);
740aA              clear custrec;
740aA              cmwhse = exWhse;
740aA              cmcust = ohcust;
740aA              cmname = 'Create by SETRTEAUD';
740aA              cmstat = 'A';
740aA              cmaddts = %timestamp();
740aA              cmupdts = cmaddts;
740aA              cmjob = #job;
740aA              cmuser = #curruser;
740aA              cmjobnbr = #jobnbr;
740aA              write(e) custrec;
740aA           endif;
740aA    endif;

         if exRtnCode = '*OK' and cmaaudflg = 'Y';
720aM      if cmaaudexpd = 0 or today <= cmaaudexpd;

             ohaaudflg = 'Y';
             ohaaudid = GetAuditId();
730aM        ohaaudcmp = 'N';
             ohaaudby = 0;
730aA        clear ohaaudts;
             exordh ('*ADD': exRtnCode: exRtnMsg: exWhse: ohord:
730aM                ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts);
740 A        if exRtnCode = '*ERROR';
740 A          exordh ('*CHANGE': exRtnCode: exRtnMsg: exWhse: ohord:
740 A                  ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts);
740 A        endif;

             if exRtnCode = '*OK' and ohaaudflg = 'Y';

             endif;

740aA      else;
740aA        cmaaudflg='N';
740aA        cmaaudexpd=0;
740aA        cmaudr=*blanks;
740aA        excustmast ('*CHANGE': exRtnCode: exRtnMsg: exWhse: ohcust:
740aA                    cmaaudflg: cmaaudexpd: cmspflg: cmaudr);
710aM      endif;
         endif;

       enddo;

       return;

      /end-free


     *----------------------------------------------------------------
     *  GetAuditId     Get audit id, must be unique within route
     *----------------------------------------------------------------

     p GetAuditId      b

     * Local Files

     Fordh3     if   e           k disk

     d GetAuditId      pi             5  0

     * Local File Data Structures

     d locohrec        ds                  likerec(ohrec: *input)

     * Local Variables

     d id              s              5  0
     d idFound         s               n
     d ranNum          s              6  0
730aAd tmpaudflg       s                   like(ohaaudflg)
730aAd tmpaudid        s                   like(ohaaudid)

      /free

       id = 0;

       // Loop until finding a unique audit id

       idFound = *off;

       dow forever = forever;

         random2 (0: 1: 99999: ranNum);

         // Loop through orders for the route

         setll ($pwhse: $prtid) ordh3;

         dow forever = forever;

           reade ($pwhse: $prtid) ordh3  locohrec;
           if %eof(ordh3);
             leave;
           endif;

           exWhse = $pwhse;
730aM      exordh ('*GET': exRtnCode: exRtnMsg: exWhse: locohrec.ohord:
730aM              tmpaudflg: tmpaudid);

730aM      if exRtnCode = '*OK' and ranNum = tmpaudid;
             iter;
           endif;

           idFound = *on;
           leave;

         enddo;

         if idFound;
           id = ranNum;
           leave;
         endif;

       enddo;

       return id;

      /end-free

     p                 e

