     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OI260     Auto-select truck
     *  29 April 2004
     *  Dave Sommerville
     *
417 A*    04/29/04  DAS  4.17
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftruckh    if   e           k disk
     Ftruckd    if   e           k disk
     Frtesum    if   e           k disk

     *----------------------------------------------------------------
     *  Multiple occurance truck data structure
     *----------------------------------------------------------------

     D truckds         DS                  OCCURS(100)
417fAD  tdsstat                       1
417fAD  tdscode                      10
417fAD  tdsdrycube                    9  3
417fAD  tdsfrzcube                    9  3
417fAD  tdspltcube                    9  3

414 A*----------------------------------------------------------------
414 A* Program variables.
414 A*----------------------------------------------------------------
414 A
     D cubeneeded      s              9  3
     D forever         s               n
417fAD i               s              3  0
     D lowcube         s              9  3
417fAD maxdrycube      s              9  3 inz(0)
417fAD maxfrzcube      s              9  3 inz(0)
417fAD maxpltcube      s              9  3 inz(0)
417fAD mindrycube      s              9  3 inz(*hival)
417fAD minfrzcube      s              9  3 inz(*hival)
417fAD minpltcube      s              9  3 inz(*hival)
     D rtesumfound     s               n
     D truckcount      s              3  0 inz(0)

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
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   Program to send messages back to.
     *      $PWHSE  Warehouse
     *      $PRTEID Route id
     *
     *    Returned Parameters
417eM*      $PTRUCK Selected truck code, if any.
     *      $PRTN   *OK      - Truck found.
     *              *NOTFND  - No matching truck found.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prteid           5
     C                   parm                    $ptruck          10
     C                   parm                    $prtn             8

     C                   eval      $ptruck = *blanks
     C                   eval      $prtn   = '*NOTFND'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get truck information.

     *    Read through Header file.

     C     keyth         setll     truckh
     C                   dow       forever = forever
     C     keyth         reade     truckh
     C                   if        %eof
     C                   leave
     C                   endif

     *      See if truck should be exluded.

     C                   if        %subst(thdesc:22:9) = '*exclude*'
     C                   iter
     C                   endif

     C                   if        truckcount = 100
     C                   iter
     C                   endif

     *      Initialize data structure entry for truck.

     C                   eval      truckcount = truckcount + 1
     C     truckcount    occur     truckds
     C                   eval      tdscode = thtruk
     C                   eval      tdsstat = ' '
     C                   eval      tdsdrycube = 0
     C                   eval      tdsfrzcube = 0
     C                   eval      tdspltcube = 0

     *      Read througth Detail.

     C     keytd         setll     truckd
     C                   dow       forever = forever
     C     keytd         reade     truckd
     C                   if        %eof
     C                   leave
     C                   endif

     *        Added cube to appropriate compartment total.

     C                   select
     C                   when      tdcomp = 'D'
     C                   eval      tdsdrycube = tdsdrycube + tdcube
     C                   when      tdcomp = 'F'
     C                   eval      tdsfrzcube = tdsfrzcube + tdcube
     C                   when      tdcomp = 'P'
     C                   eval      tdspltcube = tdspltcube + tdcube
     C                   endsl

     C                   enddo

     C                   if        tdsfrzcube <  minfrzcube
     C                   eval      minfrzcube = tdsfrzcube
     C                   endif

     C                   if        tdsfrzcube >  maxfrzcube
     C                   eval      maxfrzcube = tdsfrzcube
     C                   endif

     C                   if        tdsdrycube <= 0
     C                             and tdsfrzcube <= 0
     C                             and tdspltcube <= 0
     C                   eval      truckcount = truckcount - 1
     C                   endif

     C                   enddo

     C                   if        truckcount = 0
     C                   goto      bottom
     C                   endif

     C                   eval      rtesumfound = *off

     *  First, select truck based on best match for FRZ.

     C                   eval      kywhdp = 'FRZ'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdsfrzcube = minfrzcube
     C                   eval      lowcube = tdsfrzcube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdsfrzcube
     C                             and tdsfrzcube <= lowcube
     C                   eval      lowcube = tdsfrzcube

     C                   when      cubeneeded > maxfrzcube
     C                             and tdsfrzcube = maxfrzcube

     C                   other
     C                   eval      tdsstat = '1'

     C                   endsl

     C                   if        tdsstat = ' ' and tdspltcube < minpltcube
     C                   eval      minpltcube = tdspltcube
     C                   endif

     C                   if        tdsstat = ' ' and tdspltcube > maxpltcube
     C                   eval      maxpltcube = tdspltcube
     C                   endif

     C                   enddo

     *  Next, select truck based on best match for PLT.

     C                   eval      kywhdp = 'PLT'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdspltcube = minpltcube
     C                   eval      lowcube = tdspltcube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdspltcube
     C                             and tdspltcube <= lowcube
     C                   eval      lowcube = tdspltcube

     C                   when      cubeneeded > maxpltcube
     C                             and tdspltcube = maxpltcube

     C                   other
     C                   eval      tdsstat = '2'

     C                   endsl

     C                   if        tdsstat = ' ' and tdsdrycube < mindrycube
     C                   eval      mindrycube = tdsdrycube
     C                   endif

     C                   if        tdsstat = ' ' and tdsdrycube > maxdrycube
     C                   eval      maxdrycube = tdsdrycube
     C                   endif

     C                   enddo

     *  Last, select truck based on best match for DRY.

     *  Currently, this is not needed because the way the trucks are
     *  defined at City Line, only 1 truck will be left.


     C**********         GOTO      SKIPDRYREF


     C                   eval      kywhdp = 'DRY'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      kywhdp = 'REF'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = cubeneeded + rsordc
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdsdrycube = mindrycube
     C                   eval      lowcube = tdsdrycube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdsdrycube
     C                             and tdsdrycube <= lowcube
     C                   eval      lowcube = tdsdrycube

     C                   when      cubeneeded > maxdrycube
     C                             and tdsdrycube = maxdrycube

     C                   other
     C                   eval      tdsstat = '3'

     C                   endsl

     C                   enddo

     C     skipdryref    tag

     *  Now select from the remaining trucks

 1B  C                   if        not rtesumfound
     C                   goto      bottom
 1E  C                   endif

     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   if        tdspltcube < lowcube
     C                   eval      lowcube = tdspltcube
     C                   eval      $ptruck = tdscode
     C                   eval      $prtn   = '*OK'
     C                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for TRUCKH file.

     C     keyth         klist
     C                   kfld                    $pwhse

     *  Define partial key for TRUCKD file.

     C     keytd         klist
     C                   kfld                    thwhse
     C                   kfld                    thtruk

     *  Define key for RTESUM file.

     C     *like         define    rswhdp        kywhdp
     C     keyrs         klist
     C                   kfld                    thwhse
     C                   kfld                    $prteid
     C                   kfld                    kywhdp

     C                   endsr
