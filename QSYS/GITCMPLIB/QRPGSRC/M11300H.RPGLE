      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11300H  Get transaction cw entry header JSON info
     *  22 April 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/22/14  DAS  6.50
     *      - Created.
730aA*    08/14/19  LMC  7.30a
     *      - Enh - Added logic to calculate high and low variance
     *        based on the ordered weight instead of the pick qty
     *        on pick to weight labels.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel     if   e           k disk
     Fordc1     if   e           k disk
405 AFoptions   if   e           k disk
     Fitemmsc   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.driordc
730aA /copy qcopysrc,p.umlabel

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDC
     D saveVer#        s                   like($ocver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pLbl           s              7p 0
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
     D cCmd            s             10    inz(' ')
     D cTrn            s              7p 0 inz(0)
     D chrOutStr       s            512
     D chrSessId       s             40
     D chrUser         s             10
     D chrRtid         s              5
     D dpcombo         s             20
     D lblNotFound     s               n
     D ttlCnt          s              5  0
     D ttlWgt          s             13  2
     D hvskp           s               n
     D ihrng           s             13  2
     D ihvar           s             13  2
     D ilrng           s             13  2
     D ilvar           s             13  2
     D lvskp           s               n
     D prg1c           s              4  3
     D prg2c           s              4  3
650aAD pieces          s                   like(lbqpck)
650aAD rngText         s             30

730aAD Pick2Wgt        s               n
730aAD Pick2lbs        s              6  2

     *----------------------------------------------------------------
410aA*  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
410 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPICW   -  Individual catch weight entry (Y,N).
530aA*    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
530aAD  opuci                 36     36
     D  optend               117    117

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D RteClsTrn       pr                  extpgm('RTECLSTRN')
     D  pCmd                          8
     D  pSessId                      40
     D  pUser                        10
     D  pCombo                       20
     D  pWhse                         3p 0
     D  pRtid                         5
     D  pTrn                          7p 0
     D  pOutStr                     512

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pLbl         Label number
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pLbl
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get label information

         chain (pLbl) label;
         if not %found(label);
           clear lbrec;
           lblNotFound = *on;
         else;
           lblNotFound = *off;
         endif;


