      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11400   Get transaction label maintenance JSON info
     *  05 December 2013
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    12/05/13  DAS  6.50
     *      - Created.
700a *    08/02/16  LMC  7.00a
     *      - Added code to setup Allowing substitutions
720a *    12/20/18  LMC  7.20a
     *      - Fix - Merge labels should not allow entering weights
730a *    08/23/19  LMC  7.30a
     *      - Enh - UCI selection items will not allow the label
     *        Pick qty to be changed.
750a *    01/07/22  LMC  7.50a
     *      - Revised to send back selection method. Used to control
     *        if we allow pick qty or weights to be updated. if
     *        Selection method = 2 - uci selection. We do not allow
     *        pick qty or weights to be updated in gui.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel     if   e           k disk
     Fpiritem   if   e           k disk
730aAFitemfld   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.driordc

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

500fA*----------------------------------------------------------------
500fA*  Customer id
500fA*----------------------------------------------------------------
500fA
500fA /copy qcopysrc,id#cheney

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

     D allowChg        s               n
     D allowChgText    s             50
     D client          s             10
     D clientloc       s             10
     D isOut           s               n
     D isNotStk        s               n
     D lblNotFound     s               n
     D maxQty          s              7  0
     D runner          s              1
     D runnerText      s             50
     D status          s              1
     D statusText      s             50
     D lblStat         s             10
     D lblType         s             20
     D hostStop        s              5  0
     D wgtflg          s              1
     D wgtflgText      s             60

700aAD  sOutStr        s            512    varying
700AAD  SubsAllowed    s            100
700AAD  pos            s              3  0
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D m11200          pr                  extpgm('M11200')
     D  pWhse                         3p 0
     D  pTrn                          7p 0
     D  pLbl                          7p 0
     D  pUser                        10
     D  pOutStr                     512    varying

700aAD i01800          pr                  extpgm('I01800')
700aAD  pWhse                         3p 0
700aAD  pOrd                          7p 0
700aAD  pSeq                          5p 0
700aAD  pItem                        15
700aAD  pUser                        10
700aAD  pOutStr                     512    varying

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

        // Get label record

         chain (pLbl) label;
         if not %found(label);
           clear lbrec;
           lblNotFound = *on;
         else;
           lblNotFound = *off;
         endif;

         // Initialize status flag.

         status = '4';
         statusText = 'No warnings or errors';

        // Set Label status

        Select;
          when lbstat = 'C';
            lblStat = 'Closed';
          other;
            lblStat = '';
        endsl;

        // Set Label type

        Select;
          when lbasl2 = 'OUT';
            lblType = 'OUT';
          when lbasl2 = '*';
            lblType = 'Not Stocked';
          when lbtype = 'O';
            lblType = 'Pick';
          when lbtype = 'M';
            lblType = 'Merge';
          when lbtype = 'B';
            lblType = 'Bulk';
          other;
            lblType = lbtype;
        endsl;

        // Get host stop

        exsr GetHostStop;

        // Set OUT flag

        if lbasl2 = 'OUT';
          isOut = *on;
        else;
          isOut = *off;
        endif;

        // Set Not Stocked flag

        if lbasl2 = '*';
          isNotStk = *on;
        else;
          isNotStk = *off;
        endif;

        // Check for warnings

        exsr ChkWarnings;

        // Check for hard errors

        exsr ChkErrors;

        // Get maximum qty allowed

        exsr GetMaxQty;

        // Get weight flags

        exsr GetWgtFlags;

        // See if allowed to change quantity

        exsr GetAllowChg;

700aA   // See if Substituion is allowed

700aA   exsr GetAllowSub;

        // Build JSON string to return
        // Note, sts must come first so it can be used for sorting

        pOutStr = '{'
700aA           // this addition of subs is not normally how we build
700aA           // the pOutStr. This allowed me to call I01800 and not
700aA           // have to duplicate the code into this program
700aA           +  %trimr(SubsAllowed) + ','
                +  '"sts":' + status + ','
                +  '"ststxt":"' + %trimr(statusText) + '",'
                +  '"alwchg":' + allowChg + ','
                +  '"alwtxt":"' + %trimr(allowChgText) + '",'
                +  '"run":"' + runner + '",'
                +  '"runtxt":"' + %trimr(runnerText) + '",'
                +  '"isOut":' + isOut + ','
                +  '"isNotStk":' + isNotStk + ','
                +  '"maxqty":"' + %char(maxQty) + '",'
                +  '"wgtflg":"' + wgtflg + '",'
                +  '"wgttxt":"' + %trimr(wgtflgText) + '",'
                +  '"lblsts":"' + %trimr(lblStat) + '",'
                +  '"lbltyp":"' + %trimr(lblType) + '",'
750aA           +  '"selmth":"' + %trimr(ifsltmth) + '",'
                +  '"hststp":"' + %char(hostStop) + '"';

        // Add custom client fields


        // Close JSON string

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
     *  GetAllowChg     See if allowed to change quantity
     *----------------------------------------------------------------

      /free
       begsr GetAllowChg;

         allowChg = *on;
         allowChgText = '';

