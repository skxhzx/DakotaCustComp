      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTCOPYIFS    Test Copy IFS file
     *  29 June 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*    06/29/18  DAS  7.20
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d ifsCmd          s             10
     d ifsFromPath     s            256    varying
     d ifsFromFile     s            128    varying
     d ifsToPath       s            256    varying
     d ifsToFile       s            128    varying
     d ifsRtn          s             10
     d ifsMessage      s             60

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.copyifs

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

       ifsFromPath = '/BFCTraxDev/Pictures/JPG/';
       ifsFromFile = 'w001r49815s03_SIG.jpg';

       ifsToPath = '/BFCTraxDev/Pictures/JPG/ByOrder';
       ifsToFile = 'w001o123456r49815s03_SIG.jpg';

       CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
               ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       ifsFromPath = '/BFCTraxDev/';
       ifsFromFile = 'Company_W900_V020.XML';

       ifsToPath = '/BFCTraxDev/Pictures/JPG/ByOrder';
       ifsToFile = 'Company_W900_V020_copy.XML';

       CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
               ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       ifsFromPath = '/BFCTraxDave/Pictures/JPG/';
       ifsFromFile = 'w900r99001s1iDA101u9900100003t020304085167-07.jpg';

       ifsToPath = '/BFCTraxDev/Pictures/JPG/ByOrder';
       ifsToFile = 'w001o123456r99001s1iDA101u9900100003t020304085167-07.jpg';

       CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
               ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       // Test invalid From Path

       ifsFromPath = '/XBFCTraxDave/Pictures/JPG/';

       CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
               ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       // Test invalid To Path

       ifsFromPath = '/BFCTraxDave/Pictures/JPG/';
       ifsToPath = '/xBFCTraxDev/Pictures/JPG/ByOrder';

       CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
               ifsRtn:ifsMessage);
       if ifsRtn <> '*OK';
         ifsMessage = ifsMessage;
       endif;

       *inlr = *on;

      /end-free

