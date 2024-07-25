      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR13200      PO Receiving - License entry - retieve uom for entry
     *  01 January 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    01/14/15  LMC  7.00
     *      - Created.
     *
700aA*    12/17/15  LMC  7.00a
     *      - Needs to validate the number of licenses entered
     *        matches the number of pallets from the detail screen
700bA*    02/11/16  LMC  7.00b
     *      - Logic needed for license level PCM. RCVL
700c *    06/01/16  LMC  7.00c
     *      - Enh-Need to retrieve *rcvlbl from options to
     *        be used for protecting/requiring the license to be
700d *    06/22/16  LMC  7.00d
     *      - Fix - multiple uoms received on same pallet.
     *        licensecnt is overstated, when in fact the user
     *        receives multiple UOM on same pallet, we require a
     *        license for each UOM on the pallet.
     *        When this occurs our licensecnt won't match pallet count
     *        received. changed to take multiple UOM into account.
700e *    12/16/16  DAS  7.00e
     *      - Fix - Ensure UOMCnt is not zero
700f *    12/16/16  DAS  7.00f
     *      - Enh - Write PIRHOLD record when not found.
710a *    02/06/17  LMC  7.10a
     *      - Enh - Added program to incoming parms for debugging.
710b *    04/13/17  LMC  7.10b
     *      - Enh - Clients who use Generic License = 'N' but are
     *       doing OSS receiving, need to be treated like they have
     *       Use Generic License = 'Y', and they will be required to
     *       Scan/Enter a license.
720a *    07/31/18  LMC  7.20a
     *      - Fix - If the item is non stock coded with an * in the
     *       last position of the designation code. set on the ENTDONE
     *       field to Y. so we don't display the license entry screen.
720b *    10/17/18  LMC  7.20b
     *      - Enh - Add logic to determine if box labeler should be
     *       used on this item.
720c *    10/30/18  LMC  7.20c
     *      - Enh - Add logic to be able to send pick slot receiving
     *       into this program to get box labels. But don't do any
     *       of the other processing.
740aA*    07/22/20  LMC  7.40a
     *      - Enh: Show notification for placement of license.
     *        Based on new receiving options opspn1,opspn2,opspn3.
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIPaA*    07/27/20  LMC  VIPa - found in PO236 04/29/16 MLB
     *      - Check if item category = ALLERGEN, then load info msg.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Purchase Order Seq#
     *      pPOItem     Purchase Order Item
710aA*      pPgm        Program
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

700bDF*pirhold   if   e           k disk    rename(horec:holcn)
700fDF*irhold   uf   e           k disk    rename(horec:holcn)
700fMFpirhold   uf a e           k disk    rename(horec:holcn)
     Flabel2    if   e           k disk
740aAFslot3     if   e           k disk
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
740aA*----------------------------------------------------------------
740aA*  Customer id
740aA*----------------------------------------------------------------

740aA /copy qcopysrc,id#sgc
VIPaA /COPY QCOPYSRC,Id#VIP

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
700bA /copy qcopysrc,p.CHKPCM

     *----------------------------------------------------------------
     *  PIRHOLD
     *----------------------------------------------------------------

      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLLCN
700cA*----------------------------------------------------------------
700cA* Data structure
700cA*
700cA*    OPPLCN  -  Use Generic License                              )
740aA*    OPSPN1  -  Spin pallet for license placement      (Y,N)     (Y/N)
740aA*    OPSPN2  -  Spin pallet length                               (Y/N)
740aA*    OPSPN3  -  Spin pallet text                                 (Y/N)
700cA*
700cAD optionrec       ds
700cAD  opplcn                23     23
740aAD  opspn1                46     46
740aAD  opspn2                47     49  0
740aAD  opspn3                50     59
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psession        s             40
710aAD ppgm            s             20
     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D pPOItem         s             15
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D sumqty1         s              5p 0
     D sumqty2         s              5p 0
     D sumqty3         s              5p 0
     D Entqty          s              5p 0
     D EntUom          s              5
     D EntDone         s              1
720bAD BoxLabelerN     s              1
720bAD BoxLabeler1     s              1
720bAD BoxLabeler2     s              1
720bAD uomN            s              2
720bAD uom1            s              2
720bAD uom2            s              2
720bAD qtyN            s              5  0
720bAD qty1            s              5  0
720bAD qty2            s              5  0
     D EntPCM          s              1
     D keytype         s             10
     D NoLicense       s               n
700aAD LicenseCnt      s              5p 0
700dAD UOMCnt          s              3p 0

