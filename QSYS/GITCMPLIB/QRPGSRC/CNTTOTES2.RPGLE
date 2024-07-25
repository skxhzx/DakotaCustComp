     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CNTTOTES2   Count total totes for a stop.
     *  01 July  2008
     *  Jeffrey Jahnke
     *----------------------------------------------------------------
     *  Copy of program CNTTOTES
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*   07/01/08  JCJ  5.20
     *     - Created.
     *
520aA*   09/18/08  DAS  5.20a
     *     - Fix, change $ptcnt to 3.0 from 2.0.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum3   if   e           k disk
     Flabel13   if   e           k disk

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
520aDC**                 parm                    $ptcnt            2 0
520aMC                   parm                    $ptcnt            3 0
     C                   parm                    $pord             7 0
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

     *      Skip if not for correct order.
     *      Note, totes only have 1 order per stop.

     C     keyl13        chain     label13
     C                   if        %found(label13)
     C                   if        lbord <> $pord
     C                   iter
     C                   endif
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

     *  Define key for LAEL132 file.

     C     keyl13        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    $pstop

     C                   endsr
