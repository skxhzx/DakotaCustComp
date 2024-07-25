      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PFILES2   Staging Export - Pick Labels
     *  16 May 2017
     *  Mike Rooker
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    05/16/17  MR  7.10
     *      - Created
     *
710 B*    07/31/17  RTR 7.10b
     *      - Various fixes.
     *
710 C*    10/02/17  MR  7.10c
     *      - Force read of EXPSPLBL to start at beginning of file.
     *
730 C*    02/10/19  MLB 7.30
     *      - Fix: Revised pgm to receive $pcmd, $pwhse, $pbatid from
     *        PFILES. Revised pgm to process records in EXPSPLBL file
     *        for single batch id only. Pgm was reading complete file
     *        every time. Every route processed was causing ever longer
     *        run times for each route.
     *
730aA*    11/03/19  DAS  7.30a
     *      - Revised to use LABELW, PIRTRANDW
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
730aDF*irtrand  if   e           k disk
730aMFpirtrandw if   e           k disk
     Fpirtran4  if   e           k disk
710bD**Fordh3     if   e           k disk
710bMFordh4     if   e           k disk
710bAFordhm     if   e           k disk
     Fordd      if   e           k disk
     Foptionz   if   e           k disk
     Frtehed    if   e           k disk
     Fpiritem   if   e           k disk
730aDF*abel     if   e           k disk
730aMFlabelw    if   e           k disk
710bD**Fpiruser   if   e           k disk
710bMFpiruser1  if   e           k disk
     Fexpsplbl  uf   e           k disk
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D$code            s             10
     DbegStartTime     s               z
     DendStartTime     s               z
     Dcount            s              5s 0
     Dtotsec           s              7s 0
     D  client         s             10
     D  cliloc         s             10
     *----------------------------------------------------------------
     *  Client IDs
     *----------------------------------------------------------------
      //copy qcopysrc,id#citylin
      /copy qcopysrc,id#fischer
      /copy qcopysrc,id#hkw
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          PR                  extpgm('GETCLIENT')
     D  client                       10
     D  cliloc                       10
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opzdta          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117
     *----------------------------------------------------------------
     *  Main line
     *
730 A*----------------------------------------------------------------
730 A*  Let the show begin .....
730 A*
730 AC     *entry        plist
730 AC                   parm                    $pcmd             8
730 AC                   parm                    $pwhse            3 0
730 AC                   parm                    $pbatid          11
730 A*
     *  Begin process.
     *  Read EXPSPLBL for update.
     *
      /Free
710cA    close expsplbl;
710cA    open expsplbl;
730 A    setll ($pwhse:$pbatid) expsplbl;
         dow not %eof(expsplbl);
730 D    //read expsplbl;
730 M      reade ($pwhse:$pbatid) expsplbl;
           if %eof(expsplbl);
             leave;
           endif;
710bA      if %subst(lbetext:1:1) = '*';
710bA        iter;
710bA      endif;

           // Pirtrand Info
           Exsr GetTranD;

           // Order Detail Info
           Exsr GetOrdDtl;

           // Determine Combo
           Exsr GetCombo;

710bA      if lbetext = *blanks;
710bA        lbetext = '*';
           endif;
           update lberec;
         enddo;

         //End Program
710cA    close expsplbl;
         eval *INLR = *on;
      /end-free
     *
     *----------------------------------------------------------------
     *  GETTRAND - Get PIRTRAND information
     *----------------------------------------------------------------
     *
      /Free
         begsr GETTRAND;
730aD      //setll (lbetr#) pirtrand;
730aD      //if %Equal (pirtrand);
730aM      setll (lbewhs: lbetr#) pirtrandw;
730aM      if %Equal (pirtrandw);
             count = 1;
             dow not %eof;
730aD           //reade (lbetr#) pirtrand;
730aD           //if %eof (pirtrand);
730aM           reade (lbewhs: lbetr#) pirtrandw;
730aM           if %eof (pirtrandw);
                   leave;
                endif;

          //Get Begin and end time
               if count = 1;
                  begStartTime = ptdsts;
                  totsec = ptdsec;
               else;
                  totsec += ptdsec;
               endif;
               count += 1;
               if count >= 10;
                leave;
               endif;
               endStartTime = ptdets;

          //Get user info
               Exsr  GetUsrNm;
             enddo;

             lbetotsec =totsec;
             lbestartts = begStartTime;
             lbeendts = endStartTime;
             lbeshftday = ptdshftday;
           endif;
         endsr;
      /end-free
     *----------------------------------------------------------------
     *  GETUSRNM - Get User Name
     *----------------------------------------------------------------
     *
      /Free
         begsr GETUSRNM;

710bD   //chain (ptdAddUsr) piruser;
710bD   // if %found (piruser);
710bM    chain (ptdempnum) piruser1;
710bM    if %found (piruser1);
            eval lbeEmpNo = usemp#;
            eval lbeFname = usfnam;
            eval lbeMInit = usinit;
            eval lbeLname = uslnam;
         else;
            eval lbeEmpNo = 0;
            eval lbeFname = '';
            eval lbeMInit = '';
710bD     //eval lbeLname = '';
710bM       eval lbeLname = 'Not Configured';
         endif;

         endsr;
      /end-free
     *
     *----------------------------------------------------------------
     *  GETORDDTL - Get Order Detail Information
     *----------------------------------------------------------------
      /Free
         begsr GETORDDTL;

710bD    //chain (lbewhs:lberid) ordh3;
710bD    //if %found (ordh3);
710bM    chain (lbewhs:lberid:lbeord) ordh4;
710bM    if %found (ordh4);
710bA      chain (lbewhs:ohord:lbedsq:lbeitm) ordd;
           if %found (ordd);
             lbeordqty1 = odqpk1;
             lbeordqty2 = odqpk2;
             lbeordqty3 = odqpk3;
           else;
             lbeordqty1 = 0;
             lbeordqty2 = 0;
             lbeordqty3 = 0;
           endif;
710bA      chain (ohwhse:ohord) ordhm;
710bA      if %found (ordhm);
710bA        lbecusa = hmmsc1;
710bA      else;
710bA        lbecusa = *blanks;
710bA      endif;
           endif;

         endsr;

      /End-Free
     *----------------------------------------------------------------
     *  GETCOMBO - Determine combo status
     *----------------------------------------------------------------
      /Free
        begsr GETCOMBO;

          lbecombo = 'N';
          //Get Client
          @getcl (client:cliloc);

          //Chain RTHED to get truck
          chain (lbewhs: lberid) rtehed;
          if %found (rtehed);

            //Get Pick Label Options
            chain ('*PICKLBL':lbewhs:rhtruk:lbezon) optionz;
            if %found (optionz);

            //Get Labels
730aD          //chain (lbelb#) label;
730aD          //if %found (label);
730aM          chain (lbewhs: lbelb#) labelw;
703aM          if %found (labelw);
                  if lbqpck > opclvl;
                     lbecombo = 'Y';
                  endif;

                  // Get Item Type
                  chain (lbewhs:lbeitm) piritem;
                //if lbqpck >= opclvl
                 //  or client = cityline
                 //  and ittype = 'S';
                 //  lbecombo = 'Y';
                //endif;
                  if lbqpck >= opclvl
                     or ittype = 'S'
                     and client <> fischr
                     and client <> hkw;
                     lbecombo = 'Y';
                  endif;
               endif;
            endif;
          endif;

        endsr;

      /End-Free
