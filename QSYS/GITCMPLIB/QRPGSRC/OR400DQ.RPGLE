      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     Hbnddir('BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *
     *  OR400DQ    Unique SelectPrime OR400 session
     *  13 April 2021
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    04/13/21  DAS  7.50
     *      - Created.
     *
750a *    05/11/21  DAS  7.50a
     *      - Increased data queue data lenght to maximum, 64512
     *      - Increased parm sizes
     *
750b *    05/12/21  DA  7.50b
     *     - Revised to shut down program upon OR400 call error
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

     *----------------------------------------------------------------
     *  YAJL Header
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

     d outputNode      s                   like(yajl_val)

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

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  gMessage       s           4096
     D  minutesToWait  s              2p 0
     D  jType          s              1
     D  return         s             10
     D  jobqEnd        s             26
750aDd* jsonStr        s           4096    varying
750aMd  jsonStr        s          64512    varying
     d  errmsg500      s            500    varying
     d  errmsg         s             99    varying
     d  nxtscr         s             20
750bAd  abort          s               n

     d  spapp          s             20
     d  spuser         s             10
     d  spwhereFrom    s             20
     d  spuid          s             32
     d  spwhouse       s              3
     d  pwd            s             30


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

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.jsonstr

     d CreateRtnError  pr

     d DQClear         pr

     d DQSend          pr
750aDd* data                       4096    const varying
750aMd  data                      64512    const varying

     d DQRead          pr

     d GetCurrStamp    pr

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

      /copy qcopysrc,p.or400

     D ChkActJob2      pr                  extpgm('CHKACTJOB2')
     D   pJobName                    10
     D   pReturn                     10

     D GetJType        pr                  extpgm('GETJTYPE')
     D   pJType                       1

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pDQKey
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     C                   Parm                    pDQkey           32
     C                   Parm                    jobqStart        26

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        dqKey = pDQkey;

        gMessage = '<Begin> '
                 + %trimr(#job) + ' started for key ' + dqKey;
        WriteVoiceLog('Inf': gMessage);

        GetCurrStamp();
        jobqEnd = %char(currStampSys);

        // Set time to wait for something to be set, in minutes
        // If nothing sent, we will shut down.

        minutesToWait = 90;
        dqWait = minutesToWait * 60;

        // Clear any left over commands from OR400QDOUT data queue.

        DQClear();

        // Now we go into a loop waiting for something to do.

        dow forever = forever;

          error = *off;
          errmsg500 = '';
          spWhereFrom = '';

          gMessage = '<Listen> Listening to OR400DQIN ' + dqkey;
          WriteVoiceLog('Inf': gMessage);
          DQRead();

          // If error occured (nothing sent during wait time),
          // Then assume frontend no longer working, so end program.

          if error;
            gMessage = '<End> '
                     + 'Ending Job - No activity for '
                     + %char(minutesToWait) + ' minutes. ' + dqkey;
            WriteVoiceLog('Inf': gMessage);
            return;
          endif;

          //spparms = spdqparms;
          //spStartEnd = spdqStartEnd;

          //spJobqStart = jobqStart;
          //spJobqEnd = jobqEnd;
          //GetCurrStamp();
          //spCallEnd = %char(currStampSys);

          // See if we are shutting down or just being pinged

          select;

            when jsonStr = '*SHUTDOWN';
              gMessage = '<*SHUTDOWN> Shutting down ' + dqkey;
              WriteVoiceLog('Inf': gMessage);
              return;

            when jsonStr = '*PING';
              gMessage = '<Send> Return PING on OR400DQOUT ' + dqkey;
              WriteVoiceLog('Inf': gMessage);
              DQSend(jsonStr);
              iter;

          endsl;

          // Process screen

          gMessage = '<Received> Received on OR400DQIN ' + dqKey + ' ' +jsonStr;
          WriteVoiceLog('Inf': gMessage);

750bA     abort = *off;
          //monitor;
            or400 (jsonStr);
          //on-error;
750bA     //  abort = *on;
750bD     //  errmsg500 = 'Error calling OR400';
750bM     //  errmsg500 = 'Error calling OR400. Get out and sign back in.';
          //  CreateRtnError();
          //endmon;

          // Return spParms

          //GetCurrStamp();
          //spRtnStart = %char(currStampSys);

          //spdqparms = spparms;
          //spdqStartEnd = spStartEnd;

          gMessage = '<Send> Sending OR400 response to OR400DQOUT '
                   + dqkey + ' - ' + jsonStr;
          WriteVoiceLog('Inf': gMessage);
          DQSend(jsonStr);

          // If user went back to signon screen, end job

750bA     if not abort;
            nxtscr = '';
            docNode = yajl_string_load_tree( jsonStr : yajlerr );
            if yajlerr = '';
              outputNode = yajl_object_find(docNode: 'Output');
              if outputNode <> *null;
                nxtscr = jsonGetValue(outputNode: 'nxtscr');
              endif;
              yajl_tree_free( docNode );
            endif;
750bA     endif;

750bM     if nxtscr = 'LOGOUT' or abort;
            *inlr = *on;
            leave;
          endif;

        enddo;

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

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
750bA          yajl_addchar('nxtscr': %trim(spWhereFrom));
               yajl_addchar('errmsg': errmsg500);
               yajl_addchar('spoken': errmsg500);
             yajl_endObj();

         yajl_endObj();

           jsonStr = YAJL_copyBufStr();

         yajl_genClose();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DQClear    Clear OR400DQOUT data queue
     *----------------------------------------------------------------

     p DQClear         b
     d DQClear         pi

     C                   call      'QCLRDTAQ'
     C                   parm      'OR400DQOUT'  dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderinf

     p                 e

     *----------------------------------------------------------------
     *  DQSend      Send return values back to OR400DQOUT data queue
     *----------------------------------------------------------------

     p DQSend          b
     d DQSend          pi
750aDd* data                       4096    const varying
750aMd  data                      64512    const varying

      /free

        //GetCurrStamp();
        //spRtnStart = %char(currStampSys);
        //spdqparms = spparms;
        //spdqStartEnd = spStartEnd;
        dqdata = data;
        dqlen  = %len(dqdata) + 2;

      /end-free

     C                   call      'QSNDDTAQ'
     C                   parm      'OR400DQOUT'  dqname
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

     C                   call      'QRCVDTAQ'
     C                   parm      'OR400DQIN'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
     C                   parm                    dqwait
     C                   parm      'EQ'          dqorder
     C                   parm                    dqkeylen
     C                   parm                    dqkey
     C                   parm                    dqsenderlen       3 0
     C                   parm                    dqsenderinf      50

      /free

         if dqlen = 0;
           error = *on;
         else;
           jsonStr = %subst(dqdata:1:dqlen-2);
           //spStartEnd = spdqStartEnd;
           //GetCurrStamp();
           //spCallEnd = %char(currStampSys);
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

     p GetCurrStamp    e

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
       //       + '    '
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
       slgid  = dqKey;
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

