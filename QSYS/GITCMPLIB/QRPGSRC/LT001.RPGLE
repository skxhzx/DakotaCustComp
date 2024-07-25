      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT001       Sync LICACTIVE with slots
     *  22 February 2009
     *  Dave Sommerville
     *
600 A*    02/22/09  DAS  6.00   P#00045
     *      - Created
     *      - Replace old LT001 that worked with LICHIST.
600aA*    08/24/09  MLB  6.00a  P#00045
     *      - Enh: Added new action code, HQ to indicate
     *        updates coming from HQ121.
     *
640 A*    05/02/11  MLB  6.40
     *      - Fix: Added %parms if stmt around $pdummy stmt.
770aA*    05/24/23  LM/RH 7.70a
     *      - Fix: Defailt $saToCode = 'S' we only work with slots
     *        should not be blank.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.drislot

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driSlotCalled   s               n

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pAction -  FIX   Fix
600aA*                  HQ    Compute pick slot qty from Host W/H Qty
     *                  SI    Slot import
     *                  SU    Start up
     *
     *      $pWhse   -  Warehouse
     *      $pWhdp   -  Department (optional)
     *      $pDisp   -  Slot display (optional)
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pAction          3
     C                   parm                    $pWhse            3 0
     C                   parm                    $pWhdp            5
     C                   parm                    $pDisp           12
     C                   parm                    $pDummy           1

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         // Ensure program was called from CL program, not from command.
640 A    if %parms >= 5;
         $pDummy = $pDummy;
640 A    endif;

         error = *off;

         // Get employee #

         getUser(#curruser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

         // Call drislot

         savever# = $slver#;
         clear $slot;
         clear $slot2;
         $slver# = savever#;

         $slwhseu = *on;
         $slwhse = $pWhse;

         if %parms >= 3;
           $slwhdpu = *on;
           $slwhdp = $pWhdp;
         endif;

         if %parms >= 4;
           $sldispu = *on;
           $sldisp = $pDisp;
         endif;

         $saemp#u = *on;
         $saemp# = e$emp#;
         $saActionU = *on;
         $saAction = $pAction;

770aA    $saToCodeU = *on;
770aA    $satoCode = 'S';

         $saToLcnsU = *on;
         select;
           when $pAction = 'FIX';
             $saToLcns = '*FX';
600aA      when $pAction = 'HQ ';
600aA        $saToLcns = '*HQ';
           when $pAction = 'SI ';
             $saToLcns = '*SI';
           when $pAction = 'SU ';
             $saToLcns = '*SU';
           other;
             $saToLcns = '*FX';
         endsl;

         $dridata = $slot;
         $dridata2 = $slot2;

         driSlot('%SYNCLCNS': $pprogram: $drireturn: $drimessage:
                              $dridata: $dridata2);

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

         driSlot('%CLOSE': $pprogram: $drireturn: $drimessage:
                           $dridata: $dridata2);

         *inlr = *on;
         return;

      /end-free
