     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PO111     PO header (mark/unmark record for export)
     F*  11 July, 1997
     F*  Hemant Kapadia
     F*
     F*
     F*  Revisions
     F*
401 AF*    07/14/97  HNK  4.01
     F*      - ZZUHDR subroutine revised set the partial flag right.
     F*
415 AF*    03/31/01  DAS  4.15
     F*      - Revised to get PO header in main line.
     F*      - Added logic to see if a PO is allowed to be marked.
     F*      - Added command *MRKUNM to mark or unmark the P.O. based
     F*        on its current setting.
     F*      - Added command *ISMARKD to check to see if P.O. is marked
     F*
610aAF*    09/03/09  DAS  6.10
     F*      - Fix: Revised routine zzmark to unlock POHDR if $ok=*off.
650aAF*    04/05/13  RTR  6.50a
     F*      - Added command *MKPART to mark for partial export, Stat=4.
750a *    05/14/21  RTR  7.50a
     *      - Converted to RPGLE.
     *      - DockVue: Added update of POSTATUS table when PO added or
     *        updated.
     *
770aA*   08/27/22  TDC  770a
     *     - Add system option opdckv to control DockVue processing.
     *     - included 750a mods in 770a so we will know DockVue
     *       We will know that this code did not get installed in
     *       base 760
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
     FPOHDR     UF   E           K DISK
     FPODTL     IF   E           K DISK
     F                                     RENAME(PDREC:RECORD)
415 AFPODTL3    IF   E           K DISK
415 AFOPTIONS   IF   E           K DISK
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA /copy qcopysrc,c#stdsql
770aA*----------------------------------------------------------------
770aA*  System options
770aA*----------------------------------------------------------------
770aAd sysoptrec     E Ds                  Extname(options) prefix(SO_)
770aA *
770aA* Data structure
770aA*
770aAd sysoptions      ds
770aAd  opepm                  1      1
770aAd  oprf                   2      2
770aAd  opcapc                 3      3
770aAd  opletd                 4      4
770aAd  opwrnc                 5      5
770aAd  oprg1c                 6      8  1
770aAd  oprg2c                 9     11  1
770aAd  opimpi                12     12
770aAd  opicw                 13     13
770aAd  opmpck                14     14
770aAd  oprcdy                15     15  0
770aAd  oppkdy                16     16  0
770aAd  oprths                17     19  0
770aAd  opcrhs                20     22  0
770aAd  oppohs                23     25  0
770aAd  opiahs                26     28  0
770aAd  opmshs                29     31  0
770aAd  optbjq                32     32
770aAd  opishs                33     35  0
770aAd  opuci                 36     36
770aAd  opwrncr               37     37
770aAd  opicwr                38     38
770aAd  optrax                39     39
770aAd  optaxr                40     40
770aAd  opchkr                41     41
770aAd  opvoice               42     42
770aAd  opslot                43     43
770aAd  opdspl                44     44
770aAd  optbpm                45     45
770aAd  opsrte                46     46
770aAd  optrna                47     47
770aAd  opsrta                48     48
770aAd  optall                49     49
770aAd  opdckv                50     50
770aAd  opaepf                51     51
770aAd  opaepo                52     52
770aAd  opamrt                53     53
770aAd  sysoptend            117    117
770aA*----------------------------------------------------------------
770aA*  Variables
770aA*
770aAd dockvue         s               n   inz('0')
750 AD nostamp         s               z     inz
770aAd ocode           s              8
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
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
     D  $PPO                  22     30
415 AD  $PSEQ                 31     35  0
415 AD*----------------------------------------------------------------
415 AD*  *RCVLBL  -  Receiving options
415 AD*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPLPGM  -  Receiving label program.
     D*    OPUPCT  -  Ideal slot usage percentage.
     D*    OPPDEF  -  PIR minimum number of slots priority.
     D*    OPPBLD  -  PIR same build code priority.
     D*    OPPACT  -  PIR same activity zone priority.
     D*    OPFDEF  -  Fixed minimum number or slots priority.
     D*    OPFASL  -  Fixed same aisle priority.
     D*    OPFSID  -  Fixed same side priority.
     D*    OPFLVL  -  Fixed highest level priority.
     D*    OPPASL  -  PIR same aisle priority.
     D*    OPPFRC  -  Force PIR same aisle priority.
     D*    OPPLCN  -  Use generic license plates.
     D*    OPPCHM  -  Check chimney (Y,N)
     D*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
     D*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
     D*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
     D*
     D* Data structure
     D*
     D OPDATA          DS
     D  OPLPGM                 1     10
     D  OPUPCT                11     13  0
     D  OPPDEF                14     14  0
     D  OPPBLD                15     15  0
     D  OPPACT                16     16  0
     D  OPFDEF                17     17  0
     D  OPFASL                18     18  0
     D  OPFSID                19     19  0
     D  OPFLVL                20     20  0
     D  OPPASL                21     21  0
     D  OPPFRC                22     22
     D  OPPLCN                23     23
     D  OPPCHM                24     24
     D  OPPMIX                25     25
     D  OPAPCK                26     26
     D  OPFRCM                27     27
     D  OPTEND               117    117
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
     C*      $PCMD   *MARK    -  Mark P.O. for Export
     C*              *UNMARK  -  Unmark P.O. for Export
