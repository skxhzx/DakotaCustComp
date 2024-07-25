     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CNTTOTES    Count total totes for a stop.
     *  26 April 2006
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
500 A*   04/26/06  DAS  5.00
     *     - Created.
     *
640 A*   04/02/12  MLB  6.40
     *     - Fix: Revised pgm to increase size of $PTCNT to 3,0 from 2,0.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum3   if   e           k disk

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
     *     $pcomp   - Compartment
     *     $ptzon   - Truck zone
     *     $pgen    - Generation
     *     $pszon   - Slot zone
     *     $pstop   - Stop
     *
     *  Output parameters
     *
     *     $ptcnt   - Tote count.
     *     $prtn    - *OK
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptype            1
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
500aAC                   parm                    $pszon            6
500aAC                   parm                    $pstop            2 0
640 DC*                  parm                    $ptcnt            2 0
640 MC                   parm                    $ptcnt            3 0
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   eval      $ptcnt = 0
     C                   eval      $prtn = *blanks

     *   Get pallet summary record.

     C     keyps3        setll     pltsum3

     C                   dow       forever = forever
     C     keyps3        reade     pltsum3
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        pspcs <= 0
     C                   iter
     C                   endif

     *      Skip if not for correct stop.
     *      Note, totes only have 1 stop per pallet.

     C                   if        psstp1 <> $pstop
     C                   iter
     C                   endif

     C                   eval      $ptcnt = $ptcnt + 1

     C                   enddo

     C                   eval      $prtn = '*OK'
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     *  Define key for PLTSUM2 file.

     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    $ptype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon

     C                   endsr
