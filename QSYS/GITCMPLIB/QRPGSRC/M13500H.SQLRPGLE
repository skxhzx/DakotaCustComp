      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
700iA*----------------------------------------------------------------
700iA*  Binding Directories
700iA*----------------------------------------------------------------

700iAHbnddir('BFCBND')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M13500H     Purchase Order Receiving Detail
      *  20 June 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    06/20/14  LMC  6.50
      *      - Created.
     *      - Returns value field for displaying on list.
650a  *    10/02/14  LMC  6.50a
      *      - Enh - Added po detail message
650b  *    10/07/14  LMC  6.50b
      *      - Enh - Added estimated pallets
650c  *    10/07/14  LMC  6.50c
      *      - Enh - Added touched flag
700a  *    08/19/15  LMC  7.00a
      *      - Enh - Need to get PCM flags to control cog entries
700b  *    10/12/15  LMC  7.00b
      *      - Enh - Add UCI to special receiving information
700c  *    12/15/15  LMC  7.00c
      *      - Enh - Added the cleanup for pirhold type PODTLCW
700d  *    01/13/16  LMC  7.00d
      *      - Enh - Added the cleanup for pirhold type PODTLCT
700e  *    02/19/16  LMC  7.00e
      *      - Enh - Added the cleanup for pirhold type PODTLUCI
700d  *    03/16/16  LMC  7.00d
      *      - Enh - Added the cleanup for pirhold type PODTLUCIE
700g  *    05/24/16  LMC  7.00g
      *      - Enh - Added to check for Branded Items, send flag back
700h  *    10/27/16  LMC  7.00h
      *      - Enh - Close any RCVPO transactions left open when
      *        user backs up from M13600 - gui receiving.
700i  *    12/20/16  LMC  7.00i
      *      - Enh - Added logic for checking for PIRHOLD locks.
      *        This was added to eliminate the long wait time when
      *        displaying the po detail. There was a 30 file wait
      *        for the first 10 records on the PO. if a lock existed
      *        on pirhold.
720a  *    02/05/18  LMC  7.20a
      *      - Fix - only call zzrcvpoclose if the savetrn field is not
      *        zero.
720b  *    03/29/18  LMC  7.20b
      *      - Enh - Send the user when closing the transaction.
720c *    08/22/18  LMC  7.20c
     *      - Recompile only - Databases changes.
720d *    10/11/18  LMC  7.20d
     *      - PCMREXIExist needs to use poseq on the check not just
     *        the item number.
740a *    05/19/20  LMC  7.40a
     *      - Recompile only - Databases changes.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

650bA*----------------------------------------------------------------
650bA* Function prototypes.
650bA*----------------------------------------------------------------

650bA /copy qcopysrc,p.getpales
650bA /copy qcopysrc,p.CHKPCM
700gA /copy qcopysrc,p.GETBRAND
700iA /copy qcopysrc,p.bfcdteti

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSess          s             40
     D  pWhse          s              3p 0
     D  pPO            s              9
     D  pPOSeq         s              5p 0
     D  pPOItem        s             15
     D  puser          s             10
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D optiondrec      ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
     *
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

700iA*----------------------------------------------------------------
700iA*  Time variables
700iA*----------------------------------------------------------------

700iAD CurrStamploc    s               z
700iAD CurrStampsys    s               z
700iAD CurrStampuc     s               z
700iAD FromStamp       s               z
700iAD ToStamp         s               z
700iAD oldeststamp     s               z
700iAD ts              s               z

700iAD Duration        s              7  2
700iAD TtlMin          s              5  0
700iAD TtlMinSec       s              9  0
700iAD TtlSec          s              9  0
700iAD RemSec          s              3  0

700iAD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D QtyRecFlag      s              1
     D QtyDiff         s              1
650aAD itemmsg         s             40
650cAD NoPickSlot      s              1
650bAD TotalPallet     s              5s 0
650cAD Touch           s              1
650cAD sprcv           s             13
     D ocode           s              8
     D chk4err         s               n
     D zmflag          s               n
     D zmsflag         s               n

700aAD PCMExist        s              1
700aAD PCMAllow        s              1
700aAD PCMREXIExist    s              1
700aAD PCMREXIAllow    s              1
650cAD pcmcmd          s              8
650cAD pcmlvl          s              4
650cAD pcmsup          s              1
650cAD pcmtyp          s              3
650cAD pentpcm         s              1
650bAD pcmseq          s              5  0
650cAD pcmitm          s             15
700gAD pBrand          s              1
700gAD bCmd            s             10
700gAD bBrand          s             10
700gAD bBranditm       s             15
700gAD bBrandFlg       s              1
700iAD reclock         s              1
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
     D savever#        s                   like($itver#)
