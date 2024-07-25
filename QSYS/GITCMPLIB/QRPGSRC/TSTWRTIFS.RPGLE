      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTWRTIFS    Test Write IFS file
     *  30 November 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
710 A*    09/30/17  DAS  7.10
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d ifsCmd          s             10
     d ifsPath         s            256    varying
     d ifsFileName     s            128    varying
     d ifsLine         s           3072    varying
     d ifsFileId       s             10I 0
     d ifsRtn          s             10
     d ifsMessage      s             60

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------

     d fdFile1         s             10I 0
     d fdFile2         s             10I 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.wrtifs

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      ifsCmd = 'OPENFILE'
     C                   eval      ifsPath = 'BFCLabels'
     C                   eval      ifsFileName = 'TestFile1'
     C                   eval      ifsLine = ''

     C                   call      'WRTIFS'
     C                   parm      'OPENFILE'    ifsCmd
     C                   parm                    ifsPath
     C                   parm                    ifsFileName
     C                   parm                    ifsLine
     C                   parm                    fdFile1
     C                   parm                    ifsRtn
     C                   parm                    ifsMessage

     C                   if         ifsRtn <> '*OK'
     C                   eval       ifsMessage = ifsMessage
     C                   endif

     C                   eval       ifsPath = ''
     C                   eval       ifsFileName = ''

      /free

       ifsPath = 'BFCLabels';
       ifsFileName = 'TestFile2';

       WrtIFS('OPENFILE':ifsPath:ifsFileName:'':fdFile2:ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       ifsPath = '';
       ifsFileName = '';

      /end-free


     C                   eval       ifsLine = 'Hello World - ' + %char(fdFile1)

     C                   call      'WRTIFS'
     C                   parm      'WRITELINE'   ifsCmd
     C                   parm                    ifsPath
     C                   parm                    ifsFileName
     C                   parm                    ifsLine
     C                   parm                    fdFile1
     C                   parm                    ifsRtn
     C                   parm                    ifsMessage

     C                   if         ifsRtn <> '*OK'
     C                   eval       ifsMessage = ifsMessage
     C                   endif

      /free

       ifsLine = 'Hello World 2 - ' + %char(fdFile2);

       WrtIFS('WRITELINE':'':'':ifsLine:fdFile2:ifsRtn:ifsMessage);
       WrtIFS('WRITELINE':'':'':'Ditto':fdFile2:ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

      /end-free



     C                   call      'WRTIFS'
     C                   parm      'CLOSEFILE'   ifsCmd
     C                   parm                    ifsPath
     C                   parm                    ifsFileName
     C                   parm                    ifsLine
     C                   parm                    fdFile1
     C                   parm                    ifsRtn
     C                   parm                    ifsMessage

     C                   if         ifsRtn <> '*OK'
     C                   eval       ifsMessage = ifsMessage
     C                   endif

      /free

       WrtIFS('CLOSEFILE':'':'':'':fdFile2:ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

      /end-free


     C                   call      'WRTIFS'
     C                   parm      'CLOSEPGM'    ifsCmd
     C                   parm                    ifsPath
     C                   parm                    ifsFileName
     C                   parm                    ifsLine
     C                   parm                    fdFile1
     C                   parm                    ifsRtn
     C                   parm                    ifsMessage

     C                   if         ifsRtn <> '*OK'
     C                   eval       ifsMessage = ifsMessage
     C                   endif


      /free

       WrtIFS('CLOSEPGM':'':'':'':fdFile2:ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       *inlr = *on;

      /end-free

