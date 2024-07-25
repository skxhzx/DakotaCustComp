      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CHKPCM    Check for PCM Entry neeeded.
     *  24 March 2015
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700 A*    03/24/15  LMC  7.00
     *      - Created.
700aA*    02/10/16  LMC  7.00a
     *      - Check for previous entry on RCVL
     *        Gui version of PCM questions will allow the user
     *        to setup a RCVL question with a frequency of 4.
     *        In case a user sets up RCVL with frequency 4 we still
     *        need to check if the question has already been answered
     *        for the license.
     *      - RCVL level records need to get the item for the pirhold
     *        POLCNS record, old haccp would already have a licactive
     *        record to get the item, GUI hasn't written the licactive
     *        record at this point.
710aA*    10/09/17  LMC  7.10a
     *      - Added first record only. We are getting duplicates from
     *        the super po process. This is a temporary fix, until I
     *        can correct the loading program. This fix can stay it
     *        will not hurt anything.
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
720b *    10/25/18  LMC  7.20b
     *      - Do not ask frequency type 1 questions on non stock items
720c *    01/07/199 LMC  7.20c
     *      - gui doesn't use session HPSID - so if session is blank
     *        assume the haccplog record does not exist.
730aA*    04/22/19  LMC  7.30a
     *      - Added first record only. We are getting duplicates from
     *        the super po process. This is a temporary fix, until I
     *        can correct the loading program. This fix can stay it
     *        will not hurt anything.  RCVH was missed
740aA*    04/15/20  LMC  7.40a
     *      - Added POVFY logic for PO PCM verification.
740bA*    05/26/20  LMC  7.40b
     *      - Recompile only - database change
740cA*    06/05/20  LMC  7.40c
     *      - Added POFU logic for PO follow-up
750aA*    03/30/20  LMC  7.50a
     *      - Added PCM Exclusion logic.
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fhaccpq3   if   e           k disk
     fhaccplog1 if   e           k disk
     fhaccplog2 if   e           k disk    rename(hlrec:hl3) prefix(h3_)
     Fhaccpqt   if   e           k disk
     Fpospo     if   e           k disk
     Fpospo1    if   e           k disk    rename(purec:spurec)
750aAFitemcls   if   e           k disk
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
740aA*----------------------------------------------------------------
740aA*  Sub-procedure prototypes
740aA*----------------------------------------------------------------

740aAd CreateTS        pr              z
740aAd  date                          8p 0 const
740aAd  time                          6p 0 const

700aA*----------------------------------------------------------------
700aA*  pirhold structures
700aA*----------------------------------------------------------------
700aA /copy qcopysrc,C#PIRHLLCN

     *----------------------------------------------------------------
     *  Customer id
     *
     *---------------------------------------------------------------
     *  Variables
     *

     D pcmd            s              8
     D PWhse           s              3s 0
     D PLevel          s              4
     D PType           s              3
     D PPO             s              9
     D PPOSeq          s              5  0
     D PSuper          s              1
     D Plcns           s             15
     D PEntPCM         s              1

     D client          s             10
     D clientloc       s             10

