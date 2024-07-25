      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TOTSLTDTE   Total SLOTDTE file.
     *  19 December 2008
     *  Roxanne Harrison
     *
     *  Revisions
     *
510 A*    12/19/08  RH   5.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslotdte   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A /COPY *libl/qcopysrc,C#DRIPARMS

500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

500 AD error           s               n
     d forever         s               n   inz(*on)
     d difqty1         s                   like($pqty1)
     d difqty2         s                   like($pqty2)
     d difqty3         s                   like($pqty3)

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
     *
     *  Input parameters
     *
     *     $pcmd    -  *FIX     - Called to total for fix
     *     $ppgm    -  Original calling program
     *     $ppgm2   -  DRI program.
     *     $pwhse   -  Warehouse
     *     $pwhdp   -  Department
     *     $pslot   -  Slot
     *     $pitem   -  Item number
     *
     *  Output parameters
     *
     *     $pqty1   -  Quantity 1
     *     $pqty2   -  Quantity 2
     *     $pqty3   -  Quantity 3
     *     $prtn    -  Retun code
     *                 *OK    - Valid userid
     *                 *ERROR - Invalid userid
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $ppgm            10
     C                   parm                    $ppgm2           10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pslot           12
     C                   parm                    $pitem           15
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Calculate difference between slot and slot date quantities.

     C                   eval      difQty1 = $pqty1
     C                   eval      difQty2 = $pqty2
     C                   eval      difQty3 = $pqty3

     C                   exsr      getDateTotal
     C                   eval      $pqty1 = difqty1
     C                   eval      $pqty2 = difqty2
     C                   eval      $pqty3 = difqty3

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forever = *on

     *
     *  Define partial key for SLOTDTE file.

     C     sdtkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pslot
     C                   kfld                    $pitem

     C                   endsr

     *----------------------------------------------------------------
     *  getDateTotal   Get total qty from SLOTDTE.
     *----------------------------------------------------------------

     C     getDateTotal  begsr

     *  Loop through records for slot.

     C     sdtkey        setll     slotdte
     C                   dow       forever = forever
     C     sdtkey        reade     slotdte                                79

     C                   if        *in79
     C                   leave
     C                   endif

     C                   eval      difQty1 = difQty1 - sdtqt1
     C                   eval      difQty2 = difQty2 - sdtqt2
     C                   eval      difQty3 = difQty3 - sdtqt3

     C                   enddo

     C                   endsr


