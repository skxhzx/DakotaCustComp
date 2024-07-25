417cA /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ER610MRC     MRC Task Summary - Main
     *  19 November 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    11/19/09  DAS  6.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptione   if   e           k disk
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D forever         s               n   inz(*on)
     D gDebug          s               n   inz(*on)
     D gFDate          s              8  0
     D gReturn         s              8
     D gTDate          s              8  0
     D gVoice          s              1

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * OPTIONE *USER Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N)
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Voice Module? (Y/N)
     *    OPZORD  -  Zone or Department. (Z/D)
     *    OPTBD   -  Tote/Box/Drop? (Y/N)
     *
     *----------------------------------------------------------------
     D opedta          ds
     D  OPMAN                  1      1
     D  OPNXTE                 2      6  0
     D  OPVYN                  7      7
     D  OPZORD                 8      8
     D  OPTBD                  9      9

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.cvtcase

     D er610clmrc      pr                  extpgm('ER610CLMRC')
     D  zWhse                         3    const
     D  zUser                        10    const
     D  zEmp#                         5    const
     D  zShift                        6    const
     D  zCrew                         6    const
     D  zFDate                        8    const
     D  zFTime                        6    const
     D  zTDate                        8    const
     D  zTTime                        6    const
     D  zVoice                        1    const
     D  zMerge                        1    const
     D  zSessId                      40    const
     D  zReturn                       8

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D cvt2Upper       pr           500
     D  zIn                         500    const

     D wrtDebugParms   pr
     D  zMessage                     80    const
     D  zSessId                      40    const
     D  zWhse                         3    const
     D  zUser                        10    const
     D  zEmp#                         5    const
     D  zShift                        6    const
     D  zCrew                         6    const
     D  zFDate                        8    const
     D  zFTime                        6    const
     D  zTDate                        8    const
     D  zTTime                        6    const
     D  zMerge                        1    const

     D zzChk           pr
     D  zMessage                     80
     D  zSessId                      40
     D  zWhse                         3  0
     D  zUser                        10
     D  zEmp#                         5  0
     D  zShift                        6
     D  zCrew                         6
     D  zFDate                        8
     D  zFTime                        6  0
     D  zTDate                        8
     D  zTTime                        6  0
     D  zMerge                        1
     D  zrFDate                       8  0
     D  zrTDate                       8  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pWhse       Warehouse
     *      pUser       User
     *      pEpm#       Employee number
     *      pShift      Shift
     *      pCrew       Crew
     *      pFDate      From date (mmddyy or mm/dd/yy)
     *      pFTime      From time
     *      pTDate      To date (mmddyy or mm/dd/yy)
     *      pTTime      To time
     *      pMerge      Merge Pieces option
     *
     *    Returned Parameters
     *      pMessage    Return error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         80
     C                   parm                    pSessId          40
     C                   parm                    pWhse             3 0
     C                   parm                    pUser            10
     C                   parm                    pEmp#             5 0
     C                   parm                    pShift            6
     C                   parm                    pCrew             6
     C                   parm                    pFDate            8
     C                   parm                    pFTime            6 0
     C                   parm                    pTDate            8
     C                   parm                    pTTime            6 0
     C                   parm                    pMerge            1

      /free
        *inlr = *on;
        pMessage = ' ';

        // Convert character fields to upper case

        pUser  = cvt2Upper(pUser);
        pShift = cvt2Upper(pShift);
        pCrew  = cvt2Upper(pCrew);
        pMerge = cvt2Upper(pMerge);

        // Verify parameters

        zzChk(pMessage :
              pSessId:
              pWhse:
              pUser:
              pEmp#:
              pShift:
              pCrew:
              pFDate:
              pFTime:
              pTDate:
              pTTime:
              pMerge:
              gFDate:
              gTDate);

        // Write out debug informaiton

        if gDebug or pMessage <> ' ';
          wrtDebugParms(pMessage :
                        pSessId:
                        %editc(pWhse:'X'):
                        pUser :
                        %editc(pEmp#:'X'):
                        pShift :
                        pCrew :
                        pFDate:
                        %editc(pFTime:'X'):
                        pTDate:
                        %editc(pTTime:'X'):
                        pMerge);
        endif;

        if pMessage <> ' ';
          return;
        endif;

        // Get voice option

         chain(n) ('*USER': pWhse) optione;

         if %found and opvyn = 'Y';
           gVoice = 'Y';
         else;
           gVoice = 'N';
         endif;

        // Call program to create work file data

        monitor;
           er610clmrc(%editc(pWhse:'X'):
                      pUser:
                      %editc(pEmp#:'X'):
                      pShift:
                      pCrew:
                      %editc(gFDate:'X'):
                      %editc(pFTime:'X'):
                      %editc(gTDate:'X'):
                      %editc(pTTime:'X'):
                      gVoice:
                      pMerge:
                      pSessId:
                      gReturn);
        on-error;
          pMessage = '(ER610MRC) Error calling ER610CLMRC';
          return;
        endmon;

        if gReturn <> ' ';
          pMessage = '(ER610MRC) Error '
                   + %trim(gReturn)
                   + ' returned from ER610CLMRC ';
        endif;

        return;
      /end-free

     *----------------------------------------------------------------
     *  cvt2Upper  Convert to upper case
     *----------------------------------------------------------------

     p cvt2Upper       b
     d cvt2Upper       pi           500
     d  sIn                         500    const

     * Local variables

     d  sOut           s            500

      /free

         cvtCase('*LOW2UPR': sIn: sOut);
         return sOut;

      /end-free
     p cvt2Upper       e

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

     p wrtDebugParms   b
     d wrtDebugParms   pi
     D  sMessage                     80    const
     D  sSessId                      40    const
     D  sWhse                         3    const
     D  sUser                        10    const
     D  sEmp#                         5    const
     D  sShift                        6    const
     D  sCrew                         6    const
     D  sFDate                        8    const
     D  sFTime                        6    const
     D  sTDate                        8    const
     D  sTTime                        6    const
     D  sMerge                        1    const

      /free

         bdtype = 'PARMS';

         bdvalues = '&pMessage=' + %trimr(sMessage)
                  + '&pWhse=' + sWhse
                  + '&pUser=' + %trimr(sUser)
                  + '&pEmp#=' + sEmp#
                  + '&pShift=' + %trimr(sShift)
                  + '&pCrew=' + %trimr(sCrew)
                  + '&pFDate=' + sFDate
                  + '&pFTime=' + sFTime
                  + '&pFDate=' + sFDate
                  + '&pFTime=' + sTTime
                  + '&pMerge=' + sMerge
                  + '&pSessId=' + %trimr(sSessId)
         ;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       return;
      /end-free

     p wrtDebugParms   e

     *----------------------------------------------------------------
     *  zzChk   Verify parameters
     *----------------------------------------------------------------

     p zzChk           b
     d zzChk           pi
     D  sMessage                     80
     D  sSessId                      40
     D  sWhse                         3  0
     D  sUser                        10
     D  sEmp#                         5  0
     D  sShift                        6
     D  sCrew                         6
     D  sFDate                        8
     D  sFTime                        6  0
     D  sTDate                        8
     D  sTTime                        6  0
     D  sMerge                        1
     D  rFDate                        8  0
     D  rTDate                        8  0

     * Local variables

     d  gsUser         s             10
     d  gsWhse         s              3  0
     d  tmp5n          s              5  0
     d  tmp6a          s              6

      /free

         // Get session info.

         exec sql select gsuser, gswhse
                  into  :gsuser, :gswhse
                  from glosess
                  where gssessid = :sSessId;

         If sqlstt <> sqlSuccess;
           sMessage = '(ER610MRC) Error retrieving session info - '
                    + sqlstt;
           return;
         endif;

         // If warehouse is zero, set to session warehouse.

         if sWhse = 0;
           // If session warehouse is zero, throw error.
           if gswhse = 0;
             sMessage = '(ER610MRC) No warehouse defined for the session';
             return;
           endif;
           // Otherwise, set warehouse to session warehouse.
           sWhse = gswhse;
         endif;

         // Verify warehouse matches session warehouse

         if sWhse <> gswhse;
           sMessage = '(ER610MRC) Warehouse mismatch';
           return;
         endif;

         // User cannot be blank

         if sUser = ' ';
           sMessage = '(ER610MRC) User not sent';
           return;
         endif;

         // Verify user matches session user

         if sUser <> gsuser;
           sMessage = '(ER610MRC) User mismatch';
           return;
         endif;

         // One value must be sent of Emp#/Shift/Crew

         if sEmp# = 0 and sShift = ' ' and sCrew = ' ';
             sMessage = '(ER610MRC) One value must be sent of '
                      + 'Shift, Crew, Employee#';
             return;
         endif;

         // Only one value can be sent of Emp#/Shift/Crew

         if sEmp# <> 0 and (sShift <> ' ' or sCrew <> ' ')
            or sShift <> ' ' and (sEmp# <> 0 or sCrew <> ' ')
            or sCrew <> ' ' and (sEmp# <> 0 or sShift <> ' ');
             sMessage = '(ER610MRC) Only one value can be sent of '
                      + 'Shift, Crew, Employee#';
             return;
         endif;

         // Verify Employee #

         if sEmp# <> 0;
           exec sql select usemp#
                  into  :tmp5n
                  from piruser
                  where usemp# = :sEmp#;
           If sqlstt <> sqlSuccess;
             sMessage = '(ER610MRC) Invalid employee number ('
                      + %char(sEmp#) + ')';
             return;
           endif;
         endif;

         // Verify Shift

         if sShift <> ' ';
           exec sql select shcode
                    into  :tmp6a
                    from shift
                    where shwhse = :sWhse
                      and shwhdp = ' '
                      and shcode = :sShift;
           If sqlstt <> sqlSuccess;
             sMessage = '(ER610MRC) Invalid Shift ('
                      + %trimr(sShift) + ')';
             return;
           endif;
         endif;

         // Verify Crew

         if sCrew <> ' ';
           exec sql select crcode
                    into  :tmp6a
                    from crew
                    where crwhse = :sWhse
                      and crcode = :sCrew;
           If sqlstt <> sqlSuccess;
             sMessage = '(ER610MRC) Invalid Crew ('
                      + %trimr(sCrew) + ')';
             return;
           endif;
         endif;

         // Verify From Date

         if %scan('/': sFDate) = 0;
           monitor;
             rFDate = %dec(%char(%date(sFDate:*mdy0):*iso0):8:0);    // mmddyy
           on-error;
             pMessage = '(ER610MRC) Invalid From date - '
                      + sFDate;
             return;
           endmon;
         else;
           monitor;
             rFDate = %dec(%char(%date(sFDate:*mdy/):*iso0):8:0);   // 'mm/dd/yy
           on-error;
             pMessage = '(ER610MRC) Invalid From date - '
                      + sFDate;
             return;
           endmon;
         endif;

         // Verify To Date

         if %scan('/': sTDate) = 0;
           monitor;
             rTDate = %dec(%char(%date(sTDate:*mdy0):*iso0):8:0);    // mmddyy
           on-error;
             pMessage = '(ER610MRC) Invalid To date - '
                      + sTDate;
             return;
           endmon;
         else;
           monitor;
             rTDate = %dec(%char(%date(sTDate:*mdy/):*iso0):8:0);   // 'mm/dd/yy
           on-error;
             pMessage = '(ER610MRC) Invalid To date - '
                      + sTDate;
             return;
           endmon;
         endif;


       return;
      /end-free

     p zzChk           e
