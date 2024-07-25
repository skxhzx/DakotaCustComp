      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM011  Update SUM011 file
     *             Used by Daily Selection Label Report
     *
     *  10 Dec 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    12/10/19  KDE  7.30
     *      - Created.
730aA*    12/19/19  KDE  7.30
     *      - Add code to include Return code and quantity information.
     *        It will loop through returns for a given day at the end of
     *        the process.  If original label is found and included it
     *        will associate to original pick, otherwise it will show as
     *        return on it's own
730bA*    01/03/20  KDE  7.30b
     *      - Use LABEL13 instead of LABEL32.  Also chain to ORDH
730cA*    01/07/20  KDE  7.30c
     *      - If not picked using voice or rf show scanned as no
730dA*    01/08/20  KDE  7.30d
     *      - Chain to order file for customer info since no longer
     *        using label32 with that information
740aA*    01/22/20  LMC  7.40a
     *      - Added logic to handle new selection type 6 - UPC
     *        verification - normal UOM only
740bA*    02/13/20  KDE  7.40b
     *      - Correct where report was not populating customer name
     *        with most current ordh read
740cA*    02/20/20  KDE  7.40c
     *      - When label not found in LABELDO get employee from
     *        PIRTRAND with label transaction, or add employee
     *        if no employee number associated to transaction.
     *        Also quit calling Returns processing
740dA*    09/10/20  KDE  7.40d
     *      - Correct issue with mod 740c
740eA*    12/22/20  KDE  7.40e
     *      - Fix:  Voice/UPC exceptions not cleared before each write,
     *        and therefore carried over potentially to next write
     *      - Fix:  Change to use VOEXCP instead of VOEXCP4.  It was
     *        finding incorrect labels by just looking for label
740fA*    12/08/20  RH   740f
     *      - Change CPJa mod to standard 740f
750fA*    01/21/22  LMC  750a
     *      - Change field SMRFV to shows the selection tool used.
     *        RF-RF Selection,SP-SelectPrime,V-Voice,NO-not on system
750bA*    01/24/22  LMC  750b
     *      - Change Selection logic, because we now check for each
     *        selection type individualy.
750cA*    01/24/22  LMC  750c
     *      - When getting employee from pirtrand3, need to read to
     *        get the current generated transaction. For clients who
     *        keep a fair amount of history, they can have the same
     *        transaction in the file with different generated dates.
750dA*    03/10/22  LMC  750d
     *      - SMSCAN field logic hadn't been updated since we added
     *        the location verification process.
760 A*    04/08/22  KDE  760
     *      - If transaction passed only process that route and transaction
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: CPJ Jamacia
CPJaA*    12/08/20  RH   CPJa
     *      - Revised to include Will Call Orders
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum011    uf a e           k disk
     frtehed8   if   e           k disk
730aAforrtn6    if   e           k disk
730aAfpiritem   if   e           k disk
730aAfordh      if   e           k disk
730dAfordhm     if   e           k disk
730aAfpirtran   if   e           k disk
740cAfpirtrand3 if   e           k disk
730aAfrtncode   if   e           k disk
730aAfpiruser   if   e           k disk    rename(usrec:usrec1)
730aAflabel     if   e           k disk    rename(lbrec:lbrec1)
730bMflabel13   if   e           k disk
     flabeldo   if   e           k disk
     fpiruser1  if   e           k disk
     fgloucicd  if   e           k disk
     fupc5      if   e           k disk
     fitemfld   if   e           k disk
     fupc1      if   e           k disk    rename(uprec:iprec1)
740eDf*voexcp4   if   e           k disk
740eMfvoexcp    if   e           k disk
     frunner6   if   e           k disk
     fldrhdetl  if   e           k disk
     fordhexa   if   e           k disk
     foptions   if   e           k disk

730dA*----------------------------------------------------------------
730dA*  Customer id
730dA*----------------------------------------------------------------
730dA
730dA /copy qcopysrc,id#grc
CPJaA /copy qcopysrc,id#cpj

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2
      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.driuci

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

730hA*----------------------------------------------------------
730hA*  SQL record layouts referenced
730hA*----------------------------------------------------------

730hAD slrecdd       E Ds                  Extname(Slot) prefix(s_)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d frmtnmCmd       s              8
     d inclIdle        s              1

     d cmpItem         s             15
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
730aAd hldEmp          s              5  0

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000
     D ucicnt          s                   like(lbqpck)
     d wktype          s              1
