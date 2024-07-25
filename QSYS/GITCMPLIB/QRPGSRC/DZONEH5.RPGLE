      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DZONEH5     Processing program for PDZONEH5
     *  16 October 2018
     *  Dave Sommerville
     *
     *  Revisions:
     *
720 A*    10/16/18  DAS  7.20
     *      - Created.
     *
740aA*    05/27/20  DAS  7.40a
     *      - Added ozrfzp
     *
740bA*    06/08/20  DAS  7.40b
     *      - Revised wrtDebugParms to display pParmStr fields in
     *        Before call and $z fields in After call.
     *
740cA*    08/20/20  KDE  7.40c
     *      - Added opicub, oppisplt, opmscb, opmsvh, opmsvm,opmsvl,
     *        and opoacb, version 9 fields
     *
750 A*    02/18/21  KDE  7.50
     *      - Added oppstuff
     *
750aA*    03/19/21  KDE  7.50a
     *      - Added oppmsp, oppmstp, oppmord
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes for adding new option field
     *
     * - Add new field to appropriate OPTION defs (e.g.,OPTIONZDSL, OPTIONZDS)
     * - Add new field to appropriate QCOPY/C# source (e.g., C#ZONEH)
     * - Add new field to DRIZONEH program.
     * - Add field to ConvertField routine in this program.
     * - Add new field to appropriate QDDSFILES/OP program (e.g., OPZPICK)
     * - Run above OP program to update the SQL View.
     * - Copy above OP SQL View to BFCDAKOTAF.
     * - Add field to file in MRC Dictionary
     * - Revise MRC program to use new field.
     * - Add field to BfcSubmit routine in the MRC program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

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
     D debugAfter      s               n
     D debugBefore     s               n
     D debugLoc        s              1
     D dpCombo         s             20
     D logText         s            100
     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStr         s            999    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0
     D savsubcmd       s                   like($drisubcmd)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pSubCmd      DRI subcommand without '%'.
     *      pObjLoc      External object location called from.
     *
     *    Returned Parameters
     *      pErrMsg      Error message
     *
     *----------------------------------------------------------------

     D dzoneh5         pr                  extpgm('DZONEH5')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pSubCmd                      10
     D  pType                         1
     D  pParmStr1                   999
     D  pParmStr2                   999

     D dzoneh5         pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pSubCmd                      10
     D  pType                         1
     D  pParmStr1                   999
     D  pParmStr2                   999

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ZONEH
     D saveVer#        s                   like($zhver#)

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             select;
               when bdfflag = 1;
                 debug = *on;
                 debugAfter = *on;
               when bdfflag = 2;
                 debug = *on;
                 debugBefore = *on;
               when bdfflag = 3;
                 debug = *on;
                 debugBefore = *on;
                 debugAfter = *on;
             endsl;
           endif;
         endif;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         *inlr = *on;

         if debugBefore;
           debugLoc = 'B';
           exsr wrtDebugParms;
         endif;
         pErrMsg = ' ';

         // Determine DRI subcommand to use.

         $drisubcmd = ' ';
         pSubCmd = %xlate(xlower: xupper: pSubCmd);
         select;
           when pSubCmd = 'A';
             select;
               when pType = 'T';
                 $drisubcmd = 'SKIP';
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYADD';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%ADD';
             endsl;
           when pSubCmd = 'COPY' and pType = 'T';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERFYCPYT';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%COPYTPL';
             endsl;
           when pSubCmd = 'COPY' and pType = 'Z';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERFYCPYZ';
               when pObjLoc = 'AFTERACT';
710aD            //$drisubcmd = '%COPYZON';
710aM            $drisubcmd = '%COPYZONW';
             endsl;
           when pSubCmd = 'C' or pSubCmd = 'U';
             select;
               when pType = 'T';
                 $drisubcmd = 'SKIP';
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYCHG';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%CHANGE';
             endsl;
           when pSubCmd = 'D' and pType = 'T';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERFYDELT';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%DELETETPL';
             endsl;
           when pSubCmd = 'D' and pType = 'Z';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYDEL';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%DELETE';
             endsl;
           other;
             $drisubcmd = '%' + pSubCmd;
         endsl;

         savsubcmd = $drisubcmd;

         // Initialize DRI fields.

         savever# = $zhver#;
         clear $zoneh;
740cA    if savever# >= 9;
740cA      clear $zoneh2;
740cA    endif;
         $zhver# = savever#;

         // Extract parameters from delimited string

         exsr ExtractParms;

         if pErrMsg = '';

           // Call DRI program

           $dricommand = '*ZONEH';
           $drisys2upd = 'D';
           $driprogram = #pgm;
           $dridata = $zoneh;
740cA      if savever# >= 9;
740cA        $dridata2 = $zoneh2;
740cA      endif;

           if $drisubcmd <> 'SKIP';

