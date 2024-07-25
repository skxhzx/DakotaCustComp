      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  CSLTQTY    Calculate new Production Slot inventory based
      *             on current inventory and incoming adjustments
      *  08 July 2014
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    06/17/14  KDE  6.50
     *      - Created.
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Foptions   if   e           k disk
     Fslot2     if   e           k disk
     Fplined    if   e           k disk
     Fpremwgt   uf a e           k disk
     Fpiritem   if   e           k disk
     fitemprd1  if   e           k disk    prefix(r_)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
      *  12/20/02  DAS  4.16  Created
      *  07/12/08  DAS  6.00a
      *    - Added #curruser, #prog, #jobn
      *  03/02/11  MLB  6.40
      *    - Added #parms
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pItem          s             15
     D  pSlot          s             12
     D  pLine          s              3p 0
     D  pendnrmq       s              5p 0
     D  pendbd1q       s              5p 0
     D  pendbd2q       s              5p 0
     D  pendPrdq       s              9p 4
     D  peodwgt        s              9p 3
     D  pusenrmq       s              5p 0
     D  pusebd1q       s              5p 0
     D  pusebd2q       s              5p 0
     D  pusePrdq       s              9p 4
     D  pCmd           s              1
     D  ploc           s             10

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     D whse            s              3  0
     D logText         s            100
     D Numbers         S             11    Inz(' 0123456789')
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D dbgflgExists    s               n
     D debug           s               n
     D err             s               n
     d TodayJul        s              5
     d wrkMfgno        s              2  0
     d bugstate        s              5  0
     d jultoDay        s             12
     d adjqtyn         s              5  0
     d adjqty1         s              5  0
     d adjqty2         s              5  0
     d totaloh         s              5  0
     d totaladj        s              5  0
     d pNewQty         s             12
     d prdSlot         s             12
     D pwstnrmq        s              5p 0
     D pwstbd1q        s              5p 0
     D pwstbd2q        s              5p 0
     D pwstPrdq        s              9p 4
     D saveVer#        s                   like($ppver#)
     d wkWstNrm        s              5  0
     d wkWstBD1        s              5  0
     d wkWstBD2        s              5  0
     d wkUseNrm        s              5  0
     d wkUseBD1        s              5  0
     d wkUseBD2        s              5  0
     d wkumq2          s              5  0
     d wkumq3          s              5  0
     d wkError         s               n
     d wkRerr2         s             50
     d wkCrtProdErr    s             15

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *  Division Prod Adjustment

     d divAdjust       ds
     d  PrdAdj                        9  4
     d   intAdjust                    5  0 overlay(PrdAdj)
     d   decAdjust                    4  0 overlay(PrdAdj:*next)

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

     *----------------------------------------------------------------
     *  *PROD  -  Production Option Settings
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLBRP  -  Reprint production labels
     *    OPLBDL  -  Delete Production labels
     *    OPVARM  -  Use Variable Measure for generated GTIN
     *    OPIMPGTIN  Import GTIN's from Customer
     *    OPGENGTIN  Generate GTIN's from customer item number
     *    OPPRDDTE-  Include Production date in GS1
     *    OPPCKDTE-  Include Package date in GS1
     *    OPEXPDTE-  Include Expiration Date in GS1
     *    OPNETLBS-  Include Net pounds in GS1
     *    OPLBSDEC-  Number of decimals for Net pounds
     *    OPNETKG -  Include Net kilograms in GS1
     *    OPKGDEC -  Number of decimals for Net kilograms
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  oplbrp                 1      1
     D  oplbdl                 2      2
     D  opvarm                 3      3
     D  opimpgtin              4      4
     D  opgengtin              5      5
     D  opprddte               6      6
     D  oppckdte               7      7
     D  opexpdte               8      8
     D  opnetlbs               9      9
     D  oplbsdec              10     10  0
     D  opnetkg               11     11
     D  opkgdec               12     12  0
     D  optend               117    117

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pErrMsg      Returned Error Message
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse hard wired to user
     *      pItem        Raw MAterial that MFG Lie needs
     *      pSlot        Raw MAterial slot
     *      pLine        MFG Production Line Number
     *      pEndNrmq     Ending normal Quantity
     *      pEndBD1q     Ending Breakdown 1 Quantity
     *      pEndBD2q     Ending Breakdown 2 Quantity
     *      pEndPrdq     Ending Production Quantity
     *      pUseNrmq     Used Normal Quantity
     *      pUseBD1q     Used Breakdown Quantity 1
     *      pUseBD2q     Used Breakdown Quantity 2
     *      pUsePrdq     Production Quantity
     *      pCmd         Function to perform
     *      pLoc         Tells whether to just do edits or not
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg          99
     c                   parm                    pSessId          40
     c                   parm                    pUser            10
     c                   parm                    pPgm             20
     c                   parm                    pWhse
     c                   parm                    pItem
     c                   parm                    pSlot
     c                   parm                    pLine
     c                   parm                    pEndNrmq
     c                   parm                    pEndBD1q
     c                   parm                    pEndBD2q
     c                   parm                    pEndPrdq
     c                   parm                    pEodWgt
     c                   parm                    pUseNrmq
     c                   parm                    pUseBD1q
     c                   parm                    pUseBD2q
     c                   parm                    pUsePrdq
     c                   parm                    pCmd
     c                   parm                    pLoc

      /free

          pErrMsg = *blanks;
          exsr init;
             if debug;
               exsr wrtDebugParms;
             endif;
             select;
                when Pcmd = Pcmd;
                   exsr calcWaste;
                   if pErrMsg = ' ';
                      if pLoc='*AFTERACT';
                         exsr updProdSlot;
                      endif;
                   endif;
                other;
                   pErrMsg = 'Invalid Function Received';
             endsl;

        *inlr = *on;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

                         #curruser = pUser;

      /end-free
     *
     *   Get default values for the user.
     *

     C                   call      'GETUSER'
     C                   parm                    #curruser
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
      /free
          endsr;

       //---------------------------------------------------------
       // calcWaste - Calculate Waste from Beginning, Ending and
       //             Used inventories passed in from MRC Screen
       //             M145xx
       //---------------------------------------------------------

       begsr calcWaste;

          wkWstNrm=0;
          wkWstBD1=0;
          wkWstBD2=0;
          wkUseNrm=0;
          wkUseBD1=0;
          wkUseBD2=0;
          err = *off;
          chain (pwhse:pitem) piritem;
          if not %found(piritem);
             err = *on;
             pErrMsg = 'Invalid Item Number';
          else;

          setll (pWhse:itwhdp:pSlot) slot2;
          reade (pwhse:itwhdp:pSlot) slot2;
          if not %equal(slot2);
             err = *on;
             pErrMsg = 'Invalid Slot';
          else;
             // convert quantities to lowest level for math
             if itumq2 = 0;
                wkumq2 = 1;
             else;
                wkumq2 = itumq2;
             endif;
             if itumq3 = 0;
                wkumq3 = 1;
             else;
                wkumq3 = itumq3;
             endif;

             // calculate Waste values from begin, ending and usage
             totaloh  = (slstk1*wkumq2*wkumq3) + (slstk2*wkumq3)
                           + slstk3;
             totaladj = ((pendnrmq+pusenrmq)*wkumq2*wkumq3)
                         + ((pendbd1q+pusebd1q)*wkumq3)
                           + pendbd2q + pusebd2q;
             totaladj = totaloh - totaladj;
             exsr zzupqty;
             pWstNrmq = adjqtyn;
             pWstbd1q = adjqty1;
             pWstBd2q = adjqty2;

             // get total adjustment figure after determining waste above
             totaladj = ((pwstnrmq+pusenrmq)*wkumq2*wkumq3)
                         + ((pwstbd1q+pusebd1q)*wkumq3)
                           + pwstbd2q + pusebd2q;
             // roll quantity back from lowest level to highest level
             exsr zzupqty;

           endif;    // invalid slot
           endif;   // invalid item

       endsr;
      /end-free

