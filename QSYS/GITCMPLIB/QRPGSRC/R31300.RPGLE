      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R31300      Label Detail function call
     *  02 January 2019
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    01/02/19  LMC  7.20
     *      - Created.
730 A*    09/10/19  KDE  7.30
     *      - Modified to return Employee Name
730aA*    10/08/19  KDE  7.30a
     *      - Modified to considerGlobal UPC pick setting
730bA*    12/02/19  KDE  7.30b
     *      - Modified to return column whether item has UPC for
     *        given UOM whether it is UPC selection or not.
740a *    01/22/20  LMC  7.40a
     *      - Enh: Adding logic to handle new selection method 6
     *        UPC Verification Normal UOM only.
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
     Flabel     if   e           k disk
730bAFlabeldo   if   e           k disk
     Fgloucicd  if   e           k disk
     Fvoexcp4   if   e           k disk
730aAfoptions   if   e           k disk
730aAfupc1      if   e           k disk
730bAfupc5      if   e           k disk
     f                                     rename(uprec:uprec5)
730 Afpiruser1  if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
      /copy qcopysrc,p.driitem
      /copy qcopysrc,p.driuci
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
730 Ad empnum          s              5  0
730bAd labelDoe        s              3
     d cmd             s             10
     d aawhse          s              3  0
     d aalabel         s              7  0
730BAd rfvoice         s              1
     d SelMethod       s                   like(gucdsc)
     D itemFound       s               n
     D error           s               n
     D ucicnt          s                   like(lbqpck)
730bAd upcExists       s              3
730bAd upcum           s              1
730bAd voExcp          s             50
730 Ad usrname         s             50
     D forever         s               n
     d scan            s              3

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n
     D driUciCalled    s               n

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

     D R31300          pr                  extpgm('R31300')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D R31300          pi
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

     d AAAClose        pr
     d GetItem         pr
730bAd buildExcp       pr
730bAd lbldo           pr
730bAd upcuom          pr

730aA*----------------------------------------------------------------
730aA*  *GENPICK -  General picking options.
730aA*----------------------------------------------------------------
730aA*
730aA* Fields
730aA*
730aA*    OPERPT  -  Print exception (short) error report (Y,N).
730aA*    OPELBL  -  Print exception (short) labels (Y,N)
730aA*    OPRFWC  -  Using RF will call (Y,N).
730aA*    OPNRSC  -  Number of pallet sections (1-9).
730aA*    OPHPWC  -  Host pick Will Call (Y/N).
730aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
730aA*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
730aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
730aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
730aA*    OPGPK1  -  <Not Used / Available>
730aA*    OPGPK2  -  <Not Used / Available>
730aA*               task has been assigned. (Y/N)
730aA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
730aA*                 0=None. No replenishments are created.
730aA*                 1=Letdowns are created during Truck Builder
730aA*                   Pick/Print processing.
730aA*                 2=Priority Replenishments are created during
730aA*                   Truck Builder Pick/Print processing.
730aA*                 3=JIT Letdowns created when transaction is
730aA*                   checked out.
730aA*                 4=JIT Priority Replenishments created when
730aA*                   transaction is checked out.
730aA*    OPPSET  -  Print separate set summary label for each pallet.
730aA*    OPRFUC  -  RF Pick Verify item with UPC.
730aA*    OPRFLC  -  RF Pick Verify item with license.
730aA*    OPUSF1  -  USF Option: Allow merge items for stop to be split.
730aA*               across truck pallets.
730aA*    OPRFSL  -  RF Pick Verify slot (Y/N)
730aA*    OPRBN1  -  Round robin printing compatable (Y/N)
730aA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
730aA*               1=Off
730aA*               2=By route
730aA*               3=By transaction
730aA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
730aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
730aA*    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
730aA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
730aA*    OPMAXA  -  USF Option: Staged route selection limit.
730aA*    OPDOCK  -  USF Option: Dock door prompt choice.
730aA*    OPRFQO  -  RF with Qty over.
730aA*    OPRFPM  -  RF Pick Method.
730aA*    OPRPLT  -  Print Pallet Label.
730aA*    OPRFUI  -  Scan individual UPC for each unit.
730aA*    OPRFZP  -  Zone Pickup.
730aA*    OPRFUW  -  Auto load weight if found in individual upc
730aA*
730aA* Data structure
730aA*
730aAD opdata          ds
730aAD  operpt                 1      1
730aAD  opelbl                 2      2
730aAD  oprfwc                 3      3
730aAD  opnrsc                 4      4  0
730aAD  ophpwc                 5      5
730aAD  opmrga                 6      6
730aAD  opplsq                 7      7
730aAD  opeadj                 8      8
730aAD  opnopk                 9      9
730aAD  opjitr                12     12
730aAD  oppset                13     13
730aAD  oprfuc                14     14
730aAD  oprflc                15     15
730aAD  opusf1                16     16
730aAD  oprfsl                17     17
730aAD  oprbn1                18     18
730aAD  oprbn2                19     19
730aAD  opsubt                20     20
730aAD  oprfqt                21     21
730aAD  oprfcs                22     22
730aAD  oppmta                23     23
730aAD  opmaxa                24     25  0
730aAD  opmaxab               24     25
730aAD  opdock                26     26
730aAD  oprfqo                27     29  0
730aAD  oprfpm                30     30
730aAD  oprplt                31     31
730aAD  oprfui                32     32
730aAD  oprfzp                33     33
730aAD  oprfuw                34     34
730aAD  optend               117    117

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

         // **** FOR TESTING ****
         debugAfter = *on;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         // Do processing

