      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M13400H     Purchase Order Receiving Header
      *  20 June 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    06/20/14  LMC  6.50
      *      - Created.
     *      - Returns value field for displaying on list.
      *
650a  *    10/07/14  LMC  6.50a
      *      - Enh - Added estimated pallets
650b  *    10/27/14  LMC  6.50b
      *      - Enh - Get Quantity ordered and received
650c  *    10/28/14  LMC  6.50c
      *      - Enh - Added super po logic
650d  *    10/29/14  LMC  6.50d
      *      - Enh - Retrieve weight to eliminate the need for I09400H
650e  *    11/07/14  LMC  6.50e
      *      - Enh - Check security to see if user has access to Delete
      *      - Enh - Add the two lumper/palletized fields from Lumper
700a  *    08/19/15  LMC  7.00a
      *      - Enh - Need to get PCM flags to control cog entries
700b  *    06/03/16  LMC  7.00b
     *      - Exclude branded item po detail lines from summary totals
     *        for Qty Ordered/Received.
700c  *    07/07/16  LMC  7.00c
     *      - Exclude branded item po detail lines from the check for
     *        BlockExport.
700d  *    12/20/16  LMC  7.00d
     *      - Clean up pirhold LOCKED record. Which is used in M13500H
     *        to reduce the delay when a lock exist.
700e  *    01/03/17  LMC  7.00e
     *      - Changed status description to include the status field
     *        value - per Roxanne, so the user can select based on
     *        the value of the status field.
710a  *    07/20/17  LMC  7.10a
     *      - Added logic to control partial export based on new flag
     *        in receiving options.
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
720bA*    09/24/18  DAS  7.20b
     *      - Added 'Complete' flag (see notes)
720cA*    09/26/18  LMC  7.20c
     *      - additional enhancements for 'Complete' flag
     *      - Added a count of the lines with PCM Exceptions.
740aA*    03/02/20  DAS  7.40a
     *      - Added indicator to SQL statement for CLSTRANS field.
     *        When no records are found, it writes a message to
     *        the job log.
     *      - When no records found in the above SQL statement,
     *        set CLSTRANS to zero.
     *      - Removed exRtnCode, exRtnMsg and exWhse defs,
     *        they are now defined in copysrc.
740bA*    09/10/20  KDE  7.40b
     *      - Added list parm of po's when super po
750aA*    04/23/21  LMC  7.50a
     *      - If client use pcm exclusions - you cannot change
     *        PCM from the header level. Becuase exclusion can
     *        be based on item/dept/category.
     *        So we will set PCMALLOW to N, to condition displaying
     *        the cog entry to allow pcm change to display.
      *----------------------------------------------------------
     *----------------------------------------------------------------
PAN  *  Client Custom Revisions: Panos
     *    04/05/17  LMC  PANa
PANa *      - Disable ability to do partial export.
     *
     *----------------------------------------------------------------
ADF  *  Client Custom Revisions: A&D Foods
     *    04/19/17  LMC  ADFa
ADFa *      - Disable ability to do partial export.
     *
     *----------------------------------------------------------------
GRC  *  Client Custom Revisions: Greco
GRCa *    09/24/18  DAS  GRCa
     *      - Disable ability to do partial export.
     *      - Block export if PO not Complete
     *
GRCb *    09/26/18  LMC  GRCb
     *      - Turn on a field to notify gui to show the complete flag
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------


650aA*----------------------------------------------------------------
650aA* Called program prototypes
650aA*----------------------------------------------------------------

650aA /copy qcopysrc,p.getpales
650eA /copy qcopysrc,p.getclien
650eA /copy qcopysrc,p.chklist
650ea /copy qcopysrc,p.cvtcase
720bAd/copy qcopysrc,p.expohdr
720cAd/copy qcopysrc,p.getpcmex

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D cvt2Upper       pr           500
     D  zIn                         500    const

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pPO            s              9
650eAD  pUser          s             10
700dAD  pSess          s             40
740bDD* pOutStr        s            512    varying
740bMD  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

