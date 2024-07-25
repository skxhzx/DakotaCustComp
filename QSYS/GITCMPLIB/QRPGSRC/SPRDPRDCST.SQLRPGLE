      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
     *----------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
     *   BFC Software, Inc.
     *----------------------------------------------------------

     *----------------------------------------------------------
     *
     *  SPRDPRDCST   Call DRIPROD routines to spread Cost
     *  25 Aug 2017
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    08/25/15  KDE  7.10
     *      - Created.
     *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     FpCostStsH uf a e           k disk
     FpCostStsD o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#stdvar

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
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

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PROD

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     d  opnTrnE        s               n
     d  prdExist       s               n
     D  pWhse          s              3p 0
     D  pprdDate       s              8
     D  pLine          s              3
     D  pType          s             13
     D  pClose         s              1
     D  pOutStr        s            512

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     D wherelabel      s            300
     DreturnStatus     S             10I 0
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D SkipFirstRead   s               n
     D dbgflgExists    s               n
     D debug           s               n
     d pErr            s            110
     d pReturn         s              5
     d wkError         s               n
     d wkRerr2         s             50

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     d  pdateNum       s              8  0
     d  pdate6         s              6  0
     d  processDate    s              8  0
     d  opnTrans       s              7  0
     d  opnWo          s             13
700aAd  pWip           s              1
     d  reccnt         s              6  0
700aAd  wkWipDisp      s             12

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     Dslrec          E Ds                  Extname(slot)
     DppcRec         E Ds                  Extname(pCostStsH) prefix(p_)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pprdDate     Production Date
     *      pLine        Production Mfg Line
     *      pClose       "Y" to Update and "N" for just checking
     *      pType        Begin, Ending, or Adjust of Inventory
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pLine
610aAc                   parm                    pprdDate
     c                   parm                    pClose

      /free

700cA     // Set SQL default parms
700cA     exec sql
700cA       set Option Commit=*none, Dlyprp=*Yes,
700cA                  Closqlcsr = *ENDMOD;

          if pLine=*blanks and pprdDate=*blanks;
             // blank Mfg Line and blank Date means it
             // should loop through all open Dates and
             // try to finalize assuming open transcations
             // have been closed

             sqlStmt = 'select * from pCostStsH ' +
                      ' where pcwhse = ' + %char(pWhse) +
                      ' and pcOpnTrns = ' + sq + 'Y' + sq;

             exec sql PREPARE opnS FROM :SqlStmt;
             exec sql DECLARE OpnSts SCROLL CURSOR FOR opnS;
             exec sql OPEN OpnSts;

             exec sql fetch first from OpnSts into :ppcrec;
             dow sqlstt = sqlSuccess;
                pLine = 'ALL';
                pprdDate = %char(p_pcprdDte);
                pClose = ' ';
                exsr DateCost;
                exec sql fetch next from OpnSts into :ppcrec;
             enddo;
          else;
             // Run for the one day passed
             exsr DateCost;
          endif;

          *inlr = *on;

       // -----------------------------------------------//
       // --  DateCost - Call Cost Spread routines for   //
       //     parms passed                               //
       // -----------------------------------------------//

          begsr DateCost;

710bA        pDate6 = %dec(%subst(pprdDate:3:6):8:0);
          // Call DRIPROD routines to spread Cost
710bA        $ppwhseu = *on;
710bA        $ppWhse = pWhse;
710bA        $pplnenou = *on;
710bA        $pplneno = 0;
             $ppPrimary = pLine;
