      /copy *libl/qcopysrc,hspecs
700aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PCMUPD   Update PCM answers
     *  25 August 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    08/25/14  DAS  6.50
     *      - Created.
     *
700aA*    03/30/15  LMC  7.00a
     *      - Added edits and file updates.
     *      - changed to sqlrpgle.
     *      - added warning override to json
700bA*    08/01/15  LMC  7.00b
     *      - Added additional logic.
700cA*    02/04/16  LMC  7.00c
     *      - Exception change logic had wrong command.
700dA*    02/11/16  LMC  7.00b
     *      - License level - RCVL need to load item/poseq.
710aA*    02/01/17  LMC  7.10a
     *      - RCVI - ALL frequency 4 needs to load item/poseq.
720a *    08/22/18  LMC  7.20a
     *      - Init new hlstop field for haccplog.
720b *    10/25/18  LMC  7.20b
     *      - load the item into qestions that are once per item
     *        frequency and rcvi all.
730a *    03/06/19  LMC  7.20c
     *      - load the item into qestions that are once per item
     *        frequency and rcvi dpt instead of the dept.
740aA*    04/15/20  LMC  7.40a
     *      - Enh: Added a PO verification process
740bA*    05/06/20  LMC  7.40b
     *      - Enh: Force user to upper case
740cA*    05/07/20  LMC  7.40c
     *      - Enh: GUI program will do edits for required fields on
     *        reactive questions. so exclude reactive questions from this
     *        edit.
     *      - Enh: Type 2 Hidden reactive questions will now have
     *        HLDCHLD in the answer field. Need to check for this
     *        for determining if there is a change in the answer.
740dA*    06/05/20  LMC  7.40d
     *      - Enh: Added a PO follow-up process
750aA*    04/23/21  LMC  7.50a
     *      - Enh: Added *RANDOMC Logic, we hadn't allowed for
     *        changing user control logs.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits an External Program parameter to 999 characters.
     *
     *   The JSON string that is passed in is not true JSON. The
     *   string will contain the following:
     *
     *   {"id":"aaa","ans":"bbb"},{"id":"aaa","ans":"bbb"},...
