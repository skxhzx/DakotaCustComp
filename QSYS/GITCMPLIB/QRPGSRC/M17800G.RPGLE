      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
750bAH bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M17800G     Item Maintenance GetAll Fields
     *  08 August 2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
740 A*    08/07/20  LMC  7.40
     *      - Created.
750aA*    08/19/21  LMC  7.50a
     *      - Need to add a call to dritiem for getall when command
     *        sent in is getbase. Otherwise if the client is using
     *        extended descriptions, we will get freemarker errors.
     *        The IXDSC1/IXDSC2 fields need to be loaded.
     *
750bA*    10/29/21  DAS  7.50b
     *      - Revised to use YAJL. Re: Some item descriptions at
     *        Merit had double quotes in them. YAJL should
     *        automatically escape them.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This is an example of a processing program that is called via
     *  the GENFNC SQL Function (RPG program PGENFNC).
     *
     *  The parameter is assumed to be a string containing value
     *  pairs, with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  The returned string is assumed to be in JSON format.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

750bA*----------------------------------------------------------------
750bA*  YAJL Header
750bA*----------------------------------------------------------------
750bA
750bA /copy qcopysrc,yajl_h

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d chk4err         s               n
     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1
     D error           s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
     d cmd             s             10
     d aaitem          s             15
     d aawhse          s              3  0
     d aalabel         s              7  0

     d alwdel          s              1

     d iacodeTFR       s              2
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Customer id
     *
      /COPY QCOPYSRC,id#coastal
      /COPY QCOPYSRC,ID#GMM
      /COPY QCOPYSRC,ID#HALSEY
      /copy qcopysrc,id#kfs
      /copy qcopysrc,id#hpc
      /COPY QCOPYSRC,ID#EGF
      /COPY QCOPYSRC,ID#SAVAL
      /copy qcopysrC,id#fpr
     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D OPSITEMMNT1   E Ds                  Extname(OPSITEMMNT)
     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D M17800G         pr                  extpgm('M17800G')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D M17800G         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

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

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = '';

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

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

750bA    // Initialize JSON buffer
750bA
750bA    yajl_genOpen(*Off);
750bA
750bA    // Begin main JSON object (i.e., intial '{')
750bA
750bA    yajl_beginObj();         // Begin JSON string

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
750bD      //pOutStr = '{"errMsg":"' + errMsg + '"}';
750bM      yajl_addchar('errmsg': errmsg);
           WrtDebugError();
750bA      yajl_endObj();                 // End JSON string
750bA      pOutStr = YAJL_copyBufStr();   // Copy JSON string into parameter
750bA      yajl_genClose();               // Close and cleanup JSON processing
           return;
         endif;

         // Do processing

         select;
           when cmd <> '*GETBASE';
             exsr clr$item;

             $itWhse = aawhse;
             $ititem = aaitem;
             $iSession = pSessId;

             $dricommand = '*ITEM';
             $drisubcmd  = '%GETALL';
             $drisys2upd = 'D';
             chk4err = *on;
             exsr zzzdricop;
             if error = *on;
             endif;

             Select;
               when cmd = '*GETITEM';
                 iacodeTFR = 'CI';
                 if client = CoastalSunbelt
                    and iacodeTFR = 'CI';
                   iacodeTFR = '10';
                 endif;
                 if client = halsey
                    and iacodeTFR = 'CI';
                   iacodeTFR = '15';
                 endif;
                 if client = menumaker
                    and iacodeTFR = 'CI';
                   iacodeTFR = '13';
                 endif;
                 if client = kellys
                    and iacodeTFR = 'CI';
                   iacodeTFR = 'IA';
                 endif;
                 if client = holtpaper
                    and iacodeTFR = 'CI';
                   iacodeTFR = '8 ';
                 endif;
                 if client = egf
                    and iacodeTFR = 'CI';
                   iacodeTFR = 'X ';
                 endif;
                 if client = saval
                    and iacodeTFR = 'CI';
                   eval iacodeTFr = ' ';
                 endif;
                 if client = FoodPro
                    and iacodeTFR = 'CI';
                   iacodeTFR = ' ';
                 endif;