415 AC*              *MRKUNM  -  Mark or Unmark P.O. for Export
650aAC*              *MKPART  -  Mark partially received P.O. for Export
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains unique key for delete.
     C*
     C*    Returned Parameters
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
415 MC*              *OK      - Record updated successfully.
415 DC***                       Message sent to pgmq.
415 AC*              *YES     - Detail is marked (*ISMARKD).
415 AC*              *NO      - Detail is not marked (*ISMARKD).
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
415 AC                   MOVEL(P)  '*OK'         $PRTN
415 AC*
415 AC* Get P.O. header record. Get out if not found.
415 AC*
415 AC     $PCMD         IFNE      '*ISMARKD'
415 AC     PHKEY         CHAIN     POHDR                              79
415 AC     *IN79         IFEQ      *ON
415 AC                   MOVEL(P)  '*ERROR'      $PRTN
415 AC                   GOTO      BOTTOM
415 AC                   ENDIF
415 AC                   ENDIF
     C*
415 AC* Execute appropriate routine.
     C*
     C                   SELECT
     C     $PCMD         WHENEQ    '*MARK   '
     C                   EXSR      ZZMARK
     C     $PCMD         WHENEQ    '*UNMARK '
     C                   EXSR      ZZUMRK
415 AC     $PCMD         WHENEQ    '*MRKUNM '
415 AC                   EXSR      ZZMKUM
415 AC     $PCMD         WHENEQ    '*ISMARKD'
415 AC                   EXSR      ZZISMK
650aAC     $PCMD         WHENEQ    '*MKPART'
650aAC                   EXSR      ZZMKPT
     C                   ENDSL
     C*
415 AC     BOTTOM        TAG
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
770aA
770aA*  Get System options
770aA /free
770aA   ocode = '*SYSTEM ';
770aA   exec sql select * into :sysoptrec
770aA              from options
770aA             where opwhse = 0
770aA               and opcode = :ocode;
770aA
770aA   If sqlstt = sqlSuccess;
770aA     sysoptions = SO_opdata;
770aA   else;
770aA     opdckv = 'N';
770aA   endif;
770aA
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
770aA
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
415 AC*----------------------------------------------------------------
415 AC*      1100  All Detail lines not touched
415 AC*
415 ACSR   ZM0110        BEGSR
415 ACSR                 MOVE      'PO11001'     #MSGID
415 ACSR                 MOVE      '*DIAG  '     #MSGTP
415 ACSR                 MOVE      *BLANKS       $MD
415 ACSR                 EXSR      ZMSMSG
415 ACSR                 MOVE      #MSGK         $PMSG
415 ACSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
415 ACSR                 MOVE      *ON           FOREVR            1
     C*
     C*  Define key for POHDR file.
     C*
     CSR   PHKEY         KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    $PPO
     C*
     C*  Define partial key for PODTL file.
     C*
     CSR   PARTKY        KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    $PPO
415 AC*
415 AC*  Define full key for PODTL3 file.
415 AC*
415 ACSR   PDKEY         KLIST
415 ACSR                 KFLD                    PDWHSE
415 ACSR                 KFLD                    PDPO
415 ACSR                 KFLD                    PDSEQ
415 AC*
415 AC*  Define key for OPTIONS file.
415 AC*
415 ACSR   KEYOPS        KLIST
415 ACSR                 KFLD                    OPWHSE
415 ACSR                 KFLD                    OPCODE
     C*
     CSR                 ENDSR
