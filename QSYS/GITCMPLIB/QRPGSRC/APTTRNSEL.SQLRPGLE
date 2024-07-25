      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H bnddir('QC2LE':'QUSAPIBD':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 601510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  APTTRNSEL  Create Transaction Selection data for APT at Export time
     *  11 February 2022
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/11/22  KDE  7.50
     *      - Created
760 A*    04/11/22  KDE  7.60
     *      - Add parm to decide whether to remove and rewrite.
     *        WRTTRAND always sends 'N'.  You can manually run and pass
     *        'Y' to rewrite and resend ftp file
     *      - Ensure new files exist or simply exit
     *      - Change beginning flow of ADDTRN routine to reflect being
     *        called from WRTTRAND versus ADJTRAN2.  This code was
     *       necessary to wait and build multi-tran when last trans sent in
760aA*    04/13/22  KDE  7.60a
     *      - Add code to loop all pirtrand records for given transaction
     *        being ended.
760bA*    04/26/22  KDE  7.60b
     *      - Prevent duplicate key
     *      - Several other changes
760cA*    04/28/22  KDE  7.60c
     *      - Add routine chkMulTran to ensure all transactions are represented
     *        before we try anything in labeldo.  on rare occasion PIRTRAND
     *        records are being wiped and everything not being picked up when
     *        first transaction being processed but then second causes potential
     *        potential duplicate
     *      - Change addtrn to only process pirtrand if matches transaction or
     *        matches employee and is indirect/idle
     *
     *----------------------------------------------------------------
     *  Custom Revisions:
     *
     *  File Specs
     *
     Faptselwk  uf a e           k disk    rename(aptselr:aptr1) usropn
     faptkvimth if   e           k disk    usropn
     flabelw    if   e           k disk
     flabel7    if   e           k disk    rename (l7rec:l7rec1)
     foptions   if   e           k disk
     ftruckh    if   e           k disk
     fzoneh     if   e           k disk
760cAfpirtran   if   e           k disk
     fpirtrand  if   e           k disk
     fpirtrand2 if   e           k disk    rename(ptdrec:ptdrec2)
     fpirtrand3 if   e           k disk    rename(ptdrec:ptdrec3)
     fmultran   if   e           k disk
     fmultran3  if   e           k disk    rename(murec:murec3)
     fpltsum4   if   e           k disk
     Fbfcsktlog o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#YHATA

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#APT
     *
     *----------------------------------------------------------------
     *  Variables
     *
     D today           s              8  0
     d first           s               n
     d firstLoop       s               n
     d firstlbo        s               n
     d lbo             s               n
     d badReadCnt      s              2  0
     d goodRead        c                   00000
     d apzonedhld      s                   like(apzoned)
     d endUsed         s               n
     d loopCnt         s              4  0
     d kcnt            s              3  0
     d tcnt            s              3  0
     d totalsOnly      s               n
     d lboStmt         s           2048
     d sqlInStmt       s           2048
     d strStmt         s           2048
     d lblListStr      s           1000
     d nxtseq          s              3  0
     d tottrns         s              2  0
760aAd mlblcnt         s              3  0
     d strLoc          s              8
     d keepFirst       s              8
     d endLoc          s              8
     d truckTmpl       s             10
     d dftTS           s               z   inz(z'0001-01-01-00.00.00.000000')
     d lstactts        s                   like(apactts)
760aAd lsts            s               z
760aAd lets            s               z
760AAd lemp#           s              5  0
     D chk4err         s               n
     D drierr          s               n
     D zmsflag         s               n
     d errmsg          s             50
     d logapt          s               n   inz(*on)
     D saveVer#        s                   like($apver#)
     d useFonly        s               n   inz(*on)
     d lastdisp        s                   like(lbdisp)
760aAd lastBatch       s               n
760aAd maxEts          s               z
760aAd maxEtsz         s               z
760aAd nxtTs           s                   like(apactts)
     d wkMwhdp         s                   like(lbwhdp)
     d wkEmp#          s                   like(ptdEmpNum)
760aAd wktran          s              7  0
760aAd wkstat          s              1
760aAd wkwhse          s              3  0
760aAd wksel           s              1  0
760aAd wkseli          s              1  0
760cAd wkind           s              1  0
760cAd wkindi          s              1  0
760aAd wksts           s               z
760aAd wkets           s               z
760aAd wktask          s              6
     d wkOtype         s              1
     d  spUid          s             32
     d multitran       s               n
760aAd trnExists       s               n
760 Ad wksdte          s              8  0
760 Ad wkstim          s              6  0
760 Ad wkedte          s              8  0
760 Ad wketim          s              6  0

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

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *  Track list of Transactions for use on Label file
     d lblList         s              7  0 dim(1000)
     *  Track list of Transactions for use in Missing Labels
760aAd mLblList        s              7  0 dim(1000)

     *----------------------------------------------------------------
     *  KVI Method Array
     *----------------------------------------------------------------
     D                 ds
     d kvim                                 dim(500)
     D  kmth                         20     overlay(kvim:*next)
     D  kfonly                        1     overlay(kvim:*next)

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#pgminfds
      /copy qcopysrc,p.bfcdteti

      *  Data Struction to hold all PIRTRAND records for
      *    passed in Transaction

     d                 ds
     d  allTrans                           dim(500)
     d   trnWhse                      3  0 overlay(allTrans)
     d   trnEmpnum                    5  0 overlay(allTrans:*next)
     d   trnSts                        z   overlay(allTrans:*next)

      *  Labeldo record
     D nextLbo       E Ds                  Extname(labeldo)
     D prevLbo       E Ds                  Extname(labeldo) prefix(p_)

      *  Label record
     D nextLbL       E Ds                  Extname(label)
     D prevLbL       E Ds                  Extname(label) prefix(p_)

      *  PIRTRAND - Indirect Entries
     D nextInd       E Ds                  Extname(pirtrand)

      *  APT Work File
     D nextAPT       E Ds                  Extname(aptselwk)

     *  used to pause/sleep process for specific period of seconds
     D sleep           pr            10u 0 extproc('sleep')
     D   Interval                    10u 0 value

     d writeVoiceLog   pr
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

     d GetCurrStamp    pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  Warehouse
     *      $pTran  Transaction
     *
     *    Returned Parameters
     *      pReturn Return *OK if update was without failure, otherwise
     *              return the appropriate error
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse            3 0
     C                   parm                    $pTran            7 0
     c                   parm                    $pCmd            10
760 Ac                   parm                    $pEmp             5 0
760 Ac                   parm                    $pReWrte          1
     C                   parm                    $pReturn         40
     *----------------------------------------------------------------
     *  Main line
     *                           addtrn
      /free
                         slgbuf = '<*ENTRY> '
                                + 'cmd=' + %trim($pCmd) + ' '
                                + 'user=' + %trimr(#curruser)  + ' '
                                + 'client=' + %trim(client) + ' '
                                + 'whs=' + %char($PWHSE)  + ' '
                                + 'trn=' + %char($ptran);
                         WriteVoiceLog ('Beg': slgbuf);

                         $pReturn = '*OK';
                         *inlr=*on;

                         select;
                           when $pCmd = '*EXPTRN';
                             exsr expaptdta;
                           when $pCmd = 'CRTAPTDTA';
                             exsr confgood;
                             exsr addTrn;
                         endsl;

760 A                    if %open(aptselwk);
760 A                      close aptselwk;
760 A                    endif;
760 A
760 A                    if %open(aptkvimth);
760 A                      close aptkvimth;
760 A                    endif;
      /end-free
     *
     *  Return to calling program
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *    - Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     c                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     *
     *   Check for APT logging option
      /free
                         chain ($pWhse:'*APTFTP') options;
                         if %found(options)
                            and %subst(opdata:1:1) = 'Y';
                           logapt = *on;
                         else;
                           logapt = *off;
                         endif;
                           logapt = *on;
      /end-free
760 A*
760 A*   Verify these files exist on this box.  If not then leave
760 A /free
760 A       open(e) aptselwk;
760 A       if %error;
760 A         return;
760 A       endif;
760 A
760 A       open(e) aptkvimth;
760 A       if %error;
760 A         return;
760 A       endif;
760 A /end-free
     C                   endsr

     *
     *----------------------------------------------------------------
     *
     *  loadKviRtn  Load KVI Routines for all KVI
     *
     C     loadKviRtn    begsr
      /free
      // Load proper methods to use for specific Transaction/Label
                        clear kvim;
                        useFonly = *off;
                        setll (client:cliloc:$pWhse:'SELECTION') aptkvimth;
                        dow forever=forever;
                          reade (client:cliloc:$pWhse:'SELECTION') aptkvimth;
                          if %eof(aptkvimth);
                            leave;
                          endif;
                          if apmztmp=' ' and apmzone=' ';
                            select;
                              when apmmeth = 'RKVI' + %editc(apmkvi:'X');
                                if kmth(apmkvi) = *blanks;
                                  // only use default if another more defined
                                  // routine has not already been applied for
                                  // this particular KVI number
                                  kmth(apmkvi)=apmmeth;
                                  kfonly(apmkvi)=apmfonly;
                                  if apmfonly='Y';
                                    useFonly = *on;
                                  endif;
                                endif;
                              other;
                                kmth(apmkvi)=apmmeth;
                                kfonly(apmkvi)=apmfonly;
                                if apmfonly='Y';
                                  useFonly = *on;
                                endif;
                            endsl;
                          else;
                             // when record read with criteria compare to see
                             // if it is a fit.
                             // If nay of the data is selected and not a match
                             // we iter to the next record.
                             if apmwhse <> 0;                    // check warehouse
                               if apmwhse <> $pWhse;
                                 iter;
                               endif;
                             endif;
                             if apmclnt <> *blanks;              // confirm client
                               if apmclnt <> client;
                                 iter;
                               endif;
                             endif;
                             if apmclnt2 <> *blanks;             // confirm client2
                               if apmclnt2 <> cliloc;
                                 iter;
                               endif;
                             endif;
                             if apmztmp<> *blanks;
                               // get template for truck
                               chain ($pwhse:psTruk) truckh;
                               if apmztmp <> thztmp;
                                 iter;
                               endif;
                             endif;
                             if apmzone<> *blanks;
                               if apmzone <> psszon;
                                 iter;
                               endif;
                             endif;
                             kmth(apmkvi) = apmmeth;
                             kfonly(apmkvi) = apmfonly;
                             if apmfonly='Y';
                               useFonly = *on;
                             endif;
                             // If it made it through the checks and iters above
                             // that means this is a match for the current label
                             kmth(apmkvi)=apmmeth;
                             kfonly(apmkvi)=apmfonly;
                             if apmfonly='Y';
                               useFonly = *on;
                             endif;
                           endif;
                        enddo;
      /free
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  confGood  Confirm this is a good Transaction before moving forward
     *
     C     confGood      begsr
      /free
           // Do not process transactions for Will Call orders, or
           // Transactions with Zero Employee
           exec sql select ptemp#,ohtype into :wkEmp#,:wkotype
                  from pirtran,label,ordh
             where ptwhse=lbwhse and pttrn#=lbtrn# and
                   lbwhse=ohwhse and lbrte=ohrte
                    and pttrn#=:$pTran
                  fetch first row only;
              slgbuf = '<CONFGOOD> '
                   + 'cmd=' + %trim($pCmd) + ' '
                   + 'user=' + %trimr(#curruser)  + ' '
                   + 'client=' + %trim(client) + ' '
                   + 'whs=' + %char($PWHSE)  + ' '
                   + 'trn=' + %char($ptran) + ' '
                   + 'logapt=' + %char(logapt) + ' '
                   + 'wkemp#=' + %char(wkemp#) + ' '
                   + 'wkotype=' + wkotype + ' '
                   + 'sqlstt=' + sqlstt;
              WriteVoiceLog ('Beg': slgbuf);
           if sqlstt <> '00000' or wkEmp#=0;
             return;
           endif;
      /free
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  addTrn  Add Transaction data for APT as transactions are ended
     *
     C     addTrn        begsr
     *
      /free

760aA       // loop all pirtrand records for specific transaction being
760aA       // ended.  Will read each pirtrand for transaction and then
760aA       // do inter loop looking for any other trand records with
760aA       // same employee, start and end times to treat as multitran.
760aA       // When that looping ends we will check to see if missing any
760aA       // labels and write them if we are
760cA       exec sql select ptedte,ptetim into :ptedte,:ptetim
760cA                   from pirtran
760cA                where pttrn#=:$pTran;
760cA       if sqlstt <> '00000';
760cA         *inlr=*on;
760cA         return;
760cA       else;
760cA         monitor;
760cA         maxets = %timestamp(%subst(%char(ptedte):1:4) + '-' +
760cA                             %subst(%char(ptedte):5:2) + '-' +
760cA                             %subst(%char(ptedte):7:2) + '-' +
760cA                             %subst(%editc(ptetim:'X'):1:2) + '.' +
760cA                             %subst(%editc(ptetim:'X'):3:2) + '.' +
760cA                             %subst(%editc(ptetim:'X'):5:2) + '.' +
760cA                             '999999');
760cA         maxetsz = %timestamp(%subst(%char(ptedte):1:4) + '-' +
760cA                             %subst(%char(ptedte):5:2) + '-' +
760cA                             %subst(%char(ptedte):7:2) + '-' +
760cA                             %subst(%editc(ptetim:'X'):1:2) + '.' +
760cA                             %subst(%editc(ptetim:'X'):3:2) + '.' +
760cA                             %subst(%editc(ptetim:'X'):5:2) + '.' +
760cA                             '000000');
760cA         on-error;
760cA           // return without doing anything if end time is bad
760cA           *inlr=*on;
760cA           return;
760cA         endmon;
760cA       endif;

760aA       lsts=dftts;
760aA       lets=dftts;
760aA       lemp#=0;
760aA       sqlStmt = 'select a.ptdwhse,a.ptdtran,a.ptdempnum,a.ptdsts,' +
760aA                 'a.ptdets,a.ptdtask,a.ptdstat,a.ptdsel,a.ptdseli,' +
760cA                 'a.ptdind,a.ptdindi ' +
760aA                 'from pirtrand as a where ' +
760aA                 'a.ptdsts>=(select min(b.ptdsts) from pirtrand as b ' +
760aA                 'where b.ptdtran=' + %char($pTran) + ') and ' +
760aA                 'a.ptdets<=(select max(c.ptdets) from pirtrand as c ' +
760aA                 'where c.ptdtran=' + %char($pTran) + ') and ' +
760aA                 'a.ptdstat>' + sq + '0' + sq + ' and a.ptdstat<' +
760aA                 sq + '5' + sq + ' and ((a.ptdsel=1 or a.ptdseli=1) ' +
760aA                 'or ((a.ptdind=1 or a.ptdindi=1 or a.ptdtask=' +
760aA                 sq + 'IDLE' + sq + ')  and a.ptdempnum=' + %char($pEmp) +
760aA                 ')) and a.ptdets<>' + sq + '0001-01-01-00.00.00.000000' +
760aA                 sq + ' order by a.ptdsts';

760aA       exec sql PREPARE tdl FROM :sqlStmt;
760aA       exec sql DECLARE ptd SCROLL CURSOR FOR tdl;
760aA       exec sql OPEN ptd;

760aA       dow forever = forever;

760aA         exec sql fetch next from ptd into :wkwhse,:wktran,:wkemp#,
760aA                      :wksts,:wkets,:wktask,:wkstat,:wksel,:wkseli,
760cA                      :wkind,:wkindi;

760aA         if sqlstt <> '00000';
760aA           leave;
760aA         else;
              // if indirect or IDLE insert line for time
760aA         if (wksel<>1 and wkseli<>1) or wktask='IDLE';
                // if you un-remark this line it will generate idle and indirect records
                // between selection direct (ptdseli=1) transactions.  We probably need
                // to set a option to determine if user wants to write this way or write
                // out the way other processes write the indirects.  For Yhata we will have
                // to ensure however we do it that it is written from WRTTRAND to ensure it
                // is written real time to always send indirect in time order like we do selection
760aA           // exsr wrtInd;
760aA           iter;
760aA         endif;
                // ensure this is for the employee or transaction passed in. The
                // reason this can happen is because of trying to pull in ALL
                // transactions between start and end of Transaction.  This could
                // span over more than one transaction since a user can suspend
                // and also go to lunch or break during a transaction.  It handles
                // and figures out multiple transactions in the PIRTRAND2 loop below.
                // In that loop it reads every transaction for employee with same
                // start and end time and only proceeds if all have been ended/closed.
760cD           //if wktran<>$pTran and wkemp#<>$pEmp;
760cM           if wktran=$pTran or (wkemp#=$pEmp and (wkind=1 or wkindi=1
760cA                                 or wktask='IDLE'));
760cA             // only process if equal direct task passed in or the employee
760cA             // passed on along with being an indirect or idle transaction
760cA           else;
                  iter;
                endif;
760aA           // do not process more than one trand with same employee,start and end time
760aA           if lemp#=wkemp# and lsts=wksts and lets=wkets;
760aA             iter;
760aA           else;
760aA             lemp#=wkemp#;
760aA             lsts=wksts;
760aA             lets=wkets;
760aA           endif;
760aA           // see if this is the max timestamp for this transaction
760aA           lastBatch = *off;
760aA           if wkets=maxets or wkets=maxEtsz;
760aA             lastBatch = *on;
760aA           endif;
760aA         endif;

760 A         exsr chkExists;
760aA         if trnExists;
                // when transaction and time range exist and rewrite flag
                // sent in as No then skip this tran/time range
760aA           iter;
760aA         endif;

760aM         if wkstat<='4';
760 A           // now we should loop pirtrand2 with this start
760 A           // time to ensure all transactions have closed.
760 A           // Since called from WRTTRAND we have to wait until
760 A           // last of the multi-transactions close
760 A           first = *on;
760 A           totTrns = 0;
760aA           mlblcnt = 0;
760aA           nxtseq  = 0;
760aA           nxtTs   = wksts;
760 A           clear lbllist;
760aA           clear mlbllist;
760 A           setll (wkWhse:wkemp#:wksts) pirtrand2;
760 A
760 A           dow forever = forever;
760 A             reade (wkwhse:wkemp#:wksts) pirtrand2;
760 A             if %eof(pirtrand2);
760 A               leave;
760 A             endif;

760aA             // skip non-numeric status codes
760aA             if ptdstat < '0';
760aA               iter;
760aA             endif;

760 A             // If any pirtrand records have status 1, 2 or default
760 A             // timestamp for Ending Stamp this means not all multi
760 A             // transactions have been closed and we should return
760 A             // and wait for last transaction of the bunch
760 A             if ptdstat='1' or ptdstat='2' or ptdets=dftts;
760 A               *inlr=*on;
760 A               return;
760 A             endif;
760 A
                  // load pirtrand2 fields to nextRec data structure

                  if first;
                    first = *off;
                    chain (ptdTran) pltsum4;
                    if %found(pltsum4);
                    endif;
                    strStmt = 'select * from labeldo ' +
                              'where lbowhse=' + %char(wkWhse) + ' and ' +
                              'lboemp#=' + %char(wkEmp#) + ' and ' +
                             'lboaddts>=' + sq + %char(wkSts) + sq +  ' and ' +
                              'lboaddts<=' + sq + %char(wkEts) + sq;
                    lboStmt = strStmt;
                  endif;

                  // check to ensure ending time stays the same.  The
                  // Warehouse, Starting time and Employee are in the
                  // reade above on pirtrand2.
760aM             if ptdEts<>wkEts;
                     // Write data to work file from LabelDo. Close the ")"
                     // from transaction build on else of this statement
                     lboStmt = %trim(lboStmt) + ')' +
                               ' order by lbowhse,lboaddts,lboemp#';
                     exsr wrtAPTwk;
                     if lastBatch;
                       exsr wrklblmissing;
                     endif;
                     exsr chkUpdTimes;
                     if nxtseq <> 0;
                       totalsOnly=*on;
                       exsr createRec;
                     endif;
760cA                exsr expaptdta;
                     clear lblList;
                     totTrns = 0;
                     strStmt = 'select * from labeldo ' +
                               'where lbowhse=' + %char(ptdWhse) + ' and ' +
                               'lboemp#=' + %char(ptdEmpNum) + ' and ' +
                             'lboaddts>=' + sq + %char(ptdSts) + sq +  ' and ' +
                               'lboaddts<=' + sq + %char(ptdEts) + sq;
                     lboStmt = strStmt;
                  endif;

                  // skip if this transaction is already represented
                  // pltsum can have multiple pallets and therefore multiple
                  // times in this query.  Joining pltsum because route id and trans
                  if %scan(%char(ptdTran):lboStmt) > 0;
                    iter;
                  endif;

                  totTrns = totTrns + 1;
                  mlblcnt = mlblcnt + 1;

                  // add select of specific transaction to sql
                  // to process proper selection data from labeldo
                  if lboStmt = strStmt;
                    lboStmt = %trim(lboStmt) + ' and (lbotrn#=' +
                              %char(ptdTran);
                    lblList(totTrns) = ptdTran;
                  else;
                    lboStmt = %trim(lboStmt) + ' or lboTrn#=' +
                              %char(ptdTran);
                    lblList(totTrns) = ptdTran;
                  endif;
                  // keep list of transactions for all trand records
                  mLblList(mLblCnt) = ptdTran;

760 A           enddo;   // loop for PIRTRAND2

              // Write last Transaction(s) if they existed
              if lboStmt <> StrStmt;
                lboStmt = %trim(lboStmt) + ')' +
                          ' order by lbowhse,lboaddts,lboemp#';
                exsr wrtAPTwk;
                if lastBatch;
                  exsr wrklblmissing;
                endif;

                // Write any label records not represented in LABELDO
                // for given transaction(s)
                exsr chkUpdTimes;
                if nxtseq <> 0;
                  totalsOnly=*on;
                  exsr createRec;
                endif;
760cA           exsr expaptdta;
760 A
760 A         else;
760 A           // this should not happen since this is called
760 A           // from wrttrand when transaction changes from
760 A           // 1 or 2 to 3.  If it does we return since
760 A           // there is nothing to do
760 A           return;
760 A         endif;
760aA        endif;
760aA       enddo;     // sql for all pirtrand records between begin and end
     *
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  wrtAPTwk  Write initial Labeldo records for specific Transaction(s)
     *
     C     wrtAPTwk      begsr
      /free

760cA       exsr chkMulTran;
            // delete Transaction from APTDATA file if batch not assigned
760cA       sqlInStmt = 'delete from aptdata as a ' +
760cA                   'where a.apwhse=' + %char($pWhse) + ' and ' +
760cA                   'a.apexpfile=' + sq + ' ' + sq +
760cA                   ' and exists(select * from aptselwk as b ' +
760cA                   'where a.apwhse=b.apwhse and a.aptrn#=b.aptrn# ' +
760cA                   'and a.aplbl#=b.aplbl# and b.apactts>=' + sq +
760cA                   %char(wksts) + sq + ' and b.apactts<='+ sq +
760cA                   %char(wkets) + sq + ' and b.apempid=' +
760cA                   %char(lemp#) + ')' +
760cA                   ' and a.aptrn# in(';
            // Build sql in string for sql statement below
            firstLoop = *on;
            for loopCnt = 1 by 1 to 1000;
              if lblList(loopCnt) = 0;
                leave;
              else;
                if firstLoop;
                  firstloop=*off;
                  sqlInStmt = %trim(sqlInStmt) +
                              %editc(lblList(loopCnt):'X');
                else;
                  sqlInStmt = %trim(sqlInStmt) + ',' +
                               %editc(lblList(loopCnt):'X');
                endif;
              endif;
            endfor;
            sqlInStmt = %trim(sqlInStmt) + ')';
            exec sql execute immediate :sqlInStmt;
760cA       exsr deltrn;

            // open and loop  Labeldo  sql from routine addTrn
            exec sql PREPARE ld FROM :lboStmt;
            exec sql DECLARE lbodata SCROLL CURSOR FOR ld;
            exec sql OPEN lbodata;

            nxtseq=0;
            clear aptr1;
            lbo = *on;
            totalsOnly=*off;
            lastdisp=*blanks;
            clear prevlbo;

            dow forever = forever;

              exec sql fetch next from lbodata into :nextlbo;
              if sqlstt <> sqlSuccess;
                leave;
              endif;

              if p_lboaddts <> dftts;
              else;
                // load kvi method routine array on first read
                exsr loadKviRtn;
              endif;
              // loads for each transaction because zones can be different and
              // change which kvi routine to be used
              exsr createRec;
              prevlbo = nextlbo;
              lastDisp = lbdisp;

            enddo;

            exec sql close lbodata;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  wrtlblmissing  - Write missing label records after processing labeldo
     *
     C     wrklblmissing begsr
      /free
            // Build sql in string for sql statement below
            firstLoop = *on;
            lastdisp=*blanks;
            for loopCnt = 1 by 1 to 1000;
760aM         if mlbllist(loopCnt) = 0;
                leave;
              else;
                if firstLoop;
                  firstloop=*off;
760aM             lblListStr = %editc(mlblList(loopCnt):'X');
                else;
                  lblListStr = %trim(lblListStr) + ',' +
760aM                          %editc(mlblList(loopCnt):'X');
                endif;
              endif;
            endfor;

            sqlStmt = 'select * from label ' +
                      ' where lbtrn# in(' + %trim(lbllistStr) + ') and ' +
                      '(select count(*) from aptselwk where apwhse=lbwhse' +
                      ' and aprtid=lbrte and aptrn# in(' + %trim(lbllistStr) +
                      ') and aplbl#=lblbl#)=0';

            // open and loop Label records not found in  Labeldo
            exec sql PREPARE lb FROM :SqlStmt;
            exec sql DECLARE lbldata SCROLL CURSOR FOR lb;
            exec sql OPEN lbldata;

            lbo = *off;
            totalsOnly=*off;

            dow forever = forever;

              exec sql fetch next from lbldata into :nextlbl;
              if sqlstt <> sqlSuccess;
                leave;
              endif;

              exsr loadKviRtn;
              exsr createRec;
              lastDisp = lbdisp;

            enddo;

            exec sql close lbldata;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  chkupdTimes - Update any work file times written from label
     *                since label has no time worked
     *
     C     chkupdtimes   begsr
      /free
            // Build sql in string for sql statement below
            firstLoop = *on;
            for loopCnt = 1 by 1 to 1000;
760aM         if mlblList(loopCnt) = 0;
                leave;
              else;
                if firstLoop;
                  firstloop=*off;
760aM             lblListStr = %editc(mlblList(loopCnt):'X');
                else;
                  lblListStr = %trim(lblListStr) + ',' +
760aM                          %editc(mlblList(loopCnt):'X');
                endif;
              endif;
            endfor;

            sqlStmt = 'select * from aptselwk ' +
                      ' where aptrn# in(' + %trim(lblliststr) + ')' +
760aM                 ' and apactts>=' + sq + %char(wksts) + sq +
760aM                 ' and apactts<=' + sq + %char(wkets) + sq +
                      ' order by apline#';

            // open and loop aptselwk to correct zero times
            // added from Label file when missing from labeldo
            exec sql PREPARE ap FROM :SqlStmt;
            exec sql DECLARE aptdata SCROLL CURSOR FOR ap;
            exec sql OPEN aptdata;

            nxtseq = 0;
            endUsed = *off;

            dow forever = forever;

              exec sql fetch next from aptdata into :nextApt;
              if sqlstt <> sqlSuccess;
                leave;
              endif;

              if apactts = dftts;
                if nxtseq = 0;
                  // if first record has no time then apply the start
                  // time from the transaction
760aM             apactts = wksts;
                  lstactts = apactts;
                else;
                  // if no time stamp and not first record then apply
                  // previous start time
                  apactts = lstactts;
                  if not endUSed and apkvi01=0 and apkvi02=0 and apkvi03=0
                                 and apkvi04=0 and apkvi05=0 and apkvi06=0
                                 and apkvi07=0 and apkvi08=0;
                    endUsed = *on;
                    exec sql fetch prior from aptdata into :nextApt;
760aM               if wkets <> dftts;
760aM                 apactts = wkets;
                    else;
760aM                 apactts = wksts;
                    endif;
                    lstactts = apactts;
                    exec sql update aptselwk set apactts=:apactts
                         where apwhse=:apwhse and aprtid=:aprtid and
                               aptrn#=:aptrn# and aplbl#=:aplbl#
                               and apline#=:nxtseq;
                    exec sql fetch next from aptdata into :nextApt;
                    apactts = lstactts;
                  endif;
                endif;
              else;
760aA           if lstactts > apactts;
760aA             apactts = lstactts;
760aA           else;
760aA             lstactts = apactts;
760aA           endif;
              endif;

              nxtseq = nxtseq + 1;

              // update this specific record in aptselwk
              exec sql update aptselwk set apactts=:apactts, apline#=:nxtseq
                         where apwhse=:apwhse and aprtid=:aprtid and
                               aptrn#=:aptrn# and aplbl#=:aplbl#
                               and apline#=:nxtseq;

            enddo;

            exec sql close aptdata;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  createRec - Write record to apt work file
     *
     C     createRec     begsr
      /free

          if not totalsOnly;
              if lbo;
                // get label number
                chain (lbowhse:lbolbl#) labelw;
              endif;

              // get zone description
              chain ($pWhse:psTruk) truckh;
              if %eof(truckh);
                apzoned = '** Truck not Found';
              else;
                chain ($pWhse:thztmp:psszon) zoneh;
                if %eof(zoneh);
                  apzoned = '** Invalid - ' + %trim(thztmp) + ' - -' +
                                              %trim(psszon);
                else;
                  apzoned = %trim(zhdesc);
                endif;
              endif;

              // loop thru kvi methods array and execute the ones
              // marked as first only since this is next seq 0
              // and we know at least one was marked as first only
              // when loading kvi methods array
              for kcnt = 1 to 500;
                // only process kvis marked as yes for first row only, or
                // run for both first and not first records
                if kmth(kcnt)=*blanks;
                  iter;
                endif;
                select;
                  when kmth(kcnt) = 'RKVI001';
                    exsr RKVI001;
                  when kmth(kcnt) = 'RKVI002';
                    exsr RKVI002;
                  when kmth(kcnt) = 'RKVI003';
                    exsr RKVI003;
                  when kmth(kcnt) = 'RKVI004';
                    exsr RKVI004;
                  when kmth(kcnt) = 'RKVI005';
                    exsr RKVI005;
                  when kmth(kcnt) = 'RKVI006';
                    exsr RKVI006;
                  when kmth(kcnt) = 'RKVI007';
                    exsr RKVI007;
                  when kmth(kcnt) = 'RKVI008';
                    exsr RKVI008;
                  when kmth(kcnt) = 'RKVI009';
                    exsr RKVI009;
                  when kmth(kcnt) = 'RKVI010';
                    exsr RKVI010;
                  when kmth(kcnt) = 'YHATAK004SI';
                    exsr YHATAK004SI;
                  when kmth(kcnt) = 'YHATAK004KP';
                    exsr YHATAK004KP;
                  when kmth(kcnt) = 'YHATAK006';
                    exsr YHATAK006;
                  when kmth(kcnt) = 'YHATAK007SI';
                    exsr YHATAK007SI;
                  when kmth(kcnt) = 'YHATAK007KP';
                    exsr YHATAK007KP;
                endsl;
              endfor;

              // get first record only data
              if nxtSeq = 0 and useFonly;
                 // Save first transaction with appended zero when multiple transactions
                 monitor;
                   if lbo;
                     aptrnm = %dec(%char(lbotrn#) + '0':8:0);
                   else;
                     aptrnm = %dec(%char(lbtrn#) + '0':8:0);
                   endif;
                 on-error;
                   if lbo;
                     aptrnm = lbotrn#;
                   else;
                     aptrnm = lbtrn#;
                   endif;
                 endmon;
                keepfirst = strLoc;
              endif;

              // start with Transaction Start time
              monitor;
760aA           apactts = nxtts;
              on-error;
760aA           apactts = wksts;
              endmon;

              monitor;
760aA           nxtts = lboaddts;
              on-error;
760aA           nxtts = wksts;
              endmon;

              // set Starting and ending locations for transaction
              apfrml = strLoc;

              aptol  = %trim(lbaisl) + %editc(lbloc:'X') +
                       %editc(lbrlvl:'X') + %trim(lbhand);

              // when merged PIR piece then get department for the originally
              // picked PIR piece and reflect the proper staging area that
              // the selector or merge from instead of the original pir slot
              if lbtype='M' and lbaisl=' ' and lbloc=0;
                wkMwhdp = *blanks;
                exec sql select lbwhdp into :wkMwhdp
                     from label
                        where lblbl# = :lbctr#;
                select;
                  when wkMwhdp = 'DRY';
                    aptol = 'STGDRY1';
                  other;
                    aptol = 'STGFRZ1';
                endsl;
              endif;
              strLoc = aptol;

              // write labeldo/label data to apt work file
              nxtSeq = nxtSeq + 1;
              aprtid = lbrte;
              aplbl# = lblbl#;
              apdisp = lbdisp;
              aptype = 'SEL';
              if lbo;
                apwhse = lbowhse;
                aptrn# = lbotrn#;
                apempid= lboemp#;
              else;
                apwhse = lbwhse;
760aM           apactts = wksts;
                aptrn# = lbtrn#;
760aA           apempid= wkemp#;
              endif;
              apline# = nxtseq;
              aptermid = *blanks;
              apactm = *blanks;
              apacts = *blanks;

760bA         chain (apwhse:aprtid:aptrn#:aplbl#:aptrnm:aptype:apactts:
760bA                                     apline#) aptselwk;
760bA         if not %found(aptselwk);
                write aptr1;
760bA         else;
760bA           slgbuf = '<*duplicate key aptselwk> '
760bA               + 'cmd=' + %trim($pCmd) + ' '
760bA               + 'user=' + %trimr(#curruser)  + ' '
760bA               + 'client=' + %trim(client) + ' '
760bA               + 'whs=' + %char($PWHSE)  + ' '
760bA               + 'trn=' + %char($ptran) + ' '
760bA               + 'trnm=' + %char(aptrnm) + ' '
760bA               + 'rtid=' + aprtid + ' '
760bA               + 'lbl#=' + %char(aplbl#) + ' '
760bA               + 'type=' + aptype + ' '
760bA               + 'actts=' + %char(apactts) + ' '
760bA               + 'line#=' + %char(apline#);
760bA           WriteVoiceLog ('W01': slgbuf);
760bA         endif;

          else;
              // Total Only for given Transaction
              // write record from last slot to door/stage area
              apkvi01=0;
              apkvi02=0;
              apkvi03=0;
              apkvi04=0;
              apkvi05=0;
              apkvi06=0;
              apkvi07=0;
              apkvi08=0;
              apkvi09=0;
              apkvi10=0;
              nxtseq = nxtseq + 1;
              apline# = nxtseq;
              apfrml = aptol;
              aptol = endloc;
760aA         apactts=nxtts;
760bA         chain (apwhse:aprtid:aptrn#:aplbl#:aptrnm:aptype:apactts:
760bA                                     apline#) aptselwk;
760bA         if not %found(aptselwk);
                write aptr1;
760bA         else;
760bA           slgbuf = '<*duplicate key aptselwk> '
760bA               + 'cmd=' + %trim($pCmd) + ' '
760bA               + 'user=' + %trimr(#curruser)  + ' '
760bA               + 'client=' + %trim(client) + ' '
760bA               + 'whs=' + %char($PWHSE)  + ' '
760bA               + 'trn=' + %char($ptran) + ' '
760bA               + 'trnm=' + %char(aptrnm) + ' '
760bA               + 'rtid=' + aprtid + ' '
760bA               + 'lbl#=' + %char(aplbl#) + ' '
760bA               + 'type=' + aptype + ' '
760bA               + 'actts=' + %char(apactts) + ' '
760bA               + 'line#=' + %char(apline#);
760bA           WriteVoiceLog ('W02': slgbuf);
760bA         endif;

              // write record from door/stage area back to desk
              apkvi01=0;
              apkvi02=0;
              apkvi03=0;
              apkvi04=0;
              apkvi05=0;
              apkvi06=0;
              apkvi07=0;
              apkvi08=0;
              apkvi09=0;
              apkvi10=0;
              nxtseq = nxtseq + 1;
              apline# = nxtseq;
              apfrml = aptol;
              aptol = keepFirst;
              // use Transaction end time for last record
760aA         apactts=wkets;
760bA         chain (apwhse:aprtid:aptrn#:aplbl#:aptrnm:aptype:apactts:
760bA                                     apline#) aptselwk;
760bA         if not %found(aptselwk);
                write aptr1;
760bA         else;
760bA           slgbuf = '<*duplicate key aptselwk> '
760bA               + 'cmd=' + %trim($pCmd) + ' '
760bA               + 'user=' + %trimr(#curruser)  + ' '
760bA               + 'client=' + %trim(client) + ' '
760bA               + 'whs=' + %char($PWHSE)  + ' '
760bA               + 'trn=' + %char($ptran) + ' '
760bA               + 'trnm=' + %char(aptrnm) + ' '
760bA               + 'rtid=' + aprtid + ' '
760bA               + 'lbl#=' + %char(aplbl#) + ' '
760bA               + 'type=' + aptype + ' '
760bA               + 'actts=' + %char(apactts) + ' '
760bA               + 'line#=' + %char(apline#);
760bA           WriteVoiceLog ('W03': slgbuf);
760bA         endif;
          endif;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI001  -  Standard Selection KVI 1
     *              Records number units for transaction/label
     *
     C     rkvi001       begsr
      /free
              // when coming from lbo file use that quantity, otherwise label
              if lbo;
                apkvi01 = lboqty;
              else;
                apkvi01 = lbqpck;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI002  -  Standard Selection KVI 2
     *              Records cube for transaction/label
     *
     C     rkvi002       begsr
      /free
              // when coming from lbo file use that quantity, otherwise label
              if lbo;
                apkvi02 = lboqty * lbucub;
              else;
                apkvi02 = lbqpck * lbucub;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI003  -  Standard Selection KVI 3
     *              Records weight for transaction/label
     *
     C     rkvi003       begsr
      /free
              // when coming from lbo file use that quantity, otherwise label
              if lbo;
                apkvi03 = lboqty * lbuwgt;
              else;
                apkvi03 = lbqpck * lbuwgt;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI004  -  Standard Selection KVI 4
     *              Records 0 for PIR item and 1 for Fixed item
     *
     C     rkvi004       begsr
      /free
              if lbtype = 'M';
                // when first label and not PIR, we should mark with 0
                // if fixed selector picking up merge
                apkvi04 = 0;
              else;
                // otherwise, it is not a PIR and not a merge so show as
                // 1 indicating fixed pick
                apkvi04 = 1;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI005  -  Standard Selection KVI 5
     *              Records number of unique Stops on every record
     *
     C     rkvi005       begsr
      /free
              // get number of unique stops per transaction(s)
              if nxtseq = 0;
                sqlInStmt = 'values (select count(*) from ' +
                            '(select distinct lbstop from label ' +
                            'where lbtrn# in(';
                // Build sql in string for sql statement below
                firstLoop = *on;
                for loopCnt = 1 by 1 to 1000;
                  if lblList(loopCnt) = 0;
                    leave;
                  else;
                    if firstLoop;
                      firstloop=*off;
                      sqlInStmt = %trim(sqlInStmt) +
                                  %editc(lblList(loopCnt):'X');
                    else;
                      sqlInStmt = %trim(sqlInStmt) + ',' +
                                   %editc(lblList(loopCnt):'X');
                    endif;
                  endif;
                endfor;
                sqlInStmt = %trim(sqlInStmt) + '))) into ?';
                exec sql prepare stp from :sqlInStmt;
                exec sql execute stp using :apkvi05;
              else;
                apkvi05=0;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI006  -  Standard Selection KVI 6
     *              Records number of labels for this specific
     *              Transaction/Label
     *
     C     rkvi006       begsr
      /free
              if lbo;
                apkvi06 = lboqty;
              else;
                apkvi06 = lbqpck;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI007 -  Standard Selection KVI 7
     *             Records 0 for PIR and 1 for Fixed pick
     *
     C     RKVI007       begsr
      /free
              // KVI 7
              if lbstyp='P' or lbtype='M';
                apkvi07 = 1;
              else;
                apkvi07 = 0;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI008 -  Standard Selection KVI 8
     *             Records number of catch weights recorded
     *
     C     RKVI008       begsr
      /free
              // KVI 8 Catchweights entered
              // get number of catch weights entered for label
              exec sql select count(*) into :apkvi08
                            from ordc
                   where ocwhse=:lbwhse and oclbl#=:lblbl#;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI009 -  Standard Selection KVI 9
     *             Nothing recorded
     *
     C     RKVI009       begsr
      /free
              // Nothing recorded currently
              apkvi09=0;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  RKVI010 -  Standard Selection KVI 10
     *             Nothing recorded
     *
     C     RKVI010       begsr
      /free
              // Nothing recorded currently
              apkvi10=0;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  YHATAK004SI - Yhata specific code for Selection KVI 4
     *                Records whether label was PIR or Fixed pick
     *                other than first record for PIR zone pick
     *                which will show unique transactions per pick
     *
     C     YHATAK004SI   begsr
      /free
              // Set KVI 4
              if nxtseq = 0;
                // Sand Island Warehouse
                if lbstyp = 'F';    // Fixed Locations
                  select;
                    when lbwhdp = 'DRY';
                      strLoc = 'DESKDRY';
                      endLoc = 'DOOR003';
                    other;
                      strLoc = 'DESKCOOL';
                      endLoc = 'DOOR009';
                  endsl;
                else;     // PIR for Sand Island
                  select;
                    when lbwhdp = 'DRY';
                      strLoc = 'RACKDRY';
                      endLoc = 'STGDRY1';
                    other;
                      strLoc = 'RACKFRZ';
                      endLoc = 'STGFRZ1';
                  endsl;
                endif;
                if lbstyp = 'P';
                  // when Transaction is pure PIR pick show unique transactions
                  // in first record for KVI 4, and zero for every other record
                  apkvi04 = totTrns;
                else;
                  if lbtype = 'M';
                    // when first label and not PIR, we should mark with 0
                    // if fixed selector picking up merge
                    apkvi04 = 0;
                  else;
                    // otherwise, it is not a PIR and not a merge so show as
                    // 1 indicating fixed pick
                    apkvi04 = 1;
                  endif;
                endif;
              else;
                if lbstyp = 'P' or lbtype='M';
                  // when not first record and it is either a PIR section or
                  // Merge label we show as zero
                  apkvi04 = *zeros;
                else;
                  // when not first record and not a PIR or Merge
                  // show as 1 for Fixed pick
                  apkvi04 = 1;
                endif;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  YHATAK004KP - Yhata specific code for Selection KVI 4
     *                Records whether label was PIR or Fixed pick
     *                other than first record for PIR zone pick
     *                which will show unique transactions per pick
     *
     C     YHATAK004KP   begsr
      /free
              // Set KVI 4
              if nxtseq = 0;
                // populate starting and ending locations
                // Koapaka Warehouse
                select;
                  when lbwhdp = 'DRY';
                    strLoc = 'DSKKDRY';
                    endLoc = 'KOAPAK1';
                  other;
                    strLoc = 'DSKKCOOL';
                    endLoc = 'KOAPAK1';
                endsl;
                if lbstyp = 'P';
                  // when Transaction is pure PIR pick show unique transactions
                  // in first record for KVI 4, and zero for every other record
                  apkvi04 = totTrns;
                else;
                  if lbtype = 'M';
                    // when first label and not PIR, we should mark with 0
                    // if fixed selector picking up merge
                    apkvi04 = 0;
                  else;
                    // otherwise, it is not a PIR and not a merge so show as
                    // 1 indicating fixed pick
                    apkvi04 = 1;
                  endif;
                endif;
              else;
                if lbstyp = 'P' or lbtype='M';
                  // when not first record and it is either a PIR section or
                  // Merge label we show as zero
                  apkvi04 = *zeros;
                else;
                  // when not first record and not a PIR or Merge
                  // show as 1 for Fixed pick
                  apkvi04 = 1;
                endif;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  YHATAK006 -  Yhata Selection KVI 6
     *               Records number of labels for this specific
     *               Transaction/Label.
     *
     C     YHATAK006     begsr
      /free
              if lbo;
                if lboqty = 0;
                  apkvi06 = lboqtys;
                else;
                  apkvi06 = lboqty;
                endif;
              else;
                apkvi06 = lbqpck;
              endif;
              if apkvi06 > 24;
                apkvi06 = 1;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  YHATAK007SI -  Yhata Selection KVI 7
     *                 Records 0 for PIR and 1 for Fixed pick
     *
     C     YHATAK007SI   begsr
      /free
              // KVI 7 not Kopaka
              if lbstyp='P' or lbtype='M';
                apkvi07 = 1;
              else;
                apkvi07 = 0;
              endif;
              if lbstyp='P' and lbtype='O' and lastDisp=lbdisp;
                apkvi07=0;
              endif;
              if apkvi07 = 1 and lbstyp<>'P';
                // zero credit for peeling and sticking labels if pir merge
                // because pir selector already picked and stuck labels.  This
                // is counted for fixed picks and the actual PIR pick
                apkvi06=0;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  YHATAK007KP -  Yhata Selection KVI 7
     *                 Records Pallet Count in First record only
     *
     C     YHATAK007KP   begsr
      /free

              // Get Pallet Count for Koapaka
              // First Record ONLY
              if nxtseq = 0;
                sqlInStmt = 'values (select count(*) from ' +
                            '(select distinct lbpal# from label ' +
                            'where lbtrn# in(';
                // Build sql in string for sql statement below
                firstLoop = *on;
                for loopCnt = 1 by 1 to 1000;
                  if lblList(loopCnt) = 0;
                    leave;
                  else;
                    if firstLoop;
                      firstloop=*off;
                      sqlInStmt = %trim(sqlInStmt) +
                                  %editc(lblList(loopCnt):'X');
                    else;
                      sqlInStmt = %trim(sqlInStmt) + ',' +
                                   %editc(lblList(loopCnt):'X');
                    endif;
                  endif;
                endfor;
                sqlInStmt = %trim(sqlInStmt) + '))) into ?';
                exec sql prepare plt from :sqlInStmt;
                exec sql execute plt using :apkvi07;
              else;
                apkvi07=0;
              endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  wrtInd      -  Write indirect activity between labeldo
     *                 records (lunch, break, etc.,
     *
     C     wrtInd        begsr
      /free

              // ensure record gone before re-adding
760aA         if $preWrte='Y';
760aA           exec sql delete from aptselwk where aptrn#=:wktran
760aA              and aptype='IND' and apactts=:wksts;
760aA         else;
760aA           leavesr;
760aA         endif;

              apwhse   = wkwhse;
              aprtid   = psRtid;
              aptrn#   = wktran;
              aplbl#   = *zeros;
              aptype   = 'IND';             // versus SEL for Selection
760aA         apactts  = wksts;
760aA         lstactts = wksts;
              nxtseq = nxtseq + 1;
              apline# = nxtseq;
              aptermid=' ';
              apactm=' ';
760aM         apzonedhld = psszon;
              apzoned='In-Direct';
              apacts=' ';
              apdisp=' ';
760aM         apempid=wkemp#;
760aM         apfrml=wktask;
760aM         aptol=wktask;
760aM         strloc=wktask;
              // write zero kvis for indirects
              apkvi01=0;
              apkvi02=0;
              apkvi03=0;
              apkvi04=0;
              apkvi05=0;
              apkvi06=0;
              apkvi07=0;
              apkvi08=0;
              apkvi09=0;
              apkvi10=0;
760bA         chain (apwhse:aprtid:aptrn#:aplbl#:aptrnm:aptype:apactts:
760bA                                     apline#) aptselwk;
760bA         if not %found(aptselwk);
                write aptr1;
760bA         endif;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  delTrn - Ensure data gone for specific Transaction before adding
     *
     C     delTrn        begsr
      /free

           chain (wkTran) pltsum4;
           if %eof(pltsum4);
             psrtid=*blanks;
             psszon=*blanks;
             pstruk=*blanks;
           endif;

           // delete Transaction from APT Work file
760cA       sqlInStmt = 'delete from aptselwk as a ' +
760cA                   'where apactts>=' + sq +
760cA                   %char(wksts) + sq + ' and apactts<='+ sq +
760cA                   %char(wkets) + sq + ' and apempid=' +
760cA                   %char(lemp#) +
760cA                   ' and aptrn# in(';
760cA       // Build sql in string for sql statement below
760cA       firstLoop = *on;
760cA       for loopCnt = 1 by 1 to 1000;
760cA         if lblList(loopCnt) = 0;
760cA           leave;
760cA         else;
760cA           if firstLoop;
760cA             firstloop=*off;
760cA             sqlInStmt = %trim(sqlInStmt) +
760cA                         %editc(lblList(loopCnt):'X');
760cA           else;
760cA             sqlInStmt = %trim(sqlInStmt) + ',' +
760cA                          %editc(lblList(loopCnt):'X');
760cA           endif;
760cA         endif;
760cA       endfor;
760cA       sqlInStmt = %trim(sqlInStmt) + ')';
760cA       exec sql execute immediate :sqlInStmt;
      /end-free
     C                   endsr
760 A*
760 A*----------------------------------------------------------------
760 A*
760 A*  chkExists - If Transaction exists but we do not want to rebuild then
760 A*              return without doing anything
760 A*
760 AC     chkExists     begsr
760 A /free
760 A
760aA      trnExists = *off;
760 A      chain (wkTran) pltsum4;
760 A      if %eof(pltsum4);
760 A        psrtid=*blanks;
760 A        psszon=*blanks;
760 A        pstruk=*blanks;
760 A      endif;
760 A
760 A      // if parm says not to rebuild and transaction exist we
760 A      // should simply return
760 A      if $pReWrte = 'Y';
760 A        leavesr;
760 A      else;
760cA        // get transaction info to load array with single or multiple trans
760cA        chain ($ptran) pirtran;
760cA        if not %found(pirtran);
760cA          return;
760cA        endif;
760cA        // load array with multi-trans or single.
760cA        clear lblList;
760cA        loopCnt=0;
760cA        setll (ptwhse:ptemp#:ptsdte:ptstim:ptedte:ptetim) multran3;
760cA        dow forever = forever;
760cA          reade (ptwhse:ptemp#:ptsdte:ptstim:ptedte:ptetim) multran3;
760cA          if %eof(multran3);
760cA            leave;
760cA          endif;
760cA          if %lookup(mutrn#:lblList) = 0;
760cA            loopCnt = loopCnt + 1;
760cA            lblList(loopCnt) = mutrn#;
760cA          endif;
760cA        enddo;
760cA        sqlInStmt = 'values (select count(*) from aptselwk ' +
760cA                    'where apactts>=' + sq + %char(wksts) + sq +
760cA                    ' and apactts<=' + sq + %char(wkets) + sq +
760cA                    ' and apwhse=' + %char(wkwhse) + ' and aptrn# in(';
760cA        // Build sql in string for sql statement below
760cA        firstLoop = *on;
760cA        for loopCnt = 1 by 1 to 1000;
760cA          if lblList(loopCnt) = 0;
760cA            leave;
760cA          else;
760cA            if firstLoop;
760cA              firstloop=*off;
760cA              sqlInStmt = %trim(sqlInStmt) +
760cA                          %editc(lblList(loopCnt):'X');
760cA            else;
760cA              sqlInStmt = %trim(sqlInStmt) + ',' +
760cA                           %editc(lblList(loopCnt):'X');
760cA            endif;
760cA          endif;
760cA        endfor;
760cA        tCnt=0;
760cA        sqlInStmt = %trim(sqlInStmt) + ')) into ?';
760cA        exec sql prepare cex from :sqlInStmt;
760cA        exec sql execute cex using :tCnt;
760cA        if tCnt <> 0;
760cA          trnExists = *on;
760cA        else;
760cA          tCnt=0;
760cA        endif;
760 A      endif;
760cA      loopCnt=0;
760cA      clear lblList;
760 A
760 A /end-free
760 AC                   endsr
760cA*
760cA*----------------------------------------------------------------
760cA*
760cA*  chkMulTran - Ensure all transactions for a specific employee
760cA*               and time range in Multran are found in LBLLIST
760cA*               array to ensure everything is at correct status
760cA*               in pirtrand before processing.
760cA*
760cAC     chkMulTran    begsr
760cA /free
760cA
760cA          // get employee, start and end times to read multran
760cA          // for one or more transactions to ensure they are
760cA          // exist in lbllist array to proceed.  If something is
760cA          // missing that means not all transactions of a multi
760cA          // trans has been ended and rewritten as such in pirtrand
760cA          // and we should simply return.  Ultimately when the last
760cA          // transaction is rewritten in wrttrand and it calls this
760cA          // this process it will find them all and write
760cA          chain ($ptran) pirtran;
760cA          if not %found(pirtran);
760cA            return;
760cA          endif;
760cA
760cA          // after finding transaction in PIRTRAN loop MULTRAN3 for
760cA          // employee and specific start and end times. This loop assumes
760cA          // either no records will be found in MULTRAN3 for the transaction
760cA          // (which means it will return to aptwrkwk and process as single)
760cA          // or every record for multi-tran will be in multran3 and it will
760cA          // close up shop and return to calling program without doing anything
760cA          // if it reads a transaction from multran3 without a match entry in
760cA          // lblList array which is loaded as it loops pirtrand in addtrn
760cA          setll (ptwhse:ptemp#:ptsdte:ptstim:ptedte:ptetim) multran3;
760cA          dow forever = forever;
760cA            reade (ptwhse:ptemp#:ptsdte:ptstim:ptedte:ptetim) multran3;
760cA            if %eof(multran3);
760cA              leave;
760cA            endif;
760cA            // lblList will only have transactions that it read from PIRTRAND2
760cA            // in addtrn where status had to be 3 or 4 and end timestamp could
760cA            // not be default meaning it was updates and rewritten by wrttrnd.
760cA            // if it happens that a record is missing from pirtrand then it will
760cA            // not be in this array either and it will cause it to return to
760cA            // wrttrand and wait until it is called with next transaction of this
760cA            // multi tran and ultimately all the multi trans will be processed and
760cA            // setting at correct status
760cA            if %lookup(mutrn#:lblList) = 0;
760cA              *inlr=*on;
760cA              return;
760cA            endif;
760cA          enddo;
760cA
760cA /end-free
760cAC                   endsr
     *----------------------------------------------------------------
     *
     *  expAptDta  -  Export Route Selection data to APT interface
     *
     C     expAptDta     begsr
      /free
     c*    Call APT Interface
     c                   if        logapt
     c                   if        error = *off
     c*    Write Selection Interface data from APTSELWK (1st at Y-HATA)
     c                   exsr      clr$apt
     c*    get route id for transaction
      /free
                   // set transaction number to master transaction
                   monitor;
                     $aptrn# = %dec(%subst(%editc(aptrnm:'X'):1:7):7:0);
                   on-error;
                     slgbuf = '<EXPAPPDTA> '
                            + 'cmd=' + %trim($pCmd) + ' '
                            + 'user=' + %trimr(#curruser)  + ' '
                            + 'client=' + %trim(client) + ' '
                            + '$aptrn#=' + %char($aptrn#) + ' '
                            + '$aprteid=' + %trim($aprteid);
                     WriteVoiceLog ('Snd': slgbuf);
                     $aptrn# = 0;
                   endmon;

760bA              if $pCmd='*EXPTRN';
760bA                $apTrn# = $ptran;
760bA              endif;

                   setll ($apTrn#) label7;
                   reade ($apTrn#) label7;
                   if %equal(label7);
                     $aprteid=lbrte;
                   endif;
      /end-free
760bAc                   if        $pCmd = '*EXPTRN'
760bAc                   eval      $aprteid = lbrte
760bAc                   else
     c                   eval      $aprteid = psrtid
760bAc                   endif
     C                   eval      $dricommand = '*APT'
     C                   eval      $drisubcmd  = '*EXPTRN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     c                   endif
     c                   endif
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  clr$apt   Clear $apt data structure fields
     *----------------------------------------------------------------

     C     clr$apt       begsr
     C                   eval      savever# = $apver#
     C                   clear                   $aptds
     C                   eval      $apver# = savever#
     C                   eval      $apuser = #user
     C                   eval      $apjob  = #job
     C                   eval      $apjobn = #jobnbr
     C                   eval      $apwhseu = *on
     C                   eval      $apwhse  = $pwhse
     C                   eval      $apemp#u = *on
     C                   eval      $apemp#  = #emp#
     C                   eval      $aprteidu = *on
     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdricop  Call DRICOP
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdricop     begsr
     C                   eval      drierr = *off
     C                   select
     C                   when      $dricommand = '*APT'
     C                   eval      $dridata = $aptds
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select
     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
     C                   endsl

     C                   select
     C                   when      $dricommand = '*APT'
     C                   eval      $aptds = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  WriteVoiceLog    Write record to voice log BFCSKTLOG
     *----------------------------------------------------------------

     p WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       GetCurrStamp();

       slgTyp = type;

       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #pgm;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p                 e
