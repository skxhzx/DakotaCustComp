     Hcopyright('(c) Copyright BFC Software, Inc - 2004')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     Htruncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)

      *----------------------------------------------------------------
      *
      *  QDCBIZONE9  Q&D to set combo to 15
      *  29 April 2004
      *  Dave Sommerville
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Files
      *----------------------------------------------------------------

     Foptionz   up   e           k disk

     D*----------------------------------------------------------------
     D*  OPTIONZ data structure
     D*  *PICKLBL  -  Picking label options
     I*    OPCLVL  -  Qty level for combined labels.
     D*
     D OPZDTA          DS
     D  OPCLVL                 1      3  0
     D  OPZEND               117    117

      *----------------------------------------------------------------
      *  Main Line
      *----------------------------------------------------------------

     C                   if        opzcod = '*PICKLBL'
     C                   eval      opclvl = 999
     C                   update(e) opzrec
     C                   if        %error
     C                   endif
     C                   endif
