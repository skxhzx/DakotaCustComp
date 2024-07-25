     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510.
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDCSP017  Coastal - Delete Stranded ORDHM records
     F*  Max Blacknik
     F*  09 May 2012
     F*
     F*----------------------------------------------------------------
     F*  Revisions
CSP AF*    05/09/12  MLB  CSP
     F*      - Created.
     F*
     Fordhm     up   e           k disk
     Frtehed    if   e           k disk
     Fordh      if   e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C
     C     hmkey1        setll     rtehed                                 50
     C                   if        *in50 = '0'
     C                   delete    hmrec
     C                   goto      delrec
     C                   endif
     *
     C     hmkey2        setll     ordh                                   50
     C                   if        *in50 = '0'
     C                   delete    hmrec
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
     C     hmkey1        klist
     C                   kfld                    kywhse
     C                   kfld                    hmrtid
     C     hmkey2        klist
     C                   kfld                    kywhse
     C                   kfld                    hmord
     C*
     C                   endsr
