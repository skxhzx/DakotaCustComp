      *===============================================================
      * Display access paths for a file
      *===============================================================
      * To compile:
      *
      *      CRTBNDRPG  PGM(XXX/FIG630RG) SRCFILE(XXX/QRPGLESRC)
      *
      *===============================================================
     FDSPPTHFM  CF   E             WORKSTN
     F                                     SFILE(SFLRCD:RelRecNbr)
     D AR              S              1    DIM(4096)
     D A2              S              1    DIM(28)
     D ARYF            S             10    DIM(2000)
     D ARYT            S             40    DIM(2000)
     D SaveStart       S              9B 0
     D SaveLen         S              9B 0
     D OutFile         S             10
     D OutLibrary      S             10
     D First           S              1
     D ObjFileFmt      S              8
     D ObjectType      S             10
     D LstOutFmt       S              8
     D Ignore          S             10
     D MessageFil      S             20
     D MessageTyp      S             10
     D MessageQue      S             10
     D FileFmt         S              8
     D RecordFmt       S             10
     D OverRide        S              1
     D System          S             10
     D FmtType         S             10
     D ListFormat      S             10
     D TestType        S              1
     D SpaceAttr       S             10
     D SpaceValue      S              1
     D SpaceText       S             50
     D SpaceAuth       S             10    INZ('*CHANGE')
     D SpaceReplc      S             10    INZ('*YES')
     D C               S              4  0
     D S               S              4  0
     D I               S              4  0
     D I1              S              4  0
     D I2              S              4  0
     D B               S              4  0
     D RelRecNbr       S              4  0
     D SfCompare       S              2
     D SfRule          S              1
     D SfValue         S             28
     D SFileLib        S             20
     D RFileLib        S             20
     D ObjReceivr      S            100
     D StartPosit      S              9B 0
     D StartLen        S              9B 0
     D ReceiveLen      S              9B 0
     D MessageKey      S              9B 0
     D MsgDtaLen       S              9B 0
     D MsgQueNbr       S              9B 0
     D FilStartP       S              9B 0
     D FilStartL       S              9B 0
     D SpaceLen        S              9B 0 INZ(1024)
     D InFileLib       S             20
     D InputDs         DS
     D  UserSpace              1     20
     D   SpaceName                   10    OVERLAY(UserSpace:1)
     D   SpaceLib                    10    OVERLAY(UserSpace:11)
     D  OutFormat             21     28
     D  FileLib               29     48
     D   FileName                    10    OVERLAY(FileLib:1)
     D   FileLibr                    10    OVERLAY(FileLib:11)
     D ListDs          DS
     D  MainFileLb             1     20
     D  MainFile                     10    OVERLAY(MainFileLb:1)
     D  MainLib                      10    OVERLAY(MainFileLb:11)
     D  DependFil             21     30
     D  DependLib             31     40
     D                 DS
     D  FieldSpace             1     20
     D  FSpaceName                   10    OVERLAY(FieldSpace:1)
     D  FSpaceLib                    10    OVERLAY(FieldSpace:11)
     D ErrorDs         DS                  INZ
     D  BytesProvd             1      4B 0
     D  BytesAvail             5      8B 0
     D  MessageId              9     15
     D  Err###                16     16
     D  MessageDta            17    116
     D KeyData         DS
     D  DependKey              1     10
     D  AscendDes             14     14
     D FindSelect      DS           150    INZ
     D  FindFormat            70     79
     D  NbrKeys              117    118B 0
     D  NbrSelOmit           130    131B 0
     D  OffSelOmit           132    135B 0
     D  OffSet               136    139B 0
     D KeySelect       DS           150    INZ
     D  Rule                   3      3
     D  Compare                4      5
     D  CompName               6     15
     D  NbrSO                 16     17B 0
     D  OffsetSO              29     32B 0
     D KeySOS          DS           150    INZ
     D  POffset                1      4B 0
     D  NL                     5      6B 0
     D  SelectVar             21     48
     D                 DS
     D  FFileLib               1     20
     D  FFileLibr                    10    OVERLAY(FFileLib:1)
     D  FFileName                    10    OVERLAY(FFileLib:11)
     D FGeneralDs      DS                  INZ
     D  FSizeInput           113    116B 0
     D  FOffsetHed           117    120B 0
     D  FSizeHead            121    124B 0
     D  FOfftoList           125    128B 0
     D  FNbrInList           133    136B 0
     D  FSizeEntry           137    140B 0
     D FListDs         DS
     D  FFieldName             1     10
     D  FFieldText            33     82
     D GenHeadDs       DS                  INZ
     D  InputSize            113    116B 0
     D  ListOffset           125    128B 0
     D  NumberList           133    136B 0
     D  EntrySize            137    140B 0
     D Receiver        DS          4096    INZ
     D  NbrFormats            62     63B 0
     D  DBFileOffS           317    320B 0
     D  AccessType           337    338
     D Requester       C                   CONST('*REQUESTER*LIBL')

     C     *ENTRY        PLIST
     C                   PARM                    InFileLib
     C                   EVAL      OutFile = %SUBST(InFileLib:1:10)
     C                   EVAL      OutLibrary = %SUBST(InFileLib:11:10)
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
     C                   EVAL      FileName = OutFile
     C                   EVAL      FileLibr = OutLibrary
     C                   EVAL      BytesProvd = 116
     C                   EVAL      MessageFil = ('QCPFMSG   ' + 'QSYS')
     C                   EVAL      *IN53 = *ON
      *  Create user space
     C                   CALL      'QUSCRTUS'
     C                   PARM                    UserSpace
     C                   PARM                    SpaceAttr
     C                   PARM      1024          SpaceLen
     C                   PARM                    SpaceValue
     C                   PARM                    SpaceAuth
     C                   PARM                    SpaceText
     C                   PARM                    SpaceReplc
     C                   PARM                    ErrorDs
      *  Attempt to retrieve object description
     C                   CALL      'QUSROBJD'
     C                   PARM                    ObjReceivr
     C                   PARM      100           ReceiveLen
     C                   PARM      'OBJD0100'    ObjFileFmt
     C                   PARM                    InFileLib
     C                   PARM      '*FILE'       ObjectType
     C                   PARM                    ErrorDs
      *  If file doesn't exist, send message and get out
     C                   IF        MessageId <> *BLANKS
     C                   EXSR      SNDMSG
     C                   GOTO      END
     C                   ENDIF
      *  Create user space for fields
     C                   EXSR      SPACE1
      *
     C                   EVAL      SFileLib = InFileLib
     C                   EVAL      First = *ON
      *  Write access path
     C                   EXSR      GETFIL
     C     MessageId     CABEQ     'CPF5715'     NORECS
     C     MessageId     CABEQ     'CPF3210'     END
     C                   EVAL      First = *OFF
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
      * List database relations to user space
     C                   CALL      'QDBLDBR'
     C                   PARM                    UserSpace
     C                   PARM      'DBRL0100'    LstOutFmt
     C                   PARM                    SFileLib
     C                   PARM      '*FIRST'      RecordFmt
     C                   PARM      *BLANKS       Ignore
     C                   PARM                    ErrorDs
     C     MessageId     CABEQ     'CPF5715'     NORECS
     C                   EVAL      StartPosit = 1
     C                   EVAL      StartLen = 140
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
      * Retrieve user space general information
     C                   CALL      'QUSRTVUS'
     C                   PARM                    UserSpace
     C                   PARM                    StartPosit
     C                   PARM                    StartLen
     C                   PARM                    GenHeadDs
     C                   EVAL      StartPosit = 1
     C                   EVAL      StartLen = InputSize
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
      *  Retrieve user space detail information
     C                   CALL      'QUSRTVUS'
     C                   PARM                    UserSpace
     C                   PARM                    StartPosit
     C                   PARM                    StartLen
     C                   PARM                    InputDs
     C                   EVAL      StartPosit = (ListOffset + 1)
     C                   EVAL      StartLen = EntrySize
     C                   EVAL      SaveLen = EntrySize
     C                   EVAL      NbrLogics = NumberList
      *  Retrieve the list by walking through the user space
     C                   DO        Nbrlogics
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
     C                   EVAL      SaveStart = StartPosit
     C                   CALL      'QUSRTVUS'
     C                   PARM                    UserSpace
     C                   PARM                    StartPosit
     C                   PARM                    StartLen
     C                   PARM                    ListDs
     C     DependFil     CABEQ     '*NONE'       NORECS
     C                   EVAL      SpaceName = 'USRSPC'
     C                   EVAL      SpaceLib = 'QTEMP'
     C                   EVAL      SFileLib = DependFil
     C                   EVAL      %SUBST(SFileLib:11:10) = DependLib
     C                   EXSR      GETFIL
     C                   EXSR      CLEAR
     C                   EVAL      StartPosit = (SaveStart + SaveLen)
     C                   ENDDO
     C     NORECS        TAG
     C                   IF        RelRecNbr > 0
     C                   EVAL      *In21 = *ON
     C                   ENDIF
     C                   WRITE     FORMAT1
     C                   EXFMT     SFLCTL
     C     END           TAG
     C                   EVAL      *InLr = *ON
      *
     C     SNDMSG        BEGSR
      *  Send error message
     C                   CALL      'QMHSNDPM'
     C                   PARM                    MessageId
     C                   PARM                    MessageFil
     C                   PARM                    InFileLib
     C                   PARM      20            MsgDtaLen
     C                   PARM      '*STATUS'     MessageTyp
     C                   PARM      '*EXT'        MessageQue
     C                   PARM      1             MsgQueNbr
     C                   PARM                    MessageKey
     C                   PARM                    ErrorDs
     C                   ENDSR

     C     GETFIL        BEGSR
      *  Retrieve key field information for each logical file
     C                   CALL      'QDBRTVFD'
     C                   PARM                    Receiver
     C                   PARM      4096          ReceiveLen
     C                   PARM                    RFileLib
     C                   PARM      'FILD0100'    FileFmt
     C                   PARM                    SFileLib
     C                   PARM                    RecordFmt
     C                   PARM      '0'           OverRide
     C                   PARM      '*LCL'        System
     C                   PARM      '*EXT'        FmtType
     C                   PARM                    ErrorDs
     C     MessageId     CABEQ     'CPF5715'     ENDGET
     C                   MOVEA     Receiver      AR(1)
     C                   IF        First = *ON
      *  File must be a physical file
     C                   MOVE      AR(9)         TestType
     C                   TESTB     '2'           TestType                 01
     C                   IF        *In01 = *ON
     C                   EVAL      MessageId = 'CPF3210'
     C                   EXSR      SNDMSG
     C                   GOTO      ENDGET
     C                   ENDIF
     C                   ENDIF

     C                   EVAL      I = DbFileOffs
     C                   DO        NbrFormats
     C                   MOVEA     AR(I)         FindSelect
     C                   EVAL      S = (Offset + 1)
     C                   IF        First = *OFF
      *  Write blank line for clarity
     C                   EXSR      CLEAR
     C                   EVAL      RelRecNbr = RelRecNbr + 1
     C                   WRITE     SFLRCD
     C                   ENDIF
     C                   EVAL      SfLibrary = %SUBST(RFileLib:1:10)
     C                   EVAL      SfFileName = %SUBST(RFileLib:11:10)
     C                   EVAL      SfFormat = FindFormat
     C                   EXSR      GETTXT
     C                   DO        NbrKeys
     C                   MOVEA     AR(S)         KeyData
     C                   TESTB     '0'           AscendDes                79
     C                   SELECT
     C                   WHEN      *In79 = *OFF
     C                   EVAL      SfAsendDec = 'A'
     C                   WHEN      *In79 = *ON
     C                   EVAL      SfAsendDec = 'D'
     C                   ENDSL
     C                   EVAL      SfKeyField = DependKey
     C                   DO        B             C
     C                   IF        ARYF(C) = DependKey
     C                   EVAL      SfValue = Aryt(C)
     C                   LEAVE
     C                   ENDIF
     C                   ENDDO
     C                   EVAL      SfText = SfValue
     C                   EVAL      RelRecNbr = RelRecNbr + 1
     C                   WRITE     SFLRCD
     C                   EVAL      SfLibrary = *BLANKS
     C                   EVAL      SfFileName = *BLANKS
     C                   EVAL      SfFormat = *BLANKS
     C                   EVAL      SfValue = *BLANKS
     C                   EVAL      S = S + 32
     C                   ENDDO
      *  If select/omit statements exist
     C                   IF        NbrSelOmit <> *ZEROS
     C                   EXSR      SELOMT
     C                   ENDIF
     C                   EVAL      SfCompare = *BLANKS
     C                   EVAL      SfRule = *BLANKS
     C                   EVAL      I = I + 160
     C                   ENDDO
     C     ENDGET        TAG
     C                   ENDSR

     C     SELOMT        BEGSR
     C                   EVAL      I1 = (OffSelOmit + 1)
     C                   DO        NbrSelOmit
     C                   MOVEA     AR(I1)        KeySelect
     C                   IF        Compare = 'AL'
     C                   ITER
     C                   ENDIF
     C                   EVAL      SfCompare = Compare
     C                   EVAL      SfRule = Rule
     C                   EVAL      I2 = OffsetSo + 1
     C                   DO        NbrSO
     C                   MOVEA     AR(I2)        KeySOS
     C                   MOVEA     SelectVar     A2
     C                   EVAL      NL = NL - 19
     C                   IF        NL > *ZEROS
     C                   MOVEA     *BLANKS       A2(NL)
     C                   ENDIF
     C                   MOVEA     A2(1)         SfValue
     C                   EVAL      SfKeyField = CompName
     C                   EVAL      RelRecNbr = RelRecNbr + 1
     C                   EVAL      SfAsendDec = *BLANKS
     C                   EVAL      SfText = (SfRule + ' ' + SfCompare +
     C                              ' ' + SfValue)
     C                   EVAL      *In59 = *ON
     C                   WRITE     SFLRCD
     C                   EVAL      *In59 = *OFF
     C                   EVAL      I2 = POffset + 1
     C                   ENDDO
     C                   EVAL      I1 = (I1 + 32)
     C                   ENDDO
     C                   ENDSR

     C     CLEAR         BEGSR
     C                   EVAL      SfLibrary = *BLANKS
     C                   EVAL      SfFileName = *BLANKS
     C                   EVAL      SfFormat = *BLANKS
     C                   EVAL      SfKeyField = *BLANKS
     C                   EVAL      SfText = *BLANKS
     C                   EVAL      SfCompare = *BLANKS
     C                   EVAL      SfRule = *BLANKS
     C                   EVAL      SfAsendDec = *BLANKS
     C                   ENDSR
      * Get text for each field
     C     GETTXT        BEGSR
     C                   EVAL      FFileName = SfFileName
     C                   EVAL      FFileLibr = SfLibrary
     C                   EVAL      FSpaceName = 'FLDSPC'
     C                   EVAL      FSpaceLib = 'QTEMP'
      * List fields to user space
     C                   CALL      'QUSLFLD'
     C                   PARM                    FieldSpace
     C                   PARM      'FLDL0100'    ListFormat
     C                   PARM                    FFileLib
     C                   PARM      SfFormat      RecordFmt
     C                   PARM      '1'           OverRide
     C                   Z-ADD     1             FilStartP
     C                   Z-ADD     140           FilStartL
     C                   EVAL      FSpaceName = 'FLDSPC'
     C                   EVAL      FSpaceLib = 'QTEMP'
      *  Retrieve user space general information
     C                   CALL      'QUSRTVUS'
     C                   PARM                    FieldSpace
     C                   PARM                    FilStartP
     C                   PARM                    FilStartL
     C                   PARM                    FGeneralDs
     C                   EVAL      FilStartP = FOffsetHed + 1
     C                   EVAL      FilStartL = FSizeHead
     C                   EVAL      FSpaceName = 'FLDSPC'
     C                   EVAL      FSpaceLib = 'QTEMP'
     C                   EVAL      FilStartP = FOfftoList + 1
     C                   EVAL      FilStartL = FSizeEntry
      *  Retrieve the list by walking through the user space
     C                   DO        FNbrInList
     C                   EVAL      FSpaceName = 'FLDSPC'
     C                   EVAL      FSpaceLib = 'QTEMP'
     C                   CALL      'QUSRTVUS'
     C                   PARM                    FieldSpace
     C                   PARM                    FilStartP
     C                   PARM                    FilStartL
     C                   PARM                    FListDs
     C                   EVAL      B = B + 1
     C                   EVAL      ARYF(B) = FFieldName
     C                   EVAL      ARYT(B) = FFieldText
     C                   EVAL      FilStartP = FilStartP + FSizeEntry
     C                   ENDDO
     C                   ENDSR
      * Create user space for listing fields
     C     SPACE1        BEGSR
     C                   EVAL      FSpaceName = 'FLDSPC'
     C                   EVAL      FSpaceLib = 'QTEMP'
     C                   CALL      'QUSCRTUS'
     C                   PARM                    FieldSpace
     C                   PARM      *BLANKS       SpaceAttr
     C                   PARM      1024          SpaceLen
     C                   PARM      *BLANKS       SpaceValue
     C                   PARM      '*CHANGE'     SpaceAuth
     C                   PARM      *BLANKS       SpaceText
     C                   PARM      '*YES'        SpaceReplc
     C                   PARM                    ErrorDs
     C                   ENDSR
