      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *  NOTE: Input parm could only be 30 characters (max 33)
     *        because this program is being called from command line.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CRTWEBXML   Create web.xml.new to replace mrc web.xml file
     *  25 March 2020
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    03/25/20  DAS  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h

      /copy qcopysrc,p.qcmdexc

     D OpenInput       PR            10i 0
     D   fileName                  2048    const varying

     D OpenOutput      PR            10i 0
     D   fileName                  2048    const varying

     D CreateWebpgm    PR            10i 0
     D   webinfDir                 2048    const varying

     D CreateWebnew    PR            10i 0
     D   webinfDir                 2048    const varying

     D ProcessXML      PR
     D   webnewFD                    10i 0 const
     D   webinfDir                 2048    const varying

     D ProcessDir      PR
     D   webpgmFD                    10i 0 const
     D   webinfDir                 2048    const varying
     D   dictionary                  20    const varying

     D WriteProgram    PR
     D   webpgmFD                    10i 0 const
     D   dct                         20    const varying
     D   pgm                         20    const varying

     D S_ISDIR         PR             1N
     D   mode                        10U 0 value

     *----------------------------------------------------------------
     *  Working Variables
     *----------------------------------------------------------------


     D forever         S               n
     d cmd             s           3000    varying
     D dirLen          S              3  0
     D dirName         S           2048A   varying
     d varStr          s           3072    varying
     D $pdir           S             30A
