      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PS162     Truck build combine selection labels
     *  19 January 2007
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
510 A*    01/19/07  JCJ  5.10
     *      - Created
     *
510aA*    12/11/07  DAS  5.10a
     *      - Revised to pass the smallest label # to PS162M.
     *
520 A*    04/28/08  DAS  5.20   P#00046
     *      - Implemented version used at USF.
     *
640aA*    03/31/11  DAS  6.40
     *      - Revised to only work with 'N' records. Re: Program
     *        was taking a '1' record and combining it with an 'N' rec.
     *        We will assume (hope) a '1' record never gets split.
     *        Same change was made to PS162M.
640bA*    12/20/12  RH   6.40b
     *      - Enh: Add client code.
650aA*    01/30/13  DAS  6.50a
     *      - Revised to work with file WORKLBLG instead of WORKLBLD.
     *      - WORKLBLG adds field LWASL2 so OUT's and non-OUT's are
     *        sorted together.
     *      - WORKLBLG adds field LWUTYP N's and 1's will get sorted
     *        together.
     *      - Added LWASL2 to checked key fields so an OUT won't be
     *        combined with a non-OUT.
     *      - Removed change 640a.
     *----------------------------------------------------------------.
     *  Client Custom Revisions: MJ Kellner                           .
     *    12/20/12  RH   MJKa                                         .
     *      - Revised to not execute, set on LR & return. Do not want .
     *        to combine labels for split order items. Contract div   .
     *        wants to keep seperate.
MJKbA*    04/06/16  DAS  MJKb                                         .
     *      - Revised to allow combining when job is QZDASOINIT,      .
     *        which would indicate this was called through a GUI      .
     *        TruckBuilder(r) job.                                    .
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    When an order detail line is split between pallets, even if
     *    a user catches the split and puts both parts onto the same
     *    pallet, 2 label records still exist to pick the single
     *    detail line.  Therefore, this program needs to identify
     *    that situation and merge the split label records into a
     *    single label record.
     *
510aA*    When combining records, we will keep the smallest label #.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650aDF*orklbld  uf   e           k disk
650aMFworklblg  uf   e           k disk
      *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /COPY QCOPYSRC,Id#MJKELLN
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $ppal#                27     33  0

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
     *  Variables
     *----------------------------------------------------------------

     D count           s              3  0
     D error           s              1
     D forever         s               n
     D first           s               n
     D svcube          s              9  3
     D svqalc          s              5  0
     D svqpck          s              5  0
     D svswgt          s              9  2
     D svitem          s                   like(lwitem)
     D svseq           s                   like(lwseq)
     D svord           s                   like(lword)
     D svdisp          s                   like(lwdisp)
     D svctr#          s                   like(lwctr#)
650aAD svasl2          s                   like(lwasl2)
650aAD svutyp          s                   like(lwutyp)
510aAD svminlbl#       s                   like(lwlbl#)

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

MJKaAC                   if        client = mjkellner
MJKbAC                             and #job <> 'QZDASOINIT'
MJKaAC                   goto      jmpit
MJKaAC                   endif
     *  Initialize totals

     C                   eval      first = *on
     C                   eval      svcube = 0
     C                   eval      svswgt = 0
     C                   eval      svqalc = 0
     C                   eval      svqpck = 0
     C                   eval      count  = 0

     *  Whip through pallet records.

650aDC**   fileky1       setll     worklbld
650aMC     fileky1       setll     worklblg
     C                   dow       forever = forever
650aDC**   fileky1       reade     worklbld
650aMC     fileky1       reade     worklblg
     C                   if        %eof
     C                   leave
     C                   endif
650aD **
650aD **   Only work with 'N' records.
650aD **
650aDC**                 if        lwutyp <> 'N'
650aDC**                 iter
650aDC**                 endif

     *    First time through, set save values

     C                   if        first
     C                   eval      svitem = lwitem
     C                   eval      svseq  = lwseq
     C                   eval      svord  = lword
     C                   eval      svdisp = lwdisp
     C                   eval      svctr# = lwctr#
650aAC                   eval      svasl2 = lwasl2
650aAC                   eval      svutyp = lwutyp
510aAC                   eval      svminlbl# = lwlbl#
     C                   eval      first = *off
     C                   endif

     *    If order detail line changed
     *      Call program to combine records if necessary.

     C                   if        svitem <> lwitem
     C                             or svseq  <> lwseq
     C                             or svord  <> lword
     C                             or svdisp <> lwdisp
     C                             or svctr# <> lwctr#
650aAC                             or svasl2 <> lwasl2
650aAC                             or svutyp <> lwutyp
     C                   exsr      zzupd
     C                   eval      svitem = lwitem
     C                   eval      svseq  = lwseq
     C                   eval      svord  = lword
     C                   eval      svdisp = lwdisp
     C                   eval      svctr# = lwctr#
650aAC                   eval      svasl2 = lwasl2
650aAC                   eval      svutyp = lwutyp
510aAC                   eval      svminlbl# = lwlbl#
     C                   eval      svcube = 0
     C                   eval      svswgt = 0
     C                   eval      svqalc = 0
     C                   eval      svqpck = 0
     C                   eval      count  = 0
     C                   endif

     *    Update totals

510aAC                   if        lwlbl# < svminlbl#
510aAC                   eval      svminlbl# = lwlbl#
510aAC                   endif
     C                   eval      svcube = svcube + lwcube
     C                   eval      svswgt = svswgt + lwswgt
     C                   eval      svqalc = svqalc + lwqalc
     C                   eval      svqpck = svqpck + lwqpck
     C                   eval      count  = count + 1

     C                   enddo

     *    Call program to see if last record read
     *    needs to be combined.

     C                   exsr      zzupd

640bAC     jmpit         tag
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  *INZSR   Program initialization subroutine.
     *----------------------------------------------------------------
     C     *INZSR        begsr
640bA
640bA * Get client id.
640bA
640bAC                   call      'GETCLIENT'
640bAC                   parm                    client           10
     *
     *  Define key for main file.
     *
     C     fileky1       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    $ppal#
     C                   endsr

     *----------------------------------------------------------------
     *  zzupd    combine selection labels
     *----------------------------------------------------------------
     C     zzupd         begsr

     *  Call program to combine records.

     C                   if        count > 1
     C                   call      'PS162M'
     C                   parm      $pwhse        $pswhse           3 0
     C                   parm                    $prte
     C                   parm      $ppal#        $pspal#           7 0
     C                   parm                    svitem
     C                   parm                    svseq
     C                   parm                    svord
     C                   parm                    svdisp
     C                   parm                    svctr#
650aAC                   parm                    svasl2
650aAC                   parm                    svutyp
     C                   parm                    svqalc
     C                   parm                    svqpck
     C                   parm                    svcube
     C                   parm                    svswgt
510aAC                   parm                    svminlbl#
     C                   endif

     C                   endsr
