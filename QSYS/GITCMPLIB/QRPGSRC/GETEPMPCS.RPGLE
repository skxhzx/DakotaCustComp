      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETEPMPCS Calculate EPM Pieces for PIRTRAND
     *  23 June 2014
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    07/23/14  LMC  6.50
     *      - Created
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    07/23/14  LMC  GFS
     *      - Revised pgm to convert pieces from pounds.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpiritem   if   e           k disk
     Flabel90   if   e           k disk
     Fitemext1  if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
GFS   /copy qcopysrc,id#GFS
     *
     *----------------------------------------------------------------
     *  Constants
     *
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3s 0
     D $ptrn           s              7  0
     D $pqtyinGrs      s              5  0
     D $pqtyinPcs      s              5  0
     D $pEPMGrs        s              5  0
     D $pEPMPcs        s              5  0
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PTRN   Transaction Number
     *      $PQTYIN Quantity sent in for conversion
     *
     *    Returned Parameters
     *      $PEPMPCS EPM Pieces.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $ptrn
     C                   parm                    $pqtyinGrs
     C                   parm                    $pqtyinPcs
     C                   parm                    $pEPMGrs
     C                   parm                    $pEPMPcs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
      /free
         *inlr = *on;
         select;
GFS A      when client = Getfresh;
GFS A        exsr chk4convert;
           other;
             $pEPMGrs = $pqtyinGrs;
             $pEPMPcs = $pqtyinPcs;
             return;
         endsl;
      /end-free

     *
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CHK4CONVERT   Determine if Item needs to have pounds converted
     *                into quantity.
     *
     C     chk4convert   begsr
      /free
         chain ($pwhse: $ptrn) label90;
         if not %found(label90);
           $pEPMGrs = $pqtyinGrs;
           $pEPMPcs = $pqtyinPcs;
           return;
         endif;

         // Only converting LB uom from label
         if lbucod <> 'LB';
           $pEPMGrs = $pqtyinGrs;
           $pEPMPcs = $pqtyinPcs;
           return;
         endif;

         // get item information
         chain ($pwhse: lbitem) piritem;
         if not %found(piritem);
           $pEPMGrs = $pqtyinGrs;
           $pEPMPcs = $pqtyinPcs;
           return;
         endif;

         select;
           when itcwgt = 'Y'
            and lbuwgt > 0;
             // convert transaction pounds into transaction quantity
             exsr zzcvtlbs2qty;
           other;
             $pEPMGrs = $pqtyinGrs;
             $pEPMPcs = $pqtyinPcs;
         endsl;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCVTLBS2QTY  Convert transaction pounds into quantity.
     *                Items with ITCWGT = Y.
     *
     C     zzcvtlbs2qty  begsr
     *
     *
     *       Convert transaction "pounds" into EPM "quantity".
     C                   if        $pqtyinGrs > 0 and lbuwgt > 0
     C                   eval (h)  $pEPMGrs = $pqtyinGrs / lbuwgt
     C                   if        $pEPMGrs = 0
     C                   eval      $pEPMGrs = 1
     C                   endif
     C                   endif

     C                   if        $pqtyinPcs > 0 and lbuwgt > 0
     C                   eval (h)  $pEPMPcs = $pqtyinPCS / lbuwgt
     C                   if        $pEPMPcs = 0
     C                   eval      $pEPMPcs = 1
     C                   endif
     C                   endif

     C                   endsr