740aAD $pdirPart2      S             30A
     D sq              c                   Const('''')
     D ttlRead         S              5  0
     D ttlSkip         S              5  0
     D ttlDir          S              5  0
     D ttlWrt          S              5  0
     D ttlRead1        S              5  0
     D ttlSkip1        S              5  0
     D ttlDir1         S              5  0
     D ttlWrt1         S              5  0
     D ttlRead2        S              5  0
     D ttlSkip2        S              5  0
     D ttlDir2         S              5  0
     D ttlWrt2         S              5  0
     D ttlRead3        S              5  0
     D ttlSkip3        S              5  0
     D ttlDir3         S              5  0
     D ttlWrt3         S              5  0
     D ttlRead4        S              5  0
     D ttlSkip4        S              5  0
     D ttlDir4         S              5  0
     D ttlWrt4         S              5  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PDIR   IFS directory containing m-power folder (optional)
740aA*              Defaults to '/MRC/development'
     *              '/TomcatDev6036/BFCDakota'
     *              '/Tomcat7062ClusterMRC1604'
     *
740aA*      $PDIR   IFS directory part 2 (optional)
     *              Defaults to '/m-power/mrcjava/WEB-INF/'
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   To use folder '/MRC/development/m-power/mrcjava/WEB-INF/' ...
     *
     *       CALL CRTWEBPGM
     *
     *   To use folder folder '/temp' ...
     *
     *       CALL CRTWEBPGM ('' '/temp/')
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdir
740aAC                   parm                    $pdirPart2

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         // Default to development directory
740aA    //   if parm not sent
         // Strip off ending '/' character

         if %parms() = 0;
           dirName = '/MRC/development';
         else;
           dirName = %trim($pDir);
           dirLen = %len(dirName);
740aM      if dirLen > 0 and %subst(dirName:dirLen:1) = '/';
             dirName = %subst(dirName:1:dirLen-1);
           endif;
         endif;

         // Create full directory name
740aA    // Default to m-power if parm not sent

740aA    if %parms() = 2;
740aA      dirName += %trim($pdirPart2);
740aA    else;
           dirName += '/m-power/mrcjava/WEB-INF/';
740aA    endif;

         if CreateWebpgm(dirName) < 0;
           return;
         endif;

         if CreateWebnew(dirName) < 0;
           return;
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  OpenInput    Open input file for read only
     *----------------------------------------------------------------

     p OpenInput       b
     d OpenInput       pi            10I 0
     d  fileName                   2048A   const varying

     *  Local Variables

     d error           S               n
     d fd              s             10I 0
     d errorStr        s            100A   varying

      /free

        // Open directory

         //fd = open(fileName:
         //          O_RDONLY+O_TEXTDATA:
         //          819);

         fd = open(fileName: O_RDONLY+O_TEXTDATA);

         if fd < 0;
           errorStr = %str(strerror(errno));
           dsply 'Error opening file';
           return fd;
         endif;

        return fd;

      /end-free

     p OpenInput       e

     *----------------------------------------------------------------
     *  OpenOutuput  Open/Create/Clear output file
     *----------------------------------------------------------------

     p OpenOutput      b
     d OpenOutput      pi            10I 0
     d  fileName                   2048A   const varying

     *  Local Variables

     d error           S               n
     d fd              s             10I 0
     d errorStr        s            100A   varying

      /free

        // Open directory

         fd = open(fileName:
                   O_TRUNC+O_CREAT+O_WRONLY+O_CODEPAGE:
                   S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
                   819);

         if fd < 0;
           errorStr = %str(strerror(errno));
           dsply 'Error creating file';
           return fd;
         endif;

         // Close file and reopen it in text mode.

         callp close(fd);
         fd = open(fileName:
                   O_WRONLY+O_TEXTDATA);

         if fd < 0;
           errorStr = %str(strerror(errno));
           dsply 'error reopening file';
           return fd;
         endif;

        return fd;

      /end-free

     p OpenOutput      e

     *----------------------------------------------------------------
     *  CreateWebpgm   Create webpgm.xml files
     *----------------------------------------------------------------

     p CreateWebpgm    b
     d CreateWebpgm    pi            10I 0
     d  webinfDir                  2048A   const varying

     *  Local Variables

     d webpgmFD        s             10I 0

      /free

         // Open/Create/Clear webpgm.xml file

         webpgmFD = openOutput(webinfDir + 'webpgm.xml');
         if webpgmFD < 0;
           dsply 'Error creating webpgm.xml file';
           return webpgmFD;
         endif;

         // Write out starting comment
         // The first comment is used for sorting

         //varStr = '<!--BFC1-->'
         varStr = ''
                + '<!-- Dakota Program Definitions '
                + %char(%timestamp()) + ' -->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         // Process dictionaries

         processDir(webpgmFD: dirName: 'BFCDAKOTA');
         ttlRead1 = ttlRead;
         ttlSkip1 = ttlSkip;
         ttlDir1 = ttlDir;
         ttlWrt1 = ttlWrt;
         processDir(webpgmFD: dirName: 'BFCREPORTS');
         ttlRead2 = ttlRead;
         ttlSkip2 = ttlSkip;
         ttlDir2 = ttlDir;
         ttlWrt2 = ttlWrt;
         processDir(webpgmFD: dirName: 'BFCSIGNON');
         ttlRead3 = ttlRead;
         ttlSkip3 = ttlSkip;
         ttlDir3 = ttlDir;
         ttlWrt3 = ttlWrt;
         processDir(webpgmFD: dirName: 'BFCGLOBAL');
         ttlRead4 = ttlRead;
         ttlSkip4 = ttlSkip;
         ttlDir4 = ttlDir;
         ttlWrt4 = ttlWrt;

         // Write out ending comment

         //varStr = '<!--BFC3-->'
         varStr = ''
                + '<!-- BFCDAKOTA '
                + 'ttlRead=' + %char(ttlRead1) + ', '
                + 'ttlSkip=' + %char(ttlSkip1) + ', '
                + 'ttlDir=' + %char(ttlDir1) + ', '
                + 'ttlWrt=' + %char(ttlWrt1) + ' '
                + '-->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         //varStr = '<!--BFC3-->'
         varStr = ''
                + '<!-- BFCREPORTS '
                + 'ttlRead=' + %char(ttlRead2) + ', '
                + 'ttlSkip=' + %char(ttlSkip2) + ', '
                + 'ttlDir=' + %char(ttlDir2) + ', '
                + 'ttlWrt=' + %char(ttlWrt2) + ' '
                + '-->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         //varStr = '<!--BFC3-->'
         varStr = ''
                + '<!-- BFCSIGNON '
                + 'ttlRead=' + %char(ttlRead3) + ', '
                + 'ttlSkip=' + %char(ttlSkip3) + ', '
                + 'ttlDir=' + %char(ttlDir3) + ', '
                + 'ttlWrt=' + %char(ttlWrt3) + ' '
                + '-->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         //varStr = '<!--BFC3-->'
         varStr = ''
                + '<!-- BFCGLOBAL '
                + 'ttlRead=' + %char(ttlRead4) + ', '
                + 'ttlSkip=' + %char(ttlSkip4) + ', '
                + 'ttlDir=' + %char(ttlDir4) + ', '
                + 'ttlWrt=' + %char(ttlWrt4) + ' '
                + '-->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         //varStr = '<!--BFC4-->'
         varStr = ''
                + '<!-- End Dakota Program Definitions '
                + %char(%timestamp()) + ' -->';
         writeline(webpgmFD: %addr(varStr)+2: %len(varStr));

         // Close file

         callp close(webpgmFD);

         // Sort webpgm.xml file

         cmd = 'strqsh cmd(' + sq + 'sort '
             + dirname + 'webpgm.xml'
             + '|iconv -f 37 -t 819 > '
             + dirname + 'webpgmsorted.xml' + sq + ')';

         monitor;
           //qcmdexc(cmd: %len(cmd));
         on-error;
           dsply 'Sort error occured';
           return -1;
         endmon;

        return 0;

      /end-free

     p CreateWebpgm    e

     *----------------------------------------------------------------
     *  CreateWebnew   Create web.xml.new files
     *----------------------------------------------------------------

     p CreateWebnew    b
     d CreateWebnew    pi            10I 0
     d  webinfDir                  2048A   const varying

     *  Local Variables

     d webnewFD        s             10I 0
     d websrtFD        s             10I 0
     d webxmlFD        s             10I 0
     d rddata          S           3072
     d lastLine        S                   like(rddata)
     d servletFlag     S               n
     d writeFlag       S               n
     d keep            S               n

      /free

       // Open web.xml file

       webxmlFD = openInput(webinfDir + 'web.xml');
       if webxmlFD < 0;
         dsply 'Error opening web.xml file';
         return webxmlFD;
       endif;

       // Open webpgmsorted.xml file

       //websrtFD = openInput(webinfDir + 'webpgmsorted.xml');
       websrtFD = openInput(webinfDir + 'webpgm.xml');
       if websrtFD < 0;
         dsply 'Error opening webpgmsorted.xml file';
         callp close(webxmlFD);
         return websrtFD;
       endif;

       // Open/Create/Clear web.xml.new file

       webnewFD = openOutput(webinfDir + 'web.xml.new');
       if webnewFD < 0;
         dsply 'Error creating web.xml.new file';
         callp close(webxmlFD);
         callp close(websrtFD);
         return webnewFD;
       endif;

       // Read through file line by line

       servletFlag = *off;
       writeFlag = *on;

       dow readline(webxmlFD: %addr(rddata):%size(rddata))>=0;

         // Look for the start of a program definition

         if rddata = '<servlet>' or rddata = '<servlet-mapping>';
           servletFlag = *on;
           writeFlag = *off;
           lastLine = rddata;
           iter;
         endif;

         // Determine if we have a program definition

         if servletFlag;
           servletFlag = *off;

           // Determine if we should keep the servlet
           // There is no good way to identify a dictionary program
           // Therefore we hardcode what we want to keep

           keep = *off;

           if %scan('<servlet-name> ': rddata) > 0;
             keep = *on;
           endif;

           if %scan('<servlet-name>Change': rddata) > 0;
             keep = *on;
           endif;

           if %scan('<servlet-name>mrc_': rddata) > 0;
             keep = *on;
           endif;

           if %scan('<servlet-name>mrc-': rddata) > 0;
             keep = *on;
           endif;

           if %scan('<servlet-name>Set': rddata) > 0;
             keep = *on;
           endif;

           // If we don't want to keep, leave writeFlag off and iter

           if not keep;
             iter;
           endif;

           // Otherwise, turn on write flag, write last line and continue

           writeFlag = *on;
           varStr = %trimr(lastLine);
           writeline(webnewFD: %addr(varStr)+2: %len(varStr));

         endif;

         // Look for the start of a program definition

         if not writeFlag;
           if rddata = '</servlet>' or rddata = '</servlet-mapping>';
             writeFlag = *on;
             iter;
           endif;
         endif;

         // See if we should write the line
         // Don't write out last linet ('</web-app>')

         if writeFlag;
           if rddata <> '</web-app>';
             varStr = %trimr(rddata);
             writeline(webnewFD: %addr(varStr)+2: %len(varStr));
           endif;
         endif;

       enddo;

       // Now add the programs

       dow readline(websrtFD: %addr(rddata):%size(rddata))>=0;
         varStr = %trimr(rddata);
         writeline(webnewFD: %addr(varStr)+2: %len(varStr));
       enddo;

       // Finally, add last line

       varStr = '</web-app>';
       writeline(webnewFD: %addr(varStr)+2: %len(varStr));

       // Close files

       callp close(webnewFD);
       callp close(webxmlFD);
       callp close(websrtFD);

       return 0;

      /end-free

     p CreateWebnew    e

     *----------------------------------------------------------------
     *  ProcessDir   Process directory
     *----------------------------------------------------------------

     p ProcessDir      b
     d ProcessDir      pi
     d  fd                           10I 0 const
     d  webinfDir                  2048A   const varying
     d  dictionary                   20A   const varying

     *  Local Variables

     d dir             s               *
     d dictionaryDir   S           2048A   varying
     d fnwithdir       S           2048A   varying
     d filename        S           2048A   varying
     d mystat          S                   like(statds)

      /free

        // Open directory

        dictionaryDir = webinfDir + 'classes/' + dictionary;
        dir = opendir('' + dictionaryDir + '');

        if dir = *NULL;
          return;
        endif;

        // Process Directory

        ttlRead = 0;
        ttlSkip = 0;
        ttlDir  = 0;
        ttlWrt  = 0;
        p_statds = %addr(mystat);

        dow forever = forever;
          p_dirent = readdir(dir);
          if p_dirent = *null;
            leave;
          endif;

          // Get file name and information.

          filename = %subst(d_name:1:d_namelen);
          fnwithdir = dictionaryDir + '/' + filename;

          ttlRead += 1;

          if stat(fnwithdir: %addr(mystat)) < 0;
            ttlSkip += 1;
            iter;
          endif;

          // Skip directories

          if S_ISDIR(st_mode);
            ttlDir += 1;
            iter;
          endif;

          // Write program to file when we find '$Field' file

          //if %len(filename) >= 13 and %subst(filename: 8: 6) = '$Field';
          //if %len(filename) = 12 and %subst(filename: 7: 6) = 's.html';
          if %len(filename) = 13 and %subst(filename: 7: 7) = 's.class';
            ttlWrt += 1;
            WriteProgram(fd: dictionary: %subst(filename: 1: 7));
          endif;

        enddo;

        callp closedir(dir);

        return;

      /end-free

     p ProcessDir      e


     *----------------------------------------------------------------
     *  WriteProgram   Write program to file
     *----------------------------------------------------------------

     p WriteProgram    b
     d WriteProgram    pi
     d  fd                           10I 0 const
     d  dct                          20A   const varying
     d  pgm                          20A   const varying

     *  Local Variables

     d varStr          s           2048    varying

      /free

         //varStr += '<!--BFC2-->'
         varStr = ''
                + '<servlet>'
                + '<servlet-name>' + dct + '_' + pgm + '</servlet-name>'
                + '<servlet-class>' + dct + '.' + pgm + '</servlet-class>'
                + '</servlet>'
                + '<servlet-mapping>'
                + '<servlet-name>' + dct + '_' + pgm + '</servlet-name>'
                + '<url-pattern>/servlet/' + dct + '.' + pgm
                + '</url-pattern>'
                + '</servlet-mapping>';
         writeline(fd: %addr(varStr)+2: %len(varStr));

        return;

      /end-free

     p WriteProgram    e

     *----------------------------------------------------------------
     *  s_isdir
     *----------------------------------------------------------------

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This tests a file mode to see if a file is a directory.
      *
      * Here is the C code we're trying to duplicate:
      *      #define _S_IFDIR    0040000                                       *
      *      #define S_ISDIR(mode) (((mode) & 0370000) == _S_IFDIR)
      *
      * 1) ((mode) & 0370000) takes the file's mode and performs a
      *      bitwise AND with the octal constant 0370000.  In binary,
      *      that constant looks like: 00000000000000011111000000000000
      *      The effect of this code is to turn off all bits in the
      *      mode, except those marked with a '1' in the binary bitmask.
      *
      * 2) ((result of #1) == _S_IFDIR)  What this does is compare
      *      the result of step 1, above with the _S_IFDIR, which
      *      is defined to be the octal constant 0040000.  In decimal,
      *      that octal constant is 16384.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P S_ISDIR         B
     D S_ISDIR         PI             1N
     D   mode                        10U 0 value

     D                 DS
     D  dirmode                1      4U 0
     D  byte1                  1      1A
     D  byte2                  2      2A
     D  byte3                  3      3A
     D  byte4                  4      4A

     C* Turn off bits in the mode, as in step (1) above.
     c                   eval      dirmode = mode

     c                   bitoff    x'FF'         byte1
     c                   bitoff    x'FE'         byte2
     c                   bitoff    x'0F'         byte3
     c                   bitoff    x'FF'         byte4

     C* Compare the result to 0040000, and return true or false.
     c                   if        dirmode = 16384
     c                   return    *On
     c                   else
     c                   return    *Off
     c                   endif
     P                 E

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
