     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK125    Initialize slots for whse 900 pick test - Init
     *  14 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
411 A*    06/10/99  DAS  4.11
     *      - Added logic to initialize Breakdown item slots.
     *      - Added logic to delete crossdock slots.
     *      - Added logic to fill create stock for Contract items.
     *
413 A*    02/10/00  DAS  4.13
     *      - Added logic to delete virtual slots.
     *
413aA*    03/10/00  DAS  4.13a
     *      - Added new quantity fill options
     *
417 A*    08/24/04  DAS  4.17
     *      - Added logic specific to DD slots.
     *
417aA*    09/25/04  DAS  4.17a
     *      - Added logic specific to DE slots.
     *
500 A*    03/06/05  DAS  5.00
     *      - Revised to clear item number from Verified slots.
     *
520aA*    02/27/09  DAS  5.20
     *      - Revised to update Entered date.
     *
610aA*    12/18/10  DAS  6.10a
     *      - Revised to do special handling for DR slots.
     *
640aA*    07/22/11  DAS  6.40
     *      - Revised to update Expiration date.
     *
730aA*    09/04/19  DAS  7.30a
     *      - Added warehouse.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - Slot DA-104-1 only gets a quanity of 5 in order to cause
     *      a letdown condition for test 7.
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpck125fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot1     uf   e           k disk
     Fitemqty   uf   e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s                   like(slwhse)
     D lstasl          s              3
     D msgk            s              4  0
520aAD offset          s              3  0
     D savitm          s             15
     D sclear          s              1
     D temp3a          s              3
730aAD i               s              3  0

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D today           s               d
     D tmpDate         s               d

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
413aA*      $POPT1  Home slot qty option
413aA*                1 = Fully fill with 50
413aA*                2 = Partially fill with 30
413aA*                3 = Randomly fill
413aA*                4 = Zero
413aA*      $POPT2  Overflow slot qty option
413aA*                1 = Fully fill with 50
413aA*                2 = Partially fill with 30
413aA*                3 = Randomly fill
413aA*                4 = Zero
413aA*      $POPT3  PIR slot qty option
413aA*                1 = Fully fill with 50
413aA*                2 = Partially fill with 30
413aA*                3 = Randomly fill
413aA*                4 = Zero
730aA*      $PWHSEA Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
413aAC                   parm                    $popt1            1
413aAC                   parm                    $popt2            1
413aAC                   parm                    $popt3            1
730aAC                   parm                    $pwhsea           3
     *----------------------------------------------------------------
     *  Main line
     *
520aAC                   eval      today = %date()
     *
     *  Only work with warehouse 900.
730aA*  Now warehouse is sent in.
     *
730aDC**                 eval      kywhse = 900
      /free
730aM    kywhse = %dec($pwhsea: 3: 0);
730aA    if kywhse < 900;
730aA      dsply 'Whse must be 900+';
730aA      return;
730aA     endif;
      /end-free
     *
     *  Clear all item warehouse totals.
     *
     C                   exsr      clrttl
     *
     *  Create warehouse quantities for Contract items.
     *
     C                   exsr      conqty
     *
     *  Create initialize slots.
     *
     C                   eval      lstasl = *blanks
     C     keywh         setll     slot1
     C                   dou       forevr <> forevr
     C     keywh         reade     slot1                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *      Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on  and
     C                             slaisl <> lstasl
     C                   eval      w1aisl = slaisl
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *      Initialize slot record.
     *
411 A*        Delete crossdock slots.
411 A*
411 AC                   select
411 AC                   when      slaisl = 'XDK'
411 AC                   delete    slrec
520aAC                   iter
413 AC                   when      slrsrv = 'V'
413 AC                   delete    slrec
520aAC                   iter
411 AC                   when      sldisp = 'DC-101-1'  or
411 AC                             sldisp = 'DC-102-1'  or
411 AC                             sldisp = 'FC-101-1'  or
411 AC                             sldisp = 'FC-102-1'  or
411 AC                             sldisp = 'PC-101-1'  or
411 AC                             sldisp = 'PC-102-1'  or
411 AC                             sldisp = 'RC-101-1'  or
411 AC                             sldisp = 'RC-102-1'  or
411 AC                             slaisl = ' DX'
411 AC                   exsr      initbk
411 AC                   other
     C                   exsr      initsl
