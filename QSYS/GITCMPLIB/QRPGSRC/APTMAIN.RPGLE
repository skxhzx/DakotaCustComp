      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  APTMAIN   Middle man program to call DRIAPT interface
     *  September 29, 2011
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    11/09/28  RTR  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#APT
     D savever#        s                   like($apver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Program info data structure
     *
     *    Input Parameters
     *      $psubcmd     Sub-command.
     *      $pprogram    Calling program (the one that called interface)
     *      $pwhse       Warehouse number
     *      $plbl#       Label number
     *      $ptrn#       Transaction number
     *      $puser       User code
     *      $pemp#       Employee number
     *      $prteid      Route id
     *      $prte        Customer route number
     *      $plocation   Location
     *      $pseq#       Sequence number
     *
     *    Output Parameters
     *      $preturn     Return code
     *      $pmessage    Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd         10
     C                   parm                    $pprogram        10
     C                   parm                    $pwhse            3 0
     C                   parm                    $plbl#            7 0
     C                   parm                    $ptrn#            7 0
     C                   parm                    $puser           10
     C                   parm                    $pemp#            5 0
     C                   parm                    $prteid           5
     C                   parm                    $prte             5
     C                   parm                    $plocation       20
     C                   parm                    $pseq#            5 0
     C                   parm                    $preturn         10
     C                   parm                    $pmessage        60

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  See if we are closing down.

     C                   if        $psubcmd = '%CLOSE'
     C                             or $psubcmd = '*CLOSE'
     C                   exsr      zzzclose
     C                   goto      bottom
     C                   endif

     *  Initialize fields.


     C                   eval      savever# = $apver#
     C                   clear                   $aptds
     C                   eval      $apver# = savever#

     C                   eval      $apuser  = $puser
     C                   eval      $apjob   = #job
     C                   eval      $apjobn  = #jobnbr

     C                   eval      $apwhseu = *on
     C                   eval      $apwhse  = $pwhse

     C                   eval      $aplbl#u = *on
     C                   eval      $aplbl#  = $plbl#

     C                   eval      $aptrn#u = *on
     C                   eval      $aptrn#  = $ptrn#

     C                   eval      $apemp#u = *on
     C                   eval      $apemp#  = $pemp#

     C                   eval      $aplocationu = *on
     C                   eval      $aplocation = $plocation

     C                   eval      $apseq#u = *on
     C                   eval      $apseq#  = $pseq#

     C                   eval      $aprteidu = *on
     C                   eval      $aprteid = $prteid

     C                   eval      $aprte    = *on
     C                   eval      $aprte    = $prte

     *  Call DRI program.

     C                   exsr      zzzdricop

     *  Send back return code and message.

     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*APT '
     C                   eval      $drisubcmd  = '%CLOSE'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*CLOSE'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr

     C                   call(e)   'DRICOP'
     C                   parm      '*APT '       $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'D'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $aptds        parm      $aptds        $dridata

     C                   select

     C                   when      %error
     C                   eval      $drireturn = '*CALLERROR'
     C                   eval      $drimessage = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm

     C                   when      $drireturn <> '*OK'

     C                   endsl

     C     enddricop     endsr
