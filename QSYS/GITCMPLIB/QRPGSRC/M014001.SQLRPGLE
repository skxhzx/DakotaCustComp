750 A /copy *libl/qcopysrc,hspecs
750 AH Dftactgrp(*No)

750 A*----------------------------------------------------------------
750 A*  Binding Directories
750 A*----------------------------------------------------------------

750 AHbnddir('BFCBND')
     *----------------------------------------------------------------
     *
     *  M01400   Get open route JSON info
     *  03 April 2013
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    04/03/13  DAS  6.50
     *      - Created.
     *
700a *    07/21/15  DAS  7.00
     *      - Revised allowAlcBld to be 1 digit number, so it can
     *        take a value of 2 to allow closing without verification.
     *
730a *    04/02/19  DAS/LMC  7.30
     *      - Added TBType and TBProc
     *      - Added allowAlcBld checks to ensure truck is defined
     *        and TBProcess is defined.
     *
750  *    04/19/21  KDE      7.50
     *      - Enh:  Changed to use Generic Function call for M01400.
     *        Created M014001 as different version
     *
750a *    09/15/21  KDE      7.50a
     *      - Enh:  Moved Super Route position option in *SYSTEM
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
USFaA*    07/21/15  DAS  USFa
     *      - Revised to set allowAlcBld to 2 instead of 1 in order
     *        to bypass the verification screen.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtesum    if   e           k disk
730aAFrtehed    if   e           k disk
     Fordh3     if   e           k disk
     Fordh4     if   e           k disk    rename(ohrec:ohrec4)
620aAFordh10    if   e           k disk    prefix(oh_)
     Fordhm2    if   e           k disk
     Fcrossdk1  if   e           k disk
750 Afoptions   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chkiuse
730aA /copy qcopysrc,p.exrtehed
730aA /copy qcopysrc,p.getfeat

510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
510   /copy qcopysrc,id#packers
USFA  /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

750 A*----------------------------------------------------------------
750 A*  *SYSTEM  -  System options.
750 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
     *    OPSRTE  -  Allow Super Routes
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
750aDD* opsrte                43     43
750aMD  opsrte                46     46
     D  optend               117    117

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtId          s              5
     D  pRte           s              5
     D  pUser          s             10    varying
750 Ad  pDict          s             10    varying
750 Ad  pPgm           s             10    varying
750 Ad  pSessID        s             40    varying
750 AD  pSuper         s              5
750 Ad  pParmstr       s           1024    varying
     D  pOutStr        s           1024    varying
750 Ad  errmsg         s             99

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700aDD*allowAlcBld     s               n
700aMD allowAlcBld     s              1  0
750 AD allowOpnOrd     s              1  0
     D allowText       s             50
     D allowOtxt       s             50
     D client          s             10
     D clientloc       s             10
     D cube            s                   like(rsordc)
     D hasPrePick      s               n
     D inUse           s               n
     D isPrePick       s               n
     D iuCmd           s              8
     D iuRtn           s              8
     D iuFlag          s              1  0
     D iuSubFlag       s              1  0
     D iuText10        s             10
     D iuText30        s             30
     D openPrePick     s               n
     D pieces          s                   like(rsordp)
     D shipNbr         s             11
     D weight          s                   like(rsordw)
     D xdockPO         s                   like(cdpo)
730aAD TBProcess       s              1
730aAD TBText10        s             10
730aAD TBText30        s             30
730aAD $gfCmd          s              8
730aAD $gfFeature      s              1
730aAD $gfLight        s              1
730aAD $gfTBType       s              1
730aAD $gfWhse         s              3p 0
750 Ad superrte        s              5
750 Ad superrtid       s              5

     *----------------------------------------------------------------
     *  Misc Data Structure
     *----------------------------------------------------------------

     *  Shipment number from Miscellaneous field
     D                 ds
     D  hmmsc1                 1     40
     D  hmmshp                 4     14

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

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
750 A*    Now via parmStr from Generic Function call
     *      pWhse        Warehouse
     *      pRtId        Route Id
     *      pRte         Route
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pParmStr
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        // Get Super Route option information
750 A   chain (0: '*SYSTEM') options;
750 A   if not %found(options);
750 A      opsrte = 'N';
750 A   endif;

750 A   // Extract parameters from delimited string

750 A   ExtractParms();

