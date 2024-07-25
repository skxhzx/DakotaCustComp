      *===================================================================
      *
      *  Name .......... C#DRIPARMS
      *  Description ... Dakota realtime interface parameters
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   10/01/01  DAS  4.16
      *     - Created.
      *
416aA *   10/04/01  DAS  4.16a
      *     - Added $drimessage.
      *
416aA *   12/20/02  DAS  4.16b
      *     - Added $driok, $drierror, $driwarn and $driwarnovr constants.
      *
417 A *   06/11/03  DAS  4.17
      *     - Added second data parameter $dridata2.
      *
417 A *   05/04/12  DAS  6.40a
      *     - Added parameter $driuser. Needed for MRC programs because
      *       they use a generic user for the connection.
      *
710aA *   04/18/17  LMC  7.10a
      *     - Added third data parameter $dridata3.
      *
      *===================================================================

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $dricommand  Command (action) being executed
      *      $drisubcmd   Sub-command
      *      $drisys2upd  System to update (D=Dakota, H=Host)
      *      $driprogram  Program making the call
      *      $dridata     Data needed by command
417 A *      $dridata2    Data needed by command
417 A *      $driuser     User id (optional)
710aA *      $dridata3    Data needed by command
      *
      *    Returned Parameters
      *      $drireturn   Return code
      *      $drimessage  Return message
      *      $dridata     Data returned by command
417 A *      $dridata2    Data returned by command
710aA *      $dridata3    Data returned by command
      *
      *----------------------------------------------------------------

     D $driok          c                   '0'
     D $drierror       c                   '1'
     D $driwarning     c                   '2'
     D $driwarnovr     c                   '3'

     D $dricommand     s             10
     D $drisubcmd      s             10
     D $drisys2upd     s              1
     D $driprogram     s             10
     D $drireturn      s             10
     D $drimessage     s             60
     D $dridata        s            512
417 AD $dridata2       s            512
417 AD $driuser        s             10
710aAD $dridata3       s            512