700bAD pcmcmd          s              8
700bAD pcmlvl          s              4
700bAD pcmsup          s              1
700bAD pcmtyp          s              3
700bAD pentpcm         s              1
700bAD pcmseq          s              5  0
700bAD pcmwhse         s              3s 0
700bAD pcmlcns         s             15
700cAD ocode           s              8
720aAD iatest          s              1
740aAD lcnsplace       s             10
740aAD kypick          s              1
740aAD kystat          s              2
740aAD chk4err         s               n
VIPaAD allergen        s             50
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
740aA /COPY *libl/qcopysrc,C#SLOTDEF
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

650bAD horec         E Ds                  Extname(pirhold)
700cAD oprec         E Ds                  Extname(options)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSession
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
710aAc                   parm                    pPgm
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        hokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        exec sql select * into :horec
           from pirhold
           where hosess = :pSession
             and hokey  = :hokey
             and hotype = 'PODTL';
        If sqlstt = sqlSuccess;
          pirhldpods = hodata;
710bA     // treat OSS Receiving as using Generic License = 'Y'
710bA     if lflag = *on and osscode <> ' ';
710bA       opplcn = 'Y';
710bA     endif;
        else;
700fA     hosess = pSession;
700fA     hokey  = hokey;
700fA     hotype = 'R13200NF';
710aD     //hodata = sqlstt;
710aM     hodata = sqlstt + ppgm;
700fA     hoaddts = %timestamp();
700fA     hoadduc = hoaddts;
700fA     write(e) holcn;
        endif;
720cA   if psrcvreq = 'Y' or psrusr = 'Y';
720cA   else;
        // we will retrieve all the plates to accumulate the qty per uom
        // retrieve all the pirhold POLCNS records
        NoLicense = *on;
700aA   LicenseCnt = 0;
700dA   UOMCnt = 0;
        eval keytype = 'POLCNS';
        setll (psession: keytype) pirhold;
        dow not %eof(pirhold);
