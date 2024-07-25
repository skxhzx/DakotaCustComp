     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   Glen Ellyn, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  RU124     Work with Flag Entries - Delete
     F*  26 May 2004
     F*  Max Blacknik
     F*
     F*  SK114 - 1.00
     F*
     F*----------------------------------------------------------------
     F*  Revisions
417 AF*    05/26/04  MLB  4.17
     F*      - Created.
     F*
500 AF*    05/31/05  MLB  5.00
     F*      - Enh: Revised program to set LBVRFY = 'T' when runner
     F*        flag entry is deleted.
500aAF*    07/10/05  MLB  5.00a
     F*      - Enh: Revised program to receive flag type code and use
     F*        flag type code as part of key.
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
     FRUNNER    UF   E           K DISK
     F                                     RENAME(RUREC:RECORD)
     FLABEL     UF   E           K DISK
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
     D  $PWHDP                22     26
     D  $PLBLA                27     33
     D  $PLBL#                27     33  0
500aAD  $Ptype                34     34
     D currstamp       s               z
     D*
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
     C                   time                    currstamp
     C     FILEKY        CHAIN     RECORD                             79
     C     *IN79         IFEQ      *OFF
     C                   EXSR      ZZDEL
     C     ERROR         IFEQ      *OFF
     C                   eval      rustat = 'D'
     C                   eval      Rucdts = Currstamp
     C                   update    RECORD
     C*  Update failed. Send message.
     C                   if        %error
     C                   EXSR      ZM75
     C                   MOVE      '*PGMQ   '    $PRTN
     C                   else
     C                   EXSR      ZZOK
     C                   endif
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
     CSR                 MOVE      *OFF          ERROR             1
     C*
     C*  Clear runner flag entry in label record.
     C     $plbl#        chain     label
     C                   if        not %found
     C                   eval      error = *on
     C*
     C                   else
500 DC*                  eval      lbvrfy = ' '
500 MC                   eval      lbvrfy = 'T'
     C                   update    lbrec
     C                   if        %error
     C                   eval      error = *on
     C                   endif
     C*
     C                   endif
     C*
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
500cAC                   KFLD                    $Pwhse
500cAC                   KFLD                    $Ptype
     CSR                 KFLD                    $PLBL#
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZOK     Send back "successful" message.
     C*
     CSR   ZZOK          BEGSR
     CSR                 MOVE      *BLANKS       $MD
     CSR                 MOVEA     MSG(1)        $MD(1)
     CSR                 MOVEA     $PLBLA        $MD(12)
     CSR                 EXSR      ZM9803
     CSR                 MOVE      '*OK     '    $PRTN
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Flag Entry
