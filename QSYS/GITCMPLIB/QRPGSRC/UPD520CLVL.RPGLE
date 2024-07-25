     Hcopyright('(c) Copyright BFC Software, Inc - 2004')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     Htruncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)

      *----------------------------------------------------------------
      *
      *  UPD520CLVL Q&D to change zone DRYFEA from 0 combo labels to 10
      *  07 November 2009
      *  Ginger Andrews
      *
      *  Change OPCLVL from 0 to 10
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Files
      *----------------------------------------------------------------

     Foptionz   up   e           k disk

      *  OPTIONZ data structure
     *----------------------------------------------------------------
     *  *PICKLBL  -  Pick options
     *
     *----------------------------------------------------------------
     * Fields
     *
     * Data structure
     *
     D opzdta          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  opaisl                85     85
     D  optaxr                86     86
     D  opchkr                87     87
     D  opend2               117    117

      *----------------------------------------------------------------
      *  Main Line
      *----------------------------------------------------------------

     C                   if        opzcod = '*PICKLBL'
     C                             and opzzon = 'DRYFEA'
     C                   if        opclvl = 0
     C                   eval      opclvl = 10
     C                   endif
     C                   update    opzrec
     C                   endif
     CLR                 return