730bA    select;
730bA      when cmd = '*COMMAND';
             chain (aalabel) label;
             if %found(label);

730aA          chain (lbWhse:'*GENPICK') options;
730aA          if not %found(options);
730aA            oprfuc = 'N';
730aA          endif;

               getitem();
             endif;
             pOutStr = '{'
                     +    '"user":"' + pUser + '",'
                     +    '"combo":"' + dpCombo + '",'
                     +    '"cmd":"' + %trim(cmd) + '",'
                     +    '"SelMethod":"' + %trim(SelMethod) + '",'
                     +    '"Scan":"' + %trim(Scan) + '",'
730 A                +    '"label":"' + %char(aalabel) + '",'
730bA                +    '"labeldo":"' + %trim(labeldoe) + '",'
730bA                +    '"voexcp":"' + %trim(voexcp) + '",'
730bA                +    '"upcexists":"' + %trim(upcexists) + '",'
730 A                +    '"usrname":"' + %trim(usrname) + '"'
                     + '}';

730bA      when cmd = '*LBLDO';
730bA        lbldo();
730bA        // this is only returning single value for comparison purposes
730bA        pOutstr=labeldoe;

730bA      when cmd = '*UPCUOM';
730bA        upcuom();
730bA        // this is only returning single value for comparison purposes
730bA        pOutstr=upcexists;

730bA    endsl;

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

           when parmName = 'cmd';
             cmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'rfvoice';
             rfvoice = %xlate(xlower: xupper: parmValue);

           when parmName = 'upcuom';
             upcum = %xlate(xlower: xupper: parmValue);

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'label';
             if parmValue = '';
               parmValue = '0';
             endif;
             aalabel =  %dec(parmValue: 7: 0);

