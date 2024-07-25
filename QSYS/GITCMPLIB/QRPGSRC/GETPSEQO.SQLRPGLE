      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETSLTSEQ   Get Slot Sequence Information (PSEQ and LVL2)
     *  21 May 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    05/21/19  KDE  7.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fslot2     if   e           k disk
730aA
730aA*----------------------------------------------------------
730aA*  Standard SQL variables and constants
730aA*----------------------------------------------------------
730aA
730aA /copy qcopysrc,c#stdsql
730aA /copy qcopysrc,c#stdvar
730aA
730aA*----------------------------------------------------------
730aA*  SQL record layouts referenced
730aA*----------------------------------------------------------
730aA
730aAD dfprec        E Ds                  Extname(dfpickpsq)
730aAD dfdrec        E Ds                  Extname(dfpickdtl)

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

500gAD dummy           s                   like(slloc)
500gAD side            s              1  0
     d count           s              6  0
     d*$pWhse          s              3s 0

     *----------------------------------------------------------------
     *  *GENPICK  -  General Pick Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPSEQ  -  Slot Pick Sequence
     *
     * Data structure
     *
     D opfdta          DS
     D  oppseq                35     35
     D  opfend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D optcod          s              8

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd   *GETPSEQ    - Get and Return PSEQ option and seq#
     *              *ISSOFT     - Get and Return whether Soft coded (Y/N)
     *              *GETALL     - Get both PSEQ and LVL2 flags for return
     *      $pWhse  Warehouse
     *      $pwhdp  Department
     *      $pDisp  Slot Display
     *
     *    Return Parameters
     *      $pSeqCd    PSequence  (A=Ascending, D=Descending, P=Slot Sequence)
     *      $pSeq      Calculate actual pseq based on above setting
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pWhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pDisp           12
     C                   parm                    $pseqcd           1
     C                   parm                    $pseq             5 0
     C                   parm                    $plvl2            1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *   Return Pseq and Pseq Code

      /free

          $plvl2 ='X';     // Not requested
          $pseqcd='X';     // Not Requested

          count=0;
          if $pCmd = '*ISSOFT' or $pcmd = '*GETALL';
            // Return 'Y' when soft coded LVL2, otherwise 'N'
            exec sql select count(*) into :count
                 from dfpickdtl;

            if sqlStt = sqlSuccess and Count<>0;
               $plvl2='Y';
            else;
               $plvl2='N';
            endif;
          endif;

          if $pCmd = '*GETPSEQ' or $pcmd = '*GETALL';

            // get slot passed in
            chain ($pWhse:$pwhdp:$pdisp) slot2;
            if %found(slot2);
              $pseq=slpseq;
            else;
              $pseqcd='P';
              $pseq=99999;
            endif;

            // start out by getting general pick setting for Pseq
            chain ($pWhse:'*GENPICK') options;
            if not %found(options);
               $pseqcd='P';    // default to Slot Pick Sequence
            else;
               select;
                 when oppseq = 'A';    // Option set to Ascending
                   $pseqcd='A';
                 when oppseq = 'D';    // Option set to Descending
                   $pseqcd='D';
                 other;                // Option set to Descending
                   $pseqcd='P';
               endsl;
            endif;

730aA       // Now look and see if override exist from general setting
730aA       sqlstmt = 'Select dfppseq from dfpickpsq where ' +
730aA                 'dfpwhse = ' + %char($pWhse) + ' and' +
730aA                 ' dfpwhdp = ' + sq + %trim($pwhdp) + sq + ' and ' +
730aA                 ' dfpaisl=' + sq + slaisl + sq;
730aA
730aA       // Add location search possibilities
730aA       if slloc <> *zeros;
730aA          sqlstmt = %trim(sqlStmt) + ' and (dfploc1=' +
730aA                    %char(slloc) + ' or dfploc2=' +
730aA                    %char(slloc) + ' or (dfploc1<=' +
730aA                    %char(slloc) + ' and dfploc2>=' +
730aA                    %char(slloc) + ') or (dfploc1=0 and dfploc2=0))';
730aA       endif;
730aA
730aA       // Add Slot Side selection if it exists
730aA /end-free
730aAC     slloc         div       2             dummy
730aAC                   mvr                     side
730aA /free
730aA       select;
730aA         when side = 0;
730aA           sqlStmt = %trim(sqlStmt) + ' and (dfpside=' +
730aA                     sq + ' ' + sq + ' or dfpside=' +
730aA                     sq + 'E' + sq + ')';
730aA         when side = 1;
730aA           sqlStmt = %trim(sqlStmt) + ' and (dfpside=' +
730aA                     sq + ' ' + sq + ' or dfpside=' +
730aA                     sq + 'O' + sq + ')';
730aA       endsl;
730aA
730aA       exec sql PREPARE ds FROM :SqlStmt;
730aA       exec sql DECLARE dssql SCROLL CURSOR FOR ds;
730aA       exec sql OPEN dssql;
730aA
730aA       exec sql fetch first from dssql into :dfppseq;
730aA       if sqlStt = sqlSuccess;
730aA          $pSeqcd = dfppseq;
730aA       else;
730aA          // when not found use Slot Location PSEQ
730aA          $pSeqcd = 'P';
730aA       endif;
730aA       exec sql close dssql;

            // Now based on sequence calculate the PSEQ# field
            select;
              when $pSeqcd='A';
                $pSeq = slloc;
              when $pSeqcd='D';
                $pSeq = 99999-slloc;
              other;
                $pSeq = slpseq;
            endsl;

          endif;

          *inlr = *on;
          return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr
