     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIITEMADJ  Dakota realtime interface - item adjustments
     *  10 October 2001
     *  Dave Sommerville
     *
416  *    10/10/01  DAS  4.16
     *      - Created
     *
416aA*    10/29/01  DAS  4.16a
     *      - Revised to work with new adjustment code field: Sys to update
     *
416bA*    11/01/01  DAS  4.16b
     *      - Revised to create priority replenishments for *ADJUSTORD
     *
416cA*    01/07/02  DAS  4.16c
     *      - Moved all logic into DRISLOT interface.
     *      - *** New program should use *SLOT interface ***
     *
416dA*    06/11/02  DAS  4.16d
     *      - Recompiled because of change to C#SLOT.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEMADJ
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($iaver#)

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

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
416aA *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
416aAC                   parm                    $pmessage
     C                   parm                    $pdata

     C                   eval      $itemadj = $pdata

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Skip loading fields if trying to open or close.

     C                   if        $psubcmd = '*OPEN'  or
     C                             $psubcmd = '*CLOSE'
     C                   goto      skipflds
     C                   endif

     *  Move parameters into slot interface parameters.

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $iawhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $iawhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $iaslot

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $iaitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1  = $iaqty1
     C                   eval      $saqty2  = $iaqty2
     C                   eval      $saqty3  = $iaqty3

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = $iacwta

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = $iacode

     C                   eval      $samemou = *on
     C                   eval      $samemo  = $iamemo

     C                   eval      $sabyu = *on
     C                   eval      $saby  = $iaby

     C                   eval      $sadateu = *on
     C                   eval      $sadate = $iadate

     C                   eval      $satimeu = *on
     C                   eval      $satime = $iatime

     *  Call slot interface to perform adjustment.

     C     skipflds      tag

     C                   call(e)   'DRISLOT'
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C     $preturn      parm      $preturn      $drireturn
     C     $pmessage     parm      $pmessage     $drimessage
     C     $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRISLOT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   other
     C                   eval      $iawhsee = $slwhsee
     C                   eval      $iawhdpe = $slwhdpe
     C                   eval      $iaslote = $sldispe
     C                   eval      $iaiteme = $saiteme
     C                   eval      $iaqty1e = $saqty1e
     C                   eval      $iaqty2e = $saqty2e
     C                   eval      $iaqty3e = $saqty3e
     C                   eval      $iacwtae = $sacwtae
     C                   eval      $iacodee = $sacodee
     C                   eval      $iamemoe = $samemoe

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   if        $psubcmd = '*CLOSE'
     C                   eval      *inlr = *on
     C                   endif

     C                   eval      $pdata = $itemadj
     C                   return
