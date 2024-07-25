     H NOMAIN
     *----------------------------------------------------------------
     *
     *  BFCJOBD     Job description routines.
     *  20 March 2007
     *  Dave Sommerville
     *
510  *    03/20/07  DAS  5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    When creating for the first time:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)
     *
     *      CRTSRVPGM SRVPGM(*) SRCFILE(*/QSRVSRC) TGTRLS(V5R2M0)
     *                ACTGRP(*CALLER) ALWUPD(*YES)
     *
     *      ADDBNDDIRE BNDDIR(*/BFCBND) OBJ((*))
     *
     *                    --- OR ---
     *    When updating:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)
     *
     *      UPDSRVPGM SRVPGM(*) MODULE(*) SRCFILE(*/QSRVSRC)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /COPY qcopysrc,p.bfcjobd

     *----------------------------------------------------------------
     * Constants
     *----------------------------------------------------------------

      ** Maximum libraries allowed on library list
     D MAXLIBL         C                   Const(250)

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

      ** Field reference for Library Name (APIs use 11-pos name)
     D LIBNAME         S             11A

     *----------------------------------------------------------------
     * API Error Data Structure
     *----------------------------------------------------------------

     D ll_Error        DS                  EXPORT
     D  ll_DSLen                     10I 0 Inz(%Size(ll_Error))
     D  ll_ByteRtn                   10I 0 Inz
     D  ll_cpfmsgid                   7A
     D  ll_reserved                   1A
     D  ll_msgdata                  132A

     *----------------------------------------------------------------
     * API Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  RtvJobDAPI - Retrieve job description information API
     *----------------------------------------------------------------
     D RtvJobDAPI...
     D                 Pr                  ExtPgm( 'QWDRJOBD' )
     D                            32767
     D                               10I 0
     D                                8
     D                               20
     D                              272


      *  ===================================================================
      *  = Procedure..... RtvJobDInlLibL                                   =
      *  = Description... Retrieve job description's initial library list  =
      *  ===================================================================

     P RtvJobDInlLibl...
     P                 B                   Export
     D                 PI            11A   DIM(250)
     D  JobD                         10    Value
     D  JobDLib                      10    Value
     D  APIError                    272    Options( *NoPass )

      *  -------------------------------------------------------------------
      *  - Data definitions                                                -
      *  -------------------------------------------------------------------

      ** Return value is returned in LIBLARRAY
     D Libl            DS
     D* LiblArray                          DIM(LMAXLIBL) LIKE(LIBNAME)
      ** Due to a bug in the RPG compiler, a global named constant
      ** cannot be specifed on the DIM keyword. :(
     D  LiblArray                          DIM(250) LIKE(LIBNAME)

     D RcvVar          DS         32767
     D                              360
     D  OffsetToLibs                 10I 0
     D  NbrLibsInList                10I 0

     D RcvVarLen       S             10I 0 Inz( %Len( RcvVar ) )
     D Format          S              8    Inz( 'JOBD0100' )

     D QualJobD        S             20
     D JobDLibs        S            275    Inz( *Blank )

     D Pos             S             10I 0

     D NoAPIError      C                   Const( *Zero )
     D APIErrorPassed  S               N

     D APIErrorDS      DS
     D  BytesProvided                10I 0 Inz( %Size( APIErrorDS ) )
     D  BytesAvail                   10I 0 Inz( *Zero )
     D  MsgID                         7    Inz( *Blanks )
     D  Reserved                      1    Inz( X'00' )
     D  MsgDta                      256    Inz( *Blanks )

      *  -------------------------------------------------------------------
      *  - Determine whether API error parameter was passed                -
      *  -------------------------------------------------------------------

     C                   If        %Parms > 2
     C                   Eval      APIErrorPassed = *On
     C                   EndIf

      *  -------------------------------------------------------------------
      *  - Retrieve job description information                            -
      *  -------------------------------------------------------------------

     C                   Reset                   APIErrorDS

     C                   Eval      QualJobD = JobD + JobDLib

     C                   CallP     RtvJobDAPI(
     C                                         RcvVar     :
     C                                         RcvVarLen  :
     C                                         Format     :
     C                                         QualJobD   :
     C                                         APIErrorDS
     C                                      )

     C                   If        BytesAvail <> NoAPIError
     C                   ExSr      ReturnError
     C                   EndIf

      *  -------------------------------------------------------------------
      *  - Extract initial library list and return it to caller            -
      *  -------------------------------------------------------------------

     C                   Eval      Pos = OffsetToLibs + 1

     C                   Eval      Libl = %Subst(
     C                                            RcvVar             :
     C                                            Pos                :
     C                                            NbrLibsInList * 11
     C                                          )

     C                   Return    LiblArray

      *  -------------------------------------------------------------------
      *  - Subroutine.... ReturnError                                      -
      *  - Description... Return error condition to caller                 -
      *  -------------------------------------------------------------------

     C     ReturnError   BegSr

     C                   If        APIErrorPassed
     C                   Eval      APIError = APIErrorDS
     C                   EndIf

     C                   Return    *Blank

     C                   EndSr

     P RtvJobDInlLibL...
     P                 E
