     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSWT001  Q&D SWT Correct customer order number in ORDHEXA
     *  24 April 2019
     *  Max Blacknik / Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
SWT A*    04/24/19  MLB  SWT
     *      - Created.  Uses IMPFORDH9 file to correct ORDHEXA.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordh2     if   e           k disk
     Fordhexa   uf   e           k disk
     Fimpfordh9 if   e           k disk

     D $pwhse          s                   like(ohwhse) inz(0)
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $prte             5
     C                   parm                    $prtid            5
     C                   parm                    $prtetype         1
     C                   parm                    $pstatus          1

     C     ohkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pstatus
     C                   kfld                    $prtetype
     C                   kfld                    $prtid

     C     oh9key        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte

     C     hexakey       klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C
     C                   move      $pwhs         $pwhse
     C                   move      '1'           forever           1
     C     ohkey         setll     ordh2
     C     oh9key        setll     impfordh9
     C                   dow       forever = forever
     C     ohkey         reade     ordh2
     C                   if        %eof(ordh2)
     C                   leave
     C                   endif
     C
     C     oh9key        reade     impfordh9
     C                   if        %eof(impfordh9)
     C                   eval      oihord = ' '
     C                   endif
     C
     C     hexakey       chain     ordhexa
     C                   if        %found(ordhexa)
     C                   if        oihord > ' '
     C                   eval      ohaorda = %trim(%subst(oihord:1:15))
     C                   update    oharec
     C                   endif
     C                   endif
     C*
     C                   enddo
     C
     C                   eval      *inlr = '1'
