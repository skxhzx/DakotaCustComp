      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OR737S2   Staging - Export returns as adjustments
     *  23 June, 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    06/23/15  RTR  7.00
     *      - Created using RN235S and OR736
     *      - Removed mod marks and deleted lines except for client code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic
EOPa *    10/11/18  RTR  EOPa
     *      - Revised pgm to break down UOM for adjustment
     *      - Revised pgm to handle -DZ special repack items
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
EOPaAfpiritem   if   e           k disk
     Fexpsadj2  o  a e           k disk

EOPaA*----------------------------------------------------------------
EOPaA*  Customer id
EOPaA*
EOPaA /COPY QCOPYSRC,ID#eop

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

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
     D forever         s               n
     D haveBatId       s               n
EOPaAD pos             s              8s 0
     D rtnCode         s             10
     D rtnMessage      s            200
     D stamp           s               z
     D stampUC         s               z

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
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

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
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
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

         if $pBatId <> *blanks;
            BatId = $pBatId;
            haveBatId = *on;
         else;
            BatId = *blanks;
            haveBatId = *off;
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

           // If no batch id yet, get one.
           if not haveBatId;
             exsr zzzGetBatId;
             if batId = *blank;
               leave;
             endif;
             haveBatId = *on;
             $pBatId = batId;
           endif;

           // Write adjustment record.
           exsr filie;

EOPaA      //  For Earl's, convert qtys
EOPaA      if client = EarlsOrganic;
EOPaA        exsr zzEOPconvert;
EOPaA      endif;

           write ierec;

           // Update customer return file with upload date and time.
           orudte = %dec(%date():*iso);
           orutim = %dec(%time():*iso);
           update orrec;

         enddo;

         // Pass back batch ID if new.
         $pBatId = batId;
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
     C                   eval      ieitem = oritem
     C                   eval      iedate = orrdte
     C                   eval      ietime = orrtim
     C                   eval      ieby = orrusr
     C                   eval      iewhdp = *blanks
     C                   eval      iedisp = *blanks
     C                   eval      iecwta = orcwtr
     C                   eval      ieqty1 = orqty1
     C                   eval      ieqty2 = orqty2
     C                   eval      ieqty3 = orqty3
     C                   eval      iecode = opreac
     C                   eval      iememo = orinv#

     C                   exsr      zzzGetStamps
     C                   eval      iebatid = BatId
     C                   eval      iestatus = 'R'
     C                   eval      ieststs = stamp
     C                   eval      iestsuc = stampuc
     C                   eval      ieaddts = stamp
     C                   eval      ieadduc = stampuc
     *
     C                   endsr

EOPaA*----------------------------------------------------------------
EOPaA*  zzEOPConvert   Earls - Convert qty for breakdown
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /free
EOPaA   begsr zzEOPConvert;
EOPaA
EOPaA     chain (orwhse: oritem) piritem;
EOPaA     if %found();
EOPaA       // Look for '-DZ' 2.5 DZ repack item;
EOPaA       pos = %scan('-DZ': ititem);
EOPaA       select;
EOPaA         when pos > 0;
EOPaA           ieitem = %subst(ititem: 1: pos-1);
EOPaA         when itum1 = 'D2';
EOPaA           ieqty1 = (ieqty1 * 2.5) + (ieqty2 / 2);
EOPaA           ieqty2 = 0;
EOPaA         when itflg1 = 'Y';
EOPaA           ieqty1 = (ieqty1 * itumq2) + ieqty2;
EOPaA           ieqty2 = 0;
EOPaA       endsl;
EOPaA     endif;
EOPaA
EOPaA   endsr; // zzEOPConvert
EOPaA /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPADJUST': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr
