      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTRCVTRN   Manages the creation of the RCVPO/RCVRTN
     *  22 May 2013
     *  Lynn McMahon
     *
     *  Revisions
     *
650aA*    05/22/13  LMC  6.50a
     *      - Created
700aA*    06/10/16  LMC  7.00a
     *      - Enh - to get the user passed in from Gui.
720aA*    02/05/18  LMC  7.20a
     *      - Enh - when closing call adjtran2 directly.
     *        user was not being loaded correctly from gui.
720bA*    03/23/18  LMC  7.20b
     *      - Fix - when closing call adjtran2 directly.
     *        user was not being loaded correctly from gui.
     *        send crtuser to adjtran2
720cA*    04/12/18  LMC  7.20c
     *      - Fix - Send correct employee number when starting the
     *        idle.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fpirtran   if   e           k disk

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjt2          c                   const('ADJTRAN2')

     D @cvtdt          c                   const('CVTDTE')

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D
     D error           s               n
     D forever         s               n
700aAD crtUser         s                   like(#user)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd     *RETURN     - Returns
     *                *PO         - Purchase Order
     *      $psubcmd  *CREATE     - Create/Start
     *                *CLOSE      - Close
     *                *COMPLETE   - Complete transaction
     *                *CLEAN      - Clean up leftovers
     *                *CHECK      - Check to make sure transaction is open
     *                *DELETE     - creates a reversing transaction
     *      $pwhse    Warehouse
     *      $ppcs     Pieces
     *      $ppallets Pallets
     *      $psavetrn Transaction#
     *      $pord     PO# or Return Order#
     *
     *    Returned Parameters
     *      $prtn   blanks   - No problem encountered.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $psubcmd         10
     C                   parm                    $pwhse            3 0
     C                   parm                    $ppcs             5 0
     C                   parm                    $ppallets         5 0
     C                   parm                    $psavetrn         7 0
     C                   parm                    $pord             9
     C                   parm                    $pitstyp          1
     C                   parm                    $pitwhdp          5
     C                   parm                    $prtn            10
700aAC                   parm                    $puser           10

     C                   eval      $prtn = ' '

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


     *  Execute appropriate routine

      /free
700aA   if %parms >= 11;
700aA     crtuser = $puser;
700aA   else;
700aA     crtuser = #user;
700aA   endif;
        exsr Process;
        return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10


     C                   endsr
     *----------------------------------------------------------------
     *
     *  PROCESS      Manage sub command activity.
     *
      /free
        begsr process;
          select;
            when $psubcmd = '*CLEAN';
              exsr zzrcvclean;
            when $psubcmd = '*CLOSE';
              exsr zzrcvclose;
            when $psubcmd = '*CREATE';
              exsr zzrcv;
            when $psubcmd = '*CHECK';
              exsr zzrcvcheck;
            when $psubcmd = '*COMPLETE';
              exsr zzrcvcomplete;
              exsr zzrcvclose;
            when $psubcmd = '*DELETE';
              exsr zzrcv;
              exsr zzrcvcomplete;
              exsr zzrcvclose;
            other;
          endsl;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZENDI  End current Indirect task.
     *
     C     zzendi        begsr
     *
     *    Send currect Direct transaction number to ensure that this
     *    transaction doesn't get closed by mistake.
     *
     C                   eval      @ptrn# = $psavetrn
     *
     C                   call      @adjtr
     C                   parm      '*CLOSEI '    @pcmd
     C                   parm                    #job
     C                   parm                    @ptrn#
     C                   parm      *blanks       @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      *blanks       @pstyp
     C                   parm      0             @pcube
     C                   parm      0             @pswgt
     C                   parm      0             @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
     C                   parm      ' '           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZIDLE   Create and Start an Idle task.
     *
     C     zzidle        begsr
     *
     C                   eval      @pdate = 0
     C                   eval      @ptime = 0

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd2           10
     C                   parm                    #pgm
     C                   parm      '*INTER'      @ptype            8
     C                   parm      0             @ptrn#
     C                   parm      'IDLE'        @ptask
     C                   parm      $pwhse        @pwhse
     C                   parm                    @pwhdp
     C                   parm                    @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm      0             @ppcs
     C                   parm                    @paisl
     C                   parm      0             @pqty1
     C                   parm                    @pqty2
     C                   parm                    @pqty3
     C                   parm                    @prte
     C                   parm                    @ppo
     C                   parm                    @pgrp1
     C                   parm                    @pgrp2
     C                   parm                    @pdate            8 0
     C                   parm                    @ptime            6 0
720cDC*                  parm      #user         @puser           10
720cMC                   parm      CrtUser       @puser           10
     C                   parm                    @prtn
     C                   parm                    @pmsg
     C
     C     endidl        endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVCHECK check for started RCVPO Transaction
     *
     C     zzrcvcheck    begsr
     *
     *  See if RCVPO transaction is status 2 - start new if needed
     *
      /free
         if $psavetrn > 0;
           chain ($psavetrn) pirtran;
           if %found(pirtran);
             select;
               when ptstat = '3';
                 exsr zzrcvabend;
                 exsr zzrcv;
               when ptstat = '4';
                 exsr zzrcv;
               other;
             endsl;
           else;
             exsr zzrcv;
           endif;
         endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVCCLEAN Cleanup started/ended RCVVPO/RCVRTN transaction
     *
      /free
         begsr zzrcvclean;

           if $psavetrn > 0;
             chain ($psavetrn) pirtran;
             if %found(pirtran);
               select;
                 when ptstat = '2';
                   exsr zzrcvclose;
                 when ptstat = '3';
                   exsr zzrcvclose;
                 other;
               endsl;
             endif;
           endif;

         endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZRCV    Create receiver transaction.
     *
     C     zzrcv         begsr
     *
     *     clear the return field used in po236
     *
     c                   eval      $prtn = ' '
     *
     *     Get transaction number
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     c                   eval      $psavetrn   = pttrn#
     *
     *    Close any open(Inuse) Indirect tasks.
     *
     C                   exsr      zzendi

     *
     *        Create transaction record.
     *
     C                   eval      @pwhdp = $pitwhdp
     C                   eval      @pstyp = $pitstyp
      /free
         select;
           when $pcmd = '*PO';
             @ptask = 'RCVPO';
             @pgrp1 = 'P';
           when $pcmd = '*RETURN';
             @ptask = 'RCVRTN';
             @pgrp1 = 'R';
          endsl;
      /end-free
     *
700aDC*                  call      @addtr
700aDC*                  parm      '*CRTSTRT'    @pcmd             8
700aMC                   call      'ADJTRAN2'
700aMC                   parm      '*CRTSTRT'    @pcmd2           10
700aDC*                  parm                    #job
700aAC                   parm                    #pgm
700aAC                   parm      '*INTER'      @ptype            8
     C                   parm      $psavetrn     @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $pord         @ppo              9
     C                   parm                    @pgrp1            1
     C                   parm      ' '           @pgrp2            1
700aAC                   parm                    @pdate            8 0
700aAC                   parm                    @ptime            6 0
700aAC                   parm      CrtUser       @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVCLOSE  Close RCVPO transaction.
     *
     C     zzrcvclose    begsr
     c                   if        $psavetrn > 0
720aDC*                  call      @addtr
720aDC*                  parm      '*CLOSE  '    @pcmd             8
720aDC*                  parm                    #job
720aDC*                  parm      $psavetrn     @ptrn#            7 0
720aDC*                  parm                    @ptask            6
720aDC*                  parm      $pwhse        @pwhse            3 0
720aDC*                  parm                    @pwhdp            5
720aDC*                  parm                    @pstyp            1
720aDC*                  parm                    @pcube            9 3
720aDC*                  parm                    @pswgt            9 2
720aDC*                  parm                    @ppcs             5 0
720aDC*                  parm      0             @paisl            5 0
720aDC*                  parm                    @pqty1            5 0
720aDC*                  parm      0             @pqty2            5 0
720aDC*                  parm      0             @pqty3            5 0
720aDC*                  parm      '0'           @prte             5
720aDC*                  parm      ' '           @ppo              9
720aDC*                  parm      ' '           @pgrp1            1
720aDC*                  parm      ' '           @pgrp2            1
720aDC*                  parm      ' '           @prtn             8
720aDC*                  parm      ' '           @pmsg             4

720aAC                   call      'ADJTRAN2'
720aAC                   parm      '*CLOSE  '    @pcmd2
720aAC                   parm                    #pgm
720aAC                   parm      '*INTER'      @ptype
720aAC                   parm      $psavetrn     @ptrn#
720aAC                   parm                    @ptask
720aAC                   parm                    @pwhse
720aAC                   parm                    @pwhdp
720aAC                   parm                    @pstyp
720aAC                   parm                    @pcube
720aAC                   parm                    @pswgt
720aAC                   parm                    @ppcs
720aAC                   parm                    @paisl
720aAC                   parm                    @pqty1
720aAC                   parm                    @pqty2
720aAC                   parm                    @pqty3
720aAC                   parm                    @prte
720aAC                   parm                    @ppo
720aAC                   parm                    @pgrp1
720aAC                   parm                    @pgrp2
720aAC                   parm      0             @pdate
720aAC                   parm      0             @ptime
720bDC*                  parm                    @puser
720bMC                   parm      crtuser       @puser
720aAC                   parm                    @prtn
720aAC                   parm                    @pmsg
     *
     *   Start an 'IDLE' task, if no open task.
     *
     C                   exsr      zzidle
     c                   endif
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZRCVCOMPLETE  complete RCVPO/RCVRTN transaction.
     *
     C     zzrcvcomplete begsr

     C                   call      @addtr
     C                   parm      '*INCTTL '    @pcmd             8
     C                   parm                    #job
     C                   parm      $psavetrn     @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      $ppcs         @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      $ppallets     @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @prtn             8
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCVCABEND  Close RCVPO/RCVRTN for abnormal end transaction.
     *
     C     zzrcvabend    begsr
     c                   if        $psavetrn > 0
     C                   call      @addtr
     C                   parm      '*CLOSE  '    @pcmd             8
     C                   parm                    #job
     C                   parm      $psavetrn     @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm                    @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm                    @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     c                   endif
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZRCVRTN Create receiver transaction.
     *
     C     zzrcvrtn      begsr
     *
     *     clear the return field used in po236
     *
     c                   eval      $prtn = ' '
     *
     *     Get transaction number
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     c                   eval      $psavetrn   = pttrn#
     *
     *    Close any open(Inuse) Indirect tasks.
     *
     C                   exsr      zzendi

     *
     *        Create transaction record.
     *
     C                   eval      @pwhdp = $pitwhdp
     C                   eval      @pstyp = $pitstyp
     C*                  move      w1ord         rtnord
     *
     C                   call      @addtr
     C                   parm      '*CRTSTRT'    @pcmd             8
     C                   parm                    #job
     C                   parm      $psavetrn     @ptrn#            7 0
     C                   parm      'RCVRTN'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      $pord         @ppo              9
     C                   parm      'R'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   endsr
