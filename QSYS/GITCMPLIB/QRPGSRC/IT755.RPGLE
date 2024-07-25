     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT755     Remove exported item adjustments - Post
     *  10 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
530  *  10/22/09   GJA   5.30
     *      -Cleaned up and converted to RPGLE
     *
730 A*  07/13/19   MLB   7.30
     *      -Enh: Added custom client support.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse
DRY A*  07/13/19  MLB  DRY
     *      - Added file ITEMADJCW to cleanup process.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ITEMADJ
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fitemadj   up   e           k disk
DRY AFitemadjcw3uf   e           k disk    usropn
730 A*----------------------------------------------------------------
730 A*  Customer id
730 A*
730 AD @getcl          c                   const('GETCLIENT')
730 AD client          s             10
730 AD clientloc       s             10
730 A*
DRY A /copy qcopysrc,id#dairyla
730 A*
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
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
DRY AD forever         s               n   inz('0')
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
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
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     C                   if        iawhse <> $kwhse  or
     C                             iaudte >= $kdate
     C                   goto      bottom
     C                   endif
     *
     *  Delete exported item adjustments records.
     *
     C                   add       1             errecs
     C                   delete    iarec                                79
     *
     C     bottom        tag
DRY A*
DRY ACLr                 if        client = Dairyland
DRY ACLr                 exsr      zzclnitmadjcw
DRY ACLr                 endif
     *
     CLr                 exsr      zm0750
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
730 A*
730 A* Get client id.
730 A*
730 AC                   call      @getcl
730 AC                   parm                    client
730 AC                   parm                    clientloc
730 A*
DRY AC                   if        client = Dairyland
DRY AC                   if        not %open(itemadjcw3)
DRY AC                   open      itemadjcw3
DRY AC                   endif
DRY AC                   endif
DRY A*
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     C                   endsr
DRY A*
DRY A*----------------------------------------------------------------
DRY A*    ZZCLNITMADJCW  - Cleanup Chef's Warehouse Adjustment file.
DRY A*----------------------------------------------------------------
DRY A*
DRY AC     zzclnitmadjcw begsr
DRY A*
DRY AC     $kwhse        setll     itemadjcw3
DRY AC                   dow       forever = forever
DRY AC     $kwhse        reade     itemadjcw3
DRY AC                   if           %eof(itemadjcw3)
DRY AC                             or cwiaudte >= $kdate
DRY AC                   leave
DRY AC                   endif
DRY A*
DRY A*      Older than cutoff, purge from file.
DRY AC                   if        cwiaudte < $kdate
DRY AC                   delete    cwiarec                              77
DRY AC                   endif
DRY A*
DRY AC                   enddo
DRY A*
DRY AC                   endsr
DRY A*
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
     *     PIR0750  Records removed.
     *
     C     zm0750        begsr
     C                   eval      #msgid = 'PIR0750'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported inventory adjustments
