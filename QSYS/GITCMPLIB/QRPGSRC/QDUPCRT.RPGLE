     F*----------------------------------------------------------------
     F*   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   P.O. Box 1957
     F*   Batavia, IL , 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDUPCRT
     F*  05 April 2013
     F*  MLB
     F*
     F*  Update UPC file and fully right justify UPC code.
     F*
700aAF*    11/23/16  LMC  7.00a
     F*      - UPC file has a database change. Recompile only.
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FUPC       UP   E           K DISK
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
     C*----------------------------------------------------------------
     C* Main line
     C*
     C*
     C                   move      *blanks       wkupc            20
     C                   evalr     wkupc = %trimr(upupc)
     C                   eval      upupc = wkupc
     C                   UPDATE    UPREC
     C*
     C*
