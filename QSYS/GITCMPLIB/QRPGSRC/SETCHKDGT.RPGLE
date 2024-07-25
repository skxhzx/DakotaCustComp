417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SETCHKDGT   Set label check digit
     *  29 Nobember 2006
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    11/29/06  DAS  5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel33   if   e           k disk
     Flabeldgt1 uf a e           k disk

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

     D $pwhse          s              3  0
     D count           s              4  0
     D dgtflag         s              1n   dim(999)
     D forever         s               n
     D lblcount        s              3  0
     D lsttrn#         s                    like(lbtrn#)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtid            5
     C                   move      $whse         $pwhse

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Delete all existing labeldgt records for route.

     C                   exsr      dellabeldgt

     *  Loop through labels for the route in transaction order.

     C     keyrte        setll     label33

     C                   eval      lblcount = 0
     C                   eval      lsttrn# = -1

     C                   dow       forever = forever

     C     keyrte        reade     label33
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only assign check digit to type 'O' and 'B' records.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   iter
     C                   endif

     C                   eval      lblCount = lblCount + 1

     *    Do some initialization when tran# changes
     *      or label count exceeds 999.
     *    Note, check digits only have to be unique within tran#.

     C                   if        lbtrn# <> lsttrn#
     C                             or lblcount > 999
     C                   eval      dgtflag = *off
     C                   eval      lblcount = 1
     C                   eval      lsttrn# = lbtrn#

     C                   endif

     *    Get unique check digit for label.

     C                   eval      count = 0
     C                   dow       forever = forever

     *      Get random number between 1 and 999.

     C                   call      'RANDOM2'
     C                   parm                    $pseed            9 9
     C                   parm                    $pmin             6 0
     C                   parm                    $pmax             6 0
     C                   parm                    $pnum             6 0

     *      Make sure it is unique. If not, loop and try again.
     *      Give up after 5000 attempts and accept number.

     C                   eval      count = count + 1

     C                   if        dgtflag($pnum)
     C                             and count < 5000
     C                   iter
     C                   endif

     *      Otherwise, accept number and get out of loop.

     C                   leave
     C                   enddo

     *    Write record to label check digit file.

     C                   eval      ldgwhs = lbwhse
     C                   eval      ldgrid = lbrte
     C                   eval      ldgtrn = lbtrn#
     C                   eval      ldglbl = lblbl#
     C                   eval      ldgdgt = $pnum
     C                   eval      ldgdup = dgtflag($pnum)
     C                   eval      ldgcnt = count
     C                   eval      ldgcntl= lblCount
     C                   write     ldgrec

     *    Set flag to identify number has been used.

     C                   eval      dgtflag($pnum) = *on

     C                   enddo

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for route

     C     keyrte        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define parameters for RANDOM2 routine.

     C                   eval      $pseed = 0
     C                   eval      $pmin  = 1
     C                   eval      $pmax  = 999
     C                   eval      $pnum  = 0

     C                   endsr

     *----------------------------------------------------------------
     *  dellabeldgt   Delete all existing LABELDGT records for route.
     *----------------------------------------------------------------

     C     dellabeldgt   begsr

     C     keyrte        setll     labeldgt1

     C                   dow       forever = forever
     C     keyrte        reade     labeldgt1
     C                   if        %eof
     C                   leave
     C                   else
     C                   delete    ldgrec
     C                   endif
     C                   enddo

     C                   endsr