411 AC                   endsl
520aAC                   exsr      setentd
640aAC                   exsr      setexpd
     C                   update    slrec                                78
     *
     C                   enddo
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Define keys
     *
     C     keywh         klist
     C                   kfld                    kywhse
     *
     *
     C     keyiq         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
640aAC     keyit         klist
640aAC                   kfld                    slwhse
640aAC                   kfld                    slitem
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck125fm
     C                   endif
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C                   read      pck125fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRTTL  Clear warehouse totals.
     *
     C     clrttl        begsr
     *
     *   Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1aisl = 'CLR'
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *   Clear quantities in ITEMQTY records.
     *
     C     keywh         setll     itemqty
     C                   dou       forevr <> forevr
     C     keywh         reade     itemqty                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      savitm = iqitem
     C                   clear                   iqrec
     C                   eval      iqwhse = kywhse
     C                   eval      iqitem = savitm
     C                   update    iqrec                                78
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CONQTY  Create quantities for Contract items.
     *
     C     conqty        begsr
     *
     *   Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1aisl = 'CON'
     C                   write     screen1
     C                   endif
     *
     *   Loop through PIRITEM records.
     *
     C     keywh         setll     piritem
     C                   dou       forevr <> forevr
     C     keywh         reade     piritem                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Only work with Contract items.
     *
     C                   if        ittype <> 'C'
     C                   iter
     C                   endif
     *
     *     Get Base item for Contract item.
     *
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
411 AC                   parm      ' '           #bcitm           15
411 AC                   parm                    #bctyp            1
411 AC                   parm                    #bcdsc           30
411 AC                   parm                    #bcpds           15
411 AC                   parm                    #bcwdp            5
411 AC                   parm                    #bcstp            1
411 AC                   parm                    #bcum             2
411 AC                   parm                    #bcum2            2
411 AC                   parm                    #bcuq2            3 0
411 AC                   parm                    #bcum3            2
411 AC                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   if        #brtn = '*ERROR'
     C                   iter
     C                   endif
     *
     *     Update ITEMQTY record.
     *
     C     keyiq         chain     itemqty                            77
     C                   if        *in77
     C                   iter
     C                   endif
     C                   if        #bityp = 'B'
     C                   eval      iqstk1 = 3
     C                   else
     C                   eval      iqstk1 = 50
     C                   endif
     C                   update    iqrec                                78
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITBK  Initialize breakdown item slot.
     *
     C     initbk        begsr
     *
     *   Item number.
     *
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm      slaisl        $cstr            30
     C                   movel(p)  $cstr         slitem
     C                   move      slloc         temp3a
     C     slitem        cat       temp3a:0      slitem
     C     slitem        cat       'B':0         slitem
     *
     *   Reserved.
     *
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slrsrv = 'Y'
     C                   endif
     *
     *   Status.
     *
413aD**                   MOVEL'A '      SLSTAT
     *
     *   Quantities.
     *
413aD**                   Z-ADD4         SLSTK1
413aMC                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
413aA*
413aA*   Init pick slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'F'  and
413aAC                             slpick = 'Y'
413aAC                   select
413aAC                   when      $popt1 = '1'
413aAC                   eval      slstk1 = 4
413aAC                   when      $popt1 = '2'
413aAC                   eval      slstk1 = 3
413aAC                   when      $popt1 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed            9 9
413aAC                   parm      0             $rmin             6 0
413aAC                   parm      4             $rmax             6 0
413aAC                   parm                    $rnum             6 0
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt1 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
413aA*
413aA*   Init non-pick slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'F'  and
413aAC                             slpick <> 'Y'
413aAC                   select
413aAC                   when      $popt2 = '1'
413aAC                   eval      slstk1 = 4
413aAC                   when      $popt2 = '2'
413aAC                   eval      slstk1 = 3
413aAC                   when      $popt2 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed
413aAC                   parm      0             $rmin
413aAC                   parm      4             $rmax
413aAC                   parm                    $rnum
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt2 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
413aA*
413aA*   Init PIR slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'P'
413aAC                   select
413aAC                   when      $popt3 = '1'
413aAC                   eval      slstk1 = 4
413aAC                   when      $popt3 = '2'
413aAC                   eval      slstk1 = 3
413aAC                   when      $popt3 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed
413aAC                   parm      0             $rmin
413aAC                   parm      4             $rmax
413aAC                   parm                    $rnum
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt3 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
     *
     *    Broken case items don't have overflow slots.
     *
     C                   if        slpick <> 'Y'
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   eval      slstk1 = 0
     C                   endif
