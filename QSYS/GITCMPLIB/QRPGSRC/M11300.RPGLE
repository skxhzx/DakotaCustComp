      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11300   Get transaction cw entry JSON info
     *  21 April 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/21/14  DAS  6.50
     *      - Created.
730a *    08/23/19  LMC  7.30a
     *      - Enh - UCI selection items will not allow the Weights
     *        to be Added/changed/Deleted.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flabel     if   e           k disk
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
     D  pOrd           s              7p 0
     D  pOsq           s              5p 0
     D  pItem          s             15
     D  pWsq           s              3p 0
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
730aAD selmth          s              1

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pTrn         Transaction number
     *      pLbl         Label number
     *      pOrd         Order number
     *      pOsq         Order seq#
     *      pItem        Item
     *      pWsq         Weight seq#
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
     C                   parm                    pOrd
     C                   parm                    pOsq
     C                   parm                    pItem
     C                   parm                    pWsq
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

730aA    chain (lbwhse: lbitem) itemfld;
730aA    if not %found(itemfld);
730aA      ifsltmth = '1';
730aA    else;
730aA      selmth = ifsltmth;
730aA    endif;

         exsr LabelStat;
         exsr LabelType;
         exsr GetHostStop;

        // Get any flag for weight

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = pWhse;
         $ocordu = *on;
         $ocord  = pOrd;
         $ocseq#u = *on;
         $ocseq# = pOSq;
         $ocitemu = *on;
         $ocitem = pItem;
         $ocsequ = *on;
         $ocseq  = pWSq;
         $octranu = *on;
         $octran = pTrn;
         $oclbl#u = *on;
         $oclbl# = pLbl;
         $dridata = $ordc;

         driOrdc('%GETFLGWGT': #prog: $drireturn:
                  $drimessage: $dridata);

         $ordc = $dridata;

         // Build JSON string to return

         pOutStr = '{'
                 +  '"wgtflg":"' + $ocfflg + '",'
                 +  '"wgttxt":"' + %trimr($drimessage) + '",'
                 +  '"lblsts":"' + %trimr(lblStat) + '",'
                 +  '"lbltyp":"' + %trimr(lblType) + '",'
730aA            +  '"selmth":"' + %trimr(selmth) + '",'
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
