      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II296       FTP - Import Item Updates - Convert to Staging
     *  Rod Roller
     *  September 19, 2018
     *
     *----------------------------------------------------------------
     *  Notes
     *  - This program takes the FTP import file and converts it to a
     *    staging batch, then runs the staging program to import data.
     *  - DO NOT ADD LOGIC here for the import process, do it in the
     *    staging version that is called, II295S.
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    09/19/18  RTR  7.20
     *      - Created
     *
730a *    06/10/19  RTR  7.30a
     *      - Created
     *
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     fimpfitm4  if   e           k disk    rename(iurec: ftprec)
     f                                     prefix(ftp_)
     fimpsitmn  uf a e           k disk    rename(iurec: stgrec)
     f                                     prefix(stg_)
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  File data structures
     d saved         e ds                  extname(impsitmn)
     *----------------------------------------------------------------
     *  Prototypes
     *
      /copy qcopysrc,p.wrtlog
      /copy qcopysrc,p.getbatid

     d RunStage        pr                  extpgm('II295S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const
      * Output
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Working Variables
     *
     d AspenWhse       s               n   inz('0')
     d batId           s             11a
     d batStat         s              1a
     d batText         s            200a
     d cmdexcerr       s              1    inz('0')
     d rtnCode         s             10
     d rtnMessage      s            200
     d stamp           s               z
     d stampUC         s               z

     D dsWhse          ds
     D  batWhse                1      3  0
     D  batWhsea               1      3a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

730aA   // Get warehouse from data
730aA   exec sql select max(iuwhse) into :batWhse
730aA              from impfitm4;
730aA   if sqlstt <> sqlsuccess;
          batWhse = 1;
730aA   endif;
        batStat = 'R';
        batText = 'Converted from FTP.';

        // Get staging batch ID
        exsr zzzGetBatId;

        // Get timestamps
        exsr zzzGetStamps;

        dou forever <> forever;

          read ftprec;
          if %eof(impfitm4);
            leave;
          endif;

          // Write record to staging file
          exsr zzzWrtRecord;

        enddo;

        // Mark batch ready
        exsr zzzUpdStatus;

        // Run Staging Program
        RunStage(batWhsea: batId: rtncode: rtnMessage);

        // We are finished so get out
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *  *INZSR         Initialization subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
        begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'IMPITEM': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

        endsr; // zzzGetBatId
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
        begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        endsr; // zzzGetStamps
      /end-free

     *----------------------------------------------------------------
     *  zzzUpdStatus   Update Batch Status
     *----------------------------------------------------------------
      /free
        begsr zzzUpdStatus;

        // Update batch status
        exec sql
          update stgbatch
             set sbstatus = :batstat,
                 sbtext = :battext
           where sbwhse = :batwhse
             and sbbatid = :batid;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        endsr; // zzzUpdStatus
      /end-free

     *----------------------------------------------------------------
     *  zzzWrtRecord   Write record to staging file
     *----------------------------------------------------------------
      /free
        begsr zzzWrtRecord;


          stg_iubatid  = batid;
          stg_iuutyp   = ftp_iuutyp;
          stg_iustatus = 'R';
          stg_iuststs  = stamp;
          stg_iustsuc  = stampuc;
          stg_iutext   = *blanks;
          select;
            when AspenWhse;
              stg_iuitem   = %trim(ftp_iuitem) + '-'
                           + %subst(%editc(ftp_iuwhse:'X'):2:2);
              stg_iuwhse   = batwhse;
            other;
              stg_iuwhse   = ftp_iuwhse;
              stg_iuitem   = ftp_iuitem;
          endsl;
          stg_iutype   = ftp_iutype;
          stg_iudesc   = ftp_iudesc;
          stg_iuwhdp   = ftp_iuwhdp;
          stg_iustyp   = ftp_iustyp;
          stg_iudesg   = ftp_iudesg;
          stg_iuactv   = ftp_iuactv;
          stg_iubld    = ftp_iubld;
          stg_iuven    = ftp_iuven#;
          stg_iuvitm   = ftp_iuvit#;
          stg_iupdsc   = ftp_iupdsc;
          stg_iuum1    = ftp_iuum1;
          stg_iuum2    = ftp_iuum2;
          stg_iuumq2   = ftp_iuUMQ2;
          stg_iuflg1   = ftp_iuFLG1;
          stg_iuum3    = ftp_iuUM3;
          stg_iuumq3   = ftp_iuUMQ3;
          stg_iuflg2   = ftp_iuFLG2;
          stg_iuulen   = ftp_iuULEN;
          stg_iuuwdt   = ftp_iuuwdt;
          stg_iuuhgt   = ftp_iuuhgt;
          stg_iucube   = ftp_iucube;
          stg_iuswgt   = ftp_iuswgt;
          stg_iucwgt   = ftp_iucwgt;
          stg_iurepl   = ftp_iurepl;
          stg_iublnk   = ftp_iublnk;
          stg_iuflgd   = ftp_iuflgd;
          stg_iuflgb   = ftp_iuflgb;
          stg_iuslif   = ftp_iuslif;
          stg_iunday   = ftp_iunday;
          stg_iutie    = ftp_iutie;
          stg_iuhigh   = ftp_iuhigh;
          stg_iumflg   = ftp_iumflg;
          stg_iudday   = ftp_iudday;
          stg_iuuday   = ftp_iuuday;
          stg_iumday   = ftp_iumday;
          stg_iumitm   = ftp_iumitm;
          stg_iucitm   = ftp_iucitm;
          stg_iunslt   = ftp_iunslt;
          stg_iuxdck   = ftp_iuxdck;
          stg_iubnbr   = ftp_iubnbr;
          stg_iubnam   = ftp_iubnam;
          stg_iuvnam   = ftp_iuvnam;
          stg_iubrnd   = ftp_iubrnd;
          stg_iulot    = ftp_iulot;
          stg_iultrk   = ftp_iultrk;
          stg_iuoday   = ftp_iuoday;
          stg_iurg1c   = ftp_iurg1c;
          stg_iurg2c   = ftp_iurg2c;
          stg_iupqn1   = ftp_iupqn1;
          stg_iupqn2   = ftp_iupqn2;
          stg_iupqn3   = ftp_iupqn3;
          stg_impgrp   = *blanks;
          stg_imppnt   = *blanks;
          stg_impvar   = 0;
          stg_impcat   = *blanks;
          stg_impms1   = *blanks;
          stg_impms2   = *blanks;
          stg_impms3   = *blanks;
          stg_impms4   = *blanks;
          stg_impms5   = *blanks;
          stg_iuaddts  = stamp;
          stg_iuadduc  = stampuc;

          write stgrec;

        endsr; // zzzWrtRecord
      /end-free