413aA*
413aA*   Status.
413aA*
413aAC                   if        slstk1 > 0  or
413aAC                             slstyp = 'F'  and
413aAC                             slpick = 'Y'
413aAC                   eval      slstat = 'A '
413aAC                   else
413aAC                   eval      slstat = 'V '
500 AC                   eval      slitem = *blanks
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITSL  Initialize slot fields.
     *
     C     initsl        begsr
     *
     *   Item number.
     *
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm      slaisl        $cstr
     C                   movel(p)  $cstr         slitem
     C                   move      slloc         temp3a
     C     slitem        cat       temp3a:0      slitem
     *
417 AC                   if        slaisl = ' DD'
     *
417 AC                   select
417 AC                   when      slhand = ' A'
417 AC     slitem        cat       'A':0         slitem
417 AC                   when      slhand = ' B'
417 AC     slitem        cat       'B':0         slitem
417 AC                   endsl
     *
417 AC                   select
417 AC                   when      slrlvl = 1
417 AC     slitem        cat       '1':0         slitem
417 AC                   when      slrlvl = 2
417 AC     slitem        cat       '2':0         slitem
417 AC                   endsl
     *
417 AC                   endif
     *
417aAC                   if        slaisl = ' DE'
     *
417aAC                   select
417aAC                   when      slhand = ' A'
417aAC     slitem        cat       'A':0         slitem
417aAC                   when      slhand = ' B'
417aAC     slitem        cat       'B':0         slitem
417aAC                   endsl
     *
417aAC                   select
417aAC                   when      slrlvl = 1
417aAC     slitem        cat       '1':0         slitem
417aAC                   when      slrlvl = 2
417aAC     slitem        cat       '2':0         slitem
417aAC                   endsl
     *
417aAC                   endif
     *
610aAC                   if        slaisl = ' DR'
610aAC                   eval      slitem = 'DA' + %char(slloc)
610aAC                   endif
     *
     *   Reserved.
     *
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slrsrv = 'Y'
     C                   endif
     *
     *   Status.
     *
413aD**                   MOVEL'A '      SLSTAT
     *
     *   Quantities.
     *
