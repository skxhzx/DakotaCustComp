      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP('ILE')
     H BNDDIR('QC2LE':'BFCBND')
      *-----------------------------------------------------------------
      *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved by
      *   BFC Software, Inc.
      *-----------------------------------------------------------------
      *
      *  BFCUPDCOP    BFC - Update files Cop process
      *  16 February 2021
      *  Kenneth Elder
      *
      *    02/16/21  KDE  7.50
      *      - Created
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  File Specs
      *----------------------------------------------------------

      *----------------------------------------------------------
      /copy qcopysrc,p.bfcdteti

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

      *----------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D cflrec        E Ds                  Extname(CMPFILELOG)

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds
      *----------------------------------------------------------
      *  Time variables
      *----------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z
     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     d bReturn         s             10
     d cmdString       s          10000
      *----------------------------------------------------------
      *  Parameters
      *----------------------------------------------------------

     d pLib1           s             10
     d pLib2           s             10
     d pLib3           s             10

      *----------------------------------------------------------
      * Parameters
      *   Parameters:
      *     pLib1    -  PIRNFxxx library
      *     pLib2    -  Files library being updated
      *     pLib3    -  Latest Dakota source/library    (PIR740,
      *----------------------------------------------------------
     c     *entry        Plist
     c                   Parm                    pLib1
     c                   parm                    pLib2
     c                   parm                    pLib3

      *----------------------------------------------------------
      *  Main Line
      *----------------------------------------------------------
      /free
        *inlr = *on;

        // Run Compare File process
        cmdString = 'ADDLIBLE LIB(DSCOMPLIB)';
        returnCode = GoCmd(%trim(cmdString));
        // Clear CMPFILELOG
        cmdString = 'CLRPFM FILE(CMPFILELOG)';
        returnCode = GoCmd(%trim(cmdString));
        cmdString = 'BFCCMPFILE LIB1(' + %trim(pLib1) + ') LIB2(' +
                     %trim(pLib2) + ')';
        returnCode = GoCmd(%trim(cmdString));

        // Read Compare file log and take necessary action for differences
        // Reads and removes logicals first, then performs change physical
        // on physical files that are different
        sqlstmt = 'select * from CMPFILELOG ' +
                  'where CFLACTION=' + sq + 'DIFF' + sq +
                  ' order by CFLFILETYP, CFLFILE';

        exec sql PREPARE df FROM :SqlStmt;
        exec sql DECLARE diff SCROLL CURSOR FOR df;
        exec sql OPEN diff;

        dow forever = forever;
          exec sql fetch next from diff into :cflrec;
          if sqlstt <> '00000';
             leave;
          endif;
          select;
            when cflfiletyp = 'LF';
              // delete logicals that are different
              cmdString = 'DLTF FILE(' + %trim(cflfile) + ')';
              returnCode = GoCmd(%trim(cmdString));
            when cflfiletyp = 'PF';
              // perform change physical on different physical files
              //CHGPF FILE(PIRITEM) SRCFILE(PIRCUR/QDDSFILES)
              cmdString = 'CHGPF FILE(' + %trim(cflfile) + ')' +
                          ' SRCFILE(' + %trim(pLib3) + '/' +
                          'QDDSFILES)';
              returnCode = GoCmd(%trim(cmdString));
          endsl;
        enddo;

        // Perform Files update
        cmdString = 'ADDLIBLE LIB(DSUPDFILE)';
        returnCode = GoCmd(%trim(cmdString));
        cmdString = 'CLRPFM FILE(UPDFILELOG)';
        returnCode = GoCmd(%trim(cmdString));
        cmdString = 'CLRMSGQ BFCUPDERR';
        returnCode = GoCmd(%trim(cmdString));
        cmdString = 'CLRMSGQ BFCUPDFILE';
        returnCode = GoCmd(%trim(cmdString));
        //BFCUPDFILE CMD(*UPDATE) CURLIB(LIB2) UPDLIB(LIB1) SRCLIB(LIB3)
        cmdString = 'BFCUPDFILE CMD(*UPDATE) CURLIB(' + %trim(plib2) + ')' +
                     ' UPDLIB(' + %trim(plib1) + ')' +
                     ' SRCLIB(' + %trim(plib3) + ') OBJTYPE(*ALL)';
        returnCode = GoCmd(%trim(cmdString));
        exec sql CLOSE diff;
