     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RX114     Clear Item Return Exceptions - Clear
     *  05 November, 2001
     *  Roxanne Harrison
     *
     *  SK114 - 1.00
     *
     *----------------------------------------------------------------
     *  Revisions
     *    11/05/01  RH   4.16
     *      - Created
     *
750 A*    05/25/21  MLB  7.50
     *      - Fix: Revised pgm to perform Reade loop instead of chain
     *        to ITMEXCP.  Whole order returns causes duplicate keys
     *        and multiple entries for same date/time can't be cleared.
     *      - Converted pgm to ILE.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fitmexcp   uf   e           k disk
     F                                     rename(exrec:record)
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
     D  $pitem                22     36
     D  $pgdte                37     44  0
     D  $pgtim                45     50  0
     D  $pwhdp                51     55
     D  $pstyp                56     56
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
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
750 A*----------------------------------------------------------------
750 A*  Working variables
750 A*
     D $msgf           s             10
     D curtim          s              6  0
     D error           s              1
     D forevr          s              1
     D today           s              8  0
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
750 AC     fileky        setll     itmexcp
750 AC                   dow       forevr = forevr
750 DC*    fileky        chain     record                             79
750 MC     FILEKY        reade     itmexcp
750 AC                   if        %eof(itmexcp)
750 AC*       Flag to clear not found.
750 AC                   if        error = '0'
750 AC                   exsr      zzok
750 AC                   else
750 AC                   exsr      zm75
750 AC                   move      '*PGMQ   '    $prtn
750 AC                   endif
750 AC*
750 AC                   leave
750 AC                   endif
750 AC*
750 AC*      Process only Open return exceptions.
750 DC*                  if        not *in79
750 MC                   if        exesta = '1'
     C                   exsr      zzupd
     C                   if        error = *off
     C                   exsr      zzok
750 DC*                  endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
750 AC                   endif
750 AC*
750 AC                   leave
     C                   endif
750 AC*
750 AC                   enddo
750 AC*
     C                   return
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
     *   Call user added initialization routine.
     *
     *R                   EXSR ZZINZ
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
     *     IV35421  Exception cleared.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV35421'
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
     C                   eval      forevr = *off
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pstyp
     C                   kfld                    $pitem
     C                   kfld                    $pgdte
     C                   kfld                    $pgtim
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    curtim
     *
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     exfdis        $md(6)
     C                   exsr      zm21
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *
     *   Update record.
     *
     C                   eval      excdte = today
     C                   eval      exctim = curtim
     C                   eval      exuser = #user
     C                   eval      exesta = '4 '
     C                   update    record                               99
     C                   if        *in99
     C                   eval      error = *on
     C                   endif
     C     endup         endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Slot
