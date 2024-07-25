      /copy *libl/qcopysrc,hspecs
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GLOAUTHDB    Authorize DB source
     *  02 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    06/02/10  DAS  6.10
     *      - Created.
     *      - Based on original program pirsqlpgm/authdb.
     *      - Revised to look at default option of DB source.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $code           s              2    inz(' ')
500bAD cqqty1          s              7  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pDBid   - Databas id
     *      pUser   - User code
     *
     *    Returned Parameters
     *      pFlag   - 0 = Not authorized to use
     *                1 = Authorized to use
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pDBid            10
     C                   parm                    pUser            10
     C                   parm                    pFlag             1 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // See if user is authorized to use database.

         // This statement will count a maximum of 1 record if the
         // user is authorized to use the database. This value
         // will be put into the pFlag value.

         exec sql SELECT count(*) INTO :pFlag
                  FROM glodbsrc
                  WHERE gdsid = :pDBid
                    AND (EXISTS (SELECT guguser FROM glousrgrp
                                 WHERE guguser=:pUser AND guggroup='ALL'
                                )
                         OR
                         EXISTS (SELECT gdssdbid FROM glodbsec
                                 WHERE (gdssdbid=gdsid
                                        AND gdsstype='G'
                                        AND gdsscode='ALL'
                                       )
                                    OR (gdssdbid=gdsid
                                        AND gdsstype='U'
                                        AND gdsscode=:pUser
                                       )
                                    OR (gdssdbid=gdsid
                                        AND gdsstype='G'
                                        AND EXISTS
                                            (SELECT guguser
                                             FROM glousrgrp
                                             WHERE guguser=:pUser
                                               AND guggroup=gdsscode
                                            )
                                       )
                                )
                        );

         return;

      /end-free
