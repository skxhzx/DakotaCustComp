      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PV212     PO Virtual Whse Pick - Delete
     *  31 March, 2010
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
530 A*  03/31/10  RH   5.30
     *   - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  XX        XXXXXXXX XXXXXXXXX
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     F*
     Fpovpck    UF   E           K DISK
     F                                     RENAME(povREC:RECORD)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D MSG             S             50    DIM(1) CTDATA PERRCD(1)
     d*
     D $pcode          s              2
     d*
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
     D  $pwhse                19     21  0
     D  $pvnum                22     31  0
     d  $pwhdp                32     36
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
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
.    D  #JOB                 244    253
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
     C     FILEKY        CHAIN     RECORD                             79
     C     *IN79         IFEQ      '0'
     C                   EXSR      ZZDEL
     C     ERROR         IFEQ      '0'
     C                   DELETE    RECORD
     C                   EXSR      ZZOK
     C                   END
     C                   ELSE
     C                   EXSR      ZM75
     C                   MOVE      '*PGMQ   '    $PRTN
     C                   END
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
     C*  ZZDEL    Delete corresponding records.
     C*
     CSR   ZZDEL         BEGSR
     CSR                 MOVE      '0'           ERROR             1
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     C*
     C*  Define key for main file.
     C*
     CSR   FILEKY        KLIST
     c                   kFld                    $pwhse
     c                   kFld                    $pvnum
     c                   kFld                    $pwhdp
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     CSR   ZZOK          BEGSR
     CSR                 MOVE      *BLANKS       $MD
     CSR                 MOVEA     MSG(1)        $MD(1)
     CSR                 MOVEA     $PCODE        $MD(15)
     CSR                 EXSR      ZM9803
     CSR                 MOVE      '*OK     '    $PRTN
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Virutal Whse
