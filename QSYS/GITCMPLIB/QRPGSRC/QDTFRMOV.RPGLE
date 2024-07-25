      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTFRMOV   Used for changing lbstat to C on old labels when the
     *             transaction is closed. So the records will purge with
     *             normal cleanup programs.
     *  27 March 2013
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    03/27/13  LMC  6.50a
     *      - Created.
     *
     *----------------------------------------------------------------
     *
     Fpirtran8  if   e           k disk
     Flabel90   uf   e           k disk
     *

      /copy qcopysrc,p.cvtdte

     d ymd             s              6  0
     d clnwhse         s              3  0
     d clndate         s              8  0
     D forever         s              1
     d pirtran8cnt     s              9  0
     d Label90cnt      s              9  0
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76


     c     *entry        plist
     c                   parm                    $pwhse            3
     c                   parm                    $pupdate          1

     c                   call      'CMPDTE'
     C                   parm      '*MISC'       $pcmd             8
     C                   parm      'QDTFRMOV'    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8


      /free
        $cvcmd = '*CMDYMD ';
        $cvd8i = $pdate;
        cvtdte ($cvtdt);
        clndate = %int($pdate);
        clnwhse = %int($pwhse);

        // get tfrmov transactions
        setll (clnwhse) pirtran8;
        dow forever = forever;
          reade (clnwhse) pirtran8;
          if  %eof(pirtran8);
            leave;
          endif;

          if ptgdte > clndate;
            leave;
          endif;

          if pttask <> 'TFRMOV';
            iter;
          endif;

          if ptstat <> '4';
            iter;
          endif;

          pirtran8cnt = pirtran8cnt + 1;
          // ok now I have the records I want
          setll (clnwhse:pttrn#) label90;
          dow forever = forever;
            if $pupdate = 'Y';
              reade (clnwhse:pttrn#) label90;
            else;
              reade(n) (clnwhse:pttrn#) label90;
            endif;
            if %eof(label90);
              leave;
            endif;

            if lbtype <> 'T';
              iter;
            endif;

            if lbrdte > clndate;
              iter;
            endif;

            if lbstat = 'C';
              iter;
            endif;

            // now I have a label record that needs to be changed to Stat C
            lbstat = 'C';
            label90cnt = label90cnt + 1;
            if $pupdate = 'Y';
              update lbrec;
            endif;

          enddo;
        enddo;
        *inlr = *on;
      /end-free