700hA /copy qcopysrc,C#PIRHLDPO
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
     D horec         E Ds                  Extname(pirhold)
650aAD pdmrec        E Ds                  Extname(podtlm)
     D phrec         E Ds                  Extname(pohdr)
650cAD pdjrec        E Ds                  Extname(podtl3) prefix(x_)
     D porec         E Ds                  Extname(popsr)
     D opdrec        E Ds                  Extname(optiond)
     D slrec         E Ds                  Extname(slot13)
700aAD hlrec         e ds                  extname(haccplog)
700aAD hirec         e ds                  extname(haccpq3)

700hA*----------------------------------------------------------------
700hA*  Called programs
700hA*
700hAD @crtrcv         c                   const('CRTRCVTRN')
720bA*----------------------------------------------------------------
720bA*  Translation strings
720bA*----------------------------------------------------------------

720bAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
720bAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSess        Session Id
     *      pWhse        Warehouse
     *      pPO          Purchase Order
     *      pPOSeq       Seq#
     *      pPOItem      Item
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSess
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
720bAc                   parm                    puser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

720bA    puser = %xlate(xlower: xupper: puser);
         pOutStr = ' ';
         QtyRecFlag = ' ';
         QtyDiff   = ' ';
         exec sql select * into :pdrec
              from podtl
              where pdwhse = :pWhse
                and pdpo   = :pPO
                and pdseq  = :pPOSeq
                and pditem = :pPOItem;

         If sqlstt = sqlSuccess;
           // Has quantiy been received
           select;
             when pdqrc1 > 0
               or pdqrc2 > 0
               or pdqrc3 > 0;
               QtyRecFlag = 'Y';
           endsl;
           // cross dock flag
           if pdspcl = 'XD';
             sprcv = 'Cross-Dock';
           endif;
           // Quantity Descrepency
           select;
             when pdqor1 <> pdqrc1
               or pdqor2 <> pdqrc2
               or pdqor3 <> pdqrc3;
               QtyDiff    = 'Y';
           endsl;
         endif;
         // look for messages
         exec sql select * into :pdmrec
              from podtlm
              where pdmwhs = :pWhse
                and pdmpo  = :pPO
                and pdmseq = :pPOSeq
                and pdmitm = :pPOItem;

         If sqlstt = sqlSuccess;
           if pdmpom <> ' ';
             itemmsg = pdmpom;
           else;
             itemmsg = ' ';
           endif;
         endif;

700gA    // look for Branded Items
700gA    bCmd = '*GETFLAG';
700gA    bBrand = ' ';
700gA    bBrandItm = ' ';
700gA    bBrandFlg = ' ';
700gA    GetBranded(bCmd: pwhse: ppoItem: bBrand: bBrandItm: bBrandFlg);

700gA      pBrand = bBrandFlg;

         exec sql select * into :phrec
              from pohdr
              where phwhse = :pWhse
                and phpo   = :pPO;

         If sqlstt = sqlSuccess;
           // another special receiving choice - pick slot receiving
           NoPickSlot = ' ';
           if sprcv = ' ';
             // is the vendor setup to have all items pick slot received
             exec sql select * into :porec
                  from popsr
                  where powhse = :pWhse
                    and poven   = :phven
                    and poitem  = ' ';

             If sqlstt = sqlSuccess;
               sprcv = 'Pick Slot Rcv';
             else;
               // is the item setup to always be pick slot received
               exec sql select * into :porec
                    from popsr
                    where powhse = :pWhse
                      and poitem  = :pPOItem
                      and poven   = 0;

               If sqlstt = sqlSuccess;
                 sprcv = 'Pick Slot Rcv';
               else;
                 // is the item for this vendor setup to be pick slot rcvd
                 exec sql select * into :porec
                      from popsr
                      where powhse = :pWhse
                        and poitem  = :pPOItem
                        and poven   = :phven;
                 If sqlstt = sqlSuccess;
                   sprcv = 'Pick Slot Rcv';
                 endif;
               endif;
             endif;
             // if pick slot receiving - check that item has pick slot
             if sprcv = 'Pick Slot Rcv';
               exec sql select * into :slrec
                    from slot13
                    where slwhse = :pWhse
                      and slitem  = :pPOItem
                      and slstat  = 'A '
                      and slpick  = 'Y'
                fetch first 1 rows only;

               If sqlstt = sqlSuccess;
               else;
                 NoPickSlot = 'Y';
               endif;
             endif;
             // another special receiving choice - directed putaway
             // special receiving hierachy
             // 1 Xdock
             // 2 Pick slot receiving - Required
             // 3 Directed putaway
