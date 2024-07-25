500gA /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TBWAVEMSG   Send Truckbuilder Wave Messages
     *  07 February 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
510 A*    02/07/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     F*sfbranch if   e           k disk
     ftbWerrLog uf a e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D bId             s              2
     d bDesc           s             30
     d bhost           s              1
     d bredp           s              1
     d biiuf           s              1
     d beiuf           s              1
     d brobn           s              1
     d blbls           s              1
     d bdiv            s              3
     d client          s             10
     d clientloc       s             10
710bAD sq              c                   Const('''')
     d sqlstmt         s           2000
     d cmdString       s           3000

     *----------------------------------------------------------------
     *  External Prototypes
     *----------------------------------------------------------------
740 A /copy qcopysrc,p.qcmdexc

     *  GetClient
     D getclient       PR                  EXTPGM('GETCLIENT')
     D  iclient                      10
     D  iclientloc                   10

     *  GetBranch
     D getbranch       PR                  EXTPGM('GETBRANCH')
     D  ibid                          2
     D  idesc                        30
     d  ihost                         1
     d  iredp                         1
     d  iiiuf                         1
     d  ieiuf                         1
     d  irobn                         1
     d  ilbls                         1
     d  idiv                          3

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     none
     *
     *  Output parameters
     *
     *     iMsgId  -  TB000(Informational)  TB100(Severe)
     *     iWaveId -  Wave Id that TB generates
     *     iRte    -  Route
     *     iRtid   -  Route Id
     *     iTruk   -  Truck
     *     iDoor   -  Door
     *     iDrDpt  -  Door Department
     *     iRMsg   -  Return Message (*OK, or specific Message)
     *
     *----------------------------------------------------------------

     d TBWAVEMSG       pr                  extpgm('TBWAVEMSG')
     d  iWhse                         3  0
     d  iMsgId                      200
     d  iWaveId                      15
     d  iRte                          5
     d  iRtid                         5
     d  iTruk                        10
     d  iDoor                         3  0
     d  iDrDpt                        5
     d  ifromPgm                     10
     d  iPgmRtn                      20
     d  iRmsg                        50

     d TBWAVEMSG       pi
     d  iWhse                         3  0
     d  iMsgId                      200
     d  iWaveId                      15
     d  iRte                          5
     d  iRtid                         5
     d  iTruk                        10
     d  iDoor                         3  0
     d  iDrDpt                        5
     d  ifromPgm                     10
     d  iPgmRtn                      20
     d  iRmsg                        50

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get client id and branch code
      /free
             getclient(client:clientloc);
             if client=usfcorp;
               getBranch(bid:bdesc:bhost:bredp:biiuf:beiuf:brobn:blbls:bdiv);
             endif;

             // remove any previous error log record for this route/rtid
             exec sql delete from tbwerrlog where tewhse=:iWhse
                         and tewid=:iWaveid and terte=:irte
                         and tertid=:irtid;
             // Format and Send Message
             cmdString = 'TB001 ' + %trim(iMsgId) +
                         ' for, Division(' + bdiv + '), Wave (' +
                         %trim(iWaveId) + '), Route(' + %trim(iRte) +
                         '), Route Id(' + %trim(iRtid) + ')';
             if iTruk<>*blanks or iDrDpt<>*blanks or iDoor<>*zeros or
                ifromPgm<>*blanks or iPgmRtn<>*blanks;
               sqlStmt = %trim(sqlStMt) + '   Additonal Information:';
               if ifromPgm<>*blanks;
                 cmdString=%trim(cmdString) + ' Progam w/error(' +
                            %trim(ifromPgm) + ')';
               endif;
               if iPgmRtn<>*blanks;
                 cmdString=%trim(cmdSTring) + ' Routine(' + %trim(iPgmRtn) +
                                         ')';
               endif;
               if iTruk<>*blanks;
                 cmdString=%trim(cmdString) + ' Truck(' + %trim(iTruk) + ')';
               endif;
               if iDrDpt<>*blanks;
                 cmdSTring=%trim(cmdString) + ' Door Dpt(' + %trim(iDrDpt) +
                            ')';
               endif;
               if iDoor<>*zeros;
                 cmdString=%trim(cmdString) + ' Door(' + %char(iDoor) + ')';
               endif;
             endif;
             // Only write first error for given route
             setll (iWhse:iWaveid:iRte:iRtid) tbwerrlog;
             reade (iWhse:iWaveid:iRte:iRtid) tbwerrlog;
             if %eof(tbwerrlog) or not %equal(tbwerrlog);
               // Write error to Log for Wave Inquiry Screen in MRC
               tewhse=iWhse;
               tewid=iWaveid;
               terte=irte;
               tertid=irtid;
               tetruk=itruk;
               tedoor=idoor;
               tedrdpt=idrdpt;
               tefrmpgm=ifrompgm;
               tepgmrtn=ipgmrtn;
               temsgsnt=%trim(%subst(cmdstring:1:1000));
               temsgts=%timestamp();
               write(e) terec;
               if %error;
               endif;

               cmdString = %trim(cmdString);
      /end-free
     c*  call cl to send error message to QSYSOPR
     c                   CALL      'TBMSGCL'
     c                   parm                    cmdString
      /free
             endif;

             *inlr = *on;
             return;
      /end-free
