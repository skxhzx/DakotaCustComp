      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *
     *  OR400COP   OR400 DQ Gateway
     *  10 April 2021
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    04/10/21  DAS  7.50
     *      - Created.
     *
750a *    05/11/21  DAS  7.50a
     *      - Increased parm sizes
     *      - Increade data queue data lenght to maximum, 64512
     *
750b *    05/12/21  DAS  7.50b
     *      - When adding Uid to error messaged, chopped to first 5 char
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbfcsktlog o    e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  YAJL Definitions
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h
     d yajlerr         s            500    varying
     d docNode         s                   like(yajl_val)
     d node            s                   like(yajl_val)

     d stdNode         s                   like(yajl_val)
     d stdPointer      s               *   inz(%addr(stdBuffer))
     d stdBuffer       s           2048
     d stdLen          s             10i 0

     d inputNode       s                   like(yajl_val)
     d inputPointer    s               *   inz(%addr(inputBuffer))
     d inputBuffer     s           1024
     d inputLen        s             10i 0

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

     D  allowSubmit    s               n   inz(*on)
     D  oldJob         s               n   inz(*on)
     D  newJob         s               n   inz(*on)
     D  gJobName       s             10
     D  pass           s              3  0
     D  errmsg         s             99    varying
     D  newMaxPasses   s              3  0
     D  oldMaxPasses   s              3  0
     D  spJobqStart    s             26

     d  spapp          s             20
     d  spuser         s             10
     d  spwhereFrom    s             20
     d  spuid          s             32
     d  spwhouse       s              3
     d  errmsg500      s            500    varying
750aDd* returnStr      s           4096    varying
750aMd  returnStr      s          64512    varying

     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqname         s             10
     D  dqlib          s             10
750aDD* dqdata         s           4096    varying
750aMD  dqdata         s          64512    varying
     D  dqlen          s              5  0 inz(4096)
     D  dqwait         s              5  0
     D  dqorder        s              2
     D  dqkeylen       s              3  0 inz(32)
     D  dqkey          s             32
     D  dqsenderlen    s              3  0
     D  dqsenderinf    s             50

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
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcMinutes     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d CreateRtnError  pr

     d UpdateJsonStr   pr

     d DQClear         pr


     d DQSend          pr
750aDd* data                       4096    const varying
750aMd  data                      64512    const varying

     d DQRead          pr

     d GetUid          pr

     d GetCurrStamp    pr

     d SubmitOR400DQ   pr

     d PingOR400DQ     pr

     d WriteVoiceLog   pr
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

750fAd UpperToLower    pr         65535A   varying
750fAd  value                     65535A   varying const

     d SetPgmField     pr
     d  key                          50A   varying const
     d  value                              like(yajl_val) const

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D ChkActJob       pr                  extpgm('CHKACTJOB')
     D   pJobName                    10
     D   pReturn                     10

     D GetEnv          pr                  extpgm('GETENV')
     D   pEnv                         1

     d AppGetUid       PR                  extpgm('APPGETUID')
     d  pUid                         32

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *
     *      pJsonStr     - JSON string
     *
     *    Returned Parameters
     *
     *      pJsonStr     - JSON string
     *
     *----------------------------------------------------------------

     d OR400COP        pr                  extpgm('OR400COP')
750aDd**pJsonStr                   4096    varying options(*varsize)
750aMd  pJsonStr                  64512    varying options(*varsize)

     d OR400COP        pi
750aDd**pJsonStr                   4096    varying options(*varsize)
750aMd  pJsonStr                  64512    varying options(*varsize)

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        error = *off;

        slgbuf = '<Begin> '  + pJsonStr;
        WriteVoiceLog('Beg': slgbuf);

        // Load JSON string into memory and get pointer to root node/object

        docNode = yajl_string_load_tree( pJsonStr : yajlerr );
        if yajlerr <> '';
          errmsg500 = 'Error loading JSON string - ' + yajlerr;
          CreateRtnError();
          return;
        endif;

        stdNode = yajl_object_find(docNode: 'Std');
        if stdNode = *null;
          errmsg500 = 'Error loading Std section';
          yajl_tree_free( docNode );
          CreateRtnError();
          return;
        endif;

        stdLen = YAJL_stringify(stdNode: stdPointer: %len(stdBuffer));

        inputNode = yajl_object_find(docNode: 'Input');
        if inputNode = *null;
          errmsg500 = 'Error loading Input section';
          CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;

        inputLen = YAJL_stringify(inputNode: inputPointer: %len(inputBuffer));

        // Extract all fields from Std object

        jsonGetFields(stdNode);

        // Free memory used by jsonStr tree

        yajl_tree_free( docNode );

        // Set flags for starting OR400DQ job

        if spWhereFrom = 'LOGIN'
          or spWhereFrom = 'OR400.01';
            allowSubmit = *on;
        else;
            allowSubmit = *off;
        endif;

        // First time in for session, submit OR400 job
        // Otherwise, ping old job

        if spUid = '';

          submitOR400DQ();
          if error;
            return;
          endif;

        else;
          oldJob = *on;
          newJob = *off;
          //slgbuf = 'Using Old Id: ' + spUid;
          //WriteVoiceLog('Inf': slgbuf);
          PingOR400DQ();

        endif;

        dqwait = 2;  // seconds
        newMaxPasses = 5;
        oldMaxPasses = 2;
        pass = 0;

        dow forever = forever;

          pass += 1;

          DQRead();

          select;

            // Got response, move on
            when not error;
              leave;

            // Log new job passes
            when newJob and pass < newMaxPasses;
              slgbuf = 'Waiting on new job. '
                     + 'Pass ' + %char(pass) + ' of ' + %char(newMaxPasses)+ ' '
                     + 'expired. Trying again. ' + spUid;
              WriteVoiceLog('Inf': slgbuf);

            // For a new submitted job, we will wait longer than an old job
            when newJob and pass = newMaxPasses;
              errmsg500 = 'Session Init failed. Try again. '
                        + '(Uid ' + %subst(spUid: 1: 5) + ')';
              slgbuf = '<Error> ' + errmsg500;
              WriteVoiceLog('Err': slgbuf);
              CreateRtnError();
              return;

            // If an old job doesn't respond immediately
            // and we are allowed to submit, then submit new job.
            when oldJob and pass = 1 and allowSubmit;
              SubmitOR400DQ();
              if error;
                CreateRtnError();
                return;
              endif;

            // If an old job doesn't respond after a couple of tries
            // and we are not allowed to submit, then get out.
            when oldJob and pass = oldMaxPasses and not allowSubmit;
              errmsg500 = 'Session not found. Get out and sign back in. '
