      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     * Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETFLDS   Split delimited string into fields
     *  30 December 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*    12/30/17  DAS  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Assumptions:
     *
     *   - Line feed ends a line.
     *   - Carriage return character will be ignored.
     *   - Alpha fields with an embedded comma must be surrounded
     *     by single quotes.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Comma Separated Tables
     *----------------------------------------------------------------

     d  StateTable     s              5    dim(16) ctdata  perrcd(4)

     *----------------------------------------------------------------
     *  Comma Separated Variables
     *----------------------------------------------------------------

     d Action          s              2
     d CurChar         s              3
     d EOL             c                   const('EOL')
     d FieldsExpected  s              3  0
     d FieldsReceived  s              3  0
     d FieldNbr        s              3  0
     d LineCount       s              5  0
     d LineLen         s              5  0
     d DblQuote        c                   const('"')
     d SglQuote        c                   const('''')
     d State           s              1  0
     d Tx              s              3  0
     d Value           s           1024A
     d Vx              s                   like(LineLen)
     d WorkChar        s              1

     d CurChar2        s              1
     d DecOut          s             30  9
     d Left            s             21
     d Right           s              9
     d Side            s              5
     d Sign            s              1  0
     d StrIn           s             32
     d X2              s              3  0

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     d pReturn         s             10
     d pMessage        s            200

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d PutField        pr

     d CSVDoAction     pr

     d CSVGetChar      pr

     d CSVGetState     pr

     d CSVGetTblNx     pr

     d CSVSplit        pr

     d CSVStoreVal     pr

     d CSVXlateNum     pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pString     Delimited string
     *      pDelimiter  Delimiter
     *      pStartFld   Starting field number
     *
     *    Returned Parameters
     *      pRtnCode    -  Return code
     *                     *OKMORE - Okay, more fields in string
     *                     *OKEND  - Okay, no more fields in string
     *                     *ERRFLDnnn - Error processing field nnn
     *      pFldsReturned - Number of fields returned
     *      pFldnn      -  Field nn
     *
     *----------------------------------------------------------------

     d GETFLDS         pr                  extpgm('GETFLDS')
     d  pString                   65535A   varying
     d  pDelimiter                    1A   const
     d  pStartFld                     3  0 const
     d  pRtnCode                     10
     d  pFldsReturned                 3  0
     d  pFld1                     65535A   varying
     d  pFld2                     65535A   varying
     d  pFld3                     65535A   varying
     d  pFld4                     65535A   varying
     d  pFld5                     65535A   varying
     d  pFld6                     65535A   varying
     d  pFld7                     65535A   varying
     d  pFld8                     65535A   varying
     d  pFld9                     65535A   varying
     d  pFld10                    65535A   varying
     d  pFld11                    65535A   varying
     d  pFld12                    65535A   varying
     d  pFld13                    65535A   varying
     d  pFld14                    65535A   varying
     d  pFld15                    65535A   varying
     d  pFld16                    65535A   varying
     d  pFld17                    65535A   varying
     d  pFld18                    65535A   varying
     d  pFld19                    65535A   varying
     d  pFld20                    65535A   varying

     d GETFLDS         pi
     d  pString                   65535A   varying
     d  pDelimiter                    1A   const
     d  pStartFld                     3  0 const
     d  pRtnCode                     10
     d  pFldsReturned                 3  0
     d  pFld1                     65535A   varying
     d  pFld2                     65535A   varying
     d  pFld3                     65535A   varying
     d  pFld4                     65535A   varying
     d  pFld5                     65535A   varying
     d  pFld6                     65535A   varying
     d  pFld7                     65535A   varying
     d  pFld8                     65535A   varying
     d  pFld9                     65535A   varying
     d  pFld10                    65535A   varying
     d  pFld11                    65535A   varying
     d  pFld12                    65535A   varying
     d  pFld13                    65535A   varying
     d  pFld14                    65535A   varying
     d  pFld15                    65535A   varying
     d  pFld16                    65535A   varying
     d  pFld17                    65535A   varying
     d  pFld18                    65535A   varying
     d  pFld19                    65535A   varying
     d  pFld20                    65535A   varying

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       // Initialize output fields

       FieldNbr = 0;
       putField();

       // Extract fields

       CSVSplit();

       // Write record

       FieldNbr = 999;
       putField();

       // Bye, Bye

       return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Subprocedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PutField    Put extracted value into record field.
     *
     *   This routine is used in the following ways base on the FieldNbr:
     *
     *     FieldNbr  Description
     *     --------  --------------------------------------------------
     *        0      Field initialization
     *      1 - 998  Move extracted field into data structure field.
     *       999     No more fields
     *
     *----------------------------------------------------------------

     p PutField        b
     d PutField        pi

     * Local Variables

     d fldNbr          s              3  0

      /FREE
       select;

         when FieldNbr = 0;
           pRtnCode = '*OKEND';
           pFldsReturned = 0;
           clear pFld1;
           clear pFld2;
           clear pFld3;
           clear pFld4;
           clear pFld5;
           clear pFld6;
           clear pFld7;
           clear pFld8;
           clear pFld9;
           clear pFld10;
           clear pFld11;
           clear pFld12;
           clear pFld13;
           clear pFld14;
           clear pFld15;
           clear pFld16;
           clear pFld17;
           clear pFld18;
           clear pFld19;
           clear pFld20;
           return;

         when FieldNbr = 999;
           return;

         when FieldNbr < pStartFld;
           return;

         other;
           FldNbr = FieldNbr - pStartFld + 1;
           if FldNbr > 20;
             pRtnCode = '*OKMORE';
             return;
           endif;
           pFldsReturned = FldNbr;

       endsl;

       select;

         when FldNbr = 1;
           pFld1 = Value;
         when FldNbr = 2;
           pFld2 = Value;
         when FldNbr = 3;
           pFld3 = Value;
         when FldNbr = 4;
           pFld4 = Value;
         when FldNbr = 5;
           pFld5 = Value;
         when FldNbr = 6;
           pFld6 = Value;
         when FldNbr = 7;
           pFld7 = Value;
         when FldNbr = 8;
           pFld8 = Value;
         when FldNbr = 9;
           pFld9 = Value;
         when FldNbr = 10;
           pFld10 = Value;
         when FldNbr = 11;
           pFld11 = Value;
         when FldNbr = 12;
           pFld12 = Value;
         when FldNbr = 13;
           pFld13 = Value;
         when FldNbr = 14;
           pFld14 = Value;
         when FldNbr = 15;
           pFld15 = Value;
         when FldNbr = 16;
           pFld16 = Value;
         when FldNbr = 17;
           pFld17 = Value;
         when FldNbr = 18;
           pFld18 = Value;
         when FldNbr = 19;
           pFld19 = Value;
         when FldNbr = 20;
           pFld20 = Value;
       endsl;

      /END-FREE
     p PutField        e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  CSV Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     C*  CSVDoAction  Perform action specified in the state table
     *----------------------------------------------------------------

     p CSVDoAction     b
     d CSVDoAction     pi

      /FREE
       Action = %subst(StateTable(Tx):1:2);

       select;
       when Action = 'SC';
         Vx = Vx + 1;
         %subst(Value:Vx:1) = %subst(CurChar:1:1);

       when Action = 'SV';
         CSVStoreVal();

       when Action = 'SQ';
         Vx = Vx + 1;
         %subst(Value:Vx:1) = '"';

       when Action = 'LQ';
         Value = '"' + Value;
         Vx = Vx + 1;
         CSVStoreVal();

       when Action = 'QC';
         Vx = Vx + 1;
         %subst(Value:Vx:2) = '"' + CurChar;

       endsl;

      /END-FREE
     p CSVDoAction     e

     *----------------------------------------------------------------
     C*  CSVGetChar  Get next character of current input record
     *----------------------------------------------------------------

     p CSVGetChar      b
     d CSVGetChar      pi

      /FREE
       x = x + 1;
       if x <= LineLen;
         CurChar = %subst(pString: x: 1);
       else;
         CurChar = EOL;
       endif;

      /END-FREE
     p CSVGetChar      e

     *----------------------------------------------------------------
     C*  CSVGetState   Set the current state from the state table
     *----------------------------------------------------------------

     p CSVGetState     b
     d CSVGetState     pi

      /FREE
       WorkChar = %subst(StateTable(Tx):4:1);
      /END-FREE
     C                   move      WorkChar      State

     p CSVGetState     e

     *----------------------------------------------------------------
     C*  CSVGetTblNx  Determine which element of the state table to use
     C*
     C*    Note: It is assumed that only one record is sent.
     C*          A record is supposed to end with LF. Therefore,
     C*          when we come across a LF we will
     C*          process the record and ignore anything that may be left
     C*          in the buffer. CR characters will be ignored.
     C*
     *----------------------------------------------------------------

     p CSVGetTblNx     b
     d CSVGetTblNx     pi

      /FREE
       select;
       when CurChar = SglQuote or CurChar = DblQuote;
         Tx = 1;
       when CurChar = EOL;
         Tx = 2;
       when CurChar = pDelimiter;
         Tx = 3;
       other;
         Tx = 4;
       endsl;

       Tx = (State - 1) * 4 + Tx;

      /END-FREE
     p CSVGetTblNx     e

     *----------------------------------------------------------------
      *  CSVSplit   Split CSV record into fields.
     *----------------------------------------------------------------

     p CSVSplit        b
     d CSVSplit        pi

      /FREE
       x = *zero;
       FieldNbr = *zero;
       State = 1;
       LineLen = %Len(%Trim(pString));
       If %subst(pString:LineLen:1) = pDelimiter;
         pString += ' ';
         LineLen = LineLen + 1;
       endif;

       dou state = 0;
         CSVGetChar();
         CSVGetTblNx();
         CSVDoAction();
         if error or pRtnCode = '*OKMORE';
           leave;
         endif;
         CSVGetState();
       enddo;

      /END-FREE
     p CSVSplit        e

     *----------------------------------------------------------------
     C*  CSVStoreVal  Put the extracted value into the next field
     *----------------------------------------------------------------

     p CSVStoreVal     b
     d CSVStoreVal     pi

      /FREE
       FieldNbr = FieldNbr + 1;
       PutField();
       Vx = 0;
       Value = *blanks;

      /END-FREE
     p CSVStoreVal     e

     *----------------------------------------------------------------
     C*  CSVXlateNum   Translate value into number
     *----------------------------------------------------------------

     p CSVXlateNum     b
     d CSVXlateNum     pi

      /FREE
       StrIn = Value;

       // set inital values
       left = *all'0';
       right = *blanks;
       Side = 'left';
       Sign = 1;

       // extract parts of number to left & right of decimal point
      /END-FREE
     C     1             do        32            x2
      /FREE
         CurChar2 = %subst(StrIn:x2:1);
         select;
         when CurChar2 >= '0' and CurChar2 <= '9';
           if Side = 'left';
             Left = %subst(Left:2:20) + CurChar2;
           else;
             Right = %trimr(Right) + CurChar2;
           endif;
         when CurChar2 = '.';
           Side = 'right';
         when CurChar2 = '-' or CurChar2 = '<';
           Sign = -1;
         endsl;
       enddo;

       // combine the left & right strings to get the entire number
      /END-FREE
     C                   movel     Left          DecOut
      /FREE
       Right = %trimr(Right) + '000000000';
      /END-FREE
     C                   move      Right         DecOut
     C
      // if a hyphen or less-than was found, negate the number
      /FREE
       if Sign = -1;
         DecOut = (- DecOut);
       endif;

      /END-FREE
     p CSVXlateNum     e


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
     *----------------------------------------------------------------

**   ** ctdata StateTable
  :2   :0 SV:1 SC:4           quote, eol, comma, other
  :3 LQ:0 SC:2 SC:2
SQ:2 SV:0 SV:1 QC:2
SC:4 SV:0 SV:1 SC:4
