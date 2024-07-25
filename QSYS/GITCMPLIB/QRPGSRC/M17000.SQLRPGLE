      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M17000     Generate Production Yield Work File Data
     *  06 March 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
650 A*    03/06/15  KDE  6.50
     *      - Created.
700 A*    10/27/15  KDE  7.00
     *      - Exclude Pallet Build Log Transactions
720 A*    10/17/18  KDE  7.00
     *      - Include backflush in Actual Usage for Yield Report
750 A*    02/09/22  KDE  7.50
     *      - ENH:  Account for component production in lin slots
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pfromDate   Production From Date
     *      ptoDate     Production To Date
     *      pLine       Production Mfg Line
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fpyieldrpt uf a e           k disk
     fpyieldrpt1uf a e           k disk    rename(smrec:smrectot)
     f                                     prefix(t_)
     fitemprd   if   e           k disk
     fpbom      if   e           k disk
750 Afpwrkordr  if   e           k disk
750 Afitemprdbp if   e           k disk
750 Afpiritem   if   e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
650eA /COPY QCOPYSRC,ID#PACKERS

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d pErr            s             99
     D pSessId         s             40
     D pWhse           s              3p 0
     D pfromDate       s              8p 0
     D ptodate         s              8p 0
     D pline           s              3p 0
     D pOutStr         s            512
     D wherelabel      s            300
     d wrkRmi          s             15

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D plrec         E Ds                  Extname(prodlog)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pfromdate
     c                   parm                    ptodate
     c                   parm                    pline
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = '*OK';
        exsr generateYield;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  accumFG   Accumulate FG totals by looping thru BOM
     *----------------------------------------------------------------

      /free
       begsr accumFG;

          // Loop thru Bill of Material adding standard usage
            setll (plwhse:plitem) pbom;
            reade (plwhse:plitem) pbom;
            if %equal(pbom) and not %eof(pbom);
               dow forever = forever;
                  if %eof(pbom);
                     leave;
                  endif;
                  // ensure active bom and should be backflushed
                  if bmeffd <= %dec(%char(%date():*iso0):8:0)
                       and bmexpd >= %dec(%char(%date():*iso0):8:0);
                       wrkRmi = bmrmi;
                       exsr getYieldrec;
                       smrectyp = 'D';
                       smfgi = bmfgi;
                       smbmen = bmqtyn;
                       smbme1 = bmqty1;
                       smbme2 = bmqty2;
                       smbmep = bmprdq;
                       smbmpn = smbmpn + bmqtyn * plqtyn;
                       smbmp1 = smbmp1 + bmqty1 * plqtyn;
                       smbmp2 = smbmp2 + bmqty2 * plqtyn;
                       smbmpp = smbmpp + bmprdq * plqtyn;
                       smmake = smmake + plqtyn;

                       // write or update Yield Detail record
                       if %found(pYieldRpt);
                          update smrec;
                       else;
                          write smrec;
                       endif;

          // accumulate item total record
                       exsr getTotalRec;
                       smfgi = bmfgi;
                       t_smbmen = bmqtyn;
                       t_smbme1 = bmqty1;
                       t_smbme2 = bmqty2;
                       t_smbmep = bmprdq;
                       t_smbmpn = t_smbmpn + bmqtyn * plqtyn;
                       t_smbmp1 = t_smbmp1 + bmqty1 * plqtyn;
                       t_smbmp2 = t_smbmp2 + bmqty2 * plqtyn;
                       t_smbmpp = t_smbmpp + bmprdq * plqtyn;
                       t_smmake = t_smmake + plqtyn;
                       // write or update Yield Work Record
                       if %found(pYieldRpt1);
                          update smrectot;
                       else;
                          write smrectot;
                       endif;
                  endif;
                  reade (plwhse:plitem) pbom;
               enddo;
