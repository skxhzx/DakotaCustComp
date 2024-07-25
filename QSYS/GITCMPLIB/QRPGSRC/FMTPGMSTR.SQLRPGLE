417cA /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FMTPGMSTR    Format program string
     *  16 December 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    12/16/09  DAS  6.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D glosess       e ds

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D separator       s              1
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session id
     *      pUser       User
     *      pPgm        Program name being called
     *      pDict       Dictionary
     *      pName__     Parameter name
     *      pValue__    Parameter value
     *
     *    Returned Parameters
     *      pPgmStr     Redirection program string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pPgmStr          99
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pPgm             10
     C                   parm                    pDict            10
     C                   parm                    pName01          10
     C                   parm                    pValue01         20
     C                   parm                    pName02          10
     C                   parm                    pValue02         20
     C                   parm                    pName03          10
     C                   parm                    pValue03         20
     C                   parm                    pName04          10
     C                   parm                    pValue04         20
     C                   parm                    pName05          10
     C                   parm                    pValue05         20
     C                   parm                    pName06          10
     C                   parm                    pValue06         20
     C                   parm                    pName07          10
     C                   parm                    pValue07         20
     C                   parm                    pName08          10
     C                   parm                    pValue08         20
     C                   parm                    pName09          10
     C                   parm                    pValue09         20
     C                   parm                    pName10          10
     C                   parm                    pValue10         20

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;

         // Get session info.

         exec sql
           select *
           into :glosess
           from glosess
           where gssessid = :pSessId;

         If sqlstt <> sqlSuccess;
           pPgmStr = '(FMTPGMSTR) Error getting session info';
           return;
         endif;

         // Sent user must match session user

         If pUser <> gsuser;
           pPgmStr = '(FMTPGMSTR) User mismatch';
           return;
         endif;

         // Format program string

         pPgmStr = %trimr(pDict) + '.'
                 + %trimr(pPgm);

         separator = '?';

         if pName01 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName01) + '=' + %trimr(pValue01);
            separator = '&';
         endif;

         if pName02 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName02) + '=' + %trimr(pValue02);
            separator = '&';
         endif;

         if pName03 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName03) + '=' + %trimr(pValue03);
            separator = '&';
         endif;

         if pName04 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName04) + '=' + %trimr(pValue04);
            separator = '&';
         endif;

         if pName05 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName05) + '=' + %trimr(pValue05);
            separator = '&';
         endif;

         if pName06 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName06) + '=' + %trimr(pValue06);
            separator = '&';
         endif;

         if pName07 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName07) + '=' + %trimr(pValue07);
            separator = '&';
         endif;

         if pName08 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName08) + '=' + %trimr(pValue08);
            separator = '&';
         endif;

         if pName09 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName09) + '=' + %trimr(pValue09);
            separator = '&';
         endif;

         if pName10 <> ' ';
            pPgmStr = %trimr(pPgmStr) + separator
                    + %trimr(pName10) + '=' + %trimr(pValue10);
            separator = '&';
         endif;


         return;
      /end-free
