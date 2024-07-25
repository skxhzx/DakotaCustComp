      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M31800       Item Slot Maintenance - update slot data
     *  11 January   2021
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    01/11/21  LMC  7.40
     *      - Created.
     *
     *
     *
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n
     D dpCombo         s             20
     D logText         s            100
     D savsubcmd       s                   like($drisubcmd)
     D uxflag          s              1
     D kywhse          s                   like(pwhse)
     D  pWhse          s              3p 0
	    d  pwhdp          s              5
	    d  pdisp          s             12
	    d  paisl          s              3
     D  ploc           s              3p 0
     D  prlvl          s              2p 0
	    d  phand          s              2
	    d  pstat          s              2
	    d  pitem          s             15
	    d  pentd          s              8p 0
	    d  pexpd          s              8p 0
	    d  pexpd8         s              8
	    d  pexpd6         s              6
     D  pprty          s              1p 0
	    d  pcalc8         s              1
	    d  pcalc9         s              1

     D workdte         s              6  0
     D today           s              8  0
     D  pSubCmd        s             10
     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc     External object location called from.
     *      pparm1      parm string 1
     *      pparm2      parm string 2
     *      pparm3      parm string 3
     *
     *    Returned Parameters
     *      pmessage     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650bAD  pSessId        s             40
650bAD  pUser          s             10
730aAD  pDict          s             10
650bAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999



     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

DRYa  /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

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
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
      /free

         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         *inlr = *on;
         pMessage= ' ';

        // Extract parameters from delimited string

        ExtractParms();

         // Determine DRI subcommand to use.

         $drisubcmd = ' ';
         pSubCmd = %xlate(xlower: xupper: pSubCmd);
         select;
           when pSubCmd = 'A';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYADD';
               when pObjLoc = 'AFTERACT';
                 //$drisubcmd = '%ADD';
             endsl;
           when pSubCmd = 'C' or pSubCmd = 'U';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYCHG';
               when pObjLoc = 'AFTERACT';
                 //$drisubcmd = '%CHANGE';
             endsl;
           when pSubCmd = 'D';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYDEL';
               when pObjLoc = 'AFTERACT';
                 //$drisubcmd = '%DELETE';
             endsl;
           other;
             $drisubcmd = '%' + pSubCmd;
         endsl;
         // edits from it132 zzchk1
         // Verify expired date
         if pcalc9 = 'Y';

           if pexpd = 0;
             pmessage = 'Expiration Date is required';
             return;
           endif;
           //workdte = pexpd;

           //$cvcmd = '*CMDYMD ';
           //$cvd8i = %trimr(%editc(pexpd:'X'));
           //cvtdte ($cvtdt);
           //workdte = $cvd6o;

           $cvcmd = '*YMDEDT ';
           $cvd6i = pexpd6;
           cvtdte ($cvtdt);
           if $cvrtn = '*PGMQ   ';
             pmessage = 'Invalid date entered';
             return;
           endif;
           if pcalc8 = 'N';
             if pexpd < today;
               pmessage = 'Date must be greater than today';
               return;
             endif;
           endif;

         endif;

         savsubcmd = $drisubcmd;

         // Initialize DRI fields.

         savever# = $slver#;
         clear $slot;
         clear $slot2;
         $slver# = savever#;

         // Main entry form

         $slwhseu = *on;
         $slwhse  = pwhse;

         $slwhdpu = *on;
         $slwhdp  = pwhdp;

         $slaislu = *on;
         $slaisl  = paisl;

         $sllocu  = *on;
         $slloc   = ploc;

         $slrlvlu = *on;
         $slrlvl  = prlvl;

         $slhandu = *on;
         $slhand  = phand;

         $sldispu = *on;
         $sldisp  = pdisp;

         $slitemu = *on;
         $slitem  = pitem;

         $slstatu = *on;
         $slstat  = pstat;

         $slprtyu = *on;
         $slprty  = -(pprty);

         $slexpdu = *on;
         $slexpd  = pexpd;

         $slentdu = *on;
         $slentd  = pentd;

         $saActionU = *on;
         $saAction = 'CHG';
         $saETrn#U = *on;
         $saETrn# = 0;

         $dricommand = '*SLOT';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $slot;
         $dridata2 = $slot2;

         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);

         $slot = $dridata;
         $slot2 = $dridata2;

         select;
           when %error;
             pMessage= 'Error occured calling DRISLOT '
                     + '('
                     + %trimr(#Job) + '/'
                     + %trimr(#JobNbr) + '/'
                     + %trimr(#user)
                     + ')';
           when $drireturn <> '*OK';
             pMessage= 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
           other;
             if %subst($drisubcmd:2:1) <> 'V';
               logText = 'dricmd:' + %trimr($dricommand) + ','
                       + 'drisub:' + %trimr(savsubcmd) + ','
                       + 'slwhse:' + %char($slwhse) + ','
                       + 'sldisp:' + %trimr($sldisp);
               wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);
             endif;
         endsl;

         // Write debug record if flag is on.

         if debug;
           exsr wrtDebugParms;
         endif;

         // If an error occurs outside of FLDVALID,
         //   write a record to the debug log, regardless of flag.
         // We don't do this for FLDVALID because the calling program
         // will catch it and display the error.


         if pObjLoc <> 'FLDVALID' and pMessage<> ' ';
           if not debug;
             exsr wrtDebugParms;
           endif;
           exsr wrtDebugError;
         endif;

         $drisubcmd = '%CLOSE';
         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);
         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;
         $cvprg = #prog;
         $cvcmd = '*CURCMD ';
         cvtdte ($cvtdt);
         today = $cvd8o;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pWhse:' + %char(pWhse) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pSubCmd:' + %trimr(pSubCmd) + ', '
                  + 'pWhdp:' + %trimr(pWhdp) + ', '
                  + 'pdisp:' + %trimr(pdisp) + ', '
                  + 'pMessage:' + %trimr(pMessage);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = pMessage;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'SLWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'SLITEM';
             pitem = %trim(parmValue);

           when parmName = 'SLDISP';
             pdisp = %trim(parmValue);

           when parmName = 'SLWHDP';
             pwhdp = %trim(parmValue);

           when parmName = 'SLAISL';
             paisl  = %trim(parmValue);

           when parmName = 'SLHAND';
             phand = %trim(parmValue);

           when parmName = 'SLSTAT';
             pstat = %trim(parmValue);

           when parmName = 'SLENTD';
             if parmValue = '';
               parmValue = '0';
             endif;
             pentd =  %dec(parmValue: 8: 0);

           when parmName = 'SLEXPD';
             if parmValue = '';
               parmValue = '0';
             endif;
             pexpd =  %dec(parmValue: 8: 0);
             pexpd8= %trim(parmValue);
             pexpd6 = %subst(pexpd8:3:6);

           when parmName = 'SLLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             ploc  =  %dec(parmValue: 3: 0);

           when parmName = 'SLPRTY';
             if parmValue = '';
               parmValue = '0';
             endif;
             pprty =  %dec(parmValue: 1: 0);

           when parmName = 'SLRLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
             prlvl =  %dec(parmValue: 2: 0);

           when parmName = 'CALCULA008';
             pcalc8 = %trim(parmValue);

           when parmName = 'CALCULA009';
             pcalc9 = %trim(parmValue);

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
                  + %char(parmCount) + ' '
                  + parmName + ' '
                  + '(' + parmValue + ')'
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';

       endmon;

       return;

      /end-free

     p                 e
     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
                    + %char(parmCount) + ' '
                    + '(' + parmGroup + ')'
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
