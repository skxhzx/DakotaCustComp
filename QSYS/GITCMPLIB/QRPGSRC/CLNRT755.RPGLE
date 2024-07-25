510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNRT755   Clean up ORPHANS for RT755
     *  18 December 2012
     *  Lynn McMahon
     *       Notes: This program is used if the client has new LICINFO.

     *              You should compile this on the client box,
     *              Removing any files not used presently at client.
     *              This program includes all possible files based on our
     *              current RT755 program.
     *
     *              Make sure to take the object for file CLNOLDPF1 to the
     *              clients box. No source exists for this file.
     *              CLNOLDPF1 is a log file that records the results.
     *
     *              The program can be run in edit mode/no deletes
     *              Edit Mode = Send a ' ' in parm $pupdate.
     *              Update Mode = Send a 'Y' in parm $pupdate
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    12/18/12  LMC  6.50a
     *      - Created.
     *
650bA*    06/13/13  RBD  6.50b
     *      - Recompiled, RTESTP changed.
     *
650cA*    08/26/13  RBD  6.50c
     *      - Recompiled, TTLOG file changed.
     *
650dA*    01/20/15  RBD  6.50d
     *      - Recompiled, LDRHDETL file changed.
     *
     *----------------------------------------------------------------
     *
     *
     Frtehed    if   e           k disk
     Frtehed1   if   e           k disk    rename(rhrec:rh)
     Flabel     if   e           k disk    rename(lbrec:lb)
     Flabel90   if   e           k disk    rename(lbrec:lb90)
     Fordh      if   e           k disk    rename(ohrec:oh)
     Frtesum    uf   e           k disk
     Frtecsum   uf   e           k disk
     Frtenote   uf   e           k disk
     Frtestp    uf   e           k disk
     Fpltsum1   uf   e           k disk
     Fpltstp1   uf   e           k disk
     Fpltmisc   uf   e           k disk
     Fbatctl2   uf   e           k disk
     Fworkzon1  uf   e           k disk
     Fworklbl7  uf   e           k disk
     FLabel13   uf   e           k disk
     FLabelps   uf   e           k disk
     Fpirtran5  uf   e           k disk
     Fordad     uf   e           k disk
     Fordh3     uf   e           k disk
     Fordhm2    uf   e           k disk
     Fordd      uf   e           k disk
     Fordds     uf   e           k disk
     F                                     rename(osrec:ossrec)
     Forddm     uf   e           k disk
     Fordbox    uf   e           k disk
     Fordbsum1  uf   e           k disk
     Fordexpdte uf   e           k disk
     Fordc      uf   e           k disk
     Fordlbl1   uf   e           k disk
     Fordt      uf   e           k disk
     Fordslct3  uf   e           k disk
     Fpirseq1   uf   e           k disk
     Fmultran1  uf   e           k disk
     Frunner6   uf   e           k disk
     Fbulkdrp1  uf   e           k disk
     Fprexref3  uf   e           k disk
     Ftxftplog  uf   e           k disk
     Fordp      uf   e           k disk
     Ftotebund2 uf   e           k disk
     Ftotehdr   uf   e           k disk
     Fttitm     uf   e           k disk
     Fttlog     uf   e           k disk
     Fttmerg    uf   e           k disk
     Fttrte     uf   e           k disk
     Fttrtn3    uf   e           k disk
     Fttstp     uf   e           k disk
     Fttstpflg  uf   e           k disk
     Ftttrx     uf   e           k disk
     Fldrhhdr   uf   e           k disk
     Fldrhdetl  uf   e           k disk
     *
     fclnoldpf1 o  a e             disk    rename(clnoldpf:cln)

      /copy qcopysrc,p.cvtdte

     d ymd             s              6  0
     d blankroute      s              5
     d clnwhse         s              3  0
     d clndate         s              8  0
     D forever         s              1
     d rtesumcnt       s              9  0
     d rtecsumcnt      s              9  0
     d rtenotecnt      s              9  0
     d rtestpcnt       s              9  0
     d pltsum1cnt      s              9  0
     d pltstp1cnt      s              9  0
     d pltmisccnt      s              9  0
     d batctl2cnt      s              9  0
     d workzon1cnt     s              9  0
     d worklbl7cnt     s              9  0
     d Label13cnt      s              9  0
     d Labelpscnt      s              9  0
     d pirtran5cnt     s              9  0
     d ordadcnt        s              9  0
     d ordh3cnt        s              9  0
     d ordhm2cnt       s              9  0
     d orddcnt         s              9  0
     d orddscnt        s              9  0
     d orddmcnt        s              9  0
     d ordboxcnt       s              9  0
     d ordbsum1cnt     s              9  0
     d ordexpdtecnt    s              9  0
     d ordccnt         s              9  0
     d ordlbl1cnt      s              9  0
     d ordtcnt         s              9  0
     d ordslct3cnt     s              9  0
     d pirseq1cnt      s              9  0
     d multran1cnt     s              9  0
     d runner6cnt      s              9  0
     d bulkdrp1cnt     s              9  0
     d prexref3cnt     s              9  0
     d txftplogcnt     s              9  0
     d ordpcnt         s              9  0
     d totebund2cnt    s              9  0
     d totehdrcnt      s              9  0
     d ttitmcnt        s              9  0
     d ttlogcnt        s              9  0
     d ttmergcnt       s              9  0
     d ttrtecnt        s              9  0
     d ttrtn3cnt       s              9  0
     d ttstpcnt        s              9  0
     d ttstpflgcnt     s              9  0
     d tttrxcnt        s              9  0
     d ldrhhdrcnt      s              9  0
     d ldrhdetlcnt     s              9  0
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
     C                   parm      '*ROUTE'      $pcmd             8
     C                   parm      'CLNPT785'    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8


      /free
        $cvcmd = '*CMDYMD ';
        $cvd8i = $pdate;
        cvtdte ($cvtdt);
        clndate = %int($pdate);
        clnwhse = %int($pwhse);

        // rtesum
        setgt (clnwhse: blankroute) rtesum;
        dow forever = forever;
          reade (clnwhse) rtesum;
          if %eof(rtesum);
            leave;
          endif;
          chain (rswhse: rsrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: rsrtid) rtesum;
            iter;
          endif;
          if $pupdate = 'Y';
            delete rsrec;
          endif;
          rtesumcnt = rtesumcnt + 1;
        enddo;

        // rtecsum
        setgt (clnwhse: blankroute) rtecsum;
        dow forever = forever;
          reade (clnwhse) rtecsum;
          if %eof(rtecsum);
            leave;
          endif;
          chain (rcwhse: rcrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: rcrtid) rtecsum;
            iter;
          endif;
          if $pupdate = 'Y';
            delete rcrec;
          endif;
          rtecsumcnt = rtecsumcnt + 1;
        enddo;

        // rtenote
        setgt (clnwhse: blankroute) rtenote;
        dow forever = forever;
          reade (clnwhse) rtenote;
          if %eof(rtenote);
            leave;
          endif;
          chain (rnwhse: rnrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: rnrtid) rtenote;
            iter;
          endif;
          if $pupdate = 'Y';
            delete rnrec;
          endif;
          rtenotecnt = rtenotecnt + 1;
        enddo;

        // rtestp
        setgt (clnwhse: blankroute) rtestp;
        dow forever = forever;
          reade (clnwhse) rtestp;
          if %eof(rtestp);
            leave;
          endif;
          chain (rtswhs: rtsrid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: rtsrid) rtestp;
            iter;
          endif;
          if $pupdate = 'Y';
            delete rtsrec;
          endif;
          rtestpcnt = rtestpcnt + 1;
        enddo;

        // pltsum1
        setgt (clnwhse: blankroute) pltsum1;
        dow forever = forever;
          reade (clnwhse) pltsum1;
          if %eof(pltsum1);
            leave;
          endif;
          chain (pswhse: psrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: psrtid) pltsum1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete psrec;
          endif;
          pltsum1cnt = pltsum1cnt + 1;
        enddo;

        // pltstp1
        setgt (clnwhse: blankroute) pltstp1;
        dow forever = forever;
          reade (clnwhse) pltstp1;
          if %eof(pltstp1);
            leave;
          endif;
          chain (psswhs: pssrid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: pssrid) pltstp1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete pssrec;
          endif;
          pltstp1cnt = pltstp1cnt + 1;
        enddo;

        // pltmisc
        setgt (clnwhse: blankroute) pltmisc;
        dow forever = forever;
          reade (clnwhse) pltmisc;
          if %eof(pltmisc);
            leave;
          endif;
          chain (pmwhse: pmrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: pmrtid) pltmisc;
            iter;
          endif;
          if $pupdate = 'Y';
            delete pmrec;
          endif;
          pltmisccnt = pltmisccnt + 1;
        enddo;

        // batctl2
        setgt (clnwhse: blankroute) batctl2;
        dow forever = forever;
          reade (clnwhse) batctl2;
          if %eof(batctl2);
            leave;
          endif;
          if btrte = ' ';
            iter;
          endif;
          if btstrd > clndate;
            iter;
          endif;
          chain (btwhse: btrte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: btrte) batctl2;
            iter;
          endif;
          if $pupdate = 'Y';
            delete btrec;
          endif;
          batctl2cnt = batctl2cnt + 1;
        enddo;

        // workzon1
        setgt (clnwhse: blankroute) workzon1;
        dow forever = forever;
          reade (clnwhse) workzon1;
          if %eof(workzon1);
            leave;
          endif;
          chain (zwwhse: zwrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: zwrtid) workzon1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete zwrec;
          endif;
          workzon1cnt = workzon1cnt + 1;
        enddo;

        // worklbl7
        setgt (clnwhse: blankroute) worklbl7;
        dow forever = forever;
          reade (clnwhse) worklbl7;
          if %eof(worklbl7);
            leave;
          endif;
          chain (lwwhse: lwrte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: lwrte) worklbl7;
            iter;
          endif;
          if $pupdate = 'Y';
            delete lwrec;
          endif;
          worklbl7cnt = worklbl7cnt + 1;
        enddo;

        // label13
        setgt (clnwhse: blankroute) label13;
        dow forever = forever;
          reade (clnwhse) label13;
          if %eof(label13);
            leave;
          endif;
          if lbrte = ' ';
            iter;
          endif;
          if lbrdte > clndate;
            iter;
          endif;
          if lbgrp1 <> 'S';
            iter;
          endif;
          chain (lbwhse: lbrte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: lbrte) label13;
            iter;
          endif;
          if $pupdate = 'Y';
            delete lbrec;
          endif;
          label13cnt = label13cnt + 1;
        enddo;

        // ordh3
        setgt (clnwhse: blankroute) ordh3;
        dow forever = forever;
          reade (clnwhse) ordh3;
          if %eof(ordh3);
            leave;
          endif;
          chain (ohwhse: ohrte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ohrte) ordh3;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ohrec;
          endif;
          ordh3cnt = ordh3cnt + 1;
        enddo;

        // ordhm2
        setgt (clnwhse: blankroute) ordhm2;
        dow forever = forever;
          reade (clnwhse) ordhm2;
          if %eof(ordhm2);
            leave;
          endif;
          chain (hmwhse: hmrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: hmrtid) ordhm2;
            iter;
          endif;
          if $pupdate = 'Y';
            delete hmrec;
          endif;
          ordhm2cnt = ordhm2cnt + 1;
        enddo;

        // ordbsum1
        setgt (clnwhse: blankroute) ordbsum1;
        dow forever = forever;
          reade (clnwhse) ordbsum1;
          if %eof(ordbsum1);
            leave;
          endif;
          chain (bpwhse: bprte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: bprte) ordbsum1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete bprec;
          endif;
          ordbsum1cnt = ordbsum1cnt + 1;
        enddo;

        // ordlbl1
        setgt (clnwhse: blankroute) ordlbl1;
        dow forever = forever;
          reade (clnwhse) ordlbl1;
          if %eof(ordlbl1);
            leave;
          endif;
          chain (alwhse: alrte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: alrte) ordlbl1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete alrec;
          endif;
          ordlbl1cnt = ordlbl1cnt + 1;
        enddo;

        // pirseq1
        setgt (clnwhse: blankroute) pirseq1;
        dow forever = forever;
          reade (clnwhse) pirseq1;
          if %eof(pirseq1);
            leave;
          endif;
          chain (psqwhs: psqrid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: psqrid) pirseq1;
            iter;
          endif;
          if $pupdate = 'Y';
            delete psqrec;
          endif;
          pirseq1cnt = pirseq1cnt + 1;
        enddo;

        // prexref3
        setgt (clnwhse: blankroute) prexref3;
        dow forever = forever;
          reade (clnwhse) prexref3;
          if %eof(prexref3);
            leave;
          endif;
          chain (pxwhse: pxprte) rtehed;
          if %found(rtehed);
            setgt (clnwhse: pxprte) prexref3;
            iter;
          endif;
          if $pupdate = 'Y';
            delete pxrec;
          endif;
          prexref3cnt = prexref3cnt + 1;
        enddo;

        // txftplog
        setgt (clnwhse: blankroute) txftplog;
        dow forever = forever;
          reade (clnwhse) txftplog;
          if %eof(txftplog);
            leave;
          endif;
          chain (pfwhse: pfrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: pfrtid) txftplog;
            iter;
          endif;
          if $pupdate = 'Y';
            delete txftpr;
          endif;
          txftplogcnt = txftplogcnt + 1;
        enddo;

        // ordp
        setgt (clnwhse: blankroute) ordp;
        dow forever = forever;
          reade (clnwhse) ordp;
          if %eof(ordp);
            leave;
          endif;
          chain (orpwhs: orprid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: orprid) ordp;
            iter;
          endif;
          if $pupdate = 'Y';
            delete orprec;
          endif;
          ordpcnt = ordpcnt + 1;
        enddo;

        // totebund2
        setgt (clnwhse: blankroute) totebund2;
        dow forever = forever;
          reade (clnwhse) totebund2;
          if %eof(totebund2);
            leave;
          endif;
          chain (tbwhse: tbrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: tbrtid) totebund2;
            iter;
          endif;
          if $pupdate = 'Y';
            delete tbrec;
          endif;
          totebund2cnt = totebund2cnt + 1;
        enddo;

        // totehdr
        setgt (clnwhse: blankroute) totehdr;
        dow forever = forever;
          reade (clnwhse) totehdr;
          if %eof(totehdr);
            leave;
          endif;
          chain (tohwhs: tohrid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: tohrid) totehdr;
            iter;
          endif;
          if $pupdate = 'Y';
            delete tohrec;
          endif;
          totehdrcnt = totehdrcnt + 1;
        enddo;

        // ttitm
        setgt (clnwhse: blankroute) ttitm;
        dow forever = forever;
          reade (clnwhse) ttitm;
          if %eof(ttitm);
            leave;
          endif;
          chain (ttiwhs: ttirti) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttirti) ttitm;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttirec;
          endif;
          ttitmcnt = ttitmcnt + 1;
        enddo;

        // ttlog
        setgt (clnwhse: blankroute) ttlog;
        dow forever = forever;
          reade (clnwhse) ttlog;
          if %eof(ttlog);
            leave;
          endif;
          chain (ttlwhse: ttlrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttlrtid) ttlog;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttlrec;
          endif;
          ttlogcnt = ttlogcnt + 1;
        enddo;

        // ttmerg
        setgt (clnwhse: blankroute) ttmerg;
        dow forever = forever;
          reade (clnwhse) ttmerg;
          if %eof(ttmerg);
            leave;
          endif;
          chain (ttmwhs: ttmpri) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttmpri) ttmerg;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttmrec;
          endif;
          ttmergcnt = ttmergcnt + 1;
        enddo;

        // ttrte
        setgt (clnwhse: blankroute) ttrte;
        dow forever = forever;
          reade (clnwhse) ttrte;
          if %eof(ttrte);
            leave;
          endif;
          chain (ttrwhs: ttrrti) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttrrti) ttrte;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttrrec;
          endif;
          ttrtecnt = ttrtecnt + 1;
        enddo;

        // ttrtn3
        setgt (clnwhse: blankroute) ttrtn3;
        dow forever = forever;
          reade (clnwhse) ttrtn3;
          if %eof(ttrtn3);
            leave;
          endif;
          chain (ttwhse: ttrtid) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttrtid) ttrtn3;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttrec;
          endif;
          ttrtn3cnt = ttrtn3cnt + 1;
        enddo;

        // ttstp
        setgt (clnwhse: blankroute) ttstp;
        dow forever = forever;
          reade (clnwhse) ttstp;
          if %eof(ttstp);
            leave;
          endif;
          chain (ttpwhs: ttprti) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttprti) ttstp;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttprec;
          endif;
          ttstpcnt = ttstpcnt + 1;
        enddo;

        // tttrx
        setgt (clnwhse: blankroute) tttrx;
        dow forever = forever;
          reade (clnwhse) tttrx;
          if %eof(tttrx);
            leave;
          endif;
          chain (ttxwhs: ttxrti) rtehed;
          if %found(rtehed);
            setgt (clnwhse: ttxrti) tttrx;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttxrec;
          endif;
          tttrxcnt = tttrxcnt + 1;
        enddo;

        // labelps
        setll (clnwhse) labelps;
        dow forever = forever;
          reade (clnwhse) labelps;
          if %eof(labelps);
            leave;
          endif;
          chain (lslbl#) label;
          if %found(label);
            iter;
          endif;
          if $pupdate = 'Y';
            delete lsrec;
          endif;
          labelpscnt = labelpscnt + 1;
        enddo;

        // runner6
        setll (clnwhse) runner6;
        dow forever = forever;
          reade (clnwhse) runner6;
          if %eof(runner6);
            leave;
          endif;
          chain (rulbl#) label;
          if %found(label);
            iter;
          endif;
          if $pupdate = 'Y';
            delete rurec;
          endif;
          runner6cnt = runner6cnt + 1;
        enddo;

        // bulkdrp1
        setll (clnwhse) bulkdrp1;
        dow forever = forever;
          reade (clnwhse) bulkdrp1;
          if %eof(bulkdrp1);
            leave;
          endif;
          chain (bdlbl#) label;
          if %found(label);
            iter;
          endif;
          if $pupdate = 'Y';
            delete bdrec;
          endif;
          bulkdrp1cnt = bulkdrp1cnt + 1;
        enddo;

        // pirtran5
        setll (clnwhse) pirtran5;
        dow forever = forever;
          reade (clnwhse) pirtran5;
          if %eof(pirtran5);
            leave;
          endif;
          if ptgdte > clndate;
            leave;
          endif;
          if ptcat  <> 'SELECT';
            iter;
          endif;
          if pttask =  'RUNNER';
            iter;
          endif;
          chain (ptwhse: pttrn#) label90;
          if %found(label90);
            iter;
          endif;
          if $pupdate = 'Y';
            delete ptrec;
          endif;
          pirtran5cnt = pirtran5cnt + 1;
        enddo;

        // multran1
        dow forever = forever;
          read multran1;
          if %eof(multran1);
            leave;
          endif;
          if musdte > clndate;
            iter;
          endif;
          chain (clnwhse: mutrn#) label90;
          if %found(label90);
            iter;
          endif;
          if $pupdate = 'Y';
            delete murec;
          endif;
          multran1cnt = multran1cnt + 1;
        enddo;

        // ordad
        setll (clnwhse) ordad;
        dow forever = forever;
          reade (clnwhse) ordad;
          if %eof(ordad);
            leave;
          endif;
          chain (ordwhs: ordord) ordh;
          if %found(ordh);
            setgt (clnwhse: ordord) ordad;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ordrec;
          endif;
          ordadcnt = ordadcnt + 1;
        enddo;

        // ordd
        setll (clnwhse) ordd;
        dow forever = forever;
          reade (clnwhse) ordd;
          if %eof(ordd);
            leave;
          endif;
          chain (odwhse: odord) ordh;
          if %found(ordh);
            setgt (clnwhse: odord) ordd;
            iter;
          endif;
          if $pupdate = 'Y';
            delete odrec;
          endif;
          orddcnt = orddcnt + 1;
        enddo;

        // ordds
        setll (clnwhse) ordds;
        dow forever = forever;
          reade (clnwhse) ordds;
          if %eof(ordds);
            leave;
          endif;
          chain (oswhse: osord) ordh;
          if %found(ordh);
            setgt (clnwhse: osord) ordds;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ossrec;
          endif;
          orddscnt = orddscnt + 1;
        enddo;

        // orddm
        setll (clnwhse) orddm;
        dow forever = forever;
          reade (clnwhse) orddm;
          if %eof(orddm);
            leave;
          endif;
          chain (omwhse: omord) ordh;
          if %found(ordh);
            setgt (clnwhse: omord) orddm;
            iter;
          endif;
          if $pupdate = 'Y';
            delete omrec;
          endif;
          orddmcnt = orddmcnt + 1;
        enddo;

        // ordbox
        setll (clnwhse) ordbox;
        dow forever = forever;
          reade (clnwhse) ordbox;
          if %eof(ordbox);
            leave;
          endif;
          chain (obwhse: obord) ordh;
          if %found(ordh);
            setgt (clnwhse: obord) ordbox;
            iter;
          endif;
          if $pupdate = 'Y';
            delete obrec;
          endif;
          ordboxcnt = ordboxcnt + 1;
        enddo;

        // ordexpdte
        setll (clnwhse) ordexpdte;
        dow forever = forever;
          reade (clnwhse) ordexpdte;
          if %eof(ordexpdte);
            leave;
          endif;
          chain (oewhse: oeord) ordh;
          if %found(ordh);
            setgt (clnwhse: oeord) ordexpdte;
            iter;
          endif;
          if $pupdate = 'Y';
            delete oerec;
          endif;
          ordexpdtecnt = ordexpdtecnt + 1;
        enddo;

        // ordc
        setll (clnwhse) ordc;
        dow forever = forever;
          reade (clnwhse) ordc;
          if %eof(ordc);
            leave;
          endif;
          chain (ocwhse: ocord) ordh;
          if %found(ordh);
            setgt (clnwhse: ocord) ordc;
            iter;
          endif;
          if $pupdate = 'Y';
            delete ocrec;
          endif;
          ordccnt = ordccnt + 1;
        enddo;

        // ordt
        setll (clnwhse) ordt;
        dow forever = forever;
          reade (clnwhse) ordt;
          if %eof(ordt);
            leave;
          endif;
          chain (otwhse: otord) ordh;
          if %found(ordh);
            setgt (clnwhse: otord) ordt;
            iter;
          endif;
          if $pupdate = 'Y';
            delete otrec;
          endif;
          ordtcnt = ordtcnt + 1;
        enddo;

        // ordslct3
        setll (clnwhse) ordslct3;
        dow forever = forever;
          reade (clnwhse) ordslct3;
          if %eof(ordslct3);
            leave;
          endif;
          chain (oswhse: osord) ordh;
          if %found(ordh);
            setgt (clnwhse: osord) ordslct3;
            iter;
          endif;
          if $pupdate = 'Y';
            delete osrec;
          endif;
          ordslct3cnt = ordslct3cnt + 1;
        enddo;

        // ttstpflg
        setll (clnwhse) ttstpflg;
        dow forever = forever;
          reade (clnwhse) ttstpflg;
          if %eof(ttstpflg);
            leave;
          endif;
          chain (ttfwhs: ttfrte: ttfrti) rtehed1;
          if %found(rtehed1);
            iter;
          endif;
          if $pupdate = 'Y';
            delete ttfrec;
          endif;
          ttstpflgcnt = ttstpflgcnt + 1;
        enddo;

        // ldrhhdr
        setll (clnwhse) ldrhhdr;
        dow forever = forever;
          reade (clnwhse) ldrhhdr;
          if %eof(ldrhhdr);
            leave;
          endif;
          chain (lhhwhs: lhhrte: lhhrti) rtehed1;
          if %found(rtehed1);
            iter;
          endif;
          if $pupdate = 'Y';
            delete lhhrec;
          endif;
          ldrhhdrcnt = ldrhhdrcnt + 1;
        enddo;

        // ldrhdetl
        setll (clnwhse) ldrhdetl;
        dow forever = forever;
          reade (clnwhse) ldrhdetl;
          if %eof(ldrhdetl);
            leave;
          endif;
          chain (ldhwhs: ldhrte: ldhrti) rtehed1;
          if %found(rtehed1);
            iter;
          endif;
          if $pupdate = 'Y';
            delete ldhrec;
          endif;
          ldrhdetlcnt = ldrhdetlcnt + 1;
        enddo;

        *inlr = *on;
        clnoldpf = 'CLNRT755 ' + 'rtesum Count ' + %char(rtesumcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'rtecsum Count ' + %char(rtecsumcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'rtenote Count ' + %char(rtenotecnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'rtestp  Count ' + %char(rtestpcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'pltsum1 Count ' + %char(pltsum1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'pltstp1 Count ' + %char(pltstp1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'pltmisc Count ' + %char(pltmisccnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'batctl2 Count ' + %char(batctl2cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'workzon1 Count ' + %char(workzon1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'worklbl7 Count ' + %char(worklbl7cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'label13 Count ' + %char(label13cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'labelps Count ' + %char(labelpscnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'pirtran5 Count ' + %char(pirtran5cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordad Count ' + %char(ordadcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordh3 Count ' + %char(ordh3cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordhm2 Count ' + %char(ordhm2cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordd Count ' + %char(orddcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordds Count ' + %char(orddscnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'orddm Count ' + %char(orddmcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordbox Count ' + %char(ordboxcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordbsum1 Count ' + %char(ordbsum1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordexpdte Count ' + %char(ordexpdtecnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordc Count ' + %char(ordccnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordlbl1 Count ' + %char(ordlbl1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordt Count ' + %char(ordtcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordslct3 Count ' + %char(ordslct3cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'pirseq1 Count ' + %char(pirseq1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'multran1 Count ' + %char(multran1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'runner6 Count ' + %char(runner6cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'bulkdrp1 Count ' + %char(bulkdrp1cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'prexref3 Count ' + %char(prexref3cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'txftplog Count ' + %char(txftplogcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ordp Count ' + %char(ordpcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'totebund2 Count ' + %char(totebund2cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'totehdr Count ' + %char(totehdrcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttitm Count ' + %char(ttitmcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttlog Count ' + %char(ttlogcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttmerg Count ' + %char(ttmergcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttrte Count ' + %char(ttrtecnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttrtn3 Count ' + %char(ttrtn3cnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttstp Count ' + %char(ttstpcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ttstpflg Count ' + %char(ttstpflgcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'tttrx Count ' + %char(tttrxcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ldrhhdr Count ' + %char(ldrhhdrcnt);
        write cln;
        clnoldpf = 'CLNRT755 ' + 'ldrhdetl Count ' + %char(ldrhdetlcnt);
        write cln;
      /end-free
