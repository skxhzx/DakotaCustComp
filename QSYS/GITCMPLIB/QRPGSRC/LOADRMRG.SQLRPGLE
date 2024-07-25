     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     Hoption(*srcstmt : *nodebugio)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/CO) SRCFILE(XXX/QRPGSRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               DLYPRP = *YES
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LOADRMRG    Merge Pallet file (Ldrpltq) cleanup.
     *  Jose Duque
     *  September 27, 2007
     *
     *  NOTE: This is a copy of 'Socketcbi/Sktlogclnr'.
     *
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D $pmonths2keep   s              3  0
     D oldest          s              8  0
416aAD hoursdate       s              8  0
     D today           s              8  0

     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $PCmd           s              8

     D $PDateIn        s              8  0
     D $PTimeIn        s              6  0

     D $PYears         s              3  0
     D $PMonths        s              3  0
     D $PDays          s              3  0
     D $PHours         s              3  0
     D $PMinutes       s              3  0
     D $PSeconds       s              3  0

     D $PDateOut       s              8  0
     D $PTimeOut       s              6  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pmonths2keep  Number of months to keep
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pmonths2keep

     *----------------------------------------------------------------
     *  Delete records
     *----------------------------------------------------------------

     C/EXEC SQL
     C+  delete
     C+  from   ldrpltq
     C+  where  (lpstrd < :oldest)
     C/END-EXEC

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     *  Get current date.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o

     *  Compute oldest date to keep for "months"

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $pcmd
     C                   parm      today         $pdatein
     C                   parm      0             $ptimein
     C                   parm      0             $pyears
     C                   parm      $pmonths2keep $pmonths
     C                   parm      0             $pdays
     C                   parm      0             $phours
     C                   parm      0             $pminutes
     C                   parm      0             $pseconds
     C     oldest        parm      0             $pdateout
     C                   parm      0             $ptimeout

     C                   endsr
