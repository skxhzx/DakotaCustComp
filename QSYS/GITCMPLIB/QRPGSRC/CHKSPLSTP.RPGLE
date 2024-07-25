417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKSPLSTP   Check if zone/stop is split
     *              Main logic taken from PS160.
     *  29 Nobember 2007
     *  Dave Sommerville
     *
     *  Revisions:
     *
510 A*    11/29/07  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fworklbl9  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D chksplstp       pr                  extpgm('CHKSPLSTP')
      * Input
     D    pWhse                       3p 0
     D    pRtid                       5a   varying const
     D    pComp                       1a   varying const
     D    pStop                       2p 0
      * Output
     D    pFlag                       1p 0
      * Usage flags
     D    n_Whse                      5i 0
     D    n_Rtid                      5i 0
     D    n_Comp                      5i 0
     D    n_Stop                      5i 0
     D    n_Flag                      5i 0
      * SQL standard fields
     D    Sql_State                   5a
     D    Function                  139a   varying const
     D    Specific                  128a   varying const
     D    MsgText                    70a   varying
     D    CallType                    5i 0 const

     *----------------------------------------------------------------
     * Function CHKSPLSTP.
     *----------------------------------------------------------------

     D chksplstp       pi
      * Input
     D    pWhse                       3p 0
     D    pRtid                       5a   varying const
     D    pComp                       1a   varying const
     D    pStop                       2p 0
      * Output
     D    pFlag                       1p 0
      * Usage flags
     D    n_Whse                      5i 0
     D    n_Rtid                      5i 0
     D    n_Comp                      5i 0
     D    n_Stop                      5i 0
     D    n_Flag                      5i 0
      * SQL standard fields
     D    Sql_State                   5a
     D    Function                  139a   varying const
     D    Specific                  128a   varying const
     D    MsgText                    70a   varying
     D    CallType                    5i 0 const

     *----------------------------------------------------------------
     *  Current record read data fields.
     *----------------------------------------------------------------

     D curds1          ds
     D  lwcomp                 1      1
     D  lwstop                 2      3  0

     D                 ds
     D  lwpal6                 1      6  0
     D  lwplsq                 7      7  0
     D  lwpal#                 1      7  0

     D curds2          ds
     D  lwpal                  1      6  0

     *  Hold fields.

     D hldds1          ds
     D  hlcomp                 1      1
     D  hlstop                 2      3  0
     *  Pallet id data structure
     *
     *    HLPAL#  -  Pallet id.
     *    HLPLXX  -  Unused.
     *    HLPLGN  -  Generation.
     *    HLPLRW  -  Pallet row.
     *    HLPLCL  -  Pallet column.
     *    HLPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     D hldds2          ds
     D  hlpal#                 1      6  0
     D  hlplxx                 1      2  0
     D  hlplgn                 3      3  0
     D  hlplrw                 4      5  0
     D  hlplcl                 6      6  0

     D hldds3          ds
     D  hlpcs                  1      5  0
     D  hlcube                 6     14  3
     D  hlswgt                15     23  2

     D hldds4          ds
     D  hltype                 1      1
     D  hlgen                  2      2  0
     D  hlpal7                 3      9  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $kWhse          s                   like(lwwhse)
     D $kRtid          s                   like(lwrte)
     D $kComp          s                   like(lwcomp)
     D $kStop          s                   like(lwstop)

     D forever         s               n
     D first           s              1
     D pltcnt          s              5  0
     D stpchg          s              1

     *----------------------------------------------------------------
     * Constants
     *----------------------------------------------------------------

     D PARM_NULL       C                   CONST(-1)
     D PARM_NOTNULL    C                   CONST(0)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse       Warehouse
     *      $prtid       Route id
     *      $pfromplid   From pallet id
     *      $pfromlbl#   From label #
     *      $ptoplid     To pallet id
     *
     *    Returned Parameters
     *      $prtn   Return code
     *      $perm   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       // Verify that we received input

          if (n_Whse = PARM_NULL);
              SQL_State = '38999';
              MsgText = 'Warhouse is required';
              return;
          endif;

          if (n_Rtid = PARM_NULL);
              SQL_State = '38999';
              MsgText = 'Route Id is required';
              return;
          endif;

          if (n_Comp = PARM_NULL);
              SQL_State = '38999';
              MsgText = 'Compartment is reuired';
              return;
          endif;

          if (n_Stop = PARM_NULL);
              SQL_State = '38999';
              MsgText = 'Stop is reuired';
              return;
          endif;

          pFlag  = 0;
          n_Flag  = PARM_NOTNULL;
          SQL_State = '00000';
          MsgText = ' ';

          first = *off;
          stpchg = *off;
          hldds1 = *loval;
          hldds2 = *loval;
          hldds3 = *zeros;
          pltcnt = 0;

          $kWhse = pWhse;
          $kRtid = pRtid;
          $kComp = pComp;
          $kStop = pStop;

      /end-free

     C     partky        setll     worklbl9
     C                   dow       forever = forever
     C     partky        reade     worklbl9
     C                   if        %eof
     C                   leave
     C                   endif
417bA
417bA*    Ignore label items that will be put on Merge pallet.
417bA
417bAC                   if        lwgen = 2  and
417bAC                             lwtype = 'O'
     C                   iter
     C                   endif
510bA
510bA*    Ignore bulk pick records.
510bA
510bAC                   if        lwtype = 'B'
510bAC                   iter
510bAC                   endif

510bA*    Process record.
510bA
     C                   select
     C                   when      curds1 <> hldds1  and
     C                             first = *off
     C                   eval      first = *on
     C                   eval      hldds1 = curds1
     C                   eval      hlpal# = -1
     C                   eval      stpchg = *on

     C                   when      curds1 <> hldds1

     C                   if        pltcnt > 1
     C                   leave
     C                   endif

     C                   eval      pltcnt = *zeros
     C                   eval      hldds1 = curds1
     C                   eval      hlpal# = -1
     C                   eval      stpchg = *on

     C                   endsl

     *       Check for split pallets for this stop.

     C                   eval      lwpal = lwpal6

     C                   select
     C                   when      curds2 <> hldds2
     C                   add       1             pltcnt

     C                   eval      hldds3 = *zeros
     C                   eval      hldds2 = curds2

417bA*    When processing Merge label, get info from order pallet.

417bAC                   if        lwtype = 'M'
417bAC                   eval      hltype = 'O'
417bAC                   eval      hlgen = 1
417bAC                   else
     C                   eval      hltype = lwtype
     C                   move      lwgen         hlgen
417bAC                   endif
     C                   eval      hlpal7 = lwpal#

     C                   endsl

     C                   eval      stpchg = *off

     C                   enddo

     C                   if        pltcnt > 1
     C                   eval      pFlag = 1
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define partial key for main file.

     C     partky        klist
     C                   kfld                    $kWhse
     C                   kfld                    $kRtid
     C                   kfld                    $kComp
     C                   kfld                    $kStop

     C                   endsr
