      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M20800     Branded Item Entry Validation
     *  23 May 2016
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700 A*    05/23/16  LMC  7.00
     *      - Created
710aA*    10/25/17  LMC  7.10a
     *      - Revised to all necessary fields to driitem
     *      - Found this mod on A&D, and brought back to Dev
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql


     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------

      /copy qcopysrc,p.driitem
      /COPY *libl/qcopysrc,c#item
     D savever#        s                   like($itver#)

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n
     D forever         s               n
     D blank15         s             15
     D rtnCode         s              8
     D rtnMessage      s             60

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pAction        s              1
     D  pWhse          s              3  0
     D  pBrand         s             10
     D  pOrgItem       s             15
     D  pBrdItem       s             15

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D ibrec         E Ds                  Extname(itembrd)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pAction     Action
     *      pWhse       Warehouse
     *      pBrand      Brand
     *      pOrgItem    Original Item
     *      pBrdItem    Sub Item
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pAction
     C                   parm                    pWhse
     C                   parm                    pBrand
     C                   parm                    pOrgItem
     C                   parm                    pBrdItem

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        // Convert fields to uppercase

        pBrand = %xlate(xlower: xupper: pBrand);
        pOrgItem = %xlate(xlower: xupper: pOrgItem);
        pBrdItem = %xlate(xlower: xupper: pBrdItem);


        Select;
          When pAction = 'V';
            // Validate original Item
            exsr GetOrgItem;

            // Validate branded Item
            exsr GetBrdItem;

            // Only one record for each brand is allowed
            exsr CheckBrand;
          When pAction = 'A';
            // Get the original item fields, then add with the Branded Item
            exsr GetAllOrgItem;
            if not error;
            exsr AddAllBrdItem;
            endif;
          When pAction = 'D';
            // Delete from all files with driitem
            exsr DeleteBrdItem;
        endsl;
        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddAllBrdItem     Add All fields for Brandedl Item
     *----------------------------------------------------------------

      /free
       begsr AddAllBrdItem;

         // Add all the fields for Branded Item

         $itWhse = pWhse;
         $ititem = pBrdItem;
         // turn on flags for all fields
         if  $itmitem <> ' ';
           $itmitemu = '1';
         endif;
         if $itcitem  <> ' ';
           $itcitemu = '1';
         endif;
         $ittypeu  = '1';
         if $itdesc <> ' ';
           $itdescu  = '1';
         endif;
         if $itstyp <> ' ';
           $itstypu  = '1';
         endif;
         if $itwhdp <> ' ';
           $itwhdpu  = '1';
         endif;
         if $itdesg <> ' ';
           $itdesgu  = '1';
         endif;
         if $itactv <> ' ';
           $itactvu  = '1';
         endif;
         if $itupc  <> ' ';
           $itupcu   = '1';
         endif;
         if $itbld <> ' ';
           $itbldu   = '1';
         endif;
         if $itven# <> 0;
           $itven#u  = '1';
         endif;
         if $itvit# <> ' ';
           $itvit#u  = '1';
         endif;
         if $itpdsc <> ' ';
           $itpdscu  = '1';
         endif;
         if $itum1 <> ' ';
           $itum1u   = '1';
         endif;
         if $itum2 <> ' ';
           $itum2u   = '1';
           $itum3u   = '1';
         endif;
         if $itumq2 <> 0;
           $itumq2u  = '1';
           $itumq3u  = '1';
         endif;
710aD    //if $itflg1 <> ' ';
710aM    if $itflg1 <> 'N';
           $itflg1u  = '1';
         endif;
710aD    //if $itflg2 <> ' ';
710aM    if $itflg2 <> 'N';
           $itflg2u  = '1';
         endif;
         if $itulen <> 0;
           $itulenu  = '1';
         endif;
         if $ituwdt <> 0;
           $ituwdtu  = '1';
         endif;
         if $ituhgt <> 0;
           $ituhgtu  = '1';
         endif;
         if $itcube <> 0;
           $itcubeu  = '1';
         endif;
         if $itswgt <> 0;
           $itswgtu  = '1';
         endif;
         if $itcwgt <> ' ';
           $itcwgtu  = '1';
         endif;
         if $itreor <> 0;
           $itreoru  = '1';
         endif;
         if $itrepl <> 0;
           $itreplu  = '1';
         endif;
         if $itrcvd <> 0;
           $itrcvdu  = '1';
         endif;
         if $itflgd <> ' ';
           $itflgdu  = '1';
         endif;
         if $itflgb <> ' ';
           $itflgbu  = '1';
         endif;
         if $itslif <> 0;
           $itslifu  = '1';
         endif;
         if $itnday <> 0;
           $itndayu  = '1';
         endif;
         $idsdefu  = '1';
         if $ixdsc1 <> ' ';
           $ixdsc1u  = '1';
         endif;
         if $ixdsc2 <> ' ';
           $ixdsc2u  = '1';
         endif;
         if $imtie <> 0;
           $imtieu   = '1';
         endif;
         if $imhigh <> 0;
           $imhighu  = '1';
         endif;
         if $immflg <> ' ';
           $immflgu  = '1';
         endif;
         if $imdday  <> 0;
           $imddayu  = '1';
         endif;
         if $imuday <> 0;
           $imudayu  = '1';
         endif;
         if $immday <> 0;
           $immdayu  = '1';
         endif;
         if $imwrnc <> ' ';
           $imwrncu  = '1';
         endif;
         if $imrg1c <> 0;
           $imrg1cu  = '1';
         endif;
         if $imrg2c <> 0;
           $imrg2cu  = '1';
         endif;
         if $imapck <> ' ';
           $imapcku  = '1';
         endif;
         if $imnrpk <> 0;
           $imnrpku  = '1';
         endif;
         if $imnslt <> ' ';
           $imnsltu  = '1';
         endif;
         if $imxdck <> ' ';
           $imxdcku  = '1';
         endif;
         if $imbnbr <> 0;
           $imbnbru  = '1';
         endif;
         if $imbnam <> ' ';
         $imbnamu  = '1';
         endif;
         if $imvnam <> ' ';
         $imvnamu  = '1';
         endif;
         //  set up with new brand
         $imbrnd  = pBrand;
         $imbrndu = '1';
         if $imlot <> ' ';
           $imlotu   = '1';
         endif;
         if $imltrk <> ' ';
           $imltrku  = '1';
         endif;
         if $imoday <> 0;
           $imodayu  = '1';
         endif;
         if $ifcat <> ' ';
           $ifcatu   = '1';
         endif;
