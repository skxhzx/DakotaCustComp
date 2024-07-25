     F*----------------------------------------------------------------
     F*   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   P.O. Box 1957
     F*   Batavia, IL 60510.
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDJSL018  Silvert - Delete Stranded PODTLM records
     F*  Max Blacknik
     F*  29 July 2021
     F*
     F*----------------------------------------------------------------
     F*  Revisions
JSL AF*    07/29/21  MLB  JSL
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     Fpodtlm    up   e           k disk
     Fpodtl     if   e           k disk
     Fpohdr     if   e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C
     *    P/O header not found.
     C     pdmkey        setll     pohdr                                  50
     C                   if        *in50 = '0'
     C                   delete    pdmrec
     C                   goto      delrec
     C                   endif
     *
     *    P/O detail not found.
     C     pdmkey2       setll     podtl                                  50
     C                   if        *in50 = '0'
     C                   delete    pdmrec
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
     C     pdmkey        klist
     C                   kfld                    pdmwhs
     C                   kfld                    pdmpo
     C*
     C
     C     pdmkey2       klist
     C                   kfld                    pdmwhs
     C                   kfld                    pdmpo
     C                   kfld                    pdmseq
     C                   kfld                    pdmitm
     C*
     C                   endsr
