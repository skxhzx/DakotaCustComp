      /copy qcopysrc,hspecs
720 AH DFTACTGRP(*NO)
720 AH Bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *
     *  GETSESSINF   Get session info
     *  19 April 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    04/19/10  DAS  6.10
     *      - Created.
     *
610aA*    04/30/10  DAS  6.10a
     *      - Added fields pWhseName, pTouch, pMenu.
     *
650aA*    04/10/13  DAS  6.50a
     *      - Added fields pISize1, pISize2
     *
650bA*    10/29/13  DAS  6.50b
     *      - Added field pDbSrcId
     *
650cA*    12/19/13  DAS  6.50c
     *      - Added field pDbSrcCtxId
     *
720 A*    01/23/18  KDE  7.20
     *      - Add code to use getmicrotime instead of sql time
     *        Getmicrotime was changed to return proper time based
     *        on use of TimeZone/400
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D glosess       E ds
650cAD glodbsrc      E ds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

720 A*----------------------------------------------------------------
720 A* Function prototypes.
720 A*----------------------------------------------------------------
720 A
720 A /copy qcopysrc,p.bfcdteti

720 A*----------------------------------------------------------------
720 A*  Variables
720 A*----------------------------------------------------------------
720 A
720 AD CurrStampsys    s               z
720 AD CurrStampuc     s               z

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSessId        s             40
     D  pWhse          s              3p 0
610aAD  pWhseName      s             30
     D  pUser          s             10
     D  pEmpNbr        s              5p 0
     D  pEmpName       s             40
     D  pLanguage      s              2
     D  pClient        s             10
     D  pLocation      s             10
610aAD  pTouch         s              1
610aAD  pMenu          s             20
     D  pJob           s             10
     D  pJobNbr        s              6
     D  pJobUser       s             10
     D  pJobCurrUser   s             10
650aAD  pISize1        s              3p 0
650aAD  pISize2        s              3p 0
650bAD  pDbSrcId       s             10
650cAD  pDbSrcCtxId    s             30

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *
     *    Returned Parameters
     *      pWhse        Warehouse
610aA*      pWhseName    Warehouse name
     *      pUser        User code (upper case)
     *      pEmpNbr      Employee number
     *      pEmpName     Employee name
     *      pLanguage    Language
     *      pClient      Client Id
     *      pLocation    Location Id
610aA*      pTouch       Touch screen
610aA*      pMenu        Main menu
     *      pJob         Job name
     *      pJobNbr      Job number
     *      pJobUser     Job user
     *      pJobCurUser  Job Current user
650aA*      pISize1      Icon size for add/chg/del icons
650aA*      pISize2      Icon size for link icons
650bA*      pDbSrcId     Database source id
650cA*      pDbSrcCtxId  Database source spring-context id
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pWhse
610aAc                   parm                    pWhseName
     c                   parm                    pUser
     c                   parm                    pEmpNbr
     c                   parm                    pEmpName
     c                   parm                    pLanguage
     c                   parm                    pClient
     c                   parm                    pLocation
610aAc                   parm                    pTouch
610aAc                   parm                    pMenu
     c                   parm                    pJob
     c                   parm                    pJobNbr
     c                   parm                    pJobUser
     c                   parm                    pJobCurrUser
650aAc                   parm                    pISize1
650aAc                   parm                    pISize2
650bAc                   parm                    pDbSrcId
650cAc                   parm                    pDbSrcCtxId

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

650aA   // Icon sizes are hard coded for now.
650aA   if %parms >= 16;
650aA     pISize1 = 13;
650aA     pISize2 = 22;
650aA   endif;

        exec sql select * into :glosess
                 from glosess
                 where gssessid = :pSessId;

         If sqlstt = sqlSuccess;
           pWhse = gswhse;
610aA      pWhseName = gswhsedesc;
           pUser = gsuser;
           pEmpNbr = gsaddemp;
           pEmpName = gsusername;
           if pLanguage = ' ';
             pLanguage = 'EN';
           else;
             pLanguage = gslanguage;
           endif;
           pClient = gsclient;
           pLocation = gslocation;
610aA      pTouch = gstouch;
610aA      pMenu = gsmenu;
           pJob = gsaddjob;
           pJobNbr = gsaddnbr;
           pJobUser = gsaddjusr;
           pJobCurrUser = gsaddcusr;
         else;
           pWhse = 0;
           pWhseName= '** Session Info Not Found **';
           pUser = ' ';
           pEmpNbr = 0;
           pEmpName = pSessId;
           pLanguage = 'EN';
           pClient = ' ';
           pLocation = ' ';
610aA      pTouch = 'N';
610aA      pMenu = 'SQLSTT=' + sqlstt;
           pJob = #job;
           pJobNbr = #jobnbr;
           pJobUser = #user;
           pJobCurrUser = #curruser;
           gsdsid = ' ';
         endif;

        // Update Touched stamps

720 A   getmicrotime(currstampuc:currstampsys);
        exec sql update glosess
720 D        //  set gstchts = current timestamp,
720 D        //      gstchuc = current timestamp - current timezone
720 A            set gstchts = :currstampsys,
720 A                gstchuc = :currstampuc
                 where gssessid = :pSessId;

         If sqlstt = sqlSuccess;
         endif;

650bA   // Send back database source id if sent in
650bA   if %parms >= 18;
650bA     pDbSrcId = gsdsid;
650bA   endif;

650cA   // Send back database source spring-context id if sent in
650cA   if %parms >= 19;
650cA     pDbSrcCtxId = ' ';
650cA     if gsdsid <> ' ';
650cA       exec sql select * into :glodbsrc
650cA            from glodbsrc
650cA            where gdsid = :gsdsid;
650cA       If sqlstt = sqlSuccess;
650cA         pDbSrcCtxId = gdssrc;
650cA       endif;
650cA     endif;
650cA   endif;

        return;

      /end-free