415 AC*----------------------------------------------------------------
415 AC*
415 AC*  ZZCHKM   Check if PO can be marked.
415 AC*
415 ACSR   ZZCHKM        BEGSR
     C*
     C*   Get receiving options
     C*
     CSR                 Z-ADD     $PWHSE        OPWHSE
     CSR                 MOVE      '*RCVLBL '    OPCODE
     CSR   KEYOPS        CHAIN     OPREC                              79
     C*
     C*   If option record does not exist
     C*     then don't force user to touch everything.
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      'N'           OPFRCM
     CSR                 ENDIF
     C*
     C*   If force option is not 'Y'
     C*     then go ahead and mark it for export.
     C*
     CSR   OPFRCM        IFNE      'Y'
     CSR                 MOVE      *ON           $OK               1
     CSR                 GOTO      ENDCKM
     CSR                 ENDIF
     C*
     C*   Otherwise, check to ensure all detail lines have been touched
     C*
     CSR   PHKEY         SETLL     PODTL
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   PHKEY         READE     PODTL                                  79
     C*
     C*     If we run out of records, then everything has been touched.
     C*       then everything has been touched and P.O. can be marked.
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           $OK
     CSR                 LEAVE
     CSR                 ENDIF
     C*
     C*     If record doesn't exist in PODTL3
     C*       then it hasn't been touched and P.O. can't be marked.
     C*
     CSR   PDKEY         CHAIN     PODTL3                             78
     CSR   *IN78         IFEQ      *ON
     CSR                 MOVE      *OFF          $OK
     CSR                 LEAVE
     CSR                 ENDIF
     CSR                 ENDDO
     C*
     CSR   ENDCKM        TAG
     C*
     C*   Send back error if not allowed to mark P.O. for export.
     C*
     CSR   $OK           IFEQ      *OFF
     CSR                 MOVEL(P)  '*PGMQ'       $PRTN
     CSR                 EXSR      ZM0110
     CSR                 ENDIF
     C*
     CSR                 ENDSR
415 AC*----------------------------------------------------------------
415 AC*
415 AC*  ZZISMK   Check if PO detail line is marked.
415 AC*
415 ACSR   ZZISMK        BEGSR
     C*
     CSR                 Z-ADD     $PWHSE        PDWHSE
     CSR                 MOVE      $PPO          PDPO
     CSR                 Z-ADD     $PSEQ         PDSEQ
     CSR   PDKEY         CHAIN     PODTL3                             78
     CSR   *IN78         IFEQ      *ON
     CSR                 MOVEL(P)  '*NO'         $PRTN
     CSR                 ELSE
     CSR                 MOVEL(P)  '*YES'        $PRTN
     CSR                 ENDIF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZMARK   Mark for export.
     C*
     CSR   ZZMARK        BEGSR
415 ACSR                 EXSR      ZZCHKM
610aDC**         $OK       CABEQ*OFF      ENDMRK
610aACSR   $OK           IFEQ      *OFF
610aACSR                 UNLOCK    POHDR
610aACSR                 GOTO      ENDMRK
610aACSR                 ENDIF
     C*
415 DC**         PHKEY     CHAINPOHDR                79
415 DC**         *IN79     IFEQ *OFF
     CSR                 MOVE      '3'           PHSTAT
     CSR                 UPDATE    PHREC
