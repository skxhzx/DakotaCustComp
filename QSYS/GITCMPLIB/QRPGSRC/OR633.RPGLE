      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR633     Update unique piece number scan qty at export time.
     *  26 Aug 2009
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    08/26/09  RBD  5.20
     *      - Created
     *
640aA*    03/04/11  DAS  6.40
     *      - Added label# parameter.
     *        Re: With the new staging interfaces, at Cheney they
     *        will be exporting each transaction when it is closed.
     *        Therefore, we cannot wait until the route is finished
     *        to call this program. Instead, this program will be
     *        called from RH155ST for each label that is exported
     *        with the transaction.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordp3     uf   e           k disk
     Flabel     if   e           k disk

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D ctr             s              5  0
     D diff            s              5  0
     D forever         s               n
640aAD useLbl#         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
640aAC                   parm                    $plbl#            7 0

640aAC                   if        %parms >= 3
640aAC                   eval      useLbl# = *on
640aAC                   else
640aAC                   eval      useLbl# = *off
640aAC                   endif

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

640aAC                   if        useLbl#
640aAC     keyorp3wLbl   setll     ordp3
640aAC                   else
     C     keyorp3       setll     ordp3
640aAC                   endif

     C                   dow       forever = forever
640aAC                   if        useLbl#
640aAC     keyorp3wLbl   reade     ordp3
640aAC                   else
     C     keyorp3       reade     ordp3
640aAC                   endif

     C                   if        %eof
     C                   leave
     C                   endif

     C     orplbl        chain     label
     C                   if        not %found(label)
     C                   iter
     C                   endif

     C                   select

     *  When there's only 1 unique piece record for a label and the scan qty
     *  differs from the qty picked, update scan qty with qty picked.

     C                   when      orpttl = 1
     C                             and orpscn <> lbqpck
     C                   eval      orpscn = lbqpck
     C                   update    orprec

     *  When there are multiple unique piece records for the label and the
     *  qty picked is < total ORDP recs, the item has been shorted.  Loop
     *  through the ORDP recs, zeroing the scan qty as you go, stopping once
     *  you've zeroed the number of recs shorted.  For example, if there are
     *  5 ORDP recs for this label and the qty picked is 3, the last 2
     *  ORDP recs for this label will have their scan qty set to 0.

     C                   when      orpttl > 1
     C                             and lbqpck < orpttl
     C                   eval      diff = orpttl - lbqpck
     C                   eval      ctr  = 0
     C                   do        diff          ctr
     C                   eval      orpscn = 0
     C                   update    orprec
     C                   if        ctr = diff
     C                   leave
     C                   endif
     C     keyorp3a      reade     ordp3
     C                   if        %eof
     C                   leave
     C                   endif
     C                   enddo
     C     keyorp3a      setgt     ordp3

     C                   endsl

     C                   enddo

     *  Bye, Bye

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for ORDP3 file.

     C     keyorp3       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define partial key for ORDP3 file.

     C     keyorp3a      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lblbl#
640aA
640aA*  Define partial key for ORDP3 file using input parameters.
640aA
640aAC     keyorp3wLbl   klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    $prtid
640aAC                   kfld                    $plbl#

     C                   endsr
