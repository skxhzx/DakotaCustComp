     H DFTACTGRP(*NO) BNDDIR('QC2LE')

     *----------------------------------------------------------------
     *
     *  PRTSTMF      Print Stream File
     *
     *  Written by Scott Klement, August 9, 2005
     *
     *  To compile:
     *    CRTBNDRPG PGM(mylib/PRTSTMFR4) SRCFILE(mylib/QRPGLESRC)
     *    CRTCMD CMD(mylib/PRTSTMF) SRCFILE(mylib/QCMDSRC)
     *           PGM(mylib/PRTSTMFR4)
     *
     *  To run:
     *    PRTSTMF STMF('/home/klemscot/test.pdf') OUTQ(PRT01)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise
SUNa *    09/29/21  KDE  SUNa
     *      - Pass drawer for Truck Map on printer override
     *----------------------------------------------------------------

     FQSYSPRT   O    F  132        PRINTER USROPN

     D PRTSTMF         PR                  ExtPgm('PRTSTMF')
     D   stream                     256A   varying const
     D   outq                        10A   const
SUNaAd   drawer                       7    const
     D PRTSTMF         PI
     D   stream                     256A   varying const
     D   outq                        10A   const
SUNaAd   drawer                       7    const

      /copy qcopysrc,c#ifsio_h

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   command                  32702A   const options(*varsize)
     D   len                         15P 5 const
     D   igc                          3a   const options(*nopass)

     D ReportError     PR

     D cmd             s            500A   varying
     D fd              s             10I 0
     D buf             s            132A

      /free

         cmd = 'OVRPRTF FILE(QSYSPRT) '
                    +  'DEVTYPE(*USERASCII) '
                    +  'OUTQ(' + %trim(OutQ) + ')';
SUNaA    if drawer <> *blanks;
SUNaA      cmd = %trim(cmd) + ' DRAWER(' + %trim(Drawer) + ')';
SUNaA    endif;

         QCMDEXC(cmd: %len(cmd));

         open QSYSPRT;

         fd = open(stream: O_RDONLY);
         if (fd < 0);
            ReportError();
         endif;
         buf = *allx'20';
         dow (read(fd: %addr(Buf): %size(Buf)) > 0);
            except;
            buf = *allx'20';
         enddo;

         callp close(fd);
         close QSYSPRT;

         cmd = 'DLTOVR FILE(QSYSPRT)';
         QCMDEXC(cmd: %len(cmd));

         *inlr = *on;

      /end-free

     OQSYSPRT   E
     O                       buf                132


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ReportError():  Send an escape message explaining any errors
      *                 that occurred.
      *
      *  This function requires binding directory QC2LE in order
      *  to access the __errno() function.

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ReportError     B
     D ReportError     PI

     D get_errno       PR              *   ExtProc('__errno')
     D ptrToErrno      s               *
     D errno           s             10I 0 based(ptrToErrno)

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                  32767A   Const options(*varsize)
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 8192A   options(*varsize)

     D ErrorCode       DS                  qualified
     D  BytesProv              1      4I 0 inz(0)
     D  BytesAvail             5      8I 0 inz(0)

     D MsgKey          S              4A
     D MsgID           s              7A

      /free

         ptrToErrno = get_errno();
         MsgID = 'CPE' + %char(errno);

         QMHSNDPM( MsgID
                 : 'QCPFMSG   *LIBL'
                 : ' '
                 : 0
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ErrorCode         );
      /end-free
     P                 E
