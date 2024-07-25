     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETWHSE2  Get default warehouse for user w/description
     *  10 May 2002
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    05/10/02  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiruser   if   e           k disk
     Fwarehs    if   e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $CODE    -  User code
     *
     *  Output parameters
     *
     *     $WHSE    -  Default warehouse
     *     $DESC    -  Default warehouse description
     *     $FRMT    -  Default formated warehouse description
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $code            10
     C                   parm                    $whse             3 0
     C                   parm                    $desc            30
     C                   parm                    $frmt            40

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get default warehouse for user.

     C     $code         chain     piruser
     C                   if        %found
     C                   eval      $whse = uswhse
     C                   else
     C                   eval      $whse = 1
     C                   endif

     *  Get warehouse description.

     C     $whse         chain     warehs
     C                   if        %found
     C                   eval      $desc = whdesc
     C                   else
     C                   eval      $desc = '** Not on File **'
     C                   endif

     *  Create formated description

     C                   eval      $frmt = %trim(%editc($whse:'Z'))
     C                                       + ' - ' + %trim($desc)

     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return
