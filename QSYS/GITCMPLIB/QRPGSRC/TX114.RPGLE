500 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TX114     TX Truck Builder FTP Status - Delete
     *  19 July 2006
     *  Robin Clark      Copied from FP114
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    04/06/06  MLB  5.00
     *      - Created.
510 A*    12/31/06  JCJ  5.10
     *      - Replaced TXFTPLOG with TXFTPLOG3.
     *      - added transaction number to delete message
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
510 AFtxftplog3 uf   e           k disk
     F                                     rename(txftpr:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $paddts               22     47
     D  $prte                 48     52
     D  $prtid                53     57
510 AD  $ptrn#                58     64  0
510 AD  $pstat                65     65
510 AD  $ptype                66     67
     *
     *----------------------------------------------------------------
     *  status message(s)
     *
     D stsmsg01        c                   'File not sent. Error cleared by use-
     D                                     r.'
     *----------------------------------------------------------------
     *  Working variables
     *
     D currstamp       s               z
     D $msgf           s             10
     D error           s              1
     D forevr          s              1
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
     *  Program info data structure
     *
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
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     record
510 AC                   if        %found(txftplog3)
     C                   exsr      zzdel
     C                   if        error = *off
     C                   eval      pffsts = '5'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg01
     C                   time                    currstamp
     C                   eval      pflexts = currstamp
     C                   update    record
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
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
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete corresponding records.
     *
     C     zzdel         begsr
     C                   eval      error = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
510 AC                   kfld                    $prte
     C                   kfld                    $prtid
510 AC                   kfld                    $ptrn#
     *
     C                   eval      forevr = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
510 AC                   eval      errmsg = %Trim('Transaction-') +
510 AC                                      %Trim(%editc($ptrn#:'Z')) +
510 AC                                      %Trim('-of Route-')  +
510 AC                                      %Trim($prte)
510 AC                   movea     errmsg        $md(1)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Route
