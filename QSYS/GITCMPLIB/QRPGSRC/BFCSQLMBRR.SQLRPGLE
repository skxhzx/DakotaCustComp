      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  BFCSQLMBRR   Run SQL script converting PIRSQL to cccSQL
760aA*               Now works with QDDSFILES scripts as well
     *  09 May 2016
     *  Kenneth Elder
     *
     *  Revisions
     *
700 A*    05/09/16  KDE  7.00
     *      - Created.
     *
700aA*    05/11/16  DAS  7.00a
     *      - Added extdesc to file definition.
700bA*    05/30/16  KDE  7.00b
     *      - User library other than QTEMP.  Some RUNSQLSTM
     *        are not working correctly compiling in QTEMP
710 A*    02/21/17  KDE  7.10
     *      - Several changes for naming issues
760aA*    01/03/23  DAS  7.60a
     *      - Revised to allow QDDSFILES, replaces '<lib>'
     *      - Revised to use %scanrpl instead of %scan and %replace
     *      - Revised GoCmd()'s to use a variable.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     FSrcFile   uf   e           k disk    usropn
710 AF                                     extdesc('*LIBL/QSQLSRC')
760aAFSrcFileDDSuf   e           k disk    usropn
760aAF                                     extdesc('*LIBL/QDDSFILES')

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
700bAd bfclib          s             10
     D oldlib          s             10a   Varying
     D newLib          s             10a   Varying
     D position        s              5i 0
     d sq              c                   const(x'7D')
     d timestmp        s             26
760aAd cmdStr          s            500    varying
760aAd newsrc          s                   like(srcdta)

     d lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
     d upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      *----------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      pLibr       Library for Source File
      *      psrcfile    Source File within Library
      *      pObj        Source member within Source File
      *      pSrcType    Source Type
760aA *      pNewLib     Optional - New library
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
     C                   parm                    pSrcFile         10
     C                   parm                    pObj             10
     C                   parm                    pSrcType         10
     C                   parm                    pMessage         99
760aAC                   parm                    pNewLib          10

700bAc                   time                    libtime           6 0

      *----------------------------------------------------------
      *  Main line
      *----------------------------------------------------------

      /free

         //if pSrcFile <> 'QSQLSRC';
         if pSrcFile <> 'QSQLSRC' and pSrcFile <> 'QDDSFILES';
760aM       pMessage = 'Command Failed !!  Source file must be QSQLSRC'
760aA                + ' or QDDSFILES';
            return;
         endif;

         if pSrcType <> 'TXT' and pSrcType <> 'TXP';
            pMessage = 'Command FAILED !!  Source Type must be TXT';
            return;
         endif;

760aA    if pSrcFile = 'QDDSFILES' and (%parms < 6 or pNewLib = '');
760aA       pMessage = 'Command FAILED !!  New library must be entered '
760aA                + 'for QDDSFILES';
760aA       return;
760aA    endif;

760aA    select;
760aA      when pSrcFile = 'QDDSFILES';
760aA        oldLib = '<lib>';
760aA      other;
760aM        oldLib = 'PIRSQL';
760aA    endsl;

760aA    if %parms >= 6 and pNewLib <> '';
760aA      newLib = %trim(pNewLib);
760aA    else;
760aM      newLib = %trim(pLibr);
760aA    endif;

          // make sure BFCSQLLIB exists
          bfclib = 'bfc' + %char(libtime);
          returncode = Gocmd('CRTLIB LIB(' + bfclib + ')');

760aD     //returncode = Gocmd('CRTSRCPF FILE(' + %trim(bfclib) +
760aD     //             '/QSQLSRC) RCDLEN(112)');
760aD     //returncode = Gocmd('CPYSRCF FROMFILE(' + %trim(pLibr) + '/' +
760aD     //        'QSQLSRC)' +
760aD     //        ' TOFILE(' + %trim(bfclib) + '/QSQLSRC) FROMMBR(' +
760aD     //        %trim(pObj) + ')');
760aD     //returncode = GoCmd('OVRDBF FILE(SRCFILE) TOFILE(' +
760aD     //        %trim(bfclib) + '/' + pSrcFile + ') MBR(' +
760aD     //        %trim(pObj) + ')');

760aA     cmdStr = 'CRTSRCPF '
760aA            + 'FILE(' + %trim(bfclib) + '/' + %trimr(pSrcFile) + ') '
760aA            + 'RCDLEN(112)';
760aA     returncode = Gocmd(cmdStr);

