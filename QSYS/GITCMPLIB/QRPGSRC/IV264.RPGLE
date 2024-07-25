     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV264     Inventory Page Assignment - Assign multiple
     *  19 July 2006
     *  Roxanne Harrison
     *
     *  SK114 - 1.00
     *
     *
     *  Revisions
510bA*    07/21/06  RH   5.10b
     *      - Add CMD *Assign = Assign multiple pages, *Delete=Unassign
     *
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
     Finvpasn2  uf   e           k disk
     F                                     rename(ivarec:record)
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
     D  $pwhdp                22     26
     D  $ppag                 27     31  0
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
     *  Variables
     D $msgf           s             10
     D error           s              1
     D forevr          s              1
     D today           s              8  0
     D wopage          s              5
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
     C                   parm                    $paidt            8 0
     C                   parm                    $patem           10
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = *off
     C                   exsr      zzupd
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
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
     *     IV26401  Page assigned.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV26401'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IV26402  Page UnAssigned.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'IV26402'
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
     C                   kfld                    $ppag
     *
     *R         *LIKE     DEFN IVCASL    IKYASL
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
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
     C                   move      ivapag        wopage
     C                   movea     wopage        $md(6)
     C                   select
     C                   when      $pcmd = '*ASSIGN '
     C                   exsr      zm21
     C                   when      $pcmd = '*DELETE '
     C                   exsr      zm22
     C                   other
     C                   endsl
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     *
510b C                   select
510b C                   when      $pcmd = '*ASSIGN '
     C                   eval      ivasta = '2'
     C                   eval      ivatem = $patem
     C                   eval      ivaidt = $paidt
     *
510b C                   when      $pcmd = '*DELETE '
     C                   eval      ivasta = '1'
     C                   eval      ivatem = *blanks
     C                   eval      ivaidt = *zero
     C                   other
     C                   endsl
     *
     C                   time                    ivastm
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivasdt = $cvd8o
     *
     *   Update record.
     *
     C                   update    record
     C     endup         endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Page
