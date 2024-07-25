      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  QDTR842  Reprocess all Trax Routes for hardcoded date range
     *  12 June 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
417 A*    06/12/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File specs
     *----------------------------------------------------------------

     Fttrte     if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /Copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program variables
     *----------------------------------------------------------------

     D wkwhs           s              3  0
     D wkrtid          s              5
     D pWhse           s              3  0
     D pStrDte         s              8  0
     D qCmd            s           3000    varying

     *----------------------------------------------------------------
     *  Convert Date fields.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds
      /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    xWhse             3
     c                   parm                    xStrDte           8
     c                   parm                    ppath            30
      /free
         *inlr=*on;
         // Convert Numberic parms
         monitor;
           pWhse = %dec(xWhse:3:0);
           pStrDte = %dec(xStrDte:8:0);
         on-error;
           pWhse=0;
           pStrDte=0;
         endmon;
         // Loop through all routes after certain day
            sqlStmt = 'select ttrwhs,ttrrti from ttrte' +
                      ' where ttrsrd =' + xStrDte +
                      ' order by ttrsrd, ttrrti';
720 A       exec sql PREPARE tr FROM :SqlStmt;
720 A       exec sql DECLARE trrte SCROLL CURSOR FOR tr;
720 A       exec sql OPEN trrte;
            dow forever = forever;
720 A         exec sql fetch next from trrte into :wkwhs,:wkrtid;
              if sqlStt <> sqlSuccess;
                leave;
              endif;
              // format file string
              qcmd = 'TSTTR842 FILE(' + sq + 'W' + %editc(wkWhs:'X') + 'R' +
                     wkrtid + '_V020_CMP.xml' + sq + ')' +
                     ' PATH(' + sq + %trim(pPath) + sq +
                     ') COMMAND(' + sq + 'postCompletedRoute' + sq + ')';
              qcmdexc(qcmd: %len(qcmd));

            enddo;
720 A       exec sql close trrte;
