     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  UI315     Clear UCI Exceptions - Clear
     F*  12 September, 2006
     F*  Randy Haselhorst
     F*
     F*  IV354 - 1.00
     F*
     F*  ***  THIS PROGRAM'S PROCESS WILL MIRROR IV354.  ***
     F*
     F*  Revisions
414aAF*    05/15/00  RH   4.14a
     F*      - Recompiled, file INVSLOT changed.
416 AF*  09/25/01  RH   4.16
     F*    - Recompile - INVSLOT file changed.
     F*
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
     fuiiexcp1  uf   e           k disk
     f                                     rename(uierec:record)
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
     d                 ds
     d  $ukey                  1     50
     d  $iewhs                 1      3  0 inz(0)
     d  $iewhd                20     24
     d  $ieitm                 5     19
     d  $iesta                 4      4
     d  $ieasl                25     27
     d  $ieloc                28     30  0 inz(0)
     d  $ielvl                31     32  0 inz(0)
     d  $iehnd                33     34
     d  $ieuci                35     44
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
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
     C*
     c                   move      $puky         $ukey
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   exsr      zzdel
     c     error         ifeq      *off
     c                   exsr      zzupd
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
     C*----------------------------------------------------------------
     C*     IV35421  Exception cleared.
     C*
     c     zm21          begsr
     c                   move      'IV35421'     #msgid
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
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     c                   move      *off          forevr            1
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $iewhs
     c                   kfld                    $iewhd
     c                   kfld                    $ieitm
     c                   kfld                    $iesta
     c                   kfld                    $ieasl
     c                   kfld                    $ieloc
     c                   kfld                    $ielvl
     c                   kfld                    $iehnd
     c                   kfld                    $ieuci
     C*
     C*  Convert today's date into century format.
     C*
     c                   move      '*CURCMD '    $cvcmd
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   z-add     $cvd8o        today             8 0
     C*
     c                   move      #prog         $cvprg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     c     zzok          begsr
     c                   move      *blanks       $md
     c                   movea     msg(1)        $md(1)
     c                   movea     $ieitm        $md(20)
     c                   exsr      zm21
     c                   move      '*OK     '    $prtn
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     C*
     C*
     C*   Update record.
     C*
     c                   move      '4'           uiesta
     c                   update    record
404 Mc     endup         endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
**
Exception for Item
