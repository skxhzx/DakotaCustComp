      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UCIICNT   Total item UCI count.
     *  29 August 2006
     *  Roxanne Harrison
     *
     *  Revisions
     *
500 A*    08/29/06  RH   5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fucicw3    if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

500 AD $whse           s              3  0
500 AD $pwhse          s              3
500 AD error           s               n
     D forever         s               n   inz(*on)
     D totuci          s                   like($tuci)
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $WHSE    -  Warehouse
     *     $ITEM    -  Item number
     *
     *  Output parameters
     *
     *     $TUCI    -  Total Item UCI Count
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $item            15
     C                   parm                    $tuci             5 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   z-add     0             totuci            5 0
     C     ucikey        setll     ucicw3
     C                   dow       forever = forever
     C     ucikey        reade     ucicw3

     C                   if        %eof
     C                   leave
     C                   endif
 1B  C                   if        %found
     C                   add       1             totuci
     C                   iter
     C                   endif
     C                   enddo
     C                   eval      $tuci = totuci

     C                   return
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forever = *on
     C                   move      $pwhse        $whse

     *  Define partial key for UCICW3 file.

     C     ucikey        klist
     C                   kfld                    $whse
     C                   kfld                    $item

     C                   endsr

