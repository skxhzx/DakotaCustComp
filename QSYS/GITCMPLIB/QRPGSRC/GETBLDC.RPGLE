     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETBLDC   Get item build code
     *  16 August 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*  08/16/05  MLB  5.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warehouse
     *     $PITEM   -  Contract, Alias, Same Slot Breakdown or Different
     *                 Slot Breakdown item number.
     *
     *  Output parameters
     *
     *     $PBLD    - Item build code
     *     $PRTN    - *OK      -  Item build code found
     *                *ERROR   -  Item build code not found
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pbld             2
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
     C                   clear                   $pbld
     C                   eval      $prtn = '*OK     '
     *
     *      Get build code from item file.
     *
     C     keyit         chain     piritem
     C                   if        not %found
     C                   eval      $prtn = '*ERROR  '
     C                   else
     C                   eval      $pbld = itbld
     C                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     C                   endsr
