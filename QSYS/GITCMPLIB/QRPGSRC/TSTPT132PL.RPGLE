     *----------------------------------------------------------------
     *
     *  TSTPT132PL   Call PT132PL for bench testing.
     *  12 January 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    01/12/06  MLB  5.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    $pcmd       -  *PICK, *MANFLAG, *CLSFLAG
     *    $plbl#      -  label number
     *    $pqty       -  quantity picked
     *
     *   Output
     *
     *    None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $plbl#            7
     C                   parm                    $pqty             5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  call Voice Posting / Runner update program.
     C                   move      $plbl#        $llbl#
     C                   move      $pqty         $lqty
     C                   call      'PT132PL'
     C                   parm                    $PCMD
     C                   parm                    $LLBL#            7 0
     C                   parm                    $LQTY             5 0

     C                   eval      *inlr = *on
