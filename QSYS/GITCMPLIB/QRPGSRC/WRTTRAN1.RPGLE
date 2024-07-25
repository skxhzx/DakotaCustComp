      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  WRTTRAN1   Realtime gateway to WRTTRAND - Part 1
     *  30 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    08/30/12  DAS  6.40
     *      - Created.
     *    10/12/12  LMC  6.40a
     *      - Revised - changed gfiletype to 'D'. Ready for live.
640b *    11/15/12  LMC  6.40b
     *      - Revised - supress the completed job message on the
     *        sbmjob command.
650a *    01/16/13  LMC  6.50a
     *      - Revised - Job Name if based on User if client is BFC.
     *        So we don't step on each other. For all other clients
     *        job name is based on warehouse.
650b *    06/05/13  LMC  6.50b
     *      - Revised - Added JOBMSGQFL(*PRTWRAP) to sbmjob command.
650c *    09/29/13  LMC  6.50c
     *      - Revised - Kohl & Will foods and Williams will use
     *        client initials.
650d *    03/19/15  RTR  6.50d
     *      - Revised - S.Bertram, Julius Silvert, Foods Galore
     *        will use client initials.
     *
700a *    05/03/16  LMC  7.00a
     *      - Moved get client from createjobname to mainline.
     *      - Send client and location to createjobname.
700bA*    01/04/16  RTR  7.00b   Was 7.00a at BFCCloud2.
     *      - Revised - adding Indianhead, FarmBoy, Kohl Wholesale,
     *        Panos Foods to use client initials.
     *
710a *    01/27/17  LMC  7.10a
     *      - Do not allow a job to start if warehouse is 0.
710b *    08/01/17  LMC  7.10b
     *      - Added code for CBI NC locations.
710cA*    12/16/17  MLB  7.10c
     *      - Added code for T&T Produce /ServIT Cloud site.
710dA*    12/16/17  MLB  7.10d
     *      - Added code for Kelly's Foods /ServIT Cloud site.
710eA*    01/08/18  MLB  7.10e
     *      - Added code for Merit Foods /CPS Cloud3 site.
710fA*    01/08/18  MLB  7.10f
     *      - Added code for Cotati Foodservice /CPS Cloud3 site.
710gA*    01/09/18  MLB  7.10g
     *      - Added code for Marques Foods /CPS Cloud2 site.
     *
720 A*    02/06/18  MLB  7.20
     *      - Revised - Colony Foods will use client initials.
720aA*    02/06/18  MLB  7.20a
     *      - Revised - Seashore Fruit&Produce will use client initials.
720bA*    02/06/18  MLB  7.20b
     *      - Revised - Accardi Foods will use client initials.
720cA*    06/11/18  MLB  7.20c
     *      - Revised - Cheney Tifton, GA whse will use client initials.
720dA*    10/13/18  MLB  7.20d
     *      - Revised - Cheney GWB will use client initials.
720eA*    06/01/18  MLB  7.20e
     *      - Revised - Added A&D Foods to use client initials.
     *
730 A*    01/24/19  MLB  7.30
     *      - Revised - Removed 7.20c mod from pgm. Greco has their own
     *        partition at ServIT and mod no longer required.
730aA*    03/19/19  MLB  7.30a
     *      - Revised - Added code to use MIL for client initials for
     *        Milwaukee whse and PHX for Phoenix, AZ whse. This chg is
     *        needed because whse number will be 001 for all Greco whses.
730bA*    04/23/19  LMC  7.30b
     *      - Revised - Southwest Traders will use client initials.
     *        This was missed when they went live.
730c *    04/26/19  GJA  7.30c
     *      - Revised - Earls Produce will use client initials.
     *        This was missed when they went live.
730d *    06/26/19  LMC  7.30d
     *      - Fix - Earls was not using client initials, it was
     *        still using whse 001 in job name.
730e *    08/22/19  JCJ  7.30e
     *      - Enh:  changed Liebers to use client initials in job
     *        name.
730f *    11/15/19  JCJ  7.30f
     *      - Enh:  changed Holt Paper to use client initials in job
     *        name.
     *
740 A*    01/14/20  MLB  7.40
     *      - Enh:  Changed Caribbean Producers to use client initials
     *        in job name.
     *
