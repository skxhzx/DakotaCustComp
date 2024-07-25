      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  HA412     HACCP Session Id Control File
     *  10 May 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    05/10/12  LMC  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D haccps        e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     *
600fA*----------------------------------------------------------------
600fA*  Time variables
600fA*----------------------------------------------------------------
600fA
600fAD CurrStamploc    s               z
600fAD CurrStampsys    s               z
600fAD CurrStampuc     s               z
600fA
600fAD bfcoffset       s              3  0 inz(0)
600fA*----------------------------------------------------------------
600fA* Function prototypes.
600fA*----------------------------------------------------------------
600fA
600fA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $pcmd           s              8
     D $pwhse          s              3  0
     D $ppo            s              9

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    - *START
     *               - *END
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd
     C*                  parm                    $pwhse
     C*                  parm                    $ppo

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Main Processing.
         select;
           when $pcmd = '*START  ';
             exsr startsession;
           when $pcmd = '*END    ';
             exsr endsession;
         endsl;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  EndSession - Delete session Id
     *----------------------------------------------------------------

      /free
       begsr endsession;

         exec sql select * into :haccps
                  from haccps
                  where hpuser = :#user
                    and hpjob = :#job
                    and hpjobn = :#jobn;

         if sqlstt = sqlSuccess;
           exec sql delete from haccps
                where hpuser = :#user
                and hpjob = :#job
                and hpjobn = :#jobn;
           sqlstt = sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  StartSession - Create session Id
     *----------------------------------------------------------------

      /free
       begsr startsession;

         exsr zzgettime;
         exec sql select * into :haccps
                  from haccps
                  where hpuser = :#user
                    and hpjob = :#job
                    and hpjobn = :#jobn;

         if sqlstt = sqlnodata;
           exec sql insert into haccps
                (hpuser, hpjob, hpjobn, hpsid)
                values(:#user, :#job, :#jobn, :currstampsys);
           sqlstt = sqlstt;
         else;
           exec sql update haccps
                set hpsid = :CurrStampsys
                where hpuser = :#user
                and hpjob = :#job
                and hpjobn = :#jobn;
           sqlstt = sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
       endsr;
      /end-free

     *----------------------------------------------------------------
