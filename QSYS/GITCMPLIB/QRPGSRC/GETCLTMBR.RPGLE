     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETCLTMBR   Get Client Member Name for Export
     *  21 October 2008
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*    08/21/08  MLB  5.20  P#00133
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordh3     if   e           k disk
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
ETT A /COPY QCOPYSRC,ID#ETTLINE
     *
     *----------------------------------------------------------------
     *  Working variables.
     *
     D kywhse          s                   like(ohwhse)
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse number (alpha)
     *      $PRTID  Route ID
     *      $PRTE   Host route number
     *
     *    Returned Parameters
     *      $PMBR   Host member name to use for export
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $pmbr            10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   move      $pwhs         $pwhse
     *
     C                   select
     C                   when      client = Ettline
     *
     C     ohkey         setll     ordh3
     C     ohkey         reade     ordh3
     C                   if        not %eof(ordh3)
     C                   eval      $pmbr = %subst(ohmisc:1:10)
     C                   else
     C                   eval      $pmbr = 'L' + %subst($pwhs:2:2) + $prte
     C                   endif
     *
     C                   endsl
     *
     C                   eval      *inlr = *on
     *
     *   Do some clean up before leaving.
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alpabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define file keys.
     *
     C     *like         define    ohwhse        $pwhse
     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  Compile Time Tables
     *
