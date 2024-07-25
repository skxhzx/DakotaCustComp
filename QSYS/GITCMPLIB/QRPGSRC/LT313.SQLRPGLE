      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  LT313     License FIFO update - Special
     *  08 February 2017
     *  Lynn McMahon
     *
     *  This program will use the same logic as LT312 for setting
     *  a new expiration date for a license.
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
710aA*   02/08/17  LMC  7.10a
     *     - Created
710bA*   02/27/17  LMC  7.10b
     *     - Enh - If the licactive record has a zero expiration date
     *       bypass attempting to calculate a new expiration date.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flicactive8if   e           k disk
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Customer id
     *
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
      /copy qcopysrc,p.clcdur2
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Called programs
     *

     *----------------------------------------------------------------
     *  Called program parameters
     *

     *----------------------------------------------------------------
     *  Called program parameters
     *

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $cdCmd          s              8
     D $cdDatein       s              8  0
     D $cdTimein       s              6  0
     D $cdYears        s              3  0
     D $cdMonths       s              3  0
     D $cdDays         s              3  0
     D $cdHours        s              3  0
     D $cdMinutes      s              3  0
     D $cdSeconds      s              3  0
     D $cdDateout      s              8  0
     D $cdTimeout      s              6  0


     *----------------------------------------------------------------
     *  Working variables
     *
     D forever         s              1
     D AdjustUsrDays   s              3  0
     D AdjustMfgDays   s              3  0
     D AdjustDays      s              3  0
     D NewExpDate      s              8  0

     D chk4err         s               n
     D error           s               n
     D savever#        s                   like($slver#)
     D zmflag          s               n
     D zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3  0
     D $pItem          s             15
     D $pITFLGD        s              1
     D $pIMMFLG        s              1
     D $poldIMUDAY     s              3  0
     D $pnewIMUDAY     s              3  0
     D $poldIMMDAY     s              3  0
     D $pnewIMMDAY     s              3  0
     D $pReturn        s             10
     D $pMessage       s            200

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse      - Warehouse
     *      $pItem      - Item
     *      $pITFLGD    - Date Sensitive
     *      $pIMMFLG    - Mfg Dated
     *      $poldIMUDAY - current user days to sell
     *      $pnewIMUDAY - new user days to sell
     *      $poldIMMDAY - current mfg shelf life days
     *      $pnewIMMDAY - new mfg shelf life days
     *
     *    Returned Parameters
     *      $pMessage   - successful update of all active licenses
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse
     c                   parm                    $pItem
     c                   parm                    $pITFLGD
     c                   parm                    $pIMMFLG
     c                   parm                    $poldIMUDAY
     c                   parm                    $pnewIMUDAY
     c                   parm                    $poldIMMDAY
     c                   parm                    $pnewIMMDAY
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
     *
     *  If nothing has changed get out of here
     *
      /free
        if $poldImuday = $pnewImuday and
           $poldImmday = $pnewImmday;
          return;
        endif;
      /end-free
     *
     *  Determine the number of days to adjust the expiration date
     *
      /free
        AdjustUsrDays = 0;
        AdjustMfgDays = 0;
        AdjustDays = 0;
        // adjustment based on user days to sell
        AdjustUsrDays = $poldImuday - $pnewImuday;

        // adjustment based on Mfg shelf life days
        if $pIMMFLG = 'Y' and $poldIMMDAY <> $pnewIMMDAY;
          AdjustMfgDays = $pnewImmday - $poldImmday;
        endif;

        // total days to adjust expiration dat
        AdjustDays = AdjustMfgDays + AdjustUsrDays;
      /end-free
     *
     *  Lets get the active licenses
     *
      /free
        setll ($pWhse: $pItem) licactive8;
        dow forever = forever;
          reade ($pWhse: $pItem) licactive8;
          if %eof(licactive8);
            leave;
          endif;
710bA     if laexpd = 0;
710bA       iter;
710bA     endif;
          // lets calculate a new expiration date
          $cdcmd = '*ADD';
          $cddays = AdjustDays;
          clcdur2($cdcmd: laexpd: $cdtimein: $cdyears:
                  $cdmonths: $cddays: $cdhours: $cdminutes:
                  $cdseconds: $cddateout: $cdtimeout);
          NewExpDate = $cddateout;

          // time to set the new date
          exsr clr$slot;

          $slwhseu = *on;
          $slwhse  = lawhse;
          $slwhdpu = *on;
          $slwhdp  = lawhdp;
          $sldispu = *on;
          $sldisp  = ladisp;
          $slitemu = *on;
          $slitem  = $pitem;
          $slexpdu = *on;
          $slexpd  = NewExpDate;
          $slentdu = *on;
          $slentd  = laentd;
          $slprtyu = *on;
          $slprty  = laprty;
          $saToLcnsu = *on;
          $saToLcns  = lalcns;
          $saActionu = *on;
          $saAction  = 'FIF';
          $saOLcnsu  = *on;
          $saOLcns   = laolcns;
          $saEmp#u   = *on;
          $saEmp#    = 0;
          $satrn#u = *on;
          $satrn#  = 0;

          $dricommand = '*SLOT   ';
          $drisubcmd  = '%SETFIFO';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *on;
          exsr zzzdricop;

          if error;
          endif;
        enddo;
      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------

    A*----------------------------------------------------------------
    A*  clr$Slot   Clear $slot data structure fields
    A*----------------------------------------------------------------
    A
    AC     clr$Slot      begsr

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2

     C                   endsr



     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr

     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT   '
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*SLOT   '
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   else

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     *  Process any returned error conditions

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      $pMessage = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   endsl


     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off

     C     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