710bA        $ppuser = pUser;
710bA        $ppuseru = *on;
710bA        $ppExpdtu = *on;
710bA        $ppExpdt = %dec(pprdDate:8:0);
710bA
710bA        $dricommand = '*PROD';
710bA        $drisubcmd = '%SPRDCOST';
710bA        $drisys2upd = 'D';
710bA        exsr zzDriCop;

          // Update Cost Status Header and Detail File for Specific Date
          // look for any open Production Transactions
          opnTrnE=*off;
          prdExist=*off;
          sqlStmt = 'select distinct urwo#' +
                    ' from pWrkOrdru ' +
              'where urwhse = ' + %char(pWhse) + ' and ' +
                 'urprddte=' + sq + pprdDate + sq + ')' +
                 'urstat<>' + sq + 'C' + sq +
               ' and urstat<>' + sq + 'D' + sq;

          // if delete log transactions already exist for this
          // closing date ran today then delete
          processDate = %uns(%char(%Date():*Iso0));
          exec sql delete from pCostStsD
              where pdwhse=:pWhse and pdprddte=:pprddate
                     and pddteprs=:processDate;

          exec sql PREPARE owo FROM :SqlStmt;
          exec sql DECLARE OpnWo SCROLL CURSOR FOR owo;
          exec sql OPEN OpnWo;

          exec sql fetch first from OpnWo into :opnWo;
          dow sqlstt = sqlSuccess;
             pdwhse=pWhse;
             pddteprs=processDate;
             pdprddte=%dec(pprdDate:8:0);
             pdwo=opnWo;
             pdtrans=*zeros;
             opnTrnE=*on;
             prdExist=*on;
             write pdrec;
             exec sql fetch next from OpnWo into :opnWo;
          enddo;
          exec sql close OpnWo;

          // look for any open EPM transactions
          sqlStmt = 'select distinct ptdtran' +
                    ' from pirtrand as a' +
              'where a.ptdwhse = ' + %char(pwhse)+ ' and ' +
                 'a.ptdstat < 3 and a.ptdshftDay = ' + %char(pDate6) +
                 ' and a.ptdstat<>' + sq + 'X' + sq + ' and ' +
                 '(select count(*) from pirtranp as b where ' +
                 'b.ppwhse=a.ptdwhse and b.pptrn#=a.ptdtran)<>0';

          // if delete log transactions already exist for this
          // closing date ran today then delete

          exec sql PREPARE otrn FROM :SqlStmt;
          exec sql DECLARE OpnTrn SCROLL CURSOR FOR otrn;
          exec sql OPEN OpnTrn;

          exec sql fetch first from OpnTrn into :opnTrans;
          dow sqlstt = sqlSuccess;
             pdwhse=pWhse;
             pddteprs=processDate;
             pdprddte=%dec(pprdDate:8:0);
             pdwo=*blanks;
             pdtrans=opnTrans;
             opnTrnE=*on;
             prdExist=*on;
             write pdrec;
             exec sql fetch next from OpnTrn into :opnTrans;
          enddo;
          exec sql close OpnTrn;

          // if not prdExist this means there were no Prod Transactions
          // or EPM transactions open but some could have existed and
          // therefore should have Cost Status Header added
          reccnt=0;
          exec sql select count(*) into :reccnt
                    from pirtrand as a
               where a.ptdwhse = :pWhse and
                 a.ptdshftDay = :pDate6
                  and a.ptdstat<>'X'  and
                 (select count(*) from pirtranp as b where
                 b.ppwhse=a.ptdwhse and b.pptrn#=a.ptdtran)<>0;
          // update production Costing Header Status file for date
          if prdExist or reccnt<>*zeros;
             chain (pWhse:%dec(pprdDate:8:0)) pCostStsH;
             if not %found(pCostStsH);
                pcWhse=pWhse;
                pcprddte=%dec(pprdDate:8:0);
                pcnumcls=1;
                if opnTrnE;
                   pcOpnTrns='Y';
                else;
                   pcOpnTrns='N';
                endif;
                write pcrec;
             else;
                pcNumCls = pcNumCls + 1;
                if opnTrnE;
                   pcOpnTrns='Y';
                else;
                   pcOpnTrns='N';
                endif;
                update pcrec;
             endif;
          endif;
         endsr;

      /end-free
     *----------------------------------------------------------------
     *  zzdricop  Call DRICOP
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