500cA*----------------------------------------------------------------
500cA*  updProdSlot -   Get the correct raw material producion slot
500cA*                  based on item and line being passed and
500cA*                  and adjust quantity per the day end request
500cA*----------------------------------------------------------------
500cA
500cAC     updProdSlot   begsr
      /free

                // insert or update end of day weight
                chain (pwhse:pline:pitem:pslot) premwgt;
                if %found(premwgt);
                   rwremwgt = pEodwgt;
                   rwstk1 = pEndnrmq;
                   rwstk2 = pEndbd1q;
                   rwstk3 = pEndbd2q;
                   rwprdq = pEndprdq;
                   update rwrec;
                else;
                   rwwhse = pwhse;
                   rwline = pline;
                   rwitem = pitem;
                   rwdisp = pslot;
                   rwremwgt = pEodwgt;
                   rwstk1 = pEndnrmq;
                   rwstk2 = pEndbd1q;
                   rwstk3 = pEndbd2q;
                   rwprdq = pEndprdq;
                   write rwrec;
                endif;

                wkerror = *off;
                savever# = $ppver#;
                $ppver# = savever#;

                if pline <> 0;
                   chain (pwhse:pline) plined;
                   if %found(plined);
                      $ppdesc = indesc;
                      prdSlot = ' ';
                      $pprcvau = *on;      // receive aisle per line
                      $pprcva = inrcvaisl;
                   endif;
                endif;

                if pItem <> '';
                   chain (pwhse:pItem) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

               // adjust usage quantities first
                $ppActionu = *on;
                $ppAction= 'PIU';
                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $pplnenou = *on;
                $pplneno = pLine;
                $ppdestu = *on;
                $ppdest = 'M';
                $ppqty1u = *on;
                $ppqty1 = (pusenrmq+wkusenrm) * -1;
                $ppqty2u = *on;
                $ppqty2 = (puseBD1q+wkuseBD1) * -1;
                $ppqty3u = *on;
                $ppqty3 = (puseBD2q+wkuseBD2) * -1;
                $ppwgtu = *on;
                $ppwgt = 0;
                $ppuser = pUser;
                $ppuseru = *on;
                $ppadjcdeu = *on;
                $ppadjcde = 'P1';

              // since Waste and Normal usage can be sent be sure
              // normal was sent, otherwise error will be returned.
              // If only Waste was sent it will execute in the else
              // of the error below.

                if $ppqty1 <>0 or $ppqty2 <> 0 or $ppqty3<>0;
                   $dricommand = '*PROD';
                   $drisubcmd = '%ADJQTY';
                   $drisys2upd = 'D';
                   exsr zzDriCop;
                endif;

                if wkerror;
                   pErrMsg = 'No update, error applying adjustment';
                   return;
                else;
                  // adjust waste if entered
                   if pwstnrmq<>0 or pwstbd1q<>0 or pwstbd2q<>0
                      or wkwstnrm<>0 or wkwstbd1<>0 or wkwstbd2<>0;
                      $ppqty1u = *on;
                      $ppqty1 = (pwstnrmq+wkwstnrm) * -1;
                      $ppqty2u = *on;
                      $ppqty2 = (pwstBD1q+wkwstBD1) * -1;
                      $ppqty3u = *on;
                      $ppqty3 = (pwstBD2q+wkwstBD2) * -1;
                      $ppwgtu = *on;
                      $ppwgt = 0;
                      $ppuser = pUser;
                      $ppuseru = *on;
                      $ppActionu = *on;
                      $ppAction= 'PIW';
                      $ppadjcdeu = *on;
                      $ppadjcde = 'P2';

                      $dricommand = '*PROD';
                      $drisubcmd = '%ADJQTY';
                      $drisys2upd = 'D';
                      exsr zzDriCop;
                      if wkerror;
                         pErrMsg = 'No update, error applying adjustment';
                         return;
                      else;
                         prdSlot = $pprcvar;
                      endif;
                   else;
                      prdSlot = $pprcvar;
                   endif;
                endif;
      /end-free

     c                   endsr

     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   endsl

     c                   endsr

     *----------------------------------------------------------------
     *  ZZUPQTY       Up quantity
     *----------------------------------------------------------------

     C     zzupqty       begsr

      /free
                         adjqtyn = 0;
                         adjqty1 = 0;
                         adjqty2 = 0;
                         select;
                            when itumq3 > 0;
                               adjqty2 = TotalAdj;
                            when itumq2 > 0;
                               adjqty1 = TotalAdj;
                            other;
                               adjqtyn = TotalAdj;
                         endsl;
      /end-free

     C                   dow       itumq3 > 0 and +
     C                               adjqty2 >= itumq3
     C                   eval      adjqty2 -= itumq3
     C                   eval      adjqty1 += 1
     C                   enddo

     C                   dow       itumq2 > 0 and +
     C                               adjqty1 >= itumq2
     C                   eval      adjqty1 -= itumq2
     c                   eval      adjqtyn += 1
     C                   enddo

     C                   endsr

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pItem = ' + pitem
                  + '&pUser=' + %trimr(pUser)
                  + '&pItem=' + %trimr(pItem)
                  + '&pSlot=' + %trimr(pSlot)
                  + '&plocCycle=' + %trimr(pLoc)
                  + '&pwstnrmq=' + %trimr(%char(pwstnrmq))
                  + '&pwstbd1q=' + %trimr(%char(pwstbd1q))
                  + '&pwstbd2q=' + %trimr(%char(pwstbd2q))
                  + '&pwstprdq=' + %trimr(%char(pwstprdq))
                  + '&pusenrmq=' + %trimr(%char(pusenrmq))
                  + '&pusebd1q=' + %trimr(%char(pusebd1q))
                  + '&pusebd2q=' + %trimr(%char(pusebd2q))
                  + '&puseprdq=' + %trimr(%char(puseprdq))
                  + '&ppQty1=' + %trimr(%char($ppQty1))
                  + '&ppQty2=' + %trimr(%char($ppQty2))
                  + '&ppQty3=' + %trimr(%char($ppQty3));

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

      *----------------------------------------------------------
      *  wrtDebugError  Write out debug error
      *----------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = ' ';

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

