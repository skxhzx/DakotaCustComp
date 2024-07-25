      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CALCPTI     Calculate PTI Value
     *  19 June 2013
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    06/19/13  LMC  6.50
     *      - Created - copied from ucilic#
     *
     *    09/16/13  DAS  6.50a
     *      - Added PTI calculation
     *      - Revised parmeters to be defined in D-specs
     *      - Revised Pack Date to be 6.0 instead of 8.0.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pGTIN          s             14a
     D $pLot           s             20a
     D $pPackDate      s              6p 0
     D $pPTI           s              4p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D crcTable        s             10i 0 dim(256)
     D glpString       s             40
     D packDateChr     s              6

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ASCIIint        pr            10i 0
     d  char                          1

     d ComputePTI      pr             4s 0
     d  chrString                    40

     d CrtCrcTable     pr

     d ShiftRight      pr            10i 0
     d  value                        10i 0
     d  places                        1p 0 const

     D ToHex           pr                  EXTPROC('cvthc')
     D  target                         *   value
     D  src_chars                      *   value
     D  source_len                   10I 0 value

     D Translate       pr                  ExtPgm('QDCXLATE')
     D   Length                       5P 0 const
     D   Data                     32766A   options(*varsize)
     D   Table                       10A   const

     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    $pGTIN     - GTIN number
     *    $pLot      - Mfr. Lot number
     *    $pPackDate - Pack date YYMMDD (optional - allowed to be zero)
     *
     *    Returned Parameters
     *    $pPTI  - 4 digit PTI value
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pGTIN
     C                   parm                    $pLot
     C                   parm                    $pPackDate
     C                   parm                    $pPTI

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

      /free

         glpString = $pGTIN + %trimr($pLot);

         if $pPackDate > 0;
           glpString = %trimr(glpString) + %editc($pPackDate:'X');
         endif;

         $pPTI = ComputePTI(glpString);

         return;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
      /free
       begsr *inzsr;
         CrtCrcTable();
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ASCIIint      Get ASCII integer value for character
     *----------------------------------------------------------------

     p ASCIIint        b
     d ASCIIint        pi            10i 0
     d  char                          1

     *  Local Variables

     D hex             s              2a
     D intValue        s             10i 0
     D hexTbl          s             16a   Inz('0123456789ABCDEF')
     D ix              s              3p 0

      /free

         // Convert character from EBCDIC to ASCII

         Translate(1: char: 'QTCPASC');

         // Convert ASCII character to Hex

         ToHex(%addr(hex): %addr(char): %size(hex));

         // Convert Hex character to integer

         intValue = 0;
         ix = %scan(%subst(hex:1:1) : hexTbl);
         intValue += (ix - 1) * 16;
         ix = %scan(%subst(hex:2:1) : hexTbl);
         intValue += ix - 1;

        return intValue;

      /end-free

     p ASCIIint        e

     *----------------------------------------------------------------
     *  ComputePTI    Compute PTI number
     *----------------------------------------------------------------

     p ComputePTI      b
     d ComputePTI      pi             4s 0
     d  chrString                    40

     *  Local Variables

     D char1           s              1
     D crc             s             10i 0
     D i               s              3p 0
     D index           s             10i 0
     D pti             s              4s 0
     D strLength       s              2s 0
     D tableLen        s              3p 0 inz(256)
     D value           s             10i 0

      /free

         // Compute CRC-16 checksum

         crc = 0;
         strLength = %len(%trimr(chrString));
         for i = 1 to strLength;
           char1 = %subst(chrString:i);
           index = (%bitand(%bitxor(crc:ASCIIint(char1)):x'FF')) + 1;
           crc = %bitand(%bitxor(ShiftRight(crc:8):crcTable(index)):x'FFFF');
         endfor;

         // Extract last 4 digits of crc to get PTI number

         pti = %rem(crc:10000);

         return pti;

      /end-free

     p ComputePTI      e

     *----------------------------------------------------------------
     *  crtCrcTable   Create Hex table for calculating CRC-16 Checksum
     *                using polynomial x16 + x15 + x2 +1
     *----------------------------------------------------------------

     p CrtCrcTable     b
     d CrtCrcTable     pi

     *  Local Variables

     D i               s              3p 0
     D j               s              3p 0
     D tableLen        s              3p 0 inz(256)
     D temp            s             10i 0
     D value           s             10i 0

     D* x16 + x15 + x2 + x1
     D polynomial      c                   const(x'A001')

      /free

         for i = 1 to tableLen;
           value = 0;
           temp = i - 1;
           for j = 1 to 8;
             if 0 <> (%bitand(%bitxor(value:temp):x'0001'));
               value = %bitand(%bitxor(ShiftRight(value:1):polynomial):x'FFFF');
             else;
               value = ShiftRight(value:1);
             endif;
             temp = ShiftRight(temp:1);
           endfor;
           crcTable(i) = value;
         endfor;

      /end-free

     p CrtCrcTable     e

     *----------------------------------------------------------------
     *  ShiftRight    Binary right shift
     *----------------------------------------------------------------

     p ShiftRight      b
     d ShiftRight      pi            10i 0
     d  value                        10i 0
     d  places                        1p 0 const

     *  Local Variables

     D curValue        s             10i 0
     D newValue        s             10i 0
     D i               s              1p 0

      /free

        if value = 0;
          return 0;
        endif;

        curValue = value;

        for i = 1 to places;
          newValue = %div(curValue:2);
          if (newValue < 0) and (%rem(curValue:2) <> 0);
            newValue += 1;
          endif;
          curValue = newValue;
        endfor;

        return newValue;

      /end-free

     p ShiftRight      e