730aAd wkRqty          s              7  0
730aAd wkrqty1         s              5  0
730aAd wkrqty2         s              5  0
730aAd wkrqty3         s              5  0
760 Ad wkrte           s              5
760 Ad wkimpd          s              8  0
760 Ad wkimpt          s              6  0

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n
     D driUciCalled    s               n

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pTranNum       s              7p 0
     d  pRteid         s              5
     d  pPallid        s              7p 0
     d  pEmplist       s            500
730aAd  pRtnlist       s            196
     d  pfDateTime     s             14
     d  ptDateTime     s             14
     d  prfVoice       s              1
     d  pupcexists     s              1
     d  pvoerrors      s              1
     d  pitem          s             15

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
730aAd AddRtns         pr
730aAd getlabel        pr
     d DeleteRecs      pr
730bAd buildExcp       pr

730aA*----------------------------------------------------------------
730aA*  *GENPICK -  General picking options.
730aA*----------------------------------------------------------------
730aA*
730aA* Field required
730aA*
730aA*    OPRFUC  -  RF Pick Verify item with UPC.
730aA*
730aA* Data structure
730aA*
730aAD opdata          ds
730aAD  oprfuc                14     14
750dAD  oprvup                36     36  0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pErrMsg     Error Message
     *      pSessId     Session Id
     *      pWhse       Warehouse
     *      pTrannum    Selected Transaction
     *      pRteid      Selected Route Id
     *      pEmplist    Sected Employee List
     *      pfDateTime  Sected From Date and Time
     *      ptDateTime  Sected To Date and Time
     *      prfVoice    Sected RF/Voice Inclusion
     *      pUpcExists  Sected Upc Exists Inclusion
     *      pVoErrors   Select Voice/RF Errors
     *      pItem       Select specific Item
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pTrannum
     c                   parm                    pRteid
     c                   parm                    pPallid
     c                   parm                    pEmplist
730aAc                   parm                    pRtnlist
     c                   parm                    pfDateTime
     c                   parm                    ptDateTime
     c                   parm                    prfvoice
     c                   parm                    pupcexists
     c                   parm                    pvoerrors
     c                   parm                    pitem

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add work records for Report Slots w/No Activity
        AddRecs();
740cD   // AddRtns();

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

730aA    chain (pWhse:'*GENPICK') options;
730aA    if not %found(options);
730aA      oprfuc = 'N';
730aA    endif;

      /end-free
730dA
730dA* Get client id.
730dA
730dAC                   call      'GETCLIENT'
730dAC                   parm                    client           10
730dAC                   parm                    clientloc        10
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D wkcFile         s             14
     D wkfDate         s              8  0
     D wkfTime         s              6  0

      /free

760 A   // If transaction passed then get route
760 A   wkrte=*blanks;
760 A   if pTranNum <> 0;
760 A     exec sql select lbrte,rhimpd,rhimpt into :wkrte,:wkimpd,:wkimpt
760 A               from label,rtehed
760 A               where lbtrn#=:pTranNum and rhwhse=lbwhse and
760 A                      rhrtid=lbrte
760 A          fetch first row only;
760 A     if sqlstt='00000';
760 A       pfdatetime = %editc(wkimpd:'X') + %editc(wkimpt:'X');
760 A       ptdatetime = %editc(wkimpd:'X') + %editc(wkimpt:'X');
760 A     endif;
760 A   endif;

        // Breakout From Import Date and Time to set limits on Rtehed
        wkfdate = %dec(%subst(pfdatetime:1:8):8:0);
        wkftime = %dec(%subst(pfdatetime:9:6):6:0);

        // Loop thru Route Head based on passed in Date and Time Range
        setll (pWhse:wkfdate:wkftime) rtehed8;
        dow forever=forever;
          read rtehed8;
          if %eof(rtehed8);
            leave;
          endif;

          // Convert Date and time to ensure in range
          wkcfile = %editc(rhimpd:'X') + %editc(rhimpt:'X');
          if wkcFile < pfdatetime or wkcFile > ptDateTime;
            leave;
          endif;

          // skip unwanted records
