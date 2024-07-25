      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  HA301     HACCP Log check to see if log exist
     *  19 September 2012
     *  Lynn McMahon
     *
     *  Revisions
     *
640 A*    09/19/12  LMC  6.40
     *      - Created.
     *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')


     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

600fA /copy qcopysrc,p.bfcdteti

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

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D*blanks          s            100    inz(' ')
     D*SubfilePage     C                   Const(12)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D hlrec         e ds                  extname(haccplog) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------



     D getwhse         pr                  extpgm('GETWHSE')
      * Input
     D   puser                        8    const
     D   pWhse                        3  0 const

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
     D  $ltbldata             19     38
     D  $lwhse                19     21  0
     d  $llevl                22     25
     D  $ltype                26     28
     D  $lusrctl              65     65
     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $ipo            s              9
     D $iitem          s             15
     D $idev           s             10
     D $iform          s             10
     D $inew           s               n

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $ppo            s                   like($ipo)
     D $pitem          s                   like($iitem)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

     D #whse           s              3  0
     D #emp#           s              5  0
     D #fnam           s             15
     D #init           s              1
     D #lnam           s             20
     D #whdp           s              5
     D #styp           s              1
     D #nhrs           s              3  1
     D #rtn            s              8
     D #BeltPrt        s              1
     D #Language       s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D*cqerm           s             60
     D*cqustr          s             17
     D*dateonly        s             10
     D*timecurr        s              8
     D*timeonly        s              8
     D*datecurr        s             19
     D*datetime        s             19
     D*fa              s              2  0
     D*first           s               n
     D*holddate        s               d
     D*holdinfo        s             76
     D*lrtnCode        s             20
     D noParmsPassed   s               n
     D*rtnCode         s             10
     D*rtnMessage      s            200
     D*saveinfo        s             76
     D*scpad           s              3  0 inz(0)
     D*$dtetme         s               z
     D*$msgf           s             10
     D*$pmsg           s              4
     D*$pprg           s             10
     D*#msgid          s              7
     D*#msgtp          s              7
     D*#pgmq           s             10
     D*#msgk           s              4
     D*dummy           s              1
     D*msgk            s              4  0
     D*sclear          s              1
     D*wkdesc          s             30
     D*wkdesc1         s             30
     D*wkRte           s              5
     D*wkWhse          s              3  0
     D*b               s             10  0
     D*chk4err         s               n
     D*zmsflag         s               n
     D*zmflag          s               n


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *SPECIAL
     *                 *PRINT
     *      $iwhse   - Warehouse
     *      $ipo     - PO#
     *      $iitem   - Item#
     *      $idev    - Printer device
     *      $iform   - Form type
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd
     C                   parm                    $iwhse
     C                   parm                    $ipo
     C                   parm                    $iitem
     C                   parm                    $inew

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2  and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
         getwhse(#user:$pwhse);
         endif;

         if %parms >= 3 and $ipo <> ' ';
           $ppo   = $ipo;
           noParmsPassed = *off;
         else;
           $ppo   = ' ';
         endif;


         if %parms >= 4 and $iitem <> ' ';
           $pitem   = $iitem;
           noParmsPassed = *off;
         else;
           $pitem   = ' ';
         endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Establish the connection to the remote machine. The -842 return
         // code indicates that the connection is already established. If
         // you want to connect to the local machine, use CONNECT RESET.

         exec sql CONNECT RESET;

         If sqlstt = sqlSuccess;
         endif;

         // Process main screen.

           exec sql select * into :hlrec
                    from haccplog
                    where hlpo   = :$ppo
                      and hlobsolete <> 'Y'
                    fetch first row only;
           if sqlstt = sqlSuccess;
             $inew = *on;
           else;
             $inew = *off;
           endif;


         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;
         // Initialize message handling

         error = *off;

       endsr;
      /end-free

