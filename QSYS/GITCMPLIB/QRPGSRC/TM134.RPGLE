     F*----------------------------------------------------------------
     F*
     F*  TM134     Truck pallet detail maintenance - Delete
     F*  02 June 1997
     F*  Roxanne Harrison
     F*
     F*  NOTE - This is not normal delete, uses ZZDEL to process main file.
     F*  Revisions
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        CHAIN INDICATOR
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FTRUCKD    UF   E           K DISK
     F                                     RENAME(TDREC:RECORD)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D MSG             S             50    DIM(1) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $PWHSE                19     21  0
     D  $PTRUK                22     31
     D  $PROW                 32     33  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERTNUM                 1      4P 0
     D  ERDESC                 5     24
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
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
     C     *ENTRY        PLIST
     C                   PARM                    $PARMS
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C*          FILEKY    CHAINRECORD               79
     C*          *IN79     IFEQ '0'
     C                   EXSR      ZZDEL
     C     ERROR         IFEQ      '0'
     C*                    DELETRECORD
     C                   EXSR      ZZOK
     C                   END
     C*                    ELSE
     C*                    EXSR ZM75
     C*                    MOVE '*PGMQ   '$PRTN
     C*                    END
     C                   RETURN
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID            7
     CSR                 PARM                    #MSGTP            7
     CSR                 PARM                    #MSGDT
     CSR                 PARM      $PPRG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     PIR7975  Error while deleting record.
     C*
     CSR   ZM75          BEGSR
     CSR                 MOVE      'PIR7975'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $PMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*     PIR9803  Deleted record successfully.
     C*
     CSR   ZM9803        BEGSR
     CSR                 MOVE      'PIR9803'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $PMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZDEL    Delete  records.
     C*
     CSR   ZZDEL         BEGSR
     CSR                 MOVE      '0'           ERROR             1
     CSR   FILEKY        SETLL     TRUCKD
     CSR   *IN79         DOUEQ     *ON
     CSR   FILEKY        READE     TRUCKD                               7879
     C*
     C*     If record is locked then send message back and abort.
     C*
     CSR   *IN78         IFEQ      *ON
     CSR                 EXSR      ZM75
     CSR                 MOVE      '*PGMQ   '    $PRTN
     CSR                 MOVE      *ON           ERROR
     CSR                 GOTO      ENDDEL
     CSR                 ENDIF
     C*
     C*     Otherwise, delete record.
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR                 DELETE    RECORD                               77
     CSR                 ENDIF
     CSR                 ENDDO
     C*
     CSR   ENDDEL        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  Define key for main file.
     C*
     CSR   FILEKY        KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    $PTRUK
     CSR                 KFLD                    $PROW
     C*
     C*  Define partial key for TRUCKD file.
     C*
     CSR   TDKEY         KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    $PTRUK
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     CSR   ZZOK          BEGSR
     CSR                 MOVE      *BLANKS       $MD
     CSR                 MOVEA     MSG(1)        $MD(1)
     CSR                 MOVE      $PROW         PROW              2
     CSR                 MOVEA     PROW          $MD(5)
     CSR                 EXSR      ZM9803
     CSR                 MOVE      '*OK     '    $PRTN
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Row
