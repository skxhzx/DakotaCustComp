     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

      *----------------------------------------------------------------
      *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  DRICOP2     Dakota realtime interface program - Traffic cop
      *              **** Duplicate of DRICOP ***********
      *              **** Calls DRIMAIN2 ***********
      *  05 March 2007
      *  Dave Sommerville
      *
      *  Revisions
      *
416 A *    03/05/07  DAS  5.10
      *      - Created.
710aA *    04/18/17  LMC  7.10a
      *      - Added $dridata3
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Notes
      *
      *    This program is called from all Dakota programs that use the
      *    Dakota Real-time Interface (DRI).
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

416aA*----------------------------------------------------------------
416aA*  Data Formats
416aA*----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEMADJ
     D saveVer#        s                   like($iaver#)

416aA*----------------------------------------------------------------
416aA*  Verify Subprogram Variables.
416aA*----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vcode          s                   like($iacode)
     D $vsys           s              1

416aA*----------------------------------------------------------------
416aA*  Variables
416aA*----------------------------------------------------------------

     D error           s               n
     D skip            s               n

416aA*----------------------------------------------------------------
416aA*  Program info data structure
416aA*----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

      *----------------------------------------------------------------
      * Let the show begin.
      *----------------------------------------------------------------

     C     *ENTRY        PLIST
     C                   PARM                    $dricommand
     C                   PARM                    $drisubcmd
     C                   PARM                    $drisys2upd
     C                   PARM                    $driprogram
     C                   PARM                    $drireturn
     C                   PARM                    $drimessage
     C                   PARM                    $dridata
416cAC                   PARM                    $dridata2
710aAC                   PARM                    $dridata3

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------
416aA
416aA * Check special cases for whether to go on or not.
416aA
416aAC                   eval      error = *off
416aAC                   eval      skip = *off
416aA
416aAC                   if        $dricommand <> '*OPEN'  and
416aAC                             $dricommand <> '*CLOSE' and
416aAC                             $drisubcmd  <> '*OPEN'  and
416aAC                             $drisubcmd  <> '*CLOSE'
416aAC                   exsr      chkspclcases
416aAC                   if        error or skip
416aAC                   goto      bottom
416aAC                   endif
416aAC                   endif

      * Call appropriate processing program ...

416cAC                   select
416cA
416cAC                   when      %parms <= 7
     C***                call(e)   'DRIMAIN'
     C                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm                    $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C                   parm                    $dridata

416cAC                   when      %parms <= 8
416cAC***                call(e)   'DRIMAIN'
416cAC                   call(e)   'DRIMAIN2'
416cAC                   parm                    $dricommand
416cAC                   parm                    $drisubcmd
416cAC                   parm                    $drisys2upd
416cAC                   parm                    $driprogram
416cAC                   parm                    $drireturn
416cAC                   parm                    $drimessage
416cAC                   parm                    $dridata
416cAC                   parm                    $dridata2
416cA
710aAC                   when      %parms <= 9
710aAC                   call(e)   'DRIMAIN2'
710aAC                   parm                    $dricommand
710aAC                   parm                    $drisubcmd
710aAC                   parm                    $drisys2upd
710aAC                   parm                    $driprogram
710aAC                   parm                    $drireturn
710aAC                   parm                    $drimessage
710aAC                   parm                    $dridata
710aAC                   parm                    $dridata2
710aAC                   parm                    $dridata3
710aA
416cAC                   endsl

      * Check for calling error.

     C                   if        %Error
     C                   eval      $drireturn = '*ERCALLMAIN'
416aAC                   eval      $drimessage = 'Error occured on call to '
416aAC                                       + 'DRIMAIN'
416aAC                                       + '/' + %trim($dricommand)
416aAC                                       + ' from ' + #prog
     C                   Endif

      * If command or program weren't found, assume it is not used.

     C                   if        $drireturn = '*INVLDCMD'  or
     C                             $drireturn = '*NOPROGRAM'
     C                   eval      $drireturn = '*OK'
     C                   Endif

      * ... and return.

416aAC     bottom        tag
     C                   Return

416aA*----------------------------------------------------------------
416aA*          SUBROUTINES IN ALPHABETICAL ORDER
416aA*----------------------------------------------------------------

416aA*----------------------------------------------------------------
416aA*  chkspclcases  Check out special cases.
416aA*----------------------------------------------------------------

416aAC     chkspclcases  begsr

     C                   select

     *  Blocking "Dakota Only" adjustments from host.

     C                   when      $drisys2upd = 'H' and
     C                             $dricommand = '*ITEMADJ'

     C                   exsr      trapadj

     C                   endsl

     C     endchkspcl    endsr

416aA*----------------------------------------------------------------
416aA*  trapadj   Trap "Dakota Only" adjustment.
416aA*----------------------------------------------------------------

416aAC     trapadj       begsr

     *  Get system to update by verifying code.

     C                   eval      $itemadj = $dridata
     C                   call(e)   'VFYADJC'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $iacode       $vcode
     C                   parm      ' '           $vsys
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
416bDC**                 eval      error = *on
416bDC**                 eval      $drireturn = 'CALLERROR'
416bDC**                 eval      $drimessage = 'Error occured on call to '
416bDC**                                     + 'VFYADJC'
416bDC**                                     + '/' + %trim($vcommand)
416bDC**                                     + ' from ' + #prog
     C                   goto      endtrapadj

     C                   when      $vreturn <> '*OK'
416bDC**                 eval      error = *on
416bDC**                 eval      $iacodee = '1'
416bDC**                 eval      $drireturn = $vreturn
416bDC**                 eval      $drimessage = $vmessage
     C                   goto      endtrapadj

     C                   endsl

     *  If system to adjust is D=Dakota, then skip calling interface.
     *  Note: We only call this routine when trying to update host.

     C                   if        $vsys = 'D'
     C                   eval      skip = *on
     C                   eval      $drireturn = '*OK'
     C                   endif

     C     endtrapadj    endsr
