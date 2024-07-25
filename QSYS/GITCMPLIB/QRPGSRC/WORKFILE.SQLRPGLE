      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  WORKFILE     MRC Testing - Create WORKFILE records
     *  09 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    06/09/10  DAS  6.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D workfile      E ds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pmessage       s             80
     D  pSessId        s             40
     D  pfdate         s              8  0
     D  ptdate         s              8  0
     D  pshift         s              6
     D  pcrew          s              6
     D  pemp#          s              5  0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pfdate      From Date (YYYYMMDD)
     *      ptdate      To Date (YYYYMMDD)
     *      pshift      Shift
     *      pcrew       Crew
     *      pemp#       Employee #
     *
     *    Returned Parameters
     *      pMessage    (blank if okay)
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pmessage
     c                   parm                    pSessId
     c                   parm                    pfdate
     c                   parm                    ptdate
     c                   parm                    pshift
     c                   parm                    pcrew
     c                   parm                    pemp#

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Delete existing records for session

          exec sql delete from workfile
                   where wksessid = :psessid;

        // Create records

          exec sql insert into workfile
                   select :psessid,
                          ptwhse,
                          ptsdte,
                          ptstim,
                          ptedte,
                          ptetim,
                          pttrn#,
                          pttask,
                          ptshft,
                          ptcrew,
                          ptemp#,
                          ptdmin
                   from pirtran
                   where ptsdte >= :pfdate
                     and ptedte <= :ptdate;

          If sqlstt <> sqlSuccess;
          endif;

        return;
