     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PS134       Get total weight for each display column.
     *  03 April 2007
     *  Retha Davis
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
510 A*   04/03/07  RBD  5.10
     *     - Created.
     *
510aA*   04/04/07  RBD  5.10
     *     - Revised to only read PSTYPE='O' recs.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum1   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D $pwhs3          s              3  0

     *----------------------------------------------------------------
     *  Input parameters
     *
     *     $pwhse   - Warehouse
     *     $prtid   - Route id
     *
     *  Output parameters
     *
     *     $pwgt1   - Column 1 total weight
     *     $pwgt2   - Column 2 total weight
     *     $prtn    - *OK
     *     $pmsg    - Message id
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $prtid            5
     C                   parm                    $pwgt1           15 5
     C                   parm                    $pwgt2           15 5
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   eval      $pwhs3 = $pwhse
     C                   eval      $pwgt1 = 0
     C                   eval      $pwgt2 = 0
     C                   eval      $prtn = *blanks
     C                   eval      $pmsg = *blanks

     *   Get pallet summary record.

     C     keyps1        setll     pltsum1

     C                   dow       forever = forever
     C     keyps1        reade     pltsum1
     C                   if        %eof
     C                   leave
     C                   endif

     *   Skip if not generation 1
510aA*    or not PSTYP='O'
     C                   if        psgen <> 1
510aAC                             or pstype <> 'O'
     C                   iter
     C                   endif

     C                   select

     C                   when      pscol  = 1
     C                   eval      $pwgt1 = $pwgt1 + psswgt

     C                   when      pscol  = 2
     C                   eval      $pwgt2 = $pwgt2 + psswgt

     C                   endsl
     C                   enddo

     C                   eval      $prtn = '*OK'
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     *  Define key for PLTSUM1 file.

     C     keyps1        klist
     C                   kfld                    $pwhs3
     C                   kfld                    $prtid

     C                   endsr
