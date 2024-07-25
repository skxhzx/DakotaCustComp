     F*----------------------------------------------------------------
     F*   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   (630)562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDMFRCD  Q&D to left justify Mfr code in PIRITEM and PODTL
     F*
     F*  03 Aug 2010
     F*  Retha Davis
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FPIRITEM   UF   E             DISK
     FPODTL     UF   E             DISK

     D*----------------------------------------------------------------
     D*  Variable/Constant definitions
     D*
     D Forever         S              1S 0

     C*----------------------------------------------------------------
     C* Main line
     C*
     C*  Loop through piritem recs
     C*
     C     Forever       doweq     Forever
     C                   read      piritem
     C                   if        %Eof
     C                   leave
     C                   endif
     C*
     C*     Skip if 1st pos of Mfr code is not blank.
     C*
     C                   if        %subst(itvit#:1:1) <> ' '
     C                   iter
     C                   endif
     C*
     C*     Left justify Mfr code
     C*
     C                   eval      $cstr = *blanks
     C                   move      itvit#        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         itvit#
     C*
     C*     Update piritem record
     C*
     C                   update    itrec
     C*
     C                   enddo
     C*
     C*  Loop through podtl recs
     C*
     C     Forever       doweq     Forever
     C                   read      podtl
     C                   if        %Eof
     C                   leave
     C                   endif
     C*
     C*     Skip if 1st pos of Mfr code is not blank.
     C*
     C                   if        %subst(pdvitm:1:1) <> ' '
     C                   iter
     C                   endif
     C*
     C*     Left justify Mfr code
     C*
     C                   eval      $cstr = *blanks
     C                   move      pdvitm        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         pdvitm
     C*
     C*     Update podtl record
     C*
     C                   update    pdrec
     C*
     C                   enddo
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
