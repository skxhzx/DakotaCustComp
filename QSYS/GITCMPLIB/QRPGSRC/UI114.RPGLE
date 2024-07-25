     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UI114     UCI Code maintenance - Delete
     *  25 August  2006
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
510aA*    09/08/06  JCJ  5.10a
     *      - Enh: Added UCIADJ file processing
510aA*    09/29/06  RAH  5.10b
     *      - Enh: Added UCILOG file processing
520 A*    08/11/08  JCJ  5.20
     *      - Fix: Moved incomming uci parm from / to positions.
700aA*    08/30/16  LMC  700a
     *      - Enh: UCILOG file was renamed to PUCILOG, so we could
     *             reuse UCILOG for our uci tracking.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fucicw     uf   e           k disk    rename(ucirec:record)
510aAFuciadj    o    e             disk
700aDF*ucilog    o    e             disk
700aMFpucilog   o    e             disk
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
520 D **$pucin                37     51
520 D **$psq2                 52     56  0
520 D **$puci                 57     66
520 MD  $puci                 52     61
510aAD  $pcode                67     68
510aA*----------------------------------------------------------------
510aA*  Called programs
510aA*
510aAD @cvtdt          c                   const('CVTDTE')
510aA*----------------------------------------------------------------
510aA*  Called program parameters
510aA*
510aAD $cvtdt          ds
510aAD  $cvcmd                 1      8
510aAD  $cvprg                 9     18
510aAD  $cvd6i                19     24
510aAD  $cvd8i                25     32
510aAD  $cvd6o                33     38  0
510aAD  $cvd8o                39     46  0
510aAD  $cvsto                47     64
510aAD  $cvrtn                65     72
510aAD  $cverm                73    132
510aAD  $cvmsg                73     76
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
     *  Variables
     *
510aAD today           s              8  0
     D curtim          s              6  0
     D $msgf           s             10
510bAD @Caller         S             10
510bAD @Counter        S             15  5
     D $ucmd           s              8
     D error           s              1
510aAD $ptype          s              1
     D curtime         s               z
     D currstamp       s               z
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
510aAC                   parm                    $ptype
     *----------------------------------------------------------------
     *  Main line
     *
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = '0'
     C                   delete    record
     C                   exsr      zzok

510aAC                   if        $ucmd = '*DLTADJ '
510aAC                   eval      uawhse = $pwhse
510aAC                   eval      uainbr = ucinbr
510aAC                   eval      uacode = 'D'
510aAC                   eval      uarscd = $pcode
510aAC                   eval      uaapgm = 'UI114'
510aAC                   eval      uatype = $ptype
510aAC                   eval      uaoitm = *blanks
510aAC                   eval      uanitm = uciitm
510aAC                   eval      uaowgt = *zeros
510aAC                   eval      uanwgt = uciwgt
510aAC                   eval      uadate = Today
510aAC                   eval      uatime = curtim
510aAC                   eval      uaedat = *zeros
510aAC                   eval      uaetim = *zeros
510aAC                   write     uacrec
510bAc                   exsr      writeucilog
510aAC                   endif
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

510bAC     UI866P        Plist
510bAC                   Parm                    @Caller
510bAC                   Parm                    @Counter

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
     C                   kfld                    $puci
510aA*
510aA*  Convert today's date into century format.
510aA*
510aAC                   eval      $cvcmd = '*CURCMD '
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   eval      today = $cvd8o
     C                   time                    curtim
510aA*
510aAC                   if        $pcmd = '*DLTADJ '
510aAC                   eval      $ucmd = '*DLTADJ '
510aAC                   eval      $pcmd = '*DELETE '
510bAc                   eval      ultflg = 'DELETE'
510aAC                   endif
     *
510bA * Determine Calling program
510bA
510bAC                   Eval      @Counter = 4
510bAC                   Eval      @Caller  = *Blanks

510bAC                   Call      'UI866'       UI866P
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     $puci         $md(15)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     O*----------------------------------------------------------------*********
510bA *
510bA *  Write PUCILOG record.
510bA
510bAC     writeucilog   begsr
510bA
510bAc                   eval      ulwhse = $pwhse
510bAc                   eval      ulinbr = ucinbr
510bAc                   eval      uliitm = uciitm
510bAc                   eval      ulcpgm = @caller
510bAc                   eval      ulcwgt = uciwgt
510bAc                   eval      uladte = ucirdt
510bAc                   eval      ulatim = ucirtm
510bAc                   eval      uluser = #user
510bAC                   eval      uljob  = #job
510bAc                   eval      uljnbr = #jobn
510bAc                   eval      ultype = *blank
510bAc                   eval      ulptyp = *blank
510bAc                   eval      ulupgm = 'UI114'
510bAc                   eval      ulpo = *blanks
510bAc                   eval      ulseq# = *zeros
510bAc                   eval      ulptrn = *zeros
510bAc                   eval      ullcn# = ucilcn
510bAc                   eval      ulord  = *zeros
510bAc                   eval      uloseq = *zeros
510bAc                   eval      ulstrn = *zeros
510bAc                   eval      ullbl# = *zeros
510bAc                   eval      ulcode = $pcode
510bA
510bAc                   write     ulrec
510bA
510bAC                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
UCI Code
