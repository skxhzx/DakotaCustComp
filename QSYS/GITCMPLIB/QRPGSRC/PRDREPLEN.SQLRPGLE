      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------
      *
      *  PRDREPLEN   MFG Production Replenishment
      *  04 June 2014
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    06/04/14  KDE  6.50
     *      - Created.
730 A*    08/26/19  KDE  7.30
     *      - Change Production Replen type to 'O' from 'D'
     *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fplined    if   e           k disk
     Fpiritem   if   e           k disk
416bAF                                     rename(itrec:itrec1)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD
510aA /COPY *libl/qcopysrc,C#PRTYRPL
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
      *  Prototypes
      *----------------------------------------------------------
650aA /copy qcopysrc,p.wrtsessl

     D usleep          pr            10u 0 extproc('usleep')
     D  Interval                     10u 0 value

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

650aAD  pMsg           s             99    varying
650aAD  pSessId        s             40    varying
650aAD  pUser          s             10    varying
650aAD  pPgm           s             20    varying
     D  pWhse          s              3  0
     D  pMfgNo         s              3  0
     D  pItem          s             15    varying
     D  pQtyN          s              5  0
     D  pQtyB          s              5  0
     D  pTypePrc       s              1    varying

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     *  Data Structure to hold open Replenishments for MFG Line
     *     passed in
     *
     D                 ds
     D aryReplen                     74    dim(20)
     D  rtnItem                      15    overlay(aryReplen:*next)
     D  rtnDesc                      30    overlay(aryReplen:*next)
     D  rtnQty                        5  0 overlay(aryReplen:*next)
     D  rtnfLoc                      12    overlay(aryReplen:*next)
     D  rtntLoc                      12    overlay(aryReplen:*next)

     D itemdesc        s             40
     d rightStr        s           1024
     D wherelabel      s            300
     DreturnStatus     S             10I 0
     d dlytme          s              5  0
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D whse            s              3  0
     D SkipFirstRead   s               n
     D holdStamploc    s               z
     D rc              s              3  0 inz(0)
     D lstary          s              3  0 inz(0)
     D logText         s            100
     D Numbers         S             11    Inz(' 0123456789')
     D dbgflgExists    s               n
     D debug           s               n
     d prdSlot         s             12
     d wkError         s               n
     d wkRerr2         s             50
     d wkCrtProdErr    s             15
     d wrkIso          s               d   Inz(*sys)
     d TodayJul        s              5
     d wrkMfgno        s              2  0
     d bugstate        s              5  0
     d jultoDay        s             12
     D saveVer#        s                   like($prver#)

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
     D  dqkeylen       s              3  0 inz(36)
     D  dqlen          s              5  0
     D  dqorder        s              2
     D  dqwait         s              5  0
     d  dqname         s             10
     d  dqlib          s             10

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D prrec         E Ds                  Extname(Prplfil)
     D itrec         E Ds                  Extname(Piritem)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pMsg         Error Message
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pMfgNo       Manufacturing Line
     *      pItem        Item
     *      pQtyN        Normal Quantity
     *      pQtyB        Breakdown Quantity
     *      pTypePrc     I=Item Lookup, P-Replenishment
     *
     *    Returned Parameters
610aA*      pOpnRepl     Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pMsg
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pWhse
610aAc                   parm                    pMfgNo
     c                   parm                    pItem
     c                   parm                    pQtyN
     c                   parm                    pQtyB
     c                   parm                    pTypePrc

      /free

          exsr init;
          select;
             when pTypePrc = 'I';
                exsr rtvItem;
             when pTypePrc = 'P';
                exsr crtReplen;
             other;
          endsl;

        *inlr = *on;


      /end-free
650aA*----------------------------------------------------------------
650aA*  clr$prtyrpl  Clear $prtyrpl data structure fields
650aA*----------------------------------------------------------------
650aA
650aAC     clr$prtyrpl   begsr
650aAC                   eval      savever# = $prver#
650aAC                   clear                   $prtyrpl
650aAC                   eval      $prver# = savever#
650aAC                   endsr
      /free

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             pMsg = ' ';
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
         // cleanup complete production priority replenishments
           exec sql delete from prplfil
                    where prflag = 'D'
