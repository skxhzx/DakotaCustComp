     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT756     Remove exported adjustment License records - Post
     *  14 April, 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    04/14/16  RTR   7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Variables
     *
     D $kdate          s               d
     D $kstamp         s               z
     D $ktime          s               t   inz(*loval)
     D $kwhse          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     *----------------------------------------------------------------
     * Main line
     *
      /free

        $kwhse = %dec($pwhse:3:0);
        $kdate = %date(%dec($pdate:8:0):*iso);
        $kstamp = %timestamp(%char($kdate) + '-' + %char($ktime) + '.000000');

        exec sql delete from licadj
                  where adjwhs = :$kwhse
                    and adjaddts < :$kstamp
                    and adjexpflag <> ' ';

        *inlr = *on;

      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   endsr
     *
