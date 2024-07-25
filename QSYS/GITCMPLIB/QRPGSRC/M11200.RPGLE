      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11200   Get transaction cw label JSON info
     *  21 April 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/21/14  DAS  6.50
     *      - Created.
710a *    05/15/17  LMC  7.10a
     *      - Revised LabelType to set a label that is a Merge and OUT
     *        to show text 'Merge/OUT'.
     *        There was some confusion as to why the weights were set
     *        to green.
710b *    05/17/17  LMC  7.10b
     *      - Revised to send back a blank in $ocfflg if the label is
     *        a merge label. This allows us to not have to change the
     *        GUI program. if the field comes back as blank the weight
     *        link is not displayed.
     *        Added code if the client is cheney we will not execute
     *        this logic.
740a *    09/16/20  LMC  7.40a
     *      - Revised to resetlblf if while getting the flags we get
     *        an error code 01,02 or 03 on the label.
     *        This is a timing issue, where people are going into
     *        the transaction to close, before picking is completed.
     *        This shows up when client are heavy uci selection.
     *        The weight records are written to ordc, before the label
     *        pick qty is updated. So the potential is the two files
     *        will be out of sync.
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
750aAFitemfld   if   e           k disk

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

710bA*----------------------------------------------------------------
710bA*  Customer id
710bA*----------------------------------------------------------------
710bA
710ba /copy qcopysrc,id#cheney
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pTrn           s              7p 0
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
     D lblNotFound     s               n
     D lblStat         s             10
     D lblType         s             20
     D hostStop        s              5  0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pTrn         Transaction number
     *      pLbl         Label number
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pTrn
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

         exsr LabelStat;
         exsr LabelType;
         exsr GetHostStop;
750aA    exsr GetSelmth;

        // Get any weight flag for label

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = pWhse;
         $octranu = *on;
         $octran = pTrn;
         $oclbl#u = *on;
         $oclbl# = pLbl;
         $dridata = $ordc;

         driOrdc('%GETFLGLBL': #prog: $drireturn:
                  $drimessage: $dridata);

         $ordc = $dridata;

740aA    // if we come back with a label error with 01/02/03
740aA    // weights, we need to reset the label, and get the flag again
740aA    if $ocfflg = '1' and  ($ocfcod = '03' or
740aA                            $ocfcod = '02' or
740aA                            $ocfcod = '01');
740aA    savever# = $ocver#;
740aA    clear $ordc;
740aA    $ocver# = savever#;

740aA    $ocwhseu = *on;
740aA    $ocwhse = pWhse;
740aA    $octranu = *on;
740aA    $octran = pTrn;
740aA    $oclbl#u = *on;
740aA    $oclbl# = pLbl;
740aA    $ocitem = lbitem;
740aA    $ocitemu  = *on;
740aA    $dridata = $ordc;

740aA    driOrdc('%RESETLBLF': #prog: $drireturn:
740aA             $drimessage: $dridata);
740aA    driOrdc('%GETFLGLBL': #prog: $drireturn:
740aA             $drimessage: $dridata);
740aA    $ordc = $dridata;
740aA    endif;

         // If no flag return, set to '4'.
         // This will force weight link to be displayed.

710bA    // We don't want the weight link displayed on merge labels
710bA    // We will display for cheney.
710bA    Select;
710bA      When client = cheney;
             if $ocfflg = '';
               $ocfflg = '4';
               $drimessage = 'No errors or warnings';
             endif;
710bA      other;
710bA        if $ocfflg = '' and lbtype <> 'M';
710bA          $ocfflg = '4';
710bA          $drimessage = 'No errors or warnings';
710bA        endif;
710bA    endsl;

         // Build JSON string to return

         pOutStr = '{'
                 +  '"wgtflg":"' + $ocfflg + '",'
                 +  '"wgttxt":"' + %trimr($drimessage) + '",'
                 +  '"lblsts":"' + %trimr(lblStat) + '",'
                 +  '"lbltyp":"' + %trimr(lblType) + '",'
750aA            +  '"selmth":"' + %trimr(ifsltmth) + '",'
                 +  '"hststp":"' + %char(hostStop) + '"'
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
     *  LabelStat   Put label status into words
     *----------------------------------------------------------------

      /free
       begsr LabelStat;

         Select;
           when lbstat = 'C';
             lblStat = 'Closed';
           other;
             lblStat = '';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  LabelType   Put label type into words
     *----------------------------------------------------------------

      /free
       begsr LabelType;

         Select;
710aA      when lbtype = 'M' and lbasl2 = 'OUT';
710aA        lblType = 'Merge/OUT';
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

       endsr;
      /end-free

     *----------------------------------------------------------------
520 A*  ZZFGTS   Get Host Stop Number
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
750aA*----------------------------------------------------------------
750aA*  GETSELMTH  Get item selection method
750aA*----------------------------------------------------------------
750aA
750aA /free
750aA  begsr GetSelMth;
750aA    chain (lbwhse: lbitem) itemfld;
750aA    if not %found(itemfld);
750aA      ifsltmth = '1';
750aA    endif;
750aA
750aA  endsr;
750aA /end-free
