     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETPALLET   Get pallet number
     *  10 April 2006
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
500 A*   04/10/06  DAS  5.00
     *     - Created.
     *
500aA*   04/13/06  DAS  5.00a
     *     - Revised to send back slot zone.
     *
500bA*   04/26/06  DAS  5.00b
     *     - Added more return fields.
     *
640aA*   10/24/11  JCJ  6.40a
     *     - Fix: Changed chain to PLTSUM2 to a SETLL/READE using same
     *       key.  This was done because on occassion the key used was
     *       not unique enough and returned the wrong pallet number.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum2   if   e           k disk

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *----------------------------------------------------------------
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n

     *----------------------------------------------------------------
     *  Input parameters
     *
     *     $pwhse   - Warehouse
     *     $prtid   - Route id
     *     $ptype   - Type
     *     $ppid    - Pallet id.
     *
     *  Output parameters
     *
     *     $ppal#   - Pallet number.
500bA*     $ptzon   - Truck zone
500bA*     $ppzon   - Parent zone
500aA*     $pszon   - Slot zone
500bA*     $pcomp   - Compartment
500bA*     $pgen    - Generation
500bA*     $ptruk   - Truck code
500bA*     $punld   - Unload seq#
500bA*     $prow    - Row
500bA*     $pcol    - Column
500bA*     $pstp1   - First Stop
500bA*     $pstp2   - Last Stop
500bA*     $ppcs    - Pieces
500bA*     $pcube   - Cube
500bA*     $pswgt   - Weight
500bA*     $pbcnt   - Bulk pick count
500bA*     $pflag   - Add on flag
500bA*     $plbl#   - Label #
500bA*     $ptrn#   - Tran #
     *     $prtn    - *OK      -  Truck pallet found
     *                *ERROR   -  Truck pallet not found
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptype            1
     C                   parm                    $ppid             7 0
     C                   parm                    $ppal#            7 0
500bAC                   parm                    $ptzon            6
500bAC                   parm                    $ppzon            6
500aAC                   parm                    $pszon            6
500bAC                   parm                    $pcomp            1
500bAC                   parm                    $pgen             1 0
500bAC                   parm                    $ptruk           10
500bAC                   parm                    $punld            2 0
500bAC                   parm                    $prow             2 0
500bAC                   parm                    $pcol             1 0
500bAC                   parm                    $pstp1            2 0
500bAC                   parm                    $pstp2            2 0
500bAC                   parm                    $ppcs             5 0
500bAC                   parm                    $pcube            7 3
500bAC                   parm                    $pswgt            9 2
500bAC                   parm                    $pbcnt            1 0
500bAC                   parm                    $pflag            1
500bAC                   parm                    $plbl#            7 0
500bAC                   parm                    $ptrn#            7 0
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   eval      $ppal# = 0
500bAC                   eval      $ptzon = ' '
500bAC                   eval      $ppzon = ' '
500aAC                   eval      $pszon = ' '
500bAC                   eval      $pcomp = ' '
500bAC                   eval      $pgen  = 0
500bAC                   eval      $ptruk = ' '
500bAC                   eval      $punld = 0
500bAC                   eval      $prow  = 0
500bAC                   eval      $pcol  = 0
500bAC                   eval      $pstp1 = 0
500bAC                   eval      $pstp2 = 0
500bAC                   eval      $ppcs  = 0
500bAC                   eval      $pcube = 0
500bAC                   eval      $pswgt = 0
500bAC                   eval      $pbcnt = 0
500bAC                   eval      $pflag = ' '
500bAC                   eval      $plbl# = 0
500bAC                   eval      $ptrn# = 0

     C                   eval      $prtn = *blanks

     *    Split pallet id into individual fields.

     C                   eval      dsplid = $ppid

     *   Get pallet summary record.

640aD ***  keyps2        chain     pltsum2
640aD ***                if        not %found
640aAC     keyps2        setll     pltsum2
640aAC                   dou       %eof(pltsum2)
640aAC     keyps2        reade     pltsum2
640aAC                   if        %eof(pltsum2)
     C                   eval      $prtn = '*ERROR'
     C                   else
640aAC                   if        psplid = $ppid
     C                   eval      $prtn = '*OK'
     C                   eval      $ppal# = pspal#
500bAC                   eval      $ptzon = pstzon
500bAC                   eval      $ppzon = pspzon
500aAC                   eval      $pszon = psszon
500bAC                   eval      $pcomp = pscomp
500bAC                   eval      $pgen  = psgen
500bAC                   eval      $ptruk = pstruk
500bAC                   eval      $punld = psunld
500bAC                   eval      $prow  = psrow
500bAC                   eval      $pcol  = pscol
500bAC                   eval      $pstp1 = psstp1
500bAC                   eval      $pstp2 = psstp2
500bAC                   eval      $ppcs  = pspcs
500bAC                   eval      $pcube = pscube
500bAC                   eval      $pswgt = psswgt
500bAC                   eval      $pbcnt = psbcnt
500bAC                   eval      $pflag = psflag
500bAC                   eval      $plbl# = pslbl#
500bAC                   eval      $ptrn# = pstrn#
640aAC                   leave
640aAC                   endif
     C                   endif
640aAC                   enddo

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     *  Define key for PLTSUM2 file.

     C     keyps2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $ptype
     C                   kfld                    dsplgn
     C                   kfld                    dsplrw
     C                   kfld                    dsplcl

     C                   endsr
