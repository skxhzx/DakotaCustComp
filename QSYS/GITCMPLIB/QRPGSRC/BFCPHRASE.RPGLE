     H NoMain
      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    When creating for the first time:
     *
     *      CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)
     *
     *      CRTSRVPGM SRVPGM(*) SRCFILE(*/QSRVSRC) TGTRLS(V5R2M0)
     *                ACTGRP(BFCPHRASE) ALWUPD(*YES)
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
     * This program must be compiled with named activation group
     * BFCPHRASE. Re: Some programs in the call stack use the
     * defalut activation group. Because of this we end up with a
     * recursive error after getting out of a program that calls this
     * and then getting back into it.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  BFCPHRASE  Phrase routines
     *  09 July 2008
     *  Dave Sommerville
     *
600 A*    07/09/08  DAS  6.00  P#00045
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND':'HTTPAPI')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcphras
100bA /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,httpapi_h

     D fmtPhrase2      PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)


     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds
      /copy qcopysrc,c#file2ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  gDigits        c                   '0123456789'

     D  gVar           s             30    dim(5)
     D  gVarSize       s              3p 0 dim(5)

     D  gPos           s              3p 0
     D  gPhrase        s            100
     D  gPhraseId      s              5p 0
     D  gWhse          s              3s 0
     D  gEmp#          s              5s 0
     D  gUser          s             10
     D  gPgm           s             10
     D  gItem          s             15
     D  gWhdp          s              5
     D  gLocation      s             15
     D  gTrn#          s              7p 0
     D  gLcns          s             15
     D  gLtrn          s              7p 0

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     *  Define key for file.

     C*    keyph         klist
     C*                  kfld                    kyid
     C*                  kfld                    kylang

     *================================================================
     * Procedure: extractVars
     *================================================================
     *
     *   Usage:
     *
     *      callp   extractVars(pVars)
     *
     *   Return Value:
     *     gVar       -  Global array of variables
     *     gVarSize   -  Global array of variable sizes
     *
     *   Parameters:
     *     pVars      -  Variable string
     *
     *================================================================

     P extractVars     b                   Export

     D extractVars     pi
     D  pVars                       100    const

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D i               s              2  0
     D chrLen          s              2
     D start           s              3  0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

         for i = 1 to 5;
           gVar(i) = ' ';
           gVarSize = 0;
         endfor;

         gPos = 1;

         for i = 1 to 5;

           chrLen = %subst(pVars:gPos:2);
           if %check(gDigits:chrLen) > 0;
             leave;
           endif;

           gVarSize(i) = %dec(chrLen:2:0);

           start = gPos + 2;
           if start > %size(pVars);
             leave;
           endif;

           if (start + gVarSize(i) - 1) > %size(pVars);
             gVarSize(i) = %size(pVars) - start;
           endif;

           gVar(i) = %subst(pVars:start:gVarSize(i));

           gPos = start + gVarSize(i);

           if gPos > %size(pVars);
             leave;
           endif;

         endfor;

         return;

      /end-free
     P                 E

     *================================================================
     * Procedure: fmtPhrase
     *================================================================
     *
     *   Usage:
     *
     *      callp   fmtPhrase(:v2:v3:v4:v5)
     *
     *   Return Value:
     *     varPhrase  -  Formatted phrase
     *
     *   Parameters:
     *     pPhraseId  -  Phrase id
     *     pWhse      -  Warehouse
     *     pEmp#      -  Employee #
     *     pUser      -  Current User (Not job user)
     *     pPgm       -  Calling Program
     *     pItem      -  Item
     *     pWhdp      -  Warehouse Department
     *     pLocation  -  Location (Slot display, area code, etc.)
     *     pTrn#      -  Transaction #
     *     pLcns      -  License number
     *     pLtrn      -  License transction number
     *     pVars      -  Variables
     *
     *================================================================

     P fmtPhrase       b                   Export

     D fmtPhrase       pi           100
     D  pPhraseId                     5p 0 const
     D  pPhrase                     100
     D  pWhse                         3s 0 const
     D  pEmp#                         5s 0 const
     D  pUser                        10    const
     D  pPgm                         10    const
     D  pItem                        15    const
     D  pWhdp                         5    const
     D  pLocation                    15    const
     D  pTrn#                         7p 0 const
     D  pLcns                        15    const
     D  pLtrn                         7p 0 const
     D  pVars                       100    const

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

         gPhraseId = pPhraseId;
         gWhse     = pWhse;
         gEmp#     = pEmp#;
         gUser     = pUser;
         gPgm      = pPgm;
         gItem     = pItem;
         gWhdp     = pWhdp;
         gLocation = pLocation;
         gTrn#     = pTrn#;
         gLcns     = pLcns;
         gLtrn     = pLtrn;

         callp extractVars(pVars);

         gPhrase   = ' ';
         gPos      = 1;

        if (http_parse_xml_string( %addr(pPhrase)
                               : %len(%trimr(pPhrase))
                               : 37
                               : *null
                               : %paddr(fmtPhrase2)
                               : *null ) < 0 );
           gPhrase = 'xml error: ' + http_error();
        endif;

         return gPhrase;

      /end-free
     P                 E


     *================================================================
     * Procedure: fmtPhrase2
     *================================================================
     *
     * This is called for each XML element that's received in the
     * phrase string. The string will look something like the
     * following:
     *
     *   <P>
     *     <USER/>
     *     <T> put qty </T>
     *     <V1/>
     *     <T> into </T>
     *     <LOC/>
     *   </P>
     *
     *
     *  The DEPTH parameter indicates the nesting depth of the
     *  element received.  In the above example, the "P" tag
     *  would be depth 1 and the other tags would be depth 2.
     *
     *  The NAME parameter is the name of the XML element that
     *  has been received.  It might be something like "P",
     *  "T" or "USER".
     *
     *  The PATH indicates the elements that the current element
     *  is found inside. So, the path for "T" is "/P".
     *
     *  The VALUE parameter gives us the text that's inside that
     *  element.
     *
     *
     *      <P></P>  -  Beginning/End of Phrase
     *      <T></T>  -  Text
     *      <V1/>    -  Variable (1 - 5)
     *      <field/> -  File field (i.e. <USER/>).
     *
     *
     *================================================================

     P fmtPhrase2      B
     D fmtPhrase2      PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
      /free

         if gPos < %size(gPhrase);

            select;

            when name = 'EMP';
              %subst(gPhrase:gPos) = %char(gEmp#);
              gPos += %len(%char(gEmp#));

            when name = 'ID';
              %subst(gPhrase:gPos) = %char(gPhraseId);
              gPos += %len(%char(gPhraseId));

            when name = 'ITEM';
              %subst(gPhrase:gPos) = %trimr(gItem);
              gPos += %len(%trimr(gItem));

            when name = 'LOC';
              %subst(gPhrase:gPos) = %trimr(gLocation);
              gPos += %len(%trimr(gLocation));

            when name = 'LCNS';
              %subst(gPhrase:gPos) = %trimr(gLcns);
              gPos += %len(%trimr(gLcns));

            when name = 'LTRN';
              %subst(gPhrase:gPos) = %char(gLtrn);
              gPos += %len(%char(gLtrn));

            when name = 'P';

            when name = 'PGM';
              %subst(gPhrase:gPos) = %trimr(gPgm);
              gPos += %len(%trimr(gPgm));

            when name = 'T';
              %subst(gPhrase:gPos) = value;
              gPos += %len(value);

            when name = 'TRN';
              %subst(gPhrase:gPos) = %char(gTrn#);
              gPos += %len(%char(gTrn#));

            when name = 'USER';
              %subst(gPhrase:gPos) = %trimr(gUser);
              gPos += %len(%trimr(gUser));

            when name = 'V1';
              %subst(gPhrase:gPos) = gVar(1);
              gPos += gVarSize(1);

            when name = 'V2';
              %subst(gPhrase:gPos) = gVar(2);
              gPos += gVarSize(2);

            when name = 'V3';
              %subst(gPhrase:gPos) = gVar(3);
              gPos += gVarSize(3);

            when name = 'V4';
              %subst(gPhrase:gPos) = gVar(4);
              gPos += gVarSize(4);

            when name = 'V5';
              %subst(gPhrase:gPos) = gVar(5);
              gPos += gVarSize(5);

            when name = 'WHDP';
              %subst(gPhrase:gPos) = %trimr(gWhdp);
              gPos += %len(%trimr(gWhdp));

            when name = 'WHSE';
              %subst(gPhrase:gPos) = %char(gWhse);
              gPos += %len(%char(gWhse));

            other;
              attrval = '<' + %trim(name) + '/>';
              %subst(gPhrase:gPos) = %trim(attrval);
              gPos += %len(%trim(attrval));

            endsl;

         endif;

      /end-free
     P                 E

     *================================================================
     * Procedure: fmtVars
     *================================================================
     *
     *   Usage:
     *
     *      callp   fmtVars(v1:v2:v3:v4:v5)
     *
     *   Return Value:
     *     varString  -  Formatted variable string
     *
     *   Parameters:
     *     v1         -  Variable 1 (optional)
     *     v2         -  Variable 2 (optional)
     *     v3         -  Variable 3 (optional)
     *     v4         -  Variable 4 (optional)
     *     v5         -  Variable 5 (optional)
     *
     *================================================================

     P fmtVars         b                   Export

     D fmtVars         pi           100
     D  v1                           30    const varying options(*nopass)
     D  v2                           30    const varying options(*nopass)
     D  v3                           30    const varying options(*nopass)
     D  v4                           30    const varying options(*nopass)
     D  v5                           30    const varying options(*nopass)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D varLen          s              2  0
     D varString       s            100

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

         varString = ' ';

         if %parms >= 1 and v1 <> ' ';
           varLen = %len(%trimr(v1));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v1;
         endif;

         if %parms >= 2 and v2 <> ' ';
           varLen = %len(%trimr(v2));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v2;
         endif;

         if %parms >= 3 and v3 <> ' ';
           varLen = %len(%trimr(v3));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v3;
         endif;

         if %parms >= 4 and v4 <> ' ';
           varLen = %len(%trimr(v4));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v4;
         endif;

         if %parms >= 5 and v5 <> ' ';
           varLen = %len(%trimr(v5));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v5;
         endif;

         return varString;

      /end-free
     P                 E