740cA        if savever# < 9;
               driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                      $drireturn: $drimessage: $dridata);
740cA        else;
               driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
740cM                 $drireturn: $drimessage: $dridata: $dridata2);
740cA        endif;

             $zoneh = $dridata;
740cA        if savever# >= 9;
740cA          $zoneh2 = $dridata2;
740cA        endif;

             select;
               when %error;
                 pErrMsg = 'Error occured calling DRIZONEH '
                         + '('
                         + %trimr(#Job) + '/'
                         + %trimr(#JobNbr) + '/'
                         + %trimr(#user)
                         + ')';
               when $drireturn <> '*OK';
                 pErrMsg = 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
               other;
                 if %subst($drisubcmd:2:1) <> 'V';
                   logText = 'dricmd:' + %trimr($dricommand) + ','
                           + 'drisub:' + %trimr(savsubcmd) + ','
                           + 'zhwhse:' + %char($zhwhse) + ','
                           + 'zhtruk:' + %trimr($zhtruk) + ','
                           + 'zhzone:' + %trimr($zhzone);
                   wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);
                 endif;
             endsl;

           endif;

         endif;

         // Write debug record if flag is on.

         if debugAfter;
           debugLoc = 'A';
           exsr wrtDebugParms;
         endif;

         // If an error occurs outside of FLDVALID,
         //   write a record to the debug log, regardless of flag.
         // We don't do this for FLDVALID because the calling program
         // will catch it and display the error.

         if not debugAfter and pErrMsg <> '' and pObjLoc <> 'FLDVALID';
           exsr wrtDebugError;
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

      /free
       begsr ConvertField;

       monitor;

         select;

           when parmName = 'ZHWHSE';
             $zhWhseu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $zhWhse =  %dec(parmValue: 3: 0);

           when parmName = 'ZHTRUK';
             $zhtruku = *on;
             $zhtruk  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZHZONE';
             $zhzoneu = *on;
             $zhzone  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZHDESC';
             $zhdescu = *on;
             $zhdesc  = parmValue;

           when parmName = 'ZHCOMP';
             $zhcompu = *on;
             $zhcomp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZHPZON';
             $zhpzonu = *on;
             $zhpzon  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPBPCK';
             $opbpcku = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opbpck  = %dec(parmValue: 3: 0);

           when parmName = 'OPFPAL';
             $opfpalu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opfpal  = %dec(parmValue: 1: 0);

           when parmName = 'OPSPAL';
             $opspalu = *on;
             $opspal  = %xlate(xlower: xupper: parmValue);
             if $opspal  = ' ';
               $opspal  = 'N';
             endif;

           when parmName = 'OPFCUB';
             $opfcubu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opfcub  = %dec(parmValue: 5: 2);

           when parmName = 'OPFSTP';
             $opfstpu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opfstp  = %dec(parmValue: 2: 0);

           when parmName = 'OPPITM';
             $oppitmu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $oppitm  = %dec(parmValue: 4: 0);

           when parmName = 'OPPBLD';
             $oppbldu = *on;
             $oppbld  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPNWPL';
             $opnwplu = *on;
             $opnwpl  = %xlate(xlower: xupper: parmValue);
             if $opnwpl  = ' ';
               $opnwpl  = 'N';
             endif;

           when parmName = 'OPFORD';
             $opfordu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opford  = %dec(parmValue: 2: 0);

           when parmName = 'OPPTYP';
             $opptypu = *on;
             $opptyp  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPPKUP';
             $oppkupu = *on;
             $oppkup  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPSTOP';
             $opstopu = *on;
             $opstop  = %xlate(xlower: xupper: parmValue);
             if $opstop  = ' ';
               $opstop  = 'N';
             endif;

           when parmName = 'OPFTOT';
             // Not used/sent in DRIZONEH

           when parmName = 'OPTECB';
             $optecbu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $optecb  = %dec(parmValue: 5: 2);

           when parmName = 'OPTICB';
             $opticbu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opticb  = %dec(parmValue: 5: 2);

           when parmName = 'OPTORD';
             $optordu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $optord  = %dec(parmValue: 2: 0);

           when parmName = 'OPTPCS';
             $optpcsu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $optpcs  = %dec(parmValue: 3: 0);

           when parmName = 'OPCLVL';
             $opclvlu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opclvl  = %dec(parmValue: 3: 0);

           when parmName = 'OPCWRA';
             $opcwrau = *on;
             $opcwra  = %xlate(xlower: xupper: parmValue);
             if $opcwra  = ' ';
               $opcwra  = 'N';
             endif;

           when parmName = 'OPCWRB';
             $opcwrbu = *on;
             $opcwrb  = %xlate(xlower: xupper: parmValue);
             if $opcwrb  = ' ';
               $opcwrb  = 'N';
             endif;

           when parmName = 'OPUWRA';
             $opuwrau = *on;
             $opuwra  = %xlate(xlower: xupper: parmValue);
             if $opuwra  = ' ';
               $opuwra  = 'N';
             endif;

           when parmName = 'OPUWRB';
             $opuwrbu = *on;
             $opuwrb  = %xlate(xlower: xupper: parmValue);
             if $opuwrb  = ' ';
               $opuwrb  = 'N';
             endif;

           when parmName = 'OPERR';
             $operru  = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $operr   = %dec(parmValue: 2: 0);

           when parmName = 'OPCWGT';
             $opcwgtu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opcwgt  = %dec(parmValue: 2: 0);

           when parmName = 'OPAISL';
             $opaislu = *on;
             $opaisl  = %xlate(xlower: xupper: parmValue);
             if $opaisl  = ' ';
               $opaisl  = 'N';
             endif;

           when parmName = 'OPTAXR';
             $optaxru = *on;
             $optaxr  = %xlate(xlower: xupper: parmValue);
             if $optaxr  = ' ';
               $optaxr  = 'N';
             endif;

           when parmName = 'OPCHKR';
             $opchkru = *on;
             $opchkr  = %xlate(xlower: xupper: parmValue);
             if $opchkr  = ' ';
               $opchkr  = 'N';
             endif;

           when parmName = 'OPLB1';
             $oplb1u  = *on;
             $oplb1   = %xlate(xlower: xupper: parmValue);
             if $oplb1 = ' ';
               $oplb1 = 'N';
             endif;

           when parmName = 'OPCU1';
             $opcu1u  = *on;
             $opcu1   = %xlate(xlower: xupper: parmValue);
             if $opcu1 = ' ';
               $opcu1 = 'N';
             endif;

           when parmName = 'OPLP1';
             $oplp1u  = *on;
             $oplp1   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV1';
             $opdv1u  = *on;
             $opdv1   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM1';
             $opfm1u  = *on;
             $opfm1   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB2';
             $oplb2u  = *on;
             $oplb2   = %xlate(xlower: xupper: parmValue);
             if $oplb2 = ' ';
               $oplb2 = 'N';
             endif;

           when parmName = 'OPCU2';
             $opcu2u  = *on;
             $opcu2   = %xlate(xlower: xupper: parmValue);
             if $opcu2 = ' ';
               $opcu2 = 'N';
             endif;

           when parmName = 'OPLP2';
             $oplp2u  = *on;
             $oplp2   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV2';
             $opdv2u  = *on;
             $opdv2   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM2';
             $opfm2u  = *on;
             $opfm2   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB3';
             $oplb3u  = *on;
             $oplb3   = %xlate(xlower: xupper: parmValue);
             if $oplb3 = ' ';
               $oplb3 = 'N';
             endif;

           when parmName = 'OPCU3';
             $opcu3u  = *on;
             $opcu3   = %xlate(xlower: xupper: parmValue);
             if $opcu3 = ' ';
               $opcu3 = 'N';
             endif;

           when parmName = 'OPLP3';
             $oplp3u  = *on;
             $oplp3   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV3';
             $opdv3u  = *on;
             $opdv3   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM3';
             $opfm3u  = *on;
             $opfm3   = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB4';
             $oplb4u  = *on;
             $oplb4   = %xlate(xlower: xupper: parmValue);
             if $oplb4 = ' ';
               $oplb4 = 'N';
             endif;

           when parmName = 'OPCU4';
             $opcu4u = *on;
             $opcu4  = %xlate(xlower: xupper: parmValue);
             if $opcu4 = ' ';
               $opcu4 = 'N';
             endif;

           when parmName = 'OPLP4';
             $oplp4u = *on;
             $oplp4  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV4';
             $opdv4u = *on;
             $opdv4  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM4';
             $opfm4u = *on;
             $opfm4  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB5';
             $oplb5u = *on;
             $oplb5  = %xlate(xlower: xupper: parmValue);
             if $oplb5 = ' ';
               $oplb5 = 'N';
             endif;

           when parmName = 'OPCU5';
             $opcu5u = *on;
             $opcu5  = %xlate(xlower: xupper: parmValue);
             if $opcu5 = ' ';
               $opcu5 = 'N';
             endif;

           when parmName = 'OPLP5';
             $oplp5u = *on;
             $oplp5  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV5';
             $opdv5u = *on;
             $opdv5  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM5';
             $opfm5u = *on;
             $opfm5  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB6';
             $oplb6u = *on;
             $oplb6  = %xlate(xlower: xupper: parmValue);
             if $oplb6 = ' ';
               $oplb6 = 'N';
             endif;

           when parmName = 'OPCU6';
             $opcu6u = *on;
             $opcu6  = %xlate(xlower: xupper: parmValue);
             if $opcu6 = ' ';
               $opcu6 = 'N';
             endif;

           when parmName = 'OPLP6';
             $oplp6u = *on;
             $oplp6  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPDV6';
             $opdv6u = *on;
             $opdv6  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPFM6';
             $opfm6u = *on;
             $opfm6  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPLB7';
             $oplb7u = *on;
             $oplb7  = %xlate(xlower: xupper: parmValue);
             if $oplb7 = ' ';
               $oplb7 = 'N';
             endif;

           when parmName = 'OPLBL';
             $oplblu = *on;
             $oplbl  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPMCUB';
             $opmcubu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opmcub = %dec(parmValue: 5: 2);

           when parmName = 'OPPMTZ';
             $oppmtzu = *on;
             $oppmtz = %xlate(xlower: xupper: parmValue);
             if $oppmtz  = ' ';
               $oppmtz  = 'N';
             endif;

           when parmName = 'OPDDDO';
             $opdddou = *on;
             $opdddo = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZHFRMTRUK';
             $zhfrmtruku = *on;
             $zhfrmtruk  = %xlate(xlower: xupper: parmValue);

           when parmName = 'ZHFRMZONE';
             $zhfrmzoneu = *on;
             $zhfrmzone  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPNBPS';
             $opnbpsu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opnbps = %dec(parmValue: 1: 0);

           when parmName = 'OPFWGT';
             $opfwgtu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opfwgt = %dec(parmValue: 4: 0);

           when parmName = 'OPFPLT';
             $opfpltu = *on;
             $opfplt = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPBSEQ';
             $opbsequ = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opbseq = %dec(parmValue: 2: 0);

           when parmName = 'OPSSTP';
             $opsstpu = *on;
             if parmValue = '';
               parmValue = '0';
             endif;
             $opsstp = %dec(parmValue: 2: 0);

750 A      when parmName = 'OPPSTUFF';
750 A        $oppstuffu = *on;
750 A        $oppstuff = %xlate(xlower: xupper: parmValue);

750aA      when parmName = 'OPPMSP';
750aA        $oppmspu = *on;
750aA        $oppmsp = %xlate(xlower: xupper: parmValue);

750aA      when parmName = 'OPPMSTP';
750aA        $oppmstpu = *on;
750aA        $oppmstp = %xlate(xlower: xupper: parmValue);

750aA      when parmName = 'OPPMORD';
750aA        $oppmordu = *on;
750aA        $oppmord = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPICUB';
740c         $opicubu = *on;
740c         if parmValue = '';
740c           parmValue = '0';
740c         endif;
740c         $opicub = %dec(parmValue: 5: 2);

740c       when parmName = 'OPPISPLT';
740c         $oppispltu = *on;
740c         $oppisplt = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPMSCB';
740c         $opmscbu = *on;
740c         if parmValue = '';
740c           parmValue = '0';
740c         endif;
740c         $opmscb = %dec(parmValue: 2: 0);

740c       when parmName = 'OPMSVH';
740c         $opmsvhu = *on;
740c         $opmsvh = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPMSVM';
740c         $opmsvmu = *on;
740c         $opmsvm = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPMSVL';
740c         $opmsvlu = *on;
740c         $opmsvl = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPOACB';
740c         $opoacbu = *on;
740c         if parmValue = '';
740c           parmValue = '0';
740c         endif;
740c         $opoacb = %dec(parmValue: 2: 0);

740c       when parmName = 'OPZPLT';
740c         $opzpltu = *on;
740c         $opzplt = %xlate(xlower: xupper: parmValue);

740c       when parmName = 'OPBPLT';
740c         $opbpltu = *on;
740c         $opbplt = %xlate(xlower: xupper: parmValue);

740aA      when parmName = 'OZRFZP';
740aA        $ozrfzpu = *on;
740aA        $ozrfzp = %xlate(xlower: xupper: parmValue);

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

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pSubCmd:' + %trimr(pSubCmd) + ', '
                  + 'pType:' + pType + ', ';

         if debugLoc = 'A';
           bdvalues = %trimr(bdvalues)
                    + 'pWhse:' + %char($zhwhse) + ', '
                    + 'pTruck:' + %trimr($zhtruk) + ', '
                    + 'pZone:' + %trimr($zhzone) + ', '
                    + 'pFrmTruck:' + %trimr($zhfrmtruk) + ', '
                    + 'pErrMsg:' + %trimr(pErrMsg);
         endif;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         if debugLoc = 'B';
           bdvalues = 'pParm1' + pParmStr1;
           write(e) bdrec;
           bdvalues = 'pParm2' + pParmStr2;
           write(e) bdrec;
         endif;

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