650eA*----------------------------------------------------------------
650eA*  Customer id
650eA*----------------------------------------------------------------

650eA /copy qcopysrc,id#coastal
650eA /COPY QCOPYSRC,ID#SAVAL
650eA /COPY QCOPYSRC,ID#GFS
650eA /COPY QCOPYSRC,ID#EGF
650eA /COPY QCOPYSRC,ID#CITYLIN
650eA /COPY QCOPYSRC,ID#PACKERS
650eA /COPY QCOPYSRC,ID#JORDANO
650eA /COPY QCOPYSRC,ID#GLAZIER
PAN A /copy qcopysrc,id#pan
ADFaA /copy qcopysrc,id#adf
GRCaA /copy qcopysrc,id#grc

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

650eAD AllowDelete     s              1
650eAD chklistrtn      s             10
     D count           s              5p 0
650eAD option          s             20
     D StatusDesc      s             20
     D MarkExport      s              1
     D MarkExportP     s              1
     D lumper          s              1
     D palletized      s              1
700aAD PCMExist        s              1
700aAD PCMAllow        s              1
650cAD BlockExport     s               n
PANaAD BlockPartial    s              1
650cAD ExportText      s             30
650cAD OnSuperPO       s              9
650cAD super           s               n
740bAd superlist       s            250
650aAD TotalPallet     s              5s 0
650aAD palletitem      s             15
650aAD palletseq       s              5  0 inz(0)
650aAD palletwhse      s              3s 0
720bAD poComplete      s               n
740aDD*exRtnCode       s             10
740aDD*exRtnMsg        s             60
740aDD*exWhse          s              3s 0
720bAD ttlTrans        s              5  0
720bAD clsTrans        s              5  0
720cAD ShowCmpFlg      s               n

650bAD QtyRec          s              6s 0
650bAD Qty1            s              6s 0
650bAD Qty2            s              6s 0
650bAD Qty3            s              6s 0
650dAD WgtRec          s             10s 2
650dAD Wgt             s             10s 2
650bAD QtyOrd          s              6s 0
650bAD QtyO1           s              6s 0
650bAD QtyO2           s              6s 0
650bAD QtyO3           s              6s 0
720cAD PCMExcpCount    s              5p 0
720cAD PCMdetail       s              5p 0 Inz(0)

650eAD client          s             10
650eAD clientloc       s             10

740aAd ind1            s              5i 0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
650bAD pdrec         E Ds                  Extname(podtl)
650bAD porrec        E Ds                  Extname(porcv)
650cAD purec         E Ds                  Extname(pospo)
650cAD lmrec         E Ds                  Extname(lumper)
     D phmrec        E Ds                  Extname(pohdrm)
     D opsrcv        E Ds                  Extname(opsrcvlbl)
700aAD hlrec         e ds                  extname(haccplog)
700dAD horec         e ds                  extname(pirhold)
750aAD herec         e ds                  extname(haccpe)


     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pPO          Purchase Order
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
650eAc                   parm                    pUser
700dAc                   parm                    psess
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        pOutStr = ' ';

        // Get Po Status Description

        StatusDesc = ' ';
        MarkExport = ' ';
        MarkExportP = ' ';
        exec sql select * into :phrec
             from pohdr
             where phwhse = :pWhse
               and phpo   = :pPO;

        If sqlstt <> sqlSuccess;
          return;
        endif;
        select;
          when phstat = '0';
700eD       //StatusDesc = 'Open';
700eM       StatusDesc = '0=Open';
          when phstat = '1';
700eD       //StatusDesc = 'Partial receipt';
700eM       StatusDesc = '1=Partial receipt';
          when phstat = '2';
700eD       //StatusDesc = 'Received in full';
700eM       StatusDesc = '2=Received in full';
          when phstat = '3';
700eD       //StatusDesc = 'Ready for export';
700eM       StatusDesc = '3=Ready for export';
            MarkExport = 'Y';
          when phstat = '4';
700eD       //StatusDesc = 'Partial export';
700eM       StatusDesc = '4=Partial export';
            MarkExportP = 'Y';
          when phstat = '5';
