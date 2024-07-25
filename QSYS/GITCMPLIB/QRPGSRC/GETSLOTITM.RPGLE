      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETSLOTITM   Get slot item information.
     *  28 July 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    07/28/04  DAS  4.17
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warehouse
     *     $PITEM   -  Contract, Alias, Same Slot Breakdown or Different
     *                 Slot Breakdown item number.
     *
     *  Output parameters
     *
     *     $PBITM   - Base item number
     *     $PITYP   - Base item type
     *     $PDESC   - Base description
     *     $PPDSC   - Base pack description
     *     $PRETURN - *OK      -  Base item found
     *                otherwise an error occured.
     *     $PMESSAGE - Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pbitm           15
     C                   parm                    $pityp            1
     C                   parm                    $pdesc           30
     C                   parm                    $ppdsc           15
     C                   parm                    $preturn         10
     C                   parm                    $pmessage        60

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *    Initialize return parameters.

     C                   clear                   $pbitm
     C                   clear                   $pityp
     C                   clear                   $pdesc
     C                   clear                   $ppdsc
     C                   eval      $preturn = '*OK     '
     C                   eval      $pmessage = ' '

     *  Get slot item for item sent in.

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = $pitem

     C                   call(e)   'DRIITEM'
     C                   parm      '*GETSLOT'    $drisubcmd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   when      $drireturn <> '*OK'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   other
     C                   eval      $pbitm = $ititem
     C                   eval      $pityp = $ittype
     C                   eval      $pdesc = $itdesc
     C                   eval      $ppdsc = $itpdsc
     C                   endsl

     C                   return