730aA
730aA  monitor;
730aA    umWhse = lbwhse;
730aA    umlabel('*GET': umRtnCode: umRtnMsg:
730aA            umWhse: lblbl#:
730aA            umFlexPickFlag:
730aA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730aA  on-error;
730aA    umRtnCode = '*ERROR';
730aA  endmon;
730aA
730aA  if umRtnCode = '*OK';
730aA    select;
730aA      when umFlexPickFlag = 'P2W';
730aA        pick2lbs = lbswgt;
730aA      when umFlexPickFlag = 'PAQ';
730aA    endsl;
730aA  endif;
730aA

         // Start JSON string

         pOutStr = '{';

        // Add close flag.
        // '0' means not allowed to make changes.
        // Everything else is ignored.

        // If label status is 'C', set to '0'

        if lbstat = 'C';

          pOutStr = %trimr(pOutStr)
                  +  '"clsflg":"0",'
                  +  '"clstxt":"Label is closed",';

        // Otherwise, get transaction close value from RTECLSTRN.

        else;

          cTrn = lbtrn#;
          chrRtid = lbrte;
          chrOutStr = '';
          chrSessId  = '';
          chrUser = '';
          dpCombo = '';
          cCmd = '*CLSFLGS';

          RteClsTrn(cCmd:
                    chrSessId:
                    chrUser:
                    dpCombo:
                    pWhse:
                    chrRtid:
                    cTrn:
                    chrOutStr);

          pOutStr = %trimr(pOutStr)
                  + %trimr(chrOutStr) + ',';

        endif;

        // Add label count flag to string

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = pWhse;
         $octranu = *on;
         $octran = lbtrn#;
         $oclbl#u = *on;
         $oclbl# = pLbl;
         $dridata = $ordc;

         driOrdc('%GETLBLCNT': #prog: $drireturn:
                  $drimessage: $dridata);

         $ordc = $dridata;

         pOutStr = %trimr(pOutStr)
                 +  '"cntflg":"' + $ocfflg + '",'
                 +  '"cnttxt":"' + %trimr($drimessage) + '",';

        // Add label variance flag to string

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = pWhse;
         $octranu = *on;
         $octran = lbtrn#;
         $oclbl#u = *on;
         $oclbl# = pLbl;
         $dridata = $ordc;

         driOrdc('%GETLBLVAR': #prog: $drireturn:
                  $drimessage: $dridata);

         $ordc = $dridata;

         pOutStr = %trimr(pOutStr)
                 +  '"varflg":"' + $ocfflg + '",'
                 +  '"vartxt":"' + %trimr($drimessage) + '",';

         // Add item variances to string

         pieces = 1;
         exsr GetVariance;
         pOutStr = %trimr(pOutStr)
                 +  '"avgwgt":"' + %char(lbuwgt) + '",'
                 +  '"lowvar":"' + %char(ilrng) + '",'
                 +  '"hivar":"' + %char(ihrng) + '",'
                 +  '"rngtxt":"' + %trimr(rngText) + '",';

         // Add picked pieces to string

         pOutStr = %trimr(pOutStr)
                 +  '"pcs":"' + %char(lbqpck) + '",';

         // Add total count and weight to string

         exsr GetTotalWeight;
         pOutStr = %trimr(pOutStr)
                 +  '"ttlcnt":"' + %char(ttlCnt) + '",'
                 +  '"ttlwgt":"' + %char(ttlWgt) + '",';

         // Add total variances to string

         pieces = lbqpck;
         exsr GetVariance;
         pOutStr = %trimr(pOutStr)
                 +  '"lowttlvar":"' + %char(ilrng) + '",'
                 +  '"hittlvar":"' + %char(ihrng) + '",'
                 +  '"ttlrngtxt":"' + %trimr(rngText) + '"';


         // Close JSON string

         pOutStr = %trimr(pOutStr)
                 +  '}';

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
     *  GetVariance   Get variances (based on code from CW112)
     *----------------------------------------------------------------

      /free
       begsr GetVariance;

         // Get options

         chain (0: '*SYSTEM') options;
         if not %found(options);
           oprg1c = 0;
           oprg2c = 0;
         endif;

         // Get range

         lvskp = *off;
         hvskp = *off;
         prg1c = 0;
         prg2c = 0;
         ilvar = 0;
         ihvar = 0;

         // See if there is an item variance percentage

         chain (lbwhse: lbitem) itemmsc;

         if %found(itemmsc);

           if imrg1c > 0;
             prg1c = imrg1c / 100;
             if imrg1c = 99;
               lvskp = *on;
             endif;
           endif;

           if imrg2c > 0;
             prg2c = imrg2c / 100;
             if imrg2c = 99;
               hvskp = *on;
             endif;
           endif;

         endif;

         // If no item variance percentage, get system variance percentage.

         if prg1c = 0;
           if oprg1c > 0;
             prg1c = oprg1c / 100;
           endif;
         endif;

         if prg2c = 0;
           if oprg2c > 0;
             prg2c = oprg2c / 100;
           endif;
         endif;

         // Calculate weight variance

         if not lvskp;
           if prg1c = 0;
             lvskp = *on;
412 A      else;
730aA        if umFlexPickFlag = 'P2W';
730aA          ilvar = pick2lbs * prg1c;
730aA          ilrng = pick2lbs - ilvar;
730aA        else;
               ilvar = (pieces * lbuwgt) * prg1c;
               ilrng = (pieces * lbuwgt) - ilvar;
730aA        endif;
           endif;
         endif;

         if not hvskp;
           if prg2c = 0;
             hvskp = *on;
412 A      else;
730aA        if umFlexPickFlag = 'P2W';
730aA          ihvar = pick2lbs * prg2c;
730aA          ihrng = pick2lbs + ihvar;
730aA        else;
               ihvar = (pieces * lbuwgt) * prg2c;
               ihrng = (pieces * lbuwgt) + ihvar;
730aA        endif;
           endif;
         endif;

         // Create range text

         select;
           when lvskp and hvskp;
             ilrng = 0;
             ihrng = 0;
             rngText = '0 - Maximum';
           when lvskp;
             ilrng = 0;
             rngText = '0 - ' + %char(ihrng);
           when hvskp;
             ihrng = 0;
             rngText = %char(ilrng) + ' - Maximum';
           other;
             rngText = %char(ilrng) + ' - ' + %char(ihrng);
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetTotalWeight  Get total weight
     *----------------------------------------------------------------

      /free
       begsr GetTotalWeight;

         ttlCnt = 0;
         ttlWgt = 0;

         setll (pwhse: plbl) ordc1;

         dow forever = forever;

           reade (pwhse: plbl) ordc1;
           if %eof(ordc1);
             leave;
           endif;

           ttlCnt += 1;
           ttlWgt += occwgt;

         enddo;


       endsr;
      /end-free