CPJaD     //if (rhstat='5' or rhstat='6') and rhtype=' ';
740fM     if (rhstat='5' or rhstat='6');
            // Process
          else;
            // otherwise skip route
            iter;
          endif;

760 A    // if transaction passed then process only route associated to it
760 A     if pTranNum<>0 and wkrte<>*blanks;
760 A       if rhrtid<>wkrte;
760 A         iter;
760 A       endif;
760 A     endif;

          // Loop Label Data
730bM     setll (rhwhse:rhrtid) label13;
          dow forever=forever;
730bM       reade (rhwhse:rhrtid) label13;
730bM       if %eof(label13) or not %equal(label13);
              leave;
            endif;

            // Process Type M's only
            if lbtype='M' or (pitem<>*blanks and pitem<>lbitem);
              iter;
            endif;

760 A       // If transaction passed then process only that transaction
760 A       if pTranNum<>0;
760 A         if lbtrn#<>pTranNum;
760 A           iter;
760 A         endif;
760 A       endif;

750cA       // Bypass lbtype = 'A'
750cA       if lbtype='A';
750cA         iter;
750cA       endif;
730aA
730aA       chain (lbWhse:lbitem) piritem;
730aA       if not %found(piritem);
730aA         itdesc=*blanks;
730aA         itwhdp=*blanks;
730aA       endif;

            // Format and Write record to Sum011
            smsessid=pSessId;
            smwhse=lbwhse;
            smrtid=rhrtid;
            smrte=rhrte;
            smtrn#=lbtrn#;
            smlbl#=lblbl#;
            smitem=lbitem;
            smdesc=itdesc;
            smdisp=lbdisp;
            smqalc=lbqalc;
            smqpck=lbqpck;
            smcube=lbcube;
            smwgt=lbswgt;
            smstop=lbstop;
            smcnam=ohcnam;
            smord=lbord;
            smpal#=lbpal#;
            smpaln=lbpal#;
            smimpd=rhimpd;
            smimpt=rhimpt;
            smwhdp=lbwhdp;
            smaddts=%timestamp;
            smuomi=lbucod + '-' + lbutyp;
730aA       smrcod=*blanks;
730aA       smrdsc=*blanks;
730aA       smrqty= *zeros;
740eA       smvoex=*blanks;

730dA       // Get Customer Order and Customer Number Information
730dA       chain (pWhse:lbord) ordh;
730dA       if %found(ordh);
730dM         smorda=%editc(ohcord:'X');
730dM         smord=ohord;
730dM         smcusta=%editc(ohcust:'X');
740bA         smcnam=%trim(ohcnam);
730dA       else;
730dA         smorda=*blanks;
730dA         smord=0;
730dA         smcusta=*blanks;
740bA         smcnam=*blanks;
730dA       endif;
730dA       if client=greco;
730dA         chain (pWhse:lbord) ordhm;
730dA         if %found(ordhm) and hmmsc1<>*blanks;
730dA           smcusta=%trim(hmmsc1);
730dA         endif;
730dA       endif;
730dA       // if found in extension file override values
            chain (lbwhse:lbord) ordhexa;
            if %found(ordhexa);
               if ohaorda<>*blanks;
                  smorda=ohaorda;
               endif;
               if ohacusta<>*blanks;
                  smcusta=ohacusta;
               endif;
            endif;

            // Get Runner Quantity Found
            smqyfd=*zeros;