750 A       else;
750 A         // if by-product then record separately
750 A         // get finished good from work order
750 A         setll (plwhse:plbfcwo) pwrkordr;
750 A         reade (plwhse:plbfcwo) pwrkordr;
750 A         if %equal(pwrkordr);
750 A           // now see if this is a by-product
750 A           setll (plwhse:wrfgi) itemprdbp;
750 A           dow forever=forever;
750 A             reade (plwhse:wrfgi) itemprdbp;
750 A             if %eof(itemprdbp);
750 A               leave;
750 A             endif;
750 A             if iybpitm=plitem;
750 A               // Determine proper UOM
750 A               if plweght <> 0;
750 A                 chain (plwhse:plitem) piritem;
750 A                 if %found(piritem);
750 A                   if itum1='LB' or itum2='LB' or itum3='LB';
750 A                     select;
750 A                       when itum1='LB';
750 A                         plqtyn=plweght;
750 A                       when itum2='LB';
750 A                         plqty1=plweght;
750 A                         plqtyn=0;
750 A                       when itum3='LB';
750 A                         plqty2=plweght;
750 A                         plqty1=0;
750 A                         plqtyn=0;
750 A                     endsl;
750 A                   endif;
750 A                 endif;
750 A               endif;
750 A               plaction='PXX';                // PXX will cause to be added to Adjustments
750 A               plfgitm='BYPRODUCT';
750 A               exsr accumRM;
750 A               // now reduce usage recorded against original raw material
750 A               // for by-product
750 A               plitem=writem;
750 A               plfgitm=*blanks;
750 A               if plweght <> 0;
750 A                 chain (plwhse:plitem) piritem;
750 A                 if %found(piritem);
750 A                   if itum1='LB' or itum2='LB' or itum3='LB';
750 A                     select;
750 A                       when itum1='LB';
750 A                         plqtyn=plweght;
750 A                       when itum2='LB';
750 A                         plqty1=plweght;
750 A                         plqtyn=0;
750 A                       when itum3='LB';
750 A                         plqty2=plweght;
750 A                         plqty1=0;
750 A                         plqtyn=0;
750 A                     endsl;
750 A                   endif;
750 A                 endif;
750 A               endif;
750 A               plaction='PIU';       // Adjust by-product out of PIU for this report
750 A               exsr accumRM;
750 A             endif;
750 A           enddo;
750 A         endif;
            endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  accumRM   Accumulate purely Raw Material Log records
     *----------------------------------------------------------------

      /free
       begsr accumRM;

          wrkRmi = plitem;
750 A     if plfgitm<>'BYPRODUCT';
750 A      plbfcwo=*blanks;
750 A     endif;
          exsr getYieldrec;
          smfgi = ' ';
750 A     if plfgitm='BYPRODUCT';
750 A       smfgi='BYPRODUCT';
750 A     endif;
          smrectyp = 'D';
          select;
             when plAction = 'BIV';  // Beginning Inventory
                smbivn = smbivn + plqtyn;
                smbiv1 = smbiv1 + plqty1;
                smbiv2 = smbiv2 + plqty2;
             when plAction = 'EIV';  // Ending Inventory
                smeivn = smeivn + plqtyn;
                smeiv1 = smeiv1 + plqty1;
                smeiv2 = smeiv2 + plqty2;
                smeivp = 0;
             when plAction = 'RPL';  // Replenishment
750 A             //or (plAction = 'PSC' and ipPrdFlg='C');
                smrpln = smrpln + plqtyn;
                smrpl1 = smrpl1 + plqty1;
                smrpl2 = smrpl2 + plqty2;
                smrplp = 0;
             when plAction = 'PIW';  // Recorded Usage
                smawstn = smawstn + plqtyn;
                smawst1 = smawst1 + plqty1;
                smawst2 = smawst2 + plqty2;
                smawstp = 0;
             when plAction = 'PBF';  // auto back flush
                smfgi = plfgitm;
720 D       //  smbmpn = smbmpn + plqtyn;
720 D       //  smbmp1 = smbmp1 + plqty1;
720 D       //  smbmp2 = smbmp2 + plqty2;
720 A           smausen = smausen + plqtyn;
720 A           smause1 = smause1 + plqty1;
720 A           smause2 = smause2 + plqty2;
                smbmpp = 0;
                smmake = smmake + plqtyn;
             when plAction = 'PIU';  // Recorded Usage
                smausen = smausen + plqtyn;
                smause1 = smause1 + plqty1;
                smause2 = smause2 + plqty2;
                smausep = 0;
             other;    // mainly adjustments, but also catch all
                smadjn = smadjn + plqtyn;
                smadj1 = smadj1 + plqty1;
                smadj2 = smadj2 + plqty2;
                smadjp = 0;
          endsl;
          // write or update Yield Detail record
          if %found(pYieldRpt);
             update smrec;
          else;
             write smrec;
          endif;

          // update item total record
          exsr getTotalrec;
          smfgi = ' ';
          select;
             when plAction = 'BIV';  // Beginning Inventory
                t_smbivn = t_smbivn + plqtyn;
                t_smbiv1 = t_smbiv1 + plqty1;
                t_smbiv2 = t_smbiv2 + plqty2;
             when plAction = 'EIV';  // Ending Inventory
                t_smeivn = t_smeivn + plqtyn;
                t_smeiv1 = t_smeiv1 + plqty1;
                t_smeiv2 = t_smeiv2 + plqty2;
             when plAction = 'RPL';  // Replenishment
                t_smrpln = t_smrpln + plqtyn;
                t_smrpl1 = t_smrpl1 + plqty1;
                t_smrpl2 = t_smrpl2 + plqty2;
             when plAction = 'PIW';  // Recorded Usage
                t_smawstn = t_smawstn + plqtyn;
                t_smawst1 = t_smawst1 + plqty1;
                t_smawst2 = t_smawst2 + plqty2;
             when plAction = 'PBF';  // auto back flush
                t_smfgi = plfgitm;
                t_smbmpn = t_smbmpn + plqtyn;
                t_smbmp1 = t_smbmp1 + plqty1;
                t_smbmp2 = t_smbmp2 + plqty2;
                t_smmake = t_smmake + plqtyn;
             when plAction = 'PIU';  // Recorded Usage
                t_smausen = t_smausen + plqtyn;
                t_smause1 = t_smause1 + plqty1;
                t_smause2 = t_smause2 + plqty2;
             other;    // mainly adjustments, but also catch all
                t_smadjn = t_smadjn + plqtyn;
                t_smadj1 = t_smadj1 + plqty1;
                t_smadj2 = t_smadj2 + plqty2;
          endsl;
          // write or update Yield Work Record
          if %found(pYieldRpt1);
             update smrectot;
          else;
             write smrectot;
          endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  accumTotals  Accumulate totals before writing Yield record
     *----------------------------------------------------------------

      /free
       begsr accumTotals;

          chain (plwhse:plitem) itemprd;
          if not %found(itemprd);
             ipprdflg = 'F';
          endif;

          select;
             when plAction = 'PSC'       // Scale Production Entry
                or ipprdflg = 'F';
                exsr accumFG;
