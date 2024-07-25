417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETWHSEDSC   Get warehouse desc - Pgem for GETWHSEDESC proc
     *  14 January 2007
     *  Dave Sommerville
     *
     *  Revisions:
     *
510 A*    01/14/06  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

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
     *      none
     *
     *    Returned Parameters
     *      $idesc  Warehouse description
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $idesc           40

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Call program to check in route.

     C                   eval      $pcode = '*NONE'

     C                   Call(e)   'GETWHSE2'
     C                   Parm      '*NONE'       $pcode            8
     C                   Parm      0             $pwhse            3 0
     C                   Parm      ' '           $pdesc           30
     C                   Parm      ' '           $pfrmt           40

     *  Set return code.

     C                   if        %error
     C                   eval      $idesc = '* Error calling GETWHSE2 *'
     C                   else
     C                   eval      $idesc = $pdesc
     C                   endif

     C                   eval      *inlr = *on