730aA       smrund=*blanks;
            chain (lbwhse:lblbl#) runner6;
            if %found(runner6);
               smqyfd=ruqyfd;
730aA          chain (rutrn#) pirtran;
730aA          if %found(pirtran);
730aA            chain (ptemp#) piruser1;
730aA            if %found(piruser1);
730aA              smrund = %trim(uscode) + '-' + %trim(usfnam) +
730aA                       ' ' + %trim(uslnam);
730aA            else;
730aA              smrund = %char(ptemp#);
730aA            endif;
730aA          endif;
            endif;

            // Get Loader Employee Number
730aA       smhemp=*blanks;
730aA       hldemp=*zeros;
730aA       exec sql select ldhemp into:hldemp
                     from ldrhdtl2
               where ldhwhs=:lbwhse and ldhrte=:rhrte and
                     ldhrti=:rhrtid and ldhpli=:lbpal#;
730aA       chain (hldemp) piruser1;
730aA       if %found(piruser1);
730aA         smhemp = %trim(uscode) + '-' + %trim(usfnam) + ' ' +
730aA                  %trim(uslnam);
730aA       else;
730aA         if hldemp<>*zeros;
730aA           smhemp = %char(hldemp);
730aA         endif;
730aA       endif;

            // Get Labeldo information
            smrfv='No';
            smlboe=*zeros;
            smlbon=*blanks;
            smlboq=*zeros;
            smpckts=nostamp;
            chain (lblbl#) labeldo;
            if %found(labeldo);
              select;
                when prfvoice='B';
                  // do nothing because all is being selected for report
750bD           //when prfvoice='Y';
750bD             // do nothing Yes and Labeldo record found
                when prfvoice='N';
                  // skip record since No and labeldo found
                  iter;
750bA           when prfvoice='V' and lboact <> 'VPICK';
750bA             // only get VPICK Action from labeldo
750bA             iter;
750bA           when prfvoice='R' and lboact <> 'RFPICK';
750bA             // only get RFPICK Action from labeldo
750bA             iter;
750bA           when prfvoice='S' and lboact <> 'SPPICK';
750bA             // only get SPPICK Action from labeldo
750bA             iter;
              endsl;
750aA         Select;
750aA           When lboact = 'VPICK';
750aA             smrfv='V';
750aA           When lboact = 'SPPICK';
750aA             smrfv='SP';
750aA           When lboact = 'RFPICK';
750aA             smrfv='RF';
750aA         endsl;
750aD         //smrfv='Yes';
              smlboe=lboemp#;
              chain (lboemp#) piruser1;
              if %found(piruser1);
                smlbon=%trim(usfnam) + ' ' + %trim(uslnam);
              else;
                smlbon='Not Found';
              endif;
              smlboq=lboqty;
              smpckts=lboaddts;
740cA       else;
750bA         if prfvoice <> 'N'
750bA            and prfvoice <> 'B';
750bA           iter;
750bA         endif;
740cA         // when labeldo not found then get employee from transaction
750cA         // must read and find transaction between the report date
750cA         setll (lbwhse:lbtrn#) pirtrand3;
750cA         dow forever = forever;
750cA           reade (lbwhse:lbtrn#) pirtrand3;
750cA           if %eof(pirtrand3);
750cA             leave;
750cA           endif;
750cA           if ptdstat < '1';
750cA             iter;
750cA           endif;
750cA           if ptdgdte < wkfdate;
750cA             iter;
750cA           endif;
750cD           //chain (lbwhse:lbtrn#) pirtrand3;
740cA           smlboe=ptdempnum;
740cA           chain (ptdempnum) piruser1;
740cA           if %found(piruser1);
740cA             smlbon=%trim(usfnam) + ' ' + %trim(uslnam);
740cA             if lbwhdp='*BULK';
740cA               smlbon = '*BULK ' + %trim(smlbon);
740cA             endif;
740cA           else;
740cA             // user userid from job for transaction
740dA             //chain (ptdaddusr) piruser;
740dA             //if %found(piruser);
740dA             //  smlboe=usemp#;
740dA             //  smlbon=%trim(usfnam) + ' ' + %trim(uslnam);
740dA             //  if lbwhdp='*BULK';
740dA             //    smlbon = '*BULK ' + %trim(smlbon);
740dA             //  endif;
740dA             //else;
740cA             smlbon=*blanks;
740dA             //endif;
740cA           endif;
750cA         enddo;
            endif;
            smtime=%char(%time(smpckts) : *HMS:);

            // get upc uom information
            chain (lbwhse:lbitem:lbutyp:lbucod) upc5;
            if %found(upc5);
              smupce='Yes';
              select;
                when pupcexists='B';
                  // do nothing.  Including whether there or not
                when pupcexists='Y';
                  // do nothing since found and user wants items defined
                when pupcexists='N';
                  // skip record since user only wants not defined
                  iter;
              endsl;
            else;
              smupce='No';
              select;
                when pupcexists='B';
                  // do nothing.  Including whether there or not
                when pupcexists='Y';
                  // skip since user only wants defined and this not defined
                  iter;
                when pupcexists='N';
                  // do nothing since user wants undefined and this not defined
              endsl;
            endif;

            // Determine Selection Method and whether scanned and Voice/RF Errors
            chain (lbwhse:lbitem) itemfld;
            if not %found(itemfld);
              ifsltmth='1';
            endif;

730aA       if ifsltmth = '1' and oprfuc='Y';
730aA          // if global upc pick verification then
730aA          // show as UPC pick if upc exist
730aA          chain (lbwhse:lbitem) upc1;
730aA          if %found(upc1);
730aA            Smselm = 'UPC Verification';
730aA          else;
730aA            smselm = 'Standard';
730aA          endif;
730aA        else;
               // get description for selection method
               chain ('UCI3': ifsltmth) gloucicd;
               if %found(gloucicd);
                 Smselm = gucdsc;
               endif;
730aA        endif;

            // now see if scanning was done.
            Select;
750dD         //when ifsltmth = '1' and oprfuc<>'Y';
750dM         when ifsltmth = '1' and oprfuc<>'Y' and oprvup = 0
750dA              or ifsltmth = '1' and smupce <>'Yes';
                smscan = 'N/A';
              when ifsltmth = '2';
                // uci scanning - check uciinfo file
                smscan = 'Yes';

                savever# = $uiver#;
                clear $uciinfo;
                clear $uciinfo2;
                $uiver# = savever#;

                // setup some data to pass to driuciinfo
                $uisellbl# = lblbl#;

                $uiwhse = lbwhse;
                $uiitem = lbitem;

                $dridata = $uciinfo;
                $dridata2 = $uciinfo2;
                driUCICalled = *on;
                driuciinfo('%CNT4LBL': $pprogram: $drireturn: $drimessage:
                         $dridata: $dridata2);
                // message will have the count
                ucicnt  = %dec($drimessage:5:0);
                if ucicnt = 0;
                  smscan = 'No';
                endif;

              when ifsltmth = '3';
                smscan = 'N/A';
              when ifsltmth = '4'
730aA              or ifsltmth = '1' and oprfuc='Y'
750dA              or ifsltmth = '1' and oprvup <> 0;
                // upc scanning - all uom - check voexcp
740eD           //setll (lbwhse: lblbl#) voexcp4;
740eM           setll (lbwhse: lbtrn#: lbitem:lblbl#) voexcp;
                smscan = 'Yes';
730bA           smvoex = *blanks;
                dow forever = forever;
740eD             //reade (lbwhse: lblbl#) voexcp4;
740eM             reade (lbwhse: lbtrn#: lbitem: lblbl#) voexcp;
740eD             //if %eof(voexcp4);
740eM             if %eof(voexcp);
                    leave;
                  endif;
730bA             buildExcp();
                  if sxerid = 'NOUPC' or
                    sxerid = 'BADUPC' or
                    sxerid = 'SKPSLT' or
750dA               sxerid = 'SKPLUPC' or
                    sxerid = 'SKPUPC';
                    smscan = 'No';
730bD               //leave;
                  endif;
               enddo;
              when ifsltmth = '5';
                if lbutyp <> 'N';
                  // upc scanning - breakdown uom only - check voexcp
740eD             //setll (lbwhse: lblbl#) voexcp4;
740eM             setll (lbwhse: lbtrn#: lbitem:lblbl#) voexcp;
                  smscan = 'Yes';
730bA             smvoex = *blanks;
                  dow forever = forever;
740eD               //reade (lbwhse: lblbl#) voexcp4;
740eM               reade (lbwhse: lbtrn#: lbitem: lblbl#) voexcp;
740eD               //if %eof(voexcp4);
740eM               if %eof(voexcp);
                      leave;
                    endif;
730bA               buildExcp();
                    if sxerid = 'NOUPC' or
                       sxerid = 'BADUPC' or
                       sxerid = 'SKPSLT' or
                       sxerid = 'SKPUPC';
                      smscan = 'No';
730bD                 //leave;
                    endif;
                  enddo;
                endif;
740aA         when ifsltmth = '6';
740aA           if lbutyp = 'N';
740aA             // upc scanning - normal uom only - check voexcp
740eD             //setll (lbwhse: lblbl#) voexcp4;
740eM             setll (lbwhse: lbtrn#: lbitem:lblbl#) voexcp;
740aA             smscan = 'Yes';
740aA             smvoex = *blanks;
740aA             dow forever = forever;
740eD               //reade (lbwhse: lblbl#) voexcp4;
740aA               reade (lbwhse: lbtrn#: lbitem: lblbl#) voexcp;
740eD               //if %eof(voexcp4);
740eM               if %eof(voexcp);
740aA                 leave;
740aA               endif;
740aA               buildExcp();
740aA               if sxerid = 'NOUPC' or
740aA                  sxerid = 'BADUPC' or
740aA                  sxerid = 'SKPSLT' or
740aA                  sxerid = 'SKPUPC';
740aA                 smscan = 'No';
740aA                 //leave;
740aA               endif;
740aA             enddo;
740aA           endif;
             endsl;

             // Include/Exclude based on RF/Voice Error Selection
             if pVoErrors<>'B';
                if pVoErrors='Y';
                   if smvoex=*blanks;
                      iter;
                   endif;
                else;
                   if smvoex<>*blanks;
                      iter;
                   endif;
                endif;
             endif;

             // Include only Employees selected if some were selected
             if smlboe<>*zeros and %trim(pEmpList)<>'' and
                                   %trim(pEmpList)<>'NULL';
                if %scan(%char(smlboe) : pEmpList) = 0;
                   iter;
                endif;
             endif;

730cA        // if not rf nor voice show as not scanned
730cA        if smrfv='No';
730cA          smscan='No';
730cA        endif;

             write smrec;

          enddo;
        enddo;

      /end-free


     p AddRecs         e
730aA
730aA*----------------------------------------------------------------
730aA*  AddRtns   Add returns.  If original label entered then update
730aA*            existing record in SUM011
730aA*----------------------------------------------------------------
730aA
730aAp AddRtns         b
730aAd AddRtns         pi
730aA
730aA*  Local Variables
730aA
730aAD wkcFile         s             14
730aAD wkfDate         s              8  0
730aAD wkfTime         s              6  0
730aA
730aA /free
730aA
730aA   // Breakout From Import Date and Time to set limits on Rtehed
730aA   wkfdate = %dec(%subst(pfdatetime:1:8):8:0);
730aA   wkftime = %dec(%subst(pfdatetime:9:6):6:0);
730aA
730aA   // Loop thru Returns for passed in Date and Time Range
730aA   setll (pWhse:wkfdate:wkftime) orrtn6;
730aA   dow forever=forever;
730aA
730aA     read orrtn6;
730aA     if %eof(orrtn6);
730aA       leave;
730aA     endif;
730aA
730aA     // Convert Date and time to ensure in range
730aA     wkcfile = %editc(orrdte:'X') + %editc(orrtim:'X');
730aA     if wkcFile < pfDateTime or wkcFile > ptDateTime;
730aA       leave;
730aA     endif;
730aA
730aA     // if Return codes were selected only show them
730aA     if pRtnList<>*blanks and %trim(pRtnList)<>'NULL';
730aA       if %scan(%trim(orrcod):pRtnList) = 0;
730aA         iter;
730aA       endif;
730aA     else;
730aA     endif;
730aA
730aA     clear smrec;
730aA     // Get Return Description
730aA     chain (orrcod) rtncode;
730aA     if %found(rtncode);
730aA       smrdsc = %trim(rncode) + '-' + %trim(rndesc);
730aA     else;
730aA       smrdsc = %trim(smrcod);
730aA     endif;
730aA
730aA     // setup return quantity based on case and breakdowns
730aA     wkrqty1=*zeros;
730aA     if orolb#<>*zeros;
730aA       exec sql select sum(orqty1)
730aA                   into :wkrqty1
730aA                       from orrtn
730aA                where orwhse=:pwhse and orolb#=:orolb# and
730aA                      oritem=:oritem;
730aA     else;
730aA       wkrqty1=orqty1;
730aA     endif;
730aA     wkrqty=wkrqty1;
730aA
730aA     // if Return codes not sent then make code blank
730aA     // It has already built description field with Return Code
730aA     // and Description that shows on report.  It shows on report
730aA     // if either blank or matching selection
730aA     if pRtnList=*blanks or %trim(pRtnList)='NULL';
730aA       orrcod=*blanks;
730aA     endif;
730aA
730aA     // if original label is populated then
730aA     // try and update original label in sum011.
730aA     // if found then iter, otherwise add return only data
730aA     if orolb#<>0;
730aA       exec sql update sum011 set smrcod=:orrcod, smrqty=:wkrqty,
730aA                                  smrdsc=:smrdsc
730aA                where smwhse=:pwhse and smlbl#=:orolb# and
730aA                      smsessid=:pSessid;
730aA       if sqlstt = '00000';
730aA         iter;
730aA       else;
730aA         getlabel();
730aA       endif;
730aA     endif;
730aA
730aA     chain (pWhse:oritem) piritem;
730aA     if not %found(piritem);
730aA       itdesc=*blanks;
730aA       itwhdp=*blanks;
730aA     endif;
730aA     // Format and Write return data to SUM011.  This means this
730aA     // return either had no original label or the original label
730aA     // in the record is not represented in the date range in sum011
730aA     smsessid=pSessId;
730aA     smwhse=orwhse;
730aA     smimpd=orrdte;
730aA     smimpt=orrtim;
730aA     smpckts=nostamp;
730aA     if lbwhse<>*zeros;
730aA       chain (pWhse:lbord) ordh;
730aA       if not %found(ordh);
730aA         ohcnam=*blanks;
730aA         ohcust=*zeros;
730aA       endif;
730aA       chain (lblbl#) labeldo;
730aA       if %found(labeldo);
730aA         smpckts=lboaddts;
730aA       endif;
730aA       smtime=%char(%time(smpckts) : *HMS:);
730aA       smrtid=lbrte;
730aA       exec sql select rhrte into :smrte
730aA                        from rtehed
730aA                 where rhwhse=:lbwhse and rhrtid=:lbrte;
740bM       smtrn#=ortrn#;
740bM       smlbl#=orolb#;
740bD       //smitem=lbitem;
740bM       smitem=oritem;
730aA       smdesc=itdesc;
730aA       smaddts=%timestamp;
730aA       smrqty=wkrqty;
730aA       smqalc=*zeros;
730aA       smqpck=*zeros;
730aA       smcube=*zeros;
730aA       smwgt=orcwtr;
730aA       smstop=lbstop;
730aA       smcnam=ohcnam;
730aA       smcusta=%editc(ohcust:'3');
730aA       smorda=%editc(ohcust:'3');
740bM       smord=oroord;
740bM       smpal#=*zeros;
730aA       smpaln=*zeros;
740bM       smwhdp=itwhdp;
740bM       smuomi=' ';
740bM       smdisp=' ';
730aA     else;
730aA       smrqty=wkrqty;
730aA       smitem=oritem;
730aA       smdesc=itdesc;
730aA     endif;
730aA     if smlbon=*blanks;
730aA       chain (orrusr) piruser;
730aA       if %found(piruser);
730aA         smlbon = %trim(uscode) + '-' + %trim(usfnam) + ' ' +
730aA                  %trim(uslnam);
730aA         smlboe = usemp#;
730aA       else;
730aA         smlbon = %trim(orrusr);
730aA         smlboe=*zeros;
730aA       endif;
730aA     endif;
730aA
730aA     write smrec;
730aA
730aA   enddo;
730aA
730aA /end-free
730aA
730aAp AddRtns         e
730aA
730aA*----------------------------------------------------------------
730aA*  getlabel   Get label and other data for returns with Original
730aA*             outside of date range
730aA*----------------------------------------------------------------
730aA
730aAp getlabel        b
730aAd getlabel        pi
730aA
730aA /free
730aA
730aA    chain (orolb#) label;
730aA    if not %found(label);
730aA      clear lbrec1;
730aA    endif;
730aA
730aA /end-free
730aA
730aAp getlabel        e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum011
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e

     *----------------------------------------------------------------
     *  buildExcp  -  Build fields with Voice/RF Exception codes
     *----------------------------------------------------------------

     p buildExcp       b
     d buildExcp       pi

      /free

        // If Skpupc and no upc defined then don't add to list of errors.
        // OR400 had issue fixed in MOD 730s which forced them thru upc
        // verification when one did not exist and user had to do skip upc
        if sxerid='SKPUPC' and smupce='No';
           return;
        endif;

        // ensure error code not already represented in list
        if %scan(%trim(sxerid):smvoex) <> 0;
        else;
          // Add error code to return string
          if smvoex=*blanks;
            smvoex=%trim(sxerid);
          else;
            smvoex = %trim(smvoex) + ',' + %trim(sxerid);
          endif;
        endif;

      /end-free

     p buildExcp       e
