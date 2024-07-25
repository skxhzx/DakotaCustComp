     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIRLCN#     Get next PIR license number
     *  14 May  2007
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM  Next PIR license number (guarenteed to be
     *            unique; not guarenteed to be the next used in
     *            sequence; 000000 is not used)
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flichist   if   e           k disk
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $plcns                22     36

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D $nxtnm          s              7  0
     D next#           s              7  0
     D wplcns          s             15
     D stop            s              1

     *----------------------------------------------------------------
     * Parm list
     *
     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     * Key list
     *
     C     LicKey        klist
     C                   kfld                    $pwhse
     C                   kfld                    wplcns
     *----------------------------------------------------------------
     * Main Line
     *
     C     *dtaara       define    pirlicense    next#
     C     *lock         in        next#
     *
     *  Data area contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999 have not been used).
     *
     C                   eval      stop = *off
     C                   dou       stop = *on
     *
     C                   select
     C                   when      next# = 9999999
     C                   eval      next# = 1
     C                   when      next# = 0
     C                   add       1             next#
     C                   endsl
     *
     C                   eval      wplcns = 'LP' +
     C                             %trim(%editc(next#:'X'))
     *
     C     lickey        setll     lichist                                50
     C                   if        not *in50
     C                   eval      stop = *on
     C                   else
     C                   add       1             next#
     C                   endif
     C                   enddo
     *
     *  Return the unique sequence number.
     *
     C                   eval      $plcns = wplcns
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             next#
     C                   out       next#
     C                   return
