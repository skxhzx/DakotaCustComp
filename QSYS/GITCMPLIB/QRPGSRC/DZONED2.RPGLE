217cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DZONED2     Processing program for PDZONED2
     *  16 October 2018
     *  Dave Sommerville
     *
     *  Revisions:
     *
720 A*    10/16/18  DAS  7.20
     *      - Created.
     *      - Based on PDZONED1
     *      - Revised to pass in DRI parameters in a '|' delimited
     *        string, instead of individual fields.
     *
720aA*    10/25/18  DAS  7.20a
     *      - Added new fields
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes for adding new option field
     *
     * - Add new field to ZONED file
     * - Add new field to QCOPY/C#ZONED
     * - Add new field to DRIZONED program.
     * - Add new field to GETZONE program.
     * - Recompile programs that use ZONED file
     * - Add field to ConvertField routine in this program.
     * - Revise MRC program to use new field.
     * - Add field to BfcSubmit routine in the MRC program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

650bAFbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650bAD dbgflgExists    s               n
     D debug           s               n
650fAD debugAfter      s               n
650fAD debugBefore     s               n
650aAD debugLoc        s              1
650aAD disp            s             12    inz(' ')
650cAD dpCombo         s             20
650dAD logText         s            100
720 Ad pCmd            s              1    inz('A')
650dAD savsubcmd       s                   like($drisubcmd)
     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStr         s            999    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650cA*      pSessId     Session Id
650cA*      pUser       User
650cA*      pDict       Dictionary
650cA*      pPgm        Program
     *      pSubCmd      DRI subcommand without '%'.
     *      pObjLoc      External object location called from.
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     D dzoned2         pr                  extpgm('DZONED2')
     D  pErrMsg                      99
650cAD  pSessId                      40
650cAD  pUser                        10
650cAD  pDict                        10
650cAD  pPgm                         10
     D  pObjLoc                      10
     D  pSubCmd                      10
     D  pParmStr1                   999
     D  pParmStr2                   999

     D dzoned2         pi
     D  pErrMsg                      99
650cAD  pSessId                      40
650cAD  pUser                        10
650cAD  pDict                        10
650cAD  pPgm                         10
     D  pObjLoc                      10
     D  pSubCmd                      10
     D  pParmStr1                   999
     D  pParmStr2                   999

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
650dA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ZONED
     D saveVer#        s                   like($zdver#)

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D strec         E Ds                  Extname(SlotStr)
     D zdrec         E Ds                  Extname(Zoned)

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

