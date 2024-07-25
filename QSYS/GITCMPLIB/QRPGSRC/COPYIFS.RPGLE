      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  COPYIFS   Copy IFS file
     *  29 June 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    06/29/18  DAS  7.20
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
     d  fromFileId     s             10I 0
     d  toFileId       s             10I 0
     d  forever        s               n

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

     d OpenFromFile    pr
     d OpenToFile      pr
     d CopyFile        pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        COPY
     *      pFromPath   IFS path for From file
     *      pFromFile   IFS file name for From file
     *      pToPath     IFS path for To file
     *      pToFIle     IFS file name for To file
     *
     *    Returned Parameters
     *      pRtn        *OK
     *                  other code = error
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     d COPYIFS         pr                  extpgm('COPYIFS')
     d  pCmd                         10    const
     d  pFromPath                   256    const varying
     d  pFromFile                   128    const varying
     d  pToPath                     256    const varying
     d  pToFile                     128    const varying
     d  pRtn                         10
     d  pMessage                     60

     d COPYIFS         pi
     d  pCmd                         10    const
     d  pFromPath                   256    const varying
     d  pFromFile                   128    const varying
     d  pToPath                     256    const varying
     d  pToFile                     128    const varying
     d  pRtn                         10
     d  pMessage                     60

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       pRtn = '*OK';
       pMessage = '';

       // Open From file

       OpenFromFile();
       if fromFileId < 0;
         return;
       endif;

       // Create/Open To file

       OpenToFile();
       if toFileId < 0;
         callp close(fromFileId);
         return;
       endif;

       // Copy file

       CopyFile();

       // Close files

       callp close(fromFileId);
       callp close(toFileId);

       *inlr = *on;

       return;

      /end-free

     *----------------------------------------------------------------
     *  CopyFile          Copy file
     *----------------------------------------------------------------

     p CopyFile        b
     d CopyFile        pi

     * Local Variables

     D ilen            s             10I 0
     D rddata          s           1024A

      /free

       dow forever = forever;

         ilen = read(fromFileId: %addr(rddata): %size(rddata));

         if ilen <= 0;
           leave;
         endif;

         callp write(toFileId: %addr(rddata): ilen);

       enddo;

       return;

      /end-free

     p CopyFile        e

     *----------------------------------------------------------------
     *  OpenFromFile      Open From file
     *----------------------------------------------------------------

     p OpenFromFile    b
     d OpenFromFile    pi

     * Local Variables

     d  dirLen         s              3  0

     D stmfSend        S            512    varying
     D url             S            258    varying

      /free

       // Combine path and file name

       select;

         when pFromPath <> '';
           dirLen = %len(pFromPath);
           if %subst(pFromPath:1:1) <> '/';
             url = '/' + pFromPath;
           else;
             url = pFromPath;
           endif;
           if %subst(pFromPath:dirLen:1) <> '/';
             url = %trimr(url) + '/';
           endif;

         other;
           url = '/home/';

       endsl;

       stmfSend = %trimr(url) + pFromFile;

       // Open file, get out if error

       fromFileId = open(%addr(stmfSend)+2: O_RDONLY);
       if fromFileId < 0;
         pRtn = 'OPENERR1';
         pMessage = 'From file open error: '
                  + %str(strerror(errno));
         return;
       endif;

       return;

      /end-free

     p OpenFromFile    e

     *----------------------------------------------------------------
     *  OpenToFile    Open To file
     *----------------------------------------------------------------

     p OpenToFile      b
     d OpenToFile      pi

     * Local Variables

     d  dirLen         s              3  0

     D stmfSend        S            512    varying
     D url             S            258    varying
     D out_flags       s             10u 0
     D out_mode        s             10u 0

      /free

       // Combine path and file name

       select;

         when pToPath <> '';
           dirLen = %len(pToPath);
           if %subst(pToPath:1:1) <> '/';
             url = '/' + pToPath;
           else;
             url = pToPath;
           endif;
           if %subst(pToPath:dirLen:1) <> '/';
             url = %trimr(url) + '/';
           endif;

         other;
           url = '/home/';

       endsl;

       stmfSend = %trimr(url) + pToFile;

       // Set file properties

       out_flags = o_wronly + o_creat + o_trunc
                 + o_share_rdwr + o_codepage;

       out_mode = s_irusr + s_iwusr + s_ixusr
                + s_irgrp + s_iwgrp + s_ixgrp
                + s_iroth + s_iwoth + s_ixoth;

       // Open file, get out if error

       toFileId = open(%addr(stmfSend)+2: out_flags: out_mode: 819);
       if toFileId < 0;
         pRtn = 'CRTOPNERR2';
         pMessage = 'TO file create error: '
                  + %str(strerror(errno));
         return;
       endif;

       return;

      /end-free

     p OpenToFile      e

     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