730aA    chain (lbwhse: lbitem) itemfld;
730aA    if not %found(itemfld);
730aA      ifsltmth = '1';
730aA    endif;
         select;
           when lblNotFound;
             allowChg = *off;
             allowChgText = 'Cannot change qty '
                          + 'label record not found';
           when lbtype = 'M';
             allowChg = *off;
             allowChgText = 'Cannot change qty of '
                          + 'Merge label';
           when lbvrfy = 'I';
             allowChg = *off;
             allowChgText = 'Cannot change qty '
                          + 'because of flag ' + lbvrfy;
           when lbvrfy = 'F';
             allowChg = *off;
             allowChgText = 'Cannot change qty '
                          + 'because of flag ' + lbvrfy;
           when lbstat = 'C';
             allowChg = *off;
             allowChgText = 'Cannot change qty '
                          + 'because label is closed';
           when lbitem = '*PIRPICK';
             allowChg = *off;
             allowChgText = 'Cannot change qty '
                          + 'because PIRPICK item';
730aA      when ifsltmth = '2';
730aa        allowChg = *off;
730aA        allowChgText = 'Cannot change qty '
730aA                     + 'because UCI Selection';
         endsl;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  GetAllowSub     See if allowed to Substitute
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr GetAllowSub;

700aA    i01800(lbWhse :
700aA           lbord :
700aA           lbseq :
700aA           lbItem :
700aA           pUser :
700aA           sOutStr);

700aA    pos = %scan('}':sOutStr) - 2;
700aA    SubsAllowed = %subst(sOutStr:2:pos);
700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  ChkErrors       Check for hard errors
     *----------------------------------------------------------------

      /free
       begsr ChkErrors;

         runner = '';
         runnerText = '';

         // Check for hard errors

         select;
           when lblNotFound;
             status = '1';
             statusText = 'Label not found';
             leavesr;
           when lbvrfy = 'I';
             status = '1';
             statusText = 'Flag I';
             runner = 'I';
             runnerText = 'Flag I';
             leavesr;
           when lbvrfy = 'F';
             status = '1';
             statusText = 'Flag F';
             runner = 'F';
             runnerText = 'Flag F';
             leavesr;
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkWarnings     Check for warnings
     *----------------------------------------------------------------

      /free
       begsr ChkWarnings;
           //status = '2';
           //statusText = 'Warning needs override';
           //status = '3';
           //statusText = 'Warnings overridden';

       endsr;
      /end-free

     *----------------------------------------------------------------
520 A*  GetHostStop   Get Host Stop Number
     *----------------------------------------------------------------
520 A
      /free
       begsr GetHostStop;
      /end-free
520 A
520 AC                   call      'GETSTOP'
520 MC                   parm      '*ORDSTP '    $scmd             8
520 MC                   parm      lbwhse        $swhse            3 0
520 MC                   parm      lbrte         $srtid            5
520 MC                   parm      lbord         $sord             7 0
520 MC                   parm      0             $sstp             2 0
520 MC                   parm                    $sstop            5 0

     C                   if        $sstop > 0
     C                   eval      hostStop = $sstop
     C                   else
     C                   eval      hostStop = lbstop
     C                   endif

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetMaxQty       Get maximum allowed qty
     *----------------------------------------------------------------

      /free
       begsr GetMaxQty;

          maxQty = 0;

          select;
            when client = cheney;
              maxQty = lbqalc;
            other;
              if lbgrp1 = 'S' and lbgrp2 = 'S';
                maxQty = lbqalc;
              else;
                maxQty = lbqalc * 10;
              endif;
          endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetWgtFlags     Get weight flags
     *----------------------------------------------------------------

      /free
       begsr GetWgtFlags;

         wgtflg = '';
         wgtflgText = '';

         // Get Item record

         chain (lbwhse: lbitem) piritem;
         if not %found(piritem);
           leavesr;
         endif;

         // If item is not a catchweight item, leave.

         if itcwgt <> 'Y';
           leavesr;
         endif;

         // Item is a catchweight item, get flag.

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = lbwhse;
         $octranu = *on;
         $octran = lbtrn#;
         $oclbl#u = *on;
         $oclbl# = lblbl#;
         $dridata = $ordc;

         driOrdc('%GETFLGLBL': #prog: $drireturn:
                  $drimessage: $dridata);

         $ordc = $dridata;

         // If no flag return, set to '4'.
         // This will force weight link to be displayed.
         // Otherwise, pass on the flag that was returned.

720aA    // We don't want the weight link displayed on merge labels
720aA    // We will display for cheney.
720aA    Select;
720aA      When client = cheney;
             if $ocfflg = '';
               wgtflg = '4';
               wgtflgText = 'No errors or warnings';
             else;
               wgtflg = $ocfflg;
               wgtflgText = $drimessage;
             endif;
720aA      other;
720aA        if $ocfflg = '' and lbtype <> 'M';
720aA          wgtflg = '4';
720aA          $drimessage = 'No errors or warnings';
720aA        else;
720aA          wgtflg = $ocfflg;
720aa          wgtflgText = $drimessage;
720aA        endif;
720aA    endsl;

       endsr;
      /end-free
