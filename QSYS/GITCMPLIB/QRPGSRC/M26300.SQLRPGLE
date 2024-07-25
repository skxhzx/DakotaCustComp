      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M26300     MAintenance Trax Email/Text info
     *  08 March  2018
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    03/08/18  KDE  7.20
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n
     d nxtseq          s              6  0
     d reccnt          s              6  0
     d wkcusalp        s             20
     d wkcusno         s             11  0

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  pEmail         s             50
     D  pCust          s             20
     D  pText          s             35
     D  paction        s              1
     D  pCarr          s             25
     D  pSeq           s              6  0
     D  pStpN          s              1
     D  pStpcE         s              1
     D  pStpcT         s              1
     D  pStpNp         s              1
     D  pStpSp         s              1
     D  pStpRp         s              1

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

700aAD tcrec         e ds                  extname(pircontact)
700aAD ohrec         e ds                  extname(ordh)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pAction     Action from MRC (A, C, D)
     *      pCust       Customer
     *      pEmail      Email Address
     *      pText       Text number
     *      pCarr       Carrier
     *      pSeq        Record Sequence
     *      pStpN       Stop Complete Code for Sends
     *      pStpCE      Stop Complete Email
     *      pStpCT      Stop Complete Text
     *      pStpNp      Stop Note Pics sent
     *      pStpSp      Stop Signature Pics sent
     *      pStpRp      Stop Return Pics sent
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pAction
     C                   parm                    pCust
     C                   parm                    pEmail
     C                   parm                    pText
     C                   parm                    pCarr
     C                   parm                    pSeq
     C                   parm                    pStpN
     C                   parm                    pStpcE
     C                   parm                    pStpcT
     C                   parm                    pStpNp
     C                   parm                    pStpSp
     C                   parm                    pStpRp
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        exsr Edit;
        if error = *off;
          exsr Update;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         pcust  = %xlate(xlower: xupper: pcust);
         pemail  = %xlate(xlower: xupper: pemail);
         ptext  = %xlate(xlower: xupper: ptext);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Edit              Edit validation
     *----------------------------------------------------------------

      /free
       begsr Edit;

        wkcusalp=*blanks;
        wkcusno=*zeros;
        // make sure either email or text sent
        if pEmail = *blanks and pText = *blanks;
           pMessage = 'Either Email or Text number MUST be present';
           error = *on;
           leavesr;
        else;
          // if email present do some basic syntax checks
          if pEmail <> *blanks;
            select;
               when %scan('@':pEmail:1) = 0;
                  pMessage = 'Email address missing @ sign';
                  error = *on;
                  leavesr;
               when %scan('@':pEmail:1) <> 0 and
                    %scan('@':pEmail:%scan('@':pEmail:1)+1) <>0;
                  pMessage = 'Only one @ sign allowed in email';
                  error = *on;
                  leavesr;
               when %scan(' ':%trimr(pEmail):1) <> 0;
                  pMessage = 'Blanks are not valid in email';
                  error = *on;
                  leavesr;
               when %scan('?':%trimr(pEmail):1) <> 0 or
                    %scan('!':%trimr(pEmail):1) <> 0 or
                    %scan('/':%trimr(pEmail):1) <> 0 or
                    %scan('\':%trimr(pEmail):1) <> 0 or
                  pMessage = 'Invalid characters in email';
                  error = *on;
                  leavesr;
               when %scan('@':pEmail:1) <> 0 and
                    %scan('.':pEmail:%scan('@':pEmail:1)) = 0;
                    pMessage = 'At least one period must follow ' +
                               '@ sign in email address';
                    error = *on;
               when %scan('@':pEmail:1) <> 0 and
                    %scan('.':pEmail:%scan('@':pEmail:1)) - 2 <0;
                    pMessage = 'There must be at least 1 character' +
                               'prior to the @ sign in your email';
                    error = *on;
                  leavesr;
               when %scan('.':pEmail:1) <> 0 and
                    %subst(pEmail:%scan('.':pEmail:1) + 1:1)='.';
                    pMessage = 'You cannot have two decimals ' +
                               'back to back in your email';
                    error = *on;
                  leavesr;
               when %scan('@':pEmail:1) <> 0 and
                    %subst(pEmail:%scan('@':pEmail:1) + 1:1)='.';
                    pMessage = 'You cannot have a decimal ' +
                               'next to the @ sign in your' +
                               ' email';
                    error = *on;
                  leavesr;
            endsl;
          endif;
          // if text number entered make sure it is valid
          if pText <> *blanks;
             if %check('0123456789':%trim(pText)) <>0 or
                %len(%trim(pText)) <> 10;
                pMessage = 'Text has invalid characters. ' +
                           'It must be a 10 digit ' +
                           'number with no spaces';
                error = *on;
             endif;
          endif;
        endif;

        // check to see whether to store customer number as
        // numeric or alpha based on what they send in ordh
        exec sql select * into :ohrec from ordh
                       where ohwhse=:pWhse and ohcust<>0
                     fetch first row only;
        if sqlStt = sqlSuccess;
           if %check('0123456789':%trim(pCust)) <> 0 or
              %trim(pCust) = '';
              tccusalp = pCust;
              tccusno = *zeros;
           else;
              monitor;
                tccusno = %dec(%trim(pCust):11:0);
              on-error;
                tccusno = *zeros;
              endmon;
              tccusalp=*blanks;
           endif;
        else;
           tccusalp = pCust;
           tccusno = *zeros;
        endif;
        wkcusalp = tccusalp;
        wkcusno = tccusno;

        // return error if same email address used on another record
        reccnt=0;
        if tccusalp<>*blanks;
        exec sql select count(*) into :reccnt
                 from pircontact
                    where tcwhse=:pWhse and
                          tcemail=:pemail and
                          ltrim(rtrim(tccusalp))=:wkcusalp
                          and ((:paction='U' and tcseq<>:pseq)
                          or :pAction<>'U' and tcseq=:pseq);
        else;
        exec sql select count(*) into :reccnt
                 from pircontact
                    where tcwhse=:pWhse and
                          tcemail=:pemail and
                          tccusno=:tccusno
                          and ((:paction='U' and tcseq<>:pseq)
                          or :pAction<>'U' and tcseq=:pseq);
        endif;
        if sqlstt = sqlSuccess and reccnt<>0 and pAction<>'D';
           pMessage = 'Email address and csutomer combination ' +
                      'is already defined.  Please modify the ' +
                      'existing definition';
           error=*on;
           leavesr;
        endif;

        // return error if same cell phone used on another record
        reccnt=0;
        if tccusalp<>*blanks;
        exec sql select count(*) into :reccnt
                 from pircontact
                    where tcwhse=:pWhse and
                          :ptext=substring(tctext,1,10) and
                          ltrim(rtrim(tccusalp))=:wkcusalp
                          and ((:paction='U' and tcseq<>:pseq)
                          or :pAction<>'U' and tcseq=:pseq);
        else;
        exec sql select count(*) into :reccnt
                 from pircontact
                    where tcwhse=:pWhse and
                          :ptext=substring(tctext,1,10) and
                          tccusno=:tccusno
                          and ((:paction='U' and tcseq<>:pseq)
                          or :pAction<>'U' and tcseq=:pseq);
        endif;
        if sqlstt = sqlSuccess and reccnt<>0 and pAction<>'D';
           pMessage = 'Cell phone and customer combination ' +
                      'already exist.  Please modify the ' +
                      'existing definition';
           error=*on;
           leavesr;
        endif;

        // If Text number is sent you must select a Carrier
        if pText <> *blanks and pCarr=*blanks;
           pMessage = 'If Text number is entered you ' +
                      'must select a Carrier';
           error=*on;
           leavesr;
        endif;

        // If None selected for Stop Completed allow no other settings
        if pStpN = 'N' and (pStpcE<>'N' or pStpcT<>'N' or
           pStpNp<>'N' or pStpSp<>'N' or pStpRp<>'N');
           pMessage = 'No Email, Text or Pic options are ' +
                      'valid when Never is selected for Notification ' +
                      'Stop Completed';
           error=*on;
           leavesr;
        endif;
        // If confirm that Stop Completed action and email action good
        if pStpN <> 'N' and pStpN <> 'A' and pStpN<>'R';
           pMessage = 'Stop Completed Action(' + %trim(pStpn) +
                      ') is invalid';
           error=*on;
           leavesr;
        else;
           // When valid selection Email and Text should correspond
           if (pStpN = 'R' or pStpN = 'A') and
              (pStpcE <> 'E' and pStpcT <> 'T');
                 pMessage = 'Since an action for Stop Completed has ' +
                            'been selected you must specify ' +
                            'email and/or text';
           error=*on;
           leavesr;
           endif;
           // also check to be sure email exist if Email selected
           // // or text exist if text selected
           if (pStpN = 'R' or pStpN = 'A') and
              (pStpcE = 'E' and pEmail=*blanks);
                 pMessage = 'Email must be entered to send ' +
                            'notification by email';
           error=*on;
           leavesr;
           endif;
           if (pStpN = 'R' or pStpN = 'A') and
              (pStpcT = 'T' and (pText=*blanks or pCarr=*blanks));
                 pMessage = 'Phone number and Cell Carrier must be ' +
                            'entered to use notification by text';
           error=*on;
           leavesr;
           endif;
        endif;

        // Confirm that Stop Note Pics is valid
        if pStpNp <> 'Y' and pStpNp <> 'N';
           pMessage = 'Stop Note Pics value(' + %trim(pStpNp) +
                      ') is invalid';
           error=*on;
           leavesr;
        endif;

        // Confirm that Stop Signature Pics code is valid code
        if pStpSp <> 'N' and pStpSp <> 'Y';
           pMessage = 'Stop Signature Pics value(' + %trim(pStpSp) +
                      ') is invalid';
           error=*on;
           leavesr;
        endif;

        // Confirm that Stop Return Pics code is valid code
        if pStpRp <> 'N' and pStpRp <> 'Y';
           pMessage = 'Stop Returns Pics value(' + %trim(pStpRp) +
                      ') is invalid';
           error=*on;
           leavesr;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Update            Add/Delete Itemsub record
     *----------------------------------------------------------------

      /free
       begsr Update;

        error = *off;
        if pAction = 'A' or pAction = 'U';
           if pAction = 'U';
              exec sql select * into :tcrec
                 from pircontact
                   where tcwhse=:pWhse and tcseq=:pseq;
           else;
             // for adds setup additional ket fields
             tcwhse = pWhse;
             exec sql select tcseq into :nxtSeq
                   from pircontact
                     where tcwhse=:pWhse
                     order by tcseq desc
                     fetch first row only;
              if sqlStt = sqlSuccess;
                 nxtSeq = nxtSeq + 1;
              else;
                 nxtSeq = 1;
              endif;
              tcseq = nxtseq;
           endif;
        endif;
        tcemail = pEmail;
        tcText = %trim(pText) + %trim(pCarr);
        tccarr = pCarr;
        tcStpN = pStpN;
        tcStpNp=pStpNp;
        tcStpSp=pStpSp;
        tcStpRp=pStpRp;
        tccusalp=wkcusalp;
        tccusno=wkcusno;
        // Email/Text/Both flag
        select;
           when pStpcE = 'E' and pStpcT='T';
              tcstpctyp='B';        // Send both email and text
           when pStpcE = 'E';
              tcstpctyp = 'E';      // Send email only
           when pstpcT = 'T';
              tcstpctyp = 'T';      // send text only
           other;
              tcstpctyp = 'X';      // no selection
        endsl;


        select;
          when paction = 'A';
            exec sql insert into pirContact
                 values(:tcwhse,
                        :tcseq,
                        :tccusno,
                        :tccusalp,
                        :tcemail,
                        :tctext,
                        :tccarr,
                        :tcstpN,
                        :tcstpnp,
                        :tcstpsp,
                        :tcstprp,
                        :tcstpip,
                        :tcstpctyp,
                        :tcstprte);
          when paction = 'U';
            exec sql update pirContact set
               tcwhse = :tcwhse,
               tcseq  = :tcseq,
               tccusno= :tccusno,
               tccusalp=:tccusalp,
               tcemail= :tcemail,
               tctext = :tctext,
               tccarr = :tccarr,
               tcstpn = :tcstpn,
               tcstpnp=:tcstpnp,
               tcstpsp=:tcstpsp,
               tcstprp=:tcstprp,
               tcstpip=:tcstpip,
              tcstpctyp=:tcstpctyp,
              tcstprte=:tcstprte
                where tcwhse=:pWhse and tcseq=:pSeq;
          when paction = 'D';
            exec sql delete
                 from pircontact
                 where tcwhse = :pwhse
                   and tcseq = :pseq;
            If sqlstt = sqlSuccess;
            else;
            endif;
          other;
        endsl;

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
