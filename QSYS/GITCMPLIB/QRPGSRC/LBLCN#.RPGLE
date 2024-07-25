     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LBLCN#     Get next LB340 license number
     *  02 January  2008
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
     *    $NXTNM  Next LB340 license number (guarenteed to be
     *            unique; not guarenteed to be the next used in
     *            sequence; 000000 is not used)
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
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
     D  $plcns                22     28

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D $nxtnm          s              7  0
     D next#           s              7  0
     D wplcns          s              7
     D stop            s              1

     *----------------------------------------------------------------
     * Parm list
     *
     C     *entry        plist
     C                   parm                    $parms
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *dtaara       define    lblicense     next#
     C     *lock         in        next#
     *
     *  Data area contains the next sequence number to use.
     *
     C                   select
     C                   when      $plcns <> *blanks
     C                   eval      next# = %dec($plcns:7:0)
     C                   when      next# = 9999999
     C                   eval      next# = 1
     C                   when      next# = 0
     C                   add       1             next#
     C                   endsl
     *
     C                   eval      wplcns = %trim(%editc(next#:'X'))
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
