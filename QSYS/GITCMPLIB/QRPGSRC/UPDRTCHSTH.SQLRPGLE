      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

730cA*----------------------------------------------------------------
730cA*  Binding Directories
730cA*----------------------------------------------------------------

730cAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDRTCHSTH  Update RTCHSTH file
     *  28 May 2019
     *  Lynn McMahon
     *
     *  Revisions
     *
730 A*    05/28/19  LMC  7.30
     *      - Created.
730aA*    08/27/19  KDE  7.30a
     *      - Generate Random number for short id
730bA*    08/19/19  LMC  7.30b
     *      - New field to show base slots counted. Giving an idea on
     *        where they are in the process.
730cA*    10/10/19  KDE  7.30c
     *      - Update post timestamp on Finish command
730dA*    10/09/19  LMC  7.30d
     *      - In Add always load nostamp into fields RTCHPPRTS
     *        and RTCHPSTTS.
     *      - post counts if it the user cancels. They may have
     *        counted some of the slots in type 3 or 4 prior to cancel
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *    xx/xx/xx  xxx  xxxa
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.pirrtc#

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------


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
     *  Variables
     *----------------------------------------------------------------

     D rtchrec       E ds                  extname(rtchsth) inz(*EXTDFT)

     D client          s             10
     D clientloc       s             10

730aAd loopcnt         s              5  0
     d newuid          s              7p 0
     d maxsid          s              3p 0
     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
730aAd rannum          s              8  8
730cAD CurrStamploc    s               z
730cAD CurrStampsys    s               z
730cAD CurrStampuc     s               z
730cAD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pWhse          s              3p 0
     d  pCmd           s             10
     d  pUID           s              7p 0
     D  pcnttype       s              2p 0
     d  SlotCnt        s              7p 0
     d  BaseCnt        s              7p 0
730bAd  BaseCntWIP     s              7p 0
     d  AdjCnt         s              7p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d Add             pr
     d Finish          pr
     d Cancel          pr
730bAd UpdateWIP       pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pCmd        Command
     *      pUID        Count Id
     *      pcnttype    Count type
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pCmd
     c                   parm                    pUID
     c                   parm                    pcnttype

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         Select;
           when pCmd = 'ADD';
             Add();
           when pCmd = 'CANCEL';
             Cancel();
           when pCmd = 'FINISH';
             exsr getCurrStamp;
             Finish();
730bA      when pCmd = 'UPDATE';
730bA        UpdateWIP();
         Endsl;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Add           Add RTCHSTH record
     *----------------------------------------------------------------

     p Add             b
     d Add             pi

      /free

730dD   //if pCntType=1;  // Scope Count
730aA      // Update will pages printed
730aA      rtchpprts=noStamp;
730aA      rtchpstts=noStamp;
730dD   //endif;

        newuid = 0;
        pirrtc#(newuid);
        // get the short id - can't be an open id
730aD   //exec sql select max(rtchsid) into :maxSid
730aD   //         from rtchsth
730aD   //         where rtchwhse = :pWhse
730aD   //           and rtchsts = 1;
730aA   // get random three digit number for short id.
730aA   // seed with micro seconds from timestamp to get different
730aA   // number each time.  Returns decimal between 0 and 1
730aA   exec sql select RAND(MICROSECOND(CURRENT_TIMESTAMP)) into :rannum
730aA                   from sysdummy1;
730aA   loopcnt=0;
730aA   dow forever=forever;
730aA      loopcnt = loopcnt + 1;
730aA      monitor;
730aA        rtchsid =  rannum * 1000;
730aA      on-error;
730aA        rtchsid = 999;
730aA      endmon;
730aA      // confirm number not open
730aA      maxSid=0;
730aA      // loop first 999 times trying to find a unique
730aA      // unused short id.  After that simply used the
730aA      // first random number not open
730aA      if loopcnt > 999;
730aA         exec sql select rtchsid into :maxSid
730aA                  from rtchsth
730aA                 where rtchwhse = :pWhse
730aA                   and rtchsts <> 8 and rtchsts <>9
730aA                   and rtchsid = :rtchsid;
730aA      else;
730aA         exec sql select rtchsid into :maxSid
730aA                  from rtchsth
730aA                 where rtchwhse = :pWhse
730aA                   and rtchsid = :rtchsid;
730aA      endif;
730aA      if maxSid = rtchsid;
730aA         // If the above query finds the initial random
730aA         // short id as being open then request the next
730aA         // and loop
730aA         // after initial seed of Microseconds you can
730aA         // simply do RAND() which runs off the initial seed
730aA         exec sql select RAND() into :rannum
730aA                  from sysdummy1;
730aA         iter;
730aA      else;
730aA         // otherwise leave since we have an unused
730aA         // random short id
730aA         leave;
730aA      endif;
730aA   enddo;
        rtchwhse = pwhse;
        rtchuid = newuid;
