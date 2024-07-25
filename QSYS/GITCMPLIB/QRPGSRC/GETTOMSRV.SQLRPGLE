      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETTOMSRV    Get Tomcat server info
     *  22 February 2013
     *  Dave Sommerville
     *
650 A*    02/22/13  DAS  6.50
     *      - Created
     *
700aA*    08/28/15  DAS  7.00a
     *      - Added cluster and debug fields to GLOTOMSRV file.
     *      - Revised to use library list to get GLOTOMSRV file.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pathLen         s              3  0
     D gtsAppLoc       s             20

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pCode  - Server code
     *
     *   Return Value:
     *     pUser      -  User
     *     pTomPath   -  Tomcat path
     *     pJDKPath   -  JDK path
     *     pAppPath   -  Application path
700aA*     pCluster   -  Cluster (Y,N)
700aA*     pDebug     -  Debug (Y,N)
     *     pReturn    -  *OK, *ERROR
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCode            10
     C                   parm                    pUser            10
     C                   parm                    pTomPath         50
     C                   parm                    pJDKPath        100
     C                   parm                    pAppPath        100
700aAC                   parm                    pCluster          1
700aAC                   parm                    pDebug            1
     C                   parm                    pReturn          10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        pReturn = '*OK';

        // Get Tomcat server entry

          exec sql
            select gtsuser, gtstompath, gtsapploc, gtsjdkpath,
700aA              gtsclstr, gtsdebug
               into :pUser, :pTomPath, :gtsapploc, :pJDKPath,
700aA               :pCluster, :pDebug
                   from glotomsrv
                   //from bfcglobalf/glotomsrv
                   where gtscode = :pCode;

        if sqlstt <> sqlSuccess;
          pReturn = '*ERROR';
          return;
        endif;

        // Create application path

        pathLen  = %len(%trimr(pTomPath));
        select;
          when pathLen = 0 or gtsapploc = ' ';
            pAppPath = pTomPath;
          when %subst(pTomPath: pathLen: 1) = '/';
            pAppPath = %trimr(pTomPath) + gtsapploc;
          when %subst(pTomPath: pathLen: 1) <> '/';
            pAppPath = %trimr(pTomPath) + '/' + gtsapploc;
        endsl;

       return;

      /end-free