700eD       //StatusDesc = 'Import error';
700eM       StatusDesc = '5=Import error';
        endsl;

720cA    ShowCmpFlg = *off;

GRCbA   // For Greco, Turn on ShowCmpFlg.
GRCbA
GRCbA   if client = greco;
GRCbA     ShowCmpFlg = *on;
GRCbA   endif;

650aA   // get pallet estimates

650aA   TotalPallet = 0;
650aA   palletwhse = pwhse;
650aA   GetPalEst(palletwhse: ppo: palletseq: palletitem:
650aA            TotalPallet);

650bA   // get quantity ordered and received

650bA   QtyRec = 0;
650bA   QtyOrd = 0;
650dA   WgtRec = 0;

650cA   // is pPO a super po?

        exec sql select * into :purec
                 from pospo
                 where puwhse = :pWhse
                   and puspo   = :pPO
                 fetch first 1 rows only;

        If sqlstt = sqlSuccess;
          super = *on;
720cA     ShowCmpFlg = *off;
GRCbA     if client = greco;
GRCbA       BlockExport = *on;
GRCbA       ExportText = ('Super Po Export Not allowed');
GRCbA     endif;
        else;
          super = *off;
          lumper = 'N';
          palletized = 'N';
        endif;

740bA   superlist = *blanks;
650cA   select;

650cA     when super;
            OnSuperPO  = ' ';
650cA       // get the po's linked to the super po
            SqlStmt = 'select * from pospo '
                +     'where puwhse = ' + %char(pWhse) + ' '
                +       'and puspo = '
                +       sq + %trimr(pPO) + sq;
            exec sql prepare sposel from :SqlStmt;
            exec sql declare spocsr cursor for sposel;
            exec sql open spocsr;
650cA       //setll (pwhse: ppo) pospo;
650cA       dow forever = forever;
              exec sql fetch next from spocsr
                       into :purec;
              if sqlstt <> sqlSuccess;
                exec sql close spocsr;
                leave;
              endif;
740bA         if superlist=*blanks;
740bA           superlist=%trim(pupo);
740bA         else;
740bA           monitor;
740bA             superlist=%trim(superlist) + ' ' + %trim(pupo);
740bA           on-error;
740bA           endmon;
740bA         endif;
650cA         exec sql select sum(pdqrc1), sum(pdqrc2), sum(pdqrc3),
650dA                         sum(pddwgt),
650cA                         sum(pdqor1), sum(pdqor2), sum(pdqor3)
650dM                  into :qty1,:qty2,:qty3,:wgt,:qtyO1,:qtyO2,:qtyO3
650cA                  from podtl
650cA                  where pdwhse = :pWhse
650cA                    and pdpo   = :pupo
700bA                    and pdspcl <>'BR';
650cA         If sqlstt = sqlSuccess;
650cA           QtyRec = QtyRec + qty1 + qty2 + qty3;
650cA           QtyOrd = Qtyord + qtyO1 + qtyO2 + qtyO3;
650dA           WgtRec = WgtRec + wgt;
650ca         endif;
GRCbD         //if opfrcm = 'Y';
GRCbM         if opfrcm = 'Y' and client <> greco;
                BlockExport = *off;
                ExportText = ' ';
                count = 0;
                // all lines must be touched
                exec sql select count(*) into :count
                         from podtl T01 exception join porcv T02
                         on T01.pdpo=T02.porpo and T01.Pdwhse=T02.porwhs
                           and T01.pdseq=T02.porseq
                         where (T02.porseq is null)
                           and t01.pdwhse  = :pWhse
700cA                      and t01.pdspcl <> 'BR'
                           and t01.pdpo  = :puPO;
                if sqlstt = sqlsuccess;
                  if count > 0;
                    BlockExport = *on;
                    ExportText = ('Po Lines not Marked-'+ pupo);
                  endif;
                endif;
              endif;
              // Packers missing destination storage location
