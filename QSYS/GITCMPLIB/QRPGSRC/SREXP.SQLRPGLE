      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SREXP  Export Super Route
     *  17 June 2021
     *  Kenneth Elder
     *
     *  Revisions:
     *
650 A*    06/17/21  KDE  7.50
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     d pWhse           s              3p 0
     D sRtid           s              5
     d sRte            s              5
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     d sq              c                   x'7d'
     d chcnt           s              5  0
     d srdate          s              8  0
     d srtime          s              6  0

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D srexp           pr                  extpgm('SREXP')
     D  pWhse                         3
     D  pRtId                         5
     D  pRte                          5

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pRte        Route
     *
     *    Returned Parameters
     *      pMessage    Any message encountered
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    cWhse             3
     C                   parm                    pRtid             5
     C                   parm                    pRte              5
     c                   parm                    pMessage         99

      /free

         monitor;
           pWhse = %dec(cWhse:3:0);
         on-error;
           pWhse = 1;
         endmon;

         sRte = pRte;
        // When Super Route we need to loop Child Routes
        // in SRORD to point orders back to respective
        // child route and close each child route
         sqlStmt = 'select srowhs,srosrtid,sromrtid,sromrte,count(*) ' +
                      'from srord,rtehed  ' +
                 'where srowhs=' + %char(pWhse)  +
                 ' and srosrtid=' + sq + pRtid + sq +
                 ' and srowhs=rhwhse and sromrtid=rhrtid' +
                 ' and rhstat < ' + sq + '6' + sq +
                 ' group by srowhs,srosrtid,sromrtid,sromrte ' +
                 'order by srowhs,srosrtid,sromrtid,sromrte ';
         exec sql PREPARE cr FROM :SqlStmt;
         exec sql DECLARE chrte SCROLL CURSOR FOR cr;
         exec sql OPEN chrte;

         srdate = %dec(%char(%date():*iso0):8:0);
         srtime = %dec(%time():*HMS);

         dow Sqlstt = sqlSuccess;
            exec sql fetch next from chrte into :pWhse,:sRtid,:pRtid,
                                                :pRte,:chcnt;
            if sqlStt <> sqlSuccess;
              leave;
            endif;

           // update child to status 5 Closed and call rteexport for each
            exec sql update rtehed set rhstat='5',
                        rhbldd=:srdate,rhbldt=:srtime,
                        rhprtd=:srdate,rhprtt=:srtime
                 where rhwhse=:pWhse and rhrtid=:pRtid;
           // set orders back to Child Route to Export
            exec sql update ordh set ohrte=:pRtid
                     where ohwhse=:pWhse and ohrte=:sRtid
                       and (select count(*) from srord where
                       srowhs=ohwhse and srosrtid=ohrte
                       and sromordid=ohord and sromrtid=:pRtid)<>0;
            pMessage = '';
            exsr callRteExp;
            if pMessage <> ' ';
              leave;
            endif;
         enddo;
         exec sql CLOSE chrte;
         if pMessage = *blanks;
           // change super route to exported and clear in use for super route
           exec sql update rtehed set rhstat='6',rhexpd=:srdate,rhexpt=:srtime
                where rhwhse=:pWhse and rhrtid=:sRtid;
           $icmd = '*CLEAR  ';
           exsr zziuse;
         endif;

         *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  callRteExp  -  Call Route Export
     *----------------------------------------------------------------

      /free
       begsr callRteExp;

      /end-free
     *      Call Stage export to Host pgm.
     C                   eval      $rwhse = %editc(pwhse:'X')
     C                   eval      $bcmd = '*ALL'
     C                   call      'RH155SCL'
     C                   parm                    $bcmd             8
     C                   parm                    $rwhse            3
     C                   parm      pRtid         $brtid            5
     C                   parm      pRte          $btrte            5
     C                   parm      ' '           $prtn             8
      /free

         if %error;
           pMessage = 'Error occured calling '
                    + 'RH155SCL ('
                    + %trimr(#job) + '/'
                    + %trimr(#jobnbr) + '/'
                    + %trimr(#user) + ')';
         endif;

    A  endsr;
    A /end-free
     *----------------------------------------------------------------
     *
     *  ZZIUSE   Set Inuse flag for route before proceeding.
     *
     C     zziuse        begsr
     C                   call      'CHKIUSE2'
     C                   parm                    $icmd             8
     C                   parm      pWhse         $iwhse            3 0
     C                   parm      sRtid         $irtid            5
     C                   parm      #prog         $ipgm            20
     C                   parm      ''            $iuser           10
     C                   parm      ''            $isessid         40
     C                   parm                    $irtn             8
     C                   parm                    $itext10         10
     C                   parm                    $itext30         30
     C                   parm                    $iucmd            8
     C                   parm                    $iupgm           20
     C                   parm                    $iuuser          10
     C                   parm                    $iuSessId        40
     C                   parm                    $iuJobName       10
     C                   parm                    $iuJobNbr         6
     C                   parm                    $iuJobUser       10
     C                   parm                    $iuStamp         26
     C                   endsr