730 A      when parmName = 'empnum';
730 A        if parmValue = '';
730 A          parmValue = '0';
730 A        endif;
730 A        empnum =  %dec(parmValue: 5: 0);
730 A        chain (empnum) piruser1;
730 A        usrname = %trim(usfnam) + ' ' + %trim(uslnam);
730 A
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

     *----------------------------------------------------------------
     *  AAAClose     Close Called Programs.
     *----------------------------------------------------------------

     p AAAClose        b
     d AAAClose        pi

      /free

         if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
         endif;

         if driUCICalled;
           driuciinfo('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
720bA    endif;

      /end-free
     p AAAClose        e

     *----------------------------------------------------------------
     *  getItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi

      /free

         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itwhse = lbwhse;
         $ititem = lbitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         select;
           when %error;
             itemFound = *off;
             SelMethod = ' ';
           other;
730bA        // define return field to state whether item has
730bA        // UPC defined for item/uom regardless of whether
730bA        // item is defined for UPC selection or not
730bA        chain (lbwhse:lbitem:lbutyp:lbucod) upc5;
730bA        if %found(upc5);
730bA           upcExists='Yes';
730bA        else;
730bA           upcExists='No ';
730bA        endif;

730bA        // define return field whether labeldo records exist
730bA        // for given label
730bA        chain (lblbl#) labeldo;
730bA        if %found(labeldo);
730bA          labeldoe = 'Yes';
730bA        else;
730bA          labeldoe = 'No';
730bA        endif;

             itemFound = *on;
730aA        if $ifsltmth = '1' and oprfuc='Y';
730aA          // if global upc pick verification then
730aA          // show as UPC pick if upc exist
730aA          chain (lbwhse:lbitem) upc1;
730aA          if %found(upc1);
730aA            SelMethod = 'UPC Verification';
730aA          else;
730aA            selMethod = 'Standard';
730aA          endif;
730aA        else;
               // get description for selection method
               chain ('UCI3': $ifsltmth) gloucicd;
               if %found(gloucicd);
                 SelMethod = gucdsc;
               endif;
730aA        endif;
         endsl;
         // now see if scanning was done.
         Select;
730aD      //when $ifsltmth = '1';
730aM      when $ifsltmth = '1' and oprfuc<>'Y';
             scan = 'N/A';
           when $ifsltmth = '2';
             // uci scanning - check uciinfo file
             error = *off;
             scan = 'Yes';

             savever# = $uiver#;
             clear $uciinfo;
             clear $uciinfo2;
             $uiver# = savever#;

             // setup some data to pass to driuciinfo
             $uisellbl# = AALABEL;

             $uiwhse = lbwhse;
             $uiitem = lbitem;

             $dridata = $uciinfo;
             $dridata2 = $uciinfo2;
             driUCICalled = *on;
             driuciinfo('%CNT4LBL': $pprogram: $drireturn: $drimessage:
                      $dridata: $dridata2);
             // message will have the count
             ucicnt  = %dec($drimessage:5:0);
             if ucicnt = 0;
               scan = 'No';
             endif;

           when $ifsltmth = '3';
             scan = 'N/A';
           when $ifsltmth = '4'
730aA        or $ifsltmth = '1' and oprfuc='Y';
             // upc scanning - all uom - check voexcp
             setll (lbwhse: aalabel) voexcp4;
             scan = 'Yes';
730bA        voexcp = *blanks;
             dow forever = forever;
               reade (lbwhse: aalabel) voexcp4;
               if %eof(voexcp4);
                 leave;
               endif;
730bA          buildExcp();
               if sxerid = 'NOUPC' or
                  sxerid = 'BADUPC' or
                  sxerid = 'SKPUPC';
                 scan = 'No';
730bD            //leave;
               endif;
             enddo;
           when $ifsltmth = '5';
             if lbutyp <> 'N';
               // upc scanning - breakdown uom only - check voexcp
               setll (lbwhse: aalabel) voexcp4;
               scan = 'Yes';
730bA        voexcp = *blanks;
               dow forever = forever;
                 reade (lbwhse: aalabel) voexcp4;
                 if %eof(voexcp4);
                   leave;
                 endif;
730bA            buildExcp();
                 if sxerid = 'NOUPC' or
                    sxerid = 'BADUPC' or
                    sxerid = 'SKPUPC';
                   scan = 'No';
730bD              //leave;
                 endif;
               enddo;
             endif;
740aA      when $ifsltmth = '6';
740aA        if lbutyp =  'N';
740aA          // upc scanning - breakdown uom only - check voexcp
740aA          setll (lbwhse: aalabel) voexcp4;
740aA          scan = 'Yes';
740aA        voexcp = *blanks;
740aA          dow forever = forever;
740aA            reade (lbwhse: aalabel) voexcp4;
740aA            if %eof(voexcp4);
740aA              leave;
740aA            endif;
740aA            buildExcp();
740aA            if sxerid = 'NOUPC' or
740aA               sxerid = 'BADUPC' or
740aA               sxerid = 'SKPUPC';
740aA              scan = 'No';
740aA              //leave;
740aA            endif;
740aA          enddo;
740aA        endif;
         endsl;

      /end-free

     p GetItem         e

     *----------------------------------------------------------------
     *  buildExcp  -  Build fields with Voice/RF Exception codes
     *----------------------------------------------------------------

     p buildExcp       b
     d buildExcp       pi

      /free

        // ensure error code not already represented in list
        if %scan(%trim(sxerid):voexcp) <> 0;
        else;
          // Add error code to return string
          if voexcp=*blanks;
            voexcp=%trim(sxerid);
          else;
            voexcp = %trim(voexcp) + ',' + %trim(sxerid);
          endif;
        endif;

      /end-free

     p buildExcp       e

     *----------------------------------------------------------------
     *  lbldo  -  Labeldo record exist?
     *----------------------------------------------------------------

     p lbldo           b
     d lbldo           pi

      /free

             // If both was selected there is no need to read files
730bA        if rfvoice='B';
730bA          labeldoe='YES';
               return;
             endif;

730bA        chain (aalabel) label;
730bA        if %found(labeldo);
730bA          labeldoe = 'YES';
730bA        else;
730bA          labeldoe = 'NO';
730bA        endif;
730bA
730bA        select;
730bA          when rfvoice='Y';
730bA            if labeldoe<>'YES';
730bA              labeldoe='NO';
730bA            endif;
730bA          when rfvoice='N';
730bA            if labeldoe='NO';
730bA              labeldoe='YES';
730bA            else;
730bA              labeldoe='NO';
730bA            endif;
730bA        endsl;

      /end-free

     p lbldo           e

     *----------------------------------------------------------------
     *  upcuom -  UPC exists for Item UOM
     *----------------------------------------------------------------

     p upcuom          b
     d upcuom          pi

      /free

             // if both selected then no need to read files
730bA        if upcum='B';
730bA          upcExists='YES';
               return;
             endif;

             chain (aalabel) label;
             if %found(label);
730bA          chain (lbwhse:lbitem:lbutyp:lbucod) upc5;
730bA          if %found(upc5);
730bA             upcExists='YES';
730bA          else;
730bA             upcExists='NO';
730bA          endif;
730bA
730bA          select;
730bA            when upcum='Y';
730bA              if upcexists<>'YES';
730bA                upcexists='NO';
730bA              endif;
730bA            when upcum='N';
730bA              if upcexists='NO';
730bA                upcexists='YES';
730bA              else;
730bA                upcexists='NO';
730bA              endif;
730bA          endsl;
730bA        else;
730bA           upcExists='NO';
730bA        endif;

      /end-free

     p upcuom          e