650aA    if $kcqty1 <> 0;
           $kcqty1u  = '1';
         endif;
         if $kcqty2 <> 0;
           $kcqty2u  = '1';
         endif;
         if $kcqty3 <> 0;
           $kcqty3u  = '1';
         endif;
         if $ifcaseovf <> ' ';
           $ifcaseovfu = '1';
         endif;
         if $ifodrslot <> ' ';
           $ifodrslotu = '1';
         endif;
         if $ifucicde <> ' ';
           $ifucicdeu  = '1';
         endif;
         if $ifrcvmth <> ' ';
           $ifrcvmthu  = '1';
         endif;
         if $ifsltmth <> ' ';
           $ifsltmthu  = '1';
         endif;
         $ifbrdflg  = 'Y';
         $ifbrdflgu  = '1';
650aA    if $kidisp <> ' ';
650aA      $kidispu  = '1';
         endif;
650aA    if $kirptp <> ' ';
650aA      $kirptpu  = '1';
         endif;
650aA    if $kiqty1 <> 0;
650aA      $kiqty1u  = '1';
         endif;
650aA    if $kiqty2 <> 0;
650aA      $kiqty2u  = '1';
         endif;
650aA    if $kiqty3 <> 0;
650aA      $kiqty3u  = '1';
         endif;
650cA    if $kcdisp <> ' ';
650aA      $kcdispu  = '1';
         endif;

         $dridata = $item;
         $dridata2 = $item2;

         driItem('%ADD': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = 'Error: Added Branded Item '
                    + '(' + %trimr(pBrdItem) + ')';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CheckBrand     Only one record per Orginal Item/Brand allowed
     *----------------------------------------------------------------

      /free
       begsr CheckBrand;

         // The original item cannot already have the same Brand setup
           exec sql select * into :ibrec
              from itembrd
              where ibwhse = :pwhse
               and ibbrnd = :pbrand
               and ibitem = :pOrgItem;

           If sqlstt = sqlSuccess;
             error = *on;
             pMessage = 'Error: Brand is already setup for this item '
                      + '(' + %trimr(pOrgItem) + ')';
             leavesr;
           endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteBrdItem     Delete using DRIITEM
     *----------------------------------------------------------------

      /free
       begsr DeleteBrdItem;

         // Add all the fields for Branded Item

         $itWhse = pWhse;
         $ititem = pBrdItem;

         $dridata = $item;
         $dridata2 = $item2;

         driItem('%VERIFYDEL': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = $drimessage
                    + '(' + %trimr(pBrdItem) + ')';
           leavesr;
         endif;

         driItem('%DELETE': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = $drimessage
                    + '(' + %trimr(pBrdItem) + ')';
           leavesr;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetAllOrgItem     Get All fields for Orignial Item
     *----------------------------------------------------------------

      /free
       begsr GetAllOrgItem;

         // Get all the fields for Original Item

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = pWhse;
         $ititem = pOrgItem;
         $dridata = $item;
         $dridata2 = $item2;

         driItem('%GETALL': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = 'Error: Original item not found '
                    + '(' + %trimr(pOrgItem) + ')';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetBrdItem     Get Branded Item Info
     *----------------------------------------------------------------

      /free
       begsr GetBrdItem;

         // Get info for Branded Item - This should not exist

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = pWhse;
         $ititem = pBrdItem;
         $dridata = $item;
         $dridata2 = $item2;

         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn = '*OK';
           error = *on;
           pMessage = 'Error: Branded item already Exist '
                    + '(' + %trimr(pBrdItem) + ')';
           leavesr;
           error = *off;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  GetOrgItem     Get Orignial Item info
     *----------------------------------------------------------------

      /free
       begsr GetOrgItem;

         // Get info for Original Item

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = pWhse;
         $ititem = pOrgItem;
         $dridata = $item;
         $dridata2 = $item2;

         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;

         if $drireturn <> '*OK';
           error = *on;
           pMessage = 'Error: Original item not found '
                    + '(' + %trimr(pOrgItem) + ')';
           leavesr;
         endif;

         // The original item cannot be a branded item
           exec sql select * into :ibrec
              from itembrd
              where ibwhse = :pwhse
               and ibbitm = :pOrgItem;

           If sqlstt = sqlSuccess;
             error = *on;
             pMessage = 'Error: Original item can not be a branded item '
                      + '(' + %trimr(pOrgItem) + ')';
             leavesr;
           endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     O*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*----------------------------------------------------------------