740bA*    06/18/20  JCJ  7.40b
     *      - Enh:  Changed Natalies to use client initials
     *        in job name.
740cA*    08/16/20  MLB  7.40c
     *      - Enh:  Changed Sunrise to use client initials
     *        in job name.
     *
750a *    01/26/21  JCJ  7.50a
     *      - Enh:  Changed Shaheen to use client initials
     *        in job name.
750bA*    02/08/21  MLB  7.50b
     *      - Enh:  Changed Balford to use client initials
     *        in job name.
750cA*    02/15/21  NLK  7.50c
     *      - Revised - Cheney CFR, MLK will use client initials.
750dA*    04/14/21  JCJ  7.50d
     *      - Enh:  Changed Global Import to use client initials
     *        in job name.
750eA*    06/18/21  MLB  7.50e  SWTe
     *      - Revised - Southwest Traders will use client initials.
     *        Added code for whse 020 Fresno.
750fA*    07/17/19  MLB/RH 7.50f  SWTc
     *      - Revised - Southwest Traders will use client initials.
     *        Added code for whse 025 Stockton. Was 730c, missed mod
750gA*    06/18/21  MLB  7.50g  SWTd
     *      - Revised - Southwest Traders will use client initials.
     *        Added code for whse 015 Stockton Sbux. Missed 750d mod
750hA*    08/22/21  JCJ  7.50h
     *      - Revised - Cheney RIV to use client initials.
750iA*    09/08/21  JCJ  7.50i
     *      - Enh:  Changed New Ocean Seafood to use client initials
     *        in job name.
750jA*    09/08/21  JCJ  7.50j
     *      - Enh:  Changed Jacmar to use client initials.
750kA*    10/26/21  JCJ  7.50k
     *      - Enh:  Changed Chef's Kitchen to use client initials.
750lA*    11/23/21  JCJ  7.50l
     *      - Enh:  Changed KOS Distribution use client initials.
750mA*    02/21/22  JCJ  7.50m
     *      - Enh:  Changed RDP FoodService use client initials.
750nA*    03/20/22  MLB  7.50n
     *      - Revised - Cheney BBI to use client initials.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
USFaA*    05/03/16  LMC  USFa
     *      - Revised to just return for USF. They don't use Dakota
     *      EPM, so no need to process transactions into pirtrand.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
530aA /copy qcopysrc,p.qcmdexc

700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*----------------------------------------------------------------

USFA  /copy qcopysrc,id#usfcorp
710bA /copy qcopysrc,id#cheney
750hA /copy qcopysrc,id#cheneyr
710cA /copy qcopysrc,id#tnt
710dA /copy qcopysrc,id#kfs
710eA /copy qcopysrc,id#mrt
710fA /copy qcopysrc,id#cot
710gA /copy qcopysrc,id#mqs
730bA /copy qcopysrc,id#SWT
730cA /copy qcopysrc,id#EOP
750aA /copy qcopysrc,id#SBI
750bA /copy qcopysrc,id#BAL
750dA /copy qcopysrc,id#GIG
750iA /copy qcopysrc,id#NOS
750jA /copy qcopysrc,id#JAC
750kA /copy qcopysrc,id#CKF
750lA /copy qcopysrc,id#KOS
750mA /copy qcopysrc,id#RDP

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  first          s               n   inz(*on)
     D  gJobName       s             10

700aAD client          s             10
700aAD location        s             10
     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqname         s             10
     D  dqlib          s             10
     D  dq2data        s            500
     D  dqlen          s              5  0
     D  dqwait         s              5  0
     D  dqorder        s              2
     D  dqkeylen       s              3  0
     D  dqkey          s              1
     D  dqsenderlen    s              3  0 inz(44)

     D  dqsenderinf    ds
     D    dqbytesrtn                  7p 0
     D    dqbytesavl                  7p 0
     D    dqjobname                  10
     D    dquser                     10
     D    dqjobnum                    6
     D    dqcurruser                 10

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     D fromTS          s               z
     D toTS            s               z

     D Duration        s              7  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pCmd            s             10
     D pWait           s              2p 0
     D pWhse           s              3p 0
     D pTran#          s              7p 0
     D pFromDate       s              8p 0
     D pToDate         s              8p 0
     D pEmp#           s              5p 0

     *----------------------------------------------------------------
     *  Parameter Data Structure for data queue
     *----------------------------------------------------------------

     D  gdqParms       ds
     D   gCmd                        10
     D   gWait                        2s 0
     D   gWhse                        3s 0
     D   gTran#                       7s 0
     D   gFromDate                    8s 0
     D   gToDate                      8s 0
     D   gEmp#                        5s 0
     D   gFileType                    1
     D   gSentTS                       z

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcMinutes     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d CreateJobName   pr
700aAd  client                       10    const
700aAd  location                     10    const

     d DQ2Send         pr

     d GetCurrStamp    pr

     d SubmitWRTTRAN2  pr

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D ChkActJob       pr                  extpgm('CHKACTJOB')
     D   pJobName                    10
     D   pReturn                     10

     D GetEnv          pr                  extpgm('GETENV')
     D   pEnv                         1

