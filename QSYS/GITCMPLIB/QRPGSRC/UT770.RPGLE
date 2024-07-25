      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UT770     Clean up old file members
     *  31 March 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    03/31/16  RTR  7.00
     *      - Created.
700a *    04/10/16  RTR  7.00a
     *      - Fix: handle invalid change & update dates.
700b *    09/19/16  RTR  7.00b
     *      - Fix: Correct 700a.
     *
     *----------------------------------------------------------------
     fut770f    if   e             disk
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pDays     Age Cutoff in Days
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('UT770')
      * Input
     D   $pDays                       3
      * Output

     D main            pi
     D   $pDays                       3

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *
     d CommandCall     pr                  extpgm('QCMDEXC')
     d  parmcmd                     200
     d  parmlen                      15  5

     *----------------------------------------------------------------
     *  Standard variables
     *
      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Work fields
     *
     d cutdays         s              3s 0
     d dateused        s               d
     d datechgd        s               d
     d strcmd          s            200a
     d strlen          s             15  5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // validate cutoff days parm
        monitor;
          cutdays = %dec($pDays: 3: 0);
        on-error;  // if invalid parm, exit
          *inlr = *on;
          return;
        endmon;
        //curdate = %dec(%char(%date():*ymd0):6:0);

        // loop through member list
        dou forever <> forever;

          read qwhfdml;
          if %eof;
            leave;
          endif;

700aA     if mlname = *blanks;
700aA       iter;
700aA     endif;
700aA
700aA     if mludat = *blanks;
700aA       dateused = *loval;
700aA     else;
700aA       dateused = %date(mludat: *ymd0);
700aA     endif;
700aA     if mlchgd = *blanks;
700aA       datechgd = *loval;
700aA     else;
700aA       datechgd = %date(mlchgd: *ymd0);
700aA     endif;

700bD     //dateused = %date(mludat: *ymd0);
700bD     //datechgd = %date(mlchgd: *ymd0);

          // If last used & changed dates are > cutoff, remove mbr
          if %diff(%date(): dateused: *days) > cutdays
           and %diff(%date(): datechgd: *days) > cutdays
           and mlname <> mlfile;
            clear strcmd;
            strcmd = 'RMVM FILE('
                   + %trim(mlfile) + ') MBR('
                   + %trim(mlname) + ')';
            strlen = %len(%trim(strcmd));
            callp(e) CommandCall(strcmd: strlen);
          endif;

        enddo;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR      Initialization
     *----------------------------------------------------------------
      /free
       begsr *inzsr;

       endsr;
      /end-free