700bD     //reade (psession: keytype) pirhold;
700bM     reade(n) (psession: keytype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
700aA     LicenseCnt = LicenseCnt + 1;
          pirhllcnds = hodata;
          NoLicense = *off;
          select;
            when h1uom = w1um1;
              sumqty1 = sumqty1 + h1qty;
            when h1uom = w1um2;
              sumqty2 = sumqty2 + h1qty;
            when h1uom = w1um3;
              sumqty3 = sumqty3 + h1qty;
          endsl;
        enddo;

        // check to see if we can auto load the enter qty
        // This is only done if the number of pallets is one and
        // only one UOM qty was received.
        Entqty = 0;
        if w1plts = 1 and NoLicense;
          select;
            when w1qrc1 > 0 and w1qrc2 = 0 and w1qrc3 = 0;
              Entqty = w1qrc1;
            when w1qrc1 = 0 and w1qrc2 > 0 and w1qrc3 = 0;
              Entqty = w1qrc2;
            when w1qrc1 = 0 and w1qrc2 = 0 and w1qrc3 > 0;
              Entqty = w1qrc3;
          endsl;
        endif;
        // lets see if we can load info for directed
        if directed = 'Y';
          // need to process label2 for directed data
          // if license already entered for the label get the next one
          setll ($lord: pwhse) label2;
          dow not %eof(label2);
            reade ($lord: pwhse) label2;
            if %eof(label2);
              leave;
            endif;
            // is there a license record loaded already for this label?
            exec sql select * into :horec
               from pirhold
               where hosess = :pSession
                 and substr(hodata,13,7) = :lblbl#
                 and substr(hodata,20,7) = :lbtrn#
                 and hotype = 'POLCNS';
            If sqlstt = sqlSuccess;
              iter;
            endif;

            Entqty = lbqalc;
            select;
              when w1qrc1 > 0 and w1qrc2 = 0 and w1qrc3 = 0;
                Entqty = lbqalc;
              when w1qrc1 = 0 and w1qrc2 > 0 and w1qrc3 = 0;
                Entqty = lbqalc;
              when w1qrc1 = 0 and w1qrc2 = 0 and w1qrc3 > 0;
                Entqty = lbqalc;
            endsl;
            leave;

          enddo;
        endif;
        // starting with normal uom
        EntDone = ' ';
700dA   // determine UOMCnt value
700dA   if w1qrc1 > 0;
700dA     UOMCnt = UOMCnt + 1;
700dA   endif;
700dA   if w1qrc2 > 0;
700dA     UOMCnt = UOMCnt + 1;
700dA   endif;
700dA   if w1qrc3 > 0;
700dA     UOMCnt = UOMCnt + 1;
700dA   endif;

700eA   if UOMCnt = 0;
700eA     UOMCnt = 1;
700fA     hosess = pSession;
700fA     hokey  = hokey;
700fA     hotype = 'R13200ZRO';
700fA     hodata = '';
700fA     hoaddts = %timestamp();
700fA     hoadduc = hoaddts;
700fA     write(e) holcn;
700eA   endif;

        select;
          when w1qrc1 > sumqty1;
            EntUom = w1um1;
          when w1qrc2 > sumqty2;
            EntUom = w1um2;
          when w1qrc3 > sumqty3;
            EntUom = w1um3;
          when pPo = ' ';
          when w1qrc1 = sumqty1
           and w1qrc2 = sumqty2
700aD      //and w1qrc3 = sumqty3;
700aM      and w1qrc3 = sumqty3
700dD      //and LicenseCnt = w1plts;
700dM      and (LicenseCnt/UOMCnt) = w1plts;
700aA       EntDone = 'Y';
        endsl;
700bA   // check to see if License level PCM needs to be entered
700bA   // now check to see if Header PCM needs to be entered
700bA   // first get the pirhold license record for any license that
700bA   // is not flagged as pcm done
700bA   eval keytype = 'POLCNS';
700bA   setll (psession: keytype) pirhold;
700bA   dow not %eof(pirhold);
700bA     reade (psession: keytype) pirhold;
700bA     if %eof(pirhold);
700bA       leave;
700bA     endif;
700bA     pirhllcnds = hodata;
700bA     // ignore if pcm is already done
700bA     if h1pcmdone = 'Y';
700bA       iter;
700bA     endif;
700bA     // found a license that is not flagged pcm done
700bA     // do we have pcm questions to answer?
700bA     pcmcmd = '*PODTL';
700bA     pcmlvl = 'RCVL';
700bA     pcmtyp = ' ';
700bA     pcmsup = 'N';
700bA     pcmseq = 0;
700bA     pcmwhse = pwhse;
700bA     // pcmitm or pcmlcns are passed in the same field to chkpcm
700bA     // depending on the level = for RCVL pass license
700bA     pcmlcns = hokey;
700bA     CHKPCM(pcmcmd: pcmwhse: pcmlvl: pcmtyp:
700bA            pPO: pPOSeq: pcmsup: pcmlcns: pentpcm);
700bA     // when pentpcm = N, update POLCNS record to pcm done
700bA     select;
700bA       when pentpcm = 'Y';
700bA         update holcn;
700bA       other;
700bA         h1pcmdone = 'Y';
700bA         hodata = pirhllcnds;
700bA         update holcn;
700bA     endsl;
700bA   enddo;
         // otherwise need to process gui pcm program

700bD   //EntPCM = 'Y';
700bM   EntPCM = pentpcm;

720cA   endif;
720aA   // if the item is non stock set EntDone = 'Y'
720aA   // to save a little time, only do this check if EntDone is not
720bA   // need to do this logic on cross dock, so we get box labels
720aA   if EntDone <> 'Y'
720bA      or EntDone = 'Y' and H1XDK = 'Y'
720cA      or psrcvreq = 'Y'
720cA      or psrusr = 'Y';
          exsr clr$item;

          $itWhse = pwhse;
          $ititem = pPoItem;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          exsr zzzdricop;
          iatest = %subst($itdesg: 5 : 1);
          if iatest = '*';
            EntDone = 'Y';
          endif;
720bA     if $ifrcvmth = '4' and w1qrc1 > 0 or
720bA        $ifrcvmth = '6' and w1qrc1 > 0;
720bA       BoxLabelerN = 'Y';
720bA       uomN  =  $itum1;
720bA       qtyN = w1qrc1;
720bA     endif;
720bA     // 5 and 6 print breakdown1 uom labels
720bA     if $ifrcvmth = '5' and $itum2 <> ' ' and
720bA        $itflg1 = 'Y' or
720bA        $ifrcvmth = '6' and $itum2 <> ' ' and
720bA        $itflg1 = 'Y';
720bA       if w1qrc1 <> 0;
720bA         qty1 = (w1qrc1 * $itumq2) + w1qrc2;
720bA       else;
720bA         qty1 = w1qrc2;
720bA       endif;
720bA       BoxLabeler1 = 'Y';
720bA       uom1 =  $itum2;
720bA     endif;
720bA
720bA     // 5 and 6 print breakdown2 uom labels
720bA     if $ifrcvmth = '5' and $itum3 <> ' ' and
720bA        $itflg2 = 'Y' or
720bA        $ifrcvmth = '6' and $itum3 <> ' ' and
720bA        $itflg2 = 'Y';
720bA       if w1qrc1 <> 0 or w1qrc2 <> 0;
720bA         qty2 = (w1qrc1 * $itumq2 * $itumq3)
720bA              + (w1qrc2 * $itumq3) + w1qrc3;
720bA       else;
720bA         qty2 = w1qrc3;
720bA       endif;
720bA       uom2 =  $itum3;
720bA       BoxLabeler2 = 'Y';
720bA     endif;

720aA   endif;

VIPaA   // Adding message to license screen for Allergen items
VIPaA   allergen = ' ';
VIPaA   if client = vip and $ifcat = 'ALLERGEN';
VIPaA     allergen = '*** Attention ** Allergen Item ** Attention ***';
VIPaA   endif;

740aA   lcnsplace = ' ';
740aA   kystat = 'A ';
740aA   kypick = 'Y';
740aA   setll (pwhse: ppoitem: kystat: kypick) slot3;
740aA   reade(n) (pwhse: ppoitem: kystat: kypick) slot3;
740aA   if not %eof(slot3);
740aA     exsr      clr$slotdef;
740aA     $sdwhse  = slwhse;
740aA     $sdcode  = slsdef;
740aA
740aA     $dricommand = '*SLOTDEF';
740aA     $drisubcmd  = '%GET';
740aA     $drisys2upd = 'D';
740aA     chk4err = *on;
740aA     exsr zzzdricop;
740aA     if not error;
740aA       select;
740aA         when client = sgc;
740aA           if $sdlen < 48;
740aA             lcnsplace = 'SPIN';
740aA           endif;
740aA         when opspn1 = 'Y' and
740aA              $sdlen < opspn2;
740aA           lcnsplace = opspn3;
740aA         other;
740aA       endsl;
740aA     endif;
740aA   endif;

         pOutStr = '{'
                +  '"EntDone":"'  + %trimr(EntDone) + '",'
720bA           +  '"BoxLabelerN":"'  + %trimr(BoxLabelerN) + '",'
720bA           +  '"BoxLabeler1":"'  + %trimr(BoxLabeler1) + '",'
720bA           +  '"BoxLabeler2":"'  + %trimr(BoxLabeler2) + '",'
720bA           +  '"uomN":"'  + %trimr(uomN) + '",'
720bA           +  '"uom1":"'  + %trimr(uom1) + '",'
720bA           +  '"uom2":"'  + %trimr(uom2) + '",'
720bA           +  '"qtyN":"'  + %char(qtyn) + '",'
720bA           +  '"qty1":"'  + %char(qty1) + '",'
720bA           +  '"qty2":"'  + %char(qty2) + '",'
                +  '"DPTLbl":"'  + %char(lblbl#) + '",'
                +  '"DPTTrn":"'  + %char(lbtrn#) + '",'
700cA           +  '"UseGLP":"'  + %trimr(opplcn) + '",'
                +  '"EntPCM":"'  + %trimr(EntPCM) + '",'
700bA           +  '"EntLCNS":"'  + %trimr(pcmlcns) + '",'
                +  '"EntQty":"'  + %char(Entqty) + '",'
740aA           +  '"lplace":"'  + %trimr(lcnsplace) + '",'
VIPaA           +  '"allergen":"'  + %trimr(allergen) + '",'
                +  '"EntUom":"'  + %trimr(EntUom) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

720aA*----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr


740aA*----------------------------------------------------------------
740aA*  clr$slotdef  Clear $slotdef data structure fields
740aA*----------------------------------------------------------------
740aA
740aAC     clr$slotdef   begsr
740aAC                   eval      savever# = $sdver#
740aAC                   clear                   $slotdef
740aAC                   eval      $sdver# = savever#
740aAC                   endsr
740aA
720aA*----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
740aAC                   when      $dricommand = '*SLOTDEF'
740aAC                   eval      $dridata = $slotdef
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
740aAC                   when      $dricommand = '*SLOTDEF'
740aAC                   eval      $slotdef = $dridata
     C                   endsl

     C     enddricop     endsr
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

700cA    // Get RCVLBL option.
700cA   ocode = '*RCVLBL ';
700cA   exec sql select * into :oprec
700cA        from options
700cA        where opwhse = :pwhse
700cA          and opcode = :ocode;

700cA   If sqlstt = sqlSuccess;
700cA     optionrec = opdata;
700cA   else;
700cA     opplcn = 'Y';
700cA   endif;

       endsr;

      /end-free

