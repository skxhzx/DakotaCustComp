     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510.
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDMULTRAN - Delete Stranded MULTRAN records
     F*  Lynn McMahon
     F*  09 October 2012
     F*
     F*----------------------------------------------------------------
     F*  Revisions
640 AF*    10/09/12  LMC  640
     F*      - Created.
     F*
     Fmultran   up   e           k disk
     Flabel90   if   e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C
     C     mukey1        chain     label90
     c                   if        not %found(label90)
     C                   delete    murec
     C                   endif
     *
     C*
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C
     C     mukey1        klist
     C                   kfld                    muwhse
     C                   kfld                    mutrn#
     C*
     C                   endsr