750aA /free
750aA   // Set status for DockVue
770aA   if dockvue;
750aA     exec sql update postatus
750aA                 set posstat = 'X',
750aA                     posupdts = current_timestamp
750aA               where poswhs = :phwhse
750aA                 and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, 'X',
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
750aA /end-free
415 DC**                   ENDIF
415 DC**                   ENDSR
415 MCSR   ENDMRK        ENDSR
650aAC*----------------------------------------------------------------
650aAC*
650aAC*  ZZMKPT   Mark for export - partial receive
650aAC*
650aACSR   ZZMKPT        BEGSR
650aAC*
650aACSR                 MOVE      '4'           PHSTAT
650aACSR                 UPDATE    PHREC
750aA /free
750aA   // Set status for DockVue
770aA   if dockvue;
750aA     exec sql update postatus
770aD     //          set posstat = 'X',
770aD                 set posstat = :phstat,
750aA                     posupdts = current_timestamp
750aA               where poswhs = :phwhse
750aA                 and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aM     //         values (:phwhse, :phpo, 'X',
770aM                values (:phwhse, :phpo, phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
750aA /end-free
650aAC*
650aACSR   ENDMKP        ENDSR
415 AC*----------------------------------------------------------------
415 AC*
415 AC*  ZZMKUM   Mark/Unmark P.O. based on existing status.
415 AC*
415 ACSR   ZZMKUM        BEGSR
     C*
     CSR                 SELECT
     CSR   PHSTAT        WHENEQ    '3'
     CSR                 EXSR      ZZUMRK
     CSR                 OTHER
     CSR                 EXSR      ZZMARK
     CSR                 ENDSL
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUMRK   Unmark export status.
     C*
     CSR   ZZUMRK        BEGSR
     CSR                 MOVE      *OFF          ERROR             1
401 MCSR                 MOVE      *ON           FULL              1
     CSR                 MOVE      *OFF          PART              1
401 ACSR                 MOVE      *OFF          RECV              1
     CSR   PARTKY        SETLL     PODTL                              79
     CSR                 MOVE      *IN79         EOF               1
     CSR   EOF           DOWEQ     *OFF
     CSR   PARTKY        READE     PODTL                                  79
     CSR                 MOVE      *IN79         EOF
     CSR   *IN79         IFEQ      *OFF
401 ACSR   PDQRC1        IFLT      PDQOR1
401 ACSR                 MOVE      *ON           PART
401 ACSR                 MOVE      *OFF          FULL
401 ACSR                 ENDIF
401 AC*
401 ACSR   PDQRC2        IFLT      PDQOR2
401 ACSR                 MOVE      *ON           PART
401 ACSR                 MOVE      *OFF          FULL
401 ACSR                 ENDIF
401 AC*
401 ACSR   PDQRC3        IFLT      PDQOR3
401 ACSR                 MOVE      *ON           PART
401 ACSR                 MOVE      *OFF          FULL
401 ACSR                 ENDIF
401 AC*
401 ACSR   PDQRC1        IFGT      0
401 ACSR                 MOVE      *ON           RECV
401 ACSR                 ENDIF
401 AC*
401 ACSR   PDQRC2        IFGT      0
401 ACSR                 MOVE      *ON           RECV
401 ACSR                 ENDIF
401 AC*
401 ACSR   PDQRC3        IFGT      0
401 ACSR                 MOVE      *ON           RECV
401 ACSR                 ENDIF
401 AC*
401 DC*R         PDQRC1    IFGE PDQOR1
401 DC*R         PDQRC2    ANDGEPDQOR2
401 DC*R         PDQRC3    ANDGEPDQOR3
401 DC*R                   MOVE *ON       FULL
401 DC*R                   ITER
401 DC*R                   ENDIF
401 DC*R         PDQRC1    IFGT 0
401 DC*R         PDQRC1    ANDLTPDQOR1
401 DC*R                   MOVE *ON       PART
401 DC*R                   MOVE *OFF      FULL
401 DC*R                   LEAVE
401 DC*R                   ENDIF
401 DC*R         PDQRC2    IFGT 0
401 DC*R         PDQRC2    ANDLTPDQOR2
401 DC*R                   MOVE *ON       PART
401 DC*R                   MOVE *OFF      FULL
401 DC*R                   LEAVE
401 DC*R                   ENDIF
401 DC*R         PDQRC3    IFGT 0
401 DC*R         PDQRC3    ANDLTPDQOR3
401 DC*R                   MOVE *ON       PART
401 DC*R                   MOVE *OFF      FULL
401 DC*R                   LEAVE
401 DC*R                   ENDIF
401 AC*
     CSR                 ENDIF
     CSR                 ENDDO
401 AC*
401 ACSR   RECV          IFEQ      *OFF
401 ACSR                 MOVE      *OFF          FULL
401 ACSR                 MOVE      *OFF          PART
401 ACSR                 ENDIF
401 AC*
     C*
415 DC**         PHKEY     CHAINPOHDR                79
415 DC**         *IN79     IFEQ *OFF
     CSR   PART          IFEQ      *ON
     CSR                 MOVE      '1'           PHSTAT
     CSR                 ENDIF
     CSR   FULL          IFEQ      *ON
     CSR                 MOVE      '2'           PHSTAT
     CSR                 ENDIF
401 ACSR   PART          IFEQ      *OFF
401 ACSR   FULL          ANDEQ     *OFF
401 ACSR                 MOVE      '0'           PHSTAT
401 ACSR                 ENDIF
     CSR                 UPDATE    PHREC
750aA /free
750aA   // Set status for DockVue
770aA   if dockvue;
750aA     exec sql update postatus
770aD     //          set posstat = 'X',
770aM                 set posstat = :phstat,
750aA                     posupdts = current_timestamp
750aA               where poswhs = :phwhse
750aA                 and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
750aA /end-free
415 DC**                   ENDIF
     C*
     CSR   ENDUMR        ENDSR
     C*
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
