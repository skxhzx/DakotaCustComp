     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  DQ109     Delete old daily total entries.
     F*  Dave Sommerville
     F*  18 July 2001
     F*
     F*  Revisions
     F*
415 AF*    07/18/01  DAS  4.15
     F*      - Created.
     F*
     F*----------------------------------------------------------------

      *------------------------------------------------------------------
      * Misc defs ...
      *------------------------------------------------------------------

415aAD Day             s              1  0
415aAD Oldest          s              8  0
415aAD Today           s              8  0

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------

     D @CVTDT          C                   CONST('CVTDTE')
     D @CLCDR          C                   CONST('CLCDUR')

      *----------------------------------------------------------------
      *  Called program parameters
      *----------------------------------------------------------------

     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D  $CVDR1               133    140
     D  $CVVL1               141    145  0
     D  $CVDR2               146    153
     D  $CVVL2               154    158  0
     D  $CVDR3               159    166
     D  $CVVL3               167    171  0
     D  $CVDR4               172    179
     D  $CVVL4               180    184  0

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*
     C*  Delete records

     C/EXEC SQL
     C+  DELETE
     C+  FROM   DLYQTY
     C+  WHERE  (DQRDTE < :Oldest)
     C/END-EXEC

     C/EXEC SQL
     C+  DELETE
     C+  FROM   DLYQTYO
     C+  WHERE  (DORDTE < :Oldest)
     C/END-EXEC

     C/EXEC SQL
     C+  DELETE
     C+  FROM   DLYQTYT
     C+  WHERE  (DTRDTE < :Oldest)
     C/END-EXEC

     C                   Eval      *INLR = *ON
     C                   Return
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR

     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o

     C*  Convert current date to day number.

     C                   Eval      $Cvcmd = '*CMDNBR '
     C                   Move      Today         $Cvd8i
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Day = $Cvd6o

     C*  Compute oldest date to keep (keeping 5 days)

     C                   Eval      $Cvcmd = '*CMDCMD '
     C                   Move      Today         $Cvd8i
     C                   Eval      $Cvdr1 = '*SUBDAYS'
     C                   Eval      $Cvvl1 = 5
     C                   Call      @Clcdr
     C                   Parm                    $Cvtdt
     C                   Eval      Oldest = $Cvd8o

     C                   ENDSR
