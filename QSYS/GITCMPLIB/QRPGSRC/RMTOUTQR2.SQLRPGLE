     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
      *
      *  RMTOUTQR2  WRKRMTWTR - Main RPGle
      *  26 December 2007
      *  Jeffrey Jahnke
      *
     *----------------------------------------------------------------
      *  Revisions
      *
      *    12/26/07  JCJ
      *      - Copied off the internet.
     *
      *
720 A*    01/18/18  MLB  7.20
     *      - Fix: Revised pgm to check number of splf's in outq. If greater
     *        than 9999, then set o#numfls, bcurps = 9999 to prevent MCH1210
     *        Receiver value too small to hold result error.
     *
      *-------------------------------------------------------------------------
      *     Written By:  Bryan Dietz with substantial Subfile help from Tom Cham
      *     Dec. 2001
      *     Added outfile support March, 2007
      *     Fixed error if more that 9999 subfile records  May, 2007
      *                          bryandietz@yahoo.com
      *-------------------------------------------------------------------------
     h debug  dftactgrp(*NO)   Option( *SrcStmt )  BndDir( 'QC2LE' )
     FRMTOUTQDS CF   E             WORKSTN USROPN
     F                                     RENAME(WWM01000:SFLRCD)
     F                                     RENAME(WWM01001:SFLCTL)
     F                                     RENAME(WWMTOP:TOP)
     F                                     RENAME(WWMNODTA:NODATA)
     F                                     RENAME(WWMSGCTL:BOTTOM)
     F                                     INFDS(WWMDSP)
     F                                     MAXDEV(*FILE)
     F                                     SFILE(SFLRCD:RRN)
      *
      *-- Get the ILE/RPG Program Information Data Structure
      /Copy *libl/qcopysrc,ILEPGMDS
      *-- Get the ILE/RPG Display File Data Structure
     D* Display File Information Data Structure.
     D WWMDSP          DS
      /Copy *libl/qcopysrc,ILEDSPDS
      *-- Get the ILE/RPG Command Key Constants
      /Copy *libl/qcopysrc,ILECMDCNT
      *-- Get the ILE/RPG Error Message SFL Controls
      /Copy *libl/qcopysrc,ILEERRMSG
      *
     D USNAME          C                   CONST('BDRMTWTR  QTEMP     ')
      * Data Structure for API:  General Header for User Space
     D GENHDR          DS
     D  LSTOFF               125    128B 0
     D  LSTCNT               133    136B 0
     D  ENTLEN               137    140B 0
      * Data Structure for API:  QUSLOBJ
     D INPUT           DS
     D  USRSPC                 1     20
     D  FMTNAM                21     28
     D  OBJLII                29     48
     D  OBJTYI                49     58
     D  JQNAME                55     64
     D  JQLIB                 65     74
     D  OQNAME                87     96
     D  OQLIB                 97    106
     D  PDEVNA               109    118
     D                 DS
     D  STRPOS                 1      4B 0
     D  STRLEN                 5      8B 0
     D  RCVLEN                 9     12B 0
      *
     D LIST            DS
     D  outqandlib             1     20
     D  OBJNML                 1     10
     D  LIBNML                11     20
     D  OBJTYL                21     30

     D Output          DS
     D  o#outq                 1     10
     D  o#lib                 11     20
     D  o#numfiles            21     24b 0
     D  o#ostat               25     34
     D  o#rmtsys              35     54
     D  o#prtq                55     64
     d  o#mfg                 65     74
     d  o#wscst               75     84
     d  o#wstat               85     94
     d  o#wtr                 95    104

     d  O#NUMFLS       S              4  0

      *  Retrieve Output Queue Information (QSPROUTQ) API
      *    using format OUTQ0100
      *
     DQSPQ0100         DS
     D*                                             Qsp OUTQ0100
     D QSPBR                   1      4B 0
     D*                                             Bytes Return
     D QSPBA                   5      8B 0
     D*                                             Bytes Avail
     D RMTOUTQ                 9     18
     D*                                             Output Queue Name
     D RMTOUTQL               19     28
     D*                                             Output Queue Lib
     D QSPOOF                 29     38
     D*                                             Order of Files
     D QSPDAFIL               39     48
     D*                                             Display Any File
     D QSPJS                  49     52B 0
     D*                                             Job Separators
     D QSPOC                  53     62
     D*                                             Operator Control
     D QSPDQN                 63     72
     D*                                             Data Queue Name
     D QSPDQL                 73     82
     D*                                             Data Queue Lib
     D QSPATC                 83     92
     D*                                             Authority to Check
     D QSPNBROF               93     96B 0
     D*                                             Number of Files
     D RMTSTATO               97    106
     D*                                             Output Queue Status
     D QSPWJN                107    116
     D*                                             Writer Job Name
     D QSPWJU                117    126
     D*                                             Writer Job User
     D QSPWJNBR              127    132
     D*                                             Writer Job Number
     D RMTSTAT               133    142
     D*                                             Writer Status
     D QSPPDN                143    152
     D*                                             Printer Device Name
     D QSPOQD                153    202
     D*                                             Output Queue Descr
     D QSPRSV2               203    204
     D*                                             Reserved2
     D QSPNOPSG              205    208B 0
     D*                                             Number Of Page Sizes Given
     D QSPNOWS               209    212B 0
     D*                                             Number Of Writers Started
     D QSPWTA                213    216B 0
     D*                                             Writers To Autostart
     D QSPRSNT               217    217
     D*                                             Remote System Name Type
     D RMTSYS                218    472
     D*                                             Remote System Name
     D RMTPRTQ               473    600
     D*                                             Remote Printer Queue
     D QSPMQ                 601    610
     D*                                             Message Queue
     D QSPMQLIB              611    620
     D*                                             Message Queue Library
     D RMTCNN                621    624B 0
     D*                                             Connection Type
     D RMTDEST               625    628B 0
     D*                                             Destination Type
     D QSPMMVSC              629    629
     D*                                             VMMVS Class
     D QSPFCB                630    637
     D*                                             FCB
     D RMTTRNS               638    638
     D*                                             Transform SCS To ASCII
     D RMTMFG                639    655
     D*                                             Manufacturer Type Model
     D QSPWCO                656    665
     D*                                             Workstation Cust Obj
     D QSPWCOL               666    675
     D*                                             Workstation Cust Obj Library
     D QSPSASP               676    676
     D*                                             Splf Aux Storage Pool
     D QSPSFSO               677    680B 0
     D*                                             Spooled File Size Offset
     D QSPNOSE               681    684B 0
     D*                                             Number Of Size Entries
     D QSPLOESE              685    688B 0
     D*                                             Length Of Each Size Entry
     D QSPDO                 689    816
     D*                                             Destination Options
     D QSPWT                 817    817
     D*                                             Writer Type
     D QSPSP                 818    818
     D*                                             Separator Page
     D QSPLRPQ               819   1073
     D*                                             Long Remote Printer Queue
     D QSPICN               1074   1083
     D*                                             Image Configuration Name
     D QSPICLIB             1084   1093
     D*                                             Image Configuration Library
     D QSPNDPS              1094   1094
     D*                                             Network Directory Pub Status
     D QSPRSV300            1095   1096
     D*                                             Reserved3
     D QSPASPID             1097   1100B 0
     D*                                             Aux Storage Pool ID
      *
     D*******************************************************************
     D*Type Definition for the Attribute_Record_Format.
     D*******************************************************************
     DQUSARF           DS
     D QUSK00                         9B 0
     D QUSK01a                        9B 0
     D QUSLOD                         9B 0
     D QUSATR                         1

     d QDCUSSNAM       s             20
     D QUSRtnLib       s             10
     D QUSExtAtr       s             10
     D QUSIntLen       s              9B 0
     D QUSIntVal       s              1
     D QUSAuth         s             10
     D QUSText         s             50
     D QUSStart        s              9B 0
     D QUSLength       s              9B 0
     D QUSOffset       s              9B 0

     D Obj_Lib         s             20
     D InputO          s             10
     D InputL          s             10
     D bMsgId          S              7
     D bMsgDta         S            200
     D AMsgId          S              7
     D AMsgDta         S            200
     D AMessage        S             80
     D AMsgfile        S             10    Inz('QCPFMSG')
     D YourMsg         S             80
     D bErrmsg         S              5P 0 Inz(0)
     D Command         S             80
     D Length          S             15  5
     D bOQRcvLen       S              9B 0
     D bOQFmtNam       S              8    INZ('OUTQ0100')
     D bOQNamLib       S             20
     D bAction         S              1
     D bTag            S             10
     D bSflPage        S              5P 0 INZ(11)
     D RRN1            S              5P 0 Inz(1)
     D*bNetRcvLen      S              9B 0 Inz(32)
     D*bNetRtvAtr      S              9B 0 Inz(1)
     D*bNetAtrNam      S             10    Inz('SYSNAME')
     D DFDELT          S              1    Inz('B')
     D tick            S              1    Inz('''')
     D Prompt          S              1    Inz('N')
     D beenhere        S              3    Inz('not')
     D rmtque          S             40

     D QCmdCmd         S           1024    INZ
     D QCmdLength      S             15  5 INZ(%size(QCmdCmd))
     D*
     D sqlstm          s            350
     D sqlstm1         s            350
     D DspOpen         s              1
     D o#nbrsplf       s              6  0
     D*
     DOutFile          DS
     D BDfile                        10a
     D BDlib                         10a
     D
     D DspLngTxt       Pr                  ExtPgm( 'QUILNGTX' )
     D  DtLngTxt                  32767a   Const  Options( *VarSize )
     D  DtLngTxtLen                  10i 0 Const
     D  DtMsgId                       7a   Const
     D  DtMsgF                       20a   Const
     D  DtError                   32767a   Const  Options( *VarSize )
     D DspMsgWdw       Pr
     D  PxMsgStr                    512a   Const  Varying
     D*ERRC0100        Ds                  Qualified
     D* BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D* BytAvl                       10i 0
     D* MsgId                         7a
     D*                               1a
     D* MsgDta                      128a

      *---------Network attributes-------------
     d/copy qsysinc/qrpglesrc,qwcrneta

     d rcv             ds           256
     d  number                 1      4b 0
     d  off1                   5      8b 0
     D*
     d misc            ds
     d  rcvsiz                 1      4b 0 inz(256)
     d  nbr                    5      8b 0 inz(1)
     d  neta                   9     18    inz('SYSNAME')
      *
     d off             s              3  0
     d sysnam          s              8
     **-- Api error data structure:  -----------------------------------------**
     D ApiError        Ds
     D  AeBytPro                     10i 0 Inz( %Size( ApiError ))
     D  AeBytAvl                     10i 0 Inz
     D  AeMsgId                       7a
     D                                1a
     D  AeMsgDta                    128a

      *---------------------------------------------------------------------
      /Copy qsysinc/qrpglesrc,QUSEC
      *---------------------------------------------------------------------
      * The Main Processing of the Program
      *---------------------------------------------------------------
     C     *Entry        Plist
     C                   Parm                    in_outq          10
      *                                               Which outq's  *ALL *generi
     C                   Parm                    in_lib           10
      *                                               Which lib's  *ALL *ALLUSR
     c                   Parm                    OutPutx           5
      *                                               OutPut(* *FILE)
     c                   Parm                    OutFile          20
      *                                               OutPutFile and Library
     c                   Parm                    FileOpt           8
      *                                               File Option(*REPLACE *ADD)
      *---------------------------------------------------------------
     C                   Eval      DspOpen = *Off
     C
     c                   if        Outputx = '*FILE' and
     c                             Fileopt = '*REPLACE'
     C                   Exsr      $SQLDrop
     C                   Exsr      $SQLCreate
     c                   endif
     c                   if        Outputx = '*FILE' and
     c                             Fileopt = '*ADD'
     C                   Exsr      $SQLCreate
     c                   endif
      *---------------------------------------------------------------
     C                   EXSR      $RELOAD
     c     Outputx       ifeq      '*'
      * Display the Screen
     C     KEYPRS        DOWNE     CMD03

     C                   EVAL      *IN(10) = *OFF
     C* Display any Error Messages and Function Keys.
     C                   WRITE     TOP
     C* If there are not any records in the Subfile, display the
     C* '(No Records to Display)'.
     C     *IN(03)       IFEQ      *OFF
     C                   WRITE     NODATA
     C                   ENDIF
     C                   WRITE     BOTTOM
     C                   EVAL      bdRRN = rrn1
     C* Display and wait forever.
     C                   EXFMT     SFLCTL
     C* Clear the Error Messages.
     C                   EXSR      $CLRMG
     C* Save the current subfile page
     C                   EVAL      rrn1  = bsflrn

     C                   SELECT
510 AC                   when      keyprs = enter
510 AC                             and  rrn1 = *zeros
510 AC                   leave
     C     KEYPRS        WHENEQ    CMD03
     C                   LEAVE
     C     KEYPRS        WHENEQ    CMD12
     C                   LEAVE
     C     KEYPRS        WHENEQ    CMD04
     C                   EVAL      Prompt  = 'Y'
     C     KEYPRS        WHENEQ    CMD05
     C                   EXSR      $RELOAD
     C                   EVAL      rrn1  = 1
     C     KEYPRS        WHENEQ    CMD06
     C                   EXSR      $Crtoutq
     C                   EXSR      $RELOAD
     C                   EVAL      rrn1  = 1
     C     KEYPRS        WHENEQ    CMD09
     C                   EXSR      $CmdLine
     C                   EXSR      $RELOAD
     C                   EVAL      rrn1  = 1
     C     KEYPRS        WHENEQ    CMD10
     C                   EXSR      $qspljobs
     C                   EXSR      $RELOAD
     C                   ENDSL

      * Read the Subfile for Changes.
     C* If there are not any records in the Subfile, display the
     C* '(No Records to Display)'.
     C     *IN(03)       IFEQ      *OFF
     C                   WRITE     NODATA
     C                   ENDIF
     C                   READC     SFLRCD                                 99
     C     DSPSTS        DOWEQ     0
     C                   EVAL      *IN(10) = *ON

      *Option 1=Start
     C     bOPT          IFEQ      1
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?StrRmtWtr ?*Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   else
     C                   eval      QCmdCmd = 'StrRmtWtr Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Start Remote Writer
     C                   ENDIF

      *Option 2=Chg
     C     bOPT          IFEQ      2
     C                   eval      QCmdCmd = '? ChgOutq  ?*Outq('           +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     C                   EXSR      $QCMDEXC
      *Change Outq
     C                   ENDIF

      *Option 4=End
     C     bOPT          IFEQ      4
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?EndWtr ?*wtr('             +
     C                                       %trim(o#wtr) + ')' + ' ' +
     C                                       'Option(*IMMED) '
     c                   else
     C                   eval      QCmdCmd = 'EndWtr wtr('             +
     C                                       %trim(o#wtr) + ')' + ' ' +
     C                                       'Option(*IMMED) '
     c                   endif
     C                   EXSR      $QCMDEXC
      *End Writer
     C                   ENDIF
      *Option 5=Work Wtr
     C     bOPT          IFEQ      5
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?WrkWtr ?*wtr('             +
     C                                       %trim(o#wtr) + ')'
     c                   else
     C                   eval      QCmdCmd = 'WrkWtr wtr('             +
     C                                       %trim(o#wtr) + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Wrk Writer
     C                   ENDIF

      *Option 8=Work Outq
     C     bOPT          IFEQ      8
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?WrkOutq ?*Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   else
     C                   eval      QCmdCmd = 'WrkOutq   Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Wrk Outq
     C                   ENDIF

      *Option 3=Hold Outq
     C     bOPT          IFEQ      3
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?HldOutq ?*Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   else
     C                   eval      QCmdCmd = 'HldOutq   Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Hld Outq
     C                   ENDIF

      *Option 8=Rls Outq
     C     bOPT          IFEQ      6
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?RlsOutq ?*Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   else
     C                   eval      QCmdCmd = 'RlsOutq   Outq('            +
     C                                       %trim(o#lib) + '/'           +
     C                                       %trim(o#outq) + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Rls Outq
     C                   ENDIF

      *Option 99=PING
     C     bOPT          IFEQ      99
     c                   if        Prompt = 'Y'
     C                   eval      QCmdCmd = '?Ping ?*Rmtsys(' + tick    +
     C                                       %trim(o#rmtsys) + tick + ')'
     c                   else
     C                   eval      QCmdCmd = 'Ping Rmtsys(' + tick    +
     C                                       %trim(o#rmtsys) + tick + ')'
     c                   endif
     C                   EXSR      $QCMDEXC
      *Rls Outq
     C                   ENDIF

     C                   READC     SFLRCD                                 99
     C                   ENDDO
     C                   EVAL      RRN = 0
      * Check for Options Taken and Reload the Sub-File
     C     *IN(10)       IFEQ      *ON
     C                   EXSR      $RELOAD
     C                   ENDIF

     C                   ENDDO
     c                   endif
     C                   MOVE      *ON           *INLR
      *================================================================
      *CMD9=Command Line
     C     $CmdLine      begsr
     C                   eval      QCmdCmd = 'Call Quscmdln'
     C                   EXSR      $QCMDEXC
      *Cmd Outq
     C                   ENDsr
      *================================================================
      *CMD10=Wrksbsjob sbs(QSPL)
     C     $qspljobs     begsr
     C                   eval      QCmdCmd = 'WRKSBSJOB SBS(QSPL)'
     C                   EXSR      $QCMDEXC
      *Cmd sbs jobs
     C                   ENDsr
      *================================================================
      *CMD6=Create Outq
     C     $crtoutq      begsr
     C                   eval      QCmdCmd = '?CrtOutq'
     C                   EXSR      $QCMDEXC
      *Crt Outq
     C                   ENDsr
      *================================================================
     C     $RELOAD       BEGSR

     C     OutPutx       ifeq      '*'
     C     beenhere      ifne      'bmd'
     C                   open      RMTOUTQDS
     c                   eval      beenhere = 'bmd'
     C                   endif
     C                   endif
     C                   exsr      delete_us
     C                   exsr      build_us
     C
     C                   eval      InputO = in_outq
     C                   eval      InputL = in_lib
     C                   eval      Obj_Lib = InputO + InputL
     C                   EVAL      Prompt  = 'N'

     C                   EXSR      getobjlst

     C                   ENDSR
      *================================================================
     C     getobjlst     BEGSR
     C     OutPutx       ifeq      '*'
     C                   EVAL      *IN(03) = *OFF
     C                   EVAL      *IN(04) = *OFF
     C                   EVAL      *IN(05) = *ON
     C                   EVAL      *IN(06) = *OFF
     C                   WRITE     SFLCTL
     C                   EVAL      *IN(05) = *OFF
     C                   EVAL      *IN(04) = *ON
     C                   EVAL      *IN(03) = *OFF
     C                   EVAL      *IN(06) = *ON
     C                   EVAL      RRN = 0
     c                   endif
      * Process job description object list
     C                   CALL      'QUSLOBJ'
     C                   PARM      USNAME        USRSPC
     C                   PARM      'OBJL0100'    FMTNAM
     C                   PARM      Obj_Lib       OBJLII
     C                   PARM      '*OUTQ '      OBJTYI
     C                   PARM                    QUSEC

     C                   CALL      'QUSRTVUS'
     C                   PARM      USNAME        USRSPC
     C                   PARM      1             STRPOS
     C                   PARM      140           STRLEN
     C                   PARM                    GENHDR
     c                   parm                    QUSEC

     C     LSTOFF        ADD       1             STRPOS
     C                   Z-ADD     20            STRLEN
     C                   DO        LSTCNT

     C                   CALL      'QUSRTVUS'
     C                   PARM      USNAME        USRSPC
     C                   PARM                    STRPOS
     C                   PARM                    STRLEN
     C                   PARM                    LIST
     C                   PARM                    QUSEC

     C                   EXSR      getrmtoutq

     C                   ADD       ENTLEN        STRPOS
     C                   ENDDO

     C                   EVAL      *IN(06) = *ON

     C                   ENDSR
      *================================================================
     C     getrmtoutq    BEGSR
      *  Retrieve the output queue information             *
     C                   CALL      'QSPROUTQ'
     C                   PARM                    QSPQ0100
     C                   PARM      1100          bOQRcvLen
     C                   PARM                    bOQFmtNam
     C                   PARM                    outqandlib
     C                   PARM                    QUSEC
      *------------------------------------------*
     c                   if        RMTCNN = 2
     c                   eval      o#outq = rmtoutq
     c                   eval      o#lib  = rmtoutql
720 A*
720 A*   Splf's on outq exceeds space in variable.
720 AC                   if        qspnbrof > 9999
720 AC                   eval      o#numfiles = 9999
720 AC                   eval      o#numfls   = 9999
720 AC                   else
720 A*
     c                   eval      o#numfiles = QSPNBROF
     c                   eval      o#numfls = QSPNBROF
720 AC                   endif
     *
     c                   eval      o#ostat4 = rmtstato
     c                   eval      o#rmtsys = rmtsys
     c                   eval      o#prtq = rmtprtq
     c                   eval      rmtque = rmtprtq
     c                   eval      o#mfg  = rmtmfg
     c                   eval      o#wstat4 = rmtstat
     c                   eval      o#wtr    = QSPWJN

     c                   if        rmtstato = 'RELEASED'
     c                   eval      o#ostat4 = 'RLSD'
     c                   endif
     c                   if        o#mfg    = '*WSCST'
     c                   eval      o#mfg    = QSPWCO
     c                   endif

     C                   eval      bOPT = 0
     c     OutPutx       ifeq      '*'
     C                   EVAL      RRN = RRN + 1
     C                   EVAL      *IN(03) = *ON
     C                   WRITE     SFLRCD
     c                   endif
      *
     c                   if        OutPutx = '*FILE'
     C                   Exsr      $SQLAddRec
     c                   endif

     c                   endif
      *
     C                   ENDSR
      *================================================================
     C     BUILD_US      Begsr
      * Create the User Space
     C                   Call      'QUSCRTUS'
     C                   Parm      UsName        QDCUSSNAM
     C                   Parm      'SPACE'       QUSExtAtr
     C                   Parm      255           QUSIntLen
     C                   Parm      X'00'         QUSIntVal
     C                   Parm      '*ALL'        QUSAuth
     C                   Parm      'RMTOQ Lst'   QUSText

      * Set the User Space to Grow
     C                   Eval      QUSK00 = 1
     C                   Eval      QUSK01a = 3
     C                   Eval      QUSLOD = 1
     C                   Eval      QUSATR = '1'
      * Change the User Space
     C                   Call      'QUSCUSAT'
     C                   Parm                    QUSRtnLib
     C                   Parm                    QDCUSSNAM
     C                   Parm                    QUSARF
     C                   Parm                    qusec
      *
     C                   Endsr
      *================================================================
     C     DELETE_US     Begsr
      * Set the User Space Name
     C                   Call      'QUSDLTUS'
     C                   Parm      USName        QDCUSSNAM
     C                   Parm                    qusec
      *
     C                   Endsr
      *****************************************************************
      * Run QCCMEXC
      *****************************************************************
     C     $QCMDEXC      BEGSR
      *
     C                   CALL      'QCMDEXC'                            99
     C                   PARM                    QCmdCmd
     C                   PARM                    QCmdLength
      *
     C                   ENDSR
      *================================================================
      /Copy *libl/qcopysrc,ILEERRPRC
      *================================================================
     C****************************************************************
     C* Initialize the Program
     C****************************************************************
     C     *INZSR        BEGSR
     C* Set-Up Message Queue Fields.
     C                   MOVEL     '*'           bPGMQ
     C                   MOVEL     '*DIAG'       bTYPE            10
     C                   MOVEL     '*LIBL'       bLIB             10
     C                   MOVE      bLIB          bMSGF            20
     C                   MOVEL     'WRKMSGF'     bMSGF
     C                   MOVEL     *BLANKS       bMSGID            7
     C                   MOVEL     '*ALL'        bRMV             10
     C                   MOVE      *BLANKS       bMSGD            80
     C                   MOVE      *BLANKS       bMSGK

     C     *LIKE         DEFINE    bSFLRN        RRN
      *
      * Call Retrieve Network Attributes API
     c                   call      'QWCRNETA'
     c                   parm                    rcv
     c                   parm                    rcvsiz
     c                   parm                    nbr
     c                   parm                    neta
     c                   parm                    apierror
     C*
     c     number        ifeq      1
     C*
     c                   eval      off = (off1 + 1)
     C* Header Information for the Network Attribute
     c                   eval      %subst(qwcrat:1:16) =
     c                             %subst(rcv:off:16)
     C*
     c                   eval      off = (off + 16)
     C*
     c                   if        (qwcna = 'SYSNAME')
     C*
     c                   move      *blanks       sysnam
     C* Get the returned value
     c                   eval      %subst(sysnam:1:qwcld) =
     c                             %subst(rcv:off:qwcld)
     c                   endif
     c                   endif
     C                   Endsr
      *---------------------------------------------------------------
     C* SQL Create Table
      *---------------------------------------------------------------
     C     $SQLCreate    Begsr
     C                   eval      sqlStm = 'Create Table ' +
     C                                %trim(BDlib) + '/' +
     C                                %trim(BDFile) + '('    +
     C                                ' LIB      CHAR(10) NOT NULL,' +
     C                                ' OUTQ     CHAR(10) NOT NULL,' +
     C                                ' IPADDR   CHAR(15) NOT NULL,' +
     C                                ' NBRSPLF  INT      NOT NULL,' +
     C                                ' OUTQSTS  CHAR(10) NOT NULL,' +
     C                                ' RMTQUE   CHAR(40) NOT NULL,' +
     C                                ' WSCST    CHAR(10) NOT NULL,' +
     C                                ' WTRSTS   CHAR(10) NOT NULL,' +
     C                                ' OUTQDSC  CHAR(50) NOT NULL,' +
     C                                ' SYSTEM   CHAR(8)  NOT NULL,' +
     C                                ' DATETIME TIMESTAMP +
     C                                  NOT NULL WITH DEFAULT ' +
     C                                 ') '

     C/exec SQL
     C+    Set option commit = *none
     C/end-EXEC

     c/Exec Sql
     c+    declare crt statement
     c/End-Exec

     c/Exec Sql
     c+    prepare crt from :sqlStm
     c/End-Exec

     c/Exec Sql
     c+    execute crt
     c/End-Exec

     C                   Endsr
      *---------------------------------------------------------------
     C* SQL Drop Table
      *---------------------------------------------------------------
     C     $SQLDrop      Begsr

     C                   eval      sqlStm = 'Drop Table ' +
     C                                %trim(BDlib) + '/' +
     C                                %trim(BDFile)

     c/Exec Sql
     c+    declare drp statement
     c/End-Exec

     c/Exec Sql
     c+    prepare drp from :sqlStm
     c/End-Exec

     c/Exec Sql
     c+    execute drp
     c/End-Exec

     C                   Endsr
      *---------------------------------------------------------------
     C* SQL Add to Table
      *---------------------------------------------------------------
     C     $SQLAddRec    Begsr
     C
     C*                   eval      O#NUMFLS = o#numfiles

     C                   eval      sqlStm1 = 'insert into ' +
     C                                %trim(BDlib) + '/' +
     C                                %trim(BDFile) + '('    +
     C                                ' LIB,' +
     C                                ' OUTQ,' +
     C                                ' IPADDR,' +
     C                                ' NBRSPLF,' +
     C                                ' OUTQSTS,' +
     C                                ' RMTQUE,' +
     C                                ' WSCST,' +
     C                                ' WTRSTS,' +
     C                                ' OUTQDSC,' +
     C                                ' SYSTEM' +
     C                                ') Values(' + tick +
     c                                o#lib      + tick + ', ' + tick +
     c                                o#outq     + tick + ', ' + tick +
     c                                o#rmtsys   + tick + ', ' +
     c*                               o#rmtsys   + tick + ', ' + tick +
     c*                               %char(O#NUMFLS) +  tick + ', ' + tick +
     c                                %char(O#NUMFLS) +         ', ' + tick +
     c                                rmtstato   + tick + ', ' + tick +
     c                                rmtque     + tick + ', ' + tick +
     c                                o#mfg      + tick + ', ' + tick +
     c                                rmtstat    + tick + ', ' + tick +
     c                                QSPOQD     + tick + ', ' + tick +
     c                                sysnam     + tick + ')'

     c/Exec Sql
     c+    declare wrt statement
     c/End-Exec

     c/Exec Sql
     c+    prepare wrt from :sqlStm1
     c/End-Exec

     c/Exec Sql
     c+    execute wrt
     c/End-Exec

     C                   Endsr
