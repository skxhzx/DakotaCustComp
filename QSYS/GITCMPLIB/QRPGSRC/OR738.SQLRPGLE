      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OR738     FTP Export Returns as Adjustments - Signed
     *  25 August, 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700a *    06/23/15  RTR  7.00a
     *      - Created using OR737S
710a *    02/15/17  RTR  7.10a
     *      - Fix: Mispicks needed to send back the corr item not the
     *        return item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    06/23/15  RTR  HMW
     *      - Revised pgm for c/wgt items with wgt <> 0 and qty <> 0,
     *        write out 2 rcds: 1 rcd with qty only and 1 rcd with wgt
     *        only.
     *
     *----------------------------------------------------------------
     *  Notes -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forrtn4    uf   e           k disk
     Fexpfadjs  o  a e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

HMW A*----------------------------------------------------------------
HMW A*  Customer id
HMW A*
HMW A /copy qcopysrc,id#hmwagne
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $pwhse          s              3  0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200
     D batId           s             11
     D cwgt            S                   like(orcwtr)
     D forever         s               n
     D haveBatId       s               n
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z
HMW AD svcwta          S                   like(iecwta)

     D currtimestamp   s               z
     D zeroUploadDate  s              8s 0

     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  *RETURNS -  Customer Returns options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRQCH  -  Allow changes to return quantity. (Y,N).
     *    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
     *    OPRFLB  -  Force return label entry. (Y/N)
     *    OPREXQ  -  Export Quick returns.(Y/N)
     *    OPRULB  -  Use label for putaway.(Y/N)
     *    OPREAD  -  Export as adjustments. (Y/N)
     *    OPREAC  -  Adjustment code to use.
     *
     * Data structure
     *
     D oprdta          ds
     D  oprqch                 1      1
     D  oprqec                 2      2
     D  oprflb                 3      3
     D  oprexq                 4      4
     D  oprulb                 5      5
     D  opread                 6      6
     D  opreac                 7      8
     D  oprend               117    117
     D  oprdata                1    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *      $pReturn  - Sequence number
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse3A

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     C                   eval      *inlr = *on
      /free
        // Get options record for returns.
        exec sql select opdata into :oprdata from options
                  where opwhse = :$pwhse
                    and opcode = '*RETURNS';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *
     *  Add customer returns to export file.
     *
      /free
         // If option flag not set to send as adjustments, exit now.
         if opread <> 'Y';
           return;
         endif;

         setll ($pWhse: zeroUploadDate) orrtn4;

         dow forever = forever;

           reade ($pWhse: zeroUploadDate) orrtn4;
           if %eof(orrtn4);
             leave;
           endif;

           // if impact inventory = 'N', skip record.
           if oriinv <> 'Y';
             iter;
           endif;

           // Write adjustment record.
           exsr filie;

HMW A      // For HMWagner, write first rec with qty, then one with weight
HMW A      if client = HMWagner
HMW A       and iecwta <> '       .00'
HMW A       and (ieqty1 <> '    0 ' or
HMW A            ieqty2 <> '    0 ' or
HMW A            ieqty3 <> '    0 ');
HMW A        svcwta = iecwta;
HMW A        iecwta = '       .00';
HMW A        write ierec;
HMW A        ieqty1 = '    0 ';
HMW A        ieqty2 = '    0 ';
HMW A        ieqty3 = '    0 ';
HMW A        iecwta = svcwta;
HMW A      endif;
HMW A
           write ierec;

           // Update customer return file with upload date and time.
           orudte = %dec(%date():*iso);
           orutim = %dec(%time():*iso);
           update orrec;

         enddo;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILIE    Fill export fields.
     *
     C     filie         begsr
     *
     *  Initialize record
     *
     C                   clear                   ierec
     *
     *  Move fields from item adjustment file to export file.
     *
     C                   eval      iewhse = orwhse
710aAC                   if        orcitm <> *blanks
710aAC                   eval      ieitem = orcitm
710aAC                   else
     C                   eval      ieitem = oritem
710aAC                   endif
     C                   eval      iedate = orrdte
     C                   eval      ietime = orrtim
     C                   eval      ieby = orrusr
     C                   eval      iewhdp = *blanks
     C                   eval      iedisp = *blanks

     C                   if        orcwtr >= 0
     C                   eval      iecwta = %editc(orcwtr:'X')
     C                   else
     C                   eval      cwgt = %abs(orcwtr)
     C                   eval      iecwta = %editc(cwgt:'X') + '-'
     C                   endif

     C                   eval      ieqty1 = %editc(orqty1:'L')
     C                   eval      ieqty2 = %editc(orqty2:'L')
     C                   eval      ieqty3 = %editc(orqty3:'L')
     C                   eval      iecode = opreac
     C                   eval      iememo = orinv#

     C                   endsr