650fA    debug = *off;
650fA    debugBefore = *off;
650fA    debugAfter = *off;
650bA    if dbgflgExists;
650bA      chain(e) (#pgm) bfcdbgflg;
650bA      if %found(bfcdbgflg);
650fA        select;
650fA          when bdfflag = 1;
650fA            debug = *on;
650fA            debugAfter = *on;
650fA          when bdfflag = 2;
650fA            debug = *on;
650fA            debugBefore = *on;
650fA          when bdfflag = 3;
650fA            debug = *on;
650fA            debugBefore = *on;
650fA            debugAfter = *on;
650fA        endsl;
650bA      endif;
650bA    endif;

650fA    if debugBefore;
650fA      debugLoc = 'B';
650fA      exsr wrtDebugParms;
650fA    endif;

650cA    // Combine dictionary/program
650cA
650cA    dpCombo = %trim(pDict) + '.' + pPgm;

         *inlr = *on;
         pErrMsg = ' ';

         // Determine DRI subcommand to use.

         $drisubcmd = ' ';
650aA    pSubCmd = %xlate(xlower: xupper: pSubCmd);
         select;
           when pSubCmd = 'A';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYADD';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%ADD';
             endsl;
650eM      when pSubCmd = 'C' or pSubCmd = 'U';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYCHG';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%CHANGE';
             endsl;
           when pSubCmd = 'D';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYDEL';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%DELETE';
             endsl;
           other;
             $drisubcmd = '%' + pSubCmd;
         endsl;

650dA    savsubcmd = $drisubcmd;

         // Initialize DRI fields.

         savever# = $zdver#;
         clear $zoned;
         $zdver# = savever#;

         // Extract parameters from delimited string

         exsr ExtractParms;

         if pErrMsg = '';

           $dricommand = '*ZONED';
           $drisys2upd = 'D';
           $driprogram = #pgm;
           $dridata = $zoned;

           // Call DRI program.

           driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                  $drireturn: $drimessage: $dridata);

           $zoned = $dridata;

           select;
             when %error;
               pErrMsg = 'Error occured calling DRIZONED '
                       + '('
                       + %trimr(#Job) + '/'
                       + %trimr(#JobNbr) + '/'
                       + %trimr(#user)
                       + ')';
             when $drireturn <> '*OK';
               pErrMsg = 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
650dA        other;
650dA          if %subst($drisubcmd:2:1) <> 'V';
650dA            logText = 'dricmd:' + %trimr($dricommand) + ','
650dA                    + 'drisub:' + %trimr(savsubcmd) + ','
650dA                    + 'zdwhse:' + %char($zdwhse) + ','
650dA                    + 'zdtruk:' + %trimr($zdtruk) + ','
650dA                    + 'zdzone:' + %trimr($zdzone);
650dA            wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);
                 $zdtstTruk = $zdtruk;
                 $zdwhse = $zdwhse;
                 $zdCmd = 'A';
                 $dridata = $zoned;
                 $drisubcmd = '%UPDSTRSLT';
                 driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                        $drireturn: $drimessage: $dridata);
650dA          endif;
           endsl;

         endif;

         // Write debug record if flag is on.

650fM    if debugAfter;
650fA      debugLoc = 'A';
           exsr wrtDebugParms;
         endif;

         // If an error occurs outside of FLDVALID,
         //   write a record to the debug log, regardless of flag.
         // We don't do this for FLDVALID because the calling program
         // will catch it and display the error.


         if pObjLoc <> 'FLDVALID' and pErrMsg <> ' ';
650fM      if not debugAfter;
650fA      debugLoc = 'A';
             exsr wrtDebugParms;
           endif;
           exsr wrtDebugError;
         endif;

         return;

      /end-free

650bA*----------------------------------------------------------------
650bA*  *INZSR   Initialization subroutine
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
650bA /end-free

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

      /free
       begsr ConvertField;

       monitor;

         select;

           when parmName = 'ZDWHSE';
             $zdWhseu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zdWhse =  %dec(parmValue: 3: 0);

           when parmName = 'ZDTRUK';
             $zdtruku = *on;
             $zdtruk  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDZONE';
             $zdzoneu = *on;
             $zdzone  = %xlate(xlower: xupper: parmValue);

           // Update fields

           when parmName = 'ZDWHDP';
             $zdwhdpu = *on;
             $zdwhdp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDSTYP';
             $zdstypu = *on;
             $zdstyp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDAISL';
             $zdaislu = *on;
             $zdaisl  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDAISL2';
             $zdaisl2u = *on;
             $zdaisl2  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDRLVL';
             $zdrlvlu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zdrlvl =  %dec(parmValue: 2: 0);

           when parmName = 'ZDRLVL2';
             $zdrlvl2u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zdrlvl2 =  %dec(parmValue: 2: 0);

           when parmName = 'ZDLOC1';
             $zdloc1u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zdloc1 =  %dec(parmValue: 3: 0);

           when parmName = 'ZDLOC2';
             $zdloc2u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zdloc2 =  %dec(parmValue: 3: 0);

           when parmName = 'ZDDESG';
             $zddesgu = *on;
             $zddesg  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDACTV';
             $zdactvu = *on;
             $zdactv  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDCAT';
             $zdcatu = *on;
             $zdcat  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDCLCDE';
             $zdclcdeu = *on;
             $zdclcde  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDHND1';
             $zdhnd1u = *on;
             $zdhnd1  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDHND2';
             $zdhnd2u = *on;
             $zdhnd2  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDUTYP';
             $zdutypu = *on;
             $zdutyp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZDSIDE';
             $zdsideu = *on;
             $zdside  = %xlate(xlower: xupper: parmValue);

720aA      when parmName = 'ZDPCKOVF';
720aA        $zdpckovfu = *on;
720aA        $zdpckovf = %xlate(xlower: xupper: parmValue);

720aA      when parmName = 'ZDCSTCOD';
720aA        $zdcstcodu = *on;
720aA        $zdcstcod = %xlate(xlower: xupper: parmValue);

           // Original fields

           when parmName = 'ZOWHDP';
             $zowhdpu = *on;
             $zowhdp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOSTYP';
             $zostypu = *on;
             $zostyp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOAISL';
             $zoaislu = *on;
             $zoaisl  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOAISL2';
             $zoaisl2u = *on;
             $zoaisl2  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZORLVL';
             $zorlvlu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zorlvl =  %dec(parmValue: 2: 0);

           when parmName = 'ZORLVL2';
             $zorlvl2u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zorlvl2 =  %dec(parmValue: 2: 0);

           when parmName = 'ZOLOC1';
             $zoloc1u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zoloc1 =  %dec(parmValue: 3: 0);

           when parmName = 'ZOLOC2';
             $zoloc2u = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zoloc2 =  %dec(parmValue: 3: 0);

           when parmName = 'ZODESG';
             $zodesgu = *on;
             $zodesg  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOACTV';
             $zoactvu = *on;
             $zoactv  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOCAT';
             $zocatu = *on;
             $zocat  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOCLCDE';
             $zoclcdeu = *on;
             $zoclcde  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOHND1';
             $zohnd1u = *on;
             $zohnd1  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOHND2';
             $zohnd2u = *on;
             $zohnd2  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOUTYP';
             $zoutypu = *on;
             $zoutyp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZOSIDE';
             $zosideu = *on;
             $zoside  = %xlate(xlower: xupper: parmValue);

720aA      when parmName = 'ZOPCKOVF';
720aA        $zopckovfu = *on;
720aA        $zopckovf = %xlate(xlower: xupper: parmValue);

720aA      when parmName = 'ZOCSTCOD';
720aA        $zocstcodu = *on;
720aA        $zocstcod = %xlate(xlower: xupper: parmValue);

         endsl;

       on-error;

         pErrMsg = 'Error extracting parameter '
                 + %char(parmCount) + ' '
                 + parmName + ' '
                 + '(' + parmValue + ')'
                 + '('
                 + %trimr(#Job) + '/'
                 + %trimr(#JobNbr) + '/'
                 + %trimr(#user)
                 + ')';

       endmon;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

      /free
       begsr ExtractParms;

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pErrMsg = 'Error: Parameter string is empty '
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         exsr ExtractParmStr;

         if pErrMsg <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         exsr ExtractParmStr;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

      /free
       begsr ExtractParmStr;

       // Drag Id's are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter group ('fldname=value')

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
           pErrMsg = 'Error: Invalid parameter group '
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

         exsr ConvertField;
         if pErrMsg <> '';
           leave;
         endif;

       enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

650cA    bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
650fA             + 'dbgloc:' + %trimr(debugLoc) + ', '
650cA             + 'pUser:' + %trimr(pUser) + ', '
650cA             + 'pDict:' + %trimr(pDict) + ', '
650cA             + 'pPgm:' + %trimr(pPgm) + ', '
650cM             + 'pWhse:' + %char($zdWhse) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pSubCmd:' + %trimr(pSubCmd) + ', '
                  + 'pTruck:' + %trimr($zdTruk) + ', '
                  + 'pZone:' + %trimr($zdZone) + ', '
                  + 'pErrMsg:' + %trimr(pErrMsg);

650fA    bdaddts = %timestamp();
650fA    bdaddpgm = #pgm;
650fA    bdaddcusr = #curruser;
650fA    bdaddjusr = #user;
650fA    bdaddjob = #job;
650fA    bdaddnbr = #jobnbr;

650fA    write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = pErrMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
