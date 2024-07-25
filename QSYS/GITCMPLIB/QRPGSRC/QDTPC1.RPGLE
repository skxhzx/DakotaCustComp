      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTPC1    Set Odd/Even flog for Aisle 76
     *
     *----------------------------------------------------------------
     *  Jeffrey Jahnke
     *  24 February, 2017
     *
     *  Note: The 1st 2 position of location determins odd / evan
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/24/17  JCJ 7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot11    uf   e           k disk

     *----------------------------------------------------------------
     D                 ds
     D  slloc                  1      3  0
     D  slloc2                 1      2  0

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D kywhse          s                   like(slwhse)
     D kyaisl          s                   like(slaisl)
     D myremainder     s              1  0

     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      kywhse = 1
     C                   eval      kyaisl = ' 76'
     C     slkey11       setll     slot11
     C                   dou       %eof(slot11)
     C     slkey11       reade     slot11
     C                   if        not %eof(slot11)

     C                   if        slloc2 >= 03
     C                             and slloc2 <= 30

     C                   eval      myremainder=%rem(slloc2:2)
     C                   if        myremainder=0
     C                   eval      slside = 0
     C                   else
     C                   eval      slside = 1
     C                   endIf

     C                   update    slrec
     C                   endIf
     C                   endIf

     C                   enddo
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Slot key
     *
SVLiAC     slkey11       klist
SVLiAC                   kfld                    kywhse
SVLiAC                   kfld                    kyaisl
530 A*
     C                   endsr