750bM                   + '(Uid ' + %subst(spUid: 1: 5) + ')';
              slgbuf = '<Error> ' + errmsg500;
              WriteVoiceLog('Err': slgbuf);
              CreateRtnError();
              return;

            // Log new job passes
            when oldJob and pass < oldMaxPasses;
              slgbuf = 'Waiting on old job. '
                     + 'Pass ' + %char(pass) + ' of ' + %char(oldMaxPasses)+ ' '
                     + 'expired. Trying again. ' + spUid;
              WriteVoiceLog('Inf': slgbuf);

           endsl;

        enddo;

        // Job for Prime session is running.


        // Send data from frontend to OR400

        slgbuf = '<Send> Sending JSON parm to OR400DQIN '
               + spUid + ' ' + pJsonStr;
        WriteVoiceLog('Inf': slgbuf);

        DQSend(pJsonStr);

        // Receive response.
        // We will wait up to 35 seconds to allow for a record lock.

        dqwait = 15;  // Seconds

        slgbuf = '<Listen> Listening to OR400DQOUT ' + spUid;
        WriteVoiceLog('Inf': slgbuf);

        DQRead();
        if error;
          errmsg500 = 'Session not responding-Try again. '
750bM               + '(Uid ' + %subst(spUid: 1: 5) + ')';
          CreateRtnError();
          slgbuf = '<Error> ' + pJsonStr;
          WriteVoiceLog('Err': slgbuf);
          return;
        endif;

        // Move returned string into return parameter

        pJsonStr = returnStr;

        toTS = %timestamp();
        duration = CalcMinutes(fromTS: toTS);

        slgbuf = '<End> ' + pJsonStr;
        WriteVoiceLog('End': slgbuf);

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
     *  CreateRtnError    Create return JSON error string
     *----------------------------------------------------------------

     p CreateRtnError  b
     d CreateRtnError  pi

      /free

         yajl_genOpen(*Off);

           yajl_beginObj();

             // Grab Std section that was sent in and added it

             yajl_addPreformattedPtr('Std': stdPointer: stdLen);

             // Add Output section

             yajl_beginObj('Output');
               yajl_addchar('nxtscr': %trim(spWhereFrom));
               yajl_addchar('errmsg': errmsg500);
               yajl_addchar('spoken': errmsg500);
             yajl_endObj();

         yajl_endObj();

         pJsonStr = YAJL_copyBufStr();

         yajl_genClose();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  UpdateJsonStr     Update JSON string with Uid
     *----------------------------------------------------------------

     p UpdateJsonStr   b
     d UpdateJsonStr   pi

     d i               s             10i 0
     d key             s             50a   varying
     d val             s                   like(yajl_val)

      /free

         yajl_genOpen(*Off);

           yajl_beginObj();

             // Add Std section, while updating uid value

             yajl_beginObj('Std');
               yajl_addchar('app': %trim(spApp));
               yajl_addchar('user': %trim(spUser));
               yajl_addchar('uid': %trim(spUid));
               yajl_addchar('whereFrom': %trim(spWhereFrom));
               yajl_addchar('whouse': %trim(spWhouse));
             yajl_endObj();

             // Grab sent Input section and add it

             yajl_addPreformattedPtr('Input': inputPointer: inputLen);

           yajl_endObj();

           pJsonStr = YAJL_copyBufStr();

         yajl_genClose();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DQClear    Clear OR400DQOUT data queue
     *----------------------------------------------------------------

     p DQClear         b
     d DQClear         pi

     C                   eval      dqkey = spUid

     C                   call      'QCLRDTAQ'
     C                   parm      'OR400DQIN'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderinf

     C                   call      'QCLRDTAQ'
     C                   parm      'OR400DQOUT'  dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderinf

     p                 e

     *----------------------------------------------------------------
     *  DQSend      Send parameters to OR400DQIN data queue
     *----------------------------------------------------------------

     p DQSend          b
     d DQSend          pi
