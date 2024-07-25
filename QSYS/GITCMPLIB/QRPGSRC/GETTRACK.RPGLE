      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRACK   Get tracking values
     *  28 August 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*   08/28/04  DAS  5.00
     *     - Created.
     *
500 A*   01/09/05  DAS  5.00a
     *     - License tracking options changed. No longer have a
     *       general tracking option.
     *     - No 4.17 programs using this program and it has not been
     *       released to any clients yet. Therefore, for readability,
     *       replaced all code instead of marking it.
     *
500bA*   01/13/05  DAS  5.00b
     *     - Renamed putaway split option, OPSPLT, to OPPSPL.
     *     - Added transfer/replenishment split option OPTSPL.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
720aA*    06/27/16  LMC  7.20a
     *      - UCI Tracking - New Item tracking level 'U'
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *LICENSE  -  License Plate Tracking options
     *----------------------------------------------------------------
     *
     * Tracking Levels
     *
     *   Low     -  User is not asked for any extra info.
     *              All tracking is done in the background.
     *
     *   Medium  -  User may be asked to apply new license plate to
     *              a split quantity.
     *              Applying new license plate is optional.
     *
     *   High    -  User may be asked to apply new license plate to
     *              a split quantity.
     *              Applying new license plate is manditory.
     *              User may be asked to confirm license plate being
     *              used for task.
     *
     *----------------------------------------------------------------
     *
     * Split LP Quantity Options
     *
500aA*   This option comes into play when a user is putting a partial
500aA*   quantity into a slot. This could either be during Putaway,
500aA*   Replenishment or Transfer.
500aA*
     *   1  =  LP goes with first quantity put into a slot.
     *   2  =  LP goes with last quantity put into a slot.
     *   3  =  Ask user.
     *
500aA*----------------------------------------------------------------
500aA*
500aA* Split Transfer Quantity Options (OPTSPL)
500aA*
500aA*   This option comes into play when a user is doing a partial
500aA*   quantity transfer and will identify how to deal with the
500aA*   license plate for the quantity that stays in the From slot
500aA*   vs. the quantity that is being transfered.
500aA*
500aA*   1  =  LP stays with remaining quantity in From slot.
500aA*   2  =  LP goes with partial quantity being transfered.
500aA*   3  =  Ask user.
500aA*
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPTR  -  Allow license plate tracking ** NOT USED **
     *    OPLPAL  -  Default for all other items (L,M,H).
     *    OPLPDS  -  Default for date sensitive items (L,M,H).
     *    OPLPLC  -  Default for lot code items (L,M,H).
     *    OPLPCW  -  Default for catchweight items (L,M,H).
     *    OPTKSP  -  Track push back slot positions *** REMOVED ***
500aM*    OPPSPL  -  Splitting Putaway quantity (see above)
500aA*    OPTSPL  -  Splitting Transfer quantity (see above)
     *
     * Data structure
     *
     D oplicense       ds
     D  oplptr                 1      1
     D  oplpal                 2      2
     D  oplpds                 3      3
     D  oplplc                 4      4
     D  oplpcw                 5      5
500aMD  oppspl                 6      6
500aAD  optspl                 7      7
     D  optlicensee          117    117

     *----------------------------------------------------------------
     *  *TRACKSP  -  Track slot position options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSPTR  -  Track slot pallet position (Y/N)
     *    OPMRG   -  Putaway merge option
     *               1 = Only ask for pallet position.
     *               2 = Direct user step by step.
     *    OPRTN   -  Return pallet option
     *               1 = Assume user returns pallets in LOFI order.
     *               2 = Direct user step by step.
     *
     * Data structure
     *
     D optracksp       ds
     D  opsptr                 1      1
     D  opmrg                  2      2
     D  oprtn                  3      3
     D  optrackspe           117    117

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $ptrackitem           22     22
     D  $ptrackpos            23     23
     D  $pposmrg              24     24
     D  $pposrtn              25     25
500aMD  $ppsplit              26     26
500aAD  $ptsplit              27     27

     *----------------------------------------------------------------
     *  Input parameters
     *
     *      $pcmd      -  not used
     *      $pprg      -  Calling program name
     *      $puky      -  Values
     *        $pwhse      -  Warehouse
     *        $ptrackitem -  Item tracking option (comes from item)
     *
     *  Output parameters
     *
     *      $puky      -  Values
     *        $ptrackitem -  Item tracking option
     *        $ptrackpos  -  Slot position tracking option
     *        $pposmrg    -  Slot position tracking Merge option.
     *        $pposrtn    -  Slot position tracking Return option
500aM*        $ppsplit    -  Split Putaway Quantity option
500aA*        $ptsplit    -  Split Transfer Quantity option
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      getitemtrack
     C                   exsr      getpostrack
     C                   exsr      getsplittrack
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     C                   endsr

     *----------------------------------------------------------------
     *  getitemtrack  Get item tracking option
     *----------------------------------------------------------------

     C     getitemtrack  begsr

     *  If item tracking value sent in is not valid, then set it to Low.

     C                   if        $ptrackitem <> 'H'
     C                             and $ptrackitem <> 'M'
     C                             and $ptrackitem <> 'L'
720aAC                             and $ptrackitem <> 'U'
     C                   eval      $ptrackitem = 'L'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getpostrack   Get slot position tracking option
     *----------------------------------------------------------------

     C     getpostrack   begsr

     *  Get global slot position tracking option.

     C                   eval      opcode = '*TRACKSP'
     C     keyop         chain     options
     C                   if        not %found
     C                   eval      opsptr = 'N'
     C                   eval      opmrg  = '0'
     C                   eval      oprtn  = '0'
     C                   else
     C                   eval      optracksp = opdata
     C                   endif

     *  If slot pos tracking value is not valid, then set it off.

     C                   if        opsptr <> 'Y'
     C                   eval      opsptr = 'N'
     C                   eval      opmrg  = '0'
     C                   eval      oprtn  = '0'
     C                   endif

     *  Send back Position Tracking options.

     C                   eval      $ptrackpos = opsptr
     C                   eval      $pposmrg   = opmrg
     C                   eval      $pposrtn   = oprtn

     C                   endsr

     *----------------------------------------------------------------
     *  getsplittrack  Get LP split option.
     *----------------------------------------------------------------

     C     getsplittrack begsr

     C                   eval      opcode = '*LICENSE'
     C     keyop         chain     options
     C                   if        not %found
500aMC                   eval      oppspl = '3'
500aAC                   eval      optspl = '3'
     C                   else
     C                   eval      oplicense = opdata
     C                   endif

500aMC                   eval      $ppsplit = oppspl
500aAC                   eval      $ptsplit = optspl

     C                   endsr
