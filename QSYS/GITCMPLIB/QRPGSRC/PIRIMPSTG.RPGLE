      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIRDIR    Process IFS Directory - Call Import Programs
     *  10 October 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    02/07/14  MLB  6.50
     *      - Created.
650aA*    08/13/14  MLB  6.50a
     *      - Enh: Added support for pgm to process Import Total Qty
     *        Ordered (IMPQTYORD).
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
ccc A*    mm/dd/yy  iii  ccc
     *      -
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fstgbatch2 uf   e           k disk

     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D                 ds
     D errmsg                  1    128
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *
     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     D #msgid          s              7
     D #msgk           s              4
     D #msgkey         s              4  0
     D #msgtp          s              7
     D #pgmq           s             10
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D error           S              1A   inz('0')
     D dir             s               *
     D forever         S              1A   inz('1')
     D len             S              3s 0 inz(0)
     D msg             S             52A
     D $pcmd           S              8A
     D $pjobd          S             10A
     D $ppath          S            640A
     D $ppath1         S             80A
     D $ppath2         S             80A
     D $ppath3         S             80A
     D $ppath4         S             80A
     D $ppath5         S             80A
     D $ppath6         S             80A
     D $preturn        S              8A
     D $pwhse          S              3A   inz('000')
     D qcmd            S            640A

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pruntimeenv     10

     * Process Stage Batch File Looking for New Imports to Process.
     C                   eval      kystatus = 'R'
     C                   eval      kytype   = 'IMPITEM'
     C     keysb1        setll     stgbatch2
     C                   dow       forever = forever
     C     keysb1        reade     stgbatch2
     C                   select
     C                   when      %eof(stgbatch2)
     C                   leave
     *
     C                   other
     *
     C                   exsr      zzprocjobd
     *
     C                   select
     C                   when      sbtype = 'IMPITEM'
     C                   exsr      zzprocitem
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo

     * Process Stage Batch File Looking for New Imports to Process.
     C                   eval      kystatus = 'R'
     C                   eval      kytype   = 'IMPSTUF'
     C     keysb1        setll     stgbatch2
     C                   dow       forever = forever
     C     keysb1        reade     stgbatch2
     C                   select
     C                   when      %eof(stgbatch2)
     C                   leave
     *
     C                   other
     *
     C                   exsr      zzprocjobd
     *
     C                   select
     C                   when      sbtype = 'IMPSTUF'
     C                   exsr      zzprocstuf
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo

     * Process Stage Batch File Looking for New Imports to Process.
     C                   eval      kystatus = 'R'
     C                   eval      kytype   = 'IMPPO'
     C     keysb1        setll     stgbatch2
     C                   dow       forever = forever
     C     keysb1        reade     stgbatch2
     C                   select
     C                   when      %eof(stgbatch2)
     C                   leave
     *
     C                   other
     *
     C                   exsr      zzprocjobd
     *
     C                   select
     C                   when      sbtype = 'IMPPO'
     C                   exsr      zzprocpo
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo

     * Process Stage Batch File Looking for New Imports to Process.
     C                   eval      kystatus = 'R'
     C                   eval      kytype   = 'IMPROUTE'
     C     keysb1        setll     stgbatch2
     C                   dow       forever = forever
     C     keysb1        reade     stgbatch2
     C                   select
     C                   when      %eof(stgbatch2)
     C                   leave
     *
     C                   other
     *
     C                   exsr      zzprocjobd
     *
     C                   select
     C                   when      sbtype = 'IMPROUTE'
     C                   exsr      zzprocord
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo
650aA
650aA* Process Stage Batch File Looking for New Imports to Process.
650aAC                   eval      kystatus = 'R'
650aAC                   eval      kytype   = 'IMPQTYORD'
650aAC     keysb1        setll     stgbatch2
650aAC                   dow       forever = forever
650aAC     keysb1        reade     stgbatch2
650aAC                   select
650aAC                   when      %eof(stgbatch2)
650aAC                   leave
650aA*
650aAC                   other
650aA*
650aAC                   exsr      zzprocjobd
650aA*
650aAC                   select
650aAC                   when      sbtype = 'IMPQTYORD'
650aAC                   exsr      zzprocitmo
650aAC                   endsl
650aA*
650aAC                   endsl
650aA*
650aAC                   enddo

     C                   eval      *inlr = *on

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
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define partial key for STGBATCH1 file
     *
     C     *like         define    sbstatus      kystatus
     C     *like         define    sbtype        kytype
     C     keysb1        klist
     C                   kfld                    kystatus
     C                   kfld                    kytype
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0105  - Generic message id (50 character data field)
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZMPMSG  Send Message to FTP Import Message Queues.
     *
     C     zmpmsg        begsr
     *
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     *
     C                   eval      #msgkey = #msgkey + 1
     C                   eval      #msgk   = %editc(#msgkey:'X')
     *
     C                   call      'PUTMSGE'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCJOBD  Setup Job Description for import job.
     *
     C     zzprocjobd    begsr
     *
     C                   select
     C                   when      $pruntimeenv = '*STAGE'
     C                   eval      $pjobd = 'PIRJOBD'
     C                   when      $pruntimeenv = '*STAGETEST'
     C                   eval      $pjobd = 'PIRJOBT'
     C                   endsl
     *
     C                   select
     C                   when      sbwhse = 001
     *      Job Description set for Whse 001.
     C                   other
     C                   eval      $pjobd = %trim($pjobd) + %editc(sbwhse : 'X')
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCITEM  Process file extracted from directory
     *
     C     zzprocitem    begsr
     *
     *      Initialize file fields.
     C                   eval      #pgmq    = 'IMPITEM'
     C                   eval      $pcmd    = '*STGITM '
