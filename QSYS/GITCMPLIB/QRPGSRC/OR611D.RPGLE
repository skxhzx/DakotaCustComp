      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR611D     Truck build - delete ORDBSUM recs for the route
     *                           being unpicked.
     *  October 06, 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    10/06/09  JCJ  5.20
     *      -  Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  71        EOF on read to ORDDS.
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordbsum1  uf   e           k disk

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
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *----------------------------------------------------------------
     *  Main line
     *

     C     keybp1        setll     ordbsum1
     C                   dou       %eof(ordbsum1)
     C     keybp1        reade     ordbsum1
     C                   if        not %eof(ordbsum1)
     C                   delete    bprec
     C                   endif
     C                   enddo

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Define full key for ORDBSUM1 file.
     *
     C     keybp1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr
