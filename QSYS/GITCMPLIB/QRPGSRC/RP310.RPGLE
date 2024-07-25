      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RP310    Batch Reports - Generate Scripts
     *  30 November 2012
     *  Rod Roller
     *
640 A*    11/30/12  RTR  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *-------------------------
     *  File Specs
     *
     Fbatrptcfg if   e           k disk
     Fbatrptusr if   e           k disk
     Fbatrptusrlif   e           k disk    rename(brurec:brurecl) prefix(l)
     Fbatrptprt if   e           k disk
     Foptions   if   e           k disk
     Fbfcdebug  o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  File information data structure
     *
      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *
     d batrpt          s              1a
     d currdate        s               d
     d currtime        s               t
     d debugflag       s              1a
     d mrcfromadr      s             80
     d mrcoutpath      s             80
     d mrcrunpath      s             80
     d mrctoadr        s             80
     d outfile         s             80a
     d outpath         s             80a
     d prtpath         s             80a
     d scriptcmd       s            200a
     d scriptfile      s             80a
     d timstp          s             15a

     *----------------------------------------------------------------
     * Constants
     *
     d GROUP           C                   8
     d O_WRONLY        C                   2
     d O_CREAT         C                   8
     d O_TRUNC         C                   64
     d O_CODEPAGE      C                   8388608
     d O_TEXTDATA      C                   16777216
     d OWNER           C                   64
     d RW              C                   6
     d R               C                   4
     d quot            C                   '"'
     d semi            C                   ';'
     d crlf            C                   const(x'0d25')

     *----------------------------------------------------------------
     * Called Programs
     *
     ** API call to open a stream file
     D open            PR            10I 0 extproc('open')
     D   path                          *   value options(*string)
     D   oflag                       10I 0 value
     D   mode                        10U 0 value options(*nopass)
     D   codepage                    10U 0 value options(*nopass)

     ** API call to write data to a stream file
     D write           PR            10I 0 extproc('write')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value

     ** API call to close a stream file
     D close           PR            10I 0 extproc('close')
     D   fildes                      10I 0 value
     D fd              S             10I 0
     D data            S            200A
     D msg             S             52A

     *----------------------------------------------------------------
     * Program Parms
     *
     D rp310           pr                  extpgm('RP310')
     D   pRunTyp                     10
     D   pRptId                      20
     D   pUser                       10
     D   pOutq                       10
     D   pParm                      200
     D   pRetrn                      10
     D   pMsgTxt                    100
     D rp310           pi
     D   pRunTyp                     10
     D   pRptId                      20
     D   pUser                       10
     D   pOutq                       10
     D   pParm                      200
     D   pRetrn                      10
     D   pMsgTxt                    100

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pRunTyp - Type of processing:
     *               *EMAILSNGL - Single Email to passed user
     *               *EMAILLIST - Multi Email to defined user list
     *               *PRINT - Single Print to passed user/outq
     *     pRptId  - Report ID
     *     pUser   - User ID
     *     pOutq   - Outq
     *     pParm1  - Parm String
     *     pRetrn  - Returned Status
     *     pMsgtxt - Returned Message/Script Command
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        // Get report info
        chain (pRptId) batrptcfg;

        if %found(batrptcfg);
          exsr CreateFile;

          if fd < 0;
            pRetrn = '*ERROR    ';
            pMsgTxt = 'File Creation Error.';
          else;
            select;
              when pRunTyp = '*EMAILSNGL';
                exsr WrtEmailSingle;
              when pRunTyp = '*EMAILLIST';
                exsr WrtEmailList;
              when pRunTyp = '*PRINT';
                exsr WrtPrint;
              other;
                pRetrn = '*ERROR    ';
                pMsgTxt = 'Invalid Report ID.';
            endsl;

            exsr CloseFile;
          endif;
        else;
          pRetrn = '*ERROR    ';
          pMsgTxt = 'Invalid Report ID.';
        endif;

        exsr wrtDebug;
        eval *inlr = *on;

      /end-free


     *----------------------------------------------------------------
     *  CreateFile   Build script file to execute reports
     *
      /free
        begsr CreateFile;

        // Create file name/path
        outfile = %trim(pRptId) + '-' + timstp + '.pdf';
        outpath = %trim(mrcoutpath) + '/' + %trim(outfile);
        prtpath = %trim(mrcoutpath) + '/' + %trim(pRptId) + '-' + timstp;
        scriptfile = %trim(mrcrunpath) + '/' + %trim(pRptId) + '-'
                   + timstp + '.js';

        // Open new script file
        fd = open( %trim(scriptfile)
                 : O_CREAT + O_TRUNC + O_WRONLY + O_CODEPAGE
                 : RW*OWNER + RW*GROUP + R : 819);

        // If error
        if fd < 0;
          bdtype = '*ERROR    ';
          bdvalues = 'Unable to open: ' + scriptfile;

        else;
          // Close and reopen to set to ascii text
          callp close(fd);
          fd = open( %trim(scriptfile) : O_WRONLY + O_TEXTDATA );

          // write line to build report in IFS
          scriptcmd = %trim(brcdic) + '_' + %trim(brcnam) + 's.runCmd(['
                    + quot + %trim(outpath) + quot + ',' + quot + '11'
                    + quot + '])' + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

        endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtEmailHeaders  Add email headers to script
     *
      /free
        begsr WrtEmailHeaders;

          // email from variable
          scriptcmd = 'var from = ' + quot + %trim(mrcfromadr)
                    + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // outfilename variable
          scriptcmd = 'var outfilename = ' + quot + %trim(outfile)
                    + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // outfile variable
          scriptcmd = 'var outfile = ' + quot + %trim(outpath)
                    + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // outfmt variable
          scriptcmd = 'var outfmt = ' + quot + '11' + quot
                    + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // subject variable
          scriptcmd = 'var subject = ' + quot + 'Report - ' + %trim(pRptId)
                    + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // bodytext variable
          scriptcmd = 'var bodytext = ' + quot + 'Report Attached: '
                    + %trim(outfile) + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtEmailSingle   Add single email to script
     *
      /free
        begsr WrtEmailSingle;

          // get email address for user
          chain (pUser:'*EMAIL':pRptId) batrptusr;
          if %found(batrptusr);
            mrctoadr = bruloc;
          else;
            chain (pUser:'*EMAIL':'*DEFAULT') batrptusr;
            if %found(batrptusr);
              mrctoadr = bruloc;
            else;
              pRetrn = '*ERROR';
              pMsgTxt = 'User not defined for email.';
              leavesr;
            endif;
          endif;

          // Write email headers
          exsr WrtEmailHeaders;

          // write email to variable
          scriptcmd = 'var tolist = ' + quot + %trim(mrctoadr)
                    + quot + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // write email send command
          scriptcmd = 'email.send(from, tolist, outfile, outfilename, '
                    + 'subject, bodytext, outfmt)' + semi + crlf;
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

          // Pass script filename/path back to driver CL
          pRetrn = '*RUNEMAIL';
          pMsgTxt = scriptfile;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtEmailList    Build script for defined email list
     *
      /free
        begsr WrtEmailList;

          // Write email headers
          exsr WrtEmailHeaders;

          setll ('*EMAIL': pRptId) batrptusrl;
          reade ('*EMAIL': pRptId) batrptusrl;

          dow not %eof(batrptusrl);
            // Write email to variable
            scriptcmd = 'var tolist = ' + quot + %trim(lbruloc)
                      + quot + semi + crlf;
            callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

            // Write email send command
            scriptcmd = 'email.send(from, tolist, outfile, outfilename, '
                      + 'subject, bodytext, outfmt)' + semi + crlf;
            callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));

            reade ('*EMAIL': pRptId) batrptusrl;
          enddo;

          // Pass script filename/path back to driver CL
          pRetrn = '*RUNEMAIL';
          pMsgTxt = scriptfile;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtPrint    Add print to script
     *
      /free
        begsr WrtPrint;

          scriptcmd = '// Printing only';
          callp write(fd: %addr(scriptcmd): %len(%trimr(scriptcmd)));


          // Pass script filename/path back to driver CL
          pRetrn = '*RUNPRTPCL';
          pMsgTxt = prtpath;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  CloseFile   Close script file
     *
      /free
        begsr CloseFile;

        // Close the file:
        callp close(fd);

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebug  Write out debug record
     *
      /free
        begsr wrtDebug;

          if debugflag = 'Y';

            bdaddts = %timestamp();
            bdaddpgm = #pgm;
            bdaddcusr = #curruser;
            bdaddjusr = #user;
            bdaddjob = #job;
            bdaddnbr = #jobnbr;
            bdtype = pRetrn;
            bdvalues = pMsgTxt;
            write(e) bdrec;

          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

          // Get flags from OPTIONS
          chain (0:'*BATRPT ') options;
          if %found(options);
            batrpt = %subst(opdata:5:1);
            debugflag = %subst(opdata:19:1);
          else;
            batrpt = 'N';
            debugflag = 'Y';
          endif;

          // If not configured for batch reports, exit.
          if batrpt <> 'Y';
            pRetrn = '*ERROR   ';
            pMsgTxt='Not configured for Batch Reports. Set up OPTIONS records.';
            exsr wrtDebug;
            *inlr = *on;
            return;
          endif;

          timstp = %char(%date():*iso0) + '-' + %char(%time():*hms0);

          // Get script path from OPTIONS
          chain (0:'*BATRPTA') options;
          if %found(options);
            mrcrunpath = %subst(opdata:20:80);
          else;
            mrcrunpath = '/';
          endif;

          // Get output path from OPTIONS
          chain (0:'*BATRPTB') options;
          if %found(options);
            mrcoutpath = %subst(opdata:20:80);
          else;
            mrcoutpath = '/';
          endif;

          // Get email from address from OPTIONS
          chain (0:'*BATRPTC') options;
          if %found(options);
            mrcfromadr = %subst(opdata:20:80);
          else;
            mrcfromadr = 'Reports@YourCompany.net';
          endif;

        endsr;
      /end-free
