     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HQ755     Remove Import Pick Slot Adjustment Records - Post
     *  11 November 2010
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    11/11/10  MLB  5.30
     *      - Created.
650aA*    11/19/13  MLB/RH  6.50
     *      - Change to use pckqadj1, missed in previous update
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
650aDF*ckqadj   up   e             disk
     Fpckqadj1  up   e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Working variables
     *
     D $kdate          s               d   datfmt(*iso)
     D $kstamp         s               z
     D $kwhse          s              3  0
     D $msgf           s             10
     D forevr          s              1
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      5p 0
     D  erdesc                 6     50
     D                 ds
     D  $ec                    1      2p 0
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date (YYYY-MM-DD format)
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate           10
     *
     *----------------------------------------------------------------
     * Main line
     *
     C                   if           pqhwhs <> $kwhse
     C                             or pqhids >= $kstamp
     C                   goto      bottom
     C                   endif
     *
     C                   add       1             errecs
     C                   delete(e) pqhrec
     *
     C     bottom        tag
     *
     CLr                 exsr      zm0752
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
      *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     C                   eval      forevr = *off
     *
     C                   move      $pwhse        $kwhse
     *
     C     *ISO          move      $pdate        $kdate
     C                   move      $kdate        $kstamp
     *
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     C                   endsr
     *
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0752  Records removed.
     *
     C     zm0752        begsr
     *
     C                   eval      #msgid = 'PIR0752'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Import pick slot adj rcds
