      /copy qcopysrc,hspecs
710aAH DFTACTGRP(*NO)
710aAH Bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *
     *  SETSESSINF   Set session info
     *  20 April 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    04/20/10  DAS  6.10
     *      - Created.
     *
610aA*    04/30/10  DAS  6.10a
     *      - Added fields gstouch, gsmenu.
     *      - Revised to set location to blank if an '*' is found.
     *        If not used, it will normally contain '*NONE*'. Don't
     *        want to take the chance that the '*' will cause a
     *        problem in the browser.
     *
610bA*    05/24/10  DAS  6.10a
     *      - Added logic to get default menu from db source.
     *
640aA*    06/27/11  DAS  6.40
     *      - Added field GSREL.
     *
700aA*    08/20/15  DAS  7.00
     *      - Revised to get warehouse description from WAREHS
     *        instead of from GLOWHSE.
     *
700bA*    12/08/15  DAS  7.00b
     *      - Added debug logic
     *
700cA*    06/08/16  DAS  7.00c
     *      - Revised to assume record exists because BFCSIGNON2
     *        creates the glosess record. This was done because
     *        a failed update will not write records to the job log
     *        but a duplicate key insert will write recs to job log.
     *      - For readability, moved code without commenting.
     *
720 A*    01/23/18  KDE  7.20
     *      - Add code to use getmicrotime instead of sql time
     *        Getmicrotime was changed to return proper time based
     *        on use of TimeZone/400
     *
730aA*    11/27/19  DAS  7.30a
     *      - Revised to extract warehouse number from last 3 characters
     *        of db id. If number found, it will be used as the
     *        session warehouse, otherwise we will use the default
     *        warehouse for the user.
     *
740aA*    04/15/20  KDE  7.40a
     *      - Revised to create all uppercase session record when one coming
     *        up has mixed case
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

700bAFbfcdbgflg if   e           k disk    usropn
700bAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.getuser
720 A /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

710aAD GoCmd           PR            10I 0 Extproc('system')
710aAD   CmdString                     *   Value
710aAD                                     Options(*String)
710aA
710aAD NullString      C                   -1
710aAD Success         C                   0
710aAD ObjNotFound     C                   'CPF9801'
710aA
710aAD Errmsgid        S              7    Import('_EXCP_MSGID')
710aAD Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

720 AD CurrStampsys    s               z
720 AD CurrStampuc     s               z
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

700bAD dbgflgExists    s               n
700bAD debug           s               n
700bAD debugAfter      s               n
700bAD debugBefore     s               n
700bAD debugLoc        s              1
     d sq              C                   x'27'

710aAD tznexe          s             10    inz('TZNEXE')

730aAD alphaWhse       s              3
730aAD dbWhse          s              3  0
730aAD idlen           s              3  0
730aAD whseFound       s               n

740aA*----------------------------------------------------------------
740aA*  Translation strings
740aA*----------------------------------------------------------------
740aA
740aAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
740aAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             10
     D  pDtaSrc        s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser        User
     *      pDict        Dictionary
     *      pPgm         Program
     *      pDtaSrc      Data source
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pDtaSrc

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