700bA        // 4 UCi Receiving
             if sprcv = ' ';
               // get put away option
               // need to get the item info in order to check putaway option
               exsr clr$item;

               $itWhse = pwhse;
               $ititem = pPoItem;

               $dricommand = '*ITEM';
               $drisubcmd  = '%GETALL';
               $drisys2upd = 'D';
               chk4err = *on;
               zmflag  = *off;
               exsr zzzdricop;
               if error = *on;
                 opmput = 'N';
               else;
                 ocode = '*PICK   ';
                 exec sql select * into :opdrec
                      from optiond
                      where opdwhs = :pwhse
                        and opdwdp = :$itwhdp
                        and opdcod = :ocode;

                 If sqlstt = sqlSuccess;
                   optiondrec = opddta;
                 else;
                   opmput = 'N';
                 endif;
                 if opmput = 'N';
                   sprcv = 'Directed';
                 endif;
700bA            // UCI Receiving
700bA            if $ifrcvmth = '2';
700bA              sprcv = 'UCI';
700bA            endif;
               endif;
             endif;
           endif;
         else;
           phstat = ' ';
         endif;
650bA    // get pallet estimates
650bA    TotalPallet = 0;
650bA    GetPalEst(pdwhse: pdpo: pdSeq: ppoItem: TotalPallet);
650cA    // get touched flag

650cA    exec sql select * into :pdjrec
650cA         from podtl3
650cA         where pdwhse = :pWhse
650cA           and pdpo   = :pPO
650cA           and pdseq  = :pPOSeq
650cA           and poredt = 0
                fetch first 1 rows only;

650cA    If sqlstt = sqlSuccess;
650cA      touch = 'Y';
650cA    else;
650cA      touch = ' ';
650cA    endif;
         // now check to see if Header PCM needs to be entered
         pcmcmd = '*POHDR';
         pcmlvl = 'RCVH';
         pcmtyp = ' ';
         pcmsup = 'N';
         pcmseq = 0;
         pcmitm = ' ';
650bA    CHKPCM(pcmcmd: pdwhse: pcmlvl: pcmtyp:
650bA           pdpo: pcmseq: pcmsup: pcmitm: pentpcm);
         // if we return from checking header pcm with a N, check for detail
         if pentpcm = 'N';
           pcmcmd = '*PODTL';
           pcmlvl = 'RCVI';
           pcmtyp = ' ';
           pcmsup = 'N';
           pcmseq = pdseq;
           pcmitm = pditem;
650bA      CHKPCM(pcmcmd: pdwhse: pcmlvl: pcmtyp:
650bA             pdpo: pcmseq: pcmsup: pcmitm: pentpcm);
         endif;
700aA   // check to see if pcm records exist
700aA   PCMExist = ' ';
700aA   PCMAllow = ' ';
700aA   PCMREXIExist = ' ';
700aA   PCMREXIAllow = ' ';
700aA   // this controls whether show the pcm log
700aA   exec sql select * into :hlrec
700aA            from haccplog
700aA            where hlwhse = :pwhse
700aA              and hlpo   = :ppo
700aA              and hlitem = :ppoitem
700aA              and hlexpts = '0001-01-01-00.00.00.000000'
700aA              and hlobsolete <> 'Y'
700aA            fetch first row only;
700aA   if sqlstt = sqlSuccess;
700aA     PCMExist = 'Y';
700aA   endif;
700aA   // this controls whether we allow the pcm change
700aA   exec sql select * into :hlrec
700aA            from haccplog
700aA            where hlwhse = :pwhse
700aA              and hlpo   = :ppo
700aA              and hlexpts = '0001-01-01-00.00.00.000000'
700aA              and hlobsolete <> 'Y'
700aA                  and hllevl     <> 'REXI'
700aA                fetch first row only;
700aA      if sqlstt = sqlSuccess;
700aA          PCMAllow = 'Y';
700aA      endif;
700aA   // this controls whether we allow the exception pcm change
700aA   exec sql select * into :hlrec
700aA            from haccplog
700aA            where hlwhse = :pwhse
700aA              and hlpo   = :ppo
700aA              and hlitem = :pPOItem
720dA              and hlposeq = :pposeq
700aA              and hlexpts = '0001-01-01-00.00.00.000000'
700aA              and hlobsolete <> 'Y'
700aA                  and hllevl = 'REXI'
700aA                fetch first row only;
700aA      if sqlstt = sqlSuccess;
700aA          PCMREXIExist = 'Y';
700aA      endif;
700aA   // this controls whether we allow the exception pcm entry
700aA   exec sql select * into :hirec
700aA            from haccpq3
700aA            where hilevl = 'REXI'
700aA                fetch first row only;
700aA      if sqlstt = sqlSuccess;
700aA          PCMREXIAllow = 'Y';
700aA      endif;
         // Put together JSON string
         pOutStr = '{'
                +  '"QDiff":"'  + %trimr(QtyDiff) + '",'