750 A   // Get information

730aA   exsr GetRoute;
        exsr GetInUse;
        exsr GetCubeWgtPcs;
        exsr GetPrePick;
        exsr GetXDockPO;
730aA   exsr GetTBProcess;

        // See if allowed to Alloc/Bld based on information.

        select;
750 A     when rhtype = 'M';
730aA       allowAlcBld = 0;
730aA       allowText = 'Aloc & Bld not allowed '
730aA                 + 'for Super Route Merge routes';
730aA     when rhtruk = '';
730aA       allowAlcBld = 0;
730aA       allowText = 'Aloc & Bld not allowed - '
730aA                 + 'No truck assigned';
          when openPrePick;
700aD       //allowAlcBld = false;
700aM       allowAlcBld = 0;
            allowText = 'Aloc & Bld not allowed - '
                      + 'PrePick Route ('
                      + %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
                      + ') not Printed';
          when inUse;
700aD       //allowAlcBld = false;
700aM       allowAlcBld = 0;
            allowText = 'Allocate & Build not allowed - '
                      + 'Route In-Use';
750 D     //when $gfTBType = 'B' and TBProcess = ' ';
750 M     when $gfTBType = 'B' and (TBProcess = ' ' or TBProcess='U');
730aA       allowAlcBld = 0;
730aA       allowText = 'Allocate & Build not allowed - '
730aA                 + 'Set Process Method';
          other;
700aD       //allowAlcBld = true;
700aM       allowAlcBld = 1;
USFaA       if client = usfcorp;
USFaA         allowAlcBld = 2;
USFaA       endif;
            allowText = 'Allocate - Build';
        endsl;

750 A   // See if allowed to View Open Orders

750 A   if rhtype = 'M' and superrte <> *blanks;
750 A      allowOpnOrd = 0;
750 A      allowOtxt = 'You must view via Route Id ' + superrte;
750 A   else;
750 A      allowOtxt = 'View Orders';
750 A      allowOpnOrd = 1;
750 A   endif;

        // Build JSON string to return

        pOutStr = '{'
700aM           +  '"alwaloc":'   + %char(allowAlcBld) + ','
                +  '"alwtxt":"'   + %trimr(allowText) + '",'
750 A           +  '"rhtype":"'   + %trim(rhtype) + '",'
750 A           +  '"SUPERRTE":"'   + %trim(superrte) + '",'
750 A           +  '"SUPERRTID":"'   + %trim(superrtid) + '",'
750 A           +  '"alwopno":'   + %char(allowOpnOrd) + ','
750 A           +  '"alwotxt":"'   + %trimr(allowOTxt) + '",'
                +  '"cube":"'   + %trim(%editc(cube:'A')) + '",'
                +  '"wgt":"'   + %trim(%editc(weight:'A')) + '",'
                +  '"pcs":"'   + %trim(%editc(pieces:'A')) + '",'
                +  '"ispre":'   + isPrePick + ','
                +  '"haspre":'   + hasPrePick + ','
                +  '"opnpre":'   + openPrePick + ','
                +  '"iu":'   + inUse + ','
                +  '"iutxt":"'   + %trimr(iutext10) + '",'