750aDd**data                       4096    const varying
750aMd  data                      64512    const varying

      /free

        GetCurrStamp();
        //spCallStart = %char(currStampSys);

        dqkey = spUid;
        dqdata = data;

        dqlen  = %len(dqdata) + 2;

      /end-free

     C                   call      'QSNDDTAQ'
     C                   parm      'OR400DQIN'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqkeylen
     C                   parm                    dqkey

      /free

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DQRead      Read return info from OR400DQIN data queue
     *----------------------------------------------------------------

     p DQRead          b
     d DQRead          pi

      /free
         error = *off;
         dqkey = spUid;
      /end-free

     C                   call      'QRCVDTAQ'
     C                   parm      'OR400DQOUT'  dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf

      /free

         if dqlen = 0;
           error = *on;
         else;
           returnStr = %subst(dqdata:1:dqlen-2);
         endif;

        return;

      /end-free

     p                 e

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

     p                 e

     *----------------------------------------------------------------
     *  SubmitOR400DQ   Submit OR400DQ if not running
     *----------------------------------------------------------------

     p SubmitOR400DQ   b
     d SubmitOR400DQ   pi

     *  Local Variables

     D cmd             s            500

      /free
        error = *off;

        newJob = *on;
        oldJob = *off;

        // We don't want to submit OR400DQ using old Uid
        // Just because we are submitting doesn't mean old job is gone.
        // Therefore, we don't want to risk 2 jobs using same Uid

        AppGetUid(spUid);
        UpdateJsonStr();

        //slgbuf = 'Using new Id - ' + spUid;
        //WriteVoiceLog('Inf': slgbuf);

        slgbuf = 'Submitting OR400DQ with id ' + spUid;
        WriteVoiceLog('Inf': slgbuf);

        gJobName = 'OR400' + %subst(%trim(spUid): 1: 5);

        GetCurrStamp();
        spJobqStart = %char(currStampSys);

        cmd = 'SBMJOB CMD(CALL OR400DQ (' +sq+ spUid +sq+ ' '
                                          +sq+ spJobqStart +sq+ ')) ' +
              'JOBQ(qsysnomax) ' +
              'USER(' + %trim(spUser) + ') ' +
              'MSGQ(*NONE) ' +
              'JOBMSGQFL(*PRTWRAP) ' +
              'JOB(' + %trimr(gJobName) + ')';

        monitor;
          qcmdexc(%trimr(cmd): %len(%trimr(cmd)));
        on-error;
          error = *on;
750bA     errmsg500 = 'Error submitting OR400DQ (' + %subst(spUid: 1: 5) + ')';
          slgbuf = '<Error> ' + errmsg500;
          WriteVoiceLog('Err': slgbuf);
          return;
        endmon;

        // Ping submitted job

        PingOR400DQ();

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  PingOR400DQ    Ping OR400DQ job
     *----------------------------------------------------------------

     p PingOR400DQ     b
     d PingOR400DQ     pi

      /free

        DQClear();

        if newjob;
          slgbuf = '<Send> Pinging OR400DQIN with new uid ' + spUid;
        else;
          slgbuf = '<Send> Pinging OR400DQIN with old uid ' + spUid;
        endif;
        WriteVoiceLog('Inf': slgbuf);

        DQSend('*PING');

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteVoiceLog    Write record to voice log BFCSKTLOG
     *----------------------------------------------------------------

     p WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       getcurrstamp();

       slgTyp = type;

       //slgbuf = spWhereFrom
       //       + '  '
       //       + '- ' + #pgm + %trim(buffer);
       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #pgm;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     * UpperToLower   Convert uppercase to lowercase
     *----------------------------------------------------------------

     p UpperToLower    b
     d UpperToLower    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(uppercase: lowercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * SetPgmField      Set program field
     *----------------------------------------------------------------

     p SetPgmField     b
     d SetPgmField     pi
     d  key                          50A   varying const
     d  val                                like(yajl_val) const

     d lowkey          s             50A   varying

      /free

        // Force keys to lowercase to eliminate case errors

        lowkey = UpperToLower(key);

         // Move value into screen field

         monitor;

           select;

             // Standard Fields

             when lowkey = 'app';
               spApp = yajl_get_string(val);

             when lowkey = 'user';
               spUser = yajl_get_string(val);

             when lowkey = 'uid';
               spUid = yajl_get_string(val);

             when lowkey = 'wherefrom';
               spWhereFrom = yajl_get_string(val);

             when lowkey = 'whouse';
               spWhouse = yajl_get_string(val);

           endsl;

         on-error;

           error = *on;
           errmsg = 'Error extracting field ' + %trim(key);
           return;

         endmon;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  JSON Subprocedures
     *----------------------------------------------------------------

      /copy qcopysrc,$jsonstr

