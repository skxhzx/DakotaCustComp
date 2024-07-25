     *----------------------------------------------------------------
     * Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Compile at V5R1M0 or later
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OR688     RF Bulk Drop - Check for open Bulk Drop for Dept.
     *  06 April, 2006
     *  Roxanne Harrison
     *
     *  Revisions
     *
417 A*    04/06/06  RH   5.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fbulkdrp1  if   e           k disk

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
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
     D  $pwhdp                22     26
     D  $pstat                27     28
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D temp6a          s              6
     D todate          s               d
     D todatemdy       s              6
     D today           s               d


     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    $pwhse          -  Warhouse
     *    $pwhdp          -  Department
     *    $pstat          -  Status
     *
     *   Output
     *
     *    $prtn           -  *OK
     *                       *DROPOUT - No open bulk drops for department.
     ***  $pmsg           -  Error message.
     *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms
417cAC*                  parm                    $pwhse            3 0
     C*                  parm                    $pwhdp            5
     C*                  parm                    $pstat            2
     C*                  parm                    $preturn          8
     C*                  parm                    $pmessage        50

     C                   eval      $prtn = '*OK'
     C                   eval      $pmsg = *blanks

     *  Check for open Bulk Drops for department

     C     partky        setll     bulkdrp1
     C     partky        reade     bulkdrp1                               79
     C                   if        not *in79
     C                   eval      $prtn = '*OK     '
     C                   else
     C                   eval      $prtn = '*DROPOUT'
     C                   eval      $pmsg = 'No open Bulk Drops '
     C                                       + 'found'
     C                   endif

     C     bottom        tag

     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pstat
     C                   endsr