650aA           +  '"IMsg":"'  + %trimr(ItemMsg) + '",'
650bA           +  '"TPal":"'  + %char(TotalPallet) + '",'
650cA           +  '"Touch":"'  + %trimr(Touch) + '",'
                +  '"POSTAT":"'  + %trimr(phstat) + '",'
                +  '"sprcv":"'  + %trimr(sprcv) + '",'
                +  '"NOpick":"'  + %trimr(NoPickSlot) + '",'
                +  '"EntPCM":"'  + %trimr(pentpcm) + '",'
700gA           +  '"Brand":"'  + %trimr(pBrand) + '",'
700aA           +  '"PCMExist":"'  + %trimr(pcmexist) + '",'
700aA           +  '"PCMAllow":"'  + %trimr(pcmallow) + '",'
700aA           +  '"PCMREXIExist":"'  + %trimr(pcmrexiexist) + '",'
700aA           +  '"PCMREXIAllow":"'  + %trimr(pcmrexiallow) + '",'
700iA           +  '"RCDLCK":"'  + %trimr(reclock) + '",'
                +  '"recv":"'  + %trimr(QtyRecFlag) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

720bA       puser = %xlate(xlower: xupper: puser);
700hA       // before deleting any leftover PODTL records we need to
700hA       // make sure we close the RCVPO transaction that was never
700hA       // completed by the user.
700hA
700hA       exec sql select * into :horec
700hA         from pirhold
700hA        where hosess = :psess
700hA          and hotype = 'PODTL';
700hA       If sqlstt = sqlSuccess;
700hA         pirhldpods = hodata;
720aA         if savetrn <> 0;
700hA           exsr zzrcvpoclose;
720aA         endif;
700hA       endif;
700hA
700iA       exec sql select * into :horec
700iA         from pirhold
700iA        where hosess = :psess
700iA          and hotype = 'LOCKED';
700iA       If sqlstt <> sqlSuccess;
              // clear the pirhold file for this session
              exec sql delete from pirhold
                   where hosess = :psess
                     and hotype = 'PODTL'
                     or  hosess = :psess
                     and hotype = 'PODTLCW'
700dA                or  hosess = :psess
700dA                and hotype = 'PODTLCT'
700eA                or  hosess = :psess
700eA                and hotype = 'PODTLUCI'
700dA                or  hosess = :psess
700dA                and hotype = 'PODTLUCIE'
700iA                or  hosess = :psess
700iA                and hotype = 'LOCKED'
                     or  hosess = :psess
                     and hotype = 'POLCNS';

700iM         If sqlstt <> sqlSuccess and sqlstt <> sqlNoData;
700iA           reclock = 'Y';
700iA           hosess = psess;
700iA           hotype = 'LOCKED';
700iA           hokey  = psess;
700iA           hodata = ' ';
700iA           //HOADDTS = *loval;
700iA           //HOADDUC = *loval;
700iA           exsr getcurrstamp;
700iA           hoaddts = currstampsys;
700iA           hoadduc = currstampuc;
700iA           exec sql insert into pirhold values(:horec);
700iA         else;
700iA           reclock = 'N';
700iA         endif;
700iA       else;
700iA         reclock = 'Y';
700iA       endif;
           endsr;

      /end-free
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr


     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
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

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
700hA*----------------------------------------------------------------
700hA*
700hA*  ZZRCVPOCLOSE  Close RCVPO transaction.
700hA*
700hAC     zzrcvpoclose  begsr
700hA
700hA
700hAC                   call      @crtrcv
700hAC                   parm      '*PO'         $lcmdr           10
700hAC                   parm      '*CLOSE'      $lsubcmd         10
700hAC                   parm      pwhse         @lwhse            3 0
700hAC                   parm      0             $lpcs             5 0
700hAC                   parm      0             $lpallets         5 0
700hAC                   parm      savetrn       $lsavetrn         7 0
700hAC                   parm                    $ppo              9
700hAC                   parm      $itstyp       $litstyp          1
700hAC                   parm      $itwhdp       $litwhdp          5
700hAC                   parm                    $lrtnr           10
720bAC                   parm      puser         $puser           10
700hAC                   endsr
700iA*----------------------------------------------------------------
700iA*  getcurrstamp  Get current timestamps
700iA*----------------------------------------------------------------
700iA
700iA /free
700iA  begsr getCurrStamp;

700iA    getmicrotime(currstampuc:currstampsys);
700iA    currstamploc = currstampsys + %hours(bfcoffset);

700iA  endsr;
700iA /end-free
