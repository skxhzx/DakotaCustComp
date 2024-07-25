     F*----------------------------------------------------------------
     F*   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   P.O. Box 1957
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDSGC015  Restore Designation Codes from Before Journal Image
     F*  10 April 2014
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
SGC AF*    04/10/14  MLB  SGC
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FJRNITEMUB IF   E             DISK    prefix(ub_)
     FPIRITEM   UF   E           K DISK
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      $PWHSE        KYWHSE            3 0
     C                   MOVE      *ON           FOREVR            1
     C*
     C     ITKEY         KLIST
     C                   KFLD                    UB_ITWHSE
     C                   KFLD                    UB_ITITEM
     C*
     C*
     C     FOREVR        DOWEQ     FOREVR
     C                   READ      JRNITEMUB
     C                   SELECT
     C                   when      %eof(jrnitemub)
     C                   LEAVE
     C                   when      ub_itdesg > ' '
     C*
     C     ITKEY         CHAIN     piritem
     C                   if        %found(piritem)
     C                             and  (UB_itdesg = 'BEEF'
     c                                OR UB_ITDESG = 'CHICK'
     c                                OR UB_ITDESG = 'EGGS'
     c                                OR UB_ITDESG = 'ICR'
     c                                OR UB_ITDESG = 'MILK'
     c                                OR UB_ITDESG = 'PORK')
     C                             and  itdesg = ' '
     C                   eval      itdesg = ub_itdesg
     C                   update    itrec
     C                   endif
     C*
     C                   ENDSL
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   MOVE      *ON           *INLR
     C                   RETURN
