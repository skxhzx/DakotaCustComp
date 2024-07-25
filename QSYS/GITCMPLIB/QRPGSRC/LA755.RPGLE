     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LA755     Remove LABELDO records - Post
     *  26 October 2009
     *  Ginger Andrews
     *
     *  -This program will process through the LABELDO and if LABEL
     *   record no longer exist it will remove the LABELDO record.
     *   Created as a separate routine because some client do not
     *   have the LABELDO file.
     *----------------------------------------------------------------
     *  Revisions
     *
     *    10/26/09  GJA  5.30
     *      - Created
     *
530a *    01/25/10  GJA  5.30a
     *      - Fix:  Counter for removed records was too small-
     *              changed from PIR0750 to PIR0752
530b *    11/15/10  MLB  5.30b
     *      - Fix:  Corrected field name definitions for error msg info.
730aA*    10/14/19  DAS  7.30a
     *      - Revised to use labeldow
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
730aDF*abeldo   up   e           k disk
730aMFlabeldow  up   e           k disk
     Flabel90   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
530aDD**errecs                 1      3p 0
530bMD  errecs                 1      5p 0
530aDD**erdesc                 4     48
530bMD  erdesc                 6     50
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
     *-----VARIABLES--------------------------------------------------
     D $msgf           s             10
     D wkwhse          s                   like(lbowhse)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     *----------------------------------------------------------------
     * Main line
     *
     *    Delete records without corresponding label
     *
     C                   if        wkwhse=lbowhse
     C     keylbl        chain(n)  label90
     C                   if        not %found(label90)
     C                   delete    lborec
     C                   add       1             errecs
     C                   endif
     C                   endif
     *    EOF
     CLR                 exsr      zm0752
     CLR                 eval      *inlr=*on
     CLR                 return
     *
     *
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
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     C                   move      $pwhse        wkwhse
     *
     C     keylbl        klist
     C                   kfld                    lbowhse
     C                   kfld                    lbotrn#
     C                   kfld                    lbolbl#
     *
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
     *     PIR0752  Records removed.
     *
     C     zm0752        begsr
     C                   eval      #msgid = 'PIR0752'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Misc LABELDO records
