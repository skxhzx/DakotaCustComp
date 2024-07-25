     F*----------------------------------------------------------------
     F*   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   P.O. Box 1957
     F*   Batavia, IL 60510.
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDJSL017  Silvert - Delete Stranded POHDRM records
     F*  Max Blacknik
     F*  29 July 2021
     F*
     F*----------------------------------------------------------------
     F*  Revisions
JSL AF*    07/29/21  MLB  JSL
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     Fpohdrm    up   e           k disk
     Fpohdr     if   e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C
     C     phmkey        setll     pohdr                                  50
     C                   if        *in50 = '0'
     C                   delete    phmrec
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
     C     phmkey        klist
     C                   kfld                    phmwh
     C                   kfld                    phmpo
     C*
     C                   endsr
