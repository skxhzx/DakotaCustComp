      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PT655    Auto close open routes
     *  29 April 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*   04/29/04  DAS  4.17
     *     - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtehed3   uf   e           k disk
     Fpirtran4  if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and program info data structure.
     *----------------------------------------------------------------

      /copy *libl/qcopysrc,c#stdvar
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D allclosed       s               n
     D curdate         s              8  0
     D curtime         s              6  0

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
     D  $ptype                81     88

     *   Redefinition of $PUKY

     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  pttrn#                36     42  0

     *----------------------------------------------------------------
     *  Date routine parameters
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input
     *      $pwhse    Warehouse
     *
     *    Returned parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsein         15 5

     C                   eval      $pwhse = $pwhsein

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Loop through all Printed routes.

     C                   eval      kystat = '4'
     C     keyrh3        setll     rtehed3

     C                   dow       forever = forever

     C     keyrh3        reade     rtehed3
     C                   if        %eof
     C                   leave
     C                   endif

     *    Close all transactions for the route.

     C                   eval      kyrtpo = rhrtid
     C                   eval      kygrp2 = ' '
     C                   exsr      closetrans

     *    Mark route for export (if all trans are closed).

     C                   exsr      exportrte

     C                   enddo
     C*
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for RTEHED3 file.

     C     *like         define    rhstat        kystat
     C     keyrh3        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat

     *  Define partial key for PIRTRAN4 file.

     C     *like         define    ptgrp2        kygrp2
     C     *like         define    ptrtpo        kyrtpo
     C     keypt4        klist
     C                   kfld                    $pwhse
     C                   kfld                    kygrp2
     C                   kfld                    kyrtpo

     *  Get current date and time.

     C                   time                    curtime

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *  Initialize PT132 parameters

     C                   eval      $pprg = #pgm
     C                   eval      $ptype = '*BATCH'

     C                   endsr

     *----------------------------------------------------------------
     *  closetrans  Close transactions
     *----------------------------------------------------------------

     C     closetrans    begsr

     C     keypt4        setll     pirtran4

     C                   dow       forever = forever

     C     keypt4        reade     pirtran4
     C                   if        %eof
     C                   leave
     C                   endif

     *      Only work with selection transactions.

     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif

     *      Close transaction.

     C                   eval      $pcmd = '*CLOSE'
     C                   eval      $prte = ptrtpo
     C                   call      'PT132'
     C                   parm                    $parms

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  exportrte   Mark route for export.
     *----------------------------------------------------------------

     C     exportrte     begsr

     *  See if all the transactions were closed.

     C                   eval      allclosed = *on
     C     keypt4        setll     pirtran4

     C                   dow       forever = forever

     C     keypt4        reade     pirtran4
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only work with selection transactions.

     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif

     *    If a transaction is not closed, get out.

     C                   if        ptstat <> '4'
     C                   eval      allclosed = *off
     C                   endif

     C                   enddo

     *  If all transaction are closed for the route,
     *    Then mark the route as exported.

     C                   if        allclosed
     C                   eval      rhstat = '6'
     C                   eval      rhstsd = curdate
     C                   eval      rhstst = curtime
     C                   eval      rhexpd = curdate
     C                   eval      rhexpt = curtime
     C                   update    rhrec
     C                   endif

     C                   endsr
