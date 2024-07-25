510aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PS162M    Truck build combine selection labels - Merge
     *  13 April 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    04/13/07  DAS  5.10
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
     *        Same change was made to PS162.
     *
650aA*    01/30/13  DAS  6.50z
     *      - Revised to not merge an OUT with a non-OUT label.
     *
650aA*    01/30/13  DAS  6.50a
     *      - Revised to work with file WORKLBLG instead of WORKLBLD.
     *      - WORKLBLG adds field LWASL2 so OUT's and non-OUT's are
     *        sorted together.
     *      - WORKLBLG adds field LWUTYP N's and 1's will get sorted
     *        together.
     *      - Added new fields to key.
     *      - Removed change 640a.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF*orklbld  uf   e           k disk
650aMFworklblg  uf   e           k disk

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

     D forever         s               n
     D first           s               n

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prte             5
     C                   parm                    $ppal#            7 0
     C                   parm                    $pitem           15
     C                   parm                    $pseq             5 0
     C                   parm                    $pord             7 0
     C                   parm                    $pdisp           12
     C                   parm                    $pctr#            7 0
650aAC                   parm                    $pasl2            3
650aAC                   parm                    $putyp            1
     C                   parm                    $pqalc            5 0
     C                   parm                    $pqpck            5 0
     C                   parm                    $pcube            9 3
     C                   parm                    $pswgt            9 2
510aAC                   parm                    $pminlbl#         7 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      first = *on
650aDC**   fileky2       setll     worklbld
650aMC     fileky2       setll     worklblg
     C                   dow       forever = forever
650aDC**   fileky2       reade     worklbld
650aMC     fileky2       reade     worklblg
     C                   if        %eof
     C                   leave
     C                   endif
650aD **
650aD **   Only work with 'N' records.
650aD **
650aDC**                 if        lwutyp <> 'N'
650aDC**                 iter
650aDC**                 endif

510aDC**                 if        first
510aMC                   if        lwlbl# = $pminlbl#
     C                   eval      lwcube = $pcube
     C                   eval      lwswgt = $pswgt
     C                   eval      lwqalc = $pqalc
     C                   eval      lwqpck = $pqpck
     C                   update    lwrec
     C                   eval      first = *off
     C                   else
     C                   delete    lwrec
     C                   endif

     C                   enddo

     C                   return

     *----------------------------------------------------------------
     *  *INZSR   Program initialization subroutine.
     *----------------------------------------------------------------

     C     *INZSR        begsr

     *  Define key for main file.

     C     fileky2       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    $ppal#
     C                   kfld                    $pitem
     C                   kfld                    $pseq
     C                   kfld                    $pord
     C                   kfld                    $pdisp
     C                   kfld                    $pctr#
650aAC                   kfld                    $pasl2
650aAC                   kfld                    $putyp

     C                   endsr
