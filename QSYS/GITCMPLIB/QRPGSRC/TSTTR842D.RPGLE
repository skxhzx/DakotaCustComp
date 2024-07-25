      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TSTTR842D   Test for initializing Trax files
     *  02 February 2018
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtehed    if   e           k disk
     Fttrte     uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

710bAd forever         s               n
     D lastStop        s              2  0
     d  pWhse          s              3  0
     d  pRtid          s              5
     d  pStop          s              2  0
     D  prtn           s              8
     D  perm           s             60
     D  pversion       s              5
     D  pcommand       s             30

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

720aMD tr842D          pr                  extpgm('TR842D')
     D  pwhse                         3  0
     D  prtid                         5
     D  prtn                          8
     D  perm                         60
     D  pversion                      5
     D  pcommand                     30
     D  pstop                         2  0

720aMD tr842U          pr                  extpgm('TR842U')
     D  pwhse                         3  0
     D  prtid                         5
     D  prtn                          8
     D  perm                         60
     D  pversion                      5
     D  pcommand                     30
     D  pstop                         2  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      iWhse       Warehouse
     *      iRtid       Route id
     *      iStop       Stop
     *
     *----------------------------------------------------------------

     d tsttr842d       pr                  extpgm('TSTTR842D')
     D  iwhse                        15  5
     D  irtid                         5
     D  istop                        15  5

     d tsttr842d       pi
     D  iwhse                        15  5
     D  irtid                         5
     D  istop                        15  5

      /free

        *inlr = *on;

        if %parms() < 3;
          dsply 'tsttr842d (whse rtid stp)';
          return;
        endif;

        pWhse = iwhse;
        pRtid = irtid;
        pStop = istop;
        pVersion = '020';

        if pStop > 0;
          pCommand = 'postCompletedStop';
        else;
          pCommand = '';
        endif;

720aM   TR842D (pWhse: pRtid: prtn: perm:
                pversion: pcommand: pStop);

720aM   TR842U (pWhse: pRtid: prtn: perm:
                pversion: pcommand: pStop);

        // Update Route field in ttrte

        setll (pWhse: pRtid) ttrte;
        dow forever = forever;
           reade (pWhse: pRtid) ttrte;
           if %eof(ttrte);
             leave;
           endif;
           chain (pWhse: pRtid) rtehed;
           if %found(rtehed);
             ttrrte = rhrte;
           endif;
720bA
720cM      //setll (pWhse: pRtid) pltstp2;
720bA      //dow forever = forever;
720cM      //  reade (pWhse: pRtid) pltstp2;
720cM      //  if %eof(pltstp2);
720bA      //    leave;
720bA      //  endif;
720cM      //  if pssstp <> laststop and psspcs > 0;
720bA      //    ttrs += 1;
720cM      //    laststop = pssstp;
720bA      //  endif;
720bA      //enddo;
720bA
           update ttrrec;
        enddo;

        return;
      /end-free
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *   Define partial key for TTTRX file

     C     keyTrx        klist
     C                   kfld                    pwhse
     C                   kfld                    prtid

     C                   endsr

