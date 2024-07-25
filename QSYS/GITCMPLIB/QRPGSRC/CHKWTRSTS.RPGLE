     **-- Header specification:  ---------------------------------------------**
     H Option( *SrcStmt )
     *----------------------------------------------------------------
     *   Copyright (C) 1995 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CHKWTRSTS  Check Writer Status
     *  06 June 2017
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    06/14/17  KDE  7.10
     *      - Create
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     **-- API error data structure:  -----------------------------------------**
     D ApiError        Ds
     D  AeBytPrv                     10i 0 Inz( %Size( ApiError ))
     D  AeBytAvl                     10i 0
     D  AeExcpId                      7a
     D                                1a
     D  AeExcpDta                   128a
     **-- Output queue information structure:  -------------------------------**
     D OUTQ0200        Ds
     D  O2BytRtn                     10i 0
     D  O2BytAvl                     10i 0
     D  O2OutQnam                    10a
     D  O2OutQlib                    10a
     D  O2FilOrd                     10a
     D  O2DspAnyF                    10a
     D  O2JobSep                     10i 0
     D  O2OprCtl                     10a
     D  O2DtaQnam                    10a
     D  O2DtaQlib                    10a
     D  O2AutChk                     10a
     D  O2NbrF                       10i 0
     D  O2OutQsts                    10a
     D  O2OutQtxt                    50a
     D  O2NbrSplFpag                 10i 0
     D  O2NbrWtrStr                  10i 0
     D  O2AutWtrStr                  10i 0
     D  O2RmtSysNamTp                 1a
     D  O2RmtSysNam                 255a
     D  O2RmtPrtQ                   128a
     D  O2MsgQnam                    10a
     D  O2MsgQlib                    10a
     D  O2ConTyp                     10i 0
     D  O2DesTyp                     10i 0
     D  O2VmMvsCls                    1a
     D  O2FrmCtlBuf                   8a
     D  O2HstPrtTfr                   1a
     D  O2MnfTypMod                  17a
     D  O2WscObjNam                  10a
     D  O2WscObjLib                  10a
     D  O2SplFaspA                    1a
     D  O2OfsMxSpfPge                10i 0
     D  O2NbrPgeRtn                  10i 0
     D  O2LenPgeRtn                  10i 0
     D  O2OfsWtrE                    10i 0
     D  O2NbrWtrRtn                  10i 0
     D  O2LenWtrRtn                  10i 0
     D  O2DesOpt                    128a
     D  O2WtrTypStr                   1a
     D  O2PrtSepPag                   1a
     D  O2RmtPrtQLong               255a
     D                                3a
     D  O2OthFlds                   120a
     D  O2Data                     1024a
     **
     D O2MxSpfPge      Ds
     D  O2Nbrpag                     10i 0
     D  O2StrTim                      8a
     D  O2EndTim                      8a
     **
     D O2WtrE          Ds                  Based( pWtrE )
     D  O2WtrJobNam                  10a
     D  O2WtrJobUsr                  10a
     D  O2WtrJobNbr                   6a
     D  O2WtrJobSts                  10a
     D  O2PrtDevNam                  10a
     **
     D PxOutqNam       s             20a
     D PxWtrSts        s             12a
     *----------------------------------------------------------------
     *  Procedure Calls
     *
     *----------------------------------------------------------------
     **-- Retrieve output queue information:  -----------------------**
     D RtvOutqInf      Pr                  ExtPgm( 'QSPROUTQ' )
     D  RqRcvVar                  32767a          Options( *VarSize )
     D  RqRcvVarLen                  10i 0 Const
     D  RqFmtNam                      8a   Const
     D  RqOutQ                       20a   Const
     D  RqError                   32767a          Options( *VarSize )
     **
     **-- Mainline:  -----------------------------------------------**
     **
     C     *Entry        Plist
     C                   Parm                    PxOutqNam
     C                   Parm                    PxWtrSts
     **
     C                   Eval       PxWtrSts    = *Blanks
     **
     C                   CallP     RtvOutqInf( OUTQ0200
     C                                       : %Size( OUTQ0200 )
     C                                       : 'OUTQ0200'
     C                                       : PxOutqNam
     C                                       : ApiError
     C                                       )
     **
     C                   If         AeBytAvl    = *Zero
     **
     C                   If         O2ConTyp    = 2
     C                   Eval       PxWtrSts    = 'STOPPED'
     **
     C                   If         O2NbrWtrRtn > *Zero
     C                   Eval       pWtrE       =  %Addr( OUTQ0200 ) +
     C                                             O2OfsWtrE
     **
     C                   Select
     C                   When       O2WtrJobSts = 'STR '
     C                   Eval       PxWtrSts    = 'ACTIVE'
     **
     C                   When       O2WtrJobSts = 'END '
     C                   Eval       PxWtrSts    = 'STOPPED'
     **
     C                   When       O2WtrJobSts = 'JOBQ'
     C                   Eval       PxWtrSts    = 'STARTING'
     **
     C                   When       O2WtrJobSts = 'HLD '
     C                   Eval       PxWtrSts    = 'BEING HELD'
     **
     C                   When       O2WtrJobSts = 'MSGW'
     C                   Eval       PxWtrSts    = 'MESSAGE WAIT'
     C                   EndSl
     **
     C                   EndIf
     C                   EndIf
     C                   EndIf
     **
     C                   Return
     **
