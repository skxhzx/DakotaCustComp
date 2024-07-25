      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETEMPL   Get employee default values
     *  24 April 2003
     *  Dave Sommerville
     *
     *  Revisions
     *
500 A*    03/22/05  DAS  5.00
     *      - Added file PIRUSERA.
     *      - Added parameter $BPU. Note, this parm is only touched
     *        if it is on the parm list that called this program.
     *
500aA*    05/24/06  DAS  5.00a
     *      - Added parameter $LANG. Note, this parm is only touched
     *        if it is on the parm list that called this program.
     *
650 A*    01/28/14  RBD  6.50
     *      - Fix: seton LR so files will be closed.  Was causing
     *        problems when called for multiple warehouses.
     *
710 A*    12/19/17  MR   7.10a
     *      - Add Email/Text and Pictures flags for Trax.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiruser1  if   e           k disk
500 AFpirusera  if   e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $EMP#    -  Employee number
     *
     *  Output parameters
     *
     *     $WHSE    -  Default warehouse
     *     $CODE    -  User code
     *     $FNAM    -  Employee first name
     *     $INIT    -  Employee middle initial
     *     $LNAM    -  Employee last name
     *     $WHDP    -  Default department
     *     $STYP    -  Default section
     *     $SHFT    -  Default shift
     *     $CREW    -  Default crew
     *     $NHRS    -  Default hours per shift
     *     $RTN     -  Status code
     *                 *OK    - Valid userid
     *                 *ERROR - Invalid userid
500 A*     $BPU     -  Belt printer user (Y,N).
500 A*                 Note, this has to come at the end of the parm list
500 A*                 so that we can determine if it was sent or not.
500aA*     $LNG     -  Language type (EN, SP).
500aA*                 Note, this has to come at the end of the parm list
500aA*                 so that we can determine if it was sent or not.
710aA*     $EMAIL   -  Email/Text flag (Y/N)
710aA*     $PICS    -  Email/Text Pictures flag (Y/N)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $emp#             5 0
     C                   parm                    $whse             3 0
     C                   parm                    $code            10
     C                   parm                    $fnam            15
     C                   parm                    $init             1
     C                   parm                    $lnam            20
     C                   parm                    $whdp             5
     C                   parm                    $styp             1
     C                   parm                    $shft             6
     C                   parm                    $crew             6
     C                   parm                    $nhrs             3 1
     C                   parm                    $rtn              8
500 AC                   parm                    $bpu              1
500aAC                   parm                    $lng              2
710aAC                   parm                    $email            1
710aAC                   parm                    $pics             1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     $emp#         chain     piruser1
 1B  C                   if        %found
     C                   eval      $whse = uswhse
     C                   eval      $code = uscode
     C                   eval      $fnam = usfnam
     C                   eval      $init = usinit
     C                   eval      $lnam = uslnam
     C                   eval      $whdp = uswhdp
     C                   eval      $styp = usstyp
     C                   eval      $shft = usshft
     C                   eval      $crew = uscrew
     C                   eval      $nhrs = usnhrs
     C                   eval      $rtn = '*OK     '
 1X  C                   else
     C                   eval      $whse = 1
     C                   eval      $code = *blanks
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *zeros
     C                   eval      $rtn = '*ERROR  '
 1E  C                   endif

500aM*  Get PIRUSERA options if requested.
500 A
500 MC                   if        %parms < 13
500aAC                   goto      skipusera
500aAC                   endif
500aA
500aA*    Initialize PIRUSERA parameters.
500aA
500aMC                   if        %parms >= 13
500aAC                   eval      $bpu = 'N'
500aAC                   endif
500aA
500aMC                   if        %parms >= 14
500aAC                   eval      $lng = 'EN'
500aAC                   endif
710aA
710aAC                   if        %parms >= 15
710aAC                   eval      $email = 'N'
710aAC                   endif
710aA
710aAC                   if        %parms >= 16
710aAC                   eval      $pics = 'N'
710aAC                   endif
710aA
500aA*    Get PIRUSERA record. Skip to end if not found.
500aA
500 AC     $code         chain     pirusera
500aAC                   if        not %found
500aAC                   goto      skipusera
500aAC                   endif
500aA
500aA*    Move PIRUSERA fields to parameters.
500aA
500aMC                   if        %parms >= 13
500 AC                   eval      $bpu = usabpu
500 AC                   endif
500aA
500aAC                   if        %parms >= 14
500aAC                   eval      $lng = usalng
500aAC                   endif
710aA
710aAC                   if        %parms >= 15
710aAC                   eval      $email = usaeml
710aAC                   endif
710aA
710aAC                   if        %parms >= 16
710aAC                   eval      $pics = usapics
710aAC                   endif
710aA
500aAC     skipusera     tag
650 AC                   eval      *inlr = *on
     C                   return