650aAC                   eval      $pwhse   = %editc(sbwhse : 'X')
     C                   eval      $ppath1  = sbbatid
     C                   eval      $ppath2  = $pjobd
     *
     *        Update status that batch placed on jobq queue.
     C                   eval      sbstatus = 'J'
     C                   update    sbrec
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = $preturn
     C                   exsr      zm0105
     C                   endif
     *
     C                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZPROCITMO  Process file extracted from directory
650aA*
650aAC     zzprocitmo    begsr
650aA*
650aA*      Initialize file fields.
650aAC                   eval      #pgmq    = 'IMPQTY'
650aAC                   eval      $pcmd    = '*STGQTYO'
650aAC                   eval      $pwhse   = %editc(sbwhse : 'X')
650aAC                   eval      $ppath1  = sbbatid
650aAC                   eval      $ppath2  = $pjobd
650aA*
650aA*        Update status that batch placed on jobq queue.
650aAC                   eval      sbstatus = 'J'
650aAC                   update    sbrec
650aA*
650aA*        File(s) found to submit import job for processing.
650aAC                   exsr      zzsbmimp
650aA*        Job submitted to batch successfully.
650aAC                   if        $preturn = '*OK'
650aAC                   else
650aA*        Error(s) submitting job to batch for processing.
650aAC                   eval      errmsg = $preturn
650aAC                   exsr      zm0105
650aAC                   endif
650aA*
650aAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCORD  Process Customer Orders file extracted from directory
     *
     C     zzprocord     begsr
     *
     *      Initialize file fields.
     C                   eval      #pgmq    = 'IMPORD '
     C                   eval      $pcmd    = '*STGRTE '
     C                   eval      $pwhse   = %editc(sbwhse : 'X')
     C                   eval      $ppath1  = sbbatid
     C                   eval      $ppath2  = $pjobd
     *
     *        Update status that batch placed on jobq queue.
     C                   eval      sbstatus = 'J'
     C                   update    sbrec
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = $preturn
     C                   exsr      zm0105
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCPO  Process P/O file extracted from directory
     *
     C     zzprocpo      begsr
     *
     *      Initialize file fields.
     C                   eval      #pgmq    = 'IMPPO  '
     C                   eval      $pcmd    = '*STGPO  '
     C                   eval      $pwhse   = %editc(sbwhse : 'X')
     C                   eval      $ppath1  = sbbatid
     C                   eval      $ppath2  = $pjobd
     *
     *        Update status that batch placed on jobq queue.
     C                   eval      sbstatus = 'J'
     C                   update    sbrec
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = $preturn
     C                   exsr      zm0105
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCSTUF  Process Import Slot StuffIt
     *
     C     zzprocstuf    begsr
     *
     *      Initialize file fields.
     C                   eval      #pgmq    = 'IMPSTUF'
     C                   eval      $pcmd    = '*STGSTUF'
     C                   eval      $pwhse   = %editc(sbwhse : 'X')
     C                   eval      $ppath1  = sbbatid
     C                   eval      $ppath2  = $pjobd
     *
     *        Update status that batch placed on jobq queue.
     C                   eval      sbstatus = 'J'
     C                   update    sbrec
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = $preturn
     C                   exsr      zm0105
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSBMIMP  Submit Import Job for Processing.
     *
     C     zzsbmimp      begsr
     *
     C                   call      'PIRSBMCL'
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $ppath1
     C                   parm                    $ppath2
     C                   parm                    $ppath3
     C                   parm                    $ppath4
     C                   parm                    $ppath5
     C                   parm                    $ppath6
     C                   parm      ' '           $preturn
     *
     C                   endsr
