      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CCJIT     Create Just-In-Time Proirty Replenishments / Letdowns
     *  02 November 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
500 A*    11/02/04  DAS  5.00
     *      - Created.
500bA*    11/10/04  RH   5.00b
     *      - FIX: End if trans # is zero.
     *      - Only process type 'O' label records.
500cA*    01/16/05  RLP  5.00c
     *      - FIX: Change from Label90 to Label7
     *      - Only need to call CCRPL/CCLDN once per item.
500dA*    10/05/05  MLB  5.00d
     *      - Enh: Revised program to condition when JIT Letdowns,
     *        Replenishments are created based on OPJITR option.
500eA*    10/07/05  MLB  5.00e
     *      - Enh: Revised program to convert codes used for JIT
     *        Replenishments. Update *GENPICK options text.
     *
600aA*    05/08/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - Letdowns have been removed for license tracking.
     *        Revised to ensure OPJITR option is not set for Letdowns.
     *
610aA*    02/23/10  DAS  6.10a
     *      - Added client logic
     *      - Added Dierks custom mod DRKa
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dierks Waukesha Custom Mods
     *
DRKaA*    02/23/10  DAS  DRKa
     *      - Temp mod to force Letdowns (OPJITR = '1')
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

500cDF*abel90   if   e           k disk
500cAFlabel7    if   e           k disk
     Foptions   if   e           k disk

610aA*----------------------------------------------------------------
610aA*  Customer id
610aA*----------------------------------------------------------------
610aA
DRKaA /copy qcopysrc,id#dierks

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $ltrn#                19     25  0
     D  $litem                26     40

     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPHPWC  -  Host pick Will Call (Y/N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
     *    OPEADJ  -  Close short labels without adjustment (Y,N).
     *    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
     *    OPCLRF  -  Clear runner flag if qty still short/out? (Y/N)
     *    OPJITR  -  Create JIT Letdowns or JIT Replenishments?
500eM*                 0=None. No replenishments are created.
500eA*                 1=Letdowns are created during Truck Builder
500eA*                   Pick/Print processing.
500eA*                 2=Priority Replenishments are created during
500eA*                   Truck Builder Pick/Print processing.
500eA*                 3=JIT Letdowns created when transaction is
500eA*                   checked out.
500eA*                 4=JIT Priority Replenishments created when
500eA*                   transaction is checked out.
     *
     *----------------------------------------------------------------
     * Data structure

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
     D  opclrf                10     10
     D  opjitr                12     12
     D  optend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D kycode          s                   like(opcode)
     D kywhse          s                   like(lbwhse)
     D kytrn#          s                   like(lbtrn#)
500cAD holditem        s                   like(lbitem)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE    -  Warehouse
     *      $PTRN#    -  Transaction number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $ptrn#           15 5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

500b * End and return if transacton # is zero.                        .
500b C                   if        $ptrn# = 0
500b C                   goto      endall
500b C                   endif
     *  Get type of JIT replenishment to create.

     C                   eval      kywhse = $pwhse
     C                   eval      kycode = '*GENPICK'
     C     keyop         chain     options
     C                   if        not %found
500eDC*                  eval      opjitr = 'R'
500eMC                   eval      opjitr = '2'
     C                   endif
600aA
600aA* No longer allowing Letdowns. Adjust option accordingly.
600aA
600aAC                   select
600aAC                   when         opjitr = '1'
600aAC                   eval         opjitr = '2'
600aAC                   when         opjitr = '3'
600aAC                   eval         opjitr = '4'
600aAC                   endsl
DRKaA
DRKaA* Dierks - Temporarily force Letdowns only.
DRKaA
DRKaAC                   if           client = dierks
DRKaAC                   eval         opjitr = '1'
DRKaAC                   endif

     * Call program to create JIT replenishment for each label in tran.

500eMC                   if           opjitr = '3'
500eMC                             or opjitr = '4'
500dAC
500cAC                   eval      holditem = *blanks
     C                   eval      kywhse = $pwhse
     C                   eval      kytrn# = $ptrn#
500cDC*    lbkey         setll     label90
500cAC     lbkey         setll     label7
     C                   dow       forever = forever

500cDC*    lbkey         reade     label90
500cAC     lbkey         reade     label7
     C                   if        %eof
     C                   leave
     C                   endif

500cA* We want to make sure that we are in correct warehouse          .
500cAC                   if        lbwhse <> $pwhse
500cAC                   leave
500cAC                   endif

500cA* We also only want to do the call if item has changed           .
500cAC                   if        lbitem = holditem
500cAC                   iter
500cAC                   else
500cAC                   eval      holditem = lbitem
500cAC                   endif

500b * Only process 'O' label records.                                .
500b C                   if        lbtype <> 'O'
500b C                   iter
500b C                   endif

     C                   eval      $ltrn# = lbtrn#
     C                   eval      $litem = lbitem

500eDC*                  if        opjitr = 'R'
500eMC                   if        opjitr = '4'
     C                   call      'CCRPL'
     C                   parm                    $lparm
     C                   else
     C                   call      'CCLDN'
     C                   parm                    $lparm
     C                   endif

     C                   enddo
500dA
500dAC                   endif

500b C     endall        tag
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
610aA
610aA* Get client id.
610aA
610aAC                   call      'GETCLIENT'
610aAC                   parm                    client           10
610aAC                   parm                    clientloc        10

500cM*  Define partial key for LABEL7 file.

     C     lbkey         klist
500cDC*                  kfld                    kywhse
     C                   kfld                    kytrn#

     *  Define partial key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode

     C                   eval      $lprg = #prog
     C                   endsr
