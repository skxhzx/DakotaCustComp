      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  BFCSQLLIBR   Generate any missing SQL Functions or Procedures
     *               for passed in Library
     *
     *               The object for SrcFile can be found in BfcGlodevf.
     *               When compiling on DEV2 you will have no problems if
     *               if this library is in your list.  If you go to compile
     *               on a customer box you will need to carry this object
     *               over or create on fly using program dspfd statement.
     *               It creates qtemp file that it overrides to that is
     *               representative of the QSQLSRC file in the library you
     *               are recreating the procedures and functions.
     *
     *  15 May 2016
     *  Kenneth Elder
     *
     *  Revisions
     *
700 A*    05/15/16  KDE  7.00
     *      - Created.
700aA*    05/30/16  KDE  7.00a
     *      - Added code to skip object with period '.' in name
710 A*    02/21/17  KDE  7.10
     *      - Perform deletes and creates each time ran.
     *        This ensures every function and procedure is replaced
     *        with latest source
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     FSrcFile   uf   e           k disk    usropn

      *
      * Program Info
      *
     d                SDS
     d  #PGM                 001    010
     d  #PARMS               037    039  0
     d  #JOB                 244    253
     d  #USER                254    263
     d  #JOB#                264    269  0

      *----------------------------------------------------------
      * Prototypes
      *----------------------------------------------------------
     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)

     D NullString      C                   -1
     D Success         C                   0
     D WrtCurActive    C                   'CPF3310'

     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
      *
     d extName         s             40    Varying
     d extName2        s             40    Varying
     D oldlib          s             10a   Varying
     d mbrlist         s             10
710 Ad delmbrs         s               n
     d mlname2         s             10
     D newLib          s             10a   Varying
     D position        s              5i 0
     d sq              c                   const(x'7D')
     d sqlStmt         s            500
     d recCnt          s              3  0
     d timestmp        s             26

     d lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
     d upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      *----------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      pLibr       Library for Source File
      *
      *    Returned Parameters
      *      pMessage   Return error message
      *
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    pLibr            10
     C                   parm                    pMessage         99

      *----------------------------------------------------------
      *  Main line
      *----------------------------------------------------------

      /free
710 A                    delmbrs = *on;
710 A                    exsr processMbrs;
710 A                    delmbrs = *off;
710 A                    exsr processMbrs;
710 M                    *inlr = *on;
710 M                    return;

710 A     begsr processMbrs;
710 A
710 A     // ensure that Log file is found within l;ibrary list
710 A     returncode = GoCmd('CHKOBJ OBJ(' +
710 A                    '*LIBL/BFCSQLLOG) OBJTYPE(*FILE)');
710 A     if returncode <> 0;
710 A        pMessage = 'Log File BFCSQLLOG must be present in your ' +
710 A                   'library list to process';
710 A        *inlr = *on;
710 A        return;
710 A     endif;
710 A
          // ensure that library and source file exist
          returncode = GoCmd('CHKOBJ OBJ(' + %trim(pLibr) +
                         '/QSQLSRC) OBJTYPE(*FILE)');
          if returncode <> 0;
             pMessage = 'Invalid Library or no QSQLSRC source file' +
                        ' found';
             *inlr = *on;
             return;
          endif;

          mbrlist = 'mbr' + %char(%Dec(%Time():*HMS));

          // Generate member list from passed in SQL library
          returncode = Gocmd('DSPFD FILE(' + %trim(pLibr) + '/' +
                         'QSQLSRC) TYPE(*MBRLIST) OUTPUT(*OUTFILE) ' +
                         'OUTFILE(QTEMP/' + %trim(mbrlist) + ')');

          // Override rpg file spec to Member list file created in QTEMP
          returncode = GoCmd('OVRDBF FILE(SRCFILE) TOFILE(' +
                        'QTEMP/' + mbrlist + ')');

          if not %open(srcFile);
             open srcFile;
          endif;

          read srcFile;

          dow not %eof(srcFile);
700b         // skip any members with period in name.
700b         position = 0;
700b         position = %Scan ('.': mlname);
700b         if position > 0;
700b  /end-free
700b c                   goto      skipperiod
700b  /free
700b         endif;

             // make sure everything is uppercase
             mlname = %xlate(lowercase:uppercase:mlname);
             mllib = %xlate(lowercase:uppercase:mllib);

             // setup SQL Alias for member to check to see if DROP
             sqlStmt = 'Create Alias qtemp/' + %trim(mlname) +
                       ' For ' + %trim(pLibr) + '/QSQLSRC(' +
                        %trim(mlname) + ')';
             Exec SQL Execute Immediate :sqlStmt;

             // Now query the Member to see if this is a DROP SQL.
             sqlStmt = 'select count(*) from QTEMP/' + %trim(mlname) +
                      ' where srcdta like ' + sq + '%DROP FUNCTION%' +
                      sq + ' or srcdta like ' + sq + '%DROP PROCEDURE%'
                      + sq;

710 A        recCnt = *zeros;
             exec sql Declare mbrCursor Cursor for mainSql;
             exec sql Prepare mainSql from :sqlStmt;
             exec sql Open mbrCursor;
             exec sql Fetch Next From mbrCursor into :recCnt;

             if (sqlstt = '00000' and sqlcod=0 and recCnt<>0
710 A               and not delMbrs) or
710 A           (delMbrs and (sqlStt <> '00000' or recCnt = 0));
                // if records found this means it is a DROP
                // script which we do not want to process
             else;
                // otherwise, this SQL script should be verified.
                // It will now check in QSYS2/SYSROUTINES to see
                // if SQL FUNCTION or PROCEDURE exists.  If it is
                // NOT found it will call BFCSQLMBR to generate
                mlname2 = %subst(mlname:2:9);
                extName2 = '%' + %trim(pLibr) + '/' + %trim(mlname2) +
                           '%';
                extName = '%' + %trim(pLibr) + '/' + %trim(mlname) +
                           '%';
                exec sql select count(*) into :recCnt
                         from qsys2/sysroutines
                         where (external_name like :extName
                            or  external_name like :extName2);
                if sqlstt <> '00000' or sqlcod <> 0 or reccnt = 0;
                   // we determined this was not a drop script and it
                   // did not exist so we called the single BFC process
                   // that would generate the function/procedure
      /end-free
     c                   call      'BFCSQLMBR'
     c                   parm                    pLibr
     c                   parm      'QSQLSRC'     pSrcFile         10
     c                   parm                    mlname
     c                   parm      'TXP'         pType            10
     c                   parm      ' '           pMsg             70
      /free
                // log results, success or failure for sql
                // scripts it determines should process
                // because they are missing in QSYS2/SYSROUTINES
                timestmp = %char(%timestamp());
                exec sql insert into BFCSQLLOG Values(
                        :#pgm, :mlname, :mllib, :pmsg, :#user,
                        :#job#, :#job, :timestmp);
                endif;

             endif;
             sqlStmt = 'Drop Alias QTEMP/' + %trim(mlname);
             Exec SQL Execute Immediate :sqlStmt;
             exec sql close mbrCursor;

700b  /end-free
700b c     skipperiod    tag
700b  /free
             read srcFile;

          enddo;

          close srcFile;
          Returncode = Gocmd('DLTOVR *ALL');

         // delete Member list work file before leaving
         Returncode = Gocmd('DLTF QTEMP/' + %trim(mbrlist));

710 A    endsr;
      /end-free
