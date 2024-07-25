     *----------------------------------------------------------------
     *
     *  ZH124     Zone maintenance - Delete
     *  11 June 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
520aA*    02/28/09  DAS  5.20a  P#00150
     *      - Recompiled because of change to ZONED
     *
530aA*    12/17/09  JCJ  5.30
     *      - Enh: Converted to RPG4.
     *      - Fix: Add *PICKLBA & *PICKLBB to Delete logic.
     *
720aA*    10/14/18  DAS  7.20
     *      -  Recompiled because of new ZONED fields
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
     Fzoneh     uf   e           k disk
     F                                     rename(zhrec:record)
     Fzoned1    uf   e           k disk
     Foptionz   uf   e           k disk
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
     D  $ptruk                22     31
     D  $pzone                32     37
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  ertnum                 1      4p 0
     D  erdesc                 5     24
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D error           s              1
     D forevr          s              1
     D kycod1          s                   like(opzcod)
     D kycod2          s                   like(opzcod)
530 AD kycod3          s                   like(opzcod)
530 AD kycod4          s                   like(opzcod)
     D pzone           s             10
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
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   exsr      zzdel
     C                   if        error = '0'
     C                   delete    record
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
     *   Delete zone detail records.
     *
     C     fileky        setll     zoned1
     C                   dow       forevr = forevr
     C     fileky        reade     zoned1                               7879
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   delete    zdrec                                77
     C                   enddo
     *
     *   Delete pick option record.
     *
     C     pickky        chain     optionz                            7978
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   if        not *in79
     C                   delete    opzrec                               77
     C                   endif
     *
530 M*   Delete *PICKLBL pick label option record.
     *
     C     lablky        chain     optionz                            7978
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   if        not *in79
     C                   delete    opzrec                               77
     C                   endif
530 A*
530 A*   Delete *PICKLBA pick label option record.
530 A*
530 AC     lblky3        chain     optionz                            7978
530 A*
530 A*     If record is locked then send message back and abort.
530 A*
530 AC                   if        *in78
530 AC                   exsr      zm75
530 AC                   eval      $prtn = '*PGMQ   '
530 AC                   eval      error = *on
530 AC                   goto      enddel
530 AC                   endif
530 A*
530 A*     Otherwise, delete record.
530 A*
530 AC                   if        not *in79
530 AC                   delete    opzrec                               77
530 AC                   endif
530 A*
530 A*   Delete *PICKLBB pick label option record.
530 A*
530 AC     lblky4        chain     optionz                            7978
530 A*
530 A*     If record is locked then send message back and abort.
530 A*
530 AC                   if        *in78
530 AC                   exsr      zm75
530 AC                   eval      $prtn = '*PGMQ   '
530 AC                   eval      error = *on
530 AC                   goto      enddel
530 AC                   endif
530 A*
530 A*     Otherwise, delete record.
530 A*
530 AC                   if        not *in79
530 AC                   delete    opzrec                               77
530 AC                   endif
     *
     C     enddel        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     *
     *  Define key for pick options.
     *
     C                   eval      kycod1 = '*PICK   '
     C     pickky        klist
     C                   kfld                    kycod1
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     *
     *  Define key for pick label options.
     *
     C                   eval      kycod2 = '*PICKLBL'
     C     lablky        klist
     C                   kfld                    kycod2
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
530 A*
530 A*  Define key for pick label options.
530 A*
530 AC                   eval      kycod3 = '*PICKLBA'
530 AC     lblky3        klist
530 AC                   kfld                    kycod3
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
530 AC                   kfld                    $pzone
530 A*
530 A*  Define key for pick label options.
530 A*
530 AC                   eval      kycod4 = '*PICKLBB'
530 AC     lblky4        klist
530 AC                   kfld                    kycod4
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
530 AC                   kfld                    $pzone
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   move      $pzone        pzone
     C                   movea     pzone         $md(7)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Zone