740aAD pexpdate        s              8  0
740aAD pexptime        s              6  0
     D morelicense     s              1
     D savelicense     s                   like(plcns)
     D $code           s             15
     D moretypes       s              1
     D morequestions   s              1
     D holdwhpg        s              3  0
     D*hldspecdesc     s                   like(#lvdsc1)
     D forevr          s              1
     D prvscn          s              1
     D savehipge#      s              5  0
     D savetype        s              3
     D savepage        s              1
     D whpg            s              3  0
     D today           s              1
700aAD laitem          s             15
740aAD pohdrexpdtts    s               z
750aAD excludeqstn     s              1
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hirec3        E Ds                  Extname(HACCPQ3) prefix(ck_)
     D phrec         e ds                  extname(pohdr)
700aDD*larec         e ds                  extname(licactive)
700aAD horec         e ds                  extname(pirhold)
     D itrec         e ds                  extname(piritem)
     D ifrec         e ds                  extname(itemfld)
     D hprec         e ds                  extname(haccps)
     D hlrec1        e ds                  extname(haccplog)
740aAD phhrec        e ds                  extname(pohhdr)
750aAD herec         e ds                  extname(haccpe)


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      PCmd   Command
     *      PWhse  Warehouse number.
     *      PLevel Level
     *      PType  Type
     *      PPO    PO#
     *      PPOSeq PO Seq#
     *      PSuper Super Po Flag
     *      PLcns  License
     *
     *    Returned Parameters
     *      PEntPCM Enter PCM = Y or N
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     c                   parm                    Pcmd
     c                   parm                    PWhse
     c                   parm                    PLevel
     c                   parm                    PType
     c                   parm                    PPO
     c                   parm                    PPOSeq
     c                   parm                    PSuper
     c                   parm                    PLcns
     c                   parm                    pEntPCM
     *----------------------------------------------------------------
     *  Main line
     *
     * check to see if any active questions exist for the level/type
      /free
        *inlr = '1';
        pEntPCM = 'N';
        exec sql select * into :hirec3
             from HACCPQ3
             where hiwhse = :pWhse
               and hilevl = :pLevel;

        If sqlstt =  sqlNoData;
          return;
        else;
          // Code from Ha410
        endif;
        exsr zzinz2;
      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *INZSR;

          getclient(client: clientLoc);
        endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
      /free
       begsr zzinz2;

         hbtype = ptype;
         hblevl = plevel;
         // get vendor name
         exec sql select * into :phrec
                  from pohdr
                  where phwhse = :pwhse
                    and phpo   = :ppo;
         if sqlstt = sqlSuccess;
         else;
           phvnam = *blanks;
         endif;
         // Get License if *PODTLCH and no license passed in.
         if pcmd = '*PODTLCH' and plevel = 'RCVL';
           if plcns    = ' ';
             setll (pwhse: ppo: pposeq) haccplog2;
             morelicense = 'Y';
           endif;
           if morelicense = 'Y';
             h3_hllcns = ' ';
             dou savelicense <> h3_hllcns or
                 morelicense = ' ';
               reade (pwhse: ppo: pposeq) haccplog2;
               if %eof(haccplog2);
                 morelicense = ' ';
               else;
                 plcns    = h3_hllcns;
               endif;
             enddo;
               savelicense = h3_hllcns;
           endif;
         endif;

         // Get Item Number if license is passed in on RCVL
         // Load item if item passed in on RCVI
         laitem = *blanks;
         if plevel = 'RCVI';
           laitem = plcns;
         endif;
         if plevel = 'REXI';
           laitem = plcns;
         endif;
740cM    if plevel = 'RCVV'
740cA      or plevel = 'RCVF';
740aA      pexpdate = %dec(%subst(Plcns:1:8):8:0);
740aA      pexptime = %dec(%subst(Plcns:9:6):6:0);
740aA      plcns = ' ';
740aA    endif;
         if plevel = 'RCVL';
700aA      exec sql select * into :horec
700aA               from pirhold
700aA               where hokey = :plcns
700aA                 and hotype = 'POLCNS';
700aA      If sqlstt = sqlSuccess;
700aA        pirhllcnds = hodata;
700aA        laitem = h1item;
700aA      else;
700aA        laitem = ' ';
700aA      endif;
700aD      //exec sql select * into :larec
700aD               //from licactive
700aD               //where lawhse = :pwhse
700aD                 //and lalcns = :plcns;
         endif;

         // Get item description to display.
         exec sql select * into :itrec
                  from piritem
                  where itwhse = :pwhse
                    and ititem = :laitem;
         if sqlstt = sqlSuccess;
           //wodesc = %trimr(itpdsc) + ' ' + itdesc;
         else;
           //wodesc = *blanks;
         endif;
         ifcat = ' ';
         exec sql select * into :ifrec
                  from itemfld
                  where ifwhse = :pwhse
                    and ifitem = :laitem;
         // get heading for special user type selection
         select;
           when plevel = 'RCVH';
           when plevel = 'RCVI';
           when plevel = 'REXI';
           when plevel = 'RCVL';
           other;
             chain (pwhse: plevel: ptype) haccpqt;
             if %found(haccpqt);
               //hldspecdesc = hbdesc;
             else;
               //hldspecdesc = ' ';
             endif;
         endsl;

         // get session id
         exec sql select * into :hprec
                  from haccps
                  where hpuser = :#user
                    and hpjob = :#job
                    and hpjobn = :#jobn;
720cA      if sqlstt <> sqlSuccess;
720cA        hpsid = *loval;
720cA      endif;
           exsr zzfil1;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

      /free
       begsr zzfil1;

         select;
           when prvscn = 'Y' and holdwhpg > whpg;
             setll (pwhse: hblevl: hbtype) haccpqt;
           when morequestions = 'Y';
           when moretypes = 'Y';
           when ptype = ' ';
             setll (pwhse: hblevl) haccpqt;
           when ptype <> ' ';
             setll (pwhse: hblevl: hbtype) haccpqt;
         endsl;

         dow forevr = forevr;
           select;
             when prvscn = 'Y' and holdwhpg > whpg;
               reade (pwhse: hblevl) haccpqt;
             when morequestions = 'Y';
             when ptype = ' ';
               reade (pwhse: hblevl) haccpqt;
             when ptype <> ' ';
               reade (pwhse: hblevl: hbtype) haccpqt;
           endsl;

           if %eof(haccpqt);
             moretypes = ' ';
             leave;
           endif;

           if morequestions = ' ';
             $code = ' ';
           endif;

           select;
             when morequestions = 'Y';
             when hbtype = 'CAT';
               $code = ifcat;
             when hbtype = 'ITM';
               $code = ititem;
             when hbtype = 'DPT';
               $code = itwhdp;
             when hbtype = 'VEN';
               $code = %trim(%editc(phven:'Z'));
           endsl;

           if morequestions = ' ' and prvscn = ' ' or
              morequestions = ' ' and whpg = 0 or
              morequestions = ' ' and moretypes = 'Y' and prvscn = 'Y';
             hilevl = hblevl;
             hitype = hbtype;
             setll (pwhse: hilevl: hitype: $code) haccpq3;
           endif;

           // read question file for question type
           dou %eof(haccpq3);
             reade (pwhse: hilevl: hitype: $code) haccpq3;
             if %eof(haccpq3);
               morequestions = ' ';
               leave;
             endif;

750aA        // page controls are not used in web, marking this code out
750aD        // page controls
750aD        //if hipge# <> savehipge# and savepage = *on;
750aD        //  morequestions = 'Y';
750aD        //  readpe (pwhse: hilevl: hitype: $code) haccpq3;
750aD        //  if %eof (haccpq3);
750aD        //    setll (pwhse: hilevl: hitype: $code) haccpq3;
750aD        //  endif;
750aD        //  leavesr;
750aD        //endif;

750aA        // lets check for exclusion
750aA
750aA        exsr zzexclude;
750aA        if excludeqstn = 'Y';
750aA          iter;
750aA        endif;
             select;
               // previous screen is requested, need to check for answers
               // that have already been logged.
               when prvscn = 'Y';
                 exsr zzchklog;

               // *POHDR check to see if header questions have been
               // answered already for this po today don't ask again
               when pcmd = '*POHDR  ';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

740aA            // *POVFY check to see if RCVV questions have been
740aA            // answered already for this po since the export date
740cM            when pcmd = '*POVFY  '
740cA              or pcmd = '*POFU  ';
740aA              exsr zzchklog;
740aA              if today = 'Y';
740aA                savetype = hitype;
740aA                iter;
740aA              endif;
               // if *POHDRCH check to see if header question have been
               // answered for this po today, allow change to answers
               when pcmd = '*POHDRCH';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

               // *PODTL check to see if detail questions have been
               // answered already for this po today don't ask again
               when pcmd = '*PODTL  ' and plevel = 'RCVI';
                 plcns = ' ';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

               // *PODTL check to see if detail questions have been
               // answered already for this po today don't ask again
               when pcmd = '*PODTL  ' and plevel = 'REXI';
                 plcns = ' ';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;


               // if *PODTLCH check to see if detail question have been
               // answered for this po today, allow change to answers
               when pcmd = '*PODTLCH' and plevel = 'RCVI';
                 plcns = ' ';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

               // if *PODTLCH check to see if detail question have been
               // answered for this po today, allow change to answers
               when pcmd = '*PODTLCH' and plevel = 'REXI';
                 plcns = ' ';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;


               // *PODTL check to see if detail questions have been
               // answered already for this po today don't ask again
               when pcmd = '*PODTL  ' and plevel = 'RCVL';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

               // if *PODTLCH check to see if detail question have been
               // answered for this po today, allow change to answers
               when pcmd = '*PODTLCH' and plevel = 'RCVL';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

               // if *RANDOMC check to see if random question have been
               // answered for this user type today, allow change to answers
               when pcmd = '*RANDOMC';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;
             endsl;


             // If I get here set EntPCM to Yes
             pEntPCM = 'Y';
             leavesr;
             //exsr loadquestions;
           enddo;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHKLOG   Check for po receipt already done today
     *
     *----------------------------------------------------------------
      /free
       begsr zzchklog;
         today = ' ';
         select;
720bA    // freq 1 and non stock do not get asked
720bA      when hifreq = '1' and %subst(itdesg:5:1) = '*';
720bA        today = 'Y';
         // don't check on everytime question hifreq = 4  unless *PODTLCH
         when hifreq = '4' and pcmd = '*PODTLCH';
           setgt  (pwhse: ppo: pposeq: plcns: hiseq#) haccplog1;
           readpe (pwhse: ppo: pposeq: plcns: hiseq#) haccplog1;
           if not %eof(haccplog1);
             if hlexpts = *loval;
               today = 'Y';
             endif;
           endif;

700aA    // If RCVL  need to check to see if question already answered
700aD    //when hifreq = '4';
700aM    when hifreq = '4' and plevel <> 'RCVL';

         // once per po check
         when plevel = 'RCVI' and hifreq = '2' and hitype = 'CAT' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'DPT' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                    and hlexpts = '0001-01-01-00.00.00.000000'
710aM               and hlobsolete <> 'Y'
710aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
740aA    // once per po verification check
740cM    when plevel = 'RCVV'
740cA      or plevel = 'RCVF';
740aA      exec sql select * into :phhrec
740aA             from pohhdr
740aA             where phhwhs = :pwhse
740aA               and phhpo  = :ppo
740aA               and phhedt = :pexpdate
740aA               and phheti = :pexptime;
740aA      if sqlstt = sqlSuccess;
740aA        pohdrexpdtts = CreateTS(phhedt: phheti);
740aA        exec sql select * into :hlrec1
740aA               from haccplog
740aA               where hlwhse = :pwhse
740aA               and hlpo   = :ppo
740aA               and hlseq# = :hiseq#
740aA               and hladdts > :pohdrexpdtts
740aA               and hlobsolete <> 'Y'
740aA             fetch first row only;
740aA        if sqlstt = sqlSuccess;
740aA          today = 'Y';
740aA        endif;
740aA      endif;
         // once per po check - exceptions
         when plevel = 'REXI' and hifreq = '2' and hitype = 'CAT' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'DPT' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                    and hlexpts = '0001-01-01-00.00.00.000000'
710aM               and hlobsolete <> 'Y'
710aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

720cA    // once per po session check  - but no hpsid field populated
720cA    when plevel = 'RCVI' and hifreq = '3' and hitype = 'CAT'
720cA                         and hpsid = *loval or
720cA         plevel = 'RCVI' and hifreq = '3' and hitype = 'DPT'
720ca                         and hpsid = *loval or
720cA         plevel = 'RCVI' and hifreq = '3' and hitype = 'ALL'
720cA                         and hpsid = *loval;

         // once per po session check
         when plevel = 'RCVI' and hifreq = '3' and hitype = 'CAT' or
              plevel = 'RCVI' and hifreq = '3' and hitype = 'DPT' or
              plevel = 'RCVI' and hifreq = '3' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                     and hlsid = :hpsid
                    and hlexpts = '0001-01-01-00.00.00.000000'
                    and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         // once per po session check exceptions
         when plevel = 'REXI' and hifreq = '3' and hitype = 'CAT' or
              plevel = 'REXI' and hifreq = '3' and hitype = 'DPT' or
              plevel = 'REXI' and hifreq = '3' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                     and hlsid = :hpsid
                    and hlexpts = '0001-01-01-00.00.00.000000'
                    and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

720cA    // once per po session check  - but no hpsid field populated
720cA    when plevel = 'RCVI' and hifreq = '3' and hitype = 'ITM'
720cA                         and hpsid = *loval;

         when plevel = 'RCVI' and hifreq = '3' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plcns
                      and hlseq# = :hiseq#
                       and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         when plevel = 'REXI' and hifreq = '3' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plcns
                      and hlseq# = :hiseq#
                       and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

730aA    // once per po
730aA    when plevel = 'RCVH';
730aA      exec sql select * into :hlrec1
730aA               from haccplog
730aA               where hlwhse = :pwhse
730aA                   and hlpo = :ppo
730aA                 and hlseq# = :hiseq#
730aA                and hlexpts = '0001-01-01-00.00.00.000000'
730aA             and hlobsolete <> 'Y'
730aA             fetch first row only;
730aA      if sqlstt = sqlSuccess;
730aA          today = 'Y';
730aA      endif;

         // once per item per po
         when psuper = 'N' or
720bD         //plevel = 'RCVI' and hifreq = '1' or
720bM         plevel = 'RCVI' and hifreq = '1' and %subst(itdesg:5:1) <> '*' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'ITM' or
              plevel = 'RCVL' or
720bD         //plevel = 'REXI' and hifreq = '1' or
720bM         plevel = 'RCVI' and hifreq = '1' and %subst(itdesg:5:1) <> '*' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plcns
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

         when pcmd = '*RANDOMC';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                      and hlseq# = :hiseq#
                       //and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         other;
           // this will do super po check for the existence
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                       and hlspo = :ppo
                     and hlposeq = :pposeq
                      and hllcns = :plcns
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
710aM             and hlobsolete <> 'Y'
710aA             fetch first row only;
           if sqlstt = sqlSuccess or
              sqlstt = '21000';
               today = 'Y';
             // Now check to see if all po's linked to super po exist
             // in HACCPLOG need to ask questions for any po's linked
             // to super po after receipt has started.
             // Need to ask questons if new po was added.
             setll (pwhse: ppo) pospo;
             dow not %eof(pospo);
               reade (pwhse: ppo) pospo;
               if %eof(pospo);
                 leave;
               endif;
               exec sql select * into :hlrec1
                        from haccplog
                        where hlwhse = :pwhse
                            and hlpo = :pupo
                           and hlspo = :ppo
                         and hlposeq = :pposeq
                          and hllcns = :plcns
                          and hlseq# = :hiseq#
                         and hlexpts = '0001-01-01-00.00.00.000000'
710aM                 and hlobsolete <> 'Y'
710aA             fetch first row only;
               // already asked for this po.
               if sqlstt = sqlSuccess or
                 sqlstt = '21000';
               else;
               // needs to be asked for at least one po added.
                 today = 'N';
               endif;
             enddo;
           endif;
         endsl;
       endsr;
      /end-free

750aA*----------------------------------------------------------------
750aA*
750aA*  ZZEXCLUDE See if the question is excluded
750aA*
750aA*----------------------------------------------------------------
750aA /free
750aA  begsr zzexclude;
750aA    // do we have an exclusion for this question
750aA    // lets check for exclusion
750aA    ExcludeQstn = ' ';
750aA    exec sql select * into :herec
750aA         from HACCPe
750aA         where hewhse = :hiwhse
750aA           and helevl = :hilevl
750aA           and hetype = :hitype
750aA           and hecode = :hicode
750aA           and heseq# = :hiseq#
750aA         fetch first row only;
750aA    if sqlstt = sqlSuccess;
750aA      // we have to check the exclusion
750aA      // is there an exclusion for this question by vendor
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'V'
750aA             and hevend = :phven;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Dept
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'D'
750aA             and hedept = :itwhdp;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Item
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'I'
750aA             and heitem = :ititem;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Category
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'C'
750aA             and hecat  = :ifcat;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Class
750aA      //  need to read all the classes assigned to item
750aA      setll (itwhse: ititem) itemcls;
750aA      dow forever = forever;
750aA        reade (itwhse: ititem) itemcls;
750aA        if %eof(itemcls);
750aA          leave;
750aA        endif;
750aA        exec sql select * into :herec
750aA             from HACCPe
750aA             where hewhse = :hiwhse
750aA               and helevl = :hilevl
750aA               and hetype = :hitype
750aA               and hecode = :hicode
750aA               and heseq# = :hiseq#
750aA               and heetype = 'L'
750aA               and heclass= :iclcde;
750aA        if sqlstt = sqlSuccess;
750aA          ExcludeQstn = 'Y';
750aA          leave;
750aA        endif;
750aA      enddo;
750aA    endif;
750aA  endsr;
750aA /end-free

740aA*----------------------------------------------------------------
740aA*  CreateTS   Create timestamp from Date/Time
740aA*----------------------------------------------------------------

740aAp CreateTS        b
740aAd CreateTS        pi              z
740aAd  date                          8p 0 const
740aAd  time                          6p 0 const

740aA*  Local Variables

740aAD stamp           s               z
740aAD temp26          s             26

740aAD                 ds
740aAD  yyyymmdd               1      8s 0
740aAD    yyyy                 1      4
740aAD    mm                   5      6
740aAD    dd                   7      8

740aAD                 ds
740aAD  hhmiss                 1      6s 0
740aAD    hh                   1      2
740aAD    mi                   3      4
740aAD    ss                   5      6


740aA /free

740aA   clear stamp;

740aA   if date = 0;
740aA     return stamp;
740aA   endif;

740aA   yyyymmdd = date;
740aA   hhmiss = time;
740aA   temp26 = yyyy + '-' + mm + '-' + dd + '-'
740aA          + hh + '.' + mi + '.' + ss + '.000000';

740aA   monitor;
740aA     stamp = %timestamp(temp26);
740aA   on-error;
740aA     clear stamp;
740aA   endmon;

740aA   return stamp;

740aA /end-free

740aAp CreateTS        e