650eA         if client = packers;
                exec sql select * into :phmrec
                         from pohdrm
                         where phmwh  = :pWhse
                           and phmpo  = :puPO;
                if sqlstt = sqlsuccess
                   and %subst(phmm5:1:4) = '0000';
                  BlockExport = *on;
                  ExportText = (%trim(puPO) + ' ' + 'Missing Destination');
                endif;
              endif;
650ca       enddo;

          // no po's tied to super at this time - need super flag
          // to allow Gui receiving link
650cA     when not super  and
               pPO >= 'SP0000001' and pPO <= 'SP9999999';
            super = *on;
720cA       ShowCmpFlg = *off;
GRCbA       if client = greco;
GRCbA         BlockExport = *on;
GRCbA         ExportText = ('Super Po Export Not allowed');
GRCbA       endif;
            OnSuperPO  = ' ';

650cA     other;
650bA       exec sql select sum(pdqrc1), sum(pdqrc2), sum(pdqrc3),
650dA                         sum(pddwgt),
650bA                       sum(pdqor1), sum(pdqor2), sum(pdqor3)
650dM                  into :qty1,:qty2,:qty3,:wgt,:qtyO1,:qtyO2,:qtyO3
650bA                from podtl
650bA                where pdwhse = :pWhse
650bA                  and pdpo   = :pPO
700bA                  and pdspcl <>'BR';
650bA       If sqlstt = sqlSuccess;
650bA         QtyRec = qty1 + qty2 + qty3;
650bA         QtyOrd = qtyO1 + qtyO2 + qtyO3;
650dA         WgtRec = wgt;
650ba       endif;
            // get lumper information
            lumper = 'N';
            palletized = 'N';
            exec sql select * into :lmrec
             from lumper
             where lmwhse = :pWhse
               and lmpo   = :pPO
               and lmhedt = 0;

            If sqlstt = sqlSuccess;
              lumper = lmlmpr;
              palletized = lmpalt;
            endif;
            // Block export function
            BlockExport = *off;
            ExportText = ' ';
            OnSuperPO  = ' ';
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and pupo   = :pPO;

            Select;
              // attached to super po
              When sqlstt = sqlSuccess;
                BlockExport = *on;
                ExportText = ('On ' + puspo);
                OnSuperPO = puspo;
              // block export function if import error status
              When phstat = '5';
                BlockExport = *on;
                ExportText = ('Import Problem');
              // Packers missing destination storage location
650eA         when client = packers;
                exec sql select * into :phmrec
                         from pohdrm
                         where phmwh  = :pWhse
                           and phmpo  = :pPO;
                if sqlstt = sqlsuccess
                   and %subst(phmm5:1:4) = '0000';
                  BlockExport = *on;
                  ExportText = ('Missing Destination');
                endif;
650eA         when opfrcm = 'Y';
                count = 0;
                // all lines must be touched
                exec sql select count(*) into :count
                         from podtl T01 exception join porcv T02
                         on T01.pdpo=T02.porpo and T01.Pdwhse=T02.porwhs
                           and T01.pdseq=T02.porseq
                         where (T02.porseq is null)
                           and t01.pdwhse  = :pWhse
700cA                      and t01.pdspcl <> 'BR'
                           and t01.pdpo  = :pPO;
                if sqlstt = sqlsuccess;
                  if count > 0;
                    BlockExport = *on;
720cA               ShowCmpFlg = *off;
                    ExportText = ('All Po Lines not Marked');
                  endif;
                endif;
              other;
            endsl;
720cA       // how many lines have exceptions
720cA           count = 0;
720cA           exec sql select count(*) into :count
720cA                    from podtl T01 join haccplog T02
720cA                    on T01.pdpo=T02.hlpo and T01.Pdwhse=T02.hlwhse
720cA                      and T01.pdseq=T02.hlposeq
720cA                    where T02.hlobsolete <> 'Y'
720cA                      and t01.pdwhse  = :pWhse
720cA                      and t01.pdspcl <> 'BR'
720cA                      and t02.hllevl = 'REXI'
720cA                      and t01.pdpo  = :pPO
720cA                    fetch first row only;
720cA           if sqlstt = sqlsuccess;
720cA             if count > 0;
720cA               // exceptions found, how many items have exceptions
720cA               getpcmex(pwhse: ppo: PCMDetail: PCMExcpCount);
720cA
720cA               //PCMExcpCount += 1;
720cA             endif;
720cA           endif;