750bD            //pOutStr = '{'
750bD            //  +    '"imltrk":"' + %trim($imltrk) + '",'
750bD            //  +    '"itcwgt":"' + %trim($itcwgt) + '",'
750bD            //  +    '"iacodeTFR":"' + %trim(iacodeTFR) + '",'
750bD            //  +    '"itum1":"' + %trim($itum1) + '",'
750bD            //  +    '"itum2":"' + %trim($itum2) + '",'
750bD            //  +    '"itflg1":"' + %trim($itflg1) + '",'
750bD            //  +    '"itum3":"' + %trim($itum3) + '",'
750bD            //  +    '"itflg2":"' + %char($itflg2) + '"'
750bD            //  + '}';
750bM            yajl_addchar('imltrk': %trim($imltrk));
750bM            yajl_addchar('itcwgt': %trim($itcwgt));
750bM            yajl_addchar('iacodeTFR': %trim(iacodeTFR));
750bM            yajl_addchar('itum1': %trim($itum1));
750bM            yajl_addchar('itum2': %trim($itum2));
750bM            yajl_addchar('itflg1': %trim($itflg1));
750bM            yajl_addchar('itum3': %trim($itum3));
750bM            yajl_addchar('itflg2': %char($itflg2));
               other;
750bD            //pOutStr = '{'
750bD            //  +    '"itmitem":"' + %trim($itmitem) + '",'
750bD            //  +    '"itcitem":"' + %trim($itcitem) + '",'
750bD            //  +    '"ixdsc1":"' + %trim($ixdsc1) + '",'
750bD            //  +    '"ixdsc2":"' + %trim($ixdsc2) + '",'
750bD            //  +    '"imtie":"' + %char($imtie) + '",'
750bD            //  +    '"imhigh":"' + %char($imhigh) + '",'
750bD            //  +    '"immflg":"' + %trim($immflg) + '",'
750bD            //  +    '"imdday":"' + %char($imdday) + '",'
750bD            //  +    '"imuday":"' + %char($imuday) + '",'
750bD            //  +    '"immday":"' + %char($immday) + '",'
750bD            //  +    '"imwrnc":"' + %trim($imwrnc) + '",'
750bD            //  +    '"imrg1c":"' + %char($imrg1c) + '",'
750bD            //  +    '"imrg2c":"' + %char($imrg2c) + '",'
750bD            //  +    '"imapck":"' + %trim($imapck) + '",'
750bD            //  +    '"imnrpk":"' + %char($imnrpk) + '",'
750bD            //  +    '"imnslt":"' + %trim($imnslt) + '",'
750bD            //  +    '"imxdck":"' + %trim($imxdck) + '",'
750bD            //  +    '"imbnbr":"' + %char($imbnbr) + '",'
750bD            //  +    '"imbnam":"' + %trim($imbnam) + '",'
750bD            //  +    '"imvnam":"' + %trim($imvnam) + '",'
750bD            //  +    '"imbrnd":"' + %trim($imbrnd) + '",'
750bD            //  +    '"imlot":"' + %trim($imlot) + '",'
750bD            //  +    '"imltrk":"' + %trim($imltrk) + '",'
750bD            //  +    '"imoday":"' + %char($imoday) + '",'
750bD            //  +    '"ifcat":"' + %trim($ifcat) + '",'
750bD            //  +    '"kcqty1old":"' + %char($kcqty1old) + '",'
750bD            //  +    '"kcqty2":"' + %char($kcqty2) + '",'
750bD            //  +    '"kcqty3":"' + %char($kcqty3) + '",'
750bD            //  +    '"ifcaseovf":"' + %trim($ifcaseovf) + '",'
750bD            //  +    '"ifodrslot":"' + %trim($ifodrslot) + '",'
750bD            //  +    '"ifucicde":"' + %trim($ifucicde) + '",'
750bD            //  +    '"ifrcvmth":"' + %trim($ifrcvmth) + '",'
750bD            //  +    '"ifsltmth":"' + %trim($ifsltmth) + '",'
750bD            //  +    '"ifbrdflg":"' + %trim($ifbrdflg) + '",'
750bD            //  +    '"kidisp":"' + %trim($kidisp) + '",'
750bD            //  +    '"kirptp":"' + %trim($kirptp) + '",'
750bD            //  +    '"kiqty1":"' + %char($kiqty1) + '",'
750bD            //  +    '"kiqty2":"' + %char($kiqty2) + '",'
750bD            //  +    '"kiqty3":"' + %char($kiqty3) + '",'
750bD            //  +    '"kcdisp":"' + %trim($kcdisp) + '",'
750bD            //  +    '"kcqty1":"' + %char($kcqty1) + '"'
750bD            //  + '}';
750bM            yajl_addchar('itmitem': %trim($itmitem));
750bM            yajl_addchar('itcitem': %trim($itcitem));
750bM            yajl_addchar('ixdsc1': %trim($ixdsc1));
750bM            yajl_addchar('ixdsc2': %trim($ixdsc2));
750bM            yajl_addchar('imtie': %char($imtie));
750bM            yajl_addchar('imhigh': %char($imhigh));
750bM            yajl_addchar('immflg': %trim($immflg));
750bM            yajl_addchar('imdday': %char($imdday));
750bM            yajl_addchar('imuday': %char($imuday));
750bM            yajl_addchar('immday': %char($immday));
750bM            yajl_addchar('imwrnc': %trim($imwrnc));
750bM            yajl_addchar('imrg1c': %char($imrg1c));
750bM            yajl_addchar('imrg2c': %char($imrg2c));
750bM            yajl_addchar('imapck': %trim($imapck));
750bM            yajl_addchar('imnrpk': %char($imnrpk));
750bM            yajl_addchar('imnslt': %trim($imnslt));
750bM            yajl_addchar('imxdck': %trim($imxdck));
750bM            yajl_addchar('imbnbr': %char($imbnbr));
750bM            yajl_addchar('imbnam': %trim($imbnam));
750bM            yajl_addchar('imvnam': %trim($imvnam));
750bM            yajl_addchar('imbrnd': %trim($imbrnd));
750bM            yajl_addchar('imlot': %trim($imlot));
750bM            yajl_addchar('imltrk': %trim($imltrk));
750bM            yajl_addchar('imoday': %char($imoday));
750bM            yajl_addchar('ifcat': %trim($ifcat));
750bM            yajl_addchar('kcqty1old': %char($kcqty1old));
750bM            yajl_addchar('kcqty2': %char($kcqty2));
750bM            yajl_addchar('kcqty3':%char($kcqty3));
750bM            yajl_addchar('ifcaseovf': %trim($ifcaseovf));
750bM            yajl_addchar('ifodrslot': %trim($ifodrslot));
750bM            yajl_addchar('ifucicde': %trim($ifucicde));
750bM            yajl_addchar('ifrcvmth': %trim($ifrcvmth));
750bM            yajl_addchar('ifsltmth': %trim($ifsltmth));
750bM            yajl_addchar('ifbrdflg': %trim($ifbrdflg));
750bM            yajl_addchar('kidisp': %trim($kidisp));
750bM            yajl_addchar('kirptp': %trim($kirptp));
750bM            yajl_addchar('kiqty1': %char($kiqty1));
750bM            yajl_addchar('kiqty2': %char($kiqty2));
750bM            yajl_addchar('kiqty3': %char($kiqty3));
750bM            yajl_addchar('kcdisp': %trim($kcdisp));
750bM            yajl_addchar('kcqty1': %char($kcqty1));

             endsl;
           other;
             // can the item be deleted - need to protect if not
             alwdel = ' ';
             savever# = $itver#;
             exsr clr$item;
             $itver# = savever#;

             $itwhse  = aawhse;
             $ititem  = aaitem;
             $dricommand = '*ITEM';
             $drisubcmd  = '%VERIFYDEL';
             $drisys2upd = 'D';
             exsr  zzzdricop;
             if $drireturn <> '*OK';
               alwdel = 'N';
             endif;
