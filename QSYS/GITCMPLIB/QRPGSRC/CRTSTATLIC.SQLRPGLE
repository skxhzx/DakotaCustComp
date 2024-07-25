      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTSTATLBL  Create STATLBL records for LICENSE
     *  04 April 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    04/04/08  DAS  5.20
     *      - Created.
650aA*    06/05/14  RTR  6.50a
     *      - Added fields for PIRCLIENT/PIRCLIENT2.
     *      - Added fields for library/file.
     *      - Changed run date/time to timestamp.
     *      - Delete old records first, no history wanted at this time.
     *
     *----------------------------------------------------------------

650aAfliclog    if   e             disk    infds(file1ds)
650aAfliclogh   if   e             disk    infds(file2ds)

650aA*----------------------------------------------------------------
650aA*  File data data structure
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,c#file1ds
650aA /copy qcopysrc,c#file2ds

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

650aAc                   call      'GETCLIENT'
650aAc                   parm                    pclient          10
650aAc                   parm                    pclient2         10

650aA /free
650aA   exec sql DELETE from statlic;

650aA   exec sql
650aA     INSERT into statlic
650aA       (stclient, stclient2, stlib, stfile, stadded, staction,
650aA        stdrislot, stdrilic, stfrom, stto, strecs)
650aA     SELECT :pclient, :pclient2, :f1library, :f1filename,
650aA       CURRENT_TIMESTAMP, llaction, lldrislot, lldrilic,
650aA       min(lladdts), max(lladdts), count(*)
650aA     FROM liclog
650aA     GROUP BY llaction, lldrislot, lldrilic
650aA     ORDER BY llaction, lldrislot, lldrilic;

650aA   exec sql
650aA     INSERT into statlic
650aA       (stclient, stclient2, stlib, stfile, stadded, staction,
650aA        stdrislot, stdrilic, stfrom, stto, strecs)
650aA     SELECT :pclient, :pclient2, :f2library, :f2filename,
650aA       CURRENT_TIMESTAMP, llaction, lldrislot, lldrilic,
650aA       min(lladdts), max(lladdts), count(*)
650aA     FROM liclogh
650aA     GROUP BY llaction, lldrislot, lldrilic
650aA     ORDER BY llaction, lldrislot, lldrilic;

        *inlr = *on;
650aA /end-free