730aA           +  '"TBType":"'   + $gfTBType + '",'
730aA           +  '"TBProc":"'   + TBProcess + '",'
                +  '"xpo":"'  + %trimr(xdockPO) + '"';

        // Add custom client fields

        if client = packers;
          exsr GetShipNbr;
          pOutStr = %trimr(pOutStr) + ','
                  +  '"shnbr":"'  + %trimr(shipNbr) + '"';
        endif;

        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetCubeWgtPcs   Get cube, weight and pieces
     *----------------------------------------------------------------

      /free
       begsr GetCubeWgtPcs;

         cube = 0;
         weight = 0;
         pieces = 0;

         setll (pWhse: pRtId) rtesum;

         dow forever = forever;

           reade (pWhse: pRtId) rtesum;
           if %eof(rtesum);
             leave;
           endif;

           cube   += rsordc;
           weight += rsordw;
           pieces += rsordp;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetInUse   Get In-Use flag
     *----------------------------------------------------------------

      /free
       begsr GetInUse;

         iuCmd = '*GETIUSE';

         monitor;
           ChkIUse(iuCmd: pwhse: pRtId: iuRtn:
                   iuFlag: iuSubFlag: iuText10: iuText30);
         on-error;
           iuRtn = '*ERROR';
           iuText10 = 'GETIUSE NF';
           iuText30 = 'Error calling GETIUSE program';
         endmon;

        if iuRtn = '*ERROR' or iuFlag <> 0;
          inUse = true;
        else;
          inUse = false;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPrePick   Get PrePick info
     *----------------------------------------------------------------

      /free
       begsr GetPrePick;

         isPrePick = false;
         hasPrePick = false;
         openPrePick = false;

         setll (pWhse: pRtId) ordh4;

         dow forever = forever;

           reade (pWhse: pRtId) ordh4;
           if %eof(ordh4);
             leavesr;
           endif;

           // Get out if sent route is a PrePick route

           if %subst(ohmisc:17:1) = 'Y';
             isPrePick = true;
             leavesr;
           endif;

           // Look for PrePick items on route

           setll (ohwhse: ohcord) ordh10;

           dow forever = forever;

             reade (ohwhse: ohcord) ordh10;
             if %eof(ordh10);
               leave;
             endif;

             if %subst(oh_ohmisc:17:1) <> 'Y';
               iter;
             endif;

             // Item associated with a PrePick order

             hasPrePick = true;

             // See if PrePick route is only Open or Built.

             if prte = oh_rhrte and oh_rhstat < '4';
               openPrePick = true;
               leavesr;
             endif;

           enddo;

         enddo;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  GetRoute     Get RTEHED record
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr GetRoute;

750 A    superrte = *blanks;
750 A    superrtid = *blanks;
         chain (pWhse: pRtId) rtehed;
         if not %found(rtehed);
           clear rhrec;
750 A    else;
750 A      // if Super Route Merge Route then see if
750 A      // assigned Super Route and pass down if so
750 A      exec sql select srsrtid,srsrte into :superrtid, :superrte
750 A                  from srrte
750 A             where srwhse=:pwhse and srmrtid=:pRtid;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetShipNbr   Get Packers shipment number
     *----------------------------------------------------------------

      /free
       begsr GetShipNbr;

600nA    shipNbr = '';

         chain (pWhse: pRtId) ordhm2;
         if %found(ordhm2);
           shipNbr = hmmshp;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetXDockPO   Get crossdock PO
     *----------------------------------------------------------------

      /free
       begsr GetXDockPO;

600nA    xdockPO = '';

         setll (pWhse: pRtId) ordh3;

         dow forever = forever;

           reade (pWhse: pRtId) ordh3;
           if %eof(ordh3);
             leave;
           endif;

           chain (ohwhse: ohord) crossdk1;
           if %found(crossdk1);
             xdockPO = cdpo;
             leave;
           endif;

         enddo;

       endsr;
      /end-free
730aA*----------------------------------------------------------------
730aA*  GetTBProcess Get TruckBuilder Process flag
730aA*----------------------------------------------------------------

      /free
       begsr GetTBProcess;

         // Get Truck Builder Process Feature
         //   S=Standard, E=Advanced/Enhanced, B=Both

         monitor;
           $gfCmd = '*GET';
           $gfWhse = pWhse;
           GetFeat ($gfCmd: $gfwhse: $gfFeature: $gfLight: $gfTBType);
         on-error;
           // Default to Standard
           $gfTBType = 'S';
           return;
         endmon;

         TBProcess = $gfTBType;

750 A    // For Super Routes force Enhanced
750 A    if $gfTBType <> 'E' and %subst(rhrte:1:3) = '#SR';
750 A      $gfTBType = 'E';
750 A      TBProcess = $gfTBType;
750 A    endif;

         // For Both, see if TBProcess is defined for Route.
         // If not, cannot Allocate

         If $gfTBType = 'B';
           monitor;
             exWhse = pWhse;
             EXRTEHED('*GET': exRtnCode: exRtnMsg:
                      exWhse: pRtId: TBProcess);
           on-error;
             exRtnCode = '*ERROR';
             TBProcess = '';
             TBText10 = 'EXRTEHED NF';
             TBText30 = 'Error calling EXRTEHED program';
           endmon;
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

           when parmName = 'RTID';
             pRtid = %trim(parmValue);

           when parmName = 'RTE';
             pRte = %trim(parmValue);

           when parmName = 'WHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

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
