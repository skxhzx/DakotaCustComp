     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  DQQD01    Q&D to recalc difference flag.
     F*  06 July 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    07/06/01  DAS  4.15
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FDlyQty    UP   E           K DISK
     FPirItem   IF   E           K DISK

      *------------------------------------------------------------------
      * Misc defs ...
      *------------------------------------------------------------------
415aAD AlcD2           s              9  0
415aAD AlcD3           s              9  0
415aAD StkD2           s              9  0
415aAD StkD3           s              9  0
415aAD UMQty2          s                   Like(ITUMQ2)
415aAD UMQty3          s                   Like(ITUMQ3)

     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line

     C*  Get item record.

     C     KeyIt         Chain     PirItem                            79
     C     *IN79         CabEQ     *On           Bottom

     C*  Get unit of measure quantities.

     C                   If        ITUMQ2 > 0
     C                   Eval      UmQty2 = ITUMQ2
     C                   Else
     C                   Eval      UmQty2 = 1
     C                   EndIf

     C                   If        ITUMQ3 > 0
     C                   Eval      UmQty3 = ITUMQ3
     C                   Else
     C                   Eval      UmQty3 = 1
     C                   EndIf

     C*  Convert quantities to lowest breakdown 2 quantities.

     C                   Eval      StkD2 = (D2Stk1 * UmQty2 * UmQty3) +
     C                                     (D2Stk2 * UmQty3) +
     C                                      D2Stk3

     C                   Eval      AlcD2 = (D2Alc1 * UmQty2 * UmQty3) +
     C                                     (D2Alc2 * UmQty3) +
     C                                      D2Alc3

     C                   Eval      StkD3 = (D3Stk1 * UmQty2 * UmQty3) +
     C                                     (D3Stk2 * UmQty3) +
     C                                      D3Stk3

     C                   Eval      AlcD3 = (D3Alc1 * UmQty2 * UmQty3) +
     C                                     (D3Alc2 * UmQty3) +
     C                                      D3Alc3

     C*  Now compare quantities to see if there is a difference.

     C                   If        StkD2 <> StkD3 or AlcD2 <> AlcD3
     C                   Eval      DqDFlg = 1
     C                   Else
     C                   Eval      DqDFlg = 0
     C                   EndIf

     C                   Update    DqRec

     C     Bottom        Tag

     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR

     C*  Define item key for PirItem file.

     C     KeyIt         KList
     C                   Kfld                    DQWhse
     C                   Kfld                    DQItem

     C                   ENDSR
