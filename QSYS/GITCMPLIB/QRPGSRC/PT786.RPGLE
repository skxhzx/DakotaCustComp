     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT786     Remove transactions from FLGTRAN - Post
     *  25 April 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    04/25/05  MLB  5.00
     *      - Created.
530  *    10/22/09  GJA  5.30
     *      - Converted to RPGLE
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  49        - Error trying to delete a record.
     *  79        - Record not found or EOF.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fflgtran   up   e             disk
     Fpirtran   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertcnt                 1      3p 0
     D  erlcnt                 4      6p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D delete          s              1
     D forevr          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     *
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     * Check to see if we can delete this transaction.
     *
     C     fgtrn#        setll     pirtran                                79
     *    If Transaction no longer on file, remove from file.
     C                   if        not *in79
     C                   eval      delete = *on
     C                   else
     C                   eval      delete = *off
     C                   endif
     *
     * Delete Flag transaction entry.
     *
     C                   if        delete = *on
     C                   add       1             ertcnt
     C                   delete    fgrec                                49
     C                   endif
     *
     CLr                 exsr      zm10
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
     C                   eval      ertcnt = 0
     C                   eval      erlcnt = 0
     C                   eval      delete = *off
     C                   eval      forevr = *on
     *
     C                   endsr
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PT75010  Transaction and labels removed.
     *
     C     zm10          begsr
     C                   eval      #msgid = 'PT75010'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
