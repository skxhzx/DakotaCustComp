      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKIUSE2J  CHKIUSE2 with JSON return - Pgm for CHKIUSE2J func
     *  30 April 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    04/30/14  DAS  6.50
     *      - Created.
     *
650aA*    05/02/14  DAS  6.50b
     *      - Added bfcdebug logic
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650bAFbfcdbgflg if   e           k disk    usropn
650bAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCmd           s              8    varying
     D  pWhse          s              3p 0
     D  pRtid          s              5    varying
     D  pSessId        s             40    varying
     D  pDict          s             10    varying
     D  pPgm           s             10    varying
     D  pUser          s             10    varying
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dpCombo         s             20
     d cmd             s              8
     d rtid            s              5
     d sessid          s             40
     d user            s             10

     d irtn            s              8
     d iutext10        s             10
     d iutext30        s             30
     d iucmd           s              8
     d iupgm           s             20
     d iuuser          s             10
     d iuSessId        s             40
     d iuJobName       s             10
     d iuJobNbr        s              6
     d iuJobUser       s             10
     d iuStamp         s             26

650bAD dbgflgExists    s               n
650bAD debug           s               n

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.chkiuse2

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        CHKIUSE2 command
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCmd
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pOutStr

      /free

        *inlr = *on;

650aA    if dbgflgExists;
650aA      chain(e) (#pgm) bfcdbgflg;
650aA      if %found(bfcdbgflg);
650aA        debug = (bdfflag = 1);
650aA      else;
650aA        debug = *off;
650aA      endif;
650aA    endif;

        if debug;
          exsr wrtDebugParms;
        endif;

         cmd = pCmd;
         rtid = pRtid;
         sessid = pSessid;
         user = pUser;
         dpCombo = %trim(pDict) + '.' + pPgm;

         chkiuse2 (cmd: pWhse: rtid:
                   dpCombo: user: sessId: irtn:
                   iuText10: iuText30: iuCmd: iuPgm:
                   iuUser: iuSessId: iuJobName: iuJobNbr:
                   iuJobUser: iuStamp);
650aA
650aA  //   pOutStr = '{"test3":"chkiuse2jafter",'
650aA  //           +  '"rtn":"' + %trim(irtn) + '"}';
650aA  //   return;

         // Build JSON string to return

         pOutStr = '{'
                 +  '"irtn":"' + %trimr(irtn) + '",'
                 +  '"itxt10":"' + %trimr(iuText10) + '",'
                 +  '"itxt30":"' + %trimr(iuText30) + '",'
                 +  '"icmd":"' + %trimr(iuCmd) + '",'
                 +  '"ipgm":"' + %trimr(iuPgm) + '",'
                 +  '"isessid":"' + %trimr(iuSessId) + '",'
                 +  '"ijobnam":"' + %trimr(iuJobName) + '",'
                 +  '"ijobnbr":"' + %trimr(iuJobNbr) + '",'
                 +  '"ijobusr":"' + %trimr(iuJobUser) + '",'
                 +  '"istamp":"' + %trimr(iuStamp) + '"'
                 +  '}';

        return;
        if debug;
          exsr wrtDebugParms;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

650aA    open(e) bfcdbgflg;
650aA    if %error;
650aA      dbgflgExists = *off;
650aA    else;
650aA      dbgflgExists = *on;
650aA    endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  wrtDebugParms  Write out debug parm record
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'sID:' + %trimr(pSessid) + ', '
                  + 'Cmd:' + %trimr(pCmd) + ', '
                  + 'Whs:' + %char(pWhse) + ', '
                  + 'Rtid:' + %trimr(pRtid) + ', '
                  + 'Usr=' + %trimr(pUser)
                  + 'Dct:' + %trimr(pDict) + ', '
                  + 'Pgm:' + %trimr(pPgm) + ', '
                  + 'Out:' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
