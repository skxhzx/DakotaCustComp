500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETUSER   Get user default values
     *  17 November 1999
     *  Max Blacknik
     *
     *  Revisions
     *
500 A*    01/20/06  DAS  5.00
     *      - Converted to ILE.
     *      - Added file PIRUSERA.
     *      - Added parameter $BPU. Note, this parm is only touched
     *        if it is on the parm list that called this program.
     *
500aA*    05/24/06  DAS  5.00a
     *      - Added parameter $LANG. Note, this parm is only touched
     *        if it is on the parm list that called this program.
     *
710aA*    12/19/17  JCJ  7.10a
     *      - Recompiled because of DataBase change to PIRUSERA.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program is identical to the corresponding program in
     *    the PIR library. It only needs to be recompiled to work
     *    with the revised employee productivity PIRUSER file.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiruser   if   e           k disk
500 AFpirusera  if   e           k disk

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $CODE    -  User code
     *
     *  Output parameters
     *
     *     $WHSE    -  Default warehouse
     *     $EMP#    -  Employee number
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
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $code            10
     C                   parm                    $whse             3 0
     C                   parm                    $emp#             5 0
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

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     $code         chain     piruser                            79
     C                   if        not *in79
     C                   eval      $whse = uswhse
     C                   eval      $emp# = usemp#
     C                   eval      $fnam = usfnam
     C                   eval      $init = usinit
     C                   eval      $lnam = uslnam
     C                   eval      $whdp = uswhdp
     C                   eval      $styp = usstyp
     C                   eval      $shft = usshft
     C                   eval      $crew = uscrew
     C                   eval      $nhrs = usnhrs
     C                   eval      $rtn = '*OK     '
     C                   else
     C                   eval      $whse = 1
     C                   eval      $emp# = *zeros
     C                   eval      $fnam = *blanks
     C                   eval      $init = *blanks
     C                   eval      $lnam = *blanks
     C                   eval      $whdp = *blanks
     C                   eval      $styp = *blanks
     C                   eval      $shft = *blanks
     C                   eval      $crew = *blanks
     C                   eval      $nhrs = *zeros
     C                   eval      $rtn = '*ERROR  '
     C                   endif

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
500aA
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
500aA
500aAC     skipusera     tag
     *
     C                   return
