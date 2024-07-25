      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR612     Truck build - Create zone work file
     *  13 June 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    06/12/97  DAS  4.00
     *      -  New program.
     *
404 A*    08/07/97  DAS  4.04
     *      -  Changed check when finding truck zone for children.
     *
530 A*    11/09/09  JCJ  5.30
     *      - ENH: Added file TRUCKH to lookup Template code for
     *             Zone references.
     *      - ENH: Converted to RPG4.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fzoneh     if   e           k disk
530 AFtruckh    if   e           k disk
     Fworkzon   uf a e           k disk
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
     * Work
     *----------------------------------------------------------------
     D $ptmpl          s             10
     D forevr          s              1
     D kyzone          s                   like(zhzone)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $prtid            5
     *----------------------------------------------------------------
     *  Main line
     *
     *  Delete existing work records.
     *
     C     keyzw         setll     workzon
     C                   dow       forevr = forevr
     C     keyzw         reade     workzon                                79
     C                   if        *in79
     C                   leave
     C                   else
     C                   delete    zwrec
     C                   endif
     C                   enddo
     *
     *  Create work records.
     *
     C     keyzh         setll     zoneh
     C                   dow       forevr = forevr
     C     keyzh         reade     zoneh                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      zwwhse = $pwhse
     C                   eval      zwrtid = $prtid
     C                   eval      zwszon = zhzone
     C                   eval      zwpzon = zhpzon
     C                   eval      zwcomp = zhcomp
530 D **                 eval      zwtruk = zhtruk
530 MC                   eval      zwtruk = $ptruk
     C                   eval      zwgen = 1
     C                   if        zhcomp <> *blank
     C                   eval      zwtzon = zhzone
     C                   eval      zwgen = 1
     C                   else
     C                   eval      zwtzon = *blanks
     C                   eval      zwgen = 2
     C                   endif
     *
     C                   write     zwrec
     C                   enddo
     *
     *  Find truck zone and generation of children.
     *
     C     keyzw         setll     workzon
     C                   dow       forevr = forevr
     C     keyzw         reade     workzon                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
404 D*          ZWPZON    IFEQ *BLANKS
404 MC                   if        zwtzon <> *blanks
     C                   iter
     C                   endif
     *
     C                   eval      kyzone = zwpzon
     C                   dow       forevr = forevr
     C     keypz         chain     zoneh                              78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        zhpzon <> *blank
     C                   eval      kyzone = zhpzon
     C                   add       1             zwgen
     C                   else
     C                   eval      zwcomp = zhcomp
     C                   eval      zwtzon = zhzone
     C                   leave
     C                   endif
     C                   enddo
     C                   update    zwrec
     C                   enddo
     *
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
     C                   eval      forevr = *off
     *
     *  Define partial key for WORKZON file.
     *
     C     keyzw         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define partial key for ZONEH file.
     *
     C     keyzh         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     *
     *  Define key for ZONEH file.
     *
     C     keypz         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    kyzone
530 A *
530 A *  Define key for TRUCKH file.
530 A *
530 AC     trkey         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
530 A *
530 A * Get Zone Template Code if Template type is T=Truck
530 A *
530 AC     trkey         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl = thztmp
530 AC                   else
530 AC                   eval      $ptmpl = $ptruk
530 AC                   endif
     *
     C                   endsr