650aAD GetClient       pr                  extpgm('GETCLIENT')
650aAD   pClient                     10
650aAD   pLocation                   10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pCmd        Command
     *      pWait       Wait Time
     *      pWhse       Warehouse
     *      pTran#      Transaction Number
     *      pFromDate   From Date
     *      pToDate     To Date
     *      pEmp#       Employee Number
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
640pAc                   parm                    pCmd
640pAc                   parm                    pWait
     c                   parm                    pWhse
640yAc                   parm                    pTran#
640fAc                   parm                    pFromDate
640fAc                   parm                    pToDate
640fAc                   parm                    pEmp#

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

710a    // Get out if warehouse sent in is zero.
710a    if pWhse = 0;
710a    else;
        // First time through initialization

        if first;

700aM   GetClient(client: location);
USFaA   if client = usfcorp;
USFaA     return;
USFaA   endif;

          // Hard code file type
          //   'P' = Use PIRTRANP file (initial testing)
          //   'D' = Use PIRTRAND file

640aD     //gFileType = 'P';
640aM     gFileType = 'D';

          // Create job name to be used for WRTTRAN2 submit.

700aD     //createJobName();
700aM     createJobName(client: location);

          // Submit WRTTRAN2

          SubmitWRTTRAN2();

          // Start timer for checking if WRTTRAN2 is running

          fromTS = %timestamp();

          first = *off;
        endif;

        // Check every 5 minutes to make sure WRTTRAN2 is running
        // (checking every time through was too slow)

        toTS = %timestamp();
        duration = CalcMinutes(fromTS: toTS);
        if duration > 5;
          SubmitWRTTRAN2();
          fromTS = %timestamp();
        endif;

        // Send parameters to WRTTRAN2 data queue

        gCmd       = pCmd;
        gWait      = pWait;
        gWhse      = pWhse;
        gTran#     = pTran#;
        gFromDate  = pFromDate;
        gToDate    = pToDate;
        gEmp#      = pEmp#;

        DQ2Send();

710a    endif;
        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CalcMinutes   Calculate minutes between timestamps
     *----------------------------------------------------------------

     p CalcMinutes     b
     d CalcMinutes     pi             7p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D minutes         s              7p 0

      /free

            monitor;
              minutes = %diff(toTS: fromTS: *MINUTES);
            on-error;
              minutes = 0;
            endmon;

        return minutes;

      /end-free

     p CalcMinutes     e

     *----------------------------------------------------------------
     *  CreateJobName   Create WRTTRAN2 job name
     *
     *    Job Name = 'BFCWT' + file type + warehouse + environment
     *
     *    Examples: BFCWTD001  - PIRTRAND file, whse 1, Production
     *              BFCWTP001T - PIRTRANP file, whse 1, Test
     *
     *----------------------------------------------------------------

     p CreateJobName   b
     d CreateJobName   pi
700aAd client                        10    const
700aAd location                      10    const

     *  Local Variables

     D env             s              1
700aAD*client          s             10
700aAD*location        s             10

      /free

700aD   //GetClient(client: location);

