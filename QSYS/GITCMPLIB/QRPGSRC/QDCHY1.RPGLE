     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  QDCHY1      Q&D for Cheney Bros to put hypens in slot display
     F*  02 June 2000
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program changes a Cheney Bros slot display field
     F*    from 1003010 to 10-030-10.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FSLOT      UF   E             DISK

     D*----------------------------------------------------------------
     D*  Variable/Constant definitions
     D*
     D Forever         S              1S 0
     D HyphenPos       S              3P 0

     C*----------------------------------------------------------------
     C* Main line
     C*
     C*  Loop through slot records
     C*
     C     Forever       doweq     Forever
     C                   read      Slot
     C                   if        %Eof
     C                   leave
     C                   endif
     C*
     C*     Skip if slot display already contains a hyphen.
     C*
     C                   eval      HyphenPos = %Scan('-':SLDisp)
     C                   if        HyphenPos > 0
     C                   iter
     C                   endif
     C*
     C*     Add hypens
     C*
     C                   eval      SLDisp = %Subst(SLDisp:1:2) + '-' +
     C                                      %Subst(SLDisp:3:3) + '-' +
     C                                      %Subst(SLDisp:6:2)
     C*
     C*     Update slot record
     C*
     C                   update    SLREC
     C*
     C                   enddo
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
