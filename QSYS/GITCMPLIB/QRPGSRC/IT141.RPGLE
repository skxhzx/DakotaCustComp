     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT141     Item tie/high maintenance
     *  29 July, 1994
     *  Hemant Kapadia
     *
     *  Revisions:
     *
DRI A*    10/23/01  DAS  4.16
     *      - Total rewrite. Changed to call IT112.
     *
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *
416bA*    06/11/03  DAS  4.16b
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
     *
510 A*    07/02/07  JCJ  5.10
     *      - Added check for repack item type.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparms         ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
411 AD  $litpe               137    137
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
219 AD  $lxflg                37     37

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
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
     *      $PITEM  Item #
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
     C                   parm                    $pitem           15

     *  Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
416bAC                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = $pwhse
     C                   eval      $ititem   = $pitem

     C                   call(e)   'DRICOP'
     C                   parm      '*ITEM'       $dricommand
     C                   parm      '%GETMAIN'    $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
416bAC     $item2        parm      $item2        $dridata2

     C                   if        %error or
     C                             $drireturn <> '*OK'
     C                   goto      bottom
     C                   endif

     *  If item is not a slot item, use master item returned above.

     C                   if        $ittype <> ' ' and $ittype <> 'B'
510 AC                                            and $ittype <> 'R'
     C                   eval      $litem = $itmitem
     C                   else
     C                   eval      $litem = $pitem
     C                   endif

     *  Now call IT112 to do the dirty work.

     C                   eval      $lcmd = '*WORKTIE'
     C                   eval      $lprg  = #prog
     C                   eval      $lwhse = $pwhse
     C                   eval      $litpe = $ittype

     C                   call      'IT112'
     C                   parm                    $lparms

     C     bottom        tag
     C                   return
