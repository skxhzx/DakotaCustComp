      *****************************************************************
      *
      * Program Name: USP2000 - Create a List of ODBC Jobs
      * Author: Thomas D. Chamberlain -
      * Date: January 13, 1999
      *
      * Nov. 2001 - Added V5R1 Support for Returning jobs IP Address (Bryan Dietz)
      * July 2004 - Fixed V5R3 Support                               (Bryan Dietz)
      * July 2004 - Added Message Subfile                            (Tom Chamberlain)
      * Nov. 2004 - Added selection by servicing user profile        (Bryan Dietz)
      * Dec. 2004 - Added number of open files                       (Bryan Dietz)
      * Jan. 2006 - fixed page up/down                               (Bryan Dietz)
      *
      * http://www.iseries-user.co.uk/API_Monthly/qusrtvus_rpg.txt
      *****************************************************************
      * Parameters:
      *
      *
      *****************************************************************
     h   Option(*SRCSTMT:*NODEBUGIO)

     FUSP2000FM CF   E             WORKSTN INFDS(DSPINF)
     F                                     SFILE(USP200001:RRN1)
      * Program Information
     D                SDS
     D PGM_PARMS         *PARMS
     D PGM_PROCS         *PROC
     D PGM_ROUTNE        *ROUTINE
     D PGM_STATUS        *STATUS
      * Display Information
     DDSPINF           DS
     D DSP_STATUS        *STATUS
     D KEY_PRESS             369    369
     D SFL_RRN               378    379B 0
      * Parameters
     D USER_PARM       S             10
     D SPACE_NAME      S             10
     D SPACE_LIBL      S             10
     D MODE            S              7
      *****************************************************************
      *Standard Parameters for Retrieve User Space
      *****************************************************************
     DQUAL_SPACE       DS
     D SPC_NAME                      10
     D SPC_LIB                       10    INZ('QTEMP')
      *
     D START_POS       S              9B 0
     D DATA_LEN        S              9B 0
     D X               S             15  0
     D RRN1            S              4  0
      * Returned Data Variable
     D@DATA            DS                  BASED(SPCPTR)
     D*DATA                    1   1024
     D    @offsethdr         117    120b 0
     D    @headrsize         121    124b 0
     D    @offsetlst         125    128b 0
     D    @numlstent         133    136b 0
     D    @lstentsz          137    140b 0

      * Pointer to Returned Variable
     D SPCPTR          S               *   inz(*null)
      * Work Fields
     D @Job_Name       S             10
     D @Job_User       S             10
     d found           s              2  0
     D Error_Msg       S             50
     D Max_RRN         S              4  0
     D Inf_Len         S              8B 0 inz(65535)
     D Format_N1       S              8    INZ('JOBL0100')
     D Format_N2       S              8    INZ('JOBI0600')
     D Job_Sts         S             10    INZ('*ACTIVE')
     D Len_Rcv         S             10i 0 INZ(322)
     D Qual_JN         S             26    INZ('*INT')
     D QCommand        S            256
     D QCmd_Len        S             15  5 INZ(256)
     D Cmd_Opt         S              7
     d elenb           S              9B 0
     d bin4            S             10i 0 inz(4)
     D MsgKey          s              4a
     D MsgTxt          s            256a   Varying
     D dsply52         S             52
      *****************************************************************
      *Type Definition for the User Space Generic Header.
      *****************************************************************
     d/COPY qsysinc/qrpglesrc,QUSGEN
      *****************************************************************
      *Record structure for Error Code Parameter
      *****************************************************************
     d/COPY qsysinc/qrpglesrc,QUSEC
      *****************************************************************
      *Type Definition for the JOBL0100 and JOBL0200 header section.
      *****************************************************************
     d/COPY qsysinc/qrpglesrc,QUSLJOB
      *****************************************************************
      *Type Definition for the JOBL0100 format.
     D*****************************************************************
     D******************************************************************
     D*Record structure for QUSRJOBI JOBI0600 format
     D******************************************************************
     DQUSQGL           DS                                                       Qwc Grp List
     D QUSGN01                 1     10                                         Grp Name
     DQUSI0600         DS                                                       Qwc JOBI0600
     D QUSBR05                 1      4B 0                                      Bytes Return
     D QUSBA05                 5      8B 0                                      Bytes Avail
     D QUSJN08                 9     18                                         Job Name
     D QUSUN07                19     28                                         User Name
     D QUSJNBR07              29     34                                         Job Number
     D QUSIJID05              35     50                                         Int Job ID
     D QUSJS14                51     60                                         Job Status
     D QUSJT08                61     61                                         Job Type
     D QUSJS15                62     62                                         Job Subtype
     D QUSJS16                63     70                                         Job Switch
     D QUSES00                71     71                                         End Status
     D QUSSN00                72     81                                         Subsys Name
     D QUSSL06                82     91                                         Subsys Lib
     D QUSCUN                 92    101                                         Curr Usrprf Name
     D QUSDE                 102    102                                         Dbcs Enabled
     D QUSEK                 103    103                                         Exit Key
     D QUSCK00               104    104                                         Cancel Key
     D QUSPRC                105    108B 0                                      Product Return Code
     D QUSURC                109    112B 0                                      User Return Code
     D QUSPGMRC              113    116B 0                                      Program Return Code
     D QUSSE02               117    126                                         Special Environment
     D QUSDN                 127    136                                         Device Name
     D QUSGPN                137    146                                         Group Profile Name
     D QUSGRP                        10    DIM(00015)
     D  QUSGN00                      10    OVERLAY(QUSGRP:00001)
     D QUSJUID               297    306                                         Job User ID
     D QUSJUIDS              307    307                                         Job User ID Setting
     D QUSJUIP               308    322                                         Job User IP ADDRESS
      *****************************************************************
     D* Named Constants
      *****************************************************************
     D* File Status
     D BAD_READ        C                   0011
     D GOOD_READ       C                   0000
     D TIME_OUT        C                   1331
     D REC_LOCKED      C                   1218
     D* Command Keys
     D CMD01           C                   X'31'
     D CMD02           C                   X'32'
     D CMD03           C                   X'33'
     D CMD04           C                   X'34'
     D CMD05           C                   X'35'
     D CMD06           C                   X'36'
     D CMD07           C                   X'37'
     D CMD08           C                   X'38'
     D CMD09           C                   X'39'
     D CMD10           C                   X'3A'
     D CMD11           C                   X'3B'
     D CMD12           C                   X'3C'
     D CMD13           C                   X'B1'
     D CMD14           C                   X'B2'
     D CMD15           C                   X'B3'
     D CMD16           C                   X'B4'
     D CMD17           C                   X'B5'
     D CMD18           C                   X'B6'
     D CMD19           C                   X'B7'
     D CMD20           C                   X'B8'
     D CMD21           C                   X'B9'
     D CMD22           C                   X'BA'
     D CMD23           C                   X'BB'
     D CMD24           C                   X'BC'
     D ENTER           C                   X'F1'
     D PAGEUP          C                   X'F4'
     D PAGEDOWN        C                   X'F5'
      *****************************************************************
     **-- Send program message:  ---------------------------------------------**
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  SpMsgId                       7a   Const
     D  SpMsgFq                      20a   Const
     D  SpMsgDta                    128a   Const
     D  SpMsgDtaLen                  10i 0 Const
     D  SpMsgTyp                     10a   Const
     D  SpCalStkE                    10a   Const Options( *VarSize )
     D  SpCalStkCtr                  10i 0 Const
     D  SpMsgKey                      4a
     D  SpError                      10i 0 Const
     **-- Remove program message:  -------------------------------------------**
     D RmvPgmMsg       Pr                  ExtPgm( 'QMHRMVPM' )
     D  RpMsgQ                      276a   Const
     D  RpStack                      10i 0 Const
     D  RpMsgKey                      4a   Const
     D  RpMsgRmv                     10a   Const
     D  RpError                      10i 0 Const
     **
     d openfiles       ds         65535
     d  BYTESRETURNED          1      4b 0
     d  BYTESAVAIL             5      8b 0
     d  FILESAVAIL             9     12b 0
     d  OFFSET                13     16b 0
     d  FILESOPEN             17     20b 0
     d  LENGTH                21     24b 0
     d JIDF0100INFO    ds
     d  JIDJoBNAME                   10    INZ('*INT')
     d  JIDUSERNAME                  10
     d  JIBJOBNUMB                    6
     d  JIDINTJOBID                  16
     d  JIDRESERVED                   2    INZ(*ALLX'00')
     d  JIDTHREADIND                 10I 0 INZ(2)
     d  JIDTHREADIDEN                 8    INZ(*ALLx'00')
     D API_Err         DS
     d  ErrBytes               1      4b 0
     d  ErrBytesAva            5      8b 0
     d  Exception              9     15
     d  Reserve               16     16
     d  Data                  17    271
      *****************************************************************
      * Main Program
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    @Job_Name
     C                   Parm                    @Job_User
      *
     C                   Eval      bmd     = 1
     C                   Eval      @PGMQ     = '*'
     c                   Eval      QUSJN00   = 'QZDASOINIT'
     c                   Eval      QUSUN00   = '*ALL  '
     c                   Eval      QUSJNBR00 = '*ALL  '

     C                   If        @Job_Name <> '*ODBC'
     C                   Eval      QUSJN00 = @Job_Name
     C                   Endif
      * Load the User Space - Initial Load
     C                   Exsr      $Load_US
      * Display the Data
     C                   Exsr      $Display
      * End of Program
     C                   Eval      *INLR = *On
     C                   Return
      *****************************************************************
      * Display the List
      *****************************************************************
     C     $Display      Begsr
      * Display the Screen
     C                   Dou       KEY_PRESS = CMD03 or
     C                             KEY_PRESS = CMD12
      * Display
     C                   Write     USP200003
     C                   Exfmt     USP200002
      * F5 - Refresh
     C                   If        KEY_PRESS = CMD05
     C                   Eval      bmd     = 1                                  back to the top
      * Load the User Space - Initial Load
     C                   Exsr      $Load_US
     C                   Endif
      * Subfile Processing
     C                   If        *IN(40)
     C                   Exsr      $Sfl_Proc
     C                   Endif
     C                   Enddo
      *
     C                   Endsr
      *****************************************************************
      * Subfile Processing
      *****************************************************************
     C     $Sfl_Proc     Begsr
      *
     C                   Readc     USP200001                              99
     C                   Dow       *IN(99) = *Off
      *
     C                   Eval      Cmd_Opt = *Blanks
     C                   Select
     C                   When      Option = 1
     C                   Eval      Cmd_Opt = '*STSA'
     C                   When      Option = 2
     C                   Eval      Cmd_Opt = '*DFNA'
     C                   When      Option = 3
     C                   Eval      Cmd_Opt = '*RUNA'
     C                   When      Option = 4
     C                   Eval      Cmd_Opt = '*SPLF'
     C                   When      Option = 10
     C                   Eval      Cmd_Opt = '*JOBLOG'
     C                   When      Option = 11
     C                   Eval      Cmd_Opt = '*PGMSTK'
     C                   When      Option = 12
     C                   Eval      Cmd_Opt = '*JOBLCk'
     C                   When      Option = 13
     C                   Eval      Cmd_Opt = '*LIBL'
     C                   When      Option = 14
     C                   Eval      Cmd_Opt = '*OPNF'
     C                   When      Option = 15
     C                   Eval      Cmd_Opt = '*FILOVR'
     C                   When      Option = 16
     C                   Eval      Cmd_Opt = '*CMTCTL'
     C                   When      Option = 99
     C                   Eval      Cmd_Opt = *Blanks
     C                   Exsr      $Kill_Job
     C                   Endsl
      * Was the Option Valid?
     C                   If        Cmd_Opt <> *Blanks
     C                   Exsr      $Proc_Cmd
     C                   Endif
      * Update the Option
     C                   Eval      OPTION = 0
     c                   if        bmd > max_rrn
     c                   eval      bmd = 1
     c                   endif
     C                   Update    USP200001
      * Next Record
     C                   Readc     USP200001                              99
     C                   Enddo
      *
     C                   Endsr
      *****************************************************************
      * Process the Command
      *****************************************************************
     C     $Proc_Cmd     Begsr
      * Build the Command
     C                   Eval      QCommand = 'WRKJOB JOB(' +
     C                             %TRIM(QUAL_JOB) + ') OPTION(' +
     C                             %TRIM(Cmd_Opt) + ')'
      * Set the Length
     C                   Eval      QCmd_Len = %len(QCommand)
      * Execute the Command
     C                   Call      'QCMDEXC'                            69
     C                   Parm                    QCommand
     C                   Parm                    QCmd_Len
      *
     c                   eval      bmd = rrn1
     C                   Endsr
      *****************************************************************
      * Kill a Job
      *****************************************************************
     C     $Kill_Job     Begsr
      * Build the Command
     C                   Eval      QCommand = 'ENDJOB JOB(' +
     C                             %TRIM(QUAL_JOB) + ') OPTION(*IMMED)'
      * Set the Length
     C                   Eval      QCmd_Len = %len(QCommand)
      * Execute the Command
     C                   Call      'QCMDEXC'                            69
     C                   Parm                    QCommand
     C                   Parm                    QCmd_Len
      *
     C                   Endsr
      *****************************************************************
      * Load the User Space with the Job List
      *****************************************************************
     C     $Load_US      Begsr
      * Clear the Error Message Subfile
     C                   CallP     RmvPgmMsg( '*'
     C                                      : *Zero
     C                                      : *Blanks
     C                                      : '*ALL'
     C                                      : *Zero
     C                                      )
      *
      * Set the User Space Name
     C                   Eval      SPACE_NAME = 'QJOBLIST'
     C                   Eval      SPC_NAME = SPACE_NAME
      * Build the User Space
     C                   Call      'USP0001'
     C                   Parm      '*CREATE'     MODE
     C                   Parm                    SPC_NAME
      * List the Current Jobs
     C                   Call      'QUSLJOB'
     C                   Parm                    QUAL_SPACE
     C                   Parm                    Format_N1
     C                   Parm                    QUSLH
     C                   Parm                    JOB_STS
     C                   Parm                    QUSEC
      * Process the User Space
     C                   Exsr      $Proc_US
      * Delete the User Space
     C                   Call      'USP0001'
     C                   Parm      '*DELETE'     MODE
     C                   Parm                    SPC_NAME
      *
     C                   Endsr
      *****************************************************************
      * Process the User Space
      *****************************************************************
     C     $Proc_US      Begsr
      * Clear the SubFile
     C                   Exsr      $Clear_Sfl
      * Get the Pointer
     C                   Exsr      $Get_Point
      * Here, the offset is set for:
      * The retrieved list
     C                   Eval      @offsetlst = (@offsetlst + 1)
      * and the header information (if applicable to your API)
     C                   Eval      @offsethdr = (@offsethdr + 1)
      * Start the Loop
     C                   Do        @numlstent
      * Get the List Element
     C                   Exsr      $Get_Data
      * Get the User Job Information
     C                   Exsr      $Get_User_Job
      *
     C                   If        QUSEI <> 'CPF3C51'
      *   Find out if *ALL or a Generic(*) or whole name entered        
      *   for the Servicing User Parm                                   
     C                   If        @Job_User = '*ALL    '
     C                   Exsr      $Write_SF
      * Else (User = *All)
     C                   Else
      * Check use of Partial User Name (Generic)
     C                   Eval      found = %scan('*' : @Job_User : 2)
     C                   If        found > 1
      * Check for Partial User Name
     C                   If        %subst(QUSCUN    : 1 : found - 1) =
     C                             %subst(@Job_User : 1 : found - 1)
     C                   Exsr      $Write_SF
     C                   Endif
      * Else (Found > 1)
     C                   Else
      * Check for the Full User Name
     C                   If        QUSCUN = @Job_User
     C                   Exsr      $Write_SF
     C                   Endif
      * EndIf (Found > 1)
     C                   Endif
      * EndIf (User = *ALL)
     C                   Endif
      * EndIf (CPF Error)
     C                   Endif
      * Update the Off-Set
     C                   Eval      @offsetlst = @offsetlst + @lstentsz
      * Loop
     C                   Enddo
      *
     C                   Endsr
      *****************************************************************
      * Write the Sub-File Record
      *****************************************************************
     C     $Write_SF     Begsr
      *
     C                   Eval      RRN1 = RRN1 + 1
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Get List Element-' + QUSEI
     C                   Endif
      * Build the Job Name for the Call's to the WRKJOB Commend
     C                   Eval      QUAL_JOB =  QUSJNBR07 + '/' +
     C                               %TRIM(QUSUN07) + '/' + QUSJN08
      *  *Call the QDMLOPNF API to get the open files for this job     
     C                   Move      QUSIJI        JIDINTJOBID
     C                   Call      'QDMLOPNF'
     C                   Parm                    OPENFILES
     C                   Parm                    INF_Len
     C                   Parm      'OPNF0100'    Api_Format        8
     C                   Parm                    JIDF0100info
     C                   Parm      'JIDF0100'    JOBFORMAT         8
     C                   Parm                    API_ERR
      * Check for Error
     C                   If        errbytesava = 0
     C                   Eval      openfil = filesopen
     C                   EndIf
      * *      thanks to BOB PASCAS @ rpgiv.org for the above code block
     C                   Eval      *IN40 = *On
      * Write the Sub-File Record
     C                   Write     USP200001
      * Save the Maximum Records
     C                   Eval      Max_RRN = RRN1
      *
     C                   Endsr
      *****************************************************************
      * Get Data from the User Space
      *****************************************************************
     C     $Get_Data     Begsr
      *
     C                   Call      'QUSRTVUS'
     C                   Parm                    QUAL_SPACE
     C                   Parm                    @offsetlst
     C                   Parm                    @lstentsz
     C                   Parm                    QUSL010002
     C                   Parm                    QUSEC
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Get Data Error: ' + QUSEI
     C                   Endif
      *
     C                   Endsr
      *****************************************************************
      * Clear the Subfile
      *****************************************************************
     C     $Clear_Sfl    Begsr
      * Clear the SubFile
     C                   Eval      *IN40 = *Off
     C                   Eval      *IN41 = *Off
     C                   Eval      *IN42 = *On
     C                   Eval      *IN43 = *Off
     C                   Write     USP200002
     C                   Eval      *IN41 = *On
     C                   Eval      *IN42 = *Off
     C                   Eval      *IN43 = *On
     C                   Eval      RRN1 = *Zero
      *
     C                   Endsr
      *****************************************************************
      * Get Pointer to the User Space
      *****************************************************************
     C     $Get_Point    Begsr
      *
     C                   Call      'QUSPTRUS'
     C                   Parm                    QUAL_SPACE
     C                   Parm                    SPCPTR
     C                   Parm                    QUSEC
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Pointer Error: ' + QUSEI
     C                   Endif
      *
     C                   Endsr
      *****************************************************************
      * Get Pointer to the User Space
      *****************************************************************
     C     $Get_User_Job Begsr
      *
     C                   Call      'QUSRJOBI'
     C                   Parm                    QUSI0600
     C                   Parm                    Len_Rcv
     C                   Parm                    Format_N2
     C                   Parm                    Qual_JN
     C                   Parm                    QUSIJI
     C                   Parm                    QUSEC
      *
     C                   Endsr