750 A           if plAction = 'PSC' and ipPrdFlg='C';
750 A             wrkRmi = plitem;
750 A             exsr accumRM;
750 A           endif;
             other;                      // all others are Inv type Trans
                wrkRmi = plitem;
        //      exsr getYieldrec;
                exsr accumRM;
          endsl;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  createYield  Create Yield Data for reporting
     *----------------------------------------------------------------

      /free
       begsr createYield;

          sqlStmt = 'Select * from prodlog';

          // build select based on parms passed
          // from and to production dates, mfg line and raw
          // material item
          wherelabel = 'where plprddte >=' + %char(pfromdate) +
                       ' and plprddte <= ' + %char(ptoDate) +
700 A                  ' and plaction <> ' + sq + 'PBL' + sq +
                       ' and plwhse = ' + %char(pWhse);

          // From and To date are forced.  If Mfg Line passed
          // then narrow search
          wherelabel = %trim(wherelabel) +
                     ' and plline = ' + %char(pLine);

          // append join information and data selection to select
          sqlStmt = %trim(sqlStmt) + ' ' +
                     %trim(whereLabel);

          // append order by to select clause
          sqlStmt = %trim(sqlStmt) + ' order by plitem, plbfcwo, +
                          plprddte, plcts';

          exec sql PREPARE Rpt FROM :SqlStmt;
          exec sql DECLARE YieldRpt SCROLL CURSOR FOR Rpt;
          exec sql OPEN YieldRpt;
          exec sql
            fetch first from YieldRpt into :plrec;

          if sqlstt = sqlSuccess;
            dow sqlstt = sqlSuccess;
               exsr accumTotals;
               exec sql
                fetch next from Yieldrpt into :plrec;
            enddo;
          else;   // sql failed for some reason
             if sqlstt = '02000';   // eof..no records
                // no records exist
                pErr = 'No Yield Data for selections';
             else;
                // return error that SQL failed
                pErr = 'SQL error ' + sqlstt + ' occurred.  No Yields';
             endif;
          endif;
          exec sql CLOSE YieldRpt;
       endsr;

      /end-free

     *----------------------------------------------------------------
     *  generateYield  Generate Report requests for Yield per User
     *----------------------------------------------------------------

      /free
       begsr generateYield;

          // Clear previous records for requesting Session Id
             exec sql delete from PYIELDRPT
                  where smSessid = :pSessId;
             exsr createYield;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getYieldrec  Retrieve or Initialize Yield Work Record
     *----------------------------------------------------------------

      /free
       begsr getYieldrec;

          // see if Yield Record exists
        chain (pSessId:plwhse:plprddte:plline:wrkRmi:plbfcwo:'D') pYieldrpt;
          if not %found(pYieldRpt);
             // if no record, setup key values and zero accumulators
             clear smrec;
             smsessid = pSessid;
             smwhse = plwhse;
             smline = plline;
             smprddte = plprddte;
             smrmi = wrkRmi;
             smwo = plbfcwo;
          endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  wrtItemTotal  Write item total record to Yield Work File
     *----------------------------------------------------------------

      /free
       begsr getTotalRec;

        clear smrectot;
        // see if Yield Item Total Record Exists
        chain (pSessId:plwhse:plprddte:plline:wrkRmi:' ':'T') pYieldrpt1;
        if not %found(pYieldRpt1);
           // if no total record found set key values
           clear smrectot;
           t_smsessid = pSessid;
           t_smwhse = pWhse;
           t_smline = pline;
           t_smprddte = pfromdate;
           t_smrmi = wrkRmi;
           t_smrectyp = 'T';
          endif;

       endsr;

      /end-free