730 D                 //and prrplt = 'D';
730 M                 and prrplt = 'O';

          endsr;

       //---------------------------------------------------------
       // crtReplen  -   Create or update requested replenishment
       //                for the given production line
       //---------------------------------------------------------

          begsr crtReplen;

                savever# = $ppver#;
                clear $pprod;
                clear $pprod;
                $ppver# = savever#;

                if pMfgNo <> 0;
                   chain (pwhse:pMfgno) plined;
                   if %found(plined);
                      prdSlot = ' ';
                      $ppdesc = indesc;
                      $pprcvau = *on;
                      $pprcva = inrcvaisl;
                   endif;
                endif;

                if pItem <> '';
                   chain (pwhse:pitem) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

                $ppwhseu = *on;
                $ppwhse  = pwhse;
                $pplnenou = *on;
                $pplneno = pmfgno;
                $ppuser = pUser;
                $ppuseru = *on;

                $dricommand = '*PROD';
                $drisubcmd = '%GETMIN';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror or $driReturn <> '*OK';
                   pMsg = $driMessage;
                else;
                   prdSlot = $pprcvar;
                // call replenishment process
      /end-free
650aA*
650aA* Create Priority Replenishment to move requested quantity
650aA*  to desired MFG Line area
650aA
650aAC                   exsr      clr$prtyrpl
510aA*
510aAC                   eval      $tmsg = *blanks
510aAC                   move      pwhse         $twhse            3
650aAc                   eval      $twhdp = $ppwhdp
650aAc                   eval      $tpitm = $ppitem
650aAC                   call      'LT110G'
650aAC                   parm                    $twhse
650aAC                   parm                    $twhdp            5
650aAC                   parm      '*SINGLE '    $tplb             8
650aAC                   parm                    $tpitm           15
650aAc                   parm                    prdslot
650aAc                   parm                    pqtyn
     c                   parm                    pqtyb
650aAC                   parm                    $trtn             8
650aAC                   parm                    $tmsg            99
      *
     c                   if        $trtn <> ' ' and $trtn <> '*OK'
     c                   eval      pMsg = $tmsg
     c                   endif

     c                   endif

     c                   endsr
      /free

       //---------------------------------------------------------
       // rtvItem - Retrieve the passed in Item record
       //           Place in ITREC data structure for use
       //---------------------------------------------------------

         begsr rtvItem;

        // get item description
          if pItem <> ' ';
             exec sql
              select *
               into :itrec
                from piritem
                 where ititem = :pItem;

             if Sqlstt <> sqlSuccess;
                itemdesc = '** Invalid Item **';
             else;
                itemdesc = itdesc;
             EndIf;

          else;
             itemdesc = ' ';
          endif;
         endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  gloSession  - Write Glo Session record
650aA*  Write GloSession record when activity takes place to assist
650aA*  with debugging and tracking user who made change
650aA*----------------------------------------------------------------

650aA /free
650aA    begsr gloSession;
650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'Line:' + %char(pMfgNo) + ','
650aA            + 'Item:' + pItem + ','
650aA            + 'QtyN:' + %char(pQtyn) + ','
650aA            + 'QtyB:' + %char(pQtyb) + ','
650aA            + 'Type:' + pTypePrc;
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
650aA
650aA    endsr;
650aA /end-free

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
     c                   eval      $dridata2 = $pprod2

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
     c                   eval      $pprod2 = $dridata2
     c                   endsl

     c                   endsr

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pWhse = ' + %char(pWhse)
                  + '&pMfgNo=' + %trimr(%char(pMfgNo))
                  + '&pItem=' + %trimr(pItem)
                  + '&pQtyn=' + %trimr(%char(pQtyn))
                  + '&pQtyb=' + %trimr(%char(pQtyb))
                  + '&pTypePrc=' + %trimr(pTypePrc);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
