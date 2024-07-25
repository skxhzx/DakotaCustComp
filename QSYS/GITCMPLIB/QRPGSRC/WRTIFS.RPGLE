      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WRTIFS    Write IFS file
     *  30 November 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*    09/30/17  DAS  7.10
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *      - Use BFCIFSBND binding directory.
     *
     *      - Used code page logic to write the file as an
     *        ASCII file so that when downloaded to a PC it
     *        will be readable ... by wordpad or notepad.
     *        In essence, it will be written as ccsid 819
     *        rather than ccsid 37.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     d  line           s           3072    varying

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,c#ifsio_h
     d/copy qcopysrc,errno_h
     d/copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d OpenFile        pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        OPENFILE
     *                  WRITELINE
     *                  CLOSEFILE
     *                  CLOSEPGM
     *      pPath       IFS path for OPENFILE
     *      pFileName   IFS file name for OPENFILE
     *      pLine       Line to write to file for WRITELINE
     *      pFileId     fd file descriptor for WRITELINE and CLOSEFILE
     *
     *    Returned Parameters
     *      pFIleId     fd file descriptor from opening file
     *      pRtn        *OK
     *                  other code = error
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     d WRTIFS          pr                  extpgm('WRTIFS')
     d  pCmd                         10    const
     d  pPath                       256    const varying
     d  pFileName                   128    const varying
     d  pLine                      3072    const varying
     d  pFileId                      10I 0
     d  pRtn                         10
     d  pMessage                     60

     d WRTIFS          pi
     d  pCmd                         10    const
     d  pPath                       256    const varying
     d  pFileName                   128    const varying
     d  pLine                      3072    const varying
     d  pFileId                      10I 0
     d  pRtn                         10
     d  pMessage                     60

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       pRtn = '*OK';
       pMessage = '';

       Select;

         when pCmd = 'OPENFILE';
           OpenFile();

         when pCmd = 'WRITELINE';
           line = pLine;
           if WriteLine(pFileId: %addr(line)+2: %len(line)) < 0;
             pRtn = 'WRITEERROR';
             pMessage = 'WriteLine error: '
                      + %str(strerror(errno));
           endif;

         when pCmd = 'CLOSEFILE';
           callp close(pFileId);

         when pCmd = 'CLOSEPGM';
           *inlr = *on;

       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  OpenFile      Open file
     *----------------------------------------------------------------

     p OpenFile        b
     d OpenFile        pi

     * Local Variables

     d  dirLen         s              3  0

     D stmfSend        S            512    varying
     D url             S            258    varying
     D out_flags       s             10u 0
     D out_mode        s             10u 0

      /free

       // Combine path and file name

       select;

         when pPath <> '';
           dirLen = %len(pPath);
           if %subst(pPath:1:1) <> '/';
             url = '/' + pPath;
           else;
             url = pPath;
           endif;
           if %subst(pPath:dirLen:1) <> '/';
             url = %trimr(url) + '/';
           endif;

         other;
           url = '/home/';

       endsl;

       stmfSend = %trimr(url) + pFileName;

       // Set file properties

       out_flags = o_wronly + o_creat + o_trunc
                 + o_share_rdwr + o_codepage;

       out_mode = s_irusr + s_iwusr + s_ixusr
                + s_irgrp + s_iwgrp + s_ixgrp
                + s_iroth + s_iwoth + s_ixoth;

       // Open file, get out if error

       pFileId = open(%addr(stmfSend)+2: out_flags: out_mode: 819);
       if pFileId < 0;
         pRtn = 'CRTOPNERR1';
         pMessage = 'File create error: '
                  + %str(strerror(errno));
         return;
       endif;

       //  Close, then re-open the file in text mode

       callp close(pFileId);
       pFileId = open(%addr(stmfSend)+2: O_WRONLY+O_TEXTDATA);
       if pFileId < 0;
         pRtn = 'CRTOPNERR1';
         pMessage = 'File reopen error: '
                  + %str(strerror(errno));
         return;
       endif;

       return;

      /end-free

     p OpenFile        e

     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