750aA        savever# = $itver#;
750aA        exsr clr$item;
750aA        $itver# = savever#;

750aA        $itwhse  = aawhse;
750aA        $ititem  = aaitem;
750aA        $dricommand = '*ITEM';
750aA        $drisubcmd  = '%GETALL';
750aA        $drisys2upd = 'D';
750aA        exsr  zzzdricop;
      /end-free
     C                   call      'GETBASE'
     C                   parm      aawhse        $gwhse            3 0
     C                   parm      aaitem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
      /free

750bD        //pOutStr = '{'
750bD              //+    '"alwdel":"' + %trim(alwdel) + '",'
750bD              //+    '"ixdsc1":"' + %trim($ixdsc1) + '",'
750bD              //+    '"ixdsc2":"' + %trim($ixdsc2) + '",'
750bD              //+    '"baseitm":"' + %trim(#bitem) + '",'
750bD              //+    '"basetype":"' + %char(#bityp) + '"'
750bD              //+ '}';
750bM        yajl_addchar('alwdel': %trim(alwdel));
750bM        yajl_addchar('ixdsc1': %trim($ixdsc1));
750bM        yajl_addchar('ixdsc2': %trim($ixdsc2));
750bM        yajl_addchar('baseitm': %trim(#bitem));
750bM        yajl_addchar('basetype': %char(#bityp));
         endsl;

750bA    // Wrap up JSON string
750bA
750bA    yajl_endObj();                 // End JSON string
750bA    pOutStr = YAJL_copyBufStr();   // Copy JSON string into parameter
750bA    yajl_genClose();               // Close and cleanup JSON processing

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
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
         getclient(client: clientLoc);

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
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM' or
     C                             $dricommand = '*UCIINFO'
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
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      chk4err = *off
     C     enddricop     endsr
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

           when parmName = 'cmd';
             cmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'item';
             aaitem = %xlate(xlower: xupper: parmValue);


         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
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

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

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
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
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
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = errMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