700bA    debug = *off;
700bA    debugBefore = *off;
700bA    debugAfter = *off;
700bA    if dbgflgExists;
700bA      chain(e) (#pgm) bfcdbgflg;
700bA      if %found(bfcdbgflg);
700bA        select;
700bA          when bdfflag = 1;
700bA            debug = *on;
700bA            debugAfter = *on;
700bA          when bdfflag = 2;
700bA            debug = *on;
700bA            debugBefore = *on;
700bA          when bdfflag = 3;
700bA            debug = *on;
700bA            debugBefore = *on;
700bA            debugAfter = *on;
700bA        endsl;
700bA      endif;
700bA    endif;

700bA    if debugBefore;
700bA      debugLoc = 'B';
           gswhse = 0;
700bA      exsr wrtDebugParms;
700bA    endif;

        // Get user information

        getUser(pUser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        // Set field values

720 D   //exec sql values (current timestamp,
720 D   //                 (current timestamp - current timezone))
720 D   //         into :gstchts, :gstchuc;
720 A   getmicrotime(currstampuc:currstampsys);
720 A   gstchts = currstampsys;
720 A   gstchuc = currstampuc;

        gssessid = pSessId;
        gsuser = pUser;
        if e$init = ' ';
          gsusername = %trim(e$fnam) + ' ' + %trim(e$lnam);
        else;
          gsusername = %trim(e$fnam) + ' ' + %trim(e$init) + ' '
                     + %trim(e$lnam);
        endif;

730aD   //gswhse = e$whse;
730aA   exsr GetSessWhse;
640aA   gsrel = 'EQ';

700aD   //exec sql select gwname into :gswhsedesc
700aD   //         from glowhse
700aD   //         where gwwhse = :gswhse;

730aD   //exec sql select whdesc into :gswhsedesc
730aD   //         from warehs
730aD   //         where whcode = :gswhse;
730aD
730aD   //If sqlstt <> sqlSuccess;
730aD   //  gswhsedesc = ' ';
730aD   //endif;

        gslanguage = e$lng;
        gsdsid = pDtaSrc;

        getClient(gsclient: gslocation);
610aA   if %scan('*': gslocation) > 0;
610aA     gslocation = ' ';
610aA   endif;

610aA   gstouch = 'N';

610cA   // Determine Main menu
610cA
610cA     // First see if a default menu is defined for user
610cA
610cA     exec sql select gumenu into :gsmenu
610cA              from glousr
610cA              where guuser = :pUser;
610bA     If sqlstt <> sqlSuccess;
610aA       gsmenu = ' ';
610bA     endif;
610cA
610cA     // If not, see if a default menu is defined for data source
610cA
610cA     if gsmenu = ' ';
610bA       exec sql select gdsmenu into :gsmenu
610bA                from glodbsrc
610bA                where gdsid = :pDtaSrc;
610bA       If sqlstt <> sqlSuccess;
610aA         gsmenu = ' ';
610bA       endif;
610cA     endif;
610cA
610cA     // If not, set to MAIN
610bA
610bA     If gsmenu = ' ';
610aA       gsmenu = 'MAIN';
610bA     endif;

        // Update record (should have been created with BFCSIGNON2)

        gschgts = gstchts;
        gschguc = gstchuc;
        gschgcdct = pDict;
        gschgcpgm = pPgm;
        gschgjpgm = #pgm;
        gschgemp  = e$emp#;
        gschgeusr = pUser;
        gschgcusr = #curruser;
        gschgjusr = #user;
        gschgjob  = #job;
        gschgnbr  = #jobnbr;

          exec sql update glosess
                 set gsuser = :pUser,
                     gsusername = :gsusername,
                     gswhse = :gswhse,
                     gswhsedesc = :gswhsedesc,
                     gsclient = :gsclient,
                     gslocation = :gslocation,
                     gslanguage = :gslanguage,
                     gstouch = :gstouch,
                     gsmenu = :gsmenu,
640aA                gsrel = :gsrel,
                     gsdsid = :gsdsid,
                     gschgts = :gschgts,
                     gschguc = :gschguc,
                     gschgcdct = :gschgcdct,
                     gschgcpgm = :gschgcpgm,
                     gschgjpgm = :gschgjpgm,
                     gschgemp  = :gschgemp,
                     gschgeusr = :gschgeusr,
                     gschgcusr = :gschgcusr,
                     gschgjusr = :gschgjusr,
                     gschgjob  = :gschgjob,
                     gschgnbr  = :gschgnbr,
                     gstchts = :gstchts,
                     gstchuc = :gstchuc
                 where gssessid = :pSessId;

740aD     //If sqlstt <> sqlSuccess;
740aM     If sqlstt = sqlSuccess;
740aA       if pSessId <> %xlate(xlower: xupper: pSessId);
740aA         // when mixed case we should also update all uppercase record
740aA     exec sql update glosess
740aA            set gsuser = :pUser,
740aA                gsusername = :gsusername,
740aA                gswhse = :gswhse,
740aA                gswhsedesc = :gswhsedesc,
740aA                gsclient = :gsclient,
740aA                gslocation = :gslocation,
740aA                gslanguage = :gslanguage,
740aA                gstouch = :gstouch,
740aA                gsmenu = :gsmenu,
740aA                gsrel = :gsrel,
740aA                gsdsid = :gsdsid,
740aA                gschgts = :gschgts,
740aA                gschguc = :gschguc,
740aA                gschgcdct = :gschgcdct,
740aA                gschgcpgm = :gschgcpgm,
740aA                gschgjpgm = :gschgjpgm,
740aA                gschgemp  = :gschgemp,
740aA                gschgeusr = :gschgeusr,
740aA                gschgcusr = :gschgcusr,
740aA                gschgjusr = :gschgjusr,
740aA                gschgjob  = :gschgjob,
740aA                gschgnbr  = :gschgnbr,
740aA                gstchts = :gstchts,
740aA                gstchuc = :gstchuc
740aA            where gssessid = upper(:pSessId);
740aA       endif;
          endif;

        // If error, try adding record

        If sqlstt <> sqlSuccess;

          gsaddts = gstchts;
          gsadduc = gstchuc;
          gsaddcdct = pDict;
          gsaddcpgm = pPgm;
          gsaddjpgm = #pgm;
          gsaddemp  = e$emp#;
          gsaddeusr = pUser;
          gsaddcusr = #curruser;
          gsaddjusr = #user;
          gsaddjob  = #job;
          gsaddnbr  = #jobnbr;

          exec sql insert into glosess
                 values(:pSessId,
                        :pUser,
                        :gsusername,
                        :gswhse,
                        :gswhsedesc,
                        :gsclient,
                        :gslocation,
                        :gslanguage,
                        :gsdsid,
610aA                   :gstouch,
610aA                   :gsmenu,
640aA                   :gsrel,
                        :gsaddts,
                        :gsadduc,
                        :gsaddcdct,
                        :gsaddcpgm,
                        :gsaddjpgm,
                        :gsaddemp,
                        :gsaddeusr,
                        :gsaddcusr,
                        :gsaddjusr,
                        :gsaddjob,
                        :gsaddnbr,
                        :gschgts,
                        :gschguc,
                        :gschgcdct,
                        :gschgcpgm,
                        :gschgjpgm,
                        :gschgemp,
                        :gschgeusr,
                        :gschgcusr,
                        :gschgjusr,
                        :gschgjob,
                        :gschgnbr,
                        :gstchts,
                        :gstchuc) ;

          If sqlstt <> sqlSuccess;
          endif;

740aA     // if session has mixed case then add an all uppercase record
740aA     if pSessId <> %xlate(xlower: xupper: pSessId);
740aA     exec sql insert into glosess
740aA            values(upper(:pSessId),
740aA                   :pUser,
740aA                   :gsusername,
740aA                   :gswhse,
740aA                   :gswhsedesc,
740aA                   :gsclient,
740aA                   :gslocation,
740aA                   :gslanguage,
740aA                   :gsdsid,
740aA                   :gstouch,
740aA                   :gsmenu,
740aA                   :gsrel,
740aA                   :gsaddts,
740aA                   :gsadduc,
740aA                   :gsaddcdct,
740aA                   :gsaddcpgm,
740aA                   :gsaddjpgm,
740aA                   :gsaddemp,
740aA                   :gsaddeusr,
740aA                   :gsaddcusr,
740aA                   :gsaddjusr,
740aA                   :gsaddjob,
740aA                   :gsaddnbr,
740aA                   :gschgts,
740aA                   :gschguc,
740aA                   :gschgcdct,
740aA                   :gschgcpgm,
740aA                   :gschgjpgm,
740aA                   :gschgemp,
740aA                   :gschgeusr,
740aA                   :gschgcusr,
740aA                   :gschgjusr,
740aA                   :gschgjob,
740aA                   :gschgnbr,
740aA                   :gstchts,
740aA                   :gstchuc) ;
740aA     endif;

        endif;

700bA   if debugAfter;
700bA     debugLoc = 'A';
700bA     exsr wrtDebugParms;
700bA   endif;

        return;

      /end-free

700bA*----------------------------------------------------------------
700bA*  *INZSR   Initialization subroutine
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  GetDbWhse    Get Database warehouse
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr GetDbWhse;

         dbWhse = 0;
         idLen = %len(%trimr(pDtaSrc));

         if idLen > 3;
           alphaWhse = %subst(pDtaSrc: idLen - 2: 3);
           monitor;
             dbWhse = %dec(alphaWhse: 3: 0);
           on-error;
             dbWhse = 0;
             leavesr;
           endmon;
         endif;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  GetSessWhse   Get session warehouse
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr GetSessWhse;


         // If db id ends with 3-digits,
         // Then treat as a warehouse number and use it
         // for the session warehouse.
         // Of course, warehouse must exist.

         exsr GetDbWhse;
         if dbWhse <> 0;
           gswhse = dbWhse;
           exsr GetWhseDesc;
           if whseFound;
             leavesr;
           endif;
         endif;

         // Otherwise, use user default warehouse

         gswhse = e$whse;
         exsr GetWhseDesc;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  GetWhseDesc   Get warehouse description
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr GetWhseDesc;

        exec sql select whdesc into :gswhsedesc
                 from warehs
                 where whcode = :gswhse;

        If sqlstt = sqlSuccess;
          whseFound = *on;
        else;
          whseFound = *off;
          gswhsedesc = ' ';
        endif;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  wrtDebugParms  Write out debug parm record
700bA*----------------------------------------------------------------
700bA
700bA /free
700bA  begsr wrtDebugParms;

        bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pDtaSrc:' + %trimr(pDtaSrc) + ', '
                  + 'gswhse:' + %char(gswhse) + ', '
                  + 'gsmenu:' + %trimr(gsmenu) + ', '
                  + 'gsclient:' + %trimr(gsclient) + ', '
                  + 'dbgloc:' + %trimr(debugLoc);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