700aA*   {"id":"aaa","ans":"bbb","wo":"ccc"},{"id":"aaa","ans":"bbb","wo":"ccc"
     *
     *   were aaa is the Question Id and ans is the answer.
700aA*   were ccc is the warning override. Will be true or false.
     *
     *   True JSON would have bundled all of the {id}'s into
     *   a JSON array.
     *
     *----------------------------------------------------------------
700aA*----------------------------------------------------------------
700aA*  Binding Directories
700aA*----------------------------------------------------------------

700aAHbnddir('BFCBND')


     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     F*dopts    uf a e           k disk
     Fglosess   if   e           k disk
700bAFpospo     if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
700aA*      pCmd        Command
700aA*      pSuperPO    Super PO
700aA*      pPO         PO
700aA*      pPOSeq      PO Seq#
700aA*      pLcns       License
700aA*      pItem       Item
     *      pJSON       JSON String
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------
740bA*----------------------------------------------------------------
740bA*  Translation strings
740bA*----------------------------------------------------------------

740bAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
740bAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'


     D pcmupd          pr                  extpgm('PCMUPD')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
700aAD  pCmd                          8    varying
700aAD  pSuperPO                      9    varying
700aAD  pPO                           9    varying
700aAD  pPOSeq                        5  0
700aAD  pLcns                        15    varying
700aAD  pItem                        15    varying
     D  pJSON                       999    varying

     D pcmupd          pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
700aAD  pCmd                          8    varying
700aAD  pSuperPO                      9    varying
700aAD  pPO                           9    varying
700aAD  pPOSeq                        5  0
700aAD  pLcns                        15    varying
700aAD  pItem                        15    varying
     D  pJSON                       999    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700bAD answerchanged   s               n
     D forever         s               n

     D idChar          s             10    varying
     D ans             s             30    varying
700aAD wo              s              5    varying
     D delimiter       s              1    varying

     D i               s              5p 0
     D idBeg           s              5p 0
     D idEnd           s              5p 0
     D idLen           s              5p 0
     D idPos           s              5p 0
     D ansBeg          s              5p 0
     D ansEnd          s              5p 0
     D ansLen          s              5p 0
     D ansPos          s              5p 0
700aAD woBeg           s              5p 0
700aAD woEnd           s              5p 0
700aAD woLen           s              5p 0
700aAD woPos           s              5p 0

700aAD q#              s              5p 0
700aA*----------------------------------------------------------------
700aA*  Time variables
700aA*----------------------------------------------------------------
700aA
700aAD CurrStamploc    s               z
700aAD CurrStampsys    s               z
700aAD CurrStampuc     s               z
700aA
700aAD bfcoffset       s              3  0 inz(0)
700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------
700aA
700aA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hirec         E Ds                  Extname(HACCPQ1) prefix(q1_)
     D hlrec         E Ds                  Extname(haccplog)
700bAD haccplogck    E ds                  extname(haccplog) prefix(ck_)
700aAD phrec         E Ds                  Extname(pohdr)
700aAD hvrec         E Ds                  Extname(haccpv1)
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
740bA    puser = %xlate(xlower: xupper: puser);
700aA    exsr zzgettime;
700aA    HLsid = currstampsys;
         select;

           when pObjLoc = 'FLDVALID';
             exsr ProcessJSON;

         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  ProcessJSON   Process JSON string
     *----------------------------------------------------------------

      /free
       begsr ProcessJSON;

         if %len(pJSON) = 0;
           leavesr;
         endif;

         chain (pSessId) glosess;
         if not %found(glosess);
           leavesr;
         endif;

         i = 1;
         dow forever = forever;

           // Get next option

           idPos = %scan('"id"': pJSON: i);
           if idPos = 0;
             leave;
           endif;

           // Calculate beginning of id code

           idBeg = idPos + 6;

           // Get end of id code

           idEnd = %scan('",': pJSON: idBeg);
           if idEnd = 0;
             leave;
           endif;

           // Calculate length of id code

           idLen = idEnd - idBeg;

           // Get id

           idChar = %subst(pJSON: idBeg: idLen);

           // Calculate beginning of answer

           ansBeg = idEnd + 9;
           if ansBeg > %len(pJSON);
             leave;
           endif;

           // Get end of answer

700aD      //ansEnd = %scan('"}': pJSON: ansBeg);
700aM      ansEnd = %scan('",': pJSON: ansBeg);
           if ansEnd = 0;
             leave;
           endif;

           // Calculate length of answer

           ansLen = ansEnd - ansBeg;

           // Get answer

           ans = %subst(pJSON: ansBeg: ansLen);
700aA      // Edit Answers

700aA      exsr EditAns;

700aA      if pErrMsg <> ' ';
700aA        leave;
700aA      endif;

700aD      // Update record
700aD      //exsr UpdateAns;

700aD      //i = ansEnd;

700aA      // Calculate beginning of warning override

700aA      woBeg = ansEnd + 8;
700aA      if woBeg > %len(pJSON);
700aA        leave;
700aA      endif;

700aA      // Get end of warning

700aA      woEnd = %scan('"}': pJSON: woBeg);
700aA      if woEnd = 0;
700aA        leave;
700aA      endif;

700aA      // Calculate length of warning override

700aA      woLen = woEnd - woBeg;

700aA      // Get warning override

700aA      wo = %subst(pJSON: woBeg: woLen);

700aA      if q# <> 0;
700aA        select;
700aA          when pcmd = '*PORCV'
740aA               or pcmd = '*POVFY'
740dA               or pcmd = '*POFU'
700aA               or pcmd = '*POEXCP';
700bA            if pSuperPo <> ' ' and q1_hitype <> 'ITM';
700bA              // get all po's for the super po
700bA              setll (gswhse: pSuperPo) pospo;
700bA              dow not %eof(pospo);
700bA                reade (gswhse: pSuperPo) pospo;
700bA                if %eof(pospo);
700bA                  leave;
700bA                endif;
700aA                exsr WriteAns;
700bA              enddo;
700bA            else;
700aA              exsr WriteAns;
700bA            endif;
750aA          when pcmd = '*RANDOMC';
750aA            exsr UpdateAns;
700aA          when pcmd = '*PORCVCH'
700cD               //or pcmd = '*POEXCPCH';
700cM               or pcmd = '*POEXCPC';
700bA            if pSuperPo <> ' ' and q1_hitype <> 'ITM';
700bA              // get all po's for the super po
700bA              setll (gswhse: pSuperPo) pospo;
700bA              dow not %eof(pospo);
700bA                reade (gswhse: pSuperPo) pospo;
700bA                if %eof(pospo);
700bA                  leave;
700bA                endif;
700bA                exsr UpdateAns;
700bA              enddo;
700bA            else;
700aA              exsr UpdateAns;
700bA            endif;
700aA          other;
700aA            // Write record
700cA            exsr WriteAns;
700aA        endsl;
700aA      endif;

700aA      i = woEnd;
         enddo;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  EditAns    Edit answer
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr EditAns;

700aA    // need the question#
700bA    if %subst(idchar:1:1) = 'q';
700aA      q# = %DEC( %XLATE('q*,':'   ':idchar) : 5 : 0 );
700bA      exec sql select * into :hirec
700bA               from haccpq
700bA               where hiseq# = :q#;
700bA      if sqlstt = sqlSuccess;
700bA        // check for required answer;
740cD        //if q1_hireqd = 'Y' and ans = ' ';
740cM        if q1_hireqd = 'Y' and ans = ' ' and q1_hipc <> 'R';
700bA          pErrmsg = 'Answer Required for ' + %trimr(q1_hiqstn);
700bD          //return;
700bA        endif;
700bA      endif;
700bA    endif;


700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  UpdateAns    Update answer
     *----------------------------------------------------------------

      /free
       begsr UpdateAns;

700bA    // mark the original record as obsolete if the answer has changed
700bA    if psuperpo <> ' ';
700bA      exec sql select * into :haccplogck
700bA               from haccplog
700bA               where hlwhse = :gswhse
700bA                 and hlpo   = :pupo
700bA                 and hlseq# = :q#
700bA                 and hlexpts = '0001-01-01-00.00.00.000000'
700bA                 and hlobsolete <> 'Y';
700bA    else;
700bA      // we only allow an update to the last answered question on
700bA      // questions setup as every time - code 4 frequency
700bA      if q1_hifreq = '4';
700bA        exec sql select * into :haccplogck
700bA                 from haccplog
700bA                 where hlwhse = :gswhse
700bA                   and hlpo   = :ppo
700bA                   and hlseq# = :q#
700bA                   and hlexpts = '0001-01-01-00.00.00.000000'
700bA                   and hlobsolete <> 'Y'
700bA                 order by hladdts desc
700bA                 fetch first row only;
700bA      else;
700bA        exec sql select * into :haccplogck
700bA                 from haccplog
700bA                 where hlwhse = :gswhse
700bA                   and hlpo   = :ppo
700bA                   and hlseq# = :q#
700bA                   and hlexpts = '0001-01-01-00.00.00.000000'
700bA                   and hlobsolete <> 'Y';
700bA      endif;
700bA    endif;
700bA    if sqlstt = sqlSuccess;
700bA      // if the answer has changed then we need to obsolete the old one
700bA      answerchanged = *off;
700bA      select;
700bA        when q1_hiatyp = '2';
700bA          if ck_hldata = 'Yes' and ans = 'OFF' or
740cA             ck_hldata = 'Yes' and ans = 'HDNCHLD' or
740cA             ck_hldata = 'No' and ans = 'HDNCHLD' or
700bA             ck_hldata = 'No' and ans = 'ON';
700bA            answerchanged = *on;
700bA          endif;
700bA        other;
700bA          if ck_hldata <> ans;
700bA            answerchanged = *on;
700bA          endif;
700bA      endsl;
700bA      if answerchanged;
700bA        exsr zzgettime;
700bA        exec sql update haccplog
700bA                 set hlchgts = :CurrStampsys,
700bA                     hlchguc = :Currstampuc,
700bA                     hlchgcpgm = :#prog,
700bA                     hlchgjpgm = :#prog,
700bA                     hlchgeusr = :#user,
700bA                     hlobsolete = 'Y'
700bA                 where hlwhse = :ck_hlwhse
700bA                     and hlpo = :ck_hlpo
700bA                     and hlposeq = :ck_hlposeq
700bA                     and hllcns = :ck_hllcns
700bA                     and hlseq# = :ck_hlseq#
700bA                     and hldata = :ck_hldata
700bA                     and hlobsolete <> 'Y';
700bA        if sqlstt = sqlSuccess;
700bA          exsr writeans;
700bA        endif;
700bA      endif;
700bA    endif;
       endsr;
      /end-free
700aA*----------------------------------------------------------------
700aA*  WriteAns    Write answer
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr WriteAns;

700aA    // load fields for log file
700aA    hlwhse = gswhse;
700aA    hlseq# = q#;
700aA    hlpcmd = pcmd;
700aA    hllevl = q1_hilevl;
700aA    hltype = q1_hitype;
700aA    select;
700aA      when q1_hiatyp = '2';
740cA        select;
740cA          when ans = 'ON';
740cD            //if ans = 'ON';
700aA            hldata = 'Yes';
740cA          when ans = 'OFF';
740cD            //else;
700aA            hldata = 'No';
740cA          when ans = 'HDNCHLD';
700aA            hldata = ans;
740cD        //endif;
740cA        endsl;
700aA      other;
700aA        hldata = ans;
700aA    endsl;
700aA    hlspo  = psuperpo;
700bA    if psuperpo <> ' ' and q1_hitype <> 'ITM';
700aA      hlpo   = pupo;
700bA    else;
700aA      hlpo   = ppo;
700bA    endif;
700bA    if psuperpo <> ' ' and q1_hitype <> 'ITM';
700aA      exec sql select * into :phrec
700aA           from pohdr
700aA           where phwhse = :gswhse
700aA             and phpo   = :pupo;
700bA    else;
700aA      exec sql select * into :phrec
700aA           from pohdr
700aA           where phwhse = :gswhse
700aA             and phpo   = :pPO;
700bA    endif;
700aA    If sqlstt = sqlSuccess;
700aA      hlname = phvnam;
700aA      hlcust = phven;
700aA    else;
700aA      hlname = ' ';
700aA      hlcust  = 0;
700aA    endif;
700aA    // load po seq & item if item type question or item exceptions
700aA    select;
700aA      when q1_hilevl = 'REXI';
700aA        hlitem  = pitem;
700aA        hlposeq = pposeq;
700dA      when q1_hilevl = 'RCVL';
700dA        hlitem  = pitem;
700dA        hlposeq = pposeq;
700aA      when q1_hitype = 'ITM' and q1_hilevl = 'RCVI';
700aA        hlitem  = pitem;
700aA        hlposeq = pposeq;
700aA      when q1_hitype = 'CAT' and q1_hilevl = 'RCVI';
700aA        hlitem  = 'CAT=' + q1_hicode;
700aA        hlposeq = pposeq;
730aA      when q1_hitype = 'DPT' and q1_hilevl = 'RCVI' and q1_hifreq = '1';
730aA        hlitem  = pitem;
730aA        hlposeq = pposeq;
700aA      when q1_hitype = 'DPT' and q1_hilevl = 'RCVI';
700aA        hlitem  = 'Dept=' + q1_hicode;
700aA        hlposeq = pposeq;
710aA      when q1_hifreq = '4' and q1_hitype = 'ALL' and q1_hilevl = 'RCVI';
710aA        hlitem  = pitem;
710aA        hlposeq = pposeq;
720bA      when q1_hifreq = '1' and q1_hitype = 'ALL' and q1_hilevl = 'RCVI';
720bA        hlitem  = pitem;
720bA        hlposeq = pposeq;
700aA      other;
700aA        hlitem  = ' ';
700aA        hlposeq = 0;
700aA    endsl;
740dM    if q1_hilevl = 'RCVV'
740dA       or q1_hilevl = 'RCVF';
740aA      hllcns  = ' ';
740aA    else;
700aA      hllcns  = plcns;
740aA    endif;
700aA    hlrte   = ' ';
700aA    hlord  = 0;
700aA    hlcord = 0;
700aA    hloseq = 0;
700aA    if wo = 'true';
700aA      hlwarn  = 'Y';
700aA    else;
700aA      hlwarn  = ' ';
700aA    endif;
700aA    if q1_hiatyp = '3';
700aA      exec sql select * into :hvrec
700aA           from haccpv1
700aA           where hvwhse = :gswhse
700bA             and hvactive = 1
700aA             and hvseq# = :q#
700aA             and hvt3vl = :ans;
700aA      if sqlstt = sqlSuccess;
700aA        hlvsq# = hvvsq#;
700aA      else;
700aA        hlvsq#  = 0;
700aA      endif;
700aA    else;
700aA      hlvsq#  = 0;
700aA    endif;
700aA    exsr zzgettime;
700aA    hladdts = currstampsys;
700aA    hladduc = currstampuc;
700aA    hladdcpgm = ppgm;
700aA    hladdjpgm = #prog;
700aA    hladdeusr = puser;
700aA    hlchgts = *loval;
700aA    hlchguc = *loval;
700aA    hlchgcpgm = ' ';
700aA    hlchgjpgm = ' ';
700aA    hlchgeusr = ' ';
700aA    hlexpts = *loval;
700aA    hlexpuc = *loval;
700aA    hlexpjusr = ' ';

740cA    if ans = 'HDNCHLD';
740cA      hlobsolete = 'H';
740cA    else;
700aA      hlobsolete = ' ';
740cA    endif;
720aA    hlstop = 0;
700aA    exec sql insert into haccplog values(:hlrec);
700aA  endsr;
700aA /end-free
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZGETTIME Get Timestamp information.
700aA*
700aA*----------------------------------------------------------------
700aA /free
700aA  begsr zzgettime;
700aA    getmicrotime(currstampuc:currstampsys);
700aA  endsr;
700aA /end-free

