     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     F*----------------------------------------------------------------
     F*
     F*  GTS114    Global Tomcat server maintenance - Delete
     F*  22 February 2013
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
650  F*    02/22/13  DAS  6.50
     F*      - Created
     F*
700aAF*    08/28/15  DAS  7.00
     F*      - Recompiled because GLOTOMSRV file changed.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Chain indicator
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fglotomsrv uf   e           k disk
     f                                     rename(gtsrec:record)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d msg             s             50    dim(1) ctdata perrcd(1)
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $pcode                19     28
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   Not used
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains unique key for delete.
     C*
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*              *OK      - Record deleted successfully.
     C*                         Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   exsr      zzdel
     c     error         ifeq      *off
     c                   delete    record
     c                   exsr      zzok
     c                   end
     c                   else
     c                   exsr      zm75
     c                   move      '*PGMQ   '    $prtn
     c                   end
     c                   return
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid            7
     c                   parm                    #msgtp            7
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     PIR7975  Error while deleting record.
     C*
     c     zm75          begsr
     c                   move      'PIR7975'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
520a C*----------------------------------------------------------------
520a C*     IT11220  Can not delete record.
520a C*
520a c     zm1220        begsr
520a c                   move      'IT11220'     #msgid
520a c                   move      '*DIAG  '     #msgtp
520a c                   movea     errmsg        $md(1)
520a c                   exsr      zmsmsg
520a c                   move      #msgk         $pmsg
520a c                   endsr
     C*----------------------------------------------------------------
     C*     PIR9803  Deleted record successfully.
     C*
     c     zm9803        begsr
     c                   move      'PIR9803'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDEL    Delete corresponding records.
     C*
     c     zzdel         begsr
     c                   move      *off          error             1
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pcode
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     c     zzok          begsr
     c                   move      *blanks       $md
     c                   movea     msg(1)        $md(1)
     c                   movea     $pcode        $md(17)
     c                   exsr      zm9803
     c                   move      '*OK     '    $prtn
     c                   endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Global Tomcat Server