650cA   Select;
650cA     when client = 'BFC';
650cD   //if client = 'BFC';
650aA       gJobName = 'BFCWT'
650aA                + gFileType
650aA                + %subst(#user:1:3);
650cA     When client = 'KOHL';
650cA       gJobName = 'BFCWT'
650cA                + gFileType
650cA                + 'KHL';
650cA     when client = 'WILLFOODS';
650cA       gJobName = 'BFCWT'
650cA                + gFileType
650cA                + 'WIL';
650cA     when client = 'WILLIAMS ';
650cA       gJobName = 'BFCWT'
650cA                + gFileType
650cA                + 'WIF';
650dA     when client = 'SBERTRAM  ';
650dA       gJobName = 'BFCWT'
650dA                + gFileType
650dA                + 'SBR';
650dA     when client = 'JULIUSSILV';
650dA       gJobName = 'BFCWT'
650dA                + gFileType
650dA                + 'JSL';
650dA     when client = 'FOODSGALOR';
650dA       gJobName = 'BFCWT'
650dA                + gFileType
650dA                + 'FGL';
700bA     when client = 'INDIANHEAD';
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'IFD';
700bA     when client = 'FARMBOY   ';
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'FBY';
700bA     when client = 'KOHL      ';
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'KHL';
700bA     when client = 'PANOS     ';
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'PAN';
710bA     when          client = Cheney
710bA               and location  = cbigr;
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'GR';
710bA     when          client = Cheney
710bA               and location  = cbigo;
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'GO';
710bA     when          client = Cheney
710bA               and location  = cbist;
700bA       gJobName = 'BFCWT'
700bA                + gFileType
700bA                + 'ST';
720cA     when          client = Cheney
720cA               and location  = cbitif;
720cA       gJobName = 'BFCWT'
720cA                + gFileType
720cA                + 'TIF';
750cA     when          client = Cheney
750cA               and location  = cbimlk;
750cA       gJobName = 'BFCWT'
750cA                + gFileType
750cA                + 'MLK';
750cA     when          client = Cheney
750cA               and location  = cbicfr;
750cA       gJobName = 'BFCWT'
750cA                + gFileType
750cA                + 'CFR';
750hA     when          client = Cheney
750hA               and location  = cbiriv;
750hA       gJobName = 'BFCWT'
750hA                + gFileType
750hA                + 'RIV';
750nA     when          client = Cheney
750nA               and location  = cbibbi;
750nA       gJobName = 'BFCWT'
750nA                + gFileType
750nA                + 'BBI';
720dA     when          client = Cheney
720dA               and location  = cbigwb;
720dA       gJobName = 'BFCWT'
720dA                + gFileType
720dA                + 'GWB';
710cA     when          client = TnTProduce;
710cA       gJobName = 'BFCWT'
710cA                + gFileType
710cA                + 'TNT';
710dA     when          client = Kellys;
710dA       gJobName = 'BFCWT'
710dA                + gFileType
710dA                + 'KFS';
710eA     when          client = Merit;
710eA       gJobName = 'BFCWT'
710eA                + gFileType
710eA                + 'MRT';
710fA     when          client = Cotati;
710fA       gJobName = 'BFCWT'
710fA                + gFileType
710fA                + 'COT';
710gA     when          client = Marques;
710gA       gJobName = 'BFCWT'
710gA                + gFileType
710gA                + 'MQS';
720 A     when client = 'COLONYFOOD';
720 A       gJobName = 'BFCWT'
720 A                + gFileType
720 A                + 'CFI';
720aA     when client = 'SEASHORE  ';
720aA       gJobName = 'BFCWT'
720aA                + gFileType
720aA                + 'SFP';
720eA     when client = 'AANDDFOODS';
720eA       gJobName = 'BFCWT'
720eA                + gFileType
720eA                + 'ADF';
720bA     when client = 'ACCARDI   ';
720bA       gJobName = 'BFCWT'
720bA                + gFileType
720bA                + 'ACC';

730aA     when  client = 'GRECO     '
730aA       and location = 'MILWAUKEE';
730aA       gJobName = 'BFCWT'
730aA                + gFileType
730aA                + 'MIL';
730aA     when  client = 'GRECO     '
730aA       and location = 'PHOENIX  ';
730aA       gJobName = 'BFCWT'
730aA                + gFileType
730aA                + 'PHX';
730bA     when client = 'SWT       ';
750fA     select;
750fA     when location = SWTTEMECULA;
730bA       gJobName = 'BFCWT'
730bA                + gFileType
730bA                + 'SWT';
750eA     when location = SWTSTOCKTON;
750eA       gJobName = 'BFCWT'
750eA                + gFileType
750eA                + 'SW2';
750gA     when location = SWTSTKSBUX;
750gA       gJobName = 'BFCWT'
750gA                + gFileType
750gA                + 'SW3';
750eA     when location = SWTFRESNO;
750eA       gJobName = 'BFCWT'
750eA                + gFileType
750eA                + 'SW4';
750eA     endsl;
730dD     //when client = 'EOP       ';
730dM     when client = 'EARLS     ';
730cA       gJobName = 'BFCWT'
730cA                + gFileType
730cA                + 'EOP';

730eD     //when client = 'LKF       ';
730eM     when client = 'LIEBERS   ';
730eA       gJobName = 'BFCWT'
730eA                + gFileType
730eA                + 'LKF';

730fA     //when client = 'HPC       ';
730fM     when client = 'HOLTPAPER ';
730fA       gJobName = 'BFCWT'
730fA                + gFileType
730fA                + 'HPC';

740 A     when client = 'CARIBBEAN ';
740 A       gJobName = 'BFCWT'
740 A                + gFileType
740 A                + 'CPJ';

740bA     when client = 'NATALIES  ';
740bA       gJobName = 'BFCWT'
740bA                + gFileType
740bA                + 'NOJ';

740cA     when client = 'SUNRISE   ';
740cA       gJobName = 'BFCWT'
740cA                + gFileType
740cA                + 'SUN';

750aA     when client = 'SHAHEEN   ';
750aA       gJobName = 'BFCWT'
750aA                + gFileType
750aA                + 'SBI';

750bA     when client = 'BALFORD   ';
750bA       gJobName = 'BFCWT'
750bA                + gFileType
750bA                + 'BAL';

750dA     when client = 'GLOBALIMP ';
750dA       gJobName = 'BFCWT'
750dA                + gFileType
750dA                + 'GIG';

750iA     when client = 'NEWOCEAN  ';
750iA       gJobName = 'BFCWT'
750iA                + gFileType
750iA                + 'NOS';

750jA     when client = 'JACMAR    ';
750jA       gJobName = 'BFCWT'
750jA                + gFileType
750jA                + 'JAC';

750kA     when client = 'CHEFSKITCH';
750kA       gJobName = 'BFCWT'
750kA                + gFileType
750kA                + 'CKF';

750lA     when client = 'KOS       ';
750lA       gJobName = 'BFCWT'
750lA                + gFileType
750lA                + 'KOS';

750mA     when client = 'RDP       ';
750mA       gJobName = 'BFCWT'
750mA                + gFileType
750mA                + 'RDP';

650aA     other;
650dA   //else;
          gJobName = 'BFCWT'
                   + gFileType
                   + %editc(pWhse:'X');
650dD   //endif;
650cA   Endsl;

        GetEnv(env);

        if env = 'T';
          gJobName = %trimr(gJobName) + 'T';
        endif;

        return;

      /end-free

     p CreateJobName   e

     *----------------------------------------------------------------
     *  DQ2Send     Send parameters to WRTTRAN2 data queue
     *----------------------------------------------------------------

     p DQ2Send         b
     d DQ2Send         pi

      /free

        GetCurrStamp();
        gSentTS   = currStampSys;

        dq2data = gdqParms;
        dqlen   = %len(dq2data);

      /end-free

     C                   call      'QSNDDTAQ'
     C                   parm      'WRTTRAND2'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dq2data

      /free

        return;

      /end-free

     p DQ2Send         e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  SubmitWRTTRAN2  Submit WRTTRAN2 if not running
     *----------------------------------------------------------------

     p SubmitWRTTRAN2  b
     d SubmitWRTTRAN2  pi

     *  Local Variables

     D return          s             10
     D cmd             s            500

      /free

        ChkActJob(gJobName: return);

        if return = '*EXIST';
          return;
        endif;

        cmd = 'SBMJOB CMD(call wrttran2) ' +
              'JOBQ(qsysnomax) ' +
640bA         'MSGQ(*NONE) ' +
650bA         'JOBMSGQFL(*PRTWRAP) ' +
              'JOB(' + %trimr(gJobName) + ')';

        qcmdexc(%trimr(cmd): %len(%trimr(cmd)));

        return;

      /end-free

     p SubmitWRTTRAN2  e