760aA     cmdStr = 'CPYSRCF '
760aA            + 'FROMFILE(' + %trim(pLibr) + '/' + %trimr(pSrcFile) + ') '
760aA            + 'TOFILE(' + %trim(bfclib) + '/' + %trimr(pSrcFile) + ') '
760aA            + 'FROMMBR(' + %trim(pObj) + ')';
760aA     returncode = Gocmd(cmdStr);

760aA     select;
760aA       when pSrcFile = 'QDDSFILES';
760aA         cmdStr = 'OVRDBF FILE(SRCFILEDDS) '
760aA                + 'TOFILE(' + %trim(bfclib) + '/' + pSrcFile + ') '
760aA                + 'MBR(' + %trim(pObj) + ')';
760aA       other;
760aA         cmdStr = 'OVRDBF FILE(SRCFILE) '
760aA                + 'TOFILE(' + %trim(bfclib) + '/' + pSrcFile + ') '
760aA                + 'MBR(' + %trim(pObj) + ')';
760aA     endsl;

760aA     returncode = Gocmd(cmdStr);

760aA     select;
760aA       when pSrcFile = 'QDDSFILES';
760aA         if not %open(srcFileDDS);
760aA           open srcFileDDS;
760aA         endif;
760aA       other;
              if not %open(srcFile);
                open srcFile;
              endif;
760aA     endsl;

760aA     select;
760aA       when pSrcFile = 'QDDSFILES';
760aA         read srcFileDDS;
760aA       other;
              read srcFile;
760aA     endsl;

760aD     //dow not %eof(srcFile);
760aM     dow not %eof();
             // make sure everything is uppercase
760aA        // only for QSQLSRC

760aA        if pSrcFile = 'QSQLSRC';
760aM          srcdta = %xlate(lowercase:uppercase:srcdta);
760aA        endif;

             // replace any occurence of PIRSQL with new library
760aA        // <lib> for QDDSFILES

             // no need to do any changes if RS ran from PIRSQL
760aA        // This IF statement works with QDDSFILES becuase it
760aA        // is assumed newLib wouldn't be PIRSQL.

             if newLib <> 'PIRSQL';
                //dou position = 0;
                //  position = %Scan (oldLib: srcdta);
                //  if position > 0;
                //    srcdta = %replace (newLib: srcdta: position);
                //  endif;
                //enddo;
760aA           newsrc = %scanrpl (oldLib: newLib: srcdta);
760aA           if newsrc <> srcdta;
760aA             srcdta = newsrc;
760aA             select;
760aA               when pSrcFile = 'QDDSFILES';
760aA                 update qddsfiles;
760aA               other;
710 M                 update qsqlsrc;
760aA             endsl;
760aA           endif;
             endif;

760aA       select;
760aA         when pSrcFile = 'QDDSFILES';
760aA           read srcFileDDS;
760aA         other;
                read srcFile;
760aA       endsl;

          enddo;
760aA     select;
760aA       when pSrcFile = 'QDDSFILES';
760aA         close srcFileDDS;
760aA       other;
              close srcFile;
760aA     endsl;
          Returncode = Gocmd('DLTOVR *ALL');

          // Process the RS command to generate the modified SQL
          // Function or Procedure
          Returncode = GoCmd('RUNSQLSTM SRCFILE(' + %trim(bfclib) +
                       '/' + %trim(pSrcFile) +
                       ') SRCMBR(' + %trim(pObj) + ') COMMIT(*NC) ' +
710 M                  'NAMING(*SYS)');
          if Returncode = 0;
760aD        //pMessage = 'SQL generated successfully';
760aM        pMessage = 'RUNSQLSTM successful for '
760aM                 + %trim(newlib) + '/' + pObj;
          else;
760aD        //pMessage = 'SQL failed.  Please review spool file' +
760aD        //          ' for more detail';
760aM        pMessage = 'RUNSQLSTM failed for ' + pObj + '. '
760aM                 + 'Please review spool file for more detail';
          endif;

          // insert log record showing this was created interactively
          // only if not called by BFCSQLLIBR.  That process adds record
          // of its own showing it was called from batch program
          if pSrcType <> 'TXP';
             timestmp = %char(%timestamp());
             exec sql insert into BFCSQLLOG Values(
                      :#pgm, :pObj, :pLibr, :pmessage, :#user,
                      :#job#, :#job, :timestmp);
          endif;

760aD    //Returncode = Gocmd('DLTF ' + %trim(bfclib) + '/QSQLSRC');
760aM    Returncode = Gocmd('DLTF ' + %trim(bfclib) + '/' + %trim(pSrcFile));
         Returncode = GoCmd('DLTLIB LIB(' + %trim(bfclib) + ')');
         *inlr = *on;
         return;

      /end-free