650cA   endsl;

740bA   // create super po list parm if they exist
740bA   if superlist <> *blanks;
740bA     superlist = '&rls_PDPO=LS&val_PDPO=' + %trim(superlist);
740bA   endif;

650eA   // check user security for delete allowed

650eA   AllowDelete = ' ';
650eA   Select;
650eA     when client = saval
650eA      or  client = egf
650eA      or  client = getfresh;
650eA       // check to see if user has access
650eA       option = 'DELETE';
650ea       chklist(#prog: %trim(option): Puser: chklistrtn);
650eA       if chklistrtn = '*NO ';
650eA         AllowDelete = 'N';
650eA       else;
650eA         AllowDelete = 'Y';
650eA       endif;
650eA     other;
650eA       AllowDelete = 'Y';
650eA   endsl;

700aA   // check to see if pcm records exist

700aA   PCMExist = ' ';
700aA   PCMAllow = ' ';
700aA   select;
700aA     when super;
700aA       exec sql select * into :hlrec
700aA                from haccplog
700aA                where hlwhse = :pwhse
700aA                  and hlspo   = :ppo
700aA                  and hlexpts = '0001-01-01-00.00.00.000000'
700aA                  and hlobsolete <> 'Y'
700aA                fetch first row only;
700aA     other;
700aA       exec sql select * into :hlrec
700aA                from haccplog
700aA                where hlwhse = :pwhse
700aA                  and hlpo   = :ppo
700aA                  and hlexpts = '0001-01-01-00.00.00.000000'
700aA                  and hlobsolete <> 'Y'
700aA                fetch first row only;
700aA   endsl;
700aA      if sqlstt = sqlSuccess;
700aA          PCMExist = 'Y';
700aA      endif;

700aA   // see if we have non exception pcm records. These we allow to
700aA   // to be changed from the po list display

700aA   select;
700aA     when super;
700aA       exec sql select * into :hlrec
700aA                from haccplog
700aA                where hlwhse = :pwhse
700aA                  and hlspo   = :ppo
700aA                  and hlexpts = '0001-01-01-00.00.00.000000'
700aA                  and hlobsolete <> 'Y'
700aA                  and hllevl     <> 'REXI'
700aA                fetch first row only;
700aA     other;
700aA       exec sql select * into :hlrec
700aA                from haccplog
700aA                where hlwhse = :pwhse
700aA                  and hlpo   = :ppo
700aA                  and hlexpts = '0001-01-01-00.00.00.000000'
700aA                  and hlobsolete <> 'Y'
700aA                  and hllevl     <> 'REXI'
700aA                fetch first row only;
700aA   endsl;
700aA   if sqlstt = sqlSuccess;
700aA     PCMAllow = 'Y';
700aA   endif;
750aA   // If client uses PCM exclusion no change allowed at the PO
750aA   // header.
750aA       exec sql select * into :herec
750aA                from haccpe
750aA                where hewhse = :pwhse
750aA                fetch first row only;
750aA   if sqlstt = sqlSuccess;
750aA     PCMAllow = ' ';
750aA   endif;

PANaA   // Panos Host can not handle partial export

PANaA   if client = panos;
PANaA     BlockPartial = *on;
PANaA   endif;

PANaA   // A&D Host can not handle partial export

ADFaA   if client = AandDFoods;
ADFaA     BlockPartial = *on;
ADFaA   endif;

GRCaA   // Greco 2-Stage Export process doesn't work with partial export
GRCaA
GRCaA   if client = greco;
GRCaA     BlockPartial = *on;
GRCaA   endif;

720bA   // Get 'Complete' flag
720bA
720bA    poComplete = *off;
720bA    monitor;
720bA      exWhse = pwhse;
720bA      expohdr('*GET': exRtnCode: exRtnMsg: exWhse: ppo: phacmpflg);
720bA      if exRtnCode = '*OK' and phacmpflg = 'Y';
720bA        poComplete = *on;
720bA      endif;
720bA    on-error;
720bA    endmon;

GRCaA   // For Greco, if Complete is off, then block export
GRCaA
GRCbD   //if client = greco and not poComplete;
GRCbM   if client = greco and not poComplete
GRCbA      and BlockExport = *off and ShowCmpFlg = *on;
GRCaA     BlockExport = *on;
GRCaA     ExportText = 'PO not marked Completed';
GRCaA   endif;

720bA   // Get Total/Closed transactions for PO
720bA
720bA   exec sql
720bA     select count(*),
720bA            sum(case when ptstat <> '1' then 1 else 0 end)
740aD       //into :ttlTrans, :clsTrans
740aM       into :ttlTrans, :clsTrans :ind1
720bA       from pirtran
720bA       where ptwhse = :pwhse
720bA         and ptrtpo = :ppo
720bA         and pttask = 'PUTEMP'
720bA         and ptpcs > 0;

740aA    if ttlTrans = 0;
740aA      clsTrans = 0;
740aA    endif;

         // Put together JSON string

         pOutStr = '{'
                +  '"stscd":"'  + %trimr(phstat) + '",'
650aA           +  '"TPal":"'  + %char(TotalPallet) + '",'
650bA           +  '"QtyO":"'  + %char(QtyOrd) + '",'
650bA           +  '"QtyR":"'  + %char(QtyRec) + '",'
650dA           +  '"WgtR":"'  + %char(WgtRec) + '",'
650cA           +  '"Super":"'  + %trimr(Super) + '",'
650cA           +  '"OnSuper":"'  + %trimr(OnSuperPO) + '",'
650eA           +  '"Dlt":"'  + %trimr(AllowDelete) + '",'
                +  '"Lump":"'  + %trimr(Lumper) + '",'
                +  '"LPal":"'  + %trimr(palletized) + '",'
                +  '"MExp":"'  + %trimr(MarkExport) + '",'
                +  '"MExpP":"'  + %trimr(MarkExportP) + '",'
                +  '"BlockExp":"'  + %trimr(BlockExport) + '",'
                +  '"BlockExpT":"'  + %trimr(ExportText) + '",'
700aA           +  '"PCMExist":"'  + %trimr(pcmexist) + '",'
700aA           +  '"PCMAllow":"'  + %trimr(pcmallow) + '",'
PANaA           +  '"BlockPExp":"'  + %trimr(BlockPartial) + '",'
720bA           +  '"CmpFlg":"'  + %trimr(poComplete) + '",'
720bA           +  '"TtlTrans":"' + %char(ttlTrans) + '",'
720bA           +  '"ClsTrans":"' + %char(clsTrans) + '",'
720cA           +  '"ShowCmpFlg":"' + %trimr(ShowCmpFlg) + '",'
740bA           +  '"superlist":"' + %trimr(superlist) + '",'
720cA           +  '"PCMECnt":"'  + %char(PCMExcpCount) + '",'
                +  '"stat":"'  + %trimr(StatusDesc) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

650eA   getclient(client: clientLoc);
        // see if all lines must be touched
        exec sql select * into :opsrcv
                 from opsrcvlbl
                 where opwhse  = :pWhse;
        if sqlstt = sqlsuccess;
710aA     if oppexp = 'N';
710aA       BlockPartial = *on;
710aA     endif;
        else;
          opfrcm = 'N';
        endif;
700dA   exec sql delete from pirhold
700dA        where hosess = :psess
700dA          and hotype = 'LOCKED';
           endsr;

      /end-free

     *----------------------------------------------------------------
     *  cvt2Upper  Convert to upper case
     *----------------------------------------------------------------

     p cvt2Upper       b
     d cvt2Upper       pi           500
     d  sIn                         500    const

     * Local variables

     d  sOut           s            500

      /free

         cvtCase('*LOW2UPR': sIn: sOut);
         return sOut;

      /end-free
     p cvt2Upper       e

