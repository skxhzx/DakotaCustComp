      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  BFCLIBSIZ   Populate file BFCLIBSIZ
     *  24 May 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    05/24/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D bfclibsiz     E ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

      *---------------------------------------------------------------------
      *API prototypes
      *---------------------------------------------------------------------
      *
      *QLIRLIBD - Retrieve Library Description
      *
     D qlirlibd        PR                  Extpgm('QLIRLIBD')
     D   RcvVar                   32767A         Options(*Varsize)
     D   RcvVarLen                   10I 0 Const
     D   Library                     10A   Const
     D   LibAtrToRtv                       Const Like(LibAtrToRtvDS)
     D   ApiError                          Like(QUSEC)
      *
      *QUSCRTUS - Create User Space
      *
     D quscrtus        PR                  ExtPgm('QUSCRTUS')
     D   qUsrSpc                     20A   Const
     D   ExtendedAtr                 10A   Const
     D   InitialSize                 10I 0 Const
     D   InitialValue                 1A   Const
     D   PublicAuth                  10A   Const
     D   Text                        50A   Const
     D   Replace                     10A   Const Options(*Nopass)
     D   ApiError                                Like(QUSEC)
     D                                           Options(*Nopass)
      *
      *QUSDLTUS - Delete User Space
      *
     D qusdltus        PR                  ExtPgm('QUSDLTUS')
     D   qUsrSpc                     20A   Const
     D   ApiError                                Like(QUSEC)
      *
      *QUSPTRUS - Retrieve Pointer to User Space
      *
     D qusptrus        PR                  ExtPgm('QUSPTRUS')
     D   qUsrSpc                     20A   Const
     D   UsrSpc@                       *
     D   ApiError                                Like(QUSEC)
     D                                           Options(*Nopass)
      *
      *QUSLOBJ - List Objects
      *
     D quslobj         PR                  Extpgm('QUSLOBJ')
     D   qUsrSpc                     20A   Const
     D   Format                       8A   Const
     D   qObj                        20A   Const
     D   ObjType                     10A   Const
     D   ApiError                          Options(*Nopass) Like(QUSEC)
     D   AutCtl                   32767A   Const Options(*Nopass:*Varsize)
     D   SelCtl                   32767A   Const Options(*Nopass:*Varsize)
      *
      *QWCCVTDT - Convert Date/Time Format
      *
     D qwccvtdt        PR                  Extpgm('QWCCVTDT')
     D   InputFormat                 10A   Const
     D   InputVar                    17A   Const Options(*Varsize)
     D   OutputFormat                10A   Const Options(*Varsize)
     D   OutputVar                   17A   Const Options(*Varsize)
     D   ApiError                          Like(QUSEC)
      *
      *---------------------------------------------------------------------
      *API structures
      *---------------------------------------------------------------------
      *
      *QUSEC - Generic API error parameter structure
      *
     D QUSEC           DS                  Qualified
     D  ErrBytesProv                 10I 0 Inz(%size(QUSEC))
     D  ErrBytesAvail                10I 0 Inz
     D  ErrMsgID                      7A
     D                                1
     D  ErrMsgDta                   512A
      *
      *Varying Length data structure (QLIRLIBD)
      *
     D VarLenDS        DS                  Qualified Based(VarLen@)
     D   RtnDtaLen                   10I 0
     D   KeyID                       10I 0
     D   FldSize                     10I 0
     D   FldValue                  1000A
     D     FldValInt                 10I 0 Overlay(FldValue)
      *
      *Library attributes to retrieve (QLIRLIBD)
      *
     D LibAtrToRtvDS   DS                  Qualified
     D   Nbr                         10I 0
     D   Elm                         10I 0 Dim(7)
      *
      *Returned data (QLIRLIBD)
      *
     D QLIRR           DS         32767    Qualified
     D   BytesReturn                 10I 0
     D   BytesAvail                  10I 0
     D   VarLenRcdRtn                10I 0
     D   VarLenRcdAvl                10I 0
      *
      *Library size data structure (QLIRLIBD)
      *
     D LibSizeDS       DS
     D   LibSize                     10I 0
     D   LibSizeMult                 10I 0
     D   LibInfSts                     N
     D                                3A
      *
      *List API header structure (QUSLOBJ)
      *
     D QUSH0100        DS                  Based(QUSH0100@) Qualified
     D   UserArea                    64A
     D   GenHdrSize                  10I 0
     D   StructRlsLvl                 4A
     D   FormatName                   8A
     D   ApiUsed                     10A
     D   DatTimCrt                   13A
     D   InfStatus                    1A
     D   UsrSpcSize                  10I 0
     D   InpParmOS                   10I 0
     D   InpParmSize                 10I 0
     D   HeaderOS                    10I 0
     D   HeaderSize                  10I 0
     D   ListDataOS                  10I 0
     D   ListDataSize                10I 0
     D   EntryNbr                    10I 0
     D   EntrySize                   10I 0
     D   EntryCCSID                  10I 0
     D   CountryID                    2A
     D   LanguageID                   3A
     D   SubSetInd                    1A
     D                               42A
     D APIEntryPoint                256A
     D                              128A
      *
      *OBJL0400 returned data structure (QUSLOBJ)
      *
     D OBJL0400        DS                  Qualified Based(OBJL0400@)
     D   ObjName                     10A
     D   ObjLib                      10A
     D   ObjType                     10A
     D   ObjInfSts                    1A
     D   ObjExtAtr                   10A
     D   ObjText                     50A
     D   ObjUsrAtr                   10A
     D   ObjRsv1                      7A
     D   ObjAuxStg                   10i 0
     D   ObjOwnBy                    10A
     D   ObjDomain                    2A
     D   ObjCrtDteTim                 8A
     D   ObjChgDteTim                 8A
     D   ObjStg                      10A
     D   ObjCmpSts                    1A
     D   ObjAlwChg                    1A
     D   ObjPgmChg                    1A
     D   ObjAdtVal                   10A
     D   ObjDgtSgn1                   1A
     D   ObjDgtSgn2                   1A
     D   ObjDgtSgn3                   1A
     D   ObjRsv2                      2A
     D   ObjAuxStg2                  10i 0
     D   ObjSrcNam                   10A
     D   ObjSrcLib                   10A
     D   ObjSrcMbr                   10A
     D   ObjSrcUpd                   13A
     D   ObjCrtBy                    10A
      *
      *---------------------------------------------------------------------
      *Global variables
      *---------------------------------------------------------------------
      *
     D UsrSpc@         S               *
     D qUsrSpc         DS
     D   UsrSpc                      10A   Inz('QUSLOBJ')
     D   UsrSpcLib                   10A   Inz('QTEMP')
     D UsrSpcSize      C                   10000000
      *
     D                 DS
     D L                             10I 0
     D LibDArr                             Dim(5000)
     D LibName                       10A   Overlay(LibdArr)
     D LibText                       50A   Overlay(LibdArr:*Next)
     D NbrLibObj                     10I 0 Overlay(LibdArr:*Next)
     D LibTotSize                    20I 0 Overlay(LibdArr:*Next)
      *
     D R                             10I 0
     D TotLibX         S             10A
     D NbrLibObjX      S             10A
     D LibTotSizeX     S             20A
     D OutFile         S             20A

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Clear file

        exsr DltLibDtls;

        //Set variables

        LibAtrToRtvDS.Nbr    = 2;
        LibAtrToRtvDS.Elm(1) = 6; //Library size
        LibAtrToRtvDS.Elm(2) = 7; //Objects in library
        L          = 0;
        LibName    = *HIVAL;
        LibText    = *HIVAL;
        NbrLibObj  = *HIVAL;
        LibTotSize = *HIVAL;

        //Create the user space

        reset QUSEC;
        quscrtus( qUsrSpc : *blanks : UsrSpcSize : x'00' : '*ALL' :
                  *blanks : '*NO' : QUSEC );
        if QUSEC.ErrBytesAvail > 0 and QUSEC.ErrMsgID <> 'CPF9870';
          exsr *pssr;
        endif;

        //Retrieve the pointer to the user space.

        reset QUSEC;
        qusptrus( qUsrSpc : UsrSpc@ : QUSEC );
        if QUSEC.ErrBytesAvail > 0;
          exsr *pssr;
        endif;

        //List all the specified libraries into the user space

        reset QUSEC;
        quslobj( qUsrSpc : 'OBJL0400' : '*ALLUSR   QSYS' : '*LIB' : QUSEC );
        if QUSEC.ErrBytesAvail > 0;
          exsr *pssr;
        endif;

        //Process each library in the user space
        QUSH0100@ = UsrSpc@;
        OBJL0400@ = QUSH0100@ + QUSH0100.ListDataOS;
        for L = 1 to QUSH0100.EntryNbr;
          exsr RtvLibDtls;
          exsr WrtLibDtls;
          OBJL0400@ = OBJL0400@ + QUSH0100.EntrySize;
        endfor;

        qusdltus( qUsrSpc : QUSEC );

        return;

        //RtvLibDtls: Retrieve library details

        begsr RtvLibDtls;

          //Don't try to process QSYS

          if OBJL0400.ObjName = 'QSYS';
            blsLib    = OBJL0400.ObjName;
            blsLibTxt = OBJL0400.ObjText;
            blsOwnBy  = '';
            blsCrtBy  = '';
            blsCrtDt  = '';
            blsObj    = 0;
            blsSize   = 0;
            leavesr;
          endif;

          //Retrieve the library details
          clear QLIRR;
          reset QUSEC;
          qlirlibd( QLIRR : %size( QLIRR ) : OBJL0400.ObjName :
                    LibAtrToRtvDS : QUSEC );
          if QUSEC.ErrBytesAvail > 0;
            blsLib    = OBJL0400.ObjName;
            blsLibTxt = '**UNABLE TO RETRIEVE DETAILS**';
            blsOwnBy  = '';
            blsCrtBy  = '';
            blsCrtDt  = '';
            blsObj    = 0;
            blsSize   = 0;
            leavesr;
          endif;

          blsLib    = OBJL0400.ObjName;
          blsLibTxt = OBJL0400.ObjText;
          blsOwnBy  = OBJL0400.ObjOwnBy;
          blsCrtBy  = OBJL0400.ObjCrtBy;
          qwccvtdt( '*DTS': OBJL0400.ObjCrtDteTim:
                    '*YYMD': blsCrtDt: QUSEC);

          //Process the library detail variable-length records

          VarLen@ = %addr( QLIRR ) + 16;
          for R = 1 to QLIRR.VarLenRcdRtn;
            select;
              when VarLenDS.KeyID = 6; //Library total size
                LibSizeDS = VarLenDS.FldValue;
                blsSize = LibSize * LibSizeMult;
              when VarLenDS.KeyID = 7; //Number of objects in library
                blsObj = VarLenDS.FldValInt;
              other;
            endsl;
            VarLen@ = VarLen@ + VarLenDS.RtnDtaLen;
          endfor;

        endsr;

        //Delete existing records

        begsr DltLibDtls;

          exec sql delete from mrcclean2/bfclibsiz;

        endsr;

        //Write library to file

        begsr WrtLibDtls;

          exec sql insert into mrcclean2/bfclibsiz
                 values(:blslib,
                        :blslibtxt,
                        :blsownby,
                        :blscrtby,
                        :blscrtdt,
                        :blsobj,
                        :blssize,
                        current timestamp);

        endsr;

        //*PSSR Error subroutine

        begsr *pssr;
          qusdltus( qUsrSpc : QUSEC );
        endsr;

      /end-free
