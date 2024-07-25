     F*----------------------------------------------------------------
     F*   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   P.O. Box 1957
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDDRY002  Delete Stranded Rcds from RTEINUSE.
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FRTEINUSE  UP   E           K DISK
     FRTEHED    IF   E           K DISK
     I*----------------------------------------------------------------
     I*
     I*
     I*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C     riukey        KLIST
     C                   KFLD                    riuwhse
     C                   KFLD                    riurtid
     C*
     C     riukey        setll     rtehed
     C                   if        not %equal(rtehed)
     C                   delete    riurec
     C                   else
     C                   unlock    rteinuse
     C                   endif
