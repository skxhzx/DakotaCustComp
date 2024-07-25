     h dftactgrp(*NO)
      *---------------------------------------------------------------------
      *  Description : Retrieve lock information APIs
      *  Author  . . : Carsten Flensburg
      *  Published . : Club Tech iSeries Programming Tips Newsletter
      *  Date  . . . : September 29, 2005
      *  Source  . . : http://www.think400.dk/apier_9.htm#eks0001
      *                MODIFIED FOR BFC USE
      *---------------------------------------------------------------------
      *
     **-- Api error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPro                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0 Inz
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      128a
     **-- Global variables:
     D Idx             s             10u 0
     D IdxKey          s             10u 0
     D ApiRcvSiz       s             10u 0
     D MsgTxt          s            512a   Varying
     D PxMbrNam        s             10a   inz('*NONE     ')
     D PxRelRcdNbr     s             10p 0 inz(0)
     **-- List API parameters:
     D LstApi          Ds                  Qualified  Inz
     D  NbrKeyRtn                    10i 0 Inz( %Elem( LstApi.KeyFld ))
     D  KeyFld                       10i 0 Dim( 3 )
     **-- Global constants:
     D OFS_MSGDTA      c                   16
     D NO_RTN_KEY      c                   0
     D TYP_JOBTHR      c                   0
     D TYP_LCKSPC      c                   1
     D ALL_RCD         c                   0
     D OBJ_LVL         c                   0
     D RCD_LVL         c                   1
     **-- Object identification:
     D LOBJ0100        Ds                  Qualified
     D  ObjIdSiz                     10i 0 Inz( %Size( LOBJ0100 ))
     D  ObjNam                       10a
     D  ObjLib                       10a
     D  ObjLibAps                    10a
     D  ObjTyp                       10a
     D  MbrNam                       10a
     D                                2a   Inz( x'0000' )
     D  RcdLckI                      10i 0
     D  RelRcdNbr                    10u 0
     **
     D LOBJ0200        Ds                  Qualified
     D  ObjHdlSiz                    10i 0 Inz( %Size( LOBJ0200 ))
     D  ObjLckHdl                    64a
     **-- Lock filter:
     D LKFL0100        Ds                  Qualified
     D  FltSiz                       10i 0 Inz( %Size( LKFL0100 ))
     D  FltLckStt                    10i 0 Inz( *Zero )
     D  FltLckScp                    10i 0 Inz( *Zero )
     D  FltLckSts                    10i 0 Inz( *Zero )
     D  FltLckHlrTyp                  1a   Inz( '0' )
     D  FltMbrLckTyp                  1a   Inz( '0' )
     **-- Lock information:
     D LCKI0100        Ds                  Qualified  Based( pLckInf )
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  TypEnt                       10i 0
     D  ObjNamExt                    30a
     D  ObjLib                       10a
     D  ObjAsp                       10a
     D  ObjLibAsp                    10a
     D  ObjAspNbr                    10i 0
     D  ObjLibAspNbr                 10i 0
     D  ObjTyp                       10a
     D  ExtObjAtr                    10a
     D  NbrLckInfEntA                10i 0
     D  OfsLckInfEnt                 10i 0
     D  NbrLckInfEntR                10i 0
     D  LenLckInfEnt                 10i 0
     **
     D LckInfEnt       Ds                  Based( pLckInfEnt )  Qualified
     D  LckStt                       10a
     D                                2a
     D  LckSts                       10i 0
     D  LckScp                        1a
     D                                3a
     D  LckSpcId                     20a
     D  LckRqsHdl                    64a
     D  LckCnt                       10i 0
     D  MbrNam                       10a
     D  MbrLckTyp                     1a
     D                                1a
     D  RelRcdNbr                    10i 0
     D  DisHlrInf                    10i 0
     D  DisKeyInf                    10i 0
     D  NbrKeyRtn                    10i 0
     D  HlrTyp                       10i 0
     **-- Key information:
     D KeyInf          Ds                  Based( pKeyInf )  Qualified
     D  FldInfLen                    10i 0
     D  KeyFld                       10i 0
     D  DtaTyp                        1a
     D                                3a
     D  DtaLen                       10i 0
     D  Data                         64a
     **-- Lock holder - job/thread format:
     D HlrJobThr       Ds                  Based( pJobThrFmt )  Qualified
     D  HlrInfSiz                    10i 0
     D  JobNam                       10a
     D  UsrNam                       10a
     D  JobNbr                        6a
     D  ThdId                         8a
     D                                2a
     D  ThdHdl                       10u 0
     **-- Lock holder - lock space format:
     D HlrLckSpc       Ds                  Based( pLckSpcFmt )  Qualified
     D  HlrInfSiz                    10i 0
     D  HldLckSpcId                  20a
     D  UsrNam                       10a
     D  JobNbr                        6a
     D  ThdId                         8a
     D                                2a
     D  ThdHdl                       10u 0
     **-- Lock request identification:
     D LRQI0100        Ds          4096    Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  OfsStmIds                    10i 0
     D  NbrStmIds                    10i 0
     D  OfsPrcNam                    10i 0
     D  LenPrcNam                    10i 0
     D  PgmNam                       10a
     D  PgmLib                       10a
     D  PgmAsp                       10a
     D  PgmLibAsp                    10a
     D  PgmAspNbr                    10i 0
     D  PgmLibAspNbr                 10i 0
     D  MiInstNbr                    10i 0
     D  ModNam                       10a
     D  ModLib                       10a
     **-- API return information:    64a   Const
     D PrcNam          s           1024a   Inz  Varying
     D StmIds          s             10a   Inz  Dim( 64 )
     D pJobThrFmt      s               *   Inz( *Null )
     D pLckSpcFmt      s               *   Inz( *Null )
     **
     D KeyDta          Ds                  Qualified  Inz
     D  ActJobSts                     4a
     D  FcnNam                       10a
     D  MsgRpy                        1a

     **-- Retrieve lock information:
     D RtvLckInf       Pr                  ExtPgm( 'QWCRLCKI' )
     D  RcvVar                    65535a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  ObjId                        68a   Const  Options( *VarSize )
     D  ObjIdFmt                      8a   Const
     D  NbrKeyFld                    10i 0 Const
     D  KeyFldRtn                    10i 0 Const  Options( *VarSize )  Dim( 32 )
     D  Filter                       18a   Const  Options( *VarSize )
     D  FltFmt                        8a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Retrieve lock request information:
     D RtvLckRqsInf    Pr                  ExtPgm( 'QWCRLRQI' )
     D  RcvVar                    65535a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  RqsHdl                       64a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  MsgId                         7a   Const
     D  MsgFq                        20a   Const
     D  MsgDta                      128a   Const
     D  MsgDtaLen                    10i 0 Const
     D  MsgTyp                       10a   Const
     D  CalStkE                      10a   Const  Options( *VarSize )
     D  CalStkCtr                    10i 0 Const
     D  MsgKey                        4a
     D  Error                     32767a          Options( *VarSize )
     **-- Register termination exit:
     D CeeRtx          Pr                    ExtProc( 'CEERTX' )
     D  procedure                      *     ProcPtr   Const
     D  token                          *     Options( *Omit )
     D  fb                           12a     Options( *Omit )
     **-- Unregister termination exit:
     D CeeUtx          Pr                    ExtProc( 'CEEUTX' )
     D  procedure                      *     ProcPtr   Const
     D  fb                           12a     Options( *Omit )
     **-- Copy memory:
     D memcpy          Pr              *   ExtProc( '_MEMMOVE' )
     D pOutMem                         *   Value
     D pInpMem                         *   Value
     D iMemSiz                       10u 0 Value

     **-- Send completion message:
     D SndCmpMsg       Pr            10i 0
     D  PxMsgDta                    512a   Const  Varying
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- Send message by type:
     D SndMsgTyp       Pr            10i 0
     D  PxMsgDta                    512a   Const  Varying
     D  PxMsgTyp                     10a   Const
     **-- Terminate program:
     D TrmPgm          Pr
     D  pPtr                           *

     **-- Entry parameters:
     D SavOfs          Ds                  Based( pNull )
     D  NbrElm                        5i 0
     D  DatFrm                        7a
     D  TimFrm                        6a
     **
     D RTNLCKINF       Pr
     D  PxObjNam_q                   20a
     D  PxObjTyp                     10a
     D  PxLkjNam                     10a
     D  PxLkjUsr                     10a
     D  PxLkjNum                      6a
     **
     D RTNLCKINF       Pi
     D  PxObjNam_q                   20a
     D  PxObjTyp                     10a
     D  PxLkjNam                     10a
     D  PxLkjUsr                     10a
     D  PxLkjNum                      6a

      /Free
        //-- Step 1:
        ExSr  InzParms;

        //-- Step 2a:
        ApiRcvSiz = 65535;
        pLckInf   = %Alloc( ApiRcvSiz );

        LCKI0100.BytAvl = *Zero;

        DoU  LCKI0100.BytAvl <= ApiRcvSiz  Or  ERRC0100.BytAvl > *Zero;

          //-- Step 2b:
          If  LCKI0100.BytAvl > ApiRcvSiz;
            ApiRcvSiz  = LCKI0100.BytAvl;
            pLckInf    = %ReAlloc( pLckInf: ApiRcvSiz );
          EndIf;

          RtvLckInf( LCKI0100
                   : ApiRcvSiz
                   : 'LCKI0100'
                   : LOBJ0100
                   : 'LOBJ0100'
                   : LstApi.NbrKeyRtn
                   : LstApi.KeyFld
                   : LKFL0100
                   : 'LKFL0100'
                   : ERRC0100
                   );
        EndDo;

        //-- Step 3:

        CeeRtx( %Paddr( TrmPgm ): pLckInf: *Omit );

        If  ERRC0100.BytAvl > *Zero;

          SndEscMsg( ERRC0100.MsgId
                   : 'QCPFMSG'
                   : %Subst( ERRC0100.MsgDta: 1: ERRC0100.BytAvl - OFS_MSGDTA )
                   );
        Else;

          //-- Step 4:
          ExSr  PrcLstEnt;

          SndCmpMsg( 'Lock API example completed normally.' );
        EndIf;

        //-- Step 5:
        CeeUtx( %Paddr( TrmPgm ): *Omit );

        TrmPgm( pLckInf );

        PxLkjNam = HlrJobThr.JobNam;
        PxLkjUsr = HlrJobThr.UsrNam;
        PxLkjNum = HlrJobThr.JobNbr;

        *InLr = *On;
        Return;

        BegSr  InzParms;

          LOBJ0100.ObjNam    = %Subst( PxObjNam_q:  1: 10 );
          LOBJ0100.ObjLib    = %Subst( PxObjNam_q: 11: 10 );
          LOBJ0100.ObjLibAps = '*';
          LOBJ0100.ObjTyp    = PxObjTyp;
          LOBJ0100.MbrNam    = PxMbrNam;

          Select;
          When  PxRelRcdNbr = -1;
            LOBJ0100.RcdLckI   = RCD_LVL;
            LOBJ0100.RelRcdNbr = ALL_RCD;

          When  PxRelRcdNbr >  0;
            LOBJ0100.RcdLckI   = RCD_LVL;
            LOBJ0100.RelRcdNbr = PxRelRcdNbr;

          Other;
            LOBJ0100.RcdLckI   = OBJ_LVL;
            LOBJ0100.RelRcdNbr = 0;
          EndSl;

          LstApi.KeyFld(1) = 101;
          LstApi.KeyFld(2) = 601;
          LstApi.KeyFld(3) = 1307;

        EndSr;

        BegSr  PrcLstEnt;

          pLckInfEnt = pLckInf + LCKI0100.OfsLckInfEnt;

          For  Idx = 1  to LCKI0100.NbrLckInfEntR;

            If  LckInfEnt.LckStt <> '*NONE';

              If  LckInfEnt.HlrTyp = TYP_JOBTHR;
                pJobThrFmt = pLckInfEnt + LckInfEnt.DisHlrInf;
              Else;
                pLckSpcFmt = pLckInfEnt + LckInfEnt.DisHlrInf;
              EndIf;

              ExSr  GetKeyDta;

              RtvLckRqsInf( LRQI0100
                          : %Size( LRQI0100 )
                          : 'LRQI0100'
                          : LckInfEnt.LckRqsHdl
                          : ERRC0100
                          );

              If  ERRC0100.BytAvl = *Zero;
                ExSr  PrcRqsEnt;
              EndIf;

              // All retrieved data available at this point:

              If  pJobThrFmt <> *Null;
                // Job or thread information retrieved
              Else;
                // Lock space information retrieved
              EndIf;

              If  Idx < LCKI0100.NbrLckInfEntR;
                Reset  KeyDta;
                Reset  StmIds;
                Reset  PrcNam;
                Reset  pJobThrFmt;
                Reset  pLckSpcFmt;
                pLckInfEnt += LCKI0100.LenLckInfEnt;
              EndIf;
            EndIf;
          EndFor;

        EndSr;

        BegSr  PrcRqsEnt;

          If  LRQI0100.OfsPrcNam > *Zero;
            PrcNam = %Subst( LRQI0100: LRQI0100.OfsPrcNam: LRQI0100.LenPrcNam );
          EndIf;

          If  LRQI0100.OfsStmIds > *Zero;
            memcpy( %Addr( StmIds )
                  : %Addr( LRQI0100 ) + LRQI0100.OfsStmIds
                  : LRQI0100.NbrStmIds * %Size( StmIds )
                  );
          EndIf;

        EndSr;

        BegSr  GetKeyDta;

          pKeyInf = pLckInfEnt + LckInfEnt.DisKeyInf;

          For  IdxKey = 1  To LckInfEnt.NbrKeyRtn;

            Select;
            When  KeyInf.KeyFld = 101;

              KeyDta.ActJobSts = %Subst( KeyInf.Data: 1: KeyInf.DtaLen );

            When  KeyInf.KeyFld = 601;

              KeyDta.FcnNam = %Subst( KeyInf.Data: 1: KeyInf.DtaLen );

            When  KeyInf.KeyFld = 1307;

              KeyDta.MsgRpy = %Subst( KeyInf.Data: 1: KeyInf.DtaLen );
            EndSl;

            If  IdxKey < LckInfEnt.NbrKeyRtn;
              pKeyInf = pKeyInf + KeyInf.FldInfLen;
            EndIf;
          EndFor;

        EndSr;

      /End-Free

     **-- Send completion message:  ------------------------------------------**
     P SndCmpMsg       B
     D                 Pi            10i 0
     D  PxMsgDta                    512a   Const  Varying
     **
     D MsgKey          s              4a

      /Free

        SndPgmMsg( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*COMP'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return  0;

        EndIf;

      /End-Free

     **
     P SndCmpMsg       E
     **-- Send escape message:  ----------------------------------------------**
     P SndEscMsg       B
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying
     **
     D MsgKey          s              4a

      /Free

        SndPgmMsg( PxMsgId
                 : PxMsgF + '*LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return   0;
        EndIf;

      /End-Free

     P SndEscMsg       E
     **-- Send message by type:  ---------------------------------------------**
     P SndMsgTyp       B
     D                 Pi            10i 0
     D  PxMsgDta                    512a   Const  Varying
     D  PxMsgTyp                     10a   Const
     **
     D MsgKey          s              4a

      /Free

        SndPgmMsg( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : PxMsgTyp
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return   0;
        EndIf;

      /End-Free

     P SndMsgTyp       E
     **-- Terminate program:  ------------------------------------------------**
     P TrmPgm          B
     D                 Pi
     D  pPtr                           *

      /Free

        DeAlloc  pPtr;

        *InLr = *On;

        Return;

      /End-Free

     P TrmPgm          E
