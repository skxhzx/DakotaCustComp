     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HQ239     Q&D Utility - Populate IMPFPCKQ from LABEL file.
     *  02 February 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*  02/03/11  MLB  6.40
     *    - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
ccc A*  mm/dd/yy  iii  ccc
     *    -
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fimpfpckq  uf a e           k disk
     frtehed2   if   e           k disk
     flabel94   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     d a10             s              1    dim(10)
     d desc            s             40    dim(10) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d client          s             10    inz
     d clientloc       s             10    inz
     d forever         s              1    inz('1')
     d $pwhse          s              3  0 inz
     d startdate       s              8  0 inz
     d enddate         s              8  0 inz
     *

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -None-
     *
     *    Returned Parameters
     *      -None -
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pstat            1
     C                   parm                    $ptype            1
     C                   parm                    $pstartdate       8
     C                   parm                    $penddate         8
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     c     rhkey         setll     rtehed2
     c                   dow       forever = forever
     c     rhkey         reade     rtehed2
     *
     c                   if        %eof(rtehed2)
     c                   leave
     c                   endif
     *
     c                   if           rhimpd < startdate
     c                             or rhimpd > enddate
     c                   iter
     c                   endif
     *
     c     lbkey         setll     label94
     c                   dow       forever = forever
     c     lbkey         reade     label94
     c                   if        %eof(label94)
     c                   leave
     c                   endif
     *
     ** Get Import Pick Qty Adj record.
     *
     C                   if            lbtype = 'O'
     C                             and lbqpck > 0
     C                             or  lbtype = 'B'
     C                             and lbqpck > 0
     *
     c     ipqkey        chain     impfpckq
     *
     C                   if        not %found(impfpckq)
     c                   clear                   ipqrec
     c                   eval      ipqwhs = rhwhse
     c                   eval      ipqwhd = lbwhdp
     c                   eval      ipqitm = lbitem
     *
     C                   select
     C                   when      lbutyp = 'N'
     c                   eval      ipqqp1 = lbqpck * -1
     C                   when      lbutyp = '1'
     c                   eval      ipqqp2 = lbqpck * -1
     C                   when      lbutyp = '2'
     c                   eval      ipqqp3 = lbqpck * -1
     C                   endsl
     *
     c                   eval      ipqadj = 'FX'
     c                   eval      ipqsof = 'Y'
     c                   eval      ipqmem = rhrte
     c                                      + '/'
     c                                      + rhrtid
     c                   write     ipqrec
     *
     c                   else
     *
     C                   select
     C                   when      lbutyp = 'N'
     c                   eval      ipqqp1 = ipqqp1 + (lbqpck * -1)
     C                   when      lbutyp = '1'
     c                   eval      ipqqp2 = ipqqp2 + (lbqpck * -1)
     C                   when      lbutyp = '2'
     c                   eval      ipqqp3 = ipqqp3 + (lbqpck * -1)
     C                   endsl
     *
     c                   update    ipqrec
     c                   endif                                                  Endif - eof impfpckq
     *
     c                   endif                                                  Endif - Lbtype
     *
     c                   enddo                                                  Enddo - Label94
     *
     c                   enddo                                                  Enddo - Rtehed2
     *
     C                   eval      *inlr = '1'
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr

     * Get client id.

     c                   call      'GETCLIENT'
     c                   parm                    client
     c                   parm                    clientloc
     *

     *   Set warehouse defaults.

     c                   move      $pwhs         $pwhse
     c                   move      $pstartdate   startdate
     c                   move      $penddate     enddate
     *
     * Define full key for RTEHED2.
     *
     c     rhkey         klist
     c                   kfld                    $pwhse
     c                   kfld                    $pstat
     c                   kfld                    $ptype
     *
     * Define full key for LABEL94
     *
     c     LBkey         klist
     c                   kfld                    $pwhse
     c                   kfld                    rhrtid
     *
     * Define full key for IMPFPCKQ
     *
     c     ipqkey        klist
     c                   kfld                    $pwhse
     c                   kfld                    lbitem
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
