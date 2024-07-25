     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETITEMSUB   Check Allowed, Get, or Verify item substitute.
     *  07 Sep 2012
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*   09/07/12  RBD  6.40
     *     - Created.
     *
650 A*   04/21/13  MLB  6.50
     *     - Enh: Added client custom code support to program.
     *
650aA*   05/16/14  DAS  6.50a
     *     - Added command *GETLIMIT
     *
710aA*   12/19/17  RBD  7.10a
     *     - Added command *GETSTRING to build a string of sub items.
     *       Will populate the string with as many subs as space allows
     *       and pass it back.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*   04/21/13  MLB  CWD
     *     - Fix: Revised routine ZZVFYISUB to return error if no
     *       subs found on file for item.
CWDaA*   01/21/16  MLB  CWDa
     *     - Disabled CWD mod. Code was never activated.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fitemsub   if   e           k disk
     Foptions   if   e           k disk
     *
650 A*----------------------------------------------------------------
650 A*  Customer id
650 A*
650 AD @getcl          c                   const('GETCLIENT')
650 A*
CWD A /COPY QCOPYSRC,ID#Cashwa
     *----------------------------------------------------------------
     *  *GENPICK -  General picking.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N).
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *    OPGPK1  -  <Not Used / Available>
     *    OPGPK2  -  <Not Used / Available>
     *               task has been assigned. (Y/N)
     *    OPJITR  -  Create JIT Letdown or JIT Replenishment
     *                 0=None. No replenishments are created.
     *                 1=Letdowns are created during Truck Builder
     *                   Pick/Print processing.
     *                 2=Priority Replenishments are created during
     *                   Truck Builder Pick/Print processing.
     *                 3=JIT Letdowns created when transaction is
     *                   checked out.
     *                 4=JIT Priority Replenishments created when
     *                   transaction is checked out.
     *    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
     *    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
     *    OPRFLC  -  RF Pick Verify item with license (Y/N)
     *    OPRFSL  -  RF Pick Verify slot (Y/N)
     *    OPRBN1  -  Round robin printing compatable (Y/N)
     *    OPRBN2  -  Round robin Type ing compatable (Y/N)
     *               1=Off
     *               2=By route
     *               3=By transaction
     *    OPSUBT  -  Allow Customer Item Substitution (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
     D  opgpk1                10     10
     D  opgpk2                11     11
     D  opjitr                12     12
     D  oppset                13     13
     D  oprfuc                14     14
     D  oprflc                15     15
     D  opusf1                16     16
     D  oprfsl                17     17
     D  oprbn1                18     18
     D  oprbn2                19     19
     D  opsubt                20     20
     D  optend               117    117
     *----------------------------------------------------------------
     *  Work fields
     *
     D $pwhse          s              3  0
     D forever         s              1
     D kycust          s                   like(isucust)
     D kyisub          s                   like(isuisub)
     D kyitem          s                   like(isuitem)
710aAD byCust          s               n
710aAD itmLen          s              2  0
710aAD strLen          s              2  0
     *
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PCMD    -  *CHKALLOW - Check if subs are allowed.
     *                 *GET      - Get item substitute.
650aA*                 *GETLIMIT - Get item substitute, send back limit in $prtn.
     *                 *VERIFY   - Verify item substitute.
     *     $PWHSE   -  Warehouse.
     *     $PITEM   -  Item number.
     *     $PCUST   -  Customer.
     *     $PISUB   -  Item substitute.
     *
     *  Output parameters
     *
     *     $PRTN    - *OK    - Substitutes are allowed.
     *                *ERROR - Substitutes are not allowed.
650aA*                *CUST  - Sub item limited by customer (*GETLIMIT only)
650aA*                *ITEM  - Sub item limited by item (*GETLIMIT only)
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhse
     C                   parm                    $pitem           15
     C                   parm                    $pcust           11 0
     C                   parm                    $pisub           15
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
710aAC                   parm                    $pstr            72
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *   Initialize return parameters.
     *
     C                   eval      $prtn  = '*OK     '
     C                   exsr      zzinz2
     *
     *    Check to see if substitutes are allowed.
     C                   exsr      zzchkallow
     *    If subs are not allowed, return error.
     C                   if        $prtn   = '*ERROR  '
     C                   goto      bottom
     C                   endif
     *
     C                   select
     *
     *    Look for item substitute.
     C                   when      $pcmd   = '*GET      '
650aAC                             or $pcmd = '*GETLIMIT '
710aAC                             or $pcmd = '*GETSTRING'
     C                   exsr      zzgetisub
     *
     *    Verify item substitute.
     C                   when      $pcmd   = '*VERIFY   '
     C                   exsr      zzvfyisub
     *
     C                   endsl
     *
     C     bottom        tag
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
650 A*
650 A* Get client id.
650 A*
650 AC                   call      @getcl
650 AC                   parm                    client           10
650 AC                   parm                    clientloc        10
650 A*

     C                   eval      forever = *off
     *
     *  Define partial key for ITEMSUB file.
     *
     C     keyisubP      klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    kycust
     *
     *  Define partial key for ITEMSUB file.
     *
     C     keyisubP1     klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define full key for ITEMSUB file.
     *
     C     keyisubF      klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     C                   kfld                    kycust
     C                   kfld                    kyisub
     *
     *  Define key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKALLOW  Check to see if substitutes are allowed.
     *
     C     zzchkallow    begsr
     *
     C                   eval      $perm = *blanks
     *
     *  If subs are not allowed for this client, return an error.
     C                   if        opsubt <> 'Y'
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm   = 'Substitutes are not allowed'
     C                   goto      endchk
     C                   endif
     *
     *  If subs are not allowed for cust passed in, return an error.
     *
     C                   eval      kyitem = '*NOSUB         '
     C                   eval      kycust = $pcust
     C                   eval      kyisub = *blanks
     C     keyisubF      chain     itemsub
     C                   if        %found
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm   = 'Substitutes are not allowed '
     C                                     + 'for cust '
     C                                     + %Trim(%EditC(kycust:'Z'))
     C                   goto      endchk
     C                   endif
     *
     *  If subs are not allowed for customer 0, return an error.
     C                   eval      kyitem = $pitem
     C                   eval      kycust = 0
     C                   eval      kyisub = '*NOSUB         '
     C     keyisubF      chain     itemsub
     C                   if        %found
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm   = 'Substitutes are not allowed '
     C                                     + 'for item '
     C                                     + %trim($pitem)
     C                   goto      endchk
     C                   endif
     *
     *  If subs are not allowed for cust/item passed in, return an error.
     C                   eval      kyitem = $pitem
     C                   eval      kycust = $pcust
     C                   eval      kyisub = '*NOSUB         '
     C     keyisubF      chain     itemsub
     C                   if        %found
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm   = 'Subs are not allowed '
     C                                     + 'for cust '
     C                                     + %Trim(%EditC(kycust:'Z'))
     C                                     + ' item '
     C                                     + %trim($pitem)
     C                   goto      endchk
     C                   endif
     *
     C     endchk        endsr
     *----------------------------------------------------------------
     *
     *  ZZGETISUB  Look for item substitute and return it if you find
     *             one, otherwise, return a blank item sub.
     *
710aA*             Added logic to also create string of multiple subs
710aA*             when command is *GETSTRING.
     *
     C     zzgetisub     begsr
     *
     C                   eval      $pisub = *blanks
710aAC                   eval      byCust = *off
     *
     *  First, try to find an item sub for the customer passed in.
     C                   eval      kycust = $pcust
     C     keyisubP      setll     itemsub
     C     keyisubP      reade     itemsub
     C                   if        not %eof
     C                   eval      $pisub = isuisub
650aAC                   if        $pcmd = '*GETLIMIT'
650aAC                   eval      $prtn = '*CUST'
650aAC                   endif
710aAC                   if        $pcmd = '*GETSTRING'
710aAC                   eval      byCust = *on
710aAC                   eval      $pstr = %trim(isuisub)
710aAC                   exsr      bldStrOfSubs
710aAC                   endif
     C                   goto      endget
     C                   endif
     *
     *  If no item sub found for the customer passed in, try to
     *  find one for customer 0.
     C                   eval      kycust = 0
     C     keyisubP      setll     itemsub
     C     keyisubP      reade     itemsub
     C                   if        not %eof
     C                   eval      $pisub = isuisub
650aAC                   if        $pcmd = '*GETLIMIT'
650aAC                   eval      $prtn = '*ITEM'
650aAC                   endif
710aAC                   if        $pcmd = '*GETSTRING'
710aAC                   eval      $pstr = %trim(isuisub)
710aAC                   exsr      bldStrOfSubs
710aAC                   endif
     C                   goto      endget
     C                   endif
     *
     C     endget        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Retrieve General Pick options for warehouse.
     *
     C                   eval      opcode = '*GENPICK'
     C     keyop         chain     options
     C                   if        not %found
     C                   eval      opsubt = 'N'
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZVFYISUB  Verify item substitute.
     *
     C     zzvfyisub     begsr

     *  See if any subs exist for the item passed in, regardless of
     *  customer number.

     C     keyisubP1     setll     itemsub
     C                   do
     C     keyisubP1     reade     itemsub

     *  If no subs exist for the item passed in, any and all items
     *  are acceptable as the item sub.

     C                   if        %eof
CWDaDC*                  if        client = Cashwa
CWDaDC*                  eval      $prtn  = '*ERROR  '
CWDaDC*                  eval      $perm   = 'Sub item '
CWDaDC*                                    + %trim($pisub)
CWDaDC*                                    + ' not found for item '
CWDaDC*                                    + %trim($pitem)
CWDaDC*                  endif
     C                   goto      endvfy
     C                   endif

     *  At this point we know sub/s exist for the item passed in, now
     *  see if the item sub passed in is a sub for the item.
     C                   eval      kyitem = $pitem
     C                   eval      kycust = $pcust
     C                   eval      kyisub = $pisub
     C     keyisubF      chain     itemsub
     C                   if        not %found
     C                   eval      kycust = 0
     C     keyisubF      chain     itemsub
     C                   if        not %found
     C                   eval      $prtn = '*ERROR  '
     C                   eval      $perm   = 'Sub item '
     C                                     + %trim($pisub)
     C                                     + ' not found for item '
     C                                     + %trim($pitem)
     C                   goto      endvfy
     C                   endif
     C                   endif

     C                   enddo

     C     endvfy        endsr
710aA*----------------------------------------------------------------
710aA*
710aA*  BLDSTROFSUBS  Build string of sub items
710aA
      /free
       begsr bldStrOfSubs;

         // If you get here you've already loaded the first hit into
         // the string

         dow forever = forever;
           if byCust = *on;
             reade ($pWhse: $pItem: $pCust) itemsub;
           else;
             reade ($pWhse: $pItem) itemsub;
           endif;

           if %eof(itemsub);
             leavesr;
           endif;

           itmLen = %len(%trim(isuisub));
           strLen = %len(%trim($pstr));
           if strLen + itmLen + 1 <= 72;
             $pstr = %trim($pstr)
                   + ','
                   + %trim(isuisub);
           else;
             leavesr;
           endif;

         enddo;

       endsr;
      /end-free

