     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510.
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDCSP018  Coastal - Delete Stranded RTESTP records
     F*  Max Blacknik
     F*  09 May 2012
     F*
     F*----------------------------------------------------------------
     F*  Revisions
CSP AF*    05/09/12  MLB  CSP
     F*      - Created.
     F*
650 AF*    06/21/13  RBD  650
     F*      - Recompiled only, RTESTP changed.
     F*
     FRTESTP    up   e           k disk
     Frtehed    if   e           k disk
     Fordh      if   e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C
     C     rtskey1       setll     rtehed                                 50
     C                   if        *in50 = '0'
     C                   delete    rtsrec
     C                   goto      delrec
     C                   endif
     *
     C     rtskey2       setll     ordh                                   50
     C                   if        *in50 = '0'
     C                   delete    rtsrec
     C                   goto      delrec
     C                   endif
     *
     C     delrec        tag
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
     C                   move      '001'         kywhse            3 0
     C
     C     rtskey1       klist
     C                   kfld                    kywhse
     C                   kfld                    rtsrid
     C     rtskey2       klist
     C                   kfld                    kywhse
     C                   kfld                    rtsord
     C*
     C                   endsr