413aD**                   Z-ADD50        SLSTK1
413aMC                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
413aA*
413aA*   Init pick slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'F'  and
413aAC                             slpick = 'Y'
413aAC                   select
417 AC                   when      $popt1 = '1'  and
417 AC                             slaisl = ' DD'
417 AC                   eval      slstk1 = 10
417 AC                   when      $popt1 = '2'  and
417 AC                             slaisl = ' DD'
417 AC                   eval      slstk1 = 5
417 AC                   when      $popt1 = '3'  and
417 AC                             slaisl = ' DD'
417 AC                   call      'RANDOM2'
417 AC                   parm                    $rseed
417 AC                   parm      0             $rmin
417 AC                   parm      10            $rmax
417 AC                   parm                    $rnum
417 AC                   z-add     $rnum         slstk1
417aAC                   when      $popt1 = '1'  and
417aAC                             slaisl = ' DE'
417aAC                   eval      slstk1 = 12
417aAC                   when      $popt1 = '2'  and
417aAC                             slaisl = ' DE'
417aAC                   eval      slstk1 = 6
417aAC                   when      $popt1 = '3'  and
417aAC                             slaisl = ' DE'
417aAC                   call      'RANDOM2'
417aAC                   parm                    $rseed
417aAC                   parm      0             $rmin
417aAC                   parm      12            $rmax
417aAC                   parm                    $rnum
417aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt1 = '1'
413aAC                   eval      slstk1 = 50
413aAC                   when      $popt1 = '2'
413aAC                   eval      slstk1 = 30
413aAC                   when      $popt1 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed
413aAC                   parm      0             $rmin
413aAC                   parm      50            $rmax
413aAC                   parm                    $rnum
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt1 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
413aA*
413aA*   Init non-pick slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'F'  and
413aAC                             slpick <> 'Y'
413aAC                   select
417 AC                   when      slaisl = ' DD'
417 AC                   eval      slstk1 = 0
413aAC                   when      $popt2 = '1'
413aAC                   eval      slstk1 = 50
413aAC                   when      $popt2 = '2'
413aAC                   eval      slstk1 = 30
413aAC                   when      $popt2 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed
413aAC                   parm      0             $rmin
413aAC                   parm      50            $rmax
413aAC                   parm                    $rnum
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt2 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
413aA*
413aA*   Init PIR slot qty according to user option.
413aA*
413aAC                   if        slstyp = 'P'
413aAC                   select
413aAC                   when      $popt3 = '1'
413aAC                   eval      slstk1 = 50
413aAC                   when      $popt3 = '2'
413aAC                   eval      slstk1 = 30
413aAC                   when      $popt3 = '3'
413aAC                   call      'RANDOM2'
413aAC                   parm                    $rseed
413aAC                   parm      0             $rmin
413aAC                   parm      50            $rmax
413aAC                   parm                    $rnum
413aAC                   z-add     $rnum         slstk1
413aAC                   when      $popt3 = '4'
413aAC                   eval      slstk1 = 0
413aAC                   endsl
413aAC                   endif
     *
     *   Force letdown condition for slot DA-104-1.
     *
     C                   if        sldisp = 'DA-104-1'
     C                   eval      slstk1 = 10
     C                   endif
413aA*
413aA*   Status.
413aA*
413aAC                   if        slstk1 > 0  or
413aAC                             slstyp = 'F'  and
413aAC                             slpick = 'Y'
610aAC                   if        slaisl = ' DR'
610aAC                   eval      slstat = 'RP'
610aAC                   else
413aAC                   eval      slstat = 'A '
610aAC                   endif
413aAC                   else
413aAC                   eval      slstat = 'V '
500 AC                   eval      slitem = *blanks
413aAC                   endif
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  SETENTD   Set Entered date.
520aA*
520aAC     setentd       begsr

     *

     C                   if        slpick = 'Y'

     C                   eval      offset = 20

     C                   else

     C                   call      'RANDOM2'
     C                   parm                    $rseed
     C                   parm      1             $rmin
     C                   parm      19            $rmax
     C                   parm                    $rnum
     C                   eval      offset = 20 - $rnum

     C                   endif

     C                   eval      tmpDate = today - %days(offset)
     C                   eval      slentd = %dec(
     C                                      %char(tmpDate:*iso0)
     C                                      :8:0)

     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  SETEXPD   Set Expiration date
640aA*
640aAC     setexpd       begsr
     C                   eval      slexpd = 0

     *  Get out if no qty

     C                   if        slstk1=0 and slstk2=0 and slstk3=0
     C                   leavesr
     C                   endif

     *  Get out if item not date sensitive

     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                             or itflgd <> 'Y'
     C                   leavesr
     C                   endif

     *  Calculate expiration date

     C                   if        slpick = 'Y'

     C                   eval      $rnum = 5

     C                   else

     C                   call      'RANDOM2'
     C                   parm                    $rseed
     C                   parm      6             $rmin
     C                   parm      60            $rmax
     C                   parm                    $rnum

     C                   endif

     C                   eval      tmpDate = today + %days($rnum)
     C                   eval      slexpd = %dec(
     C                                      %char(tmpDate:*iso0)
     C                                      :8:0)

     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'UT81201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'UT81221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'UT81222'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'UT81223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
