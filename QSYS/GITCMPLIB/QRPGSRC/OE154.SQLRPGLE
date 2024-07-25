      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *  OE154     Customer/Item Amazon Maintenance - Delete
     *  08 January 2015
     *  Lynn McMahon
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
650 A*    01/08/15  LMC  6.50
     *      - Enh: Date created.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
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
     D  $pcust                22     32  0
     D  $pcusta               22     32
     D* $pwhdp                33     37
     D  $pitem                33     47
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
     D                                     dim(128)
     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D custitm       e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D*error           s              1
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
      /free
        exec sql select * into :custitm
                 from custitm
                 where ciwhse = :$pwhse
                 //and ciwhdp = :$pwhdp
                 and cicust = :$pcust
                 and ciitem = :$pitem;
        if sqlstt = sqlsuccess;
          exsr zzdel;
          if error = *off;
              // delete the custitm record
              exec sql delete from custitm
                       where ciwhse = :$pwhse
                       //and cnwhdp = :$pwhdp
                       and cicust = :$pcust
                       and ciitem = :$pitem;
              exsr zzok;
          endif;
        else;
          exsr zm75;
          $prtn = '*PGMQ   ';
        endif;
        return;
      /end-free
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
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
     *     IT11220  Can not delete record.
     *
     C     zm1220        begsr
     C                   eval      #msgid = 'IT11220'
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
     C     error         cabeq     *on           enddel
     *
     C     enddel        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     $pcusta       $md(15)
     C                   movea     $pitem        $md(27)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Customer/Item