730aD   // rtchsid = maxsid + 1;
        rtchsts = '1';
        rtchutflg = ' ';
        rtchtype = pcnttype;
        exec sql insert into rtchsth values(:rtchrec);
        puid = newuid;

      /end-free

     p Add             e

     *----------------------------------------------------------------
     *  Cancel        Cancel RTCHSTH record
     *----------------------------------------------------------------

     p Cancel          b
     d Cancel          pi

      /free

730dD   //Exec Sql
730dD     //UPDATE rtchsth
730dD     //SET rtchsts = '8'
730dD          //where rtchwhse = :pwhse
730dD          //and rtchsts = 1
730dD          //and rtchuid = :puid;

730dA   // get base slot and total slots
730dA   SlotCnt = *zeros;
730dA   exec sql select count(*) into :SlotCnt
730dA              from rtchstd
730dA            where rtcdwhse = :pwhse and
730dA                  rtcduid = :puid;

730dA   BaseCnt = *zeros;
730dA   exec sql select count (distinct rtcdbase)
730dA              into :BaseCnt
730dA             from rtchstd
730dA            where rtcdwhse = :pwhse and
730dA                  rtcduid = :puid;

730dA   BaseCntWIP = *zeros;
730dA   exec sql select count (distinct rtcdbase)
730dA              into :BaseCntWIP
730dA             from rtchstd
730dA            where rtcdwhse = :pwhse and
730dA                  rtcduid = :puid;

730dA   AdjCnt = *zeros;
730dA   exec sql select count (distinct rtcldisp)
730dA              into :AdjCnt
730dA             from rtchstl
730dA            where rtclwhse = :pwhse and
730dA                  (rtcladj1 <> 0 or rtcladj2 <> 0 or rtcladj3 <> 0) and
730dA                  rtcluid = :puid;

730dA   Exec Sql
730dA     UPDATE rtchsth
730dA     SET rtchsts = '8',
730dA         rtchbasslt = :BaseCnt,
730dA         rtchbascnt = :BaseCntWIP,
730dA         rtchttlslt = :SlotCnt,
730dA         rtchadj    = :AdjCnt,
730dA         rtchpstts  = :currstampsys
730dA          where rtchwhse = :pwhse
730dA          and rtchsts = 1
730dA          and rtchuid = :puid;
      /end-free

     p Cancel          e

     *----------------------------------------------------------------
     *  Finish        Finish and Update RTCHSTH record
     *----------------------------------------------------------------

     p Finish          b
     d Finish          pi

      /free

        // get base slot and total slots
        SlotCnt = *zeros;
        exec sql select count(*) into :SlotCnt
                   from rtchstd
                 where rtcdwhse = :pwhse and
                       rtcduid = :puid;

        BaseCnt = *zeros;
        exec sql select count (distinct rtcdbase)
                   into :BaseCnt
                  from rtchstd
                 where rtcdwhse = :pwhse and
                       rtcduid = :puid;

730bA   BaseCntWIP = *zeros;
730bA   exec sql select count (distinct rtcdbase)
730bA              into :BaseCntWIP
730bA             from rtchstd
730bA            where rtcdwhse = :pwhse and
730bA                  rtcduid = :puid;

        AdjCnt = *zeros;
        exec sql select count (distinct rtcldisp)
                   into :AdjCnt
                  from rtchstl
                 where rtclwhse = :pwhse and
                       (rtcladj1 <> 0 or rtcladj2 <> 0 or rtcladj3 <> 0) and
                       rtcluid = :puid;

        Exec Sql
          UPDATE rtchsth
          SET rtchsts = '9',
              rtchbasslt = :BaseCnt,
730bA         rtchbascnt = :BaseCntWIP,
              rtchttlslt = :SlotCnt,
              rtchadj    = :AdjCnt,
730cA         rtchpstts  = :currstampsys
               where rtchwhse = :pwhse
               and rtchsts = 1
               and rtchuid = :puid;

      /end-free

     p Finish          e
730bA*----------------------------------------------------------------
730bA*  UpdateWIP     Update WIP RTCHSTH record
730bA*----------------------------------------------------------------

730bAp UpdateWIP       b
730bAd UpdateWIP       pi

730bA /free

730bA   BaseCntWIP = *zeros;
730bA   exec sql select count (distinct rtcdbase)
730bA              into :BaseCntWIP
730bA             from rtchstd
730bA            where rtcdwhse = :pwhse and
730bA                  rtcduid = :puid;


730bA   Exec Sql
730bA     UPDATE rtchsth
730bA         set
730bA         rtchbascnt = :BaseCntWIP
730bA          where rtchwhse = :pwhse
730bA          and rtchsts = 1
730bA          and rtchuid = :puid;

730bA /end-free

730bAp UpdateWIP       e
