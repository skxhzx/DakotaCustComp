     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

      *----------------------------------------------------------------
      *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  DRICOPL     Dakota realtime interface program - Legacy connection
      *  24 January 2002
      *  Dave Sommerville
      *
      *  Revisions
      *
416 A *    01/24/02  DAS  4.16
      *      - Created.
      *
416aA *    06/11/03  DAS  4.16a
      *      - Revised to identify multiple data parameters.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Notes
      *
      *    This program is called from all non-ILE Dakota programs
      *    that use the Dakota Real-time Interface (DRI).
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

416aA*----------------------------------------------------------------
416aA*  Variables
416aA*----------------------------------------------------------------

     D error           s               n

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
     C                   PARM                    datapart1       256
     C                   PARM                    datapart2       256
416aAC                   PARM                    datapart3       256
416aAC                   PARM                    datapart4       256

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------
416aA
      * Call ILE cop program ...

     C                   movel     datapart1     $dridata
     C                   move      datapart2     $dridata

416aAC                   if        %parms > 8
416aAC                   movel     datapart3     $dridata2
416aAC                   move      datapart4     $dridata2
416aAC                   endif

416aAC                   select
416aA
416aAC                   when      %parms <= 8
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm                    $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C                   parm                    $dridata

416aAC                   when      %parms <= 10
416aAC                   call(e)   'DRICOP'
416aAC                   parm                    $dricommand
416aAC                   parm                    $drisubcmd
416aAC                   parm                    $drisys2upd
416aAC                   parm                    $driprogram
416aAC                   parm                    $drireturn
416aAC                   parm                    $drimessage
416aAC                   parm                    $dridata
416aAC                   parm                    $dridata2
416aA
416aAC                   endsl

     C                   movel     $dridata      datapart1
     C                   move      $dridata      datapart2

416aAC                   if        %parms > 8
416aAC                   movel     $dridata      datapart3
416aAC                   move      $dridata      datapart4
416aAC                   endif

      * Check for calling error.

     C                   if        %Error
     C                   eval      $drireturn = '*ERCALLCOP'
416aAC                   eval      $drimessage = 'Error occured on call to '
416aAC                                       + 'DRICOP'
416aAC                                       + '/' + %trim($dricommand)
416aAC                                       + ' from ' + #prog
     C                   Endif

      * ... and return.

416aAC     bottom        tag
     C                   Return
