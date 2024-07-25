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
     *  FR13300U     PO Receiving - cleanup on cancel from license entry
     *  30 January 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    01/30/15  LMC  7.00
     *      - Created.
700aA*    07/11/16  LMC  7.00a
     *      - Added cleanup of OSS information
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Purchase Order Detail Seq#
     *      puser       user
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fpirhold   uf   e           k disk
700aAFworkoss2  uf   e           k disk
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

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
      /COPY QCOPYSRC,ID#PACKERS
      /copy qcopysrc,id#citylin

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pSession        s             40
     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D puser           s             10
     D pprog           s             20
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D hldtim          s             19
     D today           s              8  0
     D cancelLcns      s             15
     D curtime         s              6  0
     D $ok             s               n
     D count           s              5p 0
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

700aAD ck4err          s              1
700aAD  errmsg         s             50
700aAD forevr          s              1
700aAD zmflag          s               n
700aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
700aA*----------------------------------------------------------------
700aA*  DRI parameters
700aA*----------------------------------------------------------------
700aA /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  pirhold structures
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLLCN

700aA*----------------------------------------------------------------
700aA*  Data Formats
700aA*----------------------------------------------------------------
700aA /COPY *libl/qcopysrc,C#SLOT
700aAD savever#        s                   like($slver#)

700aA*----------------------------------------------------------------
700aA*  Translation strings
700aA*----------------------------------------------------------------
700aA
700aAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
700aAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D haccplog      e ds
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSession
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    puser
     c                   parm                    pprog
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        // process all license records in pirhold
        hotype = 'POLCNS';
        setll (pSession: hotype) pirhold;
        dow not %eof(pirhold);
          reade (psession: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
          pirhllcnds = hodata;
          cancelLcns = %trimr(hokey);
          // handle cleanup of RCVL - License entry PCM records
          exsr zzgettime;
          exec sql update haccplog
                   set hlchgts = :CurrStampsys,
                       hlchguc = :Currstampuc,
                       hlchgcpgm = :pprog,
                       hlchgjpgm = :#prog,
                       hlchgeusr = :#user,
                       hlobsolete = 'Y'
                   where hlwhse = :pwhse
                     and hlpo = :ppo
                     and hllcns = :cancelLcns
                     and hllevl = 'RCVL'
                     and hlexpts = '0001-01-01-00.00.00.000000'
                     and hlobsolete <> 'Y';
          delete horec;
        enddo;

700aA   // cleanup lefotver OSS slots/license
700aA   exsr ZZWODLTJOB;
      /end-free


     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
        begsr *INZSR;

700aA   puser = %xlate(xlower: xupper: puser);
        getclient(client: clientLoc);

        getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        $cvcmd = '*CURCMD';
        cvtdte($cvtdt);
        today = $cvd8o;
        endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
       endsr;
700aA /end-free
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZWODLTJOB     Delete WORKOSS records for current job
700aA*
700aAC     zzWoDltJob    begsr
700aA
700aA /free
700aA   setll (pSession: pUser) workoss2;
700aA   dow forevr = forevr;
700aA   reade (pSession: pUser) workoss2;
700aA   if %eof(workoss2);
700aA     leave;
700aA   endif;
700aA /end-free
700aA
700aA*    Delete oss slot that was created.
700aA
700aAC                   exsr      clr$slot
700aAC                   eval      $slwhseu = *on
700aAC                   eval      $slwhse  = wowhse
700aAC                   eval      $slwhdpu = *on
700aAC                   eval      $slwhdp  = wowhdp
700aAC                   eval      $sldispu = *on
700aAC                   eval      $sldisp  = wodisp
700aA
700aAC                   eval      $saActionU = *on
700aAC                   eval      $saAction = 'OSS'
700aAC                   eval      $saETrn#U = *on
700aAC                   eval      $saETrn# = 0
700aA
700aAC                   eval      $dricommand = '*SLOT'
700aAC                   eval      $drisubcmd  = '%DELETEX'
700aAC                   eval      $drisys2upd = 'D'
700aAC                   eval      ck4err = *off
700aAC                   eval      zmflag  = *off
700aAC                   exsr      zzzdricop
700aAC                   if        error
700aAC                   endif
700aA
700aA*    Delete workoss record.
700aA
700aAC                   delete(e) workoss2
700aA
700aAC                   enddo
700aA
700aAC                   endsr
700aA*----------------------------------------------------------------
700aA*  clr$slot  Clear $slot data structure fields
700aA*----------------------------------------------------------------
700aA
700aAC     clr$slot      begsr
700aAC                   eval      savever# = $slver#
700aAC                   clear                   $slot
700aAC                   clear                   $slot2
700aAC                   eval      $slver# = savever#
700aAC                   eval      $saemp#U = *on
700aAC                   eval      $saemp# = e$emp#
700aAC                   endsr
700aA
700aA*----------------------------------------------------------------
700aA*  zzzdricop  Call DRICOP
700aA*----------------------------------------------------------------
700aA
700aAC     zzzdricop     begsr
700aAC                   eval      error = *off
700aA
700aAC                   select
700aAC                   when      $dricommand = '*SLOT'
700aAC                   eval      $dridata = $slot
700aAC                   eval      $dridata2 = $slot2
700aAC                   endsl
700aA
700aAC                   if        $dricommand = '*SLOT'
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #pgm          $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   parm                    $dridata2
700aAC                   else
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #pgm          $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   endif
700aA
700aAC                   select
700aA
700aAC                   when      %error and ck4err = *on
700aAC                   eval      error = *on
700aAC                   eval      errmsg    = 'Error occured on call to '
700aAC                                       + 'DRICOP'
700aAC                                       + '/' + %trim($drisubcmd)
700aAC                                       + ' from ' + #pgm
700aAC                   select
700aAC                   when      zmsflag
700aAC                   when      zmflag
700aAC                   endsl
700aA
700aAC                   when      $drireturn <> '*OK' and ck4err = *on
700aAC                   eval      error = *on
700aA
700aAC                   endsl
700aA
700aAC                   select
700aAC                   when      $dricommand = '*SLOT'
700aAC                   eval      $slot = $dridata
700aAC                   eval      $slot2 = $dridata2
700aAC                   endsl
700aA
700aAC                   eval      zmflag = *off
700aAC                   eval      zmsflag = *off
700aAC                   eval      ck4err = *off
700aAC     enddricop     endsr
700aA
