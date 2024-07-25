500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  LH710   Delete inactive LICHIST records older than 6 mnths
     *  30 March 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD keepDateTS      s               z

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   time                    keepDateTS
     C                   eval      keepDateTS = keepDateTS - %months(6)

     *  Delete matrix records

     C/EXEC SQL
     C+  DELETE
     C+  FROM   LICHIST
     C+  WHERE  LRSTAT = 'I' and LRADDTS < :keepDateTS
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   Eval      *inlr = *ON
     C                   return
