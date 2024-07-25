      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR12700U     PO Receiving - Mark detail line as Touched
     *  17 December 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    12/17/14  LMC  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Purchase Order Detail Seq#
     *      pMark       Mark
     *      puser       user
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
      /COPY QCOPYSRC,ID#PACKERS
      /copy qcopysrc,id#citylin

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3p 0
     D pPo             s              9
     D pPOSeq          s              5p 0
     D pMark           s              1
     D puser           s             10
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D hldtim          s             19
     D today           s              8  0
     D curtime         s              6  0
     D $ok             s               n
     D count           s              5p 0
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

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

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
     D pdrec         E Ds                  Extname(podtl)
     D porrec        E Ds                  Extname(porcv)
     D smdrec        E Ds                  Extname(smartdock)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pMark
     c                   parm                    puser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        select;
          when pMark = 'Y';
            // Get start time
            if client = cityline;
              exsr zzSDtime;
            endif;

          // check porcv if not found or export allow add
          exec sql select * into :porrec
                   from porcv
                   where porwhs  = :pWhse
                     and porpo  = :pPo
                     and porseq = :pPOSeq
                   order by porwhs,porpo,porseq,poredt
                   fetch first row only;
          if sqlstt = sqlsuccess
             and poredt = 0;
          else;
            porwhs = pWhse;
            porpo = pPO;
            porseq = pPOSeq;
            pordte = today;
            portim = #jobtime;
            porusr = Puser;
            poremp = e$emp#;
            portrn = 0;
            porlic = *blanks;
            porlbl = 0;
            poract = 'X';
            poredt = 0;
            poreti = 0;
            exec sql insert into porcv values(:porrec);
            // update PO header to partial if status is open.
            exec sql update pohdr set
                       phstat = 1
                     where phwhse = :pWhse
                       and phpo = :pPO
                       and phstat = '0';
          endif;

          // check to see if SMARTDOCK start and /or stop times
          // should be updated.
          if client = cityline;
            exsr zzSDstart;
            exsr zzckrc;
          endif;

        endsl;

         pOutStr = '{'
                +  '"PO":"'  + %trimr(pPO) + '",'
                +  '"Mark":"'  + %trimr(pMark) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free


     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
        begsr *INZSR;

        getclient(client: clientLoc);

650aA   getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA           e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA           e$bpu: e$lng);

        $cvcmd = '*CURCMD';
        cvtdte($cvtdt);
        today = $cvd8o;
        endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  ZZSDTIME   Populate date and time field to write to SMARTDOCK file.
     *
     C     zzSDtime      begsr

     C                   time                    curtime
     C                   eval      hldtim=%trim(%subst(%editc(today:'X'):5:2))
     C                                   + '/' +
     C                                    %trim(%subst(%editc(today:'X'):7:2))
     C                                   + '/' +
     C                                    %trim(%subst(%editc(today:'X'):1:4))
     C                                   + ' ' +
     C                                    %trim(%subst(%editc(curtime:'X'):1:2))
     C                                   + ':' +
     C                                    %trim(%subst(%editc(curtime:'X'):3:2))
     C                                   + ':' +
     C                                    %trim(%subst(%editc(curtime:'X'):5:2))
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSDSTART   Update start time in SMARTDOCK file.
     *
     C     zzSDstart     begsr
      /free
        exec sql update smartdock set
                   smdstr = :hldtim
                 where smdwhs = :pWhse
                   and smdpo = :pPO
                       and smdstr = ' ';
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKRC   Check P/O to see if all detail lines have been received
     *           or touched.  If so, update stop time in SMARTDOCK file.
     *
     c     zzckrc        begsr

      /free
        $ok = *on;
        // all lines must be touched
        exec sql select count(*) into :count
                 from podtl T01 exception join porcv T02
                    on T01.pdpo=T02.porpo and T01.Pdwhse=T02.porwhs
                   and T01.pdseq=T02.porseq
                 where (T02.porseq is null)
                   and t01.pdwhse  = :pWhse
                   and t01.pdpo  = :pPO;
        if sqlstt = sqlsuccess;
          if count > 0;
            $ok = *off;
          endif;
        endif;

        if $ok = *on;
          exsr zzSDstop;
        endif;
      /end-free

     c                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZSDSTOP   Update stop time in SMARTDOCK file.
     *
     C     zzSDstop      begsr
      /free
        exsr zzSDtime;
        exec sql update smartdock set
                   smdstp = :hldtim
                 where smdwhs = :pWhse
                   and smdpo = :pPO
                       and smdstp = ' ';
      /end-free
     C                   endsr
     *
